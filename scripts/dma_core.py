"""RAW C2H-only backend; lifecycle copied from the exercised 2026-10-02 probe.

A five-second observation timeout requests cancellation, then retains storage
and waits for completion without a hard deadline. Never terminate a pending run.
"""
import ctypes as C
import re
import time
import uuid

ADDRESS, SIZE = 0x100000, 65536
DRIVER_HASH = '5cdbaf12776444e45ad3cb837e42b4d2487c3bffd9acac9bb08515ae980f8396'
PENDING = 997


class Overlapped(C.Structure):
    _fields_ = [('Internal', C.c_size_t), ('InternalHigh', C.c_size_t),
                ('Offset', C.c_uint32), ('OffsetHigh', C.c_uint32),
                ('hEvent', C.c_void_p)]


def select_device(paths):
    if len(paths) != 1 or not re.search(r'ven_10ee&dev_(?:8028|8038)(?:&|#)', paths[0].lower()):
        raise RuntimeError(f'Require exactly one present XDMA interface for 10EE:8028/8038: {paths}')
    return paths[0]


def aligned_buffer():
    storage = C.create_string_buffer(SIZE + 4095)
    address = (C.addressof(storage) + 4095) & ~4095
    if address % 4096 or address + SIZE > C.addressof(storage) + len(storage):
        raise RuntimeError('Aligned buffer does not contain the full RAW slot')
    C.memset(address, 0xCC, SIZE)
    return storage, address


def validate_identifiers(words):
    # Fixed compatibility/diagnostic image, checked immediately before submission.
    expected = {0x0000: 0x1FC00006, 0x1000: 0x1FC10006}
    if words != expected:
        raise RuntimeError(f'Control BAR identifiers invalid; no further DMA submitted: {words}')


def transfer(api, direction, emit):
    """The only I/O lifecycle; shared by native backend and offline fault tests."""
    callback = emit
    def emit(event):
        try:
            callback(event)
        except Exception:
            pass  # Logging cannot interrupt pending I/O retention and drain.
    token = api.open(direction)
    pending = False
    try:
        pending = True  # Preserve storage even if an unexpected exception interrupts submission.
        code = api.start(token, direction)
        pending = code == PENDING
        if code not in (0, PENDING):
            raise OSError(code, 'I/O submission failed')
        if pending:
            if not api.wait(token, 5000):
                raise TimeoutError('5-second observation deadline; no further DMA will be submitted')
            pending = False  # Manual-reset completion event has signaled.
        count = api.result(token)
        emit({'direction': direction, 'address': hex(ADDRESS), 'bytes': count})
        if count != SIZE:
            raise ValueError(f'{direction}: short transfer {count}/{SIZE}')
        return api.data(token)
    finally:
        if pending:
            # Do not let timeout handling release a buffer still owned by a driver.
            try:
                code = api.cancel(token)
                emit({'cancel_requested': True, 'cancel_error': code})
            except Exception as error:
                emit({'cancel_error': str(error)})
            emit({'waiting_for_completion': True, 'instruction': 'Do not kill process or reconfigure FPGA'})
            warned = False
            while True:
                try:
                    if api.wait(token, 1000):
                        break
                except Exception as error:
                    if not warned:
                        emit({'wait_error': str(error), 'buffers_retained': True})
                        warned = True
                    time.sleep(1)
            try:
                emit({'completion_after_cancel': api.result(token)})
            except Exception as error:
                emit({'completion_after_cancel_error': str(error)})
        api.close(token)


