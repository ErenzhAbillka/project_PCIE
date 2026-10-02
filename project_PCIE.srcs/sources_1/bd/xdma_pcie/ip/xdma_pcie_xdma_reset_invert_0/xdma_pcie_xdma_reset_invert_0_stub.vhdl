-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Oct  1 15:46:34 2026
-- Host        : WIN-76HS90OBB7Q running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top xdma_pcie_xdma_reset_invert_0 -prefix
--               xdma_pcie_xdma_reset_invert_0_ xdma_pcie_perst_invert_0_stub.vhdl
-- Design      : xdma_pcie_perst_invert_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku060-ffva1156-2-i
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xdma_pcie_xdma_reset_invert_0 is
  Port ( 
    Op1 : in STD_LOGIC_VECTOR ( 0 to 0 );
    Res : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end xdma_pcie_xdma_reset_invert_0;

architecture stub of xdma_pcie_xdma_reset_invert_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "Op1[0:0],Res[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "util_vector_logic_v2_0_1_util_vector_logic,Vivado 2018.3";
begin
end;
