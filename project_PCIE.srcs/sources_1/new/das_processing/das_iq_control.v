`timescale 1ns/1ps
`default_nettype none

// The phase accumulator advances on samples, never on empty 200-MHz UI cycles.
// DDS TUSER carries the exact ADC sample and its acquisition-window markers.
module das_phase_source #(
    parameter [31:0] PHASE_STEP = 32'h66666666  // 50 MHz / 125 MSPS
)(
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000, ASSOCIATED_RESET reset_n" *)
    input wire clk, input wire reset_n,
    input wire [31:0] adc_data, input wire [1:0] adc_user,
    input wire adc_valid, output wire adc_ready,
    output wire [15:0] phase_data, output wire [15:0] phase_user,
    output wire phase_valid, input wire phase_ready
);
    reg [31:0] phase;
    assign adc_ready = reset_n && phase_ready;
    assign phase_valid = reset_n && adc_valid;
    assign phase_data = phase[31:16];
    assign phase_user = {adc_user, adc_data[13:0]};
    always @(posedge clk) begin
        if (!reset_n) phase <= 0;
        else if (adc_valid && adc_ready) phase <= phase + PHASE_STEP;
    end
endmodule

// One elastic multiply stage per I/Q leg. A leg can wait without re-sending
// its already accepted partner. Both products use the same sample/LO phase.
module das_iq_mixer (
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000, ASSOCIATED_RESET reset_n" *)
    input wire clk, input wire reset_n,
    input wire [31:0] lo_data, input wire [15:0] lo_user,
    input wire lo_valid, output wire lo_ready,
    output reg [23:0] i_data, output reg [1:0] i_user,
    output reg i_valid, input wire i_ready,
    output reg [23:0] q_data, output reg [1:0] q_user,
    output reg q_valid, input wire q_ready
);
    wire signed [13:0] sample = lo_user[13:0];
    wire signed [9:0] cosine = lo_data[9:0];
    wire signed [9:0] negative_sine = lo_data[25:16];
    assign lo_ready = reset_n && (!i_valid || i_ready) && (!q_valid || q_ready);
    always @(posedge clk) begin
        if (!reset_n) begin
            i_valid <= 0; q_valid <= 0;
            i_data <= 0; q_data <= 0; i_user <= 0; q_user <= 0;
        end else begin
            if (i_valid && i_ready) i_valid <= 0;
            if (q_valid && q_ready) q_valid <= 0;
            if (lo_valid && lo_ready) begin
                i_data <= sample * cosine; q_data <= sample * negative_sine;
                i_user <= lo_user[15:14]; q_user <= lo_user[15:14];
                i_valid <= 1; q_valid <= 1;
            end
        end
    end
endmodule

module das_iq_join (
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000, ASSOCIATED_RESET reset_n" *)
    input wire clk, input wire reset_n,
    input wire [15:0] i_data, input wire [1:0] i_user,
    input wire i_valid, output wire i_ready,
    input wire [15:0] q_data, input wire [1:0] q_user,
    input wire q_valid, output wire q_ready,
    output wire [31:0] cartesian_data, output wire [1:0] cartesian_user,
    output wire cartesian_valid, input wire cartesian_ready,
    output reg alignment_error
);
    assign cartesian_data = {q_data, i_data};
    assign cartesian_user = i_user;
    assign cartesian_valid = reset_n && i_valid && q_valid && !alignment_error;
    assign i_ready = reset_n && q_valid && cartesian_ready && !alignment_error;
    assign q_ready = reset_n && i_valid && cartesian_ready && !alignment_error;
    always @(posedge clk) begin
        if (!reset_n) alignment_error <= 0;
        else if (i_valid && q_valid && i_user != q_user) alignment_error <= 1;
    end
endmodule

// The writer still receives four-beat packets; full DAS frame boundaries are
// retained separately for completion checking and never substituted for WLAST.
module das_writer_packet (
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000, ASSOCIATED_RESET reset_n" *)
    input wire clk, input wire reset_n,
    input wire [31:0] frame_data, input wire frame_valid,
    input wire frame_last, output wire frame_ready,
    output wire [31:0] writer_data, output wire writer_valid,
    output wire writer_last, input wire writer_ready,
    input wire burst_done, output reg [31:0] ddr_frames_done,
    output reg framing_error
);
    reg [1:0] beat;
    reg last_pending;
    assign frame_ready = reset_n && writer_ready;
    assign writer_data = frame_data;
    assign writer_valid = reset_n && frame_valid;
    assign writer_last = beat == 3;
    always @(posedge clk) begin
        if (!reset_n) begin
            beat <= 0; framing_error <= 0; last_pending <= 0; ddr_frames_done <= 0;
        end else begin
            if (frame_valid && frame_ready) begin
                beat <= beat + 1'b1;
                if (frame_last) begin
                    last_pending <= 1;
                    if (beat != 3) framing_error <= 1;
                end
            end
            if (burst_done && last_pending) begin
                last_pending <= 0; ddr_frames_done <= ddr_frames_done + 1'b1;
            end
        end
    end
endmodule
`default_nettype wire
