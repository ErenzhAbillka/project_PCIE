# Run only after a real WSH launcher failure, against its generated run directory.
if {$argc != 1} {error "Pass the generated dbg_hub_synth_1 run directory"}
set run_dir [file normalize [lindex $argv 0]]
set generated [file join $run_dir dbg_hub.tcl]
if {![file exists $generated]} {error "Generated debug hub Tcl is missing"}
cd $run_dir
source $generated
if {![file exists [file join $run_dir dbg_hub.dcp]]} {error "Real debug hub synthesis did not write its DCP"}
# This marker is written only after the generated synthesis Tcl actually succeeds.
close [open [file join $run_dir .vivado.end.rst] w]
puts "DEBUG_HUB_MANUAL_SYNTHESIS_PASS"
exit
