// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Oct  1 15:48:25 2026
// Host        : WIN-76HS90OBB7Q running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/FPGA_Doc/project_PCIE/project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ila_readback_0/xdma_pcie_ila_readback_0_stub.v
// Design      : xdma_pcie_ila_readback_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku060-ffva1156-2-i
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module xdma_pcie_ila_readback_0(clk, probe0, probe1, probe2, probe3, probe4)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[31:0],probe1[0:0],probe2[0:0],probe3[0:0],probe4[0:0]" */;
  input clk;
  input [31:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
endmodule
