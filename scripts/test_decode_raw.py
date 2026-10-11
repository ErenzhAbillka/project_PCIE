"""Offline RAW1 contract, corruption, publication, PN9, historical ramp and TGD tests."""
import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import decode_raw as raw


def fixture(a=None, b=None, epoch=77, test_mode=15, config_id=19):
    # Explicit contract numbers intentionally independent of decoder constants.
    if a is None:
        a = [((8195 - i + 8192) % 16384) - 8192 for i in range(128)]
    if b is None:
        b = [((120 - i + 8192) % 16384) - 8192 for i in range(len(a))]
    words = [0] * 16384
    words[:16] = [0x52415731, 0, 16384, len(a), 0, epoch, 125000000,
                  31250, 1, test_mode, 0, 6, config_id, 14, 1, 0xFFFFFFFF]
    checksum = 0
    for i, (x, y) in enumerate(zip(a, b)):
        words[32 + i] = ((y & 0xFFFF) << 16) | (x & 0xFFFF)
        checksum ^= words[32 + i]
    words[16352:16362] = [0x52415731, 0, 0xFFFFFFFF, 0, epoch, len(a), 0, 6,
                          checksum, checksum ^ 0xFFFFFFFF]
    words[-4:] = [0x434F4D54, 0, 0xFFFFFFFF, 0x454E4421]
    return words


def packed(words):
    return struct.pack('<16384I', *words)



# ADI hdl_2016_r1 axi_ad9643_pnmon.v, parallel 30-bit PN9 reference.
ADI_TAPS = (
    (8,4),(7,3),(6,2),(5,1),(4,0),(3,8,4),(2,7,3),(1,6,2),(0,5,1),(8,0),
    (7,8,4),(6,7,3),(5,6,2),(4,5,1),(3,4,0),(2,3,8,4),(1,2,7,3),(0,1,6,2),
    (8,0,4,5,1),(7,8,3,0),(6,7,2,8,4),(5,6,1,7,3),(4,5,0,6,2),(3,8,5,1),
    (2,4,7,0),(1,3,6,8,4),(0,2,5,7,3),(8,1,6,2),(7,0,5,1),(6,8,0))


def pn9_reference(count, seed=0x1ff, xor_mask=0x3fff):
    values = []
    while len(values) < count:
        out = 0
        for taps in ADI_TAPS:
            bit = 0
            for tap in taps:
                bit ^= (seed >> tap) & 1
            out = (out << 1) | bit
        for word in ((out >> 15) & 0x3fff, out & 0x3fff):
            word ^= xor_mask
            values.append(word - 16384 if word & 8192 else word)
        seed = out & 0x1ff
    return values[:count]


