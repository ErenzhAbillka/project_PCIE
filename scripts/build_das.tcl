# ADC -> DDS/IQ/FIR/CORDIC -> difference + phase ROI -> four-beat writer.
# vivado -mode batch -source scripts/build_das.tcl
set scripts [file dirname [file normalize [info script]]]
set root [file dirname $scripts]
set out [file join $root link_bulid ADC_RAW_TX]
file mkdir $out
cd $out
open_project [file join $root project_PCIE.xpr]
set_property ip_output_repo [file join $root project_PCIE.cache ip] [current_project]
open_bd_design [get_files */xdma_pcie.bd]
source $scripts/ensure_xdma_compat.tcl
# Resolve the TX ROM from this checkout whenever the project moves disks.
set txdir [file join $root project_PCIE.srcs sources_1 new tgd_tx]
update_module_reference [get_ips *top_layer*]
set_property CONFIG.TX_SINE_MEM [file normalize [file join $txdir sine_4096.mem]] [get_bd_cells top_layer_0]
validate_bd_design -force
save_bd_design
# Global top-level synthesis avoids the main Windows Script Host run launcher.
# opt_design can still launch dbg_hub via WSH; see manual_debug_hub.tcl if it fails.
set_property generate_synth_checkpoint false [get_files */xdma_pcie.bd]
# Vivado 2018.3 may invalidate nested SmartConnect products during validation.
# Reset generated targets only if the known nested HDL helper is absent.
set sc_clock_helper [file join $root project_PCIE.srcs sources_1 bd xdma_pcie ip xdma_pcie_axi_smc_0 bd_0 ip ip_0 synth bd_5f9e_one_0.v]
if {![file exists $sc_clock_helper]} {reset_target all [get_files */xdma_pcie.bd]}
generate_target all -force [get_files */xdma_pcie.bd]
if {![file exists $sc_clock_helper]} {error "SmartConnect nested HDL missing after parent BD regeneration"}
make_wrapper -files [get_files */xdma_pcie.bd] -top
update_compile_order -fileset sources_1
synth_design -top xdma_pcie_wrapper -part [get_property PART [current_project]]
source $scripts/verify_dac_constraints.tcl
write_checkpoint -force $out/synth.dcp
# Debug cores can be black boxes here and are linked during opt_design.
# Implementation DRC (including INBB-3) remains the final black-box check.
opt_design
write_checkpoint -force $out/opt.dcp
place_design
phys_opt_design
route_design
write_checkpoint -force $out/routed.dcp
report_timing_summary -report_unconstrained -file $out/timing_summary.rpt
report_bus_skew -file $out/bus_skew.rpt
set skew_file [open $out/bus_skew.rpt r]
set skew_report [read $skew_file]
close $skew_file
if {[string first {VIOLATED} $skew_report] >= 0} {error "Bus skew failed"}
report_drc -file $out/drc.rpt
report_io -file $out/io.rpt
report_cdc -details -file $out/cdc.rpt
report_route_status -file $out/route_status.rpt
report_utilization -file $out/utilization.rpt
source $scripts/verify_physical_pins.tcl
if {[llength [get_drc_violations -filter {SEVERITY == Error || SEVERITY == {Critical Warning}}]]} {error "Resolve DRC before bitstream"}
foreach kind {max min} {
 set paths [get_timing_paths -delay_type $kind -max_paths 1]
 if {![llength $paths] || [get_property SLACK $paths] < 0} {error "Timing failed ($kind)"}
}
write_debug_probes -force $out/xdma_pcie_wrapper.ltx
write_bitstream -force $out/xdma_pcie_wrapper.bit
puts "ADC_RAW_TX_BITSTREAM_BUILD_PASS"
exit
