# vivado -mode batch -source E:/FPGA_Doc/project_PCIE/scripts/build_link.tcl
set scripts [file dirname [file normalize [info script]]]
set root [file dirname $scripts]
set out [file join $root link_build]
file mkdir $out
open_project [file join $root project_PCIE.xpr]
open_bd_design [get_files */xdma_pcie.bd]
validate_bd_design -force
save_bd_design
# Global synthesis avoids the Windows Script Host run launcher.
set_property generate_synth_checkpoint false [get_files */xdma_pcie.bd]
generate_target all [get_files */xdma_pcie.bd]
make_wrapper -files [get_files */xdma_pcie.bd] -top
update_compile_order -fileset sources_1
synth_design -top xdma_pcie_wrapper -part [get_property PART [current_project]]
write_checkpoint -force $out/synth.dcp
# Debug cores can be black boxes here and are linked during opt_design.
# Implementation DRC (including INBB-3) remains the final black-box check.
opt_design
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
puts "LINK_BITSTREAM_BUILD_PASS"
exit
