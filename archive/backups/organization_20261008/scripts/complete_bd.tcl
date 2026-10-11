# Run with xdma_pcie open. Applies to the original, incomplete BD once.
current_bd_design xdma_pcie
set_property -dict [list CONFIG.pcie_blk_locn {X0Y1} CONFIG.en_gt_selection {true} CONFIG.select_quad {GTH_Quad_227}] [get_bd_cells xdma_0]
set_property -dict [list CONFIG.axi_data_width {256_bit} CONFIG.axisten_freq {125}] [get_bd_cells xdma_0]
if {[llength [get_bd_cells -quiet axi_smc]]} {error "BD is already completed"}
delete_bd_objs [get_bd_intf_nets -of_objects [get_bd_intf_ports C0_DDR4_S_AXI_0]]
delete_bd_objs [get_bd_intf_ports C0_DDR4_S_AXI_0]
delete_bd_objs [get_bd_nets -of_objects [get_bd_ports sys_clk]]
delete_bd_objs [get_bd_ports sys_clk]

create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc
set_property -dict [list CONFIG.NUM_SI {2} CONFIG.NUM_MI {1} CONFIG.NUM_CLKS {2}] [get_bd_cells axi_smc]
connect_bd_intf_net [get_bd_intf_pins xdma_0/M_AXI] [get_bd_intf_pins axi_smc/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins wr_addr_0/m00_axi] [get_bd_intf_pins axi_smc/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 perst_invert
set_property -dict [list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}] [get_bd_cells perst_invert]
connect_bd_net [get_bd_ports reset_rtl_0] [get_bd_pins perst_invert/Op1]
connect_bd_net [get_bd_pins perst_invert/Res] [get_bd_pins ddr4_0/sys_rst]
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 xdma_reset_invert
set_property -dict [list CONFIG.C_OPERATION {not} CONFIG.C_SIZE {1}] [get_bd_cells xdma_reset_invert]
connect_bd_net [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins xdma_reset_invert/Op1]
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ddr
set_property -dict [list CONFIG.C_EXT_RESET_HIGH {1} CONFIG.C_AUX_RESET_HIGH {1}] [get_bd_cells rst_ddr]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins rst_ddr/ext_reset_in]
connect_bd_net [get_bd_pins xdma_reset_invert/Res] [get_bd_pins rst_ddr/aux_reset_in]
connect_bd_net [get_bd_pins ddr4_0/c0_init_calib_complete] [get_bd_pins rst_ddr/dcm_locked]

# The generator, FIFO, and both wr_addr clocks share the DDR user clock.
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_smc/aclk] [get_bd_pins rst_ddr/slowest_sync_clk] [get_bd_pins AXI_data_out_0_0/clk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins wr_addr_0/clk] [get_bd_pins wr_addr_0/m00_axi_aclk]
connect_bd_net [get_bd_pins xdma_0/axi_aclk] [get_bd_pins axi_smc/aclk1]
connect_bd_net [get_bd_pins rst_ddr/peripheral_aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins axi_smc/aresetn] [get_bd_pins AXI_data_out_0_0/rst_n] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins wr_addr_0/rst_n] [get_bd_pins wr_addr_0/m00_axi_aresetn]
connect_bd_net [get_bd_pins axis_data_fifo_0/m_axis_tdata] [get_bd_pins wr_addr_0/i_data]
connect_bd_net [get_bd_pins axis_data_fifo_0/m_axis_tvalid] [get_bd_pins wr_addr_0/i_valid]
connect_bd_net [get_bd_pins axis_data_fifo_0/m_axis_tlast] [get_bd_pins wr_addr_0/i_last]
connect_bd_net [get_bd_pins wr_addr_0/fifo_ready] [get_bd_pins axis_data_fifo_0/m_axis_tready]
set_property -dict [list CONFIG.HAS_TLAST {1} CONFIG.FIFO_MODE {2} CONFIG.FIFO_DEPTH {512}] [get_bd_cells axis_data_fifo_0]

