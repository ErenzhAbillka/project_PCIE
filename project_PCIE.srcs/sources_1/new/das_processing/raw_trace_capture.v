`timescale 1ns/1ps
`default_nettype none

// Finite diagnostic capture. Keep the first complete ADC window in BRAM, then
// drain subsequent ADC samples without overwriting it. Frame delivery is not a
// DDR commit: the existing packetizer's ddr_frames_done is the publish counter.
module raw_trace_capture #(
    parameter integer TRACE_POINTS = 16320,
    parameter integer FRAME_WORDS = 16384,
    parameter integer SAMPLE_RATE = 125000000,
    parameter integer TRACE_PERIOD = 31250
)(
    input wire clk, reset_n, arm, input_fault,
    input wire [31:0] epoch_cfg, config_id_cfg,
    input wire test_active,
    input wire [31:0] adc_data,
    input wire [1:0] adc_user,
    input wire adc_valid, output wire adc_ready,
    output reg [31:0] frame_data,
    output wire frame_valid, frame_last, input wire frame_ready,
    output reg capture_complete, capture_error, frame_sent
);
    localparam integer HEADER_WORDS = 32;
    localparam integer FOOTER_START = FRAME_WORDS - 32;
    localparam integer POINT_W = TRACE_POINTS < 2 ? 1 : $clog2(TRACE_POINTS);
    localparam integer FRAME_W = $clog2(FRAME_WORDS);
    (* ram_style = "block" *) reg [31:0] samples [0:TRACE_POINTS-1];
    reg [POINT_W-1:0] point;
    reg in_window, saw_outside;
    reg [31:0] epoch, config_id, payload_xor;
    reg [7:0] test_mode;
    assign adc_ready = reset_n;
    wire take = adc_valid && adc_ready;
    wire capturing = arm && !capture_complete && !capture_error;
    wire window_take = capturing && take && adc_user[0] && (in_window || saw_outside);

    // No RAM reset: every payload entry is written before the frame is emitted.
    always @(posedge clk) begin
        if (window_take && !input_fault) samples[point] <= adc_data;
    end
    always @(posedge clk) begin
        if (!reset_n) begin
            point <= 0; in_window <= 0; saw_outside <= 0;
            epoch <= 0; config_id <= 0; payload_xor <= 0; test_mode <= 0;
            capture_complete <= 0; capture_error <= 0;
        end else if (capturing) begin
            if (input_fault) capture_error <= 1;
            else if (take) begin
                if (adc_user[1] && !adc_user[0]) capture_error <= 1;
                if (!adc_user[0]) begin
                    saw_outside <= 1;
                    if (in_window) capture_error <= 1;
                end else if (!in_window && !saw_outside) begin
                    // The source supplies warmup/outside samples before every
                    // first window. Starting in its middle is not a valid trace.
                    capture_error <= 1;
                end else begin
                    if (!in_window) begin
                        in_window <= 1;
                        epoch <= epoch_cfg; config_id <= config_id_cfg;
                        test_mode <= test_active ? 8'h0f : 8'h00;
                    end
                    payload_xor <= payload_xor ^ adc_data;
                    if (adc_user[1] != (point == TRACE_POINTS-1)) capture_error <= 1;
                    else if (point == TRACE_POINTS-1) begin
                        capture_complete <= 1;
                        in_window <= 0;
                    end else point <= point + 1'b1;
                end
            end
        end
    end

    function [31:0] metadata;
        input integer index;
        begin
            metadata = 0;
            case (index)
                0: metadata = 32'h52415731; // RAW1, little-endian uint32 words
                1: metadata = 0;            // single-shot frame sequence
                2: metadata = FRAME_WORDS;
                3: metadata = TRACE_POINTS;
                4: metadata = 0;            // first trace after source warmup
                5: metadata = epoch;
                6: metadata = SAMPLE_RATE;
                7: metadata = TRACE_PERIOD;
                8: metadata = 1;            // capture stride
                9: metadata = {24'b0,test_mode};
                10: metadata = 0;           // invalid captures are not published
                11: metadata = 6;           // signed14 extended to16; A low/B high
                12: metadata = config_id;
                13: metadata = 14;
                14: metadata = 1;           // protocol version
                15: metadata = 32'hffffffff;
                FOOTER_START: metadata = 32'h52415731;
                FOOTER_START+1: metadata = 0;
                FOOTER_START+2: metadata = 32'hffffffff;
                FOOTER_START+3: metadata = 0;
                FOOTER_START+4: metadata = epoch;
                FOOTER_START+5: metadata = TRACE_POINTS;
                FOOTER_START+6: metadata = 0;
                FOOTER_START+7: metadata = 6;
                FOOTER_START+8: metadata = payload_xor;
                FOOTER_START+9: metadata = ~payload_xor;
                FRAME_WORDS-4: metadata = 32'h434f4d54; // COMT
                FRAME_WORDS-3: metadata = 0;
                FRAME_WORDS-2: metadata = 32'hffffffff;
                FRAME_WORDS-1: metadata = 32'h454e4421; // END!
                default: metadata = 0;
            endcase
        end
    endfunction

    localparam [2:0] OUT_IDLE=0, OUT_READ=1, OUT_LOAD=2, OUT_HOLD=3, OUT_DONE=4;
    reg [2:0] out_state;
    reg [FRAME_W-1:0] out_index;
    reg [31:0] sample_read;
    wire is_payload = out_index >= HEADER_WORDS && out_index < HEADER_WORDS+TRACE_POINTS;
    always @(posedge clk) begin
        if (out_state == OUT_READ && is_payload)
            sample_read <= samples[out_index-HEADER_WORDS];
    end
    assign frame_valid = reset_n && out_state == OUT_HOLD;
    assign frame_last = out_index == FRAME_WORDS-1;
    always @(posedge clk) begin
        if (!reset_n) begin
            out_state <= OUT_IDLE; out_index <= 0; frame_data <= 0; frame_sent <= 0;
        end else begin
            case (out_state)
                OUT_IDLE: if (capture_complete && !capture_error) out_state <= OUT_READ;
                OUT_READ: out_state <= OUT_LOAD;
                OUT_LOAD: begin
                    frame_data <= is_payload ? sample_read : metadata(out_index);
                    out_state <= OUT_HOLD;
                end
                OUT_HOLD: if (frame_ready) begin
                    if (out_index == FRAME_WORDS-1) begin
                        frame_sent <= 1; out_state <= OUT_DONE;
                    end else begin
                        out_index <= out_index + 1'b1; out_state <= OUT_READ;
                    end
                end
                OUT_DONE: out_state <= OUT_DONE;
                default: out_state <= OUT_IDLE;
            endcase
        end
    end
`ifndef SYNTHESIS
    initial begin
        if (TRACE_POINTS < 1 || FRAME_WORDS < TRACE_POINTS+64 ||
            (FRAME_WORDS & (FRAME_WORDS-1)) != 0 || FRAME_WORDS < 128)
            $fatal(1,"Invalid RAW frame parameters");
    end
`endif
endmodule

// Lock acquisition configuration on the first start request. A system reset is
// required for another run; never reset a writer with an AXI burst outstanding.
module acquisition_router #(
    parameter integer TRACE_POINTS = 16320,
    parameter integer FRAME_WORDS = 16384,
    parameter integer SAMPLE_RATE = 125000000,
    parameter integer TRACE_PERIOD = 31250
)(
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000, ASSOCIATED_RESET reset_n" *)
    input wire clk, input wire reset_n,
    input wire start, raw_mode_cfg, test_enable_cfg, tx_enable_cfg,
    input wire [31:0] epoch_cfg, config_id_cfg,
    input wire adc_test_active, input_fault, tx_init_done, tx_fault,
    output wire frontend_enable, adc_test_request, tx_enable_locked,
    output reg mode_locked, raw_mode_active, configuration_error,
    input wire [31:0] adc_data, input wire [1:0] adc_user,
    input wire adc_valid, output wire adc_ready,
    output wire [31:0] das_adc_data, output wire [1:0] das_adc_user,
    output wire das_adc_valid, input wire das_adc_ready,
    input wire [31:0] das_frame_data,
    input wire das_frame_valid, das_frame_last, output wire das_frame_ready,
    output wire [31:0] frame_data,
    output wire frame_valid, frame_last, input wire frame_ready,
    output wire raw_capture_complete, raw_capture_error, raw_frame_sent
);
    reg test_locked, tx_locked;
    reg [31:0] epoch_locked, config_locked;
    always @(posedge clk) begin
        if (!reset_n) begin
            mode_locked <= 0; raw_mode_active <= 0; test_locked <= 0; tx_locked <= 0;
            epoch_locked <= 0; config_locked <= 0; configuration_error <= 0;
        end else if (start && !mode_locked) begin
            mode_locked <= 1; raw_mode_active <= raw_mode_cfg;
            test_locked <= test_enable_cfg; tx_locked <= tx_enable_cfg; epoch_locked <= epoch_cfg;
            // TX01 identifies the fixed, documented electrical test waveform.
            config_locked <= tx_enable_cfg ? 32'h54583031 : config_id_cfg;
            configuration_error <= (test_enable_cfg && !raw_mode_cfg) ||
                                   (tx_enable_cfg && (!raw_mode_cfg || test_enable_cfg));
        end
    end
    assign tx_enable_locked = mode_locked && tx_locked && !configuration_error;
    assign frontend_enable = mode_locked && !configuration_error &&
                             (!tx_locked || (tx_init_done && !tx_fault));
    assign adc_test_request = mode_locked ? test_locked : test_enable_cfg;
    // Routing remains stable for the whole run, including while a final DDR
    // frame is stalled. TX status gates starting the frontend, not AXI VALID.
    wire raw_selected = mode_locked && !configuration_error && raw_mode_active;
    wire das_selected = mode_locked && !configuration_error && !raw_mode_active;
    wire raw_ready, raw_valid, raw_last;
    wire [31:0] raw_data;
    assign adc_ready = raw_selected ? raw_ready : das_selected ? das_adc_ready : reset_n;
    assign das_adc_data = adc_data;
    assign das_adc_user = adc_user;
    assign das_adc_valid = adc_valid && das_selected;
    assign das_frame_ready = frame_ready && das_selected;
    assign frame_data = raw_mode_active ? raw_data : das_frame_data;
    assign frame_valid = raw_selected ? raw_valid : das_selected ? das_frame_valid : 1'b0;
    assign frame_last = raw_mode_active ? raw_last : das_frame_last;
    raw_trace_capture #(.TRACE_POINTS(TRACE_POINTS), .FRAME_WORDS(FRAME_WORDS),
                        .SAMPLE_RATE(SAMPLE_RATE), .TRACE_PERIOD(TRACE_PERIOD)) raw_capture_inst (
        .clk(clk), .reset_n(reset_n), .arm(raw_selected), .input_fault(input_fault || (tx_locked && tx_fault)),
        .epoch_cfg(epoch_locked), .config_id_cfg(config_locked), .test_active(adc_test_active),
        .adc_data(adc_data), .adc_user(adc_user), .adc_valid(adc_valid && raw_selected), .adc_ready(raw_ready),
        .frame_data(raw_data), .frame_valid(raw_valid), .frame_last(raw_last), .frame_ready(frame_ready && raw_selected),
        .capture_complete(raw_capture_complete), .capture_error(raw_capture_error), .frame_sent(raw_frame_sent)
    );
endmodule
`default_nettype wire
