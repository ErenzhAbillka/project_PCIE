# Run in batch after copying the checked RTL/XDC and backing up the original.
set root E:/FPGA_Doc/project_PCIE
open_project $root/project_PCIE.xpr
open_bd_design [get_files */xdma_pcie.bd]
update_module_reference [get_ips *wr_addr*]
source $root/scripts/complete_bd.tcl
generate_target all [get_files */xdma_pcie.bd]
set wrappers [make_wrapper -files [get_files */xdma_pcie.bd] -top]
foreach wrapper $wrappers {
 if {![llength [get_files -quiet $wrapper]]} {add_files $wrapper}
}
set_property top xdma_pcie_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
write_bd_tcl -force $root/scripts/xdma_pcie_completed.tcl
report_ip_status -file $root/scripts/ip_status.rpt
puts "ORIGINAL_PROJECT_BD_COMPLETED"
close_project
exit