# Tie off unused management/interrupt inputs explicitly, at their actual widths.
foreach width {1 4 19 32} {
 create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_$width
 set_property -dict [list CONFIG.CONST_WIDTH $width CONFIG.CONST_VAL {0}] [get_bd_cells zero_$width]
}
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 one
set_property CONFIG.CONST_VAL 1 [get_bd_cells one]
foreach pin {rst_ddr/mb_debug_sys_rst wr_addr_0/m00_axi_init_axi_txn xdma_0/usr_irq_req xdma_0/cfg_mgmt_read xdma_0/cfg_mgmt_write xdma_0/cfg_mgmt_type1_cfg_reg_access} {
 connect_bd_net [get_bd_pins zero_1/dout] [get_bd_pins $pin]
}
connect_bd_net [get_bd_pins zero_4/dout] [get_bd_pins xdma_0/cfg_mgmt_byte_enable]
connect_bd_net [get_bd_pins zero_19/dout] [get_bd_pins xdma_0/cfg_mgmt_addr]
connect_bd_net [get_bd_pins zero_32/dout] [get_bd_pins xdma_0/cfg_mgmt_write_data]
connect_bd_net [get_bd_pins one/dout] [get_bd_pins wr_addr_0/i_fifo_ready]

# VIO triggers the existing four-word read at 0xF000; ILA captures its response.
create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_readback
set_property -dict [list CONFIG.C_NUM_PROBE_IN {2} CONFIG.C_NUM_PROBE_OUT {1} CONFIG.C_PROBE_OUT0_INIT_VAL {0x0}] [get_bd_cells vio_readback]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins vio_readback/clk]
connect_bd_net [get_bd_pins vio_readback/probe_out0] [get_bd_pins wr_addr_0/xdma_valid]
connect_bd_net [get_bd_pins ddr4_0/c0_init_calib_complete] [get_bd_pins vio_readback/probe_in0]
connect_bd_net [get_bd_pins wr_addr_0/m00_axi_error] [get_bd_pins vio_readback/probe_in1]
create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_readback
set_property CONFIG.C_MONITOR_TYPE Native [get_bd_cells ila_readback]
set_property -dict [list CONFIG.C_NUM_OF_PROBES {5} CONFIG.C_PROBE0_WIDTH {32} CONFIG.C_PROBE1_WIDTH {1} CONFIG.C_PROBE2_WIDTH {1} CONFIG.C_PROBE3_WIDTH {1} CONFIG.C_PROBE4_WIDTH {1} CONFIG.C_DATA_DEPTH {1024}] [get_bd_cells ila_readback]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins ila_readback/clk]
foreach {idx pin} {0 wr_addr_0/o_data 1 wr_addr_0/o_valid 2 wr_addr_0/o_last 3 wr_addr_0/m00_axi_error 4 wr_addr_0/m00_axi_txn_done} {
 connect_bd_net [get_bd_pins $pin] [get_bd_pins ila_readback/probe$idx]
}
create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_pcie
set_property -dict [list CONFIG.C_NUM_PROBE_IN {2} CONFIG.C_NUM_PROBE_OUT {0}] [get_bd_cells vio_pcie]
connect_bd_net [get_bd_pins xdma_0/axi_aclk] [get_bd_pins vio_pcie/clk]
connect_bd_net [get_bd_pins xdma_0/user_lnk_up] [get_bd_pins vio_pcie/probe_in0]
connect_bd_net [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins vio_pcie/probe_in1]

assign_bd_address
foreach space {xdma_0/M_AXI wr_addr_0/m00_axi} {
 set seg [get_bd_addr_segs -of_objects [get_bd_addr_spaces $space]]
 set_property offset 0x00000000 $seg
 set_property range 4G $seg
}
validate_bd_design
save_bd_design
puts "LINK_BD_VALIDATION_PASS"
