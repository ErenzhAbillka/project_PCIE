`timescale 1ns/1ps
`default_nettype none
// KU060 UltraScale PHY: one I/Q pair per sample_clk (DCI), I on high half.
// DCI MUST remain continuous during FIFO configuration while data_enable=0.
// FRAME is logical zero; FIFO initialization uses SPI, not FRAME pulses.
// data_enable is synchronous to sample_clk and defaults low at the caller.
// This wrapper DOES NOT establish pin locations or board output timing.
module ad9122_lvds_tx (
    input wire sample_clk, input wire forward_clk, input wire reset,
    input wire data_enable, input wire sample_valid,
    input wire signed [15:0] i_sample, input wire signed [15:0] q_sample,
    output wire [15:0] dac_data_p, output wire [15:0] dac_data_n,
    output wire dac_dci_p, output wire dac_dci_n,
    output wire dac_frame_p, output wire dac_frame_n
);
    wire [15:0] data_sdr;
    wire [15:0] i_word=(data_enable && sample_valid) ? i_sample : 16'd0;
    wire [15:0] q_word=(data_enable && sample_valid) ? q_sample : 16'd0;
    genvar k;
    generate for(k=0;k<16;k=k+1) begin : lane
        ODDRE1 #(.SIM_DEVICE("ULTRASCALE"),.SRVAL(1'b0)) ddr(
            .Q(data_sdr[k]),.C(sample_clk),.D1(i_word[k]),.D2(q_word[k]),.SR(reset));
        OBUFDS outbuf(.I(data_sdr[k]),.O(dac_data_p[k]),.OB(dac_data_n[k]));
    end endgenerate
    wire dci;
    ODDRE1 #(.SIM_DEVICE("ULTRASCALE"),.SRVAL(1'b0)) dci_ddr(
        .Q(dci),.C(forward_clk),.D1(1'b1),.D2(1'b0),.SR(reset));
    OBUFDS dci_out(.I(dci),.O(dac_dci_p),.OB(dac_dci_n));
    OBUFDS frame_out(.I(1'b0),.O(dac_frame_p),.OB(dac_frame_n));
endmodule
`default_nettype wire
