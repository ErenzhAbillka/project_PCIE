set root [file dirname [file dirname [file normalize [info script]]]]
open_project $root/project_PCIE.xpr
open_bd_design [get_files */xdma_pcie.bd]
update_module_reference [get_ips *top_layer*]
# The incomplete DDS/multiplier branch never fed DDR and had no clock/reset.
# Its complete original BD is preserved in adc_integration_backup_20261004.
foreach cell {AXI_data_out_0_0 fifo_generator_0 dds_compiler_0 dds_compiler_1 xlslice_0 xlslice_1 mult_gen_0 mult_gen_1} {
    if {[llength [get_bd_cells -quiet $cell]]} {delete_bd_objs [get_bd_cells $cell]}
}
set_property -dict [list LEFT {13} RIGHT {0}] [get_bd_ports data_pin_p_0]
set_property -dict [list LEFT {13} RIGHT {0}] [get_bd_ports data_pin_n_0]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports {adc_data_clk_p_0 adc_data_clk_n_0}]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins top_layer_0/ctrl_clk]
connect_bd_net [get_bd_pins rst_ddr/peripheral_aresetn] [get_bd_pins top_layer_0/rst_n]
connect_bd_net [get_bd_pins top_layer_0/stream_data] [get_bd_pins axis_data_fifo_0/s_axis_tdata]
connect_bd_net [get_bd_pins top_layer_0/stream_valid] [get_bd_pins axis_data_fifo_0/s_axis_tvalid]
connect_bd_net [get_bd_pins top_layer_0/stream_last] [get_bd_pins axis_data_fifo_0/s_axis_tlast]
connect_bd_net [get_bd_pins axis_data_fifo_0/s_axis_tready] [get_bd_pins top_layer_0/stream_ready]
connect_bd_net [get_bd_pins wr_addr_0/m00_axi_txn_done] [get_bd_pins top_layer_0/write_burst_done]
foreach name {device_spi_sclk adk_spi_csb adc_spi_csb dac_spi_csb adc_sync} {
    create_bd_port -dir O $name
    connect_bd_net [get_bd_ports $name] [get_bd_pins top_layer_0/$name]
}
create_bd_port -dir IO device_spi_sda
connect_bd_net [get_bd_ports device_spi_sda] [get_bd_pins top_layer_0/device_spi_sda]
set_property -dict [list CONFIG.C_NUM_PROBE_IN {5} CONFIG.C_NUM_PROBE_OUT {2} CONFIG.C_PROBE_OUT1_INIT_VAL {0x0}] [get_bd_cells vio_readback]
connect_bd_net [get_bd_pins vio_readback/probe_out1] [get_bd_pins top_layer_0/capture_toggle]
foreach {index pin} {2 init_done 3 capture_done 4 ddr_capture_done} {
    connect_bd_net [get_bd_pins top_layer_0/$pin] [get_bd_pins vio_readback/probe_in$index]
}
# Observe the actual accepted DDR write words, while retaining existing readback probes.
set_property -dict [list CONFIG.C_NUM_OF_PROBES {8} CONFIG.C_PROBE5_WIDTH {32} CONFIG.C_PROBE6_WIDTH {1} CONFIG.C_PROBE7_WIDTH {1}] [get_bd_cells ila_readback]
foreach {index pin} {5 axis_data_fifo_0/m_axis_tdata 6 axis_data_fifo_0/m_axis_tvalid 7 wr_addr_0/fifo_ready} {
    connect_bd_net [get_bd_pins $pin] [get_bd_pins ila_readback/probe$index]
}
foreach net [get_bd_nets] {
    if {[llength [get_bd_pins -quiet -of_objects $net]] + [llength [get_bd_ports -quiet -of_objects $net]] == 0} {delete_bd_objs $net}
}
set xdc $root/project_PCIE.srcs/constrs_1/new/fmc_adc_pins.xdc
if {![llength [get_files -quiet $xdc]]} {add_files -fileset constrs_1 $xdc}
set_property PROCESSING_ORDER LATE [get_files $xdc]
validate_bd_design -force
save_bd_design
set_property generate_synth_checkpoint false [get_files */xdma_pcie.bd]
generate_target all [get_files */xdma_pcie.bd]
set wrappers [make_wrapper -files [get_files */xdma_pcie.bd] -top]
foreach wrapper $wrappers {if {![llength [get_files -quiet $wrapper]]} {add_files $wrapper}}
set_property top xdma_pcie_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
write_bd_tcl -force $root/scripts/xdma_pcie_adc.tcl
puts "ADC_ORIGINAL_BD_INTEGRATION_PASS"
close_project
exit

