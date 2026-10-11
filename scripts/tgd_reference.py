"""Offline TGD-OFDR engineering model; synthetic results are not board results.

Generates a gated LFM complex waveform with exactly the RTL phase recurrence,
checks first-Nyquist receive feasibility, and tests FFT matched filtering.
No instrument, DAC, PCIe device, or laser is accessed.
"""
import argparse
import json
from pathlib import Path
import numpy as np

PHASE_MODULUS = 1 << 48
C = 299792458.0


def plan(sample_rate=125e6, f_start=40e6, f_end=60e6,
         pulse_us=20.0, period_us=250.0, group_index=1.4682):
    if not (sample_rate > 0 and 0 < f_start < sample_rate/2 and 0 < f_end < sample_rate/2):
        raise ValueError("This prototype requires the entire receive band strictly inside first Nyquist.")
    if f_start == f_end or not (0 < pulse_us <= period_us) or group_index <= 1:
        raise ValueError("Need a nonzero sweep, pulse <= period, and group index > 1.")
    samples = round(pulse_us * 1e-6 * sample_rate)
    period = round(period_us * 1e-6 * sample_rate)
    if samples < 2 or period < samples:
        raise ValueError("Rounded waveform is too short or exceeds period.")
    start = round(f_start / sample_rate * PHASE_MODULUS)
    delta = round((f_end-f_start)/(samples-1)/sample_rate * PHASE_MODULUS)
    bandwidth = abs(f_end-f_start)
    return {
        "status": "offline_example_not_hardware_configuration",
        "sample_rate_hz": sample_rate, "f_start_hz": f_start, "f_end_hz": f_end,
        "sweep_samples": samples, "period_samples": period,
        "actual_gate_seconds": samples/sample_rate,
        "ftw_start_hex": f"48'h{start:012x}",
        "ftw_delta_hex": f"48'h{delta % PHASE_MODULUS:012x}",
        "ftw_start": start, "ftw_delta_signed": delta,
        "quantized_first_interval_hz": start/PHASE_MODULUS*sample_rate,
        "quantized_final_ftw_hz": (start+(samples-1)*delta)/PHASE_MODULUS*sample_rate,
        "nyquist_edge_margin_hz": min(f_start, f_end, sample_rate/2-f_start, sample_rate/2-f_end),
        "group_index_assumption": group_index,
        "ideal_resolution_m": C/(2*group_index*bandwidth),
        "sample_spacing_m": C/(2*group_index*sample_rate),
        "ideal_time_bandwidth_product": bandwidth*samples/sample_rate,
        "conservative_full_echo_fiber_length_m": C/(2*group_index)*(period-samples)/sample_rate,
        "phase_convention": "phase[k]=FTW_START*k+FTW_DELTA*k*(k-1)/2 mod 2^48; final FTW denotes next interval",
        "limits": "AOM/EOM, DAC interpolation, amplifier/filter band, clock coherence and triggering are unverified; rectangular-gate resolution only, windowing broadens main lobe.",
    }


def waveform(p):
    # Integer arithmetic keeps the model identical to the 48-bit HDL recurrence.
    phases = np.array([(p["ftw_start"]*k + p["ftw_delta_signed"]*k*(k-1)//2) % PHASE_MODULUS
                       for k in range(p["sweep_samples"])], dtype=np.uint64)
    return np.exp(2j*np.pi*phases.astype(np.float64)/PHASE_MODULUS)


def matched_filter(received, reference):
    """Linear convolution with conj(reference[::-1]); lag = peak-(N-1)."""
    length = len(received)+len(reference)-1
    nfft = 1 << (length-1).bit_length()
    return np.fft.ifft(np.fft.fft(received, nfft)*
                       np.fft.fft(reference[::-1].conj(), nfft))[:length]


def self_test(p):
    tx = waveform(p)
    delay = 373
    phase1, phase2 = 0.25, 0.62
    peaks, measured = [], []
    for phase in (phase1, phase2):
        rx = np.zeros(len(tx)+delay+256, dtype=np.complex128)
        rx[delay:delay+len(tx)] = 0.3*np.exp(1j*phase)*tx
        compressed = matched_filter(rx, tx)
        peak = int(np.argmax(abs(compressed)))
        assert peak-(len(tx)-1) == delay, (peak, delay)
        assert abs(np.angle(compressed[peak])-phase) < 1e-9
        assert abs(abs(compressed[peak])-0.3*len(tx)) < 1e-8
        peaks.append(peak)
        measured.append(float(np.angle(compressed[peak])))
    assert abs((measured[1]-measured[0])-(phase2-phase1)) < 1e-9
    # Two scatterers, deliberately well separated: verify linear convolution,
    # correct lag calibration and each local peak, without claiming no sidelobes.
    delays = [200, 900]
    rx = np.zeros(len(tx)+max(delays)+256, dtype=np.complex128)
    for lag, amplitude in zip(delays, [1.0, 0.6j]):
        rx[lag:lag+len(tx)] += amplitude*tx
    compressed = matched_filter(rx, tx)
    for lag in delays:
        expected = lag+len(tx)-1
        found = expected-4+int(np.argmax(abs(compressed[expected-4:expected+5])))
        assert found == expected, (found, expected)
    return {"result": "TGD_REFERENCE_TEST_PASS", "source": "synthetic complex IQ only",
            "known_delay_samples": delay, "matched_peak_indices": peaks,
            "recovered_phase_rad": measured, "phase_change_rad": measured[1]-measured[0],
            "two_scatterer_delays": delays,
            "not_tested": "real ADC Hilbert/IQ conversion, fixed-point FFT, optical speckle/fading, DAC transfer, analog bandwidth and hardware synchronization"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sample-rate", type=float, default=125e6)
    parser.add_argument("--start-hz", type=float, default=40e6)
    parser.add_argument("--end-hz", type=float, default=60e6)
    parser.add_argument("--pulse-us", type=float, default=20)
    parser.add_argument("--period-us", type=float, default=250)
    parser.add_argument("--output", type=Path, default=Path(__file__).parent/"reference_output")
    args = parser.parse_args()
    p = plan(args.sample_rate, args.start_hz, args.end_hz, args.pulse_us, args.period_us)
    result = self_test(p)
    # Also exercise a down-chirp and reject the thesis RF example at 125 MSPS.
    self_test(plan(args.sample_rate, args.end_hz, args.start_hz, args.pulse_us, args.period_us))
    try:
        plan(125e6, 150e6, 250e6)
    except ValueError:
        pass
    else:
        raise AssertionError("Unsupported first-Nyquist thesis example accepted")
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output/"plan.json").write_text(json.dumps(p, indent=2), encoding="utf-8")
    (args.output/"self_test.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    tx = waveform(p)
    np.savetxt(args.output/"tx_iq.csv", np.column_stack((np.arange(len(tx)),
               np.rint(tx.real*30000).astype(np.int16), np.rint(tx.imag*30000).astype(np.int16))),
               fmt="%d", delimiter=",", header="sample,i_s16,q_s16", comments="")
    print(json.dumps({"test": result, "plan": p}, indent=2))


if __name__ == "__main__":
    main()
