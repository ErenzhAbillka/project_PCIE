`timescale 1ns/1ps
`default_nettype none
// AD9122 three-wire SPI transport, mode 0, MSB first, 16 total clock edges.
// A system arbiter MUST grant this engine exclusive SCLK/SDIO/DAC_CSB control
// for the entire configuration sequence. These are logical signals; a shared
// top-level IOBUF drives sdio_out when sdio_oe=1 and otherwise reads sdio_in.
module ad9122_spi_master #(
    parameter integer HALF_CYCLES=100
)(
    input wire clk, input wire reset_n,
    input wire cmd_valid, output wire cmd_ready,
    input wire cmd_read, input wire [6:0] cmd_address,
    input wire [7:0] cmd_data,
    output reg rsp_valid, output reg [7:0] rsp_data,
    output wire rsp_error,
    output reg sclk, output reg cs_n,
    output wire sdio_out, output reg sdio_oe, input wire sdio_in
);
    localparam [1:0] IDLE=0, RISE=1, FALL=2, HOLD_CS=3;
    reg [1:0] state;
    reg [15:0] shift;
    reg [3:0] bit_index;
    reg [31:0] count;
    reg read_operation;
    assign cmd_ready=(state==IDLE);
    assign rsp_error=1'b0;
    assign sdio_out=shift[15];
    always @(posedge clk) begin
        if (!reset_n) begin
            state<=IDLE; shift<=0; bit_index<=0; count<=0;
            read_operation<=0; rsp_valid<=0; rsp_data<=0;
            sclk<=0; cs_n<=1; sdio_oe<=0;
        end else begin
            rsp_valid<=0;
            case(state)
                IDLE: if (cmd_valid) begin
                    shift<={cmd_read,cmd_address,cmd_data};
                    bit_index<=15; count<=0; read_operation<=cmd_read;
                    rsp_data<=0; sclk<=0; cs_n<=0; sdio_oe<=1; state<=RISE;
                end
                RISE: if (count==HALF_CYCLES-1) begin
                    count<=0; sclk<=1;
                    if (read_operation && bit_index<8)
                        rsp_data<={rsp_data[6:0],sdio_in};
                    state<=FALL;
                end else count<=count+1'b1;
                FALL: if (count==HALF_CYCLES-1) begin
                    count<=0; sclk<=0;
                    if (bit_index==0) state<=HOLD_CS;
                    else begin
                        bit_index<=bit_index-1'b1; shift<={shift[14:0],1'b0};
                        if (read_operation && bit_index==8) sdio_oe<=0;
                        state<=RISE;
                    end
                end else count<=count+1'b1;
                HOLD_CS: if (count==HALF_CYCLES-1) begin
                    count<=0; cs_n<=1; sdio_oe<=0;
                    rsp_valid<=1; state<=IDLE;
                end else count<=count+1'b1;
            endcase
        end
    end
`ifndef SYNTHESIS
    initial if (HALF_CYCLES<1) $fatal(1,"SPI divider must be positive");
`endif
endmodule
`default_nettype wire
