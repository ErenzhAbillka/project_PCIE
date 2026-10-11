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
    parameter integer AOM_WIDTH = 12,
    parameter TX_SINE_MEM = "sine_4096.mem"
)(
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET rst_n, FREQ_HZ 200000000" *)
    input  wire        ctrl_clk,
    input  wire        rst_n,
    // ctrl_clk-domain run level. Default VIO output is zero until DSP is connected.
    input  wire        acquisition_enable,
    // Change test mode only before the first acquisition request after reset.
    input  wire        adc_test_enable,
    output wire        adc_test_active,
    output wire        adc_test_error,
    output wire [31:0] adc_test_checked_count,
    output wire [31:0] adc_test_error_count,
    output wire        adc_test_config_locked,
    // Electrical TX01 profile only: RAW + normal ADC, one chirp per reset.
    input  wire        tx_enable,
    input  wire        tx_abort,
    output wire        tx_init_done,
    output wire        tx_fault,
    output wire [31:0] tx_status,
    output wire [15:0] dac_data_p,
    output wire [15:0] dac_data_n,
    output wire        dac_dci_p,
    output wire        dac_dci_n,
    output wire        dac_frame_p,
    output wire        dac_frame_n,
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
    output wire        device_spi_sclk,
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
    reg sample_capture_enable = 0;
    reg ramp_check_enable = 0;
    reg test_mode_target = 0;

    wire dac_forward_clk;
    adc_driver #(.INPUT_DELAY_TAPS(INPUT_DELAY_TAPS)) adc_driver_inst (
        .ctrl_clk(ctrl_clk), .rst(~ctrl_rst_n), .capture_enable(sample_capture_enable),
        .adc_data_clk_p(adc_data_clk_p), .adc_data_clk_n(adc_data_clk_n),
        .data_pin_p(data_pin_p), .data_pin_n(data_pin_n),
        .adc_data_out_ch1(adc_data_ch1), .adc_data_out_ch2(adc_data_ch2),
        .adc_data_clk_bufg(sys_clk), .adc_data_valid(adc_data_valid),
        .dac_forward_clk(dac_forward_clk)
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
        else if (acquisition_enable && init_done &&
                 adc_test_enable == test_mode_target &&
                 (!tx_enable || tx_init_done)) run_latched <= 1;
    end
    assign adc_test_active = ramp_check_enable;
    assign adc_test_config_locked = run_latched;
    wire stable_acquisition_enable = run_latched && init_done;
    wire waveform_run;
    adc_stream_source #(.TRACE_PERIOD(TRACE_PERIOD), .TRACE_POINTS(TRACE_POINTS),
                        .AOM_WIDTH(AOM_WIDTH)) stream_source_inst (
        .sample_clk(sys_clk), .reset_n(adc_fifo_aresetn),
        .sample_valid(adc_data_valid), .enable_async(stable_acquisition_enable),
        .ch_a(adc_data_ch1), .ch_b(adc_data_ch2),
        .stream_ready(stream_ready), .stream_data(stream_data),
        .stream_valid(stream_valid), .stream_user(stream_user), .aom_pulse(aom_pulse),
        .overflow(overflow_adc), .active(active_adc), .waveform_run(waveform_run)
    );
    (* ASYNC_REG = "TRUE" *) reg [1:0] overflow_sync = 0, active_sync = 0;
    always @(posedge ctrl_clk) begin
        if (!ctrl_rst_n) begin overflow_sync <= 0; active_sync <= 0; end
        else begin
            overflow_sync <= {overflow_sync[0], overflow_adc};
            active_sync <= {active_sync[0], active_adc};
        end
    end
    // A stopped/restarted sample clock must not silently splice separate ADC
    // runs into one DAS group. Keep this fault in the independent control
    // clock domain; only a system reset permits acquisition to start again.
    wire capture_fault;
    adc_capture_monitor capture_monitor_inst (
        .ctrl_clk(ctrl_clk), .reset_n(ctrl_rst_n), .run(run_latched && init_done),
        .sample_clk(sys_clk), .sample_valid(adc_data_valid),
        .fault(capture_fault)
    );
    assign adc_overflow = overflow_sync[1] | capture_fault;
    assign acquisition_active = active_sync[1];

    // Digital tests run before normal acquisition and can remain enabled for
    // board bring-up. Counts cross domains as one held request/ack snapshot.
    wire checker_reset_n, ramp_error;
    wire [31:0] ramp_checked_count, ramp_error_count;
    (* ASYNC_REG = "TRUE" *) reg [1:0] checker_reset_sync = 0;
    always @(posedge sys_clk or negedge ctrl_rst_n) begin
        if (!ctrl_rst_n) checker_reset_sync <= 0;
        else checker_reset_sync <= {checker_reset_sync[0],1'b1};
    end
    assign checker_reset_n = checker_reset_sync[1];
    adc_ramp_checker ramp_checker_inst (
        .sample_clk(sys_clk), .reset_n(checker_reset_n),
        .enable_async(ramp_check_enable), .sample_valid(adc_data_valid),
        .ch_a(adc_data_ch1), .ch_b(adc_data_ch2),
        .error(ramp_error), .checked_count(ramp_checked_count), .error_count(ramp_error_count)
    );
    adc_test_snapshot test_snapshot_inst (
        .ctrl_clk(ctrl_clk), .ctrl_reset_n(ctrl_rst_n),
        .sample_clk(sys_clk), .sample_reset_n(checker_reset_n),
        .source_error(ramp_error), .source_checked_count(ramp_checked_count),
        .source_error_count(ramp_error_count), .error(adc_test_error),
        .checked_count(adc_test_checked_count), .error_count(adc_test_error_count)
    );

    // ADC/AD9516 use 16-bit instruction + 8-bit data writes. The AD9122 has
    // its own 8+8-bit read/write engine. Grant it only after ADC mode is stable;
    // hold ownership through command gaps so SDIO never has two drivers.
    assign adc_sync = 1'b0;
    reg [23:0] spi_shift;
    reg adc_device_sclk;
    wire spi_sdi, dac_bus_owned, dac_sclk, dac_sdo, dac_oe, dac_cs_n;
    assign device_spi_sclk = dac_bus_owned ? dac_sclk : adc_device_sclk;
    assign dac_spi_csb = dac_bus_owned ? dac_cs_n : 1'b1;
    IOBUF spi_sdio_buffer (
        .I(dac_bus_owned ? dac_sdo : spi_shift[23]),
        .T(dac_bus_owned ? !dac_oe : (adk_spi_csb && adc_spi_csb)),
        .O(spi_sdi), .IO(device_spi_sda)
    );

    // Initialization precedes the ADC stream. Both data and the quadrature
    // forwarded DCI come from the ADC MMCM; no independent TX start CDC exists.
    (* ASYNC_REG = "TRUE" *) reg [1:0] tx_adc_valid_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] tx_arm_sync = 0, tx_kill_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] tx_ready_ctrl_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] tx_started_ctrl_sync = 0, tx_done_ctrl_sync = 0;
    reg tx_aborted = 0, tx_requested = 0;
    reg [4:0] tx_qualify = 0;
    wire dac_init_ready, dac_init_fault, dac_busy, dac_sample_ready;
    wire [3:0] dac_error_code;
    wire [7:0] dac_revision, dac_fifo_level;
    wire tx_shot_started, tx_shot_done;
    wire profile_valid = (TRACE_PERIOD == 31250);
    wire tx_clocks_ready = tx_adc_valid_sync[1] && init_done && !adc_overflow &&
                           !test_mode_target && !adc_test_enable;
    wire tx_bus_grant = init_done && adk_spi_csb && adc_spi_csb;
    wire tx_request = (tx_qualify == 31) && !tx_requested && !tx_aborted && !tx_abort &&
                      tx_enable && tx_clocks_ready && tx_bus_grant && profile_valid;
    assign tx_fault = dac_init_fault || tx_aborted || (tx_enable && !profile_valid);
    assign tx_init_done = dac_init_ready && tx_ready_ctrl_sync[1] && !tx_fault;
    wire [3:0] tx_error_code = tx_aborted ? 4'hf : (tx_enable && !profile_valid) ? 4'he : dac_error_code;
    assign tx_status = {8'b0,dac_revision,dac_fifo_level,tx_error_code,
                        dac_busy,tx_started_ctrl_sync[1],tx_done_ctrl_sync[1],tx_init_done};
    always @(posedge ctrl_clk) begin
        if (!ctrl_rst_n) begin
            tx_adc_valid_sync <= 0; tx_ready_ctrl_sync <= 0;
            tx_started_ctrl_sync <= 0; tx_done_ctrl_sync <= 0;
            tx_aborted <= 0; tx_requested <= 0; tx_qualify <= 0;
        end else begin
            tx_adc_valid_sync <= {tx_adc_valid_sync[0],adc_data_valid};
            tx_ready_ctrl_sync <= {tx_ready_ctrl_sync[0],dac_sample_ready};
            tx_started_ctrl_sync <= {tx_started_ctrl_sync[0],tx_shot_started};
            tx_done_ctrl_sync <= {tx_done_ctrl_sync[0],tx_shot_done};
            if (tx_abort) tx_aborted <= 1;
            if (!tx_enable || !tx_clocks_ready || !tx_bus_grant || !profile_valid || tx_aborted)
                tx_qualify <= 0;
            else if (tx_qualify != 31) tx_qualify <= tx_qualify + 1'b1;
            if (tx_request) tx_requested <= 1;
        end
    end
    always @(posedge sys_clk or negedge adc_fifo_aresetn) begin
        if (!adc_fifo_aresetn) begin tx_arm_sync <= 0; tx_kill_sync <= 0; end
        else begin
            tx_arm_sync <= {tx_arm_sync[0],tx_enable};
            tx_kill_sync <= {tx_kill_sync[0],tx_aborted || adc_overflow || dac_init_fault};
        end
    end
    wire signed [15:0] tx_i, tx_q;
    wire tx_sample_valid;
    tgd_tx_sample_path #(.PERIOD_SAMPLES(31250),.SINE_MEM(TX_SINE_MEM)) tx_sample_inst (
        .sample_clk(sys_clk),.reset_n(adc_fifo_aresetn),.run(waveform_run),
        .hardware_arm(tx_arm_sync[1]),.tx_kill(tx_kill_sync[1]),
        .dac_configured(dac_sample_ready),.waveform_approved(profile_valid),
        .active(),.sample_valid(tx_sample_valid),.sweep_gate(),.sweep_start(),.sample_index(),
        .i_sample(tx_i),.q_sample(tx_q),.tx_data_enable(),
        .shot_started(tx_shot_started),.shot_done(tx_shot_done)
    );
    tgd_tx_frontend #(.CTRL_CLK_HZ(CTRL_CLK_HZ),.SPI_CLK_HZ(SPI_CLK_HZ)) tx_frontend_inst (
        .ctrl_clk(ctrl_clk),.ctrl_reset_n(ctrl_rst_n),.request(tx_request),
        .bus_grant(tx_bus_grant),.clocks_ready(tx_clocks_ready),
        .busy(dac_busy),.done(),.init_ready(dac_init_ready),.init_fault(dac_init_fault),
        .error_code(dac_error_code),.revision_id(dac_revision),.fifo_level(dac_fifo_level),
        .spi_ownership(dac_bus_owned),.spi_sclk(dac_sclk),.spi_sdo(dac_sdo),.spi_oe(dac_oe),
        .spi_cs_n(dac_cs_n),.spi_sdi(spi_sdi),
        .sample_clk(sys_clk),.forward_clk(dac_forward_clk),.sample_reset(!adc_fifo_aresetn),
        .hardware_arm(tx_arm_sync[1]),.waveform_approved(profile_valid),.tx_kill(tx_kill_sync[1]),
        .sample_valid(tx_sample_valid),.i_sample(tx_i),.q_sample(tx_q),
        .sample_ready(dac_sample_ready),.tx_data_enabled(),
        .dac_data_p(dac_data_p),.dac_data_n(dac_data_n),.dac_dci_p(dac_dci_p),.dac_dci_n(dac_dci_n),
        .dac_frame_p(dac_frame_p),.dac_frame_n(dac_frame_n)
    );

    localparam integer SPI_HALF_CYCLES =
        (CTRL_CLK_HZ + 2 * SPI_CLK_HZ - 1) / (2 * SPI_CLK_HZ);
    localparam [3:0] WAIT_DELAY = 0, START_WORD = 1, SPI_RISE = 2,
                     SPI_FALL = 3, CS_HOLD = 4, CS_GAP = 5, DONE = 6,
                     TEST_WINDOW = 7, MODE_READY = 8;
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
            adc_device_sclk <= 1'b0;
            adk_spi_csb <= 1'b1;
            adc_spi_csb <= 1'b1;
            sample_capture_enable <= 0;
            ramp_check_enable <= 0;
            test_mode_target <= 0;
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
                        if (word_index == 0) begin
                            sample_capture_enable <= 0;
                            ramp_check_enable <= 0;
                        end
                        case (word_index)
                            0: spi_shift <= 24'h000503;
                            1: spi_shift <= test_mode_target ? 24'h000d0f : 24'h000d00;
                            default: spi_shift <= 24'h00ff01;
                        endcase
                    end
                    adk_spi_csb <= (phase != CLOCK_CONFIG);
                    adc_spi_csb <= (phase == CLOCK_CONFIG);
                    adc_device_sclk <= 1'b0;
                    bit_index <= 23;
                    spi_count <= SPI_HALF_CYCLES - 1;
                    state <= SPI_RISE;
                end
                SPI_RISE: begin
                    if (spi_count == 0) begin
                        adc_device_sclk <= 1'b1;
                        spi_count <= SPI_HALF_CYCLES - 1;
                        state <= SPI_FALL;
                    end else
                        spi_count <= spi_count - 1'b1;
                end
                SPI_FALL: begin
                    if (spi_count == 0) begin
                        adc_device_sclk <= 1'b0;
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
                            sample_capture_enable <= 1;
                            wait_count <= ADC_SETTLE_CYCLES;
                            resume_state <= TEST_WINDOW;
                            state <= WAIT_DELAY;
                        end else if (phase == ADC_NORMAL_CONFIG && word_index == 2) begin
                            sample_capture_enable <= 1;
                            wait_count <= ADC_SETTLE_CYCLES;
                            resume_state <= MODE_READY;
                            state <= WAIT_DELAY;
                        end
                    end
                end
                DONE: begin
                    adc_device_sclk <= 1'b0;
                    adk_spi_csb <= 1'b1;
                    adc_spi_csb <= 1'b1;
                    // A simultaneous start and mode change waits for the new
                    // mode to commit and settle. Run locks SPI until reset.
                    if (!run_latched && !dac_bus_owned && adc_test_enable != test_mode_target) begin
                        test_mode_target <= adc_test_enable;
                        phase <= ADC_NORMAL_CONFIG;
                        word_index <= 0;
                        sample_capture_enable <= 0;
                        ramp_check_enable <= 0;
                        state <= START_WORD;
                    end
                end
                TEST_WINDOW: begin
                    ramp_check_enable <= 1;
                    phase <= ADC_NORMAL_CONFIG;
                    word_index <= 0;
                    test_mode_target <= !run_latched && adc_test_enable;
                    wait_count <= ADC_TEST_CYCLES;
                    resume_state <= START_WORD;
                    state <= WAIT_DELAY;
                end
                MODE_READY: begin
                    ramp_check_enable <= test_mode_target;
                    state <= DONE;
                end
                default: begin
                    state <= WAIT_DELAY;
                    resume_state <= START_WORD;
                    phase <= CLOCK_CONFIG;
                    word_index <= 0;
                    wait_count <= POWERUP_DELAY_CYCLES;
                    adc_device_sclk <= 1'b0;
                    adk_spi_csb <= 1'b1;
                    adc_spi_csb <= 1'b1;
                    sample_capture_enable <= 0;
                    ramp_check_enable <= 0;
                    test_mode_target <= 0;
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
    output reg overflow, output reg active,
    output wire waveform_run
);
    (* ASYNC_REG = "TRUE" *) reg [1:0] enable_sync = 0;
    reg [31:0] sample_position;
    reg [15:0] warmup;
    wire warmed = warmup == WARMUP_SAMPLES;
    assign waveform_run = active && enable_sync[1] && !overflow && sample_valid && warmed;
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

