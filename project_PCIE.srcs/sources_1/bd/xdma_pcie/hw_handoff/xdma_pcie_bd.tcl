
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
# acquisition_router, das_writer_packet, top_layer, wr_addr, das_trace_process, das_iq_join, das_iq_mixer, das_phase_source

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

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: das_processing
proc create_hier_cell_das_processing { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_das_processing() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir O accumulator_clipped
  create_bd_pin -dir I -from 31 -to 0 adc_data
  create_bd_pin -dir O adc_ready
  create_bd_pin -dir I -from 1 -to 0 adc_user
  create_bd_pin -dir I adc_valid
  create_bd_pin -dir O alignment_error
  create_bd_pin -dir O -from 1 -to 0 banks_full
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir O format_error
  create_bd_pin -dir O -from 31 -to 0 frame_data
  create_bd_pin -dir O frame_last
  create_bd_pin -dir I frame_ready
  create_bd_pin -dir O frame_valid
  create_bd_pin -dir O -from 31 -to 0 groups_completed
  create_bd_pin -dir I input_fault
  create_bd_pin -dir I -from 15 -to 0 phase_start
  create_bd_pin -dir I -type rst reset_n

  # Create instance: cordic_amp_phase_0, and set properties
  set cordic_amp_phase_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cordic:6.0 cordic_amp_phase_0 ]
  set_property -dict [ list \
   CONFIG.ARESETN {true} \
   CONFIG.Architectural_Configuration {Parallel} \
   CONFIG.Coarse_Rotation {true} \
   CONFIG.Compensation_Scaling {Embedded_Multiplier} \
   CONFIG.Functional_Selection {Translate} \
   CONFIG.Input_Width {16} \
   CONFIG.Output_Width {16} \
   CONFIG.Phase_Format {Radians} \
   CONFIG.Round_Mode {Nearest_Even} \
   CONFIG.cartesian_has_tuser {true} \
   CONFIG.cartesian_tuser_width {2} \
   CONFIG.flow_control {Blocking} \
   CONFIG.out_tready {true} \
 ] $cordic_amp_phase_0

  # Create instance: dds_compiler_0, and set properties
  set dds_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_compiler_0 ]
  set_property -dict [ list \
   CONFIG.DDS_Clock_Rate {100} \
   CONFIG.Has_ARESETn {true} \
   CONFIG.Has_Phase_Out {false} \
   CONFIG.Has_TREADY {true} \
   CONFIG.M_DATA_Has_TUSER {User_Field} \
   CONFIG.Negative_Sine {true} \
   CONFIG.Noise_Shaping {None} \
   CONFIG.Output_Selection {Sine_and_Cosine} \
   CONFIG.Output_Width {10} \
   CONFIG.Parameter_Entry {Hardware_Parameters} \
   CONFIG.PartsPresent {SIN_COS_LUT_only} \
   CONFIG.Phase_Width {16} \
   CONFIG.S_PHASE_Has_TUSER {User_Field} \
   CONFIG.S_PHASE_TUSER_Width {16} \
 ] $dds_compiler_0

  # Create instance: dif_acc_phase_0, and set properties
  set block_name das_trace_process
  set block_cell_name dif_acc_phase_0
  if { [catch {set dif_acc_phase_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dif_acc_phase_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: fir_compiler_i, and set properties
  set fir_compiler_i [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_i ]
  set_property -dict [ list \
   CONFIG.Clock_Frequency {200} \
   CONFIG.CoefficientSource {COE_File} \
   CONFIG.Coefficient_File {../../../../new/das_processing/coefficients/das_125m.coe} \
   CONFIG.Coefficient_Width {16} \
   CONFIG.DATA_TUSER_Width {2} \
   CONFIG.Data_Width {24} \
   CONFIG.Has_ARESETn {true} \
   CONFIG.M_DATA_Has_TREADY {true} \
   CONFIG.M_DATA_Has_TUSER {User_Field} \
   CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Odd} \
   CONFIG.Output_Width {16} \
   CONFIG.Quantization {Integer_Coefficients} \
   CONFIG.S_DATA_Has_TUSER {User_Field} \
   CONFIG.Sample_Frequency {125} \
 ] $fir_compiler_i

  # Create instance: fir_compiler_q, and set properties
  set fir_compiler_q [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 fir_compiler_q ]
  set_property -dict [ list \
   CONFIG.Clock_Frequency {200} \
   CONFIG.CoefficientSource {COE_File} \
   CONFIG.Coefficient_File {../../../../new/das_processing/coefficients/das_125m.coe} \
   CONFIG.Coefficient_Width {16} \
   CONFIG.DATA_TUSER_Width {2} \
   CONFIG.Data_Width {24} \
   CONFIG.Has_ARESETn {true} \
   CONFIG.M_DATA_Has_TREADY {true} \
   CONFIG.M_DATA_Has_TUSER {User_Field} \
   CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Odd} \
   CONFIG.Output_Width {16} \
   CONFIG.Quantization {Integer_Coefficients} \
   CONFIG.S_DATA_Has_TUSER {User_Field} \
   CONFIG.Sample_Frequency {125} \
 ] $fir_compiler_q

  # Create instance: iq_align_0, and set properties
  set block_name das_iq_join
  set block_cell_name iq_align_0
  if { [catch {set iq_align_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iq_align_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mult_iq_0, and set properties
  set block_name das_iq_mixer
  set block_cell_name mult_iq_0
  if { [catch {set mult_iq_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mult_iq_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: phase_source_0, and set properties
  set block_name das_phase_source
  set block_cell_name phase_source_0
  if { [catch {set phase_source_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $phase_source_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net adc_data_1 [get_bd_pins adc_data] [get_bd_pins phase_source_0/adc_data]
  connect_bd_net -net adc_user_1 [get_bd_pins adc_user] [get_bd_pins phase_source_0/adc_user]
  connect_bd_net -net adc_valid_1 [get_bd_pins adc_valid] [get_bd_pins phase_source_0/adc_valid]
  connect_bd_net -net clk_1 [get_bd_pins clk] [get_bd_pins cordic_amp_phase_0/aclk] [get_bd_pins dds_compiler_0/aclk] [get_bd_pins dif_acc_phase_0/clk] [get_bd_pins fir_compiler_i/aclk] [get_bd_pins fir_compiler_q/aclk] [get_bd_pins iq_align_0/clk] [get_bd_pins mult_iq_0/clk] [get_bd_pins phase_source_0/clk]
  connect_bd_net -net cordic_amp_phase_0_m_axis_dout_tdata [get_bd_pins cordic_amp_phase_0/m_axis_dout_tdata] [get_bd_pins dif_acc_phase_0/amp_phase_data]
  connect_bd_net -net cordic_amp_phase_0_m_axis_dout_tuser [get_bd_pins cordic_amp_phase_0/m_axis_dout_tuser] [get_bd_pins dif_acc_phase_0/sample_user]
  connect_bd_net -net cordic_amp_phase_0_m_axis_dout_tvalid [get_bd_pins cordic_amp_phase_0/m_axis_dout_tvalid] [get_bd_pins dif_acc_phase_0/sample_valid]
  connect_bd_net -net cordic_amp_phase_0_s_axis_cartesian_tready [get_bd_pins cordic_amp_phase_0/s_axis_cartesian_tready] [get_bd_pins iq_align_0/cartesian_ready]
  connect_bd_net -net dds_compiler_0_m_axis_data_tdata [get_bd_pins dds_compiler_0/m_axis_data_tdata] [get_bd_pins mult_iq_0/lo_data]
  connect_bd_net -net dds_compiler_0_m_axis_data_tuser [get_bd_pins dds_compiler_0/m_axis_data_tuser] [get_bd_pins mult_iq_0/lo_user]
  connect_bd_net -net dds_compiler_0_m_axis_data_tvalid [get_bd_pins dds_compiler_0/m_axis_data_tvalid] [get_bd_pins mult_iq_0/lo_valid]
  connect_bd_net -net dds_compiler_0_s_axis_phase_tready [get_bd_pins dds_compiler_0/s_axis_phase_tready] [get_bd_pins phase_source_0/phase_ready]
  connect_bd_net -net dif_acc_phase_0_accumulator_clipped [get_bd_pins accumulator_clipped] [get_bd_pins dif_acc_phase_0/accumulator_clipped]
  connect_bd_net -net dif_acc_phase_0_banks_full [get_bd_pins banks_full] [get_bd_pins dif_acc_phase_0/banks_full]
  connect_bd_net -net dif_acc_phase_0_format_error [get_bd_pins format_error] [get_bd_pins dif_acc_phase_0/format_error]
  connect_bd_net -net dif_acc_phase_0_frame_data [get_bd_pins frame_data] [get_bd_pins dif_acc_phase_0/frame_data]
  connect_bd_net -net dif_acc_phase_0_frame_last [get_bd_pins frame_last] [get_bd_pins dif_acc_phase_0/frame_last]
  connect_bd_net -net dif_acc_phase_0_frame_valid [get_bd_pins frame_valid] [get_bd_pins dif_acc_phase_0/frame_valid]
  connect_bd_net -net dif_acc_phase_0_groups_completed [get_bd_pins groups_completed] [get_bd_pins dif_acc_phase_0/groups_completed]
  connect_bd_net -net dif_acc_phase_0_sample_ready [get_bd_pins cordic_amp_phase_0/m_axis_dout_tready] [get_bd_pins dif_acc_phase_0/sample_ready]
  connect_bd_net -net fir_compiler_i_m_axis_data_tdata [get_bd_pins fir_compiler_i/m_axis_data_tdata] [get_bd_pins iq_align_0/i_data]
  connect_bd_net -net fir_compiler_i_m_axis_data_tuser [get_bd_pins fir_compiler_i/m_axis_data_tuser] [get_bd_pins iq_align_0/i_user]
  connect_bd_net -net fir_compiler_i_m_axis_data_tvalid [get_bd_pins fir_compiler_i/m_axis_data_tvalid] [get_bd_pins iq_align_0/i_valid]
  connect_bd_net -net fir_compiler_i_s_axis_data_tready [get_bd_pins fir_compiler_i/s_axis_data_tready] [get_bd_pins mult_iq_0/i_ready]
  connect_bd_net -net fir_compiler_q_m_axis_data_tdata [get_bd_pins fir_compiler_q/m_axis_data_tdata] [get_bd_pins iq_align_0/q_data]
  connect_bd_net -net fir_compiler_q_m_axis_data_tuser [get_bd_pins fir_compiler_q/m_axis_data_tuser] [get_bd_pins iq_align_0/q_user]
  connect_bd_net -net fir_compiler_q_m_axis_data_tvalid [get_bd_pins fir_compiler_q/m_axis_data_tvalid] [get_bd_pins iq_align_0/q_valid]
  connect_bd_net -net fir_compiler_q_s_axis_data_tready [get_bd_pins fir_compiler_q/s_axis_data_tready] [get_bd_pins mult_iq_0/q_ready]
  connect_bd_net -net frame_ready_1 [get_bd_pins frame_ready] [get_bd_pins dif_acc_phase_0/frame_ready]
  connect_bd_net -net input_fault_1 [get_bd_pins input_fault] [get_bd_pins dif_acc_phase_0/input_fault]
  connect_bd_net -net iq_align_0_alignment_error [get_bd_pins alignment_error] [get_bd_pins iq_align_0/alignment_error]
  connect_bd_net -net iq_align_0_cartesian_data [get_bd_pins cordic_amp_phase_0/s_axis_cartesian_tdata] [get_bd_pins iq_align_0/cartesian_data]
  connect_bd_net -net iq_align_0_cartesian_user [get_bd_pins cordic_amp_phase_0/s_axis_cartesian_tuser] [get_bd_pins iq_align_0/cartesian_user]
  connect_bd_net -net iq_align_0_cartesian_valid [get_bd_pins cordic_amp_phase_0/s_axis_cartesian_tvalid] [get_bd_pins iq_align_0/cartesian_valid]
  connect_bd_net -net iq_align_0_i_ready [get_bd_pins fir_compiler_i/m_axis_data_tready] [get_bd_pins iq_align_0/i_ready]
  connect_bd_net -net iq_align_0_q_ready [get_bd_pins fir_compiler_q/m_axis_data_tready] [get_bd_pins iq_align_0/q_ready]
  connect_bd_net -net mult_iq_0_i_data [get_bd_pins fir_compiler_i/s_axis_data_tdata] [get_bd_pins mult_iq_0/i_data]
  connect_bd_net -net mult_iq_0_i_user [get_bd_pins fir_compiler_i/s_axis_data_tuser] [get_bd_pins mult_iq_0/i_user]
  connect_bd_net -net mult_iq_0_i_valid [get_bd_pins fir_compiler_i/s_axis_data_tvalid] [get_bd_pins mult_iq_0/i_valid]
  connect_bd_net -net mult_iq_0_lo_ready [get_bd_pins dds_compiler_0/m_axis_data_tready] [get_bd_pins mult_iq_0/lo_ready]
  connect_bd_net -net mult_iq_0_q_data [get_bd_pins fir_compiler_q/s_axis_data_tdata] [get_bd_pins mult_iq_0/q_data]
  connect_bd_net -net mult_iq_0_q_user [get_bd_pins fir_compiler_q/s_axis_data_tuser] [get_bd_pins mult_iq_0/q_user]
  connect_bd_net -net mult_iq_0_q_valid [get_bd_pins fir_compiler_q/s_axis_data_tvalid] [get_bd_pins mult_iq_0/q_valid]
  connect_bd_net -net phase_source_0_adc_ready [get_bd_pins adc_ready] [get_bd_pins phase_source_0/adc_ready]
  connect_bd_net -net phase_source_0_phase_data [get_bd_pins dds_compiler_0/s_axis_phase_tdata] [get_bd_pins phase_source_0/phase_data]
  connect_bd_net -net phase_source_0_phase_user [get_bd_pins dds_compiler_0/s_axis_phase_tuser] [get_bd_pins phase_source_0/phase_user]
  connect_bd_net -net phase_source_0_phase_valid [get_bd_pins dds_compiler_0/s_axis_phase_tvalid] [get_bd_pins phase_source_0/phase_valid]
  connect_bd_net -net phase_start_1 [get_bd_pins phase_start] [get_bd_pins dif_acc_phase_0/phase_start_cfg]
  connect_bd_net -net reset_n_1 [get_bd_pins reset_n] [get_bd_pins cordic_amp_phase_0/aresetn] [get_bd_pins dds_compiler_0/aresetn] [get_bd_pins dif_acc_phase_0/reset_n] [get_bd_pins fir_compiler_i/aresetn] [get_bd_pins fir_compiler_q/aresetn] [get_bd_pins iq_align_0/reset_n] [get_bd_pins mult_iq_0/reset_n] [get_bd_pins phase_source_0/reset_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}


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
  set adc_data_clk_n_0 [ create_bd_port -dir I -type clk adc_data_clk_n_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $adc_data_clk_n_0
  set adc_data_clk_p_0 [ create_bd_port -dir I -type clk adc_data_clk_p_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $adc_data_clk_p_0
  set adc_spi_csb [ create_bd_port -dir O adc_spi_csb ]
  set adc_sync [ create_bd_port -dir O adc_sync ]
  set adk_spi_csb [ create_bd_port -dir O adk_spi_csb ]
  set dac_data_n [ create_bd_port -dir O -from 15 -to 0 dac_data_n ]
  set dac_data_p [ create_bd_port -dir O -from 15 -to 0 dac_data_p ]
  set dac_dci_n [ create_bd_port -dir O dac_dci_n ]
  set dac_dci_p [ create_bd_port -dir O dac_dci_p ]
  set dac_frame_n [ create_bd_port -dir O dac_frame_n ]
  set dac_frame_p [ create_bd_port -dir O dac_frame_p ]
  set dac_spi_csb [ create_bd_port -dir O dac_spi_csb ]
  set data_pin_n_0 [ create_bd_port -dir I -from 13 -to 0 data_pin_n_0 ]
  set data_pin_p_0 [ create_bd_port -dir I -from 13 -to 0 data_pin_p_0 ]
  set device_spi_sclk [ create_bd_port -dir O device_spi_sclk ]
  set device_spi_sda [ create_bd_port -dir IO device_spi_sda ]
  set reset_rtl_0 [ create_bd_port -dir I -type rst reset_rtl_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_rtl_0

  # Create instance: acquisition_router_0, and set properties
  set block_name acquisition_router
  set block_cell_name acquisition_router_0
  if { [catch {set acquisition_router_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $acquisition_router_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.FRAME_WORDS {16384} \
   CONFIG.SAMPLE_RATE {125000000} \
   CONFIG.TRACE_PERIOD {31250} \
   CONFIG.TRACE_POINTS {16320} \
 ] $acquisition_router_0

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
   CONFIG.FIFO_DEPTH {4096} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.IS_ACLK_ASYNC {1} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {2} \
 ] $axis_data_fifo_0

  # Create instance: compat_bram, and set properties
  set compat_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 compat_bram ]
  set_property -dict [ list \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Memory_Type {Single_Port_RAM} \
 ] $compat_bram

  # Create instance: compat_bram_ctrl, and set properties
  set compat_bram_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 compat_bram_ctrl ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $compat_bram_ctrl

  # Create instance: das_processing
  create_hier_cell_das_processing [current_bd_instance .] das_processing

  # Create instance: das_writer_packet_0, and set properties
  set block_name das_writer_packet
  set block_cell_name das_writer_packet_0
  if { [catch {set das_writer_packet_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $das_writer_packet_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
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

  # Create instance: ila_das, and set properties
  set ila_das [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_das ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {4096} \
   CONFIG.C_NUM_OF_PROBES {8} \
   CONFIG.C_PROBE0_WIDTH {32} \
   CONFIG.C_PROBE1_WIDTH {1} \
   CONFIG.C_PROBE2_WIDTH {1} \
   CONFIG.C_PROBE3_WIDTH {1} \
   CONFIG.C_PROBE4_WIDTH {32} \
   CONFIG.C_PROBE5_WIDTH {32} \
   CONFIG.C_PROBE6_WIDTH {2} \
   CONFIG.C_PROBE7_WIDTH {1} \
 ] $ila_das

  # Create instance: ila_readback, and set properties
  set ila_readback [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_readback ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {1024} \
   CONFIG.C_MONITOR_TYPE {Native} \
   CONFIG.C_NUM_OF_PROBES {8} \
   CONFIG.C_PROBE0_WIDTH {32} \
   CONFIG.C_PROBE1_WIDTH {1} \
   CONFIG.C_PROBE2_WIDTH {1} \
   CONFIG.C_PROBE3_WIDTH {1} \
   CONFIG.C_PROBE4_WIDTH {1} \
   CONFIG.C_PROBE5_WIDTH {32} \
   CONFIG.C_PROBE6_WIDTH {1} \
   CONFIG.C_PROBE7_WIDTH {1} \
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

  # Create instance: top_layer_0, and set properties
  set block_name top_layer
  set block_cell_name top_layer_0
  if { [catch {set top_layer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $top_layer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.TX_SINE_MEM {E:/FPGA_Doc/project_PCIE/project_PCIE.srcs/sources_1/new/tgd_tx/sine_4096.mem} \
 ] $top_layer_0

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
   CONFIG.C_NUM_PROBE_IN {26} \
   CONFIG.C_NUM_PROBE_OUT {9} \
   CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT1_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT2_INIT_VAL {0x0000} \
   CONFIG.C_PROBE_OUT2_WIDTH {16} \
   CONFIG.C_PROBE_OUT3_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT3_WIDTH {1} \
   CONFIG.C_PROBE_OUT4_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT4_WIDTH {1} \
   CONFIG.C_PROBE_OUT5_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT5_WIDTH {32} \
   CONFIG.C_PROBE_OUT6_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT6_WIDTH {32} \
   CONFIG.C_PROBE_OUT7_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT7_WIDTH {1} \
   CONFIG.C_PROBE_OUT8_INIT_VAL {0x0} \
   CONFIG.C_PROBE_OUT8_WIDTH {1} \
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
    set_property -dict [ list \
   CONFIG.WRITE_BASE_ADDR {0x00100000} \
   CONFIG.WRITE_WINDOW_BYTES {0x00100000} \
 ] $wr_addr_0

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
   CONFIG.PF0_DEVICE_ID_mqdma {9028} \
   CONFIG.PF2_DEVICE_ID_mqdma {9028} \
   CONFIG.PF3_DEVICE_ID_mqdma {9028} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axilite_master_scale {Kilobytes} \
   CONFIG.axilite_master_size {32} \
   CONFIG.axisten_freq {125} \
   CONFIG.en_gt_selection {true} \
   CONFIG.pcie_blk_locn {X0Y1} \
   CONFIG.pciebar2axibar_axist_bypass {0x0000000000000000} \
   CONFIG.pf0_device_id {8028} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1} \
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
  connect_bd_intf_net -intf_net compat_bram_ctrl_BRAM_PORTA [get_bd_intf_pins compat_bram/BRAM_PORTA] [get_bd_intf_pins compat_bram_ctrl/BRAM_PORTA]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_ports C0_DDR4_0] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports diff_clock_rtl_0] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net wr_addr_0_m00_axi [get_bd_intf_pins axi_smc/S01_AXI] [get_bd_intf_pins wr_addr_0/m00_axi]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins axi_smc/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins compat_bram_ctrl/S_AXI] [get_bd_intf_pins xdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net AXI_data_out_0_0_data [get_bd_pins axis_data_fifo_0/s_axis_tdata] [get_bd_pins top_layer_0/stream_data]
  connect_bd_net -net AXI_data_out_0_0_valid [get_bd_pins axis_data_fifo_0/s_axis_tvalid] [get_bd_pins top_layer_0/stream_valid]
  connect_bd_net -net Net [get_bd_pins acquisition_router_0/reset_n] [get_bd_pins axi_smc/aresetn] [get_bd_pins das_processing/reset_n] [get_bd_pins das_writer_packet_0/reset_n] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins rst_ddr/peripheral_aresetn] [get_bd_pins top_layer_0/rst_n] [get_bd_pins wr_addr_0/m00_axi_aresetn] [get_bd_pins wr_addr_0/rst_n]
  connect_bd_net -net Net1 [get_bd_ports device_spi_sda] [get_bd_pins top_layer_0/device_spi_sda]
  connect_bd_net -net acquisition_router_0_adc_ready [get_bd_pins acquisition_router_0/adc_ready] [get_bd_pins axis_data_fifo_0/m_axis_tready]
  connect_bd_net -net acquisition_router_0_adc_test_request [get_bd_pins acquisition_router_0/adc_test_request] [get_bd_pins top_layer_0/adc_test_enable]
  connect_bd_net -net acquisition_router_0_configuration_error [get_bd_pins acquisition_router_0/configuration_error] [get_bd_pins vio_readback/probe_in19]
  connect_bd_net -net acquisition_router_0_das_adc_data [get_bd_pins acquisition_router_0/das_adc_data] [get_bd_pins das_processing/adc_data]
  connect_bd_net -net acquisition_router_0_das_adc_user [get_bd_pins acquisition_router_0/das_adc_user] [get_bd_pins das_processing/adc_user]
  connect_bd_net -net acquisition_router_0_das_adc_valid [get_bd_pins acquisition_router_0/das_adc_valid] [get_bd_pins das_processing/adc_valid]
  connect_bd_net -net acquisition_router_0_das_frame_ready [get_bd_pins acquisition_router_0/das_frame_ready] [get_bd_pins das_processing/frame_ready]
  connect_bd_net -net acquisition_router_0_frame_data [get_bd_pins acquisition_router_0/frame_data] [get_bd_pins das_writer_packet_0/frame_data] [get_bd_pins ila_das/probe0]
  connect_bd_net -net acquisition_router_0_frame_last [get_bd_pins acquisition_router_0/frame_last] [get_bd_pins das_writer_packet_0/frame_last] [get_bd_pins ila_das/probe3]
  connect_bd_net -net acquisition_router_0_frame_valid [get_bd_pins acquisition_router_0/frame_valid] [get_bd_pins das_writer_packet_0/frame_valid] [get_bd_pins ila_das/probe1]
  connect_bd_net -net acquisition_router_0_frontend_enable [get_bd_pins acquisition_router_0/frontend_enable] [get_bd_pins top_layer_0/acquisition_enable]
  connect_bd_net -net acquisition_router_0_mode_locked [get_bd_pins acquisition_router_0/mode_locked] [get_bd_pins vio_readback/probe_in24]
  connect_bd_net -net acquisition_router_0_raw_capture_complete [get_bd_pins acquisition_router_0/raw_capture_complete] [get_bd_pins vio_readback/probe_in16]
  connect_bd_net -net acquisition_router_0_raw_capture_error [get_bd_pins acquisition_router_0/raw_capture_error] [get_bd_pins vio_readback/probe_in17]
  connect_bd_net -net acquisition_router_0_raw_frame_sent [get_bd_pins acquisition_router_0/raw_frame_sent] [get_bd_pins vio_readback/probe_in18]
  connect_bd_net -net acquisition_router_0_raw_mode_active [get_bd_pins acquisition_router_0/raw_mode_active] [get_bd_pins vio_readback/probe_in20]
  connect_bd_net -net acquisition_router_0_tx_enable_locked [get_bd_pins acquisition_router_0/tx_enable_locked] [get_bd_pins top_layer_0/tx_enable]
  connect_bd_net -net adc_data_clk_n_0_1 [get_bd_ports adc_data_clk_n_0] [get_bd_pins top_layer_0/adc_data_clk_n]
  connect_bd_net -net adc_data_clk_p_0_1 [get_bd_ports adc_data_clk_p_0] [get_bd_pins top_layer_0/adc_data_clk_p]
  connect_bd_net -net axis_data_fifo_0_m_axis_tdata [get_bd_pins acquisition_router_0/adc_data] [get_bd_pins axis_data_fifo_0/m_axis_tdata] [get_bd_pins ila_readback/probe5]
  connect_bd_net -net axis_data_fifo_0_m_axis_tuser [get_bd_pins acquisition_router_0/adc_user] [get_bd_pins axis_data_fifo_0/m_axis_tuser]
  connect_bd_net -net axis_data_fifo_0_m_axis_tvalid [get_bd_pins acquisition_router_0/adc_valid] [get_bd_pins axis_data_fifo_0/m_axis_tvalid] [get_bd_pins ila_readback/probe6]
  connect_bd_net -net axis_data_fifo_0_s_axis_tready [get_bd_pins axis_data_fifo_0/s_axis_tready] [get_bd_pins top_layer_0/stream_ready]
  connect_bd_net -net das_processing_accumulator_clipped [get_bd_pins das_processing/accumulator_clipped] [get_bd_pins vio_readback/probe_in9]
  connect_bd_net -net das_processing_adc_ready [get_bd_pins acquisition_router_0/das_adc_ready] [get_bd_pins das_processing/adc_ready]
  connect_bd_net -net das_processing_alignment_error [get_bd_pins das_processing/alignment_error] [get_bd_pins vio_readback/probe_in5]
  connect_bd_net -net das_processing_banks_full [get_bd_pins das_processing/banks_full] [get_bd_pins ila_das/probe6]
  connect_bd_net -net das_processing_format_error [get_bd_pins das_processing/format_error] [get_bd_pins ila_das/probe7] [get_bd_pins vio_readback/probe_in6]
  connect_bd_net -net das_processing_frame_data [get_bd_pins acquisition_router_0/das_frame_data] [get_bd_pins das_processing/frame_data]
  connect_bd_net -net das_processing_frame_last [get_bd_pins acquisition_router_0/das_frame_last] [get_bd_pins das_processing/frame_last]
  connect_bd_net -net das_processing_frame_valid [get_bd_pins acquisition_router_0/das_frame_valid] [get_bd_pins das_processing/frame_valid]
  connect_bd_net -net das_processing_groups_completed [get_bd_pins das_processing/groups_completed] [get_bd_pins ila_das/probe4] [get_bd_pins vio_readback/probe_in7]
  connect_bd_net -net das_writer_packet_0_ddr_frames_done [get_bd_pins das_writer_packet_0/ddr_frames_done] [get_bd_pins ila_das/probe5] [get_bd_pins vio_readback/probe_in8]
  connect_bd_net -net das_writer_packet_0_framing_error [get_bd_pins das_writer_packet_0/framing_error] [get_bd_pins vio_readback/probe_in10]
  connect_bd_net -net das_writer_packet_0_writer_data [get_bd_pins das_writer_packet_0/writer_data] [get_bd_pins wr_addr_0/i_data]
  connect_bd_net -net das_writer_packet_0_writer_last [get_bd_pins das_writer_packet_0/writer_last] [get_bd_pins wr_addr_0/i_last]
  connect_bd_net -net das_writer_packet_0_writer_valid [get_bd_pins das_writer_packet_0/writer_valid] [get_bd_pins wr_addr_0/i_valid]
  connect_bd_net -net data_pin_n_0_1 [get_bd_ports data_pin_n_0] [get_bd_pins top_layer_0/data_pin_n]
  connect_bd_net -net data_pin_p_0_1 [get_bd_ports data_pin_p_0] [get_bd_pins top_layer_0/data_pin_p]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_pins acquisition_router_0/clk] [get_bd_pins axi_smc/aclk] [get_bd_pins axis_data_fifo_0/m_axis_aclk] [get_bd_pins das_processing/clk] [get_bd_pins das_writer_packet_0/clk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins ila_das/clk] [get_bd_pins ila_readback/clk] [get_bd_pins rst_ddr/slowest_sync_clk] [get_bd_pins top_layer_0/ctrl_clk] [get_bd_pins vio_readback/clk] [get_bd_pins wr_addr_0/clk] [get_bd_pins wr_addr_0/m00_axi_aclk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins rst_ddr/ext_reset_in]
  connect_bd_net -net ddr4_0_c0_init_calib_complete [get_bd_pins ddr4_0/c0_init_calib_complete] [get_bd_pins rst_ddr/dcm_locked] [get_bd_pins vio_readback/probe_in0]
  connect_bd_net -net frame_ready_1 [get_bd_pins acquisition_router_0/frame_ready] [get_bd_pins das_writer_packet_0/frame_ready] [get_bd_pins ila_das/probe2]
  connect_bd_net -net one_dout [get_bd_pins one/dout] [get_bd_pins wr_addr_0/i_fifo_ready]
  connect_bd_net -net perst_invert_Res [get_bd_pins ddr4_0/sys_rst] [get_bd_pins perst_invert/Res]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports reset_rtl_0] [get_bd_pins perst_invert/Op1] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net top_layer_0_acquisition_active [get_bd_pins top_layer_0/acquisition_active] [get_bd_pins vio_readback/probe_in3]
  connect_bd_net -net top_layer_0_adc_data_ch1 [get_bd_pins top_layer_0/adc_data_ch1]
  connect_bd_net -net top_layer_0_adc_fifo_aresetn [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins top_layer_0/adc_fifo_aresetn]
  connect_bd_net -net top_layer_0_adc_overflow [get_bd_pins acquisition_router_0/input_fault] [get_bd_pins das_processing/input_fault] [get_bd_pins ila_readback/probe7] [get_bd_pins top_layer_0/adc_overflow] [get_bd_pins vio_readback/probe_in4]
  connect_bd_net -net top_layer_0_adc_spi_csb [get_bd_ports adc_spi_csb] [get_bd_pins top_layer_0/adc_spi_csb]
  connect_bd_net -net top_layer_0_adc_spi_readback [get_bd_pins top_layer_0/adc_spi_readback] [get_bd_pins vio_readback/probe_in25]
  connect_bd_net -net top_layer_0_adc_sync [get_bd_ports adc_sync] [get_bd_pins top_layer_0/adc_sync]
  connect_bd_net -net top_layer_0_adc_test_active [get_bd_pins acquisition_router_0/adc_test_active] [get_bd_pins top_layer_0/adc_test_active] [get_bd_pins vio_readback/probe_in11]
  connect_bd_net -net top_layer_0_adc_test_checked_count [get_bd_pins top_layer_0/adc_test_checked_count] [get_bd_pins vio_readback/probe_in13]
  connect_bd_net -net top_layer_0_adc_test_config_locked [get_bd_pins top_layer_0/adc_test_config_locked] [get_bd_pins vio_readback/probe_in15]
  connect_bd_net -net top_layer_0_adc_test_error [get_bd_pins top_layer_0/adc_test_error] [get_bd_pins vio_readback/probe_in12]
  connect_bd_net -net top_layer_0_adc_test_error_count [get_bd_pins top_layer_0/adc_test_error_count] [get_bd_pins vio_readback/probe_in14]
  connect_bd_net -net top_layer_0_adk_spi_csb [get_bd_ports adk_spi_csb] [get_bd_pins top_layer_0/adk_spi_csb]
  connect_bd_net -net top_layer_0_dac_data_n [get_bd_ports dac_data_n] [get_bd_pins top_layer_0/dac_data_n]
  connect_bd_net -net top_layer_0_dac_data_p [get_bd_ports dac_data_p] [get_bd_pins top_layer_0/dac_data_p]
  connect_bd_net -net top_layer_0_dac_dci_n [get_bd_ports dac_dci_n] [get_bd_pins top_layer_0/dac_dci_n]
  connect_bd_net -net top_layer_0_dac_dci_p [get_bd_ports dac_dci_p] [get_bd_pins top_layer_0/dac_dci_p]
  connect_bd_net -net top_layer_0_dac_frame_n [get_bd_ports dac_frame_n] [get_bd_pins top_layer_0/dac_frame_n]
  connect_bd_net -net top_layer_0_dac_frame_p [get_bd_ports dac_frame_p] [get_bd_pins top_layer_0/dac_frame_p]
  connect_bd_net -net top_layer_0_dac_spi_csb [get_bd_ports dac_spi_csb] [get_bd_pins top_layer_0/dac_spi_csb]
  connect_bd_net -net top_layer_0_device_spi_sclk [get_bd_ports device_spi_sclk] [get_bd_pins top_layer_0/device_spi_sclk]
  connect_bd_net -net top_layer_0_init_done [get_bd_pins top_layer_0/init_done] [get_bd_pins vio_readback/probe_in2]
  connect_bd_net -net top_layer_0_stream_user [get_bd_pins axis_data_fifo_0/s_axis_tuser] [get_bd_pins top_layer_0/stream_user]
  connect_bd_net -net top_layer_0_sys_clk [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins top_layer_0/sys_clk]
  connect_bd_net -net top_layer_0_tx_fault [get_bd_pins acquisition_router_0/tx_fault] [get_bd_pins top_layer_0/tx_fault] [get_bd_pins vio_readback/probe_in22]
  connect_bd_net -net top_layer_0_tx_init_done [get_bd_pins acquisition_router_0/tx_init_done] [get_bd_pins top_layer_0/tx_init_done] [get_bd_pins vio_readback/probe_in21]
  connect_bd_net -net top_layer_0_tx_status [get_bd_pins top_layer_0/tx_status] [get_bd_pins vio_readback/probe_in23]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins util_ds_buf/IBUF_DS_ODIV2] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins util_ds_buf/IBUF_OUT] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net vio_readback_probe_out0 [get_bd_pins vio_readback/probe_out0] [get_bd_pins wr_addr_0/xdma_valid]
  connect_bd_net -net vio_readback_probe_out1 [get_bd_pins acquisition_router_0/start] [get_bd_pins vio_readback/probe_out1]
  connect_bd_net -net vio_readback_probe_out2 [get_bd_pins das_processing/phase_start] [get_bd_pins vio_readback/probe_out2]
  connect_bd_net -net vio_readback_probe_out3 [get_bd_pins acquisition_router_0/raw_mode_cfg] [get_bd_pins vio_readback/probe_out3]
  connect_bd_net -net vio_readback_probe_out4 [get_bd_pins acquisition_router_0/test_enable_cfg] [get_bd_pins vio_readback/probe_out4]
  connect_bd_net -net vio_readback_probe_out5 [get_bd_pins acquisition_router_0/epoch_cfg] [get_bd_pins vio_readback/probe_out5]
  connect_bd_net -net vio_readback_probe_out6 [get_bd_pins acquisition_router_0/config_id_cfg] [get_bd_pins vio_readback/probe_out6]
  connect_bd_net -net vio_readback_probe_out7 [get_bd_pins acquisition_router_0/tx_enable_cfg] [get_bd_pins vio_readback/probe_out7]
  connect_bd_net -net vio_readback_probe_out8 [get_bd_pins top_layer_0/tx_abort] [get_bd_pins vio_readback/probe_out8]
  connect_bd_net -net wr_addr_0_fifo_ready [get_bd_pins das_writer_packet_0/writer_ready] [get_bd_pins wr_addr_0/fifo_ready]
  connect_bd_net -net wr_addr_0_m00_axi_error [get_bd_pins ila_readback/probe3] [get_bd_pins vio_readback/probe_in1] [get_bd_pins wr_addr_0/m00_axi_error]
  connect_bd_net -net wr_addr_0_m00_axi_txn_done [get_bd_pins das_writer_packet_0/burst_done] [get_bd_pins ila_readback/probe4] [get_bd_pins wr_addr_0/m00_axi_txn_done]
  connect_bd_net -net wr_addr_0_o_data [get_bd_pins ila_readback/probe0] [get_bd_pins wr_addr_0/o_data]
  connect_bd_net -net wr_addr_0_o_last [get_bd_pins ila_readback/probe2] [get_bd_pins wr_addr_0/o_last]
  connect_bd_net -net wr_addr_0_o_valid [get_bd_pins ila_readback/probe1] [get_bd_pins wr_addr_0/o_valid]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axi_smc/aclk1] [get_bd_pins compat_bram_ctrl/s_axi_aclk] [get_bd_pins vio_pcie/clk] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins compat_bram_ctrl/s_axi_aresetn] [get_bd_pins vio_pcie/probe_in1] [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins xdma_reset_invert/Op1]
  connect_bd_net -net xdma_0_user_lnk_up [get_bd_pins vio_pcie/probe_in0] [get_bd_pins xdma_0/user_lnk_up]
  connect_bd_net -net xdma_reset_invert_Res [get_bd_pins rst_ddr/aux_reset_in] [get_bd_pins xdma_reset_invert/Res]
  connect_bd_net -net zero_19_dout [get_bd_pins xdma_0/cfg_mgmt_addr] [get_bd_pins zero_19/dout]
  connect_bd_net -net zero_1_dout [get_bd_pins rst_ddr/mb_debug_sys_rst] [get_bd_pins wr_addr_0/m00_axi_init_axi_txn] [get_bd_pins xdma_0/cfg_mgmt_read] [get_bd_pins xdma_0/cfg_mgmt_type1_cfg_reg_access] [get_bd_pins xdma_0/cfg_mgmt_write] [get_bd_pins xdma_0/usr_irq_req] [get_bd_pins zero_1/dout]
  connect_bd_net -net zero_32_dout [get_bd_pins xdma_0/cfg_mgmt_write_data] [get_bd_pins zero_32/dout]
  connect_bd_net -net zero_4_dout [get_bd_pins xdma_0/cfg_mgmt_byte_enable] [get_bd_pins zero_4/dout]

  # Create address segments
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces wr_addr_0/m00_axi] [get_bd_addr_segs ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x00008000 -offset 0x00000000 [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs compat_bram_ctrl/S_AXI/Mem0] SEG_compat_bram
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


