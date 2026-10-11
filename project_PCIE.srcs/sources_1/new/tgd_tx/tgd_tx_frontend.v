`timescale 1ns/1ps
`default_nettype none
// DAC-only front end. Caller grants the shared SPI bus before pulsing request
// and retains grant while spi_ownership=1. Existing ADC/clock configuration
// must already be complete; its SCLK and SDIO driver must be inactive here.
// No FPGA package pins or shared top-level IOBUF are instantiated here.
module tgd_tx_frontend #(
    parameter integer CTRL_CLK_HZ=200000000,
    parameter integer SPI_CLK_HZ=1000000,
    parameter integer RESET_HOLD_CYCLES=CTRL_CLK_HZ/1000,
    parameter integer COMMAND_TIMEOUT_CYCLES=CTRL_CLK_HZ/100,
    parameter integer MAX_POLLS=64
)(
    input wire ctrl_clk, input wire ctrl_reset_n,
    input wire request, input wire bus_grant, input wire clocks_ready,
    output wire busy, output wire done, output wire init_ready,
    output wire init_fault, output wire [3:0] error_code,
    output wire [7:0] revision_id, output wire [7:0] fifo_level,
    output wire spi_ownership,
    output wire spi_sclk, output wire spi_sdo, output wire spi_oe,
    output wire spi_cs_n, input wire spi_sdi,
    input wire sample_clk, input wire forward_clk, input wire sample_reset,
    // These three control inputs must already be in sample_clk domain.
    input wire hardware_arm, input wire waveform_approved, input wire tx_kill,
    input wire sample_valid,
    input wire signed [15:0] i_sample, input wire signed [15:0] q_sample,
    output wire sample_ready, output wire tx_data_enabled,
    output wire [15:0] dac_data_p, output wire [15:0] dac_data_n,
    output wire dac_dci_p, output wire dac_dci_n,
    output wire dac_frame_p, output wire dac_frame_n
);
    wire cmd_valid, cmd_ready, cmd_read, rsp_valid, rsp_error, configured;
    wire [3:0] config_error;
    // A lost DAC/DCI clock invalidates FIFO alignment. No automatic resume.
    // clocks_ready must be synchronized to ctrl_clk at the caller.
    reg clock_fault=0;
    always @(posedge ctrl_clk) begin
        if (!ctrl_reset_n) clock_fault<=0;
        else if ((busy || configured) && !clocks_ready) clock_fault<=1;
    end
    assign error_code=clock_fault ? 4'h9 : config_error;
    wire [6:0] cmd_address; wire [7:0] cmd_data, rsp_data;
    assign init_ready=configured && clocks_ready && !init_fault;
    assign init_fault=(error_code!=0);
    assign spi_ownership=busy || request || !cmd_ready;
    ad9122_config #(.RESET_HOLD_CYCLES(RESET_HOLD_CYCLES),
        .COMMAND_TIMEOUT_CYCLES(COMMAND_TIMEOUT_CYCLES),.MAX_POLLS(MAX_POLLS)) cfg(
        .clk(ctrl_clk),.reset_n(ctrl_reset_n),.request(request),
        .clocks_ready(clocks_ready && bus_grant),.busy(busy),.done(done),
        .configured(configured),.error_code(config_error),
        .revision_id(revision_id),.fifo_level(fifo_level),
        .cmd_valid(cmd_valid),.cmd_ready(cmd_ready),.cmd_read(cmd_read),
        .cmd_address(cmd_address),.cmd_data(cmd_data),
        .rsp_valid(rsp_valid),.rsp_data(rsp_data),.rsp_error(rsp_error));
    ad9122_spi_master #(.HALF_CYCLES((CTRL_CLK_HZ+2*SPI_CLK_HZ-1)/(2*SPI_CLK_HZ))) spi(
        .clk(ctrl_clk),.reset_n(ctrl_reset_n),.cmd_valid(cmd_valid),.cmd_ready(cmd_ready),
        .cmd_read(cmd_read),.cmd_address(cmd_address),.cmd_data(cmd_data),
        .rsp_valid(rsp_valid),.rsp_data(rsp_data),.rsp_error(rsp_error),
        .sclk(spi_sclk),.cs_n(spi_cs_n),.sdio_out(spi_sdo),
        .sdio_oe(spi_oe),.sdio_in(spi_sdi));
    (* ASYNC_REG="TRUE" *) reg [1:0] ready_sync=0;
    wire ready_reset=sample_reset || !init_ready;
    always @(posedge sample_clk or posedge ready_reset) begin
        if (ready_reset) ready_sync<=0;
        else ready_sync<={ready_sync[0],1'b1};
    end
    assign sample_ready=ready_sync[1];
    assign tx_data_enabled=sample_ready && hardware_arm && waveform_approved && !tx_kill;
    ad9122_lvds_tx phy(.sample_clk(sample_clk),.forward_clk(forward_clk),
        .reset(sample_reset),.data_enable(tx_data_enabled),.sample_valid(sample_valid),
        .i_sample(i_sample),.q_sample(q_sample),.dac_data_p(dac_data_p),
        .dac_data_n(dac_data_n),.dac_dci_p(dac_dci_p),.dac_dci_n(dac_dci_n),
        .dac_frame_p(dac_frame_p),.dac_frame_n(dac_frame_n));
endmodule
`default_nettype wire
