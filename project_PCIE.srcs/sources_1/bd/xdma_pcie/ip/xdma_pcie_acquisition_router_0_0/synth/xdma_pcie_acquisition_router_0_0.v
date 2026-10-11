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


// IP VLNV: xilinx.com:module_ref:acquisition_router:1.0
// IP Revision: 1

(* X_CORE_INFO = "acquisition_router,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "xdma_pcie_acquisition_router_0_0,acquisition_router,{}" *)
(* CORE_GENERATION_INFO = "xdma_pcie_acquisition_router_0_0,acquisition_router,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=acquisition_router,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,TRACE_POINTS=16320,FRAME_WORDS=16384,SAMPLE_RATE=125000000,TRACE_PERIOD=31250}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module xdma_pcie_acquisition_router_0_0 (
  clk,
  reset_n,
  start,
  raw_mode_cfg,
  test_enable_cfg,
  tx_enable_cfg,
  epoch_cfg,
  config_id_cfg,
  adc_test_active,
  input_fault,
  tx_init_done,
  tx_fault,
  frontend_enable,
  adc_test_request,
  tx_enable_locked,
  mode_locked,
  raw_mode_active,
  configuration_error,
  adc_data,
  adc_user,
  adc_valid,
  adc_ready,
  das_adc_data,
  das_adc_user,
  das_adc_valid,
  das_adc_ready,
  das_frame_data,
  das_frame_valid,
  das_frame_last,
  das_frame_ready,
  frame_data,
  frame_valid,
  frame_last,
  frame_ready,
  raw_capture_complete,
  raw_capture_error,
  raw_frame_sent
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 200000000, ASSOCIATED_RESET reset_n, PHASE 0.00, CLK_DOMAIN xdma_pcie_ddr4_0_2_c0_ddr4_ui_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_n RST" *)
input wire reset_n;
input wire start;
input wire raw_mode_cfg;
input wire test_enable_cfg;
input wire tx_enable_cfg;
input wire [31 : 0] epoch_cfg;
input wire [31 : 0] config_id_cfg;
input wire adc_test_active;
input wire input_fault;
input wire tx_init_done;
input wire tx_fault;
output wire frontend_enable;
output wire adc_test_request;
output wire tx_enable_locked;
output wire mode_locked;
output wire raw_mode_active;
output wire configuration_error;
input wire [31 : 0] adc_data;
input wire [1 : 0] adc_user;
input wire adc_valid;
output wire adc_ready;
output wire [31 : 0] das_adc_data;
output wire [1 : 0] das_adc_user;
output wire das_adc_valid;
input wire das_adc_ready;
input wire [31 : 0] das_frame_data;
input wire das_frame_valid;
input wire das_frame_last;
output wire das_frame_ready;
output wire [31 : 0] frame_data;
output wire frame_valid;
output wire frame_last;
input wire frame_ready;
output wire raw_capture_complete;
output wire raw_capture_error;
output wire raw_frame_sent;

  acquisition_router #(
    .TRACE_POINTS(16320),
    .FRAME_WORDS(16384),
    .SAMPLE_RATE(125000000),
    .TRACE_PERIOD(31250)
  ) inst (
    .clk(clk),
    .reset_n(reset_n),
    .start(start),
    .raw_mode_cfg(raw_mode_cfg),
    .test_enable_cfg(test_enable_cfg),
    .tx_enable_cfg(tx_enable_cfg),
    .epoch_cfg(epoch_cfg),
    .config_id_cfg(config_id_cfg),
    .adc_test_active(adc_test_active),
    .input_fault(input_fault),
    .tx_init_done(tx_init_done),
    .tx_fault(tx_fault),
    .frontend_enable(frontend_enable),
    .adc_test_request(adc_test_request),
    .tx_enable_locked(tx_enable_locked),
    .mode_locked(mode_locked),
    .raw_mode_active(raw_mode_active),
    .configuration_error(configuration_error),
    .adc_data(adc_data),
    .adc_user(adc_user),
    .adc_valid(adc_valid),
    .adc_ready(adc_ready),
    .das_adc_data(das_adc_data),
    .das_adc_user(das_adc_user),
    .das_adc_valid(das_adc_valid),
    .das_adc_ready(das_adc_ready),
    .das_frame_data(das_frame_data),
    .das_frame_valid(das_frame_valid),
    .das_frame_last(das_frame_last),
    .das_frame_ready(das_frame_ready),
    .frame_data(frame_data),
    .frame_valid(frame_valid),
    .frame_last(frame_last),
    .frame_ready(frame_ready),
    .raw_capture_complete(raw_capture_complete),
    .raw_capture_error(raw_capture_error),
    .raw_frame_sent(raw_frame_sent)
  );
endmodule
