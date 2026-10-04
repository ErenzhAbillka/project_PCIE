set_property CONFIG.C_MONITOR_TYPE Native [get_bd_cells ila_readback]
set_property -dict [list CONFIG.C_NUM_OF_PROBES {5} CONFIG.C_PROBE0_WIDTH {32} CONFIG.C_PROBE1_WIDTH {1} CONFIG.C_PROBE2_WIDTH {1} CONFIG.C_PROBE3_WIDTH {1} CONFIG.C_PROBE4_WIDTH {1}] [get_bd_cells ila_readback]
foreach {idx pin} {0 wr_addr_0/o_data 1 wr_addr_0/o_valid 2 wr_addr_0/o_last 3 wr_addr_0/m00_axi_error 4 wr_addr_0/m00_axi_txn_done} {
 set probe [get_bd_pins ila_readback/probe$idx]
 if {![llength [get_bd_nets -of_objects $probe]]} {connect_bd_net [get_bd_pins $pin] $probe}
 if {[get_bd_nets -of_objects $probe] ne [get_bd_nets -of_objects [get_bd_pins $pin]]} {error "ILA probe$idx wiring mismatch"}
}
if {[get_property CONFIG.C_NUM_OF_PROBES [get_bd_cells ila_readback]] != 5} {error "ILA must have five probes"}
