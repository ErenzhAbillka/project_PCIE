`timescale 1ns/1ps
`default_nettype none

// Shared phase recurrence; board pins and arming belong to the TX frontend.
// One clk edge MUST represent one physical DAC sample; there is no tready.
// phase_data, gate, sweep_start and sample_index describe the SAME sample.
// Feed phase_data[47:32] to a phase-input sine/cosine DDS, then delay all
// markers by the DDS latency. Gate the resulting IQ samples, not the phase.
// FTW_START = round(f_start / f_sample * 2^48).
// FTW_DELTA = round((f_end-f_start)/(SWEEP_SAMPLES-1)/f_sample * 2^48).
// Negative FTW_DELTA uses 48-bit two's complement; phase arithmetic is modulo.
module lfm_phase_source #(
    parameter integer PERIOD_SAMPLES = 31250,
    parameter integer SWEEP_SAMPLES = 2500,
    parameter [47:0] FTW_START = 48'h51eb851eb852, // 40 MHz @ 125 MSPS
    parameter [47:0] FTW_DELTA = 48'h0004322be6f0  // 40 -> 60 MHz, 2500 samples.
)(
    input wire clk, input wire reset_n,
    // Synchronous run request. Hold low until active==0 to request a stop;
    // the current PERIOD completes before stopping.
    // A later rising run starts a new deterministic phase-zero sweep.
    input wire run,
    output reg active,
    output wire [47:0] phase_data,
    output wire [47:0] frequency_word,
    output wire gate, output wire sweep_start,
    output wire [31:0] sample_index
);
    reg [31:0] position;
    reg [47:0] phase, step;
    assign gate = active && position < SWEEP_SAMPLES;
    assign sweep_start = active && position == 0;
    assign sample_index = position;
    assign phase_data = phase;
    assign frequency_word = step;
    always @(posedge clk) begin
        if (!reset_n) begin
            active <= 0; position <= 0; phase <= 0; step <= FTW_START;
        end else if (!active) begin
            position <= 0; phase <= 0; step <= FTW_START;
            if (run) active <= 1;
        end else if (position == PERIOD_SAMPLES-1) begin
            active <= run; position <= 0; phase <= 0; step <= FTW_START;
        end else begin
            position <= position + 1'b1;
            if (position < SWEEP_SAMPLES-1) begin
                phase <= phase + step;
                step <= step + FTW_DELTA;
            end
        end
    end
`ifndef SYNTHESIS
    initial begin
        if (SWEEP_SAMPLES < 2 || PERIOD_SAMPLES < SWEEP_SAMPLES)
            $fatal(1, "Invalid LFM length/period");
    end
`endif
endmodule
`default_nettype wire
