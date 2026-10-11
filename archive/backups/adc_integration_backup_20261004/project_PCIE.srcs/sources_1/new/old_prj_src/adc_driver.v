`timescale 1ns / 1ps
`default_nettype none

// FMCADDA-9643-9122: 14 LVDS lanes, interleaved A/B DDR output.
// KU060 is UltraScale (not 7-series or UltraScale+).
module adc_driver #(
    parameter integer INPUT_DELAY_TAPS = 10
)(
    input  wire        ctrl_clk,
    input  wire        rst,
    input  wire        capture_enable,
    input  wire        adc_data_clk_p,
    input  wire        adc_data_clk_n,
    input  wire [13:0] data_pin_p,
    input  wire [13:0] data_pin_n,
    output wire [13:0] adc_data_out_ch1,
    output wire [13:0] adc_data_out_ch2,
    output wire        adc_data_clk_bufg,
    output wire        adc_data_valid
);
    wire adc_dco;
    wire [13:0] data_buffered;
    wire [13:0] data_delayed;

    // Set IOSTANDARD, termination and package pins in the carrier-board XDC.
    IBUFDS #(.IBUF_LOW_PWR("FALSE")) dco_ibuf (
        .I(adc_data_clk_p), .IB(adc_data_clk_n), .O(adc_dco)
    );
    BUFG dco_bufg (.I(adc_dco), .O(adc_data_clk_bufg));

    // Asynchronous assertion also works when DCO has not started yet.
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_sync = 2'b11;
    always @(posedge adc_data_clk_bufg or posedge rst) begin
        if (rst)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    // Wait for both synchronization and the DDR pipeline to fill. Test-pattern
    // data remains visible on the outputs, but is not marked as normal data.
    wire valid_reset = rst | ~capture_enable;
    (* ASYNC_REG = "TRUE" *) reg [3:0] valid_sync = 4'b0000;
    always @(posedge adc_data_clk_bufg or posedge valid_reset) begin
        if (valid_reset)
            valid_sync <= 4'b0000;
        else
            valid_sync <= {valid_sync[2:0], 1'b1};
    end
    assign adc_data_valid = valid_sync[3];

    genvar bit_index;
    generate for (bit_index = 0; bit_index < 14; bit_index = bit_index + 1) begin : adc_lane
        IBUFDS #(.IBUF_LOW_PWR("FALSE")) data_ibuf (
            .I(data_pin_p[bit_index]), .IB(data_pin_n[bit_index]),
            .O(data_buffered[bit_index])
        );

        // Vendor demo uses 10 taps. COUNT mode needs EN_VTC=0 and no
        // IDELAYCTRL. Tune taps against the actual carrier's timing/eye;
        // COUNT mode does not compensate for voltage/temperature drift.
        IDELAYE3 #(
            .CASCADE("NONE"),
            .DELAY_FORMAT("COUNT"),
            .DELAY_SRC("IDATAIN"),
            .DELAY_TYPE("FIXED"),
            .DELAY_VALUE(INPUT_DELAY_TAPS),
            .SIM_DEVICE("ULTRASCALE"),
            .UPDATE_MODE("ASYNC")
        ) data_delay (
            .CASC_OUT(), .CNTVALUEOUT(), .DATAOUT(data_delayed[bit_index]),
            .CASC_IN(1'b0), .CASC_RETURN(1'b0), .CE(1'b0),
            .CLK(ctrl_clk), .CNTVALUEIN(9'd0), .DATAIN(1'b0),
            .EN_VTC(1'b0), .IDATAIN(data_buffered[bit_index]),
            .INC(1'b0), .LOAD(1'b0), .RST(rst)
        );

        // AD9643 reg 0x16=0: DCO rising edge = A, falling edge = B.
        // SAME_EDGE_PIPELINED presents one A/B pair on the same rising edge.
        IDDRE1 #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
            .IS_C_INVERTED(1'b0),
            .IS_CB_INVERTED(1'b1)
        ) data_ddr (
            .Q1(adc_data_out_ch1[bit_index]),
            .Q2(adc_data_out_ch2[bit_index]),
            .C(adc_data_clk_bufg), .CB(adc_data_clk_bufg),
            .D(data_delayed[bit_index]), .R(reset_sync[1])
        );
    end endgenerate
endmodule

`default_nettype wire
