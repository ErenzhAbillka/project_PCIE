// (c) Copyright 1995-2026 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:top_layer:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module xdma_pcie_top_layer_0_0 (
  ctrl_clk,
  rst_n,
  acquisition_enable,
  stream_ready,
  stream_data,
  stream_valid,
  stream_user,
  aom_pulse,
  adc_fifo_aresetn,
  adc_overflow,
  acquisition_active,
  adc_data_clk_p,
  adc_data_clk_n,
  data_pin_p,
  data_pin_n,
  adc_data_ch1,
  adc_data_ch2,
  sys_clk,
  adc_data_valid,
  init_done,
  device_spi_sclk,
  device_spi_sda,
  adk_spi_csb,
  adc_spi_csb,
  dac_spi_csb,
  adc_sync
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ctrl_clk, ASSOCIATED_RESET rst_n, FREQ_HZ 200000000, PHASE 0.00, CLK_DOMAIN xdma_pcie_ddr4_0_2_c0_ddr4_ui_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ctrl_clk CLK" *)
input wire ctrl_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *)
input wire rst_n;
input wire acquisition_enable;
input wire stream_ready;
output wire [31 : 0] stream_data;
output wire stream_valid;
output wire [1 : 0] stream_user;
output wire aom_pulse;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_fifo_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 adc_fifo_aresetn RST" *)
output wire adc_fifo_aresetn;
output wire adc_overflow;
output wire acquisition_active;
(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 adc_dco CLK_P" *)
input wire adc_data_clk_p;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME adc_dco, FREQ_HZ 125000000, CAN_DEBUG false" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 adc_dco CLK_N" *)
input wire adc_data_clk_n;
input wire [13 : 0] data_pin_p;
input wire [13 : 0] data_pin_n;
output wire [13 : 0] adc_data_ch1;
output wire [13 : 0] adc_data_ch2;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sys_clk, FREQ_HZ 125000000, ASSOCIATED_RESET adc_fifo_aresetn, PHASE 0.000, CLK_DOMAIN xdma_pcie_top_layer_0_0_sys_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 sys_clk CLK" *)
output wire sys_clk;
output wire adc_data_valid;
output wire init_done;
output wire device_spi_sclk;
inout wire device_spi_sda;
output wire adk_spi_csb;
output wire adc_spi_csb;
output wire dac_spi_csb;
output wire adc_sync;

  top_layer #(
    .CTRL_CLK_HZ(200000000),
    .SPI_CLK_HZ(1000000),
    .POWERUP_DELAY_CYCLES(2000000),
    .CLOCK_SETTLE_CYCLES(200000000),
    .ADC_TEST_CYCLES(600000000),
    .ADC_SETTLE_CYCLES(200000),
    .INPUT_DELAY_TAPS(10),
    .TRACE_PERIOD(31250),
    .TRACE_POINTS(16320),
    .AOM_WIDTH(12)
  ) inst (
    .ctrl_clk(ctrl_clk),
    .rst_n(rst_n),
    .acquisition_enable(acquisition_enable),
    .stream_ready(stream_ready),
    .stream_data(stream_data),
    .stream_valid(stream_valid),
    .stream_user(stream_user),
    .aom_pulse(aom_pulse),
    .adc_fifo_aresetn(adc_fifo_aresetn),
    .adc_overflow(adc_overflow),
    .acquisition_active(acquisition_active),
    .adc_data_clk_p(adc_data_clk_p),
    .adc_data_clk_n(adc_data_clk_n),
    .data_pin_p(data_pin_p),
    .data_pin_n(data_pin_n),
    .adc_data_ch1(adc_data_ch1),
    .adc_data_ch2(adc_data_ch2),
    .sys_clk(sys_clk),
    .adc_data_valid(adc_data_valid),
    .init_done(init_done),
    .device_spi_sclk(device_spi_sclk),
    .device_spi_sda(device_spi_sda),
    .adk_spi_csb(adk_spi_csb),
    .adc_spi_csb(adc_spi_csb),
    .dac_spi_csb(dac_spi_csb),
    .adc_sync(adc_sync)
  );
endmodule
