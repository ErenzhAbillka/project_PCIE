# MLK-H4 carrier schematic 20230323, page 12; CU01 KU060 FFVA1156.
# Old FMCADDA-9643-9122 SPI wiring (purchased before 2025-11-01).
# Carrier VCC_ADJ / banks 44 and 45 = 1.8 V.
set_property PACKAGE_PIN AJ21 [get_ports {adc_data_clk_p_0}]; # FMC D20/D21 LA17_CC P
set_property PACKAGE_PIN AK21 [get_ports {adc_data_clk_n_0}]; # FMC D20/D21 LA17_CC N
set_property PACKAGE_PIN AG19 [get_ports {data_pin_p_0[0]}]; # FMC LA20 P
set_property PACKAGE_PIN AH19 [get_ports {data_pin_n_0[0]}]; # FMC LA20 N
set_property PACKAGE_PIN AF22 [get_ports {data_pin_p_0[1]}]; # FMC LA19 P
set_property PACKAGE_PIN AG22 [get_ports {data_pin_n_0[1]}]; # FMC LA19 N
set_property PACKAGE_PIN AJ23 [get_ports {data_pin_p_0[2]}]; # FMC LA18 P
set_property PACKAGE_PIN AJ24 [get_ports {data_pin_n_0[2]}]; # FMC LA18 N
set_property PACKAGE_PIN AM21 [get_ports {data_pin_p_0[3]}]; # FMC LA23 P
set_property PACKAGE_PIN AN21 [get_ports {data_pin_n_0[3]}]; # FMC LA23 N
set_property PACKAGE_PIN AP20 [get_ports {data_pin_p_0[4]}]; # FMC LA22 P
set_property PACKAGE_PIN AP21 [get_ports {data_pin_n_0[4]}]; # FMC LA22 N
set_property PACKAGE_PIN AE25 [get_ports {data_pin_p_0[5]}]; # FMC LA27 P
set_property PACKAGE_PIN AE26 [get_ports {data_pin_n_0[5]}]; # FMC LA27 N
set_property PACKAGE_PIN AE22 [get_ports {data_pin_p_0[6]}]; # FMC LA21 P
set_property PACKAGE_PIN AE23 [get_ports {data_pin_n_0[6]}]; # FMC LA21 N
set_property PACKAGE_PIN AM22 [get_ports {data_pin_p_0[7]}]; # FMC LA26 P
set_property PACKAGE_PIN AN22 [get_ports {data_pin_n_0[7]}]; # FMC LA26 N
set_property PACKAGE_PIN AN23 [get_ports {data_pin_p_0[8]}]; # FMC LA25 P
set_property PACKAGE_PIN AP23 [get_ports {data_pin_n_0[8]}]; # FMC LA25 N
set_property PACKAGE_PIN AM24 [get_ports {data_pin_p_0[9]}]; # FMC LA24 P
set_property PACKAGE_PIN AN24 [get_ports {data_pin_n_0[9]}]; # FMC LA24 N
set_property PACKAGE_PIN AP24 [get_ports {data_pin_p_0[10]}]; # FMC LA29 P
set_property PACKAGE_PIN AP25 [get_ports {data_pin_n_0[10]}]; # FMC LA29 N
set_property PACKAGE_PIN AJ20 [get_ports {data_pin_p_0[11]}]; # FMC LA28 P
set_property PACKAGE_PIN AK20 [get_ports {data_pin_n_0[11]}]; # FMC LA28 N
set_property PACKAGE_PIN AG21 [get_ports {data_pin_p_0[12]}]; # FMC LA31 P
set_property PACKAGE_PIN AH21 [get_ports {data_pin_n_0[12]}]; # FMC LA31 N
set_property PACKAGE_PIN AF23 [get_ports {data_pin_p_0[13]}]; # FMC LA30 P
set_property PACKAGE_PIN AF24 [get_ports {data_pin_n_0[13]}]; # FMC LA30 N
set_property PACKAGE_PIN AG25 [get_ports {device_spi_sda}]; # FMC H38 LA32_N
set_property PACKAGE_PIN AJ25 [get_ports {device_spi_sclk}]; # FMC G37 LA33_N
set_property PACKAGE_PIN AG24 [get_ports {adc_spi_csb}]; # FMC H37 LA32_P
set_property PACKAGE_PIN AH18 [get_ports {adk_spi_csb}]; # FMC G6 LA00_P
set_property PACKAGE_PIN AH17 [get_ports {dac_spi_csb}]; # FMC G7 LA00_N
set_property PACKAGE_PIN AH24 [get_ports adc_sync]
set_property IOSTANDARD LVDS [get_ports {adc_data_clk_p_0 adc_data_clk_n_0 data_pin_p_0[*] data_pin_n_0[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_data_clk_p_0 data_pin_p_0[*]}]
set spi_ports [get_ports {device_spi_sda device_spi_sclk adc_spi_csb adk_spi_csb dac_spi_csb adc_sync}]
set_property IOSTANDARD LVCMOS18 $spi_ports
set_property SLEW SLOW $spi_ports
set_property DRIVE 8 $spi_ports
create_clock -name adc_dco -period 8.000 [get_ports adc_data_clk_p_0]
set_input_delay -clock adc_dco -min -1.100 [get_ports {data_pin_p_0[*]}]
set_input_delay -clock adc_dco -max -0.300 [get_ports {data_pin_p_0[*]}]
set_input_delay -clock adc_dco -clock_fall -min -add_delay -1.100 [get_ports {data_pin_p_0[*]}]
set_input_delay -clock adc_dco -clock_fall -max -add_delay -0.300 [get_ports {data_pin_p_0[*]}]
# Native XPM FIFO supplies its own gray-pointer max-delay and bus-skew rules.
# Do not cut the entire clock groups: that would mask the FIFO max-delay rules.
# Only the first stages of our single-bit control/status synchronizers are cut.
set adc_control_sync [get_pins -hier -regexp {.*(stream_source_inst/enable_sync_reg|overflow_sync_reg|active_sync_reg)\[0\]/D}]
set_false_path -to $adc_control_sync
# ADC continuity monitor: cut only the two independent single-bit CDC inputs.
set adc_monitor_sync [get_pins -hier -regexp {.*capture_monitor_inst/(heartbeat_sync_reg|sample_valid_sync_reg)\[0\]/D}]
set_false_path -to $adc_monitor_sync
# ADC diagnostic controls/handshake: cut only the three first-stage D inputs.
set adc_diagnostic_sync [get_pins -hier -regexp {.*(ramp_checker_inst/enable_sync_reg|test_snapshot_inst/request_sync_reg|test_snapshot_inst/ack_sync_reg)\[0\]/D}]
set_false_path -to $adc_diagnostic_sync
# Held snapshot bundle is stable through the synchronized acknowledgement.
# Earliest destination capture is >=15 ns after source hold; budget 10 ns.
set adc_snapshot_source [get_pins -hier -regexp {.*test_snapshot_inst/snapshot_data_reg\[[0-9]+\]/Q}]
set adc_snapshot_target [get_pins -hier -regexp {.*test_snapshot_inst/(error_reg|error_count_reg\[[0-9]+\]|checked_count_reg\[[0-9]+\])/D}]
set_max_delay -datapath_only 10.000 -from $adc_snapshot_source -to $adc_snapshot_target
# Async assertion / synchronous release chains; keep local lane reset recovery timed.
set adc_async_reset [get_pins -hier -regexp {.*(adc_driver_inst/(reset_sync_reg|valid_sync_reg)|fifo_reset_sync_reg|checker_reset_sync_reg)\[[0-9]+\]/(PRE|CLR)}]
set_false_path -to $adc_async_reset
# SPI outputs change on UI-clock edges, 500 ns away from SCLK sampling edges.
# These are slow board-management GPIO, not DDR sample data.
set_false_path -to $spi_ports
set_false_path -from [get_ports device_spi_sda]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