class RawContractTests(unittest.TestCase):
    def decode(self, words=None, **kwargs):
        return raw.decode_bytes(packed(fixture() if words is None else words),
                                completed=1, completed_after=1,
                                expected_epoch=77, **kwargs)

    def pn9_frame(self, a=None, b=None, count=16320, **kwargs):
        return self.decode(fixture(a=pn9_reference(count) if a is None else a,
                                  b=pn9_reference(count, 0x163) if b is None else b,
                                  test_mode=6, config_id=0x504e3039, **kwargs))[0][0]

    def test_pn9_full_payload_and_independent_long_reference(self):
        frame = self.pn9_frame()
        result = raw.pn9_analysis(frame)
        self.assertTrue(result['pn9_check_pass'], result)
        self.assertEqual(result['A']['checked_samples'], 16320)
        self.assertEqual(len(set(frame.channel_a[:511])), 511)
        self.assertEqual(frame.channel_a[:511], frame.channel_a[511:1022])
        # The algorithm is also checked beyond the RAW payload limit, without
        # pretending this synthetic frame is a valid on-wire RAW1 slot.
        values = tuple(pn9_reference(17500))
        long_frame = raw.RawFrame(0, frame.header, values, values, 0)
        self.assertTrue(raw.pn9_analysis(long_frame)['pn9_check_pass'])

    def test_pn9_rejects_frozen_prediction_faults(self):
        good = pn9_reference(16320)
        changes = {
            'repeat2': [good[i // 2] for i in range(len(good))],
            'skip': good[:100] + good[101:] + [good[0]],
            'single_bit': good[:100] + [good[100] ^ 1] + good[101:],
            'constant': [good[0]] * len(good),
            'wrong_format': pn9_reference(len(good), xor_mask=0x1fff),
            'zero_seed': [-1] * len(good),
        }
        for name, values in changes.items():
            with self.subTest(fault=name):
                result = raw.pn9_analysis(self.pn9_frame(a=values))
                self.assertFalse(result['pn9_check_pass'], result)
                self.assertGreater(result['A']['bad_samples'], 0)
                self.assertEqual(result['B']['bad_samples'], 0)
                if name == 'single_bit':
                    self.assertEqual(result['A']['bad_samples'], 1)
                    self.assertEqual(result['A']['first_bad_indices'], [100])
                if name == 'zero_seed':
                    self.assertFalse(result['A']['seed_valid'])

    def test_pn9_seed_all_phases_and_single_bit_errors(self):
        good = pn9_reference(512)
        base = self.pn9_frame(count=2)
        for index in range(511):
            values = tuple(good[index:index + 2])
            frame = raw.RawFrame(0, base.header, values, values, 0)
            self.assertTrue(raw.pn9_analysis(frame)['pn9_check_pass'], index)
            for bit in range(14):
                corrupt = ((values[0] & 0x3fff) ^ (1 << bit))
                corrupt = corrupt - 16384 if corrupt & 8192 else corrupt
                frame = raw.RawFrame(0, base.header, (corrupt, values[1]), values, 0)
                result = raw.pn9_analysis(frame)
                self.assertFalse(result['A']['seed_valid'], (index, bit))
                self.assertFalse(result['pn9_check_pass'])
        ramp_frame = self.decode()[0][0]
        self.assertFalse(raw.pn9_analysis(ramp_frame)['pn9_check_pass'])

    def test_pn9_cli_exit_status_and_summary(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            path = directory / 'pn9.bin'
            values = pn9_reference(16320)
            command = [sys.executable, str(ROOT / 'scripts/decode_raw.py'), str(path),
                       '--completed', '1', '--completed-after', '1', '--expected-epoch', '77',
                       '--expected-config-id', '0x504e3039', '--pn9', '--output', str(directory / 'out')]
            for bad in (False, True):
                samples = values.copy()
                if bad:
                    samples[100] ^= 1
                path.write_bytes(packed(fixture(a=samples, b=values, test_mode=6, config_id=0x504e3039)))
                result = subprocess.run(command, capture_output=True, text=True)
                self.assertEqual(result.returncode, 3 if bad else 0, result.stdout + result.stderr)
                report = json.loads((directory / 'out/summary.json').read_text())
                self.assertTrue(report['publication_verified'])
                self.assertEqual(report['pn9'][0]['pn9_check_pass'], not bad)
            conflict = subprocess.run(command + ['--ramp'], capture_output=True, text=True)
            self.assertEqual(conflict.returncode, 2)

    def test_signed_packing_and_ramp_wrap(self):
        frames, report = self.decode(expected_config_id=19)
        self.assertTrue(report['publication_verified'])
        self.assertEqual(frames[0].channel_a[:5], (-8189, -8190, -8191, -8192, 8191))
        self.assertEqual(frames[0].channel_b[:3], (120, 119, 118))
        self.assertTrue(raw.ramp_analysis(frames[0])['ramp_check_pass'])
        self.assertFalse(raw.ramp_analysis(frames[0], 1)['ramp_check_pass'])

    def test_maximum_payload_and_unused_ring_slots(self):
        words = fixture(a=[1] * 16320, b=[-1] * 16320, test_mode=0)
        frames, report = raw.decode_bytes(packed(words) + bytes(15 * 65536),
                                         1, 1, 77)
        self.assertEqual(len(frames[0].channel_a), 16320)
        self.assertTrue(report['publication_verified'])
        self.assertEqual(len(report['rejected_slots']), 15)

    def test_corruption_and_torn_metadata_rejected(self):
        changes = {
            'header_sequence_complement': (15, 0),
            'header_footer_mismatch': (16356, 78),
            'missing_or_torn_commit': (16383, 0),
            'payload_xor_mismatch': (32, 0),
            'nonzero_payload_padding': (32 + 128, 1),
            'nonzero_reserved_header': (16, 1),
            'nonzero_reserved_footer': (16379, 1),
            'frame_error_flags': (10, 1),
            'unsupported_format_or_channel_packing': (11, 0),
            'not_current_single_shot_contract': (4, 1),
            'unsupported_ADC_test_mode': (9, 4),
        }
        for reason, (index, value) in changes.items():
            with self.subTest(reason=reason):
                words = fixture()
                words[index] = value
                frames, report = self.decode(words)
                self.assertEqual(frames, [])
                self.assertEqual(report['rejected_slots'][0]['reason'], reason)

    def test_bad_sign_extension_rejected_even_with_matching_xor(self):
        words = fixture()
        words[32] ^= 0x4000
        words[16360] ^= 0x4000
        words[16361] ^= 0x4000
        frames, report = self.decode(words)
        self.assertFalse(frames)
        self.assertTrue(report['rejected_slots'][0]['reason'].startswith('not_sign_extended'))

    def test_xor_is_not_a_strong_checksum(self):
        words = fixture()
        words[32] ^= 1
        words[33] ^= 1
        frames, report = self.decode(words)
        # Paired changes can cancel in XOR: format passes, ramp detects the fault.
        self.assertTrue(report['publication_verified'])
        self.assertFalse(raw.ramp_analysis(frames[0])['ramp_check_pass'])

    def test_epoch_config_and_physical_slot(self):
        frames, report = raw.decode_bytes(packed(fixture()), 1, 1, 78)
        self.assertFalse(frames)
        self.assertEqual(report['rejected_slots'][0]['reason'], 'epoch_mismatch')
        frames, report = self.decode(expected_config_id=20)
        self.assertFalse(frames)
        self.assertEqual(report['rejected_slots'][0]['reason'], 'config_id_mismatch')
        frames, report = self.decode(first_slot=1)
        self.assertFalse(frames)
        self.assertEqual(report['rejected_slots'][0]['reason'], 'physical_ring_slot')

    def test_unpublished_or_unbracketed_is_not_fresh(self):
        data = packed(fixture())
        for before, after, epoch in ((None, None, None), (1, None, 77), (1, 1, None)):
            frames, report = raw.decode_bytes(data, before, after, epoch)
            self.assertEqual(len(frames), 1)
            self.assertFalse(report['publication_verified'])
        frames, report = raw.decode_bytes(data, 0, 1, 77)
        self.assertFalse(frames)
        self.assertEqual(report['rejected_slots'][0]['reason'], 'not_published_before_read')
        for args in ((1, 0, 77), (2, 2, 77), (None, 1, 77)):
            with self.assertRaises(ValueError):
                raw.decode_bytes(data, *args)

    def test_input_alignment_and_limits(self):
        for data in (b'', bytes(65535), bytes(65537), bytes(17 * 65536)):
            with self.assertRaises(ValueError):
                raw.decode_bytes(data)
        words = fixture()
        words[3] = 16321
        frames, report = self.decode(words)
        self.assertFalse(frames)
        self.assertEqual(report['rejected_slots'][0]['reason'], 'sample_count')

    def test_das_magic_untouched(self):
        words = fixture()
        words[0] = 0x44415331
        frames, report = self.decode(words)
        self.assertFalse(frames)
        self.assertEqual(report['rejected_slots'][0]['reason'], 'not_RAW1')

    def test_cli_requires_evidence_and_exports_signed_values(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            capture = directory / 'capture.bin'
            capture.write_bytes(packed(fixture()))
            command = [sys.executable, str(ROOT / 'scripts/decode_raw.py'), str(capture),
                       '--output', str(directory / 'decoded')]
            missing = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(missing.returncode, 2)
            self.assertIn('Fresh publication is unverified', missing.stdout)
            checked = subprocess.run(command + ['--completed', '1', '--completed-after', '1',
                                     '--expected-epoch', '77', '--ramp'], capture_output=True, text=True)
            self.assertEqual(checked.returncode, 0, checked.stdout + checked.stderr)
            report = json.loads((directory / 'decoded/summary.json').read_text())
            self.assertTrue(report['publication_verified'])
            self.assertTrue(report['ramp'][0]['ramp_check_pass'])
            self.assertIn('-8189,120', (directory / 'decoded/samples.csv').read_text())
            wrong_ramp = subprocess.run(command + ['--allow-unverified', '--ramp', '--ramp-direction', '1'], capture_output=True)
            self.assertEqual(wrong_ramp.returncode, 3)

    def test_real_adc_tgd_entry_and_mismatch_rejection(self):
        import numpy as np
        path = ROOT / 'scripts/tgd_reference.py'
        spec = importlib.util.spec_from_file_location('test_tgd_reference', path)
        reference = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(reference)
        plan = reference.plan()
        delay = 373
        signal = np.zeros(plan['sweep_samples'] + delay + 256)
        signal[delay:delay + plan['sweep_samples']] = 1500 * reference.waveform(plan).real
        values = np.rint(signal).astype(int).tolist()
        frames, _ = self.decode(fixture(a=values, b=values, test_mode=0))
        result, _ = raw.tgd_match(frames[0], plan)
        self.assertEqual(result['lag_samples'], delay)
        with self.assertRaises(ValueError):
            raw.tgd_match(frames[0], dict(plan, sample_rate_hz=250000000))
        ramp_frame, _ = self.decode()
        with self.assertRaises(ValueError):
            raw.tgd_match(ramp_frame[0], plan)

    def test_tx01_uses_hashed_actual_lut_reference(self):
        import numpy as np
        path = ROOT / 'project_PCIE.doc/ADC_RAW_TX/tx01_plan.json'
        plan = json.loads(path.read_text())
        lut_path = path.parent / plan['rom_relative_to_plan']
        lut = [int(line, 16) for line in lut_path.read_text().split()]
        lut = [v - 65536 if v & 32768 else v for v in lut]
        delay = 211
        values = [0] * (delay + plan['sweep_samples'] + 256)
        for k in range(plan['sweep_samples']):
            phase = (plan['ftw_start'] * k + plan['ftw_delta_signed'] * k * (k - 1) // 2) % (1 << 48)
            values[delay + k] = round(lut[((phase >> 36) + 1024) % 4096] * 0.05)
        frames, _ = self.decode(fixture(a=values, b=values, test_mode=0, config_id=0x54583031))
        result, _ = raw.tgd_match(frames[0], plan, plan_path=path)
        self.assertEqual(result['lag_samples'], delay)
        self.assertEqual(result['reference_model'], 'lut4096_signed16')
        self.assertEqual(result['reference_rom_sha256'], plan['rom_sha256'])
        with self.assertRaises(ValueError):
            raw.tgd_match(frames[0], dict(plan, rom_sha256='0' * 64), plan_path=path)
        with self.assertRaises(ValueError):
            raw.tgd_match(frames[0], dict(plan, config_id_hex='0x1234'), plan_path=path)

    def test_tgd_zero_signal_is_not_reported_as_an_echo(self):
        path = ROOT / 'project_PCIE.doc/ADC_RAW_TX/tx01_plan.json'
        plan = json.loads(path.read_text())
        frames, _ = self.decode(fixture(a=[12] * 3000, b=[12] * 3000, test_mode=0, config_id=0x54583031))
        with self.assertRaisesRegex(ValueError, 'no AC signal'):
            raw.tgd_match(frames[0], plan, plan_path=path)


if __name__ == '__main__':
    unittest.main(verbosity=2)