class Native:
    def __init__(self, base):
        if C.sizeof(C.c_void_p) != 8:
            raise RuntimeError('Requires 64-bit Python')
        assert C.sizeof(Overlapped) == 32 and Overlapped.Offset.offset == 16
        self.base = base
        self.k = C.WinDLL('kernel32', use_last_error=True)
        ptr, u32, boolean = C.c_void_p, C.c_uint32, C.c_int
        signatures = {
            'CreateFileW': (ptr, [C.c_wchar_p, u32, u32, ptr, u32, u32, ptr]),
            'CreateEventW': (ptr, [ptr, boolean, boolean, C.c_wchar_p]),
            'ReadFile': (boolean, [ptr, ptr, u32, C.POINTER(u32), C.POINTER(Overlapped)]),
            'GetOverlappedResult': (boolean, [ptr, C.POINTER(Overlapped), C.POINTER(u32), boolean]),
            'WaitForSingleObject': (u32, [ptr, u32]),
            'CancelIoEx': (boolean, [ptr, C.POINTER(Overlapped)]),
            'SetFilePointerEx': (boolean, [ptr, C.c_int64, C.POINTER(C.c_int64), u32]),
            'CloseHandle': (boolean, [ptr]),
        }
        for name, (result, args) in signatures.items():
            fn = getattr(self.k, name)
            fn.restype, fn.argtypes = result, args

    def preflight(self, emit):
        """Only ordinary identifier reads, never clear-on-read status registers."""
        handle = self.k.CreateFileW(self.base + '\\control', 0x80000000, 0, None,
                                    3, 0x80, None)
        if handle == C.c_void_p(-1).value:
            raise C.WinError(C.get_last_error())
        words = {}
        try:
            for offset in (0x0000, 0x1000):
                position, count, value = C.c_int64(), C.c_uint32(), C.c_uint32()
                if not self.k.SetFilePointerEx(handle, offset, C.byref(position), 0):
                    raise C.WinError(C.get_last_error())
                if position.value != offset:
                    raise RuntimeError('Unexpected control-file offset; no further DMA submitted')
                if not self.k.ReadFile(handle, C.byref(value), 4, C.byref(count), None):
                    raise C.WinError(C.get_last_error())
                emit({'preflight_offset': hex(offset), 'bytes': count.value,
                      'value': hex(value.value)})
                if count.value != 4:
                    raise RuntimeError('Short control identifier read; no further DMA submitted')
                words[offset] = value.value
                if value.value == 0xFFFFFFFF:
                    raise RuntimeError('Control BAR returned FFFFFFFF; no further DMA submitted')
            validate_identifiers(words)
        finally:
            self.k.CloseHandle(handle)

    @staticmethod
    def discover():
        cm = C.WinDLL('cfgmgr32')
        guid = (C.c_byte * 16).from_buffer_copy(uuid.UUID('74c7e4a9-6d5d-4a70-bc0d-20691dff9e9d').bytes_le)
        size_fn, list_fn = cm.CM_Get_Device_Interface_List_SizeW, cm.CM_Get_Device_Interface_ListW
        size_fn.restype = list_fn.restype = C.c_uint32
        size_fn.argtypes = [C.POINTER(C.c_uint32), C.c_void_p, C.c_wchar_p, C.c_uint32]
        list_fn.argtypes = [C.c_void_p, C.c_wchar_p, C.c_void_p, C.c_uint32, C.c_uint32]
        for _ in range(3):
            length = C.c_uint32()
            status = size_fn(C.byref(length), C.byref(guid), None, 0)  # PRESENT
            if status:
                raise RuntimeError(f'Interface list size failed: {status:#x}')
            buf = C.create_unicode_buffer(max(1, length.value))
            status = list_fn(C.byref(guid), None, buf, len(buf), 0)
            if status == 0x1A:  # CR_BUFFER_SMALL: topology changed during enumeration.
                continue
            if status:
                raise RuntimeError(f'Interface enumeration failed: {status:#x}')
            return select_device([p for p in buf[:].split('\0') if p])
        raise RuntimeError('Interface list changed repeatedly; stop')

    def open(self, direction):
        if direction != 'c2h_0':
            raise ValueError('Only c2h_0 reads are permitted')
        storage, address = aligned_buffer()
        handle = self.k.CreateFileW(self.base + '\\' + direction, 0x80000000, 0, None,
                                    3, 0x40000080, None)  # OVERLAPPED | NORMAL
        if handle == C.c_void_p(-1).value:
            raise C.WinError(C.get_last_error())
        event = self.k.CreateEventW(None, True, False, None)
        if not event:
            error = C.get_last_error()
            self.k.CloseHandle(handle)
            raise C.WinError(error)
        ov = Overlapped(Offset=ADDRESS, OffsetHigh=0, hEvent=event)
        return {'handle': handle, 'storage': storage, 'address': address, 'ov': ov}

    def start(self, t, direction):
        if direction != 'c2h_0':
            raise ValueError('Only c2h_0 reads are permitted')
        count = C.c_uint32()
        ok = self.k.ReadFile(t['handle'], t['address'], SIZE, C.byref(count), C.byref(t['ov']))
        return 0 if ok else C.get_last_error()

    def wait(self, t, milliseconds):
        status = self.k.WaitForSingleObject(t['ov'].hEvent, milliseconds)
        if status not in (0, 258):
            raise C.WinError(C.get_last_error())
        return status == 0

    def result(self, t):
        count = C.c_uint32()
        if not self.k.GetOverlappedResult(t['handle'], C.byref(t['ov']), C.byref(count), False):
            raise C.WinError(C.get_last_error())
        return count.value

    def cancel(self, t):
        return 0 if self.k.CancelIoEx(t['handle'], C.byref(t['ov'])) else C.get_last_error()

    def data(self, t):
        return C.string_at(t['address'], SIZE)

    def close(self, t):
        self.k.CloseHandle(t['ov'].hEvent)
        self.k.CloseHandle(t['handle'])
