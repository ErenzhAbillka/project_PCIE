set root [file dirname [file dirname [file normalize [info script]]]]
open_project $root/project_PCIE.xpr
open_bd_design [get_files */xdma_pcie.bd]
source $root/scripts/fix_ila.tcl
validate_bd_design -force
save_bd_design
generate_target all [get_files */xdma_pcie.bd]
make_wrapper -files [get_files */xdma_pcie.bd] -top
write_bd_tcl -force $root/scripts/xdma_pcie_completed.tcl
report_ip_status -file $root/scripts/ip_status.rpt
close_project
exit