// Continuity monitor: startup without DCO is allowed. Once a requested run has
// seen valid ADC data, loss of valid or of the sample-clock heartbeat is fatal.
// At 200 MHz, the default timeout is 20.48 us; normal 125 MHz sampling changes
// the heartbeat every 8 ns. The timeout is not a sampling-frequency meter.
module adc_capture_monitor #(
    parameter integer WATCHDOG_CYCLES = 4096
)(
    input wire ctrl_clk, reset_n, run,
    input wire sample_clk, sample_valid,
    output reg fault
);
    reg sample_heartbeat = 0;
    // Heartbeat has no data meaning and needs no asynchronous cross-domain reset.
    always @(posedge sample_clk) sample_heartbeat <= ~sample_heartbeat;

    (* ASYNC_REG = "TRUE" *) reg [1:0] heartbeat_sync = 0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] sample_valid_sync = 0;
    localparam integer WATCHDOG_WIDTH = WATCHDOG_CYCLES < 2 ? 1 : $clog2(WATCHDOG_CYCLES);
    reg [WATCHDOG_WIDTH-1:0] watchdog_count = 0;
    reg heartbeat_previous = 0;
    reg armed = 0;
    always @(posedge ctrl_clk or negedge reset_n) begin
        if (!reset_n) begin
            heartbeat_sync <= 0;
            sample_valid_sync <= 0;
            heartbeat_previous <= 0;
            watchdog_count <= 0;
            armed <= 0;
            fault <= 0;
        end else begin
            heartbeat_sync <= {heartbeat_sync[0], sample_heartbeat};
            sample_valid_sync <= {sample_valid_sync[0], sample_valid};
            heartbeat_previous <= heartbeat_sync[1];
            if (!armed) begin
                watchdog_count <= 0;
                if (run && sample_valid_sync[1]) armed <= 1;
            end else if (!fault) begin
                if (!sample_valid_sync[1]) fault <= 1;
                if (heartbeat_sync[1] != heartbeat_previous)
                    watchdog_count <= 0;
                else if (watchdog_count == WATCHDOG_CYCLES-1)
                    fault <= 1;
                else watchdog_count <= watchdog_count + 1'b1;
            end
        end
    end
