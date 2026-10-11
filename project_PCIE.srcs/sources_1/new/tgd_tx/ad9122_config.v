`timescale 1ns/1ps
`default_nettype none
// Request/response sequencer for an EXCLUSIVE, arbitrated AD9122 SPI master.
// cmd_valid/ready transfers one command. Every command MUST return rsp_valid,
// including writes. cmd_read uses the AD9122 8-bit instruction + 8-bit payload;
// do not send the existing ADC/AD9516 24-bit transaction to this device.
// request is accepted only on a rising edge while !busy; busy requests drop.
// done pulses on success OR failure. configured means register readback and
// FIFO alignment passed; it is NOT optical/RF/DAC output verification.
module ad9122_config #(
    parameter integer RESET_HOLD_CYCLES = 200000,
    parameter integer COMMAND_TIMEOUT_CYCLES = 2000000,
    parameter integer MAX_POLLS = 64,
    parameter [1:0] R2_DCI_DELAY = 2'b10
)(
    input wire clk, input wire reset_n, input wire request,
    input wire clocks_ready,
    output reg busy, output reg done, output reg configured,
    output reg [3:0] error_code,
    output reg [7:0] revision_id, output reg [7:0] fifo_level,
    output reg cmd_valid, input wire cmd_ready,
    output reg cmd_read, output reg [6:0] cmd_address,
    output reg [7:0] cmd_data,
    input wire rsp_valid, input wire [7:0] rsp_data, input wire rsp_error
);
    localparam [4:0] IDLE=0, ROM_SEND=1, ACCEPT=2, RESPONSE=3,
        ROM_END=4, RESET_WAIT=5, REV_SEND=6, REV_CHECK=7,
        DELAY_WRITE=8, VERIFY_SEND=9, VERIFY_CHECK=10,
        OFFSET_WRITE=11, ALIGN_REQUEST=12, ACK_SEND=13, ACK_CHECK=14,
        ALIGN_RELEASE=15, CLEAR_SEND=16, CLEAR_CHECK=17,
        LEVEL_SEND=18, LEVEL_CHECK=19, SUCCESS=20;
    reg [4:0] state, return_state;
    reg [4:0] rom_index;
    wire [6:0] rom_address; wire [7:0] rom_data; wire rom_last;
    ad9122_init_rom rom(.index(rom_index), .address(rom_address),
                         .data(rom_data), .last(rom_last));
    reg [2:0] verify_index, offset;
    reg [31:0] timeout_count, poll_count, reset_count;
    reg [7:0] response_data;
    reg request_previous, adjusted;
    function [6:0] verify_address;
        input [2:0] i;
        begin
            case(i)
                0: verify_address=7'h03; 1: verify_address=7'h0A;
                2: verify_address=7'h1B; 3: verify_address=7'h1C;
                4: verify_address=7'h1D; default: verify_address=7'h1E;
            endcase
        end
    endfunction
    function [7:0] verify_expected;
        input [2:0] i;
        begin
            case(i)
                2: verify_expected=8'hE4;
                5: verify_expected=8'h01;
                default: verify_expected=8'h00;
            endcase
        end
    endfunction
    task launch;
        input r; input [6:0] a; input [7:0] d; input [4:0] next_state;
        begin
            cmd_valid<=1; cmd_read<=r; cmd_address<=a; cmd_data<=d;
            return_state<=next_state; timeout_count<=0; state<=ACCEPT;
        end
    endtask
    task fail;
        input [3:0] code;
        begin
            cmd_valid<=0; busy<=0; done<=1; configured<=0;
            error_code<=code; state<=IDLE;
        end
    endtask
    always @(posedge clk) begin
        if (!reset_n) begin
            state<=IDLE; return_state<=IDLE; rom_index<=0; verify_index<=0;
            offset<=5; adjusted<=0; timeout_count<=0; poll_count<=0;
            reset_count<=0; response_data<=0; request_previous<=0;
            busy<=0; done<=0; configured<=0; error_code<=0;
            revision_id<=0; fifo_level<=0; cmd_valid<=0;
            cmd_read<=0; cmd_address<=0; cmd_data<=0;
        end else begin
            request_previous<=request;
            done<=0;
            case(state)
                IDLE: if (request && !request_previous) begin
                    configured<=0; error_code<=0; fifo_level<=0;
                    revision_id<=0; rom_index<=0; verify_index<=0;
                    offset<=5; adjusted<=0; poll_count<=0;
                    if (!clocks_ready) fail(4'h1);
                    else begin busy<=1; state<=ROM_SEND; end
                end
                ROM_SEND: launch(0, rom_address, rom_data, ROM_END);
                ACCEPT: begin
                    if (cmd_ready) begin
                        cmd_valid<=0; timeout_count<=0; state<=RESPONSE;
                    end else if (timeout_count == COMMAND_TIMEOUT_CYCLES-1)
                        fail(4'h2);
                    else timeout_count<=timeout_count+1'b1;
                end
                RESPONSE: begin
                    if (rsp_valid) begin
                        response_data<=rsp_data;
                        if (rsp_error) fail(4'h3);
                        else state<=return_state;
                    end else if (timeout_count == COMMAND_TIMEOUT_CYCLES-1)
                        fail(4'h2);
                    else timeout_count<=timeout_count+1'b1;
                end
                ROM_END: begin
                    if (rom_index==0) begin reset_count<=0; state<=RESET_WAIT; end
                    else if (rom_last) state<=REV_SEND;
                    else begin rom_index<=rom_index+1'b1; state<=ROM_SEND; end
                end
                RESET_WAIT: begin
                    if (reset_count==RESET_HOLD_CYCLES-1) begin
                        rom_index<=1; state<=ROM_SEND;
                    end else reset_count<=reset_count+1'b1;
                end
                REV_SEND: launch(1, 7'h7F, 0, REV_CHECK);
                REV_CHECK: begin
                    revision_id<=response_data;
                    // Rev. B p18: R1=04; R2=0C. Reject floating/unknown SDIO.
                    if (response_data==8'h04 || response_data==8'h0C)
                        state<=DELAY_WRITE;
                    else fail(4'h4);
                end
                DELAY_WRITE: launch(0, 7'h16,
                    revision_id==8'h0C ? {6'd0,R2_DCI_DELAY} : 8'd0, VERIFY_SEND);
                VERIFY_SEND: launch(1, verify_address(verify_index), 0, VERIFY_CHECK);
                VERIFY_CHECK: begin
                    if (response_data!=verify_expected(verify_index)) fail(4'h5);
                    else if (verify_index==5) state<=OFFSET_WRITE;
                    else begin verify_index<=verify_index+1'b1; state<=VERIFY_SEND; end
                end
                OFFSET_WRITE: launch(0, 7'h17, {5'd0,offset}, ALIGN_REQUEST);
                ALIGN_REQUEST: begin
                    poll_count<=0; launch(0,7'h18,8'h02,ACK_SEND);
                end
                ACK_SEND: launch(1,7'h18,0,ACK_CHECK);
                ACK_CHECK: begin
                    if (response_data[2]) state<=ALIGN_RELEASE;
                    else if (poll_count==MAX_POLLS-1) fail(4'h6);
                    else begin poll_count<=poll_count+1'b1; state<=ACK_SEND; end
                end
                ALIGN_RELEASE: begin
                    poll_count<=0; launch(0,7'h18,0,CLEAR_SEND);
                end
                CLEAR_SEND: launch(1,7'h18,0,CLEAR_CHECK);
                CLEAR_CHECK: begin
                    if (!response_data[2]) state<=LEVEL_SEND;
                    else if (poll_count==MAX_POLLS-1) fail(4'h7);
                    else begin poll_count<=poll_count+1'b1; state<=CLEAR_SEND; end
                end
                LEVEL_SEND: launch(1,7'h19,0,LEVEL_CHECK);
                LEVEL_CHECK: begin
                    fifo_level<=response_data;
                    if (response_data==8'h07 || response_data==8'h0F) state<=SUCCESS;
                    else if (!adjusted && response_data==8'h03) begin
                        adjusted<=1; offset<=6; state<=OFFSET_WRITE;
                    end else if (!adjusted && response_data==8'h1F) begin
                        adjusted<=1; offset<=4; state<=OFFSET_WRITE;
                    end else fail(4'h8);
                end
                SUCCESS: begin
                    busy<=0; done<=1; configured<=1; error_code<=0; state<=IDLE;
                end
                default: fail(4'hF);
            endcase
        end
    end
`ifndef SYNTHESIS
    initial begin
        if (RESET_HOLD_CYCLES<1 || COMMAND_TIMEOUT_CYCLES<2 || MAX_POLLS<1)
            $fatal(1,"Invalid AD9122 sequencer limits");
    end
`endif
endmodule
`default_nettype wire
