`timescale 1ns/1ps
`default_nettype none
// Hardware-independent TX samples, not an AD9122 LVDS interface driver.
// One clk = one DAC input sample. No backpressure. I=cos, Q=+sin.
// 12-bit phase truncation and a signed-16 ROM (peak 30000) are explicit.
// IQ, gate/start/index/valid all have one registered cycle of latency.
module lfm_iq_source #(
    parameter integer PERIOD_SAMPLES=31250,
    parameter integer SWEEP_SAMPLES=2500,
    parameter [47:0] FTW_START=48'h51eb851eb852,
    parameter [47:0] FTW_DELTA=48'h0004322be6f0,
    parameter SINE_MEM="sine_4096.mem"
)(
    input wire clk, input wire reset_n, input wire run,
    output wire active,
    output reg signed [15:0] i_data, q_data,
    output reg sample_valid, gate, sweep_start,
    output reg [31:0] sample_index
);
    wire [47:0] phase;
    wire source_gate, source_start;
    wire [31:0] source_index;
    (* rom_style="block" *) reg signed [15:0] sine_rom [0:4095];
    initial $readmemh(SINE_MEM, sine_rom);
    wire [11:0] sin_address=phase[47:36];
    wire [11:0] cos_address=sin_address+12'd1024;
    lfm_phase_source #(.PERIOD_SAMPLES(PERIOD_SAMPLES), .SWEEP_SAMPLES(SWEEP_SAMPLES),
        .FTW_START(FTW_START), .FTW_DELTA(FTW_DELTA)) phase_source(
        .clk(clk), .reset_n(reset_n), .run(run), .active(active),
        .phase_data(phase), .frequency_word(), .gate(source_gate),
        .sweep_start(source_start), .sample_index(source_index));
    always @(posedge clk) begin
        if (!reset_n) begin
            i_data<=0; q_data<=0; sample_valid<=0;
            gate<=0; sweep_start<=0; sample_index<=0;
        end else begin
            i_data<=source_gate ? sine_rom[cos_address] : 16'sd0;
            q_data<=source_gate ? sine_rom[sin_address] : 16'sd0;
            sample_valid<=active; gate<=source_gate;
            sweep_start<=source_start; sample_index<=source_index;
        end
    end
endmodule
`default_nettype wire
