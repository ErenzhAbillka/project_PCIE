set root [file dirname [file dirname [file normalize [info script]]]]
open_project $root/project_PCIE.xpr
open_bd_design [get_files */xdma_pcie.bd]
proc detach {pin_name} {
    set pin [get_bd_pins -quiet $pin_name]
    if {[llength $pin]} {
        foreach net [get_bd_nets -quiet -of_objects $pin] {disconnect_bd_net $net $pin}
    }
}
foreach pin {
    top_layer_0/write_burst_done top_layer_0/capture_toggle
    top_layer_0/stream_last axis_data_fifo_0/s_axis_tlast
    axis_data_fifo_0/s_axis_aclk axis_data_fifo_0/s_axis_aresetn
    axis_data_fifo_0/m_axis_tready
    wr_addr_0/i_data wr_addr_0/i_valid wr_addr_0/i_last
    vio_readback/probe_in3 vio_readback/probe_in4 ila_readback/probe7
} {detach $pin}
update_module_reference [get_ips *top_layer*]
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.FIFO_DEPTH {4096} CONFIG.FIFO_MODE {1} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TLAST {0}] [get_bd_cells axis_data_fifo_0]
connect_bd_net [get_bd_pins top_layer_0/sys_clk] [get_bd_pins axis_data_fifo_0/s_axis_aclk]
connect_bd_net [get_bd_pins top_layer_0/adc_fifo_aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axis_data_fifo_0/m_axis_aclk]
connect_bd_net [get_bd_pins vio_readback/probe_out1] [get_bd_pins top_layer_0/acquisition_enable]
connect_bd_net [get_bd_pins top_layer_0/acquisition_active] [get_bd_pins vio_readback/probe_in3]
connect_bd_net [get_bd_pins top_layer_0/adc_overflow] [get_bd_pins vio_readback/probe_in4] [get_bd_pins ila_readback/probe7]
# Intentional processing gap: no raw ADC word can enter wr_addr.
# Replace these tie-offs with the future DSP input-ready / aligned output signals.
connect_bd_net [get_bd_pins zero_1/dout] [get_bd_pins axis_data_fifo_0/m_axis_tready] [get_bd_pins wr_addr_0/i_valid] [get_bd_pins wr_addr_0/i_last]
connect_bd_net [get_bd_pins zero_32/dout] [get_bd_pins wr_addr_0/i_data]
set_property CONFIG.C_PROBE_OUT1_INIT_VAL 0x0 [get_bd_cells vio_readback]
foreach net [get_bd_nets] {
    if {[llength [get_bd_pins -quiet -of_objects $net]] + [llength [get_bd_ports -quiet -of_objects $net]] == 0} {delete_bd_objs $net}
}
validate_bd_design -force
save_bd_design
generate_target all [get_files */xdma_pcie.bd]
make_wrapper -files [get_files */xdma_pcie.bd] -top
update_compile_order -fileset sources_1
write_bd_tcl -force $root/scripts/xdma_pcie_adc_dsp_boundary.tcl
puts "ADC_FIFO_PROCESSING_BOUNDARY_BD_PASS"
close_project
exit
