"""Offline RAW1 contract, corruption, publication, ramp and TGD tests."""
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


class RawContractTests(unittest.TestCase):
    def decode(self, words=None, **kwargs):
        return raw.decode_bytes(packed(fixture() if words is None else words),
                                completed=1, completed_after=1,
                                expected_epoch=77, **kwargs)

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
