set root [file dirname [file dirname [file normalize [info script]]]]
set dsp $root/project_PCIE.srcs/sources_1/new/das_processing
open_project $root/project_PCIE.xpr
add_files -norecurse [list $dsp/das_iq_control.v $dsp/das_trace_process.v]
update_compile_order -fileset sources_1
open_bd_design [get_files */xdma_pcie.bd]
proc detach {name} {
 set p [get_bd_pins -quiet $name]
 if {[llength $p]} {foreach n [get_bd_nets -quiet -of_objects $p] {disconnect_bd_net $n $p}}
}
proc wireup {args} {set ps {}; foreach p $args {lappend ps [get_bd_pins $p]}; connect_bd_net {*}$ps}
if {[llength [get_bd_cells -quiet das_processing]]} {error "DAS hierarchy already exists; do not overwrite a user-edited chain"}
update_module_reference [get_ips *top_layer*]
update_module_reference [get_ips *wr_addr*]
set_property -dict [list CONFIG.WRITE_BASE_ADDR {0x00100000} CONFIG.WRITE_WINDOW_BYTES {0x00100000}] [get_bd_cells wr_addr_0]
set_property CONFIG.TUSER_WIDTH 2 [get_bd_cells axis_data_fifo_0]
wireup top_layer_0/stream_user axis_data_fifo_0/s_axis_tuser
foreach p {axis_data_fifo_0/m_axis_tready wr_addr_0/i_data wr_addr_0/i_valid wr_addr_0/i_last} {detach $p}

create_bd_cell -type hier das_processing
current_bd_instance /das_processing
create_bd_pin -dir I -type clk clk
create_bd_pin -dir I -type rst reset_n
foreach p {adc_valid frame_ready input_fault} {create_bd_pin -dir I $p}
foreach p {adc_ready frame_valid frame_last alignment_error format_error accumulator_clipped} {create_bd_pin -dir O $p}
create_bd_pin -dir I -from 31 -to 0 adc_data
create_bd_pin -dir I -from 1 -to 0 adc_user
create_bd_pin -dir I -from 15 -to 0 phase_start
create_bd_pin -dir O -from 31 -to 0 frame_data
create_bd_pin -dir O -from 31 -to 0 groups_completed
create_bd_pin -dir O -from 1 -to 0 banks_full
create_bd_cell -type module -reference das_phase_source phase_source_0
create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_compiler_0
set_property -dict [list CONFIG.PartsPresent {SIN_COS_LUT_only} CONFIG.Parameter_Entry {Hardware_Parameters} CONFIG.Phase_Width {16} CONFIG.Output_Width {10} CONFIG.Output_Selection {Sine_and_Cosine} CONFIG.Negative_Sine {true} CONFIG.Noise_Shaping {None} CONFIG.Has_Phase_Out {false} CONFIG.Has_TREADY {true} CONFIG.Has_ARESETn {true} CONFIG.S_PHASE_Has_TUSER {User_Field} CONFIG.S_PHASE_TUSER_Width {16} CONFIG.M_DATA_Has_TUSER {User_Field} CONFIG.DDS_Clock_Rate {200}] [get_bd_cells dds_compiler_0]
create_bd_cell -type module -reference das_iq_mixer mult_iq_0
foreach name {fir_compiler_i fir_compiler_q} {
 create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler:7.2 $name
 set_property -dict [list CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $dsp/coefficients/das_125m.coe CONFIG.Coefficient_Width {16} CONFIG.Quantization {Integer_Coefficients} CONFIG.Data_Width {24} CONFIG.Sample_Frequency {125} CONFIG.Clock_Frequency {200} CONFIG.Output_Rounding_Mode {Convergent_Rounding_to_Odd} CONFIG.Output_Width {16} CONFIG.Has_ARESETn {true} CONFIG.M_DATA_Has_TREADY {true} CONFIG.S_DATA_Has_TUSER {User_Field} CONFIG.M_DATA_Has_TUSER {User_Field} CONFIG.DATA_TUSER_Width {2}] [get_bd_cells $name]
}
create_bd_cell -type module -reference das_iq_join iq_align_0
create_bd_cell -type ip -vlnv xilinx.com:ip:cordic:6.0 cordic_amp_phase_0
set_property -dict [list CONFIG.Functional_Selection {Translate} CONFIG.Architectural_Configuration {Parallel} CONFIG.Input_Width {16} CONFIG.Output_Width {16} CONFIG.Phase_Format {Radians} CONFIG.Coarse_Rotation {true} CONFIG.Compensation_Scaling {Embedded_Multiplier} CONFIG.Round_Mode {Nearest_Even} CONFIG.flow_control {Blocking} CONFIG.out_tready {true} CONFIG.ARESETN {true} CONFIG.cartesian_has_tuser {true} CONFIG.cartesian_tuser_width {2}] [get_bd_cells cordic_amp_phase_0]
create_bd_cell -type module -reference das_trace_process dif_acc_phase_0
foreach c {phase_source_0 mult_iq_0 iq_align_0 dif_acc_phase_0} {wireup clk $c/clk; wireup reset_n $c/reset_n}
foreach c {dds_compiler_0 fir_compiler_i fir_compiler_q cordic_amp_phase_0} {wireup clk $c/aclk; wireup reset_n $c/aresetn}
foreach p {data user valid ready} {wireup adc_$p phase_source_0/adc_$p}
foreach p {data user valid ready} {wireup phase_source_0/phase_$p dds_compiler_0/s_axis_phase_t$p}
foreach p {data user valid ready} {wireup dds_compiler_0/m_axis_data_t$p mult_iq_0/lo_$p}
foreach leg {i q} {
 foreach p {data user valid ready} {wireup mult_iq_0/${leg}_$p fir_compiler_$leg/s_axis_data_t$p}
 foreach p {data user valid ready} {wireup fir_compiler_$leg/m_axis_data_t$p iq_align_0/${leg}_$p}
}
foreach p {data user valid ready} {wireup iq_align_0/cartesian_$p cordic_amp_phase_0/s_axis_cartesian_t$p}
wireup iq_align_0/alignment_error alignment_error
wireup cordic_amp_phase_0/m_axis_dout_tdata dif_acc_phase_0/amp_phase_data
foreach p {user valid ready} {wireup cordic_amp_phase_0/m_axis_dout_t$p dif_acc_phase_0/sample_$p}
wireup phase_start dif_acc_phase_0/phase_start_cfg
wireup input_fault dif_acc_phase_0/input_fault
foreach p {frame_data frame_valid frame_last frame_ready groups_completed banks_full format_error accumulator_clipped} {wireup dif_acc_phase_0/$p $p}
current_bd_instance /

