# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADC_SETTLE_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADC_TEST_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AOM_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLOCK_SETTLE_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CTRL_CLK_HZ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_DELAY_TAPS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "POWERUP_DELAY_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SPI_CLK_HZ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TRACE_PERIOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TRACE_POINTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TX_SINE_MEM" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADC_SETTLE_CYCLES { PARAM_VALUE.ADC_SETTLE_CYCLES } {
	# Procedure called to update ADC_SETTLE_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_SETTLE_CYCLES { PARAM_VALUE.ADC_SETTLE_CYCLES } {
	# Procedure called to validate ADC_SETTLE_CYCLES
	return true
}

proc update_PARAM_VALUE.ADC_TEST_CYCLES { PARAM_VALUE.ADC_TEST_CYCLES } {
	# Procedure called to update ADC_TEST_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADC_TEST_CYCLES { PARAM_VALUE.ADC_TEST_CYCLES } {
	# Procedure called to validate ADC_TEST_CYCLES
	return true
}

proc update_PARAM_VALUE.AOM_WIDTH { PARAM_VALUE.AOM_WIDTH } {
	# Procedure called to update AOM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AOM_WIDTH { PARAM_VALUE.AOM_WIDTH } {
	# Procedure called to validate AOM_WIDTH
	return true
}

proc update_PARAM_VALUE.CLOCK_SETTLE_CYCLES { PARAM_VALUE.CLOCK_SETTLE_CYCLES } {
	# Procedure called to update CLOCK_SETTLE_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLOCK_SETTLE_CYCLES { PARAM_VALUE.CLOCK_SETTLE_CYCLES } {
	# Procedure called to validate CLOCK_SETTLE_CYCLES
	return true
}

proc update_PARAM_VALUE.CTRL_CLK_HZ { PARAM_VALUE.CTRL_CLK_HZ } {
	# Procedure called to update CTRL_CLK_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CTRL_CLK_HZ { PARAM_VALUE.CTRL_CLK_HZ } {
	# Procedure called to validate CTRL_CLK_HZ
	return true
}

proc update_PARAM_VALUE.INPUT_DELAY_TAPS { PARAM_VALUE.INPUT_DELAY_TAPS } {
	# Procedure called to update INPUT_DELAY_TAPS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_DELAY_TAPS { PARAM_VALUE.INPUT_DELAY_TAPS } {
	# Procedure called to validate INPUT_DELAY_TAPS
	return true
}

proc update_PARAM_VALUE.POWERUP_DELAY_CYCLES { PARAM_VALUE.POWERUP_DELAY_CYCLES } {
	# Procedure called to update POWERUP_DELAY_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POWERUP_DELAY_CYCLES { PARAM_VALUE.POWERUP_DELAY_CYCLES } {
	# Procedure called to validate POWERUP_DELAY_CYCLES
	return true
}

proc update_PARAM_VALUE.SPI_CLK_HZ { PARAM_VALUE.SPI_CLK_HZ } {
	# Procedure called to update SPI_CLK_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SPI_CLK_HZ { PARAM_VALUE.SPI_CLK_HZ } {
	# Procedure called to validate SPI_CLK_HZ
	return true
}

proc update_PARAM_VALUE.TRACE_PERIOD { PARAM_VALUE.TRACE_PERIOD } {
	# Procedure called to update TRACE_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRACE_PERIOD { PARAM_VALUE.TRACE_PERIOD } {
	# Procedure called to validate TRACE_PERIOD
	return true
}

proc update_PARAM_VALUE.TRACE_POINTS { PARAM_VALUE.TRACE_POINTS } {
	# Procedure called to update TRACE_POINTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRACE_POINTS { PARAM_VALUE.TRACE_POINTS } {
	# Procedure called to validate TRACE_POINTS
	return true
}

proc update_PARAM_VALUE.TX_SINE_MEM { PARAM_VALUE.TX_SINE_MEM } {
	# Procedure called to update TX_SINE_MEM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TX_SINE_MEM { PARAM_VALUE.TX_SINE_MEM } {
	# Procedure called to validate TX_SINE_MEM
	return true
}


proc update_MODELPARAM_VALUE.CTRL_CLK_HZ { MODELPARAM_VALUE.CTRL_CLK_HZ PARAM_VALUE.CTRL_CLK_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CTRL_CLK_HZ}] ${MODELPARAM_VALUE.CTRL_CLK_HZ}
}

proc update_MODELPARAM_VALUE.SPI_CLK_HZ { MODELPARAM_VALUE.SPI_CLK_HZ PARAM_VALUE.SPI_CLK_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SPI_CLK_HZ}] ${MODELPARAM_VALUE.SPI_CLK_HZ}
}

proc update_MODELPARAM_VALUE.POWERUP_DELAY_CYCLES { MODELPARAM_VALUE.POWERUP_DELAY_CYCLES PARAM_VALUE.POWERUP_DELAY_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POWERUP_DELAY_CYCLES}] ${MODELPARAM_VALUE.POWERUP_DELAY_CYCLES}
}

proc update_MODELPARAM_VALUE.CLOCK_SETTLE_CYCLES { MODELPARAM_VALUE.CLOCK_SETTLE_CYCLES PARAM_VALUE.CLOCK_SETTLE_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLOCK_SETTLE_CYCLES}] ${MODELPARAM_VALUE.CLOCK_SETTLE_CYCLES}
}

proc update_MODELPARAM_VALUE.ADC_TEST_CYCLES { MODELPARAM_VALUE.ADC_TEST_CYCLES PARAM_VALUE.ADC_TEST_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_TEST_CYCLES}] ${MODELPARAM_VALUE.ADC_TEST_CYCLES}
}

proc update_MODELPARAM_VALUE.ADC_SETTLE_CYCLES { MODELPARAM_VALUE.ADC_SETTLE_CYCLES PARAM_VALUE.ADC_SETTLE_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADC_SETTLE_CYCLES}] ${MODELPARAM_VALUE.ADC_SETTLE_CYCLES}
}

proc update_MODELPARAM_VALUE.INPUT_DELAY_TAPS { MODELPARAM_VALUE.INPUT_DELAY_TAPS PARAM_VALUE.INPUT_DELAY_TAPS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_DELAY_TAPS}] ${MODELPARAM_VALUE.INPUT_DELAY_TAPS}
}

proc update_MODELPARAM_VALUE.TRACE_PERIOD { MODELPARAM_VALUE.TRACE_PERIOD PARAM_VALUE.TRACE_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRACE_PERIOD}] ${MODELPARAM_VALUE.TRACE_PERIOD}
}

proc update_MODELPARAM_VALUE.TRACE_POINTS { MODELPARAM_VALUE.TRACE_POINTS PARAM_VALUE.TRACE_POINTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRACE_POINTS}] ${MODELPARAM_VALUE.TRACE_POINTS}
}

proc update_MODELPARAM_VALUE.AOM_WIDTH { MODELPARAM_VALUE.AOM_WIDTH PARAM_VALUE.AOM_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AOM_WIDTH}] ${MODELPARAM_VALUE.AOM_WIDTH}
}

proc update_MODELPARAM_VALUE.TX_SINE_MEM { MODELPARAM_VALUE.TX_SINE_MEM PARAM_VALUE.TX_SINE_MEM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TX_SINE_MEM}] ${MODELPARAM_VALUE.TX_SINE_MEM}
}

