`timescale 1ns/1ps
`default_nettype none

// 100 traces -> sum(abs(X[n]-X[n-1])) and 100 phase-ROI rows.
// TUSER[0]: sample is inside the trace window; TUSER[1]: final window sample.
// Separate synchronous RAMs preserve point identity through the R/M/W pipeline.
// Two result banks let the next group run while the previous group reaches DDR.
module das_trace_process #(
    parameter integer TRACE_POINTS = 16320,
    parameter integer GROUP_TRACES = 100,
    parameter integer PHASE_POINTS = 100,
    parameter integer FRAME_WORDS = 16384,
    parameter integer ACC_SHIFT = 7,
    parameter integer SAMPLE_RATE = 125000000,
    parameter integer TRACE_PERIOD = 31250,
    parameter integer IF_HZ = 50000000
)(
    (* X_INTERFACE_PARAMETER = "FREQ_HZ 200000000, ASSOCIATED_RESET reset_n" *)
    input wire clk, input wire reset_n,
    input wire [31:0] amp_phase_data, input wire [1:0] sample_user,
    input wire sample_valid, output wire sample_ready,
    input wire [15:0] phase_start_cfg, input wire input_fault,
    output reg [31:0] frame_data, output wire frame_valid,
    output wire frame_last, input wire frame_ready,
    output reg format_error, output reg [31:0] groups_completed,
    output wire [1:0] banks_full, output reg accumulator_clipped
);
    localparam integer INDEX_W = $clog2(TRACE_POINTS);
    localparam integer FRAME_W = $clog2(FRAME_WORDS);
    localparam integer PHASE_TOTAL = GROUP_TRACES * PHASE_POINTS;
    localparam integer PAYLOAD_WORDS = (TRACE_POINTS > PHASE_TOTAL) ? TRACE_POINTS : PHASE_TOTAL;
    localparam integer ACC_W = 16 + $clog2(GROUP_TRACES);
    (* ram_style = "block" *) reg [15:0] previous_amp [0:TRACE_POINTS-1];
    (* ram_style = "block" *) reg [ACC_W-1:0] accumulation [0:TRACE_POINTS-1];
    (* ram_style = "block" *) reg [15:0] result_diff [0:2*FRAME_WORDS-1];
    (* ram_style = "block" *) reg [15:0] result_phase [0:2*FRAME_WORDS-1];

    reg [INDEX_W-1:0] point;
    reg [15:0] trace;
    reg write_bank, read_bank;
    reg [1:0] ready_bank;
    reg [15:0] roi_start;
    reg [FRAME_W-1:0] phase_index;
    reg [31:0] bank_sequence [0:1];
    reg [15:0] bank_roi [0:1];
    reg [1:0] bank_clipped;
    wire group_start = (point == 0 && trace == 0);
    wire [15:0] effective_roi = group_start ? phase_start_cfg : roi_start;
    assign banks_full = ready_bank;
    assign sample_ready = reset_n && !format_error && !input_fault &&
                          (!group_start || !ready_bank[write_bank]);
    wire take = sample_valid && sample_ready;
    wire window_take = take && sample_user[0];
    wire last_group_sample = trace == GROUP_TRACES-1 && sample_user[1];

    reg p0_valid, p0_first, p0_last_trace, p0_last_point, p0_bank;
    reg [INDEX_W-1:0] p0_point;
    reg [15:0] p0_amp, old_amp;
    reg [ACC_W-1:0] old_sum;
    reg p1_valid, p1_first, p1_last_trace, p1_last_point, p1_bank;
    reg [INDEX_W-1:0] p1_point;
    reg [15:0] difference;
    reg [ACC_W-1:0] p1_sum;
    wire [ACC_W:0] next_sum = p1_first ? 0 : {1'b0,p1_sum} + difference;
    wire [ACC_W:0] scaled_sum = next_sum >> ACC_SHIFT;
    wire clipped = scaled_sum > 65535;
    wire group_done = p1_valid && p1_last_trace && p1_last_point;

    // Synchronous read-before-write amplitude RAM; no reset loop destroys BRAM inference.
    always @(posedge clk) begin
        if (window_take) begin
            old_amp <= previous_amp[point];
            old_sum <= accumulation[point];
            previous_amp[point] <= amp_phase_data[15:0];
            if (point >= effective_roi && point < effective_roi + PHASE_POINTS)
                result_phase[{write_bank,phase_index}] <= amp_phase_data[31:16];
        end
        if (p1_valid) begin
            accumulation[p1_point] <= next_sum[ACC_W-1:0];
            if (p1_last_trace)
                result_diff[p1_bank*FRAME_WORDS+p1_point] <= clipped ? 16'hffff : scaled_sum[15:0];
        end
    end

    localparam [1:0] OUT_IDLE=0, OUT_READ=1, OUT_LOAD=2, OUT_HOLD=3;
    reg [1:0] out_state;
    reg [FRAME_W-1:0] out_index;
    reg [15:0] diff_read, phase_read;
    wire [FRAME_W-1:0] payload_index = out_index - 16;
    assign frame_valid = reset_n && out_state == OUT_HOLD;
    assign frame_last = out_index == FRAME_WORDS-1;
    wire frame_sent = frame_valid && frame_ready && frame_last;

    always @(posedge clk) begin
        if (!reset_n) begin
            point <= 0; trace <= 0; write_bank <= 0; phase_index <= 0;
            roi_start <= 0; ready_bank <= 0; groups_completed <= 0;
            format_error <= 0; accumulator_clipped <= 0; bank_clipped <= 0;
            bank_roi[0] <= 0; bank_roi[1] <= 0;
            bank_sequence[0] <= 0; bank_sequence[1] <= 0;
            p0_valid <= 0; p1_valid <= 0;
            p0_first <= 0; p0_last_trace <= 0; p0_last_point <= 0; p0_bank <= 0;
            p0_point <= 0; p0_amp <= 0;
            p1_first <= 0; p1_last_trace <= 0; p1_last_point <= 0; p1_bank <= 0;
            p1_point <= 0; difference <= 0; p1_sum <= 0;
        end else begin
            p0_valid <= window_take;
            p1_valid <= p0_valid;
            if (take && sample_user[1] && !sample_user[0]) format_error <= 1;
            if (window_take) begin
                if (sample_user[1] != (point == TRACE_POINTS-1)) format_error <= 1;
                if (group_start) begin
                    if (phase_start_cfg + PHASE_POINTS > TRACE_POINTS) format_error <= 1;
                    roi_start <= phase_start_cfg; bank_roi[write_bank] <= phase_start_cfg;
                    bank_clipped[write_bank] <= 0;
                end
                if (point >= effective_roi && point < effective_roi + PHASE_POINTS)
                    phase_index <= phase_index + 1'b1;
                if (sample_user[1]) begin
                    point <= 0;
                    if (last_group_sample) begin
                        trace <= 0; phase_index <= 0; write_bank <= ~write_bank;
                    end else trace <= trace + 1'b1;
                end else point <= point + 1'b1;
                p0_first <= trace == 0;
                p0_last_trace <= trace == GROUP_TRACES-1;
                p0_last_point <= sample_user[1];
                p0_bank <= write_bank; p0_point <= point; p0_amp <= amp_phase_data[15:0];
            end
            if (p0_valid) begin
                difference <= p0_amp >= old_amp ? p0_amp-old_amp : old_amp-p0_amp;
                p1_sum <= old_sum; p1_first <= p0_first;
                p1_last_trace <= p0_last_trace; p1_last_point <= p0_last_point;
                p1_bank <= p0_bank; p1_point <= p0_point;
            end
            if (frame_sent) ready_bank[read_bank] <= 0;
            if (p1_valid && p1_last_trace && clipped) begin
                bank_clipped[p1_bank] <= 1; accumulator_clipped <= 1;
            end
            if (group_done && !format_error && !input_fault) begin
                ready_bank[p1_bank] <= 1;
                bank_sequence[p1_bank] <= groups_completed;
                groups_completed <= groups_completed + 1'b1;
            end
        end
    end

    // A complete group is published only after the final accumulation write.
    // Header and trailer identify the frame so the host can reject a torn ring read.
    function [31:0] header_word;
        input [FRAME_W-1:0] index;
        input bank;
        begin
            case (index)
                0: header_word=32'h44415331;
                1: header_word=bank_sequence[bank];
                2: header_word=FRAME_WORDS;
                3: header_word=TRACE_POINTS;
                4: header_word=GROUP_TRACES;
                5: header_word={16'b0,bank_roi[bank]};
                6: header_word=PHASE_POINTS;
                7: header_word=PHASE_TOTAL;
                8: header_word=SAMPLE_RATE;
                9: header_word=IF_HZ;
               10: header_word=ACC_SHIFT;
               11: header_word=13; // phase radians = signed16 / 8192
               12: header_word={31'b0,bank_clipped[bank]};
               13: header_word=TRACE_PERIOD;
               14: header_word=1; // format version
               15: header_word=~bank_sequence[bank];
               default: header_word=0;
            endcase
        end
    endfunction
    always @(posedge clk) begin
        if (out_state == OUT_READ) begin
            diff_read <= result_diff[{read_bank,payload_index}];
            phase_read <= result_phase[{read_bank,payload_index}];
        end
        if (!reset_n) begin
            out_state <= OUT_IDLE; out_index <= 0; read_bank <= 0; frame_data <= 0;
        end else case (out_state)
            OUT_IDLE: if (ready_bank[read_bank]) begin out_index <= 0; out_state <= OUT_READ; end
            OUT_READ: out_state <= OUT_LOAD;
            OUT_LOAD: begin
                if (out_index < 16) frame_data <= header_word(out_index,read_bank);
                else if (out_index < 16+PAYLOAD_WORDS)
                    frame_data <= {payload_index < PHASE_TOTAL ? phase_read : 16'b0,
                                   payload_index < TRACE_POINTS ? diff_read : 16'b0};
                else if (out_index == FRAME_WORDS-4) frame_data <= 32'h434f4d54;
                else if (out_index == FRAME_WORDS-3) frame_data <= bank_sequence[read_bank];
                else if (out_index == FRAME_WORDS-2) frame_data <= ~bank_sequence[read_bank];
                else if (out_index == FRAME_WORDS-1) frame_data <= 32'h454e4421;
                else frame_data <= 0;
                out_state <= OUT_HOLD;
            end
            OUT_HOLD: if (frame_ready) begin
                if (frame_last) begin out_state <= OUT_IDLE; read_bank <= ~read_bank; end
                else begin out_index <= out_index + 1'b1; out_state <= OUT_READ; end
            end
        endcase
    end
`ifndef SYNTHESIS
    initial begin
        if (TRACE_POINTS < 8 || GROUP_TRACES < 2 || GROUP_TRACES > 256 ||
            PHASE_POINTS < 1 || PHASE_POINTS > TRACE_POINTS ||
            FRAME_WORDS < PAYLOAD_WORDS+20 || (FRAME_WORDS & (FRAME_WORDS-1)) != 0)
            $fatal(1,"Invalid DAS frame/trace parameters");
    end
`endif
endmodule
`default_nettype wire
