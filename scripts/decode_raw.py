"""Validate/decode RAW1 ADC slots from a little-endian XDMA C2H file.

No hardware or registers are accessed. RAW1 currently means one captured trace
per reset; only state-bracketed files with the requested epoch are called fresh.
"""
from __future__ import annotations

import argparse
import csv
from dataclasses import asdict, dataclass
import hashlib
import importlib.util
import json
from pathlib import Path
import struct

FRAME_WORDS = 16384
FRAME_BYTES = FRAME_WORDS * 4
HEADER_WORDS = FOOTER_WORDS = 32
MAX_SAMPLES = FRAME_WORDS - HEADER_WORDS - FOOTER_WORDS
FOOTER_START = FRAME_WORDS - FOOTER_WORDS
MAGIC = 0x52415731
COMMIT = 0x434F4D54
END = 0x454E4421
CONFIG_FLAGS = 0x6
MASK32 = 0xFFFFFFFF


@dataclass(frozen=True)
class RawHeader:
    frame_seq: int
    sample_count: int
    trace_id: int
    epoch: int
    sample_rate_hz: int
    trace_period_samples: int
    capture_stride: int
    test_mode: int
    error_flags: int
    config_flags: int
    config_id: int
    adc_bits: int
    version: int


@dataclass(frozen=True)
class RawFrame:
    slot: int
    header: RawHeader
    channel_a: tuple[int, ...]
    channel_b: tuple[int, ...]
    payload_xor32: int


def _signed16(value):
    return value - 65536 if value & 0x8000 else value


def _is_sign_extended_14(value):
    return value >> 14 == (3 if value & 0x2000 else 0)


def _decode_slot(words, slot, expected_epoch=None, expected_config_id=None):
    if words[0] != MAGIC:
        raise ValueError('not_RAW1')
    if words[2] != FRAME_WORDS:
        raise ValueError('frame_word_count')
    h = RawHeader(words[1], *words[3:15])
    if not 1 <= h.sample_count <= MAX_SAMPLES:
        raise ValueError('sample_count')
    if h.version != 1 or h.adc_bits != 14 or h.config_flags != CONFIG_FLAGS:
        raise ValueError('unsupported_format_or_channel_packing')
    if h.sample_rate_hz <= 0 or h.trace_period_samples < h.sample_count:
        raise ValueError('sample_timing_configuration')
    if (h.frame_seq, h.trace_id, h.capture_stride) != (0, 0, 1):
        raise ValueError('not_current_single_shot_contract')
    if slot != h.frame_seq % 16:
        raise ValueError('physical_ring_slot')
    if h.test_mode not in (0, 15):
        raise ValueError('unsupported_ADC_test_mode')
    if h.error_flags:
        raise ValueError('frame_error_flags')
    if words[15] != (h.frame_seq ^ MASK32):
        raise ValueError('header_sequence_complement')
    if any(words[16:HEADER_WORDS]):
        raise ValueError('nonzero_reserved_header')
    if expected_epoch is not None and h.epoch != expected_epoch:
        raise ValueError('epoch_mismatch')
    if expected_config_id is not None and h.config_id != expected_config_id:
        raise ValueError('config_id_mismatch')
    footer = words[FOOTER_START:]
    expected = (MAGIC, h.frame_seq, h.frame_seq ^ MASK32, h.trace_id,
                h.epoch, h.sample_count, h.error_flags, h.config_flags)
    if footer[:8] != expected:
        raise ValueError('header_footer_mismatch')
    if footer[28:] != (COMMIT, h.frame_seq, h.frame_seq ^ MASK32, END):
        raise ValueError('missing_or_torn_commit')
    if any(footer[10:28]):
        raise ValueError('nonzero_reserved_footer')
    payload = words[HEADER_WORDS:HEADER_WORDS + h.sample_count]
    if any(words[HEADER_WORDS + h.sample_count:FOOTER_START]):
        raise ValueError('nonzero_payload_padding')
    payload_xor = 0
    channel_a, channel_b = [], []
    for index, word in enumerate(payload):
        payload_xor ^= word
        a, b = word & 0xFFFF, word >> 16
        if not _is_sign_extended_14(a) or not _is_sign_extended_14(b):
            raise ValueError(f'not_sign_extended_14_at_sample_{index}')
        channel_a.append(_signed16(a))
        channel_b.append(_signed16(b))
    if footer[8] != payload_xor or footer[9] != (payload_xor ^ MASK32):
        raise ValueError('payload_xor_mismatch')
    return RawFrame(slot, h, tuple(channel_a), tuple(channel_b), payload_xor)


