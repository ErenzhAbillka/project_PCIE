# Package relocation check. Run against an extracted scratch copy:
# vivado -mode batch -source scripts/verify_delivery.tcl -tclargs <project-root>
# Vivado may refresh generated products; no project/BD save is requested here.
if {$argc != 1} {error "Pass the extracted project directory"}
set root [file normalize [lindex $argv 0]]
open_project [file join $root project_PCIE.xpr]
set missing {}
foreach f [get_files -all] {
    if {![file exists $f]} {lappend missing $f}
}
if {[llength $missing]} {error "Missing files: $missing"}
open_bd_design [get_files */xdma_pcie.bd]
set tx_mem [file join $root project_PCIE.srcs sources_1 new tgd_tx sine_4096.mem]
if {![file exists $tx_mem]} {error "Missing TX sine ROM"}
update_module_reference [get_ips *top_layer*]
set_property CONFIG.TX_SINE_MEM [file normalize $tx_mem] [get_bd_cells top_layer_0]
validate_bd_design -force
foreach name {fir_compiler_i fir_compiler_q} {
    puts "FIR_COE_REFERENCE $name [get_property CONFIG.Coefficient_File [get_bd_cells das_processing/$name]]"
}
if {[llength [get_bd_cells das_processing/*]] != 8} {error "Unexpected DAS hierarchy"}
foreach {name expected} {WRITE_BASE_ADDR 0x00100000 WRITE_WINDOW_BYTES 0x00100000} {
    if {[get_property CONFIG.$name [get_bd_cells wr_addr_0]] != $expected} {error "Wrong writer $name"}
}
if {[llength [get_bd_cells -quiet acquisition_router_0]] != 1} {error "Missing acquisition router"}
foreach {name expected} {TRACE_POINTS 16320 FRAME_WORDS 16384 SAMPLE_RATE 125000000 TRACE_PERIOD 31250} {
    if {[get_property CONFIG.$name [get_bd_cells acquisition_router_0]] != $expected} {error "Wrong router $name"}
}
foreach name {dac_data_p dac_data_n dac_dci_p dac_dci_n dac_frame_p dac_frame_n} {
    if {[llength [get_bd_ports -quiet $name]] != 1} {error "Missing DAC port $name"}
}
foreach name {ku060_tx_pins.tsv tx01_plan.json} {
    if {![file exists [file join $root project_PCIE.doc ADC_RAW_TX $name]]} {error "Missing ADC_RAW_TX document $name"}
}
puts "ADC_RAW_TX_DELIVERY_RELOCATION_PASS: files present, BD valid, RAW/TX hierarchy and writer window retained; no synthesis or timing acceptance"
close_project
exit
