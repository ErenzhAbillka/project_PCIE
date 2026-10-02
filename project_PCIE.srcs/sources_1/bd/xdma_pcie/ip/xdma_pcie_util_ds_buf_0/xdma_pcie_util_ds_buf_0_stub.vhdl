-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Oct  1 15:47:01 2026
-- Host        : WIN-76HS90OBB7Q running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               E:/FPGA_Doc/project_PCIE/project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_util_ds_buf_0/xdma_pcie_util_ds_buf_0_stub.vhdl
-- Design      : xdma_pcie_util_ds_buf_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku060-ffva1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xdma_pcie_util_ds_buf_0 is
  Port ( 
    IBUF_DS_P : in STD_LOGIC_VECTOR ( 0 to 0 );
    IBUF_DS_N : in STD_LOGIC_VECTOR ( 0 to 0 );
    IBUF_OUT : out STD_LOGIC_VECTOR ( 0 to 0 );
    IBUF_DS_ODIV2 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end xdma_pcie_util_ds_buf_0;

architecture stub of xdma_pcie_util_ds_buf_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "IBUF_DS_P[0:0],IBUF_DS_N[0:0],IBUF_OUT[0:0],IBUF_DS_ODIV2[0:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "util_ds_buf,Vivado 2018.3";
begin
end;