def decode_bytes(data, completed=None, completed_after=None,
                 expected_epoch=None, expected_config_id=None, first_slot=0):
    """Return frames plus diagnostics; publication proof is separate from format.

    Completion counters describe the same uninterrupted single-shot run. They
    must both be 1. Epoch must be selected by the caller, not inferred from DDR.
    XOR is only a weak accidental-corruption check, not CRC or a cryptographic
    checksum; counter/epoch/state checks remain necessary.
    """
    if not data or len(data) % FRAME_BYTES or len(data) > 16 * FRAME_BYTES:
        raise ValueError('Input must contain 1..16 complete physical 64-KiB slots.')
    if not 0 <= first_slot < 16 or first_slot + len(data) // FRAME_BYTES > 16:
        raise ValueError('Physical slot range must stay inside the 16-slot ring.')
    for value in (expected_epoch, expected_config_id):
        if value is not None and not 0 <= value <= MASK32:
            raise ValueError('Expected metadata must fit unsigned 32 bits.')
    if completed_after is not None and completed is None:
        raise ValueError('A post-read count requires a pre-read count.')
    if completed is not None and completed not in (0, 1):
        raise ValueError('RAW1 single-shot completion count must be 0 or 1.')
    if completed_after is not None and completed_after not in (0, 1):
        raise ValueError('RAW1 single-shot post-read count must be 0 or 1.')
    if completed_after is not None and completed_after < completed:
        raise ValueError('Completion counter reset during the read.')
    frames, rejected = [], []
    for offset in range(0, len(data), FRAME_BYTES):
        slot = first_slot + offset // FRAME_BYTES
        words = struct.unpack_from('<16384I', data, offset)
        try:
            frame = _decode_slot(words, slot, expected_epoch, expected_config_id)
            if completed is not None and frame.header.frame_seq >= completed:
                raise ValueError('not_published_before_read')
            frames.append(frame)
        except ValueError as error:
            rejected.append({'slot': slot, 'reason': str(error)})
    publication_verified = (completed == completed_after == 1 and
                            expected_epoch is not None and len(frames) == 1)
    return frames, {
        'format': 'RAW1', 'single_shot': True,
        'publication_verified': publication_verified,
        'completed_before': completed, 'completed_after': completed_after,
        'expected_epoch': expected_epoch, 'expected_config_id': expected_config_id,
        'accepted_frames': len(frames), 'rejected_slots': rejected,
        'frames': [dict(slot=f.slot, **asdict(f.header), payload_xor32=f.payload_xor32)
                   for f in frames],
        'limits': 'Publication evidence assumes VIO values bracketed this file read in the same uninterrupted run. XOR32 cannot detect every corruption. Software metadata cannot prove analog channel identity or correct ADC capture timing.',
    }


def ramp_analysis(frame, direction=-1):
    """Check modulo-2^14 adjacent codes, including signed wrap, per channel."""
    if direction not in (-1, 1):
        raise ValueError('Ramp direction must be -1 or +1.')
    result = {'expected_step': direction, 'modulus': 16384,
              'adc_test_mode_is_ramp': frame.header.test_mode == 15}
    for name, samples in (('A', frame.channel_a), ('B', frame.channel_b)):
        bad = [i for i in range(1, len(samples))
               if ((samples[i] - samples[i - 1]) & 0x3FFF) != (direction & 0x3FFF)]
        result[name] = {'samples': len(samples), 'checked_edges': len(samples) - 1,
                        'bad_edges': len(bad), 'first_bad_indices': bad[:16]}
    result['ramp_check_pass'] = (len(frame.channel_a) >= 2 and
                                 frame.header.test_mode == 15 and
                                 not result['A']['bad_edges'] and not result['B']['bad_edges'])
    result['limits'] = 'Pass checks both digital code sequences only. Identical ramp channels cannot prove A/B identity, analog behavior, eye margin, or sample-clock frequency.'
    return result


