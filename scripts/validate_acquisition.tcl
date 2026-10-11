# Validate the active ADC/RAW/TX design without running implementation.
# vivado -mode batch -source <project>/scripts/validate_acquisition.tcl
set scripts [file dirname [file normalize [info script]]]
set root [file dirname $scripts]
set out [file join $root link_bulid ADC_RAW_TX validation]
file mkdir $out
cd $out
set_param general.maxThreads 4
open_project [file join $root project_PCIE.xpr]
open_bd_design [get_files */xdma_pcie.bd]
update_module_reference [get_ips *top_layer*]
set_property CONFIG.TX_SINE_MEM [file normalize [file join $root project_PCIE.srcs sources_1 new tgd_tx sine_4096.mem]] [get_bd_cells top_layer_0]
validate_bd_design -force
set bd [get_files */xdma_pcie.bd]
set helper [file join $root project_PCIE.srcs sources_1 bd xdma_pcie ip xdma_pcie_axi_smc_0 bd_0 ip ip_0 synth bd_5f9e_one_0.v]
if {![file exists $helper]} {reset_target all $bd}
generate_target all -force $bd
if {![file exists $helper]} {error "SmartConnect nested source is missing"}
make_wrapper -files $bd -top
update_compile_order -fileset sources_1
synth_design -rtl -top xdma_pcie_wrapper -part [get_property PART [current_project]] -name acquisition_rtl
foreach reference {adc_capture_monitor adc_pn9_checker adc_test_snapshot acquisition_router raw_trace_capture wr_addr tgd_tx_frontend ad9122_lvds_tx} {
    if {[llength [get_cells -hier -filter "REF_NAME == $reference"]] != 1} {error "Expected one $reference instance"}
}
foreach {pattern expected} {
    {.*capture_monitor_inst/(heartbeat_sync_reg|sample_valid_sync_reg)\[0\]/D} 2
    {.*(test_checker_inst/enable_sync_reg|test_snapshot_inst/request_sync_reg|test_snapshot_inst/ack_sync_reg)\[0\]/D} 3
    {.*test_snapshot_inst/snapshot_data_reg\[[0-9]+\]/C} 65
    {.*test_snapshot_inst/(error_reg|error_count_reg\[[0-9]+\]|checked_count_reg\[[0-9]+\])/D} 65
    {.*(tx_adc_valid_sync_reg|tx_arm_sync_reg|tx_kill_sync_reg|tx_ready_ctrl_sync_reg|tx_started_ctrl_sync_reg|tx_done_ctrl_sync_reg)\[0\]/D} 6
} {
    if {[llength [get_pins -hier -regexp $pattern]] != $expected} {error "Constraint object mismatch: $pattern"}
}
source [file join $scripts verify_dac_constraints.tcl]
puts "ACQUISITION_RTL_VALIDATE_PASS: BD, full wrapper RTL and CDC/DAC objects; encrypted DSP internals may be black boxes; no implementation or bitstream"
close_project
exit
