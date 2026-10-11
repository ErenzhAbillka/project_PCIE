"""Single 64-KiB RAW C2H read. Default: offline self-test; --run-raw accesses hardware.

Requires independently verified bit, BAR layout, DDR completion and VIO states.
No device writes, retries, resets, PnP changes or driver changes are performed here.
A timeout stops new requests but may wait indefinitely for safe I/O completion.
"""
import argparse
import ctypes as C
import hashlib
import json
from pathlib import Path
import signal
import time
import uuid

import dma_core as core


def run():
    out = Path(__file__).resolve().parent / (
        'raw_c2h_' + time.strftime('%Y%m%d_%H%M%S') + '_' + uuid.uuid4().hex[:8])
    out.mkdir()
    print(f'OUTPUT={out}', flush=True)
    started = time.monotonic()
    result = {'address': hex(core.ADDRESS), 'requested_bytes': core.SIZE,
              'operation': 'single_c2h_read', 'observation_timeout_s': 5,
              'cancellation_drain_has_hard_timeout': False,
              'script_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'core_sha256': hashlib.sha256(Path(core.__file__).read_bytes()).hexdigest()}
    with (out / 'events.jsonl').open('w', encoding='utf-8', buffering=1) as log:
        def emit(event):
            row = json.dumps({'time': time.time(), **event})
            try:
                print(row, flush=True)
            except OSError:
                pass
            try:
                log.write(row + '\n')
            except OSError:
                pass  # Logging must never release an in-flight request's storage.

        for sig in (signal.SIGINT, signal.SIGBREAK):
            signal.signal(sig, lambda *_: emit({
                'interrupt_ignored': 'Preserving in-flight storage; do not kill or reconfigure FPGA'}))
        try:
            installed = Path(r'C:\Windows\System32\drivers\XDMA.sys')
            result['driver_sha256'] = hashlib.sha256(installed.read_bytes()).hexdigest()
            if result['driver_sha256'] != core.DRIVER_HASH:
                raise RuntimeError('Driver disk hash changed; no device access submitted')
            api = core.Native(core.Native.discover())
            result['device'] = api.base
            emit({'device': api.base, 'address': hex(core.ADDRESS), 'length': core.SIZE,
                  'driver_sha256': result['driver_sha256']})
            api.preflight(emit)
            data = core.transfer(api, 'c2h_0', emit)
            if len(data) != core.SIZE:
                raise ValueError(f'Unexpected saved data length: {len(data)}')
            raw = out / 'raw.bin'
            raw.write_bytes(data)
            result.update(result='RAW_C2H_READ_PASS', received_bytes=len(data),
                          raw_file=str(raw), raw_sha256=hashlib.sha256(data).hexdigest(),
                          validation='Read completion only; validate RAW1 epoch/config/ramp and recorded VIO states separately')
        except Exception as error:
            result.update(result='FAIL', error=repr(error))
        result['elapsed_s'] = time.monotonic() - started
        (out / 'result.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
        emit(result)
    return 0 if result['result'] == 'RAW_C2H_READ_PASS' else 1


def self_test():
    assert core.ADDRESS == 0x100000 and core.SIZE == 65536
    assert C.sizeof(core.Overlapped) == 32 and core.Overlapped.Offset.offset == 16
    for low_bits in range(4096):
        base = 0x100000 + low_bits
        aligned = (base + 4095) & ~4095
        assert base <= aligned and aligned + core.SIZE <= base + core.SIZE + 4095
    storage, address = core.aligned_buffer()
    assert len(storage) == core.SIZE + 4095 and address % 4096 == 0
    assert C.string_at(address, core.SIZE) == b'\xCC' * core.SIZE
    payload = bytes(range(256)) * 256
    C.memmove(address, payload, core.SIZE)
    assert C.string_at(address, core.SIZE) == payload
    try:
        core.Native.open(object(), 'h2c_0')
    except ValueError:
        pass
    else:
        raise AssertionError('Write direction was accepted')

    class ReadOnlyKernel:
        def __init__(self):
            self.closed = []
        def CreateFileW(self, path, access, share, security, creation, flags, template):
            assert path == 'OFFLINE\\c2h_0' and access == 0x80000000
            assert creation == 3 and flags == 0x40000080
            return 123
        def CreateEventW(self, security, manual, initial, name):
            assert manual and not initial
            return 456
        def ReadFile(self, handle, address, size, count, overlapped):
            assert handle == 123 and size == 65536 and address % 4096 == 0
            offset = C.cast(overlapped, C.POINTER(core.Overlapped)).contents
            assert offset.Offset == 0x100000 and offset.OffsetHigh == 0 and offset.hEvent == 456
            C.memmove(address, payload, size)
            C.cast(count, C.POINTER(C.c_uint32)).contents.value = size
            return True
        def GetOverlappedResult(self, handle, overlapped, count, wait):
            assert handle == 123 and not wait
            C.cast(count, C.POINTER(C.c_uint32)).contents.value = 65536
            return True
        def CloseHandle(self, handle):
            self.closed.append(handle)
            return True
    native = core.Native.__new__(core.Native)
    native.base, native.k = 'OFFLINE', ReadOnlyKernel()
    assert core.transfer(native, 'c2h_0', lambda _: None) == payload
    assert native.k.closed == [456, 123]

    class Fake:
        def __init__(self, code=core.PENDING, waits=(True,), count=core.SIZE,
                     error=None, cancel=0):
            self.code, self.waits, self.count, self.error = code, iter(waits), count, error
            self.cancel_code, self.trace, self.completed = cancel, [], code != core.PENDING
        def open(self, direction):
            assert direction == 'c2h_0'
            self.trace.append('open')
            return {'storage': storage}
        def start(self, token, direction):
            assert direction == 'c2h_0' and token['storage'] is storage
            self.trace.append('start')
            return self.code
        def wait(self, token, ms):
            assert token['storage'] is storage
            self.trace.append(('wait', ms))
            self.completed = next(self.waits)
            return self.completed
        def result(self, token):
            assert self.completed
            self.trace.append('result')
            if self.error:
                raise self.error
            return self.count
        def cancel(self, token):
            assert not self.completed and token['storage'] is storage
            self.trace.append('cancel')
            return self.cancel_code
        def data(self, token):
            assert self.completed
            return C.string_at(address, core.SIZE)
        def close(self, token):
            assert self.completed, 'Released storage while I/O was pending'
            self.trace.append('close')

    cases = [
        (Fake(code=0), None), (Fake(), None),
        (Fake(code=5), OSError), (Fake(count=core.SIZE - 4), ValueError),
        (Fake(error=OSError(31, 'device error')), OSError),
        (Fake(waits=(False, False, True), error=OSError(995, 'cancelled')), TimeoutError),
        (Fake(waits=(False, True), cancel=5), TimeoutError),
    ]
    for api, expected in cases:
        events = []
        try:
            actual = core.transfer(api, 'c2h_0', events.append)
            assert actual == payload
        except Exception as error:
            assert expected and isinstance(error, expected), (expected, error)
        else:
            assert expected is None
        assert api.trace[-1] == 'close' and api.trace.count('start') == 1
        if expected is TimeoutError:
            assert api.trace.count('cancel') == 1
            assert api.trace.index('cancel') < api.trace.index('result') < api.trace.index('close')
            assert any(e.get('waiting_for_completion') for e in events)
            assert ('wait', 5000) in api.trace and ('wait', 1000) in api.trace

    broken_log_api = Fake(waits=(False, False, True), error=OSError(995, 'cancelled'))
    broken_log_events = []
    def broken_logger(event):
        broken_log_events.append(event)
        raise ValueError('I/O operation on closed stream')
    try:
        core.transfer(broken_log_api, 'c2h_0', broken_logger)
    except TimeoutError:
        pass
    else:
        raise AssertionError('Logger failure replaced the pending I/O timeout')
    assert broken_log_api.trace == ['open', 'start', ('wait', 5000), 'cancel',
                                    ('wait', 1000), ('wait', 1000), 'result', 'close']
    assert len(broken_log_events) == 3
    assert broken_log_events[0]['cancel_requested']
    assert broken_log_events[1]['waiting_for_completion']
    assert 'completion_after_cancel_error' in broken_log_events[2]

    core.validate_identifiers({0: 0x1FC00006, 0x1000: 0x1FC10006})
    for words in ({}, {0: 0xFFFFFFFF, 0x1000: 0xFFFFFFFF}):
        try:
            core.validate_identifiers(words)
        except RuntimeError:
            pass
        else:
            raise AssertionError('Invalid BAR identifier accepted')
    for device_id in ('8028', '8038'):
        path = rf'\\?\pci#ven_10ee&dev_{device_id}&subsys_000710ee#example'
        assert core.select_device([path]) == path
    for paths in ([], [path, path], [path.replace('8038', '8039')],
                  [path.replace('8038', '80381')]):
        try:
            core.select_device(paths)
        except RuntimeError:
            pass
        else:
            raise AssertionError('Ambiguous or wrong device accepted')
    print('RAW_C2H_OFFLINE_PASS: 64-KiB aligned bounds/data, read-only guard, short/error I/O, timeout retention/drain with failing logger, BAR/unique-target guards; no device access')
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run-raw', action='store_true',
                        help='HARDWARE: one C2H 65536-byte read at DDR 0x100000')
    args = parser.parse_args()
    raise SystemExit(run() if args.run_raw else self_test())
