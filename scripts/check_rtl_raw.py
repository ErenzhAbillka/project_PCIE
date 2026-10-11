"""Cross-check the RAW RTL's actual $fwrite frame against the host contract.

This is a simulation artifact check, not evidence of a physical DMA read.
"""
import argparse
import json
from pathlib import Path
import struct
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import decode_raw

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('hex_words', type=Path)
parser.add_argument('--output', type=Path)
args = parser.parse_args()
words = [int(line.strip(), 16) for line in args.hex_words.read_text().splitlines() if line.strip()]
assert len(words) == 16384, len(words)
frames, report = decode_raw.decode_bytes(struct.pack('<16384I', *words),
    expected_epoch=0x1234, expected_config_id=0xABCD)
assert len(frames) == 1, report
frame = frames[0]
assert frame.header.sample_count == 16320
assert frame.header.test_mode == 15
for samples, start in ((frame.channel_a, 3), (frame.channel_b, 8190)):
    assert all(value == ((start - i + 8192) % 16384) - 8192
               for i, value in enumerate(samples))
ramp = decode_raw.ramp_analysis(frame)
assert ramp['ramp_check_pass'], ramp
report.update(result='RAW_RTL_HOST_CROSSCHECK_PASS',
              source='actual_RTL_simulation_frame_not_board_DMA', ramp=ramp)
if args.output:
    args.output.write_text(json.dumps(report, indent=2), encoding='utf-8')
print(json.dumps(report, indent=2))
