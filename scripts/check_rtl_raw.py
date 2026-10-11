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
    expected_epoch=0x1234, expected_config_id=0x504E3039)
assert len(frames) == 1, report
frame = frames[0]
assert frame.header.sample_count == 16320
assert frame.header.test_mode == 6
# The RTL fixture begins A at the official PN9 phase zero and B at phase193.
# Its independent published parallel generator is also checked sample-for-sample.
from test_decode_raw import pn9_reference
reference = pn9_reference(16320 + 193)
assert frame.channel_a == tuple(reference[:16320])
assert frame.channel_b == tuple(reference[193:])
pn9 = decode_raw.pn9_analysis(frame)
assert pn9['pn9_check_pass'], pn9
report.update(result='RAW_RTL_HOST_CROSSCHECK_PASS',
              source='actual_RTL_simulation_frame_not_board_DMA', pn9=pn9)
if args.output:
    args.output.write_text(json.dumps(report, indent=2), encoding='utf-8')
print(json.dumps(report, indent=2))
