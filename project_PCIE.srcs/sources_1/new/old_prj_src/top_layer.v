`timescale 1ns / 1ps
`default_nettype none

// FMCADDA-9643-9122 with the board's 10 MHz oscillator reference.
// AD9516: vendor 2 GHz VCO setup, 125 MHz ADC / 500 MHz DAC device clocks.
// ctrl_clk MUST run before ADC DCO exists. Default: DDR4 UI clock, 200 MHz.
module top_layer #(
    parameter integer CTRL_CLK_HZ = 200000000,
    parameter integer SPI_CLK_HZ = 1000000,
    parameter integer POWERUP_DELAY_CYCLES = CTRL_CLK_HZ / 100,
    parameter integer CLOCK_SETTLE_CYCLES = CTRL_CLK_HZ,
    parameter integer ADC_TEST_CYCLES = 3 * CTRL_CLK_HZ,
    parameter integer ADC_SETTLE_CYCLES = CTRL_CLK_HZ / 1000,
    parameter integer INPUT_DELAY_TAPS = 10,
    parameter integer TRACE_PERIOD = 31250,
    parameter integer TRACE_POINTS = 16320,
    parameter integer AOM_WIDTH = 12
)(
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET rst_n, FREQ_HZ 200000000" *)
    input  wire        ctrl_clk,
    input  wire        rst_n,
    // ctrl_clk-domain run level. Default VIO output is zero until DSP is connected.
    input  wire        acquisition_enable,
    input  wire        stream_ready,
    output wire [31:0] stream_data,
    output wire        stream_valid,
    output wire [1:0]  stream_user,
    output wire        aom_pulse,
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    output wire        adc_fifo_aresetn,
    output wire        adc_overflow,
    output wire        acquisition_active,
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 adc_dco CLK_P" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_dco, FREQ_HZ 125000000" *)
    input  wire        adc_data_clk_p,
    (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 adc_dco CLK_N" *)
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_dco, FREQ_HZ 125000000" *)
    input  wire        adc_data_clk_n,
    input  wire [13:0] data_pin_p,
    input  wire [13:0] data_pin_n,
    output wire [13:0] adc_data_ch1,
    output wire [13:0] adc_data_ch2,
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 125000000, ASSOCIATED_RESET adc_fifo_aresetn" *)
    output wire        sys_clk,
    output wire        adc_data_valid,
    output wire        init_done,
    output reg         device_spi_sclk,
    inout  wire        device_spi_sda,
    output reg         adk_spi_csb,
    output reg         adc_spi_csb,
    output wire        dac_spi_csb,
    output wire        adc_sync
);
    // rst_n must be asserted at startup; release is synchronized to ctrl_clk.
    (* ASYNC_REG = "TRUE" *) reg [1:0] ctrl_reset_sync = 2'b00;
    always @(posedge ctrl_clk or negedge rst_n) begin
        if (!rst_n)
            ctrl_reset_sync <= 2'b00;
        else
            ctrl_reset_sync <= {ctrl_reset_sync[0], 1'b1};
    end
    wire ctrl_rst_n = ctrl_reset_sync[1];

    adc_driver #(.INPUT_DELAY_TAPS(INPUT_DELAY_TAPS)) adc_driver_inst (
        .ctrl_clk(ctrl_clk), .rst(~ctrl_rst_n), .capture_enable(init_done),
        .adc_data_clk_p(adc_data_clk_p), .adc_data_clk_n(adc_data_clk_n),
        .data_pin_p(data_pin_p), .data_pin_n(data_pin_n),
        .adc_data_out_ch1(adc_data_ch1), .adc_data_out_ch2(adc_data_ch2),
        .adc_data_clk_bufg(sys_clk), .adc_data_valid(adc_data_valid)
    );

    // Reset is asserted without DCO; release only after MMCM/data pipeline ready.
    wire adc_fifo_reset = !ctrl_rst_n || !adc_data_valid;
    (* ASYNC_REG = "TRUE" *) reg [2:0] fifo_reset_sync = 0;
    always @(posedge sys_clk or posedge adc_fifo_reset) begin
        if (adc_fifo_reset) fifo_reset_sync <= 0;
        else fifo_reset_sync <= {fifo_reset_sync[1:0], 1'b1};
    end
    assign adc_fifo_aresetn = fifo_reset_sync[2];
    wire overflow_adc, active_adc;
    // Start once per system reset. Dropping the VIO request cannot splice a gap
    // into a trace or abort a partly transmitted writer burst.
    reg run_latched = 0;
    always @(posedge ctrl_clk) begin
        if (!ctrl_rst_n) run_latched <= 0;
        else if (acquisition_enable) run_latched <= 1;
    end
    adc_stream_source #(.TRACE_PERIOD(TRACE_PERIOD), .TRACE_POINTS(TRACE_POINTS),
                        .AOM_WIDTH(AOM_WIDTH)) stream_source_inst (
        .sample_clk(sys_clk), .reset_n(adc_fifo_aresetn),
        .sample_valid(adc_data_valid), .enable_async(run_latched),
        .ch_a(adc_data_ch1), .ch_b(adc_data_ch2),
        .stream_ready(stream_ready), .stream_data(stream_data),
        .stream_valid(stream_valid), .stream_user(stream_user), .aom_pulse(aom_pulse), .overflow(overflow_adc), .active(active_adc)
    );
    (* ASYNC_REG = "TRUE" *) reg [1:0] overflow_sync = 0, active_sync = 0;
    always @(posedge ctrl_clk) begin
        if (!ctrl_rst_n) begin overflow_sync <= 0; active_sync <= 0; end
        else begin
            overflow_sync <= {overflow_sync[0], overflow_adc};
            active_sync <= {active_sync[0], active_adc};
        end
    end
    assign adc_overflow = overflow_sync[1];
    assign acquisition_active = active_sync[1];

    // Shared SPI bus: write-only, mode 0, 16-bit instruction + 8-bit data,
    // MSB first. Only the selected device sees a transaction. SDIO is released
    // between transactions; the unused DAC remains deselected.
    assign dac_spi_csb = 1'b1;
    assign adc_sync = 1'b0;
    reg [23:0] spi_shift;
    IOBUF spi_sdio_buffer (
        .I(spi_shift[23]), .T(adk_spi_csb && adc_spi_csb),
        .O(), .IO(device_spi_sda)
    );

    localparam integer SPI_HALF_CYCLES =
        (CTRL_CLK_HZ + 2 * SPI_CLK_HZ - 1) / (2 * SPI_CLK_HZ);
    localparam [3:0] WAIT_DELAY = 0, START_WORD = 1, SPI_RISE = 2,
                     SPI_FALL = 3, CS_HOLD = 4, CS_GAP = 5, DONE = 6;
    localparam [1:0] CLOCK_CONFIG = 0, ADC_TEST_CONFIG = 1, ADC_NORMAL_CONFIG = 2;
    reg [3:0] state;
    reg [3:0] resume_state;
    reg [1:0] phase;
    reg [6:0] word_index;
    reg [4:0] bit_index;
    reg [31:0] wait_count;
    reg [31:0] spi_count;

    // Completion means the writes and settling delays finished, NOT that PLL
    // lock was read back. init_done is in ctrl_clk; adc_data_valid is in sys_clk.
    assign init_done = (state == DONE);

    // Register values from Hongney's ad9516_spi_wr_config.v, 10 MHz reference
    // profile ad9516_3_adda_ref10M_250M1000_20240320.txt. Final eight writes
    // 0x1e0=0x02 changes the VCO divider from /2 to /4 for 125 MSPS.
    // The final writes explicitly commit VCO calibration and assert/release software SYNC.
    function [23:0] clock_word;
        input [6:0] index;
        begin
            case (index)
                 0: clock_word = 24'h000018;
                 1: clock_word = 24'h000100;
                 2: clock_word = 24'h000210;
                 3: clock_word = 24'h000343;
                 4: clock_word = 24'h000400;
                 5: clock_word = 24'h00107c;
                 6: clock_word = 24'h001101;
                 7: clock_word = 24'h001200;
                 8: clock_word = 24'h001308;
                 9: clock_word = 24'h00140c;
                10: clock_word = 24'h001500;
                11: clock_word = 24'h001605;
                12: clock_word = 24'h0017b4;
                13: clock_word = 24'h001807;
                14: clock_word = 24'h001900;
                15: clock_word = 24'h001a45;
                16: clock_word = 24'h001be0;
                17: clock_word = 24'h001c02;
                18: clock_word = 24'h001d0a;
                19: clock_word = 24'h001e00;
                20: clock_word = 24'h001f0e;
                21: clock_word = 24'h00a001;
                22: clock_word = 24'h00a100;
                23: clock_word = 24'h00a200;
                24: clock_word = 24'h00a301;
                25: clock_word = 24'h00a400;
                26: clock_word = 24'h00a500;
                27: clock_word = 24'h00a601;
                28: clock_word = 24'h00a700;
                29: clock_word = 24'h00a800;
                30: clock_word = 24'h00a901;
                31: clock_word = 24'h00aa00;
                32: clock_word = 24'h00ab00;
                33: clock_word = 24'h00f00a;
                34: clock_word = 24'h00f10a;
                35: clock_word = 24'h00f20a;
                36: clock_word = 24'h00f30a;
                37: clock_word = 24'h00f40a;
                38: clock_word = 24'h00f508;
                39: clock_word = 24'h014003;
                40: clock_word = 24'h014142;
                41: clock_word = 24'h014242;
                42: clock_word = 24'h014343;
                43: clock_word = 24'h019000;
                44: clock_word = 24'h019180;
                45: clock_word = 24'h019200;
                46: clock_word = 24'h019300;
                47: clock_word = 24'h019480;
                48: clock_word = 24'h019500;
                49: clock_word = 24'h019600;
                50: clock_word = 24'h019780;
                51: clock_word = 24'h019800;
                52: clock_word = 24'h019911;
                53: clock_word = 24'h019a00;
                54: clock_word = 24'h019b11;
                55: clock_word = 24'h019c20;
                56: clock_word = 24'h019d00;
                57: clock_word = 24'h019e99;
                58: clock_word = 24'h019f00;
                59: clock_word = 24'h01a011;
                60: clock_word = 24'h01a120;
                61: clock_word = 24'h01a200;
                62: clock_word = 24'h01a300;
                63: clock_word = 24'h01e002;
                64: clock_word = 24'h01e102;
                65: clock_word = 24'h023000;
                66: clock_word = 24'h023100;
                67: clock_word = 24'h023200;
                68: clock_word = 24'h001806;
                69: clock_word = 24'h023201;
                70: clock_word = 24'h001807;
                71: clock_word = 24'h023201;
                72: clock_word = 24'h023001;
                73: clock_word = 24'h023201;
                74: clock_word = 24'h023000;
                75: clock_word = 24'h023201;
                default: clock_word = 24'h023201;
            endcase
        end
    endfunction

    function [23:0] adc_word;
        input [6:0] index;
        begin
            case (index)
                0:  adc_word = 24'h000503; // Select both A and B before reset.
                1:  adc_word = 24'h00003c; // Software reset.
                2:  adc_word = 24'h000018; // MSB first, three-wire SPI.
                3:  adc_word = 24'h000503; // Both channels.
                4:  adc_word = 24'h000800; // Power up.
                5:  adc_word = 24'h001000; // Zero offset adjustment.
                6:  adc_word = 24'h000d0f; // Ramp test pattern.
                7:  adc_word = 24'h001405; // Normal polarity, TWO'S COMPLEMENT.
                8:  adc_word = 24'h001600; // Interleaved A/B; DCO not inverted.
                9:  adc_word = 24'h001700; // Disable extra DCO delay.
                10: adc_word = 24'h00180f; // Vendor input-span setting.
                11: adc_word = 24'h001900;
                12: adc_word = 24'h001a00;
                13: adc_word = 24'h001bff;
                14: adc_word = 24'h001cff;
                15: adc_word = 24'h001d55;
                16: adc_word = 24'h001e00;
                17: adc_word = 24'h001fff;
                18: adc_word = 24'h0020ff;
                default: adc_word = 24'h00ff01; // Commit shadow registers.
            endcase
        end
    endfunction

    always @(posedge ctrl_clk or negedge ctrl_rst_n) begin
        if (!ctrl_rst_n) begin
            state <= WAIT_DELAY;
            resume_state <= START_WORD;
            phase <= CLOCK_CONFIG;
            word_index <= 0;
            bit_index <= 0;
            wait_count <= POWERUP_DELAY_CYCLES;
            spi_count <= 0;
            spi_shift <= 0;
            device_spi_sclk <= 1'b0;
            adk_spi_csb <= 1'b1;
            adc_spi_csb <= 1'b1;
        end else begin
            case (state)
                WAIT_DELAY: begin
                    if (wait_count == 0)
                        state <= resume_state;
                    else
                        wait_count <= wait_count - 1'b1;
                end
                START_WORD: begin
                    if (phase == CLOCK_CONFIG)
                        spi_shift <= clock_word(word_index);
                    else if (phase == ADC_TEST_CONFIG)
                        spi_shift <= adc_word(word_index);
                    else begin
                        case (word_index)
                            0: spi_shift <= 24'h000503;
                            1: spi_shift <= 24'h000d00; // Normal conversion.
                            default: spi_shift <= 24'h00ff01;
                        endcase
                    end
                    adk_spi_csb <= (phase != CLOCK_CONFIG);
                    adc_spi_csb <= (phase == CLOCK_CONFIG);
                    device_spi_sclk <= 1'b0;
                    bit_index <= 23;
                    spi_count <= SPI_HALF_CYCLES - 1;
                    state <= SPI_RISE;
                end
                SPI_RISE: begin
                    if (spi_count == 0) begin
                        device_spi_sclk <= 1'b1;
                        spi_count <= SPI_HALF_CYCLES - 1;
                        state <= SPI_FALL;
                    end else
                        spi_count <= spi_count - 1'b1;
                end
                SPI_FALL: begin
                    if (spi_count == 0) begin
                        device_spi_sclk <= 1'b0;
                        spi_count <= SPI_HALF_CYCLES - 1;
                        if (bit_index == 0)
                            state <= CS_HOLD;
                        else begin
                            spi_shift <= {spi_shift[22:0], 1'b0};
                            bit_index <= bit_index - 1'b1;
                            state <= SPI_RISE;
                        end
                    end else
                        spi_count <= spi_count - 1'b1;
                end
                CS_HOLD: begin
                    if (spi_count == 0) begin
                        adk_spi_csb <= 1'b1;
                        adc_spi_csb <= 1'b1;
                        spi_count <= SPI_HALF_CYCLES - 1;
                        state <= CS_GAP;
                    end else
                        spi_count <= spi_count - 1'b1;
                end
                CS_GAP: begin
                    if (spi_count != 0)
                        spi_count <= spi_count - 1'b1;
                    else begin
                        word_index <= word_index + 1'b1;
                        state <= START_WORD;
                        resume_state <= START_WORD;
                        if (phase == CLOCK_CONFIG && word_index == 71) begin
                            // Let VCO calibration finish before software SYNC.
                            wait_count <= CLOCK_SETTLE_CYCLES;
                            state <= WAIT_DELAY;
                        end else if (phase == CLOCK_CONFIG && word_index == 75) begin
                            phase <= ADC_TEST_CONFIG;
                            word_index <= 0;
                            wait_count <= CLOCK_SETTLE_CYCLES;
                            state <= WAIT_DELAY;
                        end else if (phase == ADC_TEST_CONFIG && word_index == 1) begin
                            wait_count <= ADC_SETTLE_CYCLES;
                            state <= WAIT_DELAY;
                        end else if (phase == ADC_TEST_CONFIG && word_index == 19) begin
                            phase <= ADC_NORMAL_CONFIG;
                            word_index <= 0;
                            wait_count <= ADC_TEST_CYCLES;
                            state <= WAIT_DELAY;
                        end else if (phase == ADC_NORMAL_CONFIG && word_index == 2) begin
                            wait_count <= ADC_SETTLE_CYCLES;
                            resume_state <= DONE;
                            state <= WAIT_DELAY;
                        end
                    end
                end
                DONE: begin
                    device_spi_sclk <= 1'b0;
                    adk_spi_csb <= 1'b1;
                    adc_spi_csb <= 1'b1;
                end
                default: begin
                    state <= WAIT_DELAY;
                    resume_state <= START_WORD;
                    phase <= CLOCK_CONFIG;
                    word_index <= 0;
                    wait_count <= POWERUP_DELAY_CYCLES;
                    device_spi_sclk <= 1'b0;
                    adk_spi_csb <= 1'b1;
                    adc_spi_csb <= 1'b1;
                end
            endcase
        end
    end
endmodule

// ADC cannot pause. Mark every sample before CDC and preserve markers with data.
module adc_stream_source #(
    parameter integer TRACE_PERIOD=31250,
    parameter integer TRACE_POINTS=16320,
    parameter integer AOM_WIDTH=12,
    parameter integer WARMUP_SAMPLES=64
)(
    input wire sample_clk, reset_n, sample_valid, enable_async,
    input wire [13:0] ch_a, ch_b, input wire stream_ready,
    output reg [31:0] stream_data, output reg [1:0] stream_user,
    output reg stream_valid, output reg aom_pulse,
    output reg overflow, output reg active
);
    (* ASYNC_REG = "TRUE" *) reg [1:0] enable_sync = 0;
    reg [31:0] sample_position;
    reg [15:0] warmup;
    wire warmed = warmup == WARMUP_SAMPLES;
    always @(posedge sample_clk or negedge reset_n) begin
        if (!reset_n) enable_sync <= 0;
        else enable_sync <= {enable_sync[0],enable_async};
    end
    always @(posedge sample_clk or negedge reset_n) begin
        if (!reset_n) begin
            stream_data <= 0; stream_user <= 0; stream_valid <= 0;
            aom_pulse <= 0; overflow <= 0; active <= 0;
            sample_position <= 0; warmup <= 0;
        end else begin
            if (stream_valid && stream_ready) stream_valid <= 0;
            if (!enable_sync[1]) begin active <= 0; aom_pulse <= 0; end
            else if (!active && !overflow && stream_ready && sample_valid) active <= 1;
            if (active && enable_sync[1] && !overflow && sample_valid) begin
                if (!stream_valid || stream_ready) begin
                    stream_data <= {{2{ch_b[13]}},ch_b,{2{ch_a[13]}},ch_a};
                    stream_valid <= 1;
                    stream_user <= {warmed && sample_position == TRACE_POINTS-1,
                                    warmed && sample_position < TRACE_POINTS};
                    aom_pulse <= warmed && sample_position < AOM_WIDTH;
                    if (!warmed) warmup <= warmup + 1'b1;
                    else if (sample_position == TRACE_PERIOD-1) sample_position <= 0;
                    else sample_position <= sample_position + 1'b1;
                end else begin
                    overflow <= 1; active <= 0; aom_pulse <= 0;
                end
            end
        end
    end
endmodule

`default_nettype wire
