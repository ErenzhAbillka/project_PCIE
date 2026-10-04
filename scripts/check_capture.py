"""Generate the 4 KiB FPGA pattern or verify a raw XDMA C2H capture."""
import argparse
import struct
from pathlib import Path

def expected_capture():
    lfsr = 1
    words = []
    for _ in range(1024):
        words.append(lfsr)
        feedback = ((lfsr >> 15) ^ (lfsr >> 13) ^ (lfsr >> 12) ^ (lfsr >> 10)) & 1
        lfsr = ((lfsr << 1) | feedback) & 0xffff
    return struct.pack('<1024I', *words)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('file', type=Path)
    parser.add_argument('--generate', action='store_true')
    args = parser.parse_args()
    expected = expected_capture()
    assert len(expected) == 4096 and struct.unpack('<4I', expected[:16]) == (1, 2, 4, 8)
    if args.generate:
        args.file.write_bytes(expected)
        print('Wrote expected 4096-byte little-endian FPGA pattern')
    else:
        actual = args.file.read_bytes()
        if actual != expected:
            mismatch = next((i for i, (a, b) in enumerate(zip(actual, expected)) if a != b), min(len(actual), len(expected)))
            raise SystemExit(f'FAIL: {len(actual)} bytes; first difference at byte {mismatch:#x}')
        print('PASS: all 1024 FPGA samples match')
