`timescale 1ns / 1ps
`default_nettype none

// FMCADDA-9643-9122: 14 LVDS lanes, interleaved A/B DDR output.
// KU060 is UltraScale (not 7-series or UltraScale+).
module adc_driver #(
    parameter integer INPUT_DELAY_TAPS = 10,
    parameter real SAMPLE_PHASE_DEG = 123.750
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
    output wire        adc_data_valid,
    output wire        dac_forward_clk
);
    wire adc_dco;
    wire [13:0] data_buffered;
    wire [13:0] data_delayed;

    // Set IOSTANDARD, termination and package pins in the carrier-board XDC.
    IBUFDS #(.IBUF_LOW_PWR("FALSE")) dco_ibuf (
        .I(adc_data_clk_p), .IB(adc_data_clk_n), .O(adc_dco)
    );
    wire adc_clk_raw, dac_clk_raw, adc_fb_raw, adc_fb, adc_clk_locked;
    MMCME3_ADV #(
        .CLKIN1_PERIOD(8.000), .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(8.000), .COMPENSATION("AUTO"),
        .CLKOUT0_DIVIDE_F(8.000), .CLKOUT0_PHASE(SAMPLE_PHASE_DEG),
        .CLKOUT1_DIVIDE(8), .CLKOUT1_PHASE(SAMPLE_PHASE_DEG + 90.000)
    ) adc_clock_mmcm (
        .CLKIN1(adc_dco), .CLKIN2(1'b0), .CLKINSEL(1'b1),
        .CLKFBIN(adc_fb), .CLKFBOUT(adc_fb_raw),
        .CLKOUT0(adc_clk_raw), .CLKOUT1(dac_clk_raw), .LOCKED(adc_clk_locked),
        .RST(rst), .PWRDWN(1'b0),
        .DADDR(7'b0), .DCLK(1'b0), .DEN(1'b0), .DI(16'b0), .DWE(1'b0),
        .PSCLK(1'b0), .PSEN(1'b0), .PSINCDEC(1'b0), .CDDCREQ(1'b0)
    );
    BUFG adc_feedback_buf (.I(adc_fb_raw), .O(adc_fb));
    BUFG dco_bufg (.I(adc_clk_raw), .O(adc_data_clk_bufg));
    // Quarter-cycle shifted clock for the DAC's source-synchronous DDR pins.
    // CLKOUT0 and the ADC capture phase remain unchanged.
    BUFG dac_forward_bufg (.I(dac_clk_raw), .O(dac_forward_clk));
    wire clock_reset = rst | ~adc_clk_locked;

    // Asynchronous assertion also works when DCO has not started yet.
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_sync = 2'b11;
    always @(posedge adc_data_clk_bufg or posedge clock_reset) begin
        if (clock_reset)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    // Wait for synchronization and the DDR pipeline to fill. This qualifies
    // captured words in either ADC test or normal mode; top_layer keeps test
    // words out of normal acquisition and checks them in the sample domain.
    wire valid_reset = clock_reset | reset_sync[1] | ~capture_enable;
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
        // Separate local reset registers keep half-cycle DDR recovery short.
        (* DONT_TOUCH = "TRUE" *) reg lane_reset = 1'b1;
        always @(posedge adc_data_clk_bufg or posedge reset_sync[1]) begin
            if (reset_sync[1]) lane_reset <= 1'b1;
            else lane_reset <= 1'b0;
        end
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
            .INC(1'b0), .LOAD(1'b0), .RST(lane_reset)
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
            .D(data_delayed[bit_index]), .R(lane_reset)
        );
    end endgenerate
endmodule

`default_nettype wire
