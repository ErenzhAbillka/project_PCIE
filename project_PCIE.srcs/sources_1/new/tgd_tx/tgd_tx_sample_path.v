`timescale 1ns/1ps
`default_nettype none
// Reuses the verified lfm_iq_source; no second chirp implementation.
// 5->15 MHz @125 MSPS is ONLY a digital/electrical verification example.
// It is not a claimed operating frequency for the user's unknown AOM.
// hardware_arm AND configuration AND bandwidth approval are explicit inputs.
module tgd_tx_sample_path #(
    parameter integer PERIOD_SAMPLES=31250,
    parameter integer SWEEP_SAMPLES=2500,
    parameter [47:0] FTW_START=48'h0a3d70a3d70a,
    parameter [47:0] FTW_DELTA=48'h00021915f378,
    parameter SINE_MEM="sine_4096.mem"
)(
    input wire sample_clk, input wire reset_n,
    input wire run, input wire hardware_arm, input wire tx_kill,
    input wire dac_configured, input wire waveform_approved,
    output wire active, output wire sample_valid,
    output wire sweep_gate, output wire sweep_start,
    output wire [31:0] sample_index,
    output wire signed [15:0] i_sample, q_sample,
    output wire tx_data_enable,
    output reg shot_started, output reg shot_done
);
    // A run held high cannot start another sweep. Re-arm requires reset.
    // Do not use shot_done to gate the data: its assertion overlaps the last IQ.
    wire launch=run && tx_data_enable && !shot_started;
    assign tx_data_enable=hardware_arm && dac_configured && waveform_approved && !tx_kill;
    always @(posedge sample_clk) begin
        if (!reset_n) begin shot_started<=0; shot_done<=0; end
        else begin
            if (launch) shot_started<=1;
            if (sample_valid && sweep_gate && sample_index==SWEEP_SAMPLES-1)
                shot_done<=1;
        end
    end
    lfm_iq_source #(.PERIOD_SAMPLES(PERIOD_SAMPLES),.SWEEP_SAMPLES(SWEEP_SAMPLES),
        .FTW_START(FTW_START),.FTW_DELTA(FTW_DELTA),.SINE_MEM(SINE_MEM)) source(
        .clk(sample_clk),.reset_n(reset_n),.run(launch),
        .active(active),.i_data(i_sample),.q_data(q_sample),
        .sample_valid(sample_valid),.gate(sweep_gate),
        .sweep_start(sweep_start),.sample_index(sample_index));
endmodule
`default_nettype wire
