
################################################################
# This is a generated script based on design: xdma_pcie
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source xdma_pcie_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# AXI_data_out_0, wr_addr

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku060-ffva1156-2-i
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name xdma_pcie

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:ddr4:2.2\
xilinx.com:ip:ila:6.2\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:vio:3.0\
xilinx.com:ip:xdma:4.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
AXI_data_out_0\
wr_addr\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set C0_DDR4_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 C0_DDR4_0 ]
  set C0_SYS_CLK_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_SYS_CLK_0 ]
  set diff_clock_rtl_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 diff_clock_rtl_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $diff_clock_rtl_0
  set pcie_7x_mgt_rtl_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl_0 ]

  # Create ports
  set reset_rtl_0 [ create_bd_port -dir I -type rst reset_rtl_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_rtl_0

  # Create instance: AXI_data_out_0_0, and set properties
  set block_name AXI_data_out_0
  set block_cell_name AXI_data_out_0_0
  if { [catch {set AXI_data_out_0_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $AXI_data_out_0_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $axi_smc

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {512} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.IS_ACLK_ASYNC {0} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
 ] $axis_data_fifo_0

  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [ list \
   CONFIG.C0.BANK_GROUP_WIDTH {1} \
   CONFIG.C0.DDR4_AxiAddressWidth {32} \
   CONFIG.C0.DDR4_AxiDataWidth {512} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {7} \
   CONFIG.C0.DDR4_CasLatency {11} \
   CONFIG.C0.DDR4_CasWriteLatency {9} \
   CONFIG.C0.DDR4_DataWidth {64} \
   CONFIG.C0.DDR4_InputClockPeriod {10000} \
   CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-083E} \
   CONFIG.C0.DDR4_Specify_MandD {false} \
   CONFIG.C0.DDR4_TimePeriod {1250} \
   CONFIG.System_Clock {Differential} \
 ] $ddr4_0

  # Create instance: ila_readback, and set properties
  set ila_readback [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_readback ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {1024} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {5} \
   CONFIG.C_PROBE0_WIDTH {32} \
   CONFIG.C_PROBE1_WIDTH {1} \
   CONFIG.C_PROBE2_WIDTH {1} \
   CONFIG.C_PROBE3_WIDTH {1} \
   CONFIG.C_PROBE4_WIDTH {1} \
 ] $ila_readback

  # Create instance: one, and set properties
  set one [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 one ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
 ] $one

  # Create instance: perst_invert, and set properties
  set perst_invert [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 perst_invert ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $perst_invert

  # Create instance: rst_ddr, and set properties
  set rst_ddr [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ddr ]
  set_property -dict [ list \
   CONFIG.C_AUX_RESET_HIGH {1} \
 ] $rst_ddr

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $util_ds_buf

  # Create instance: vio_pcie, and set properties
  set vio_pcie [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_pcie ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {2} \
   CONFIG.C_NUM_PROBE_OUT {0} \
 ] $vio_pcie

  # Create instance: vio_readback, and set properties
  set vio_readback [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_readback ]
  set_property -dict [ list \
   CONFIG.C_NUM_PROBE_IN {2} \
   CONFIG.C_NUM_PROBE_OUT {1} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
 ] $vio_readback

  # Create instance: wr_addr_0, and set properties
  set block_name wr_addr
  set block_cell_name wr_addr_0
  if { [catch {set wr_addr_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $wr_addr_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
   CONFIG.PF0_DEVICE_ID_mqdma {9028} \
   CONFIG.PF2_DEVICE_ID_mqdma {9028} \
   CONFIG.PF3_DEVICE_ID_mqdma {9028} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axilite_master_en {false} \
   CONFIG.axisten_freq {125} \
   CONFIG.en_gt_selection {true} \
   CONFIG.pcie_blk_locn {X0Y1} \
   CONFIG.pciebar2axibar_axist_bypass {0x0000000000000000} \
   CONFIG.pf0_device_id {8028} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_0} \
   CONFIG.pf0_msix_cap_table_bir {BAR_0} \
   CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X8} \
   CONFIG.plltype {QPLL1} \
   CONFIG.select_quad {GTH_Quad_227} \
   CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
   CONFIG.xdma_axilite_slave {false} \
 ] $xdma_0

  # Create instance: xdma_reset_invert, and set properties
  set xdma_reset_invert [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 xdma_reset_invert ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $xdma_reset_invert

  # Create instance: zero_1, and set properties
  set zero_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $zero_1

  # Create instance: zero_4, and set properties
  set zero_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_4 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {4} \
 ] $zero_4

  # Create instance: zero_19, and set properties
  set zero_19 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_19 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {19} \
 ] $zero_19

  # Create instance: zero_32, and set properties
  set zero_32 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_32 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {32} \
 ] $zero_32

  # Create interface connections
  connect_bd_intf_net -intf_net C0_SYS_CLK_0_1 [get_bd_intf_ports C0_SYS_CLK_0] [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_ports C0_DDR4_0] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports diff_clock_rtl_0] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net wr_addr_0_m00_axi [get_bd_intf_pins axi_smc/S01_AXI] [get_bd_intf_pins wr_addr_0/m00_axi]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins axi_smc/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net AXI_data_out_0_0_data [get_bd_pins AXI_data_out_0_0/data] [get_bd_pins axis_data_fifo_0/s_axis_tdata]
  connect_bd_net -net AXI_data_out_0_0_last [get_bd_pins AXI_data_out_0_0/last] [get_bd_pins axis_data_fifo_0/s_axis_tlast]
  connect_bd_net -net AXI_data_out_0_0_valid [get_bd_pins AXI_data_out_0_0/valid] [get_bd_pins axis_data_fifo_0/s_axis_tvalid]
  connect_bd_net -net Net [get_bd_pins AXI_data_out_0_0/rst_n] [get_bd_pins axi_smc/aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins rst_ddr/peripheral_aresetn] [get_bd_pins wr_addr_0/m00_axi_aresetn] [get_bd_pins wr_addr_0/rst_n]
  connect_bd_net -net axis_data_fifo_0_m_axis_tdata [get_bd_pins axis_data_fifo_0/m_axis_tdata] [get_bd_pins wr_addr_0/i_data]
  connect_bd_net -net axis_data_fifo_0_m_axis_tlast [get_bd_pins axis_data_fifo_0/m_axis_tlast] [get_bd_pins wr_addr_0/i_last]
  connect_bd_net -net axis_data_fifo_0_m_axis_tvalid [get_bd_pins axis_data_fifo_0/m_axis_tvalid] [get_bd_pins wr_addr_0/i_valid]
  connect_bd_net -net axis_data_fifo_0_s_axis_tready [get_bd_pins AXI_data_out_0_0/fifo_ready] [get_bd_pins axis_data_fifo_0/s_axis_tready]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_pins AXI_data_out_0_0/clk] [get_bd_pins axi_smc/aclk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins ila_readback/clk] [get_bd_pins rst_ddr/slowest_sync_clk] [get_bd_pins vio_readback/clk] [get_bd_pins wr_addr_0/clk] [get_bd_pins wr_addr_0/m00_axi_aclk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins rst_ddr/ext_reset_in]
  connect_bd_net -net ddr4_0_c0_init_calib_complete [get_bd_pins ddr4_0/c0_init_calib_complete] [get_bd_pins rst_ddr/dcm_locked] [get_bd_pins vio_readback/probe_in0]
  connect_bd_net -net one_dout [get_bd_pins one/dout] [get_bd_pins wr_addr_0/i_fifo_ready]
  connect_bd_net -net perst_invert_Res [get_bd_pins ddr4_0/sys_rst] [get_bd_pins perst_invert/Res]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports reset_rtl_0] [get_bd_pins perst_invert/Op1] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins util_ds_buf/IBUF_DS_ODIV2] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins util_ds_buf/IBUF_OUT] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net vio_readback_probe_out0 [get_bd_pins vio_readback/probe_out0] [get_bd_pins wr_addr_0/xdma_valid]
  connect_bd_net -net wr_addr_0_fifo_ready [get_bd_pins axis_data_fifo_0/m_axis_tready] [get_bd_pins wr_addr_0/fifo_ready]
  connect_bd_net -net wr_addr_0_m00_axi_error [get_bd_pins ila_readback/probe3] [get_bd_pins vio_readback/probe_in1] [get_bd_pins wr_addr_0/m00_axi_error]
  connect_bd_net -net wr_addr_0_m00_axi_txn_done [get_bd_pins ila_readback/probe4] [get_bd_pins wr_addr_0/m00_axi_txn_done]
  connect_bd_net -net wr_addr_0_o_data [get_bd_pins ila_readback/probe0] [get_bd_pins wr_addr_0/o_data]
  connect_bd_net -net wr_addr_0_o_last [get_bd_pins ila_readback/probe2] [get_bd_pins wr_addr_0/o_last]
  connect_bd_net -net wr_addr_0_o_valid [get_bd_pins ila_readback/probe1] [get_bd_pins wr_addr_0/o_valid]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axi_smc/aclk1] [get_bd_pins vio_pcie/clk] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins vio_pcie/probe_in1] [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins xdma_reset_invert/Op1]
  connect_bd_net -net xdma_0_user_lnk_up [get_bd_pins vio_pcie/probe_in0] [get_bd_pins xdma_0/user_lnk_up]
  connect_bd_net -net xdma_reset_invert_Res [get_bd_pins rst_ddr/aux_reset_in] [get_bd_pins xdma_reset_invert/Res]
  connect_bd_net -net zero_19_dout [get_bd_pins xdma_0/cfg_mgmt_addr] [get_bd_pins zero_19/dout]
  connect_bd_net -net zero_1_dout [get_bd_pins rst_ddr/mb_debug_sys_rst] [get_bd_pins wr_addr_0/m00_axi_init_axi_txn] [get_bd_pins xdma_0/cfg_mgmt_read] [get_bd_pins xdma_0/cfg_mgmt_type1_cfg_reg_access] [get_bd_pins xdma_0/cfg_mgmt_write] [get_bd_pins xdma_0/usr_irq_req] [get_bd_pins zero_1/dout]
  connect_bd_net -net zero_32_dout [get_bd_pins xdma_0/cfg_mgmt_write_data] [get_bd_pins zero_32/dout]
  connect_bd_net -net zero_4_dout [get_bd_pins xdma_0/cfg_mgmt_byte_enable] [get_bd_pins zero_4/dout]

  # Create address segments
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces wr_addr_0/m00_axi] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces xdma_0/M_AXI] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


