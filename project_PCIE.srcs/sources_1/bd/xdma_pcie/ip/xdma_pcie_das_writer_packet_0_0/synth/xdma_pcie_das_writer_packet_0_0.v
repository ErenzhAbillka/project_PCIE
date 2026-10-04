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


// IP VLNV: xilinx.com:module_ref:das_writer_packet:1.0
// IP Revision: 1

(* X_CORE_INFO = "das_writer_packet,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "xdma_pcie_das_writer_packet_0_0,das_writer_packet,{}" *)
(* CORE_GENERATION_INFO = "xdma_pcie_das_writer_packet_0_0,das_writer_packet,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=das_writer_packet,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module xdma_pcie_das_writer_packet_0_0 (
  clk,
  reset_n,
  frame_data,
  frame_valid,
  frame_last,
  frame_ready,
  writer_data,
  writer_valid,
  writer_last,
  writer_ready,
  burst_done,
  ddr_frames_done,
  framing_error
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 200000000, ASSOCIATED_RESET reset_n, PHASE 0.00, CLK_DOMAIN xdma_pcie_ddr4_0_2_c0_ddr4_ui_clk, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_n, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_n RST" *)
input wire reset_n;
input wire [31 : 0] frame_data;
input wire frame_valid;
input wire frame_last;
output wire frame_ready;
output wire [31 : 0] writer_data;
output wire writer_valid;
output wire writer_last;
input wire writer_ready;
input wire burst_done;
output wire [31 : 0] ddr_frames_done;
output wire framing_error;

  das_writer_packet inst (
    .clk(clk),
    .reset_n(reset_n),
    .frame_data(frame_data),
    .frame_valid(frame_valid),
    .frame_last(frame_last),
    .frame_ready(frame_ready),
    .writer_data(writer_data),
    .writer_valid(writer_valid),
    .writer_last(writer_last),
    .writer_ready(writer_ready),
    .burst_done(burst_done),
    .ddr_frames_done(ddr_frames_done),
    .framing_error(framing_error)
  );
endmodule