def tgd_match(frame, plan, channel='A', plan_path=None):
    """Real ADC -> FFT analytic signal -> existing offline TGD matched filter.

    No A+jB assumption is made: each ADC input is a real physical channel.
    Lag is relative to captured sample zero; external TX trigger/clock alignment
    and analog transfer must be established before interpreting range or phase.
    """
    import numpy as np
    if channel not in ('A', 'B') or frame.header.test_mode != 0:
        raise ValueError('TGD matching requires channel A/B in normal ADC mode.')
    if plan['sample_rate_hz'] != frame.header.sample_rate_hz:
        raise ValueError('TGD plan and RAW1 sample rates differ.')
    if 'config_id_hex' in plan and int(plan['config_id_hex'], 0) != frame.header.config_id:
        raise ValueError('TGD plan and RAW1 config_id differ.')
    rate = frame.header.sample_rate_hz
    if not all(0 < plan[key] < rate / 2 for key in ('f_start_hz', 'f_end_hz')):
        raise ValueError('TGD reference must lie strictly inside first Nyquist.')
    samples = np.asarray(frame.channel_a if channel == 'A' else frame.channel_b,
                         dtype=np.float64)
    count = int(plan['sweep_samples'])
    if not 2 <= count <= len(samples):
        raise ValueError('Captured window cannot contain a complete reference gate.')
    reference_path = Path(__file__).with_name('tgd_reference.py')
    spec = importlib.util.spec_from_file_location('raw_tgd_reference', reference_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    samples -= samples.mean()
    if not np.any(samples):
        raise ValueError('Captured channel has no AC signal to match.')
    reference_model = plan.get('reference_model', 'ideal_48bit_phase')
    rom_hash = None
    if reference_model == 'lut4096_signed16':
        if plan_path is None or plan.get('phase_address_bits') != 12:
            raise ValueError('TX01 LUT reference needs its plan file path and 12-bit ROM address.')
        rom_path = Path(plan_path).resolve().parent / plan['rom_relative_to_plan']
        rom_bytes = rom_path.read_bytes()
        rom_hash = hashlib.sha256(rom_bytes).hexdigest()
        if rom_hash != plan['rom_sha256']:
            raise ValueError('TX01 reference ROM SHA256 differs from plan.')
        rom_values = [int(line, 16) for line in rom_bytes.decode('ascii').split()]
        if len(rom_values) != 4096 or any(not 0 <= value <= 65535 for value in rom_values):
            raise ValueError('TX01 reference ROM is not 4096 signed16 values.')
        lut = np.asarray([_signed16(value) for value in rom_values], dtype=np.float64)
        addresses = np.asarray([((plan['ftw_start'] * k + plan['ftw_delta_signed'] * k * (k - 1) // 2)
                                 % (1 << 48)) >> 36 for k in range(count)], dtype=np.int64)
        tx_reference = (lut[(addresses + 1024) % 4096] + 1j * lut[addresses]) / plan['rom_peak_codes']
    elif reference_model == 'ideal_48bit_phase':
        tx_reference = module.waveform(plan)
    else:
        raise ValueError('Unsupported TGD reference_model.')
    multiplier = np.zeros(len(samples))
    multiplier[0] = 1
    if len(samples) % 2 == 0:
        multiplier[1:len(samples) // 2] = 2
        multiplier[len(samples) // 2] = 1
    else:
        multiplier[1:(len(samples) + 1) // 2] = 2
    analytic = np.fft.ifft(np.fft.fft(samples) * multiplier)
    compressed = module.matched_filter(analytic, tx_reference)
    # Search only full-gate overlap; partial negative/end lags are not echoes.
    peak = count - 1 + int(np.argmax(abs(compressed[count - 1:len(samples)])))
    lag = peak - (count - 1)
    report = {'channel': channel, 'lag_samples': lag, 'lag_seconds': lag / rate,
              'peak_index': peak, 'reference_samples': count,
              'peak_magnitude_adc_codes': float(abs(compressed[peak])),
              'peak_phase_rad_uncalibrated': float(np.angle(compressed[peak])),
              'reference_model': reference_model, 'reference_rom_sha256': rom_hash,
              'limits': 'FFT analytic conversion and rectangular reference are offline assumptions. Lag/phase are relative to capture start, without TX trigger alignment or analog/clock calibration; no calibrated optical distance is claimed.'}
    return report, compressed


def _u32(text):
    value = int(text, 0)
    if not 0 <= value <= MASK32:
        raise argparse.ArgumentTypeError('Expected unsigned 32-bit value.')
    return value


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('binary', type=Path)
    parser.add_argument('--completed', '--completed-before', dest='completed', type=int,
                        help='Existing VIO DDR frames-done count immediately before DMA read')
    parser.add_argument('--completed-after', type=int)
    parser.add_argument('--expected-epoch', type=_u32)
    parser.add_argument('--expected-config-id', type=_u32)
    parser.add_argument('--first-slot', type=int, default=0)
    parser.add_argument('--allow-unverified', action='store_true',
                        help='Permit diagnostic decoding without fresh-publication evidence')
    parser.add_argument('--ramp', action='store_true')
    parser.add_argument('--ramp-direction', type=int, choices=(-1, 1), default=-1)
    parser.add_argument('--tgd-plan', type=Path)
    parser.add_argument('--channel', choices=('A', 'B'), default='A')
    parser.add_argument('--output', type=Path, default=Path('raw_decoded'))
    args = parser.parse_args()
    try:
        frames, summary = decode_bytes(args.binary.read_bytes(), args.completed,
            args.completed_after, args.expected_epoch, args.expected_config_id, args.first_slot)
        if not frames:
            raise ValueError('No valid RAW1 frame: ' + json.dumps(summary['rejected_slots']))
        if not summary['publication_verified'] and not args.allow_unverified:
            raise ValueError('Fresh publication is unverified: require before=after=1 and expected epoch, or explicitly --allow-unverified for diagnostics.')
        args.output.mkdir(parents=True, exist_ok=True)
        with (args.output / 'samples.csv').open('w', newline='', encoding='utf-8') as stream:
            writer = csv.writer(stream)
            writer.writerow(('frame_seq', 'trace_id', 'epoch', 'sample', 'time_in_trace_s', 'A_s16', 'B_s16', 'A_code14', 'B_code14'))
            for frame in frames:
                h = frame.header
                writer.writerows((h.frame_seq, h.trace_id, h.epoch, i, i / h.sample_rate_hz,
                                  a, b, a & 0x3FFF, b & 0x3FFF)
                                 for i, (a, b) in enumerate(zip(frame.channel_a, frame.channel_b)))
        if args.ramp:
            summary['ramp'] = [ramp_analysis(frame, args.ramp_direction) for frame in frames]
        if args.tgd_plan:
            plan = json.loads(args.tgd_plan.read_text(encoding='utf-8-sig'))
            summary['tgd'] = []
            for frame in frames:
                report, compressed = tgd_match(frame, plan, args.channel, args.tgd_plan)
                summary['tgd'].append(report)
                with (args.output / f'tgd_match_{frame.header.frame_seq}.csv').open('w', newline='', encoding='utf-8') as stream:
                    writer = csv.writer(stream)
                    writer.writerow(('lag_samples', 'correlation_real', 'correlation_imag', 'magnitude'))
                    writer.writerows((i - report['reference_samples'] + 1, float(v.real), float(v.imag), float(abs(v)))
                                     for i, v in enumerate(compressed))
        (args.output / 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
        print(json.dumps(summary, indent=2))
        if args.ramp and not all(r['ramp_check_pass'] for r in summary['ramp']):
            return 3
        return 0
    except (ValueError, KeyError, OSError, ImportError) as error:
        print(f'RAW1_CHECK_FAILED: {error}')
        return 2


if __name__ == '__main__':
    raise SystemExit(main())
