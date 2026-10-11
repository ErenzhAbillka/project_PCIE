# Idempotent ADC diagnostic + finite RAW1 routing. No synth/impl/run reset/bit.
# Before first use, back up XPR, BD products, XDC and check scripts.
set scripts [file dirname [file normalize [info script]]]
set root [file dirname $scripts]
set evidence [file join $root link_bulid ADC_RAW_TX integration]
file mkdir $evidence
open_project [file join $root project_PCIE.xpr]
set raw_source [file join $root project_PCIE.srcs sources_1 new das_processing raw_trace_capture.v]
if {![llength [get_files -quiet $raw_source]]} {add_files -norecurse $raw_source}
set txdir [file join $root project_PCIE.srcs sources_1 new tgd_tx]
foreach source [concat [glob -nocomplain -directory $txdir *.v] [list [file join $txdir sine_4096.mem]]] {
    if {![llength [get_files -quiet $source]]} {add_files -norecurse $source}
}
update_compile_order -fileset sources_1
open_bd_design [get_files */xdma_pcie.bd]
proc detach {name} {
    set pin [get_bd_pins $name]
    foreach net [get_bd_nets -quiet -of_objects $pin] {disconnect_bd_net $net $pin}
}
proc wireup {args} {
    set pins {}
    foreach name $args {
        set endpoint [get_bd_pins -quiet $name]
        if {![llength $endpoint]} {set endpoint [get_bd_ports $name]}
        lappend pins $endpoint
    }
    set common [get_bd_nets -quiet -of_objects [lindex $pins 0]]
    if {[llength $common] == 1} {
        set connected_names {}
        foreach endpoint [concat [get_bd_pins -quiet -of_objects $common] [get_bd_ports -quiet -of_objects $common]] {
            lappend connected_names [string trimleft $endpoint /]
        }
        set all_present 1
        foreach pin $pins {
            if {[lsearch -exact $connected_names [string trimleft $pin /]] < 0} {set all_present 0}
        }
        if {$all_present} {return}
    }
    connect_bd_net {*}$pins
}
update_module_reference [get_ips *top_layer*]
set_property CONFIG.TX_SINE_MEM [file normalize [file join $txdir sine_4096.mem]] [get_bd_cells top_layer_0]
if {![llength [get_bd_cells -quiet acquisition_router_0]]} {
    create_bd_cell -type module -reference acquisition_router acquisition_router_0
} else {
    update_module_reference [get_ips *acquisition_router*]
}
set_property -dict [list CONFIG.TRACE_POINTS {16320} CONFIG.FRAME_WORDS {16384} CONFIG.SAMPLE_RATE {125000000} CONFIG.TRACE_PERIOD {31250}] [get_bd_cells acquisition_router_0]
set vio_parameters [list CONFIG.C_NUM_PROBE_OUT {9} CONFIG.C_NUM_PROBE_IN {25}]
foreach {index width} {3 1 4 1 5 32 6 32 7 1 8 1} {
    lappend vio_parameters CONFIG.C_PROBE_OUT${index}_WIDTH $width CONFIG.C_PROBE_OUT${index}_INIT_VAL {0x0}
}
foreach {index width} {11 1 12 1 13 32 14 32 15 1 16 1 17 1 18 1 19 1 20 1 21 1 22 1 23 32 24 1} {
    lappend vio_parameters CONFIG.C_PROBE_IN${index}_WIDTH $width
}
set_property -dict $vio_parameters [get_bd_cells vio_readback]
wireup ddr4_0/c0_ddr4_ui_clk acquisition_router_0/clk
wireup rst_ddr/peripheral_aresetn acquisition_router_0/reset_n
# Preserve actual existing VIO numbering: out0 is writer diagnostic read;
# out1 was acquisition start, out2 remains DAS phase ROI start.
detach top_layer_0/acquisition_enable
wireup vio_readback/probe_out1 acquisition_router_0/start
wireup acquisition_router_0/frontend_enable top_layer_0/acquisition_enable
detach top_layer_0/adc_test_enable
wireup acquisition_router_0/adc_test_request top_layer_0/adc_test_enable
foreach {index input} {3 raw_mode_cfg 4 test_enable_cfg 5 epoch_cfg 6 config_id_cfg 7 tx_enable_cfg} {
    detach acquisition_router_0/$input
    wireup vio_readback/probe_out$index acquisition_router_0/$input
}
wireup top_layer_0/adc_test_active acquisition_router_0/adc_test_active
wireup top_layer_0/adc_overflow acquisition_router_0/input_fault
foreach signal {data user valid} {
    detach das_processing/adc_$signal
    wireup axis_data_fifo_0/m_axis_t$signal acquisition_router_0/adc_$signal
    wireup acquisition_router_0/das_adc_$signal das_processing/adc_$signal
}
detach axis_data_fifo_0/m_axis_tready
wireup acquisition_router_0/adc_ready axis_data_fifo_0/m_axis_tready
wireup das_processing/adc_ready acquisition_router_0/das_adc_ready
foreach signal {data valid last} {
    detach das_writer_packet_0/frame_$signal
    wireup das_processing/frame_$signal acquisition_router_0/das_frame_$signal
    wireup acquisition_router_0/frame_$signal das_writer_packet_0/frame_$signal
}
detach das_processing/frame_ready
wireup acquisition_router_0/das_frame_ready das_processing/frame_ready
wireup das_writer_packet_0/frame_ready acquisition_router_0/frame_ready
foreach {index signal} {0 data 1 valid 2 ready 3 last} {
    detach ila_das/probe$index
    wireup acquisition_router_0/frame_$signal ila_das/probe$index
}
foreach {index pin} {
    11 top_layer_0/adc_test_active
    12 top_layer_0/adc_test_error
    13 top_layer_0/adc_test_checked_count
    14 top_layer_0/adc_test_error_count
    15 top_layer_0/adc_test_config_locked
    16 acquisition_router_0/raw_capture_complete
    17 acquisition_router_0/raw_capture_error
    18 acquisition_router_0/raw_frame_sent
    19 acquisition_router_0/configuration_error
    20 acquisition_router_0/raw_mode_active
    24 acquisition_router_0/mode_locked
} {
    detach vio_readback/probe_in$index
    wireup $pin vio_readback/probe_in$index
}
# Actual TX handshakes replace the temporary ADC-only zero ties.
foreach {signal index} {tx_init_done 21 tx_fault 22} {
    detach acquisition_router_0/$signal
    detach vio_readback/probe_in$index
    wireup top_layer_0/$signal acquisition_router_0/$signal vio_readback/probe_in$index
}
detach top_layer_0/tx_enable
wireup acquisition_router_0/tx_enable_locked top_layer_0/tx_enable
detach top_layer_0/tx_abort
wireup vio_readback/probe_out8 top_layer_0/tx_abort
detach vio_readback/probe_in23
wireup top_layer_0/tx_status vio_readback/probe_in23
foreach {name width} {dac_data_p 16 dac_data_n 16 dac_dci_p 1 dac_dci_n 1 dac_frame_p 1 dac_frame_n 1} {
    if {![llength [get_bd_ports -quiet $name]]} {
        if {$width == 1} {create_bd_port -dir O $name} else {create_bd_port -dir O -from [expr {$width-1}] -to 0 $name}
    }
    wireup top_layer_0/$name $name
}
set dac_xdc [file join $root project_PCIE.srcs constrs_1 new fmc_dac_pins.xdc]
if {![llength [get_files -quiet $dac_xdc]]} {add_files -fileset constrs_1 $dac_xdc}
set_property PROCESSING_ORDER LATE [get_files $dac_xdc]
validate_bd_design -force
puts "ADC_RAW_BD_VALIDATE_PASS"
save_bd_design
set_property generate_synth_checkpoint false [get_files */xdma_pcie.bd]
# Existing nested SmartConnect generation cache may say up-to-date while an
# internal HDL product is absent. Reset generated targets only, never user runs.
set sc_clock_helper [file join $root project_PCIE.srcs sources_1 bd xdma_pcie ip xdma_pcie_axi_smc_0 bd_0 ip ip_0 synth bd_5f9e_one_0.v]
if {![file exists $sc_clock_helper]} {reset_target all [get_files */xdma_pcie.bd]}
generate_target all -force [get_files */xdma_pcie.bd]
set wrappers [make_wrapper -files [get_files */xdma_pcie.bd] -top]
foreach wrapper $wrappers {if {![llength [get_files -quiet $wrapper]]} {add_files $wrapper}}
set_property top xdma_pcie_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
if {![file exists $sc_clock_helper]} {error "SmartConnect nested clock helper still missing after forced parent regeneration"}
set helper_in_order 0
foreach source [get_files -compile_order sources -used_in synthesis] {
    if {[string equal -nocase [file normalize $source] [file normalize $sc_clock_helper]]} {set helper_in_order 1}
}
if {!$helper_in_order} {error "Regenerated SmartConnect helper not in persistent project compile order"}
puts "MAIN_SMARTCONNECT_GENERATED_SOURCE_AND_COMPILE_ORDER_PASS"
set handle [open [file join $evidence adc_raw_compile_order.txt] w]
foreach source [get_files -compile_order sources -used_in synthesis] {puts $handle $source}
close $handle
write_bd_tcl -force [file join $evidence xdma_pcie_adc_raw.tcl]
puts "ADC_RAW_MAIN_BD_INTEGRATION_PASS"
close_project
exit
