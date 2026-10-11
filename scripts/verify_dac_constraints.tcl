# Source with an elaborated/synthesized design open. This checks mapped objects,
# not routed timing closure or measured board skew.
set dac_verify_scripts [file dirname [file normalize [info script]]]
set dac_verify_root [file dirname $dac_verify_scripts]
set dac_verify_table [file join $dac_verify_root project_PCIE.doc ADC_RAW_TX ku060_tx_pins.tsv]
set dac_verify_handle [open $dac_verify_table r]
set dac_verify_rows [split [read $dac_verify_handle] "\n"]
close $dac_verify_handle
set dac_verify_count 0
foreach row [lrange $dac_verify_rows 1 end] {
    set row [string trim $row]
    if {$row eq ""} {continue}
    set fields [split $row "\t"]
    if {[llength $fields] != 6} {error "Malformed DAC mapping TSV row: $row"}
    set signal [lindex $fields 0]
    if {[regexp {^DAC_D([0-9]+)$} $signal -> lane]} {
        set names [list [format {dac_data_p[%d]} $lane] [format {dac_data_n[%d]} $lane]]
    } elseif {$signal eq "DAC_DCI"} {
        set names {dac_dci_p dac_dci_n}
    } elseif {$signal eq "DAC_FRAME"} {
        set names {dac_frame_p dac_frame_n}
    } else {error "Unknown DAC mapping signal: $signal"}
    foreach name $names expected [lrange $fields 4 5] {
        set port [get_ports -quiet $name]
        if {[llength $port] != 1} {error "Missing DAC port $name"}
        if {[get_property PACKAGE_PIN $port] ne $expected} {error "DAC mapping mismatch: $name expected $expected"}
        if {[get_property IOSTANDARD $port] ne "LVDS"} {error "DAC I/O standard mismatch: $name"}
        incr dac_verify_count
    }
}
if {$dac_verify_count != 36} {error "Expected 36 DAC physical pins"}
if {[llength [get_ports {dac_data_p[*] dac_data_n[*]}]] != 32} {error "Expected 32 DAC data ports"}
if {[llength [get_pins -hier -regexp {.*adc_driver_inst/dac_forward_bufg/O}]] != 1} {error "DAC generated clock source must be unique"}
set dac_verify_clock [get_clocks -quiet dac_dci_out]
if {[llength $dac_verify_clock] != 1 || abs([get_property PERIOD $dac_verify_clock]-8.0) > 0.001} {
    error "Expected one 125 MHz forwarded DAC clock"
}
puts "DAC_CONSTRAINT_OBJECT_CHECK_PASS: 36 documented pins, 32 data ports, one 125MHz forwarded clock"
