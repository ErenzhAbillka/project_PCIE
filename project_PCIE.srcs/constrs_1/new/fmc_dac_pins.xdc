# MLK-H4 20230323 carrier schematic p12 + old FMCADDA-9643-9122 p7-8.
# Banks 44/45 VCC_ADJ=1.8 V. Match physical FMC contacts, not direction aliases.
set_property PACKAGE_PIN AH16 [get_ports {dac_data_p[0]}]
set_property PACKAGE_PIN AJ16 [get_ports {dac_data_n[0]}]
set_property PACKAGE_PIN AG17 [get_ports {dac_data_p[1]}]
set_property PACKAGE_PIN AG16 [get_ports {dac_data_n[1]}]
set_property PACKAGE_PIN AL19 [get_ports {dac_data_p[2]}]
set_property PACKAGE_PIN AM19 [get_ports {dac_data_n[2]}]
set_property PACKAGE_PIN AD20 [get_ports {dac_data_p[3]}]
set_property PACKAGE_PIN AE20 [get_ports {dac_data_n[3]}]
set_property PACKAGE_PIN AM17 [get_ports {dac_data_p[4]}]
set_property PACKAGE_PIN AN16 [get_ports {dac_data_n[4]}]
set_property PACKAGE_PIN AN19 [get_ports {dac_data_p[5]}]
set_property PACKAGE_PIN AP18 [get_ports {dac_data_n[5]}]
set_property PACKAGE_PIN AL24 [get_ports {dac_data_p[6]}]
set_property PACKAGE_PIN AL25 [get_ports {dac_data_n[6]}]
set_property PACKAGE_PIN AK22 [get_ports {dac_data_p[7]}]
set_property PACKAGE_PIN AK23 [get_ports {dac_data_n[7]}]
set_property PACKAGE_PIN AF20 [get_ports {dac_data_p[8]}]
set_property PACKAGE_PIN AG20 [get_ports {dac_data_n[8]}]
set_property PACKAGE_PIN AF15 [get_ports {dac_data_p[9]}]
set_property PACKAGE_PIN AF14 [get_ports {dac_data_n[9]}]
set_property PACKAGE_PIN AP16 [get_ports {dac_data_p[10]}]
set_property PACKAGE_PIN AP15 [get_ports {dac_data_n[10]}]
set_property PACKAGE_PIN AE18 [get_ports {dac_data_p[11]}]
set_property PACKAGE_PIN AF18 [get_ports {dac_data_n[11]}]
set_property PACKAGE_PIN AL22 [get_ports {dac_data_p[12]}]
set_property PACKAGE_PIN AL23 [get_ports {dac_data_n[12]}]
set_property PACKAGE_PIN AL20 [get_ports {dac_data_p[13]}]
set_property PACKAGE_PIN AM20 [get_ports {dac_data_n[13]}]
set_property PACKAGE_PIN AJ18 [get_ports {dac_data_p[14]}]
set_property PACKAGE_PIN AK18 [get_ports {dac_data_n[14]}]
set_property PACKAGE_PIN AD19 [get_ports {dac_data_p[15]}]
set_property PACKAGE_PIN AD18 [get_ports {dac_data_n[15]}]
set_property PACKAGE_PIN AK17 [get_ports dac_dci_p]
set_property PACKAGE_PIN AK16 [get_ports dac_dci_n]
set_property PACKAGE_PIN AH22 [get_ports dac_frame_p]
set_property PACKAGE_PIN AH23 [get_ports dac_frame_n]
set_property IOSTANDARD LVDS [get_ports {dac_data_p[*] dac_data_n[*] dac_dci_p dac_dci_n dac_frame_p dac_frame_n}]

# Forwarded DCI uses CLKOUT1 from the same ADC MMCM, 90 degrees after the
# CLKOUT0 data clock. I is sampled at DCI rising; Q at DCI falling.
# Use the BUFG output so this survives ODDRE1 -> OSERDESE3 synthesis mapping.
set dac_forward_pin [get_pins -hier -regexp {.*adc_driver_inst/dac_forward_bufg/O}]
create_generated_clock -name dac_dci_out -source $dac_forward_pin -divide_by 1 [get_ports dac_dci_p]
# AD9122 RevB table13 worst of R1/R2: setup=-0.05 ns, hold=1.22 ns.
# Design budget (NOT measured): 0.25 ns board data/clock skew + 0.10 ns margin.
# Verify board skew, placement/routing and eye before claiming interface closure.
set dac_data_ports [get_ports {dac_data_p[*] dac_data_n[*]}]
set_output_delay -clock dac_dci_out -max 0.300 $dac_data_ports
set_output_delay -clock dac_dci_out -min -1.570 $dac_data_ports
set_output_delay -clock dac_dci_out -clock_fall -max 0.300 -add_delay $dac_data_ports
set_output_delay -clock dac_dci_out -clock_fall -min -1.570 -add_delay $dac_data_ports
# FRAME is tied low; SPI FIFO alignment is used instead of a FRAME transition.
set_false_path -to [get_ports {dac_frame_p dac_frame_n}]
# Independent single-bit controls/status only; do not cut sample-data clocks.
set dac_control_sync [get_pins -hier -regexp {.*(tx_adc_valid_sync_reg|tx_arm_sync_reg|tx_kill_sync_reg|tx_ready_ctrl_sync_reg|tx_started_ctrl_sync_reg|tx_done_ctrl_sync_reg)\[0\]/D}]
set_false_path -to $dac_control_sync
set dac_async_reset [get_pins -hier -regexp {.*(tx_arm_sync_reg|tx_kill_sync_reg|tx_frontend_inst/ready_sync_reg)\[[01]\]/(CLR|PRE)}]
set_false_path -to $dac_async_reset
