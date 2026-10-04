"""Decode the 4096-byte C2H snapshot at card address 0 into signed ADC pairs."""
import argparse
import csv
import struct
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('capture', type=Path)
parser.add_argument('--output', type=Path)
args = parser.parse_args()
raw = args.capture.read_bytes()
if len(raw) != 4096:
    parser.error(f'Expected 4096 bytes (1024 A/B pairs), got {len(raw)}')
pairs = list(struct.iter_unpack('<hh', raw))
if any(not (-8192 <= a <= 8191 and -8192 <= b <= 8191) for a, b in pairs):
    parser.error('Values exceed signed 14-bit range; check capture format and loaded bitstream')
output = args.output or args.capture.with_suffix('.csv')
with output.open('w', newline='', encoding='utf-8-sig') as stream:
    writer = csv.writer(stream)
    writer.writerow(['sample', 'time_us', 'channel_A', 'channel_B'])
    writer.writerows((i, f'{i / 125:.3f}', a, b) for i, (a, b) in enumerate(pairs))
print(f'Decoded 1024 pairs at 125 MSPS into {output}')
print('Values are ADC codes; conversion to volts requires front-end calibration.')