create_bd_cell -type module -reference das_writer_packet das_writer_packet_0
wireup ddr4_0/c0_ddr4_ui_clk das_processing/clk das_writer_packet_0/clk
wireup rst_ddr/peripheral_aresetn das_processing/reset_n das_writer_packet_0/reset_n
foreach p {data user valid ready} {wireup axis_data_fifo_0/m_axis_t$p das_processing/adc_$p}
foreach p {data valid last ready} {wireup das_processing/frame_$p das_writer_packet_0/frame_$p}
foreach p {data valid last} {wireup das_writer_packet_0/writer_$p wr_addr_0/i_$p}
wireup das_writer_packet_0/writer_ready wr_addr_0/fifo_ready
wireup wr_addr_0/m00_axi_txn_done das_writer_packet_0/burst_done
wireup top_layer_0/adc_overflow das_processing/input_fault
set_property -dict [list CONFIG.C_NUM_PROBE_OUT {3} CONFIG.C_PROBE_OUT2_WIDTH {16} CONFIG.C_PROBE_OUT2_INIT_VAL {0x0000} CONFIG.C_NUM_PROBE_IN {11} CONFIG.C_PROBE_IN5_WIDTH {1} CONFIG.C_PROBE_IN6_WIDTH {1} CONFIG.C_PROBE_IN7_WIDTH {32} CONFIG.C_PROBE_IN8_WIDTH {32} CONFIG.C_PROBE_IN9_WIDTH {1} CONFIG.C_PROBE_IN10_WIDTH {1}] [get_bd_cells vio_readback]
wireup vio_readback/probe_out2 das_processing/phase_start
wireup das_processing/alignment_error vio_readback/probe_in5
wireup das_processing/format_error vio_readback/probe_in6
wireup das_processing/groups_completed vio_readback/probe_in7
wireup das_writer_packet_0/ddr_frames_done vio_readback/probe_in8
wireup das_processing/accumulator_clipped vio_readback/probe_in9
wireup das_writer_packet_0/framing_error vio_readback/probe_in10
create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_das
set_property -dict [list CONFIG.C_DATA_DEPTH {4096} CONFIG.C_NUM_OF_PROBES {8} CONFIG.C_PROBE0_WIDTH {32} CONFIG.C_PROBE1_WIDTH {1} CONFIG.C_PROBE2_WIDTH {1} CONFIG.C_PROBE3_WIDTH {1} CONFIG.C_PROBE4_WIDTH {32} CONFIG.C_PROBE5_WIDTH {32} CONFIG.C_PROBE6_WIDTH {2} CONFIG.C_PROBE7_WIDTH {1}] [get_bd_cells ila_das]
wireup ddr4_0/c0_ddr4_ui_clk ila_das/clk
wireup das_processing/frame_data ila_das/probe0
wireup das_processing/frame_valid ila_das/probe1
wireup das_processing/frame_ready ila_das/probe2
wireup das_processing/frame_last ila_das/probe3
wireup das_processing/groups_completed ila_das/probe4
wireup das_writer_packet_0/ddr_frames_done ila_das/probe5
wireup das_processing/banks_full ila_das/probe6
wireup das_processing/format_error ila_das/probe7
validate_bd_design -force
save_bd_design
generate_target all [get_files */xdma_pcie.bd]
make_wrapper -files [get_files */xdma_pcie.bd] -top
update_compile_order -fileset sources_1
write_bd_tcl -force $root/scripts/xdma_pcie_das_processing.tcl
puts DAS_TEMPLATE_BD_INTEGRATION_PASS
close_project
exit