`ifndef SYNTHESIS
    initial begin
        if (WATCHDOG_CYCLES < 1) $fatal(1, "WATCHDOG_CYCLES must be positive");
    end
`endif
endmodule

// AD9643 0x0d=0x0f selects a 14-bit modulo ramp on each channel. With
// 0x14=0x05, bit 2 inverts DIGITAL test patterns: consecutive codes decrement.
// See ADI engineer's AD9643 test-modes clarification and register table 15.
// Seed A/B independently: the common ramp cannot establish absolute A/B identity.
module adc_ramp_checker #(
    parameter integer SETTLE_SAMPLES = 32,
    parameter integer COUNT_WIDTH = 32
)(
    input wire sample_clk, reset_n, enable_async, sample_valid,
    input wire [13:0] ch_a, ch_b,
    output reg error,
    output reg [COUNT_WIDTH-1:0] checked_count, error_count
);
    (* ASYNC_REG = "TRUE" *) reg [1:0] enable_sync = 0;
    localparam integer WARMUP_WIDTH = SETTLE_SAMPLES < 2 ? 1 : $clog2(SETTLE_SAMPLES+1);
    reg [WARMUP_WIDTH-1:0] warmup;
    reg seeded;
    reg [13:0] previous_a, previous_b;
    wire pair_error = ch_a != (previous_a - 14'd1) ||
                      ch_b != (previous_b - 14'd1);
    always @(posedge sample_clk or negedge reset_n) begin
        if (!reset_n) enable_sync <= 0;
        else enable_sync <= {enable_sync[0], enable_async};
    end
    always @(posedge sample_clk or negedge reset_n) begin
        if (!reset_n) begin
            warmup <= 0;
            seeded <= 0;
            previous_a <= 0;
            previous_b <= 0;
            error <= 0;
            checked_count <= 0;
            error_count <= 0;
        end else if (!enable_sync[1] || !sample_valid) begin
            // Mode changes/invalid input restart the seed, not diagnostic history.
            warmup <= 0;
            seeded <= 0;
        end else if (warmup != SETTLE_SAMPLES) begin
            warmup <= warmup + 1'b1;
            seeded <= 0;
        end else begin
            previous_a <= ch_a;
            previous_b <= ch_b;
            if (!seeded) seeded <= 1;
            else begin
                if (!(&checked_count)) checked_count <= checked_count + 1'b1;
                if (pair_error) begin
                    error <= 1;
                    // Count one error per A/B sample pair, even if both fail.
                    if (!(&error_count)) error_count <= error_count + 1'b1;
                end
            end
        end
    end
`ifndef SYNTHESIS
    initial begin
        if (SETTLE_SAMPLES < 0 || COUNT_WIDTH < 1)
            $fatal(1, "Invalid adc_ramp_checker parameters");
    end
`endif
endmodule

// Request/acknowledge bundled-data snapshot. The sample-domain payload remains
// held from acknowledgement until a later request. Two ack synchronization
// stages plus a further capture cycle precede the ctrl-domain payload capture.
// Constrain this held data path with set_max_delay; never double-synchronize a
// changing binary counter bus. A stopped DCO leaves the last snapshot unchanged.
module adc_test_snapshot #(
    parameter integer REFRESH_CYCLES = 1024
)(
    input wire ctrl_clk, ctrl_reset_n, sample_clk, sample_reset_n,
    input wire source_error,
    input wire [31:0] source_checked_count, source_error_count,
    output reg error,
    output reg [31:0] checked_count, error_count
);
    reg request_toggle = 0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] request_sync = 0;
    reg ack_toggle = 0;
    reg [64:0] snapshot_data = 0;
    always @(posedge sample_clk or negedge sample_reset_n) begin
        if (!sample_reset_n) begin
            request_sync <= 0;
            ack_toggle <= 0;
            snapshot_data <= 0;
        end else begin
            request_sync <= {request_sync[0], request_toggle};
            if (request_sync[1] != ack_toggle) begin
                snapshot_data <= {source_error, source_error_count, source_checked_count};
                ack_toggle <= request_sync[1];
            end
        end
    end
    (* ASYNC_REG = "TRUE" *) reg [1:0] ack_sync = 0;
    localparam integer REFRESH_WIDTH = REFRESH_CYCLES < 2 ? 1 : $clog2(REFRESH_CYCLES);
    reg [REFRESH_WIDTH-1:0] refresh_count = 0;
    reg ack_previous = 0;
    reg capture_pending = 0;
    always @(posedge ctrl_clk or negedge ctrl_reset_n) begin
        if (!ctrl_reset_n) begin
            request_toggle <= 0;
            ack_sync <= 0;
            refresh_count <= 0;
            ack_previous <= 0;
            capture_pending <= 0;
            error <= 0;
            checked_count <= 0;
            error_count <= 0;
        end else begin
            ack_sync <= {ack_sync[0], ack_toggle};
            if (capture_pending) begin
                {error, error_count, checked_count} <= snapshot_data;
                capture_pending <= 0;
                refresh_count <= 0;
            end else if (ack_sync[1] != ack_previous) begin
                ack_previous <= ack_sync[1];
                capture_pending <= 1;
            end else if (ack_sync[1] == request_toggle) begin
                if (refresh_count == REFRESH_CYCLES-1) begin
                    request_toggle <= ~request_toggle;
                    refresh_count <= 0;
                end else refresh_count <= refresh_count + 1'b1;
            end
        end
    end
`ifndef SYNTHESIS
    initial begin
        if (REFRESH_CYCLES < 1) $fatal(1, "REFRESH_CYCLES must be positive");
    end
`endif
endmodule

`default_nettype wire
