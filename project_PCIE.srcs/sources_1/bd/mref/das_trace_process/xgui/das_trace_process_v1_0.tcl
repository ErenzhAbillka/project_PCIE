# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ACC_SHIFT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_WORDS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "GROUP_TRACES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IF_HZ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PHASE_POINTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SAMPLE_RATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TRACE_PERIOD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TRACE_POINTS" -parent ${Page_0}


}

proc update_PARAM_VALUE.ACC_SHIFT { PARAM_VALUE.ACC_SHIFT } {
	# Procedure called to update ACC_SHIFT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ACC_SHIFT { PARAM_VALUE.ACC_SHIFT } {
	# Procedure called to validate ACC_SHIFT
	return true
}

proc update_PARAM_VALUE.FRAME_WORDS { PARAM_VALUE.FRAME_WORDS } {
	# Procedure called to update FRAME_WORDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_WORDS { PARAM_VALUE.FRAME_WORDS } {
	# Procedure called to validate FRAME_WORDS
	return true
}

proc update_PARAM_VALUE.GROUP_TRACES { PARAM_VALUE.GROUP_TRACES } {
	# Procedure called to update GROUP_TRACES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GROUP_TRACES { PARAM_VALUE.GROUP_TRACES } {
	# Procedure called to validate GROUP_TRACES
	return true
}

proc update_PARAM_VALUE.IF_HZ { PARAM_VALUE.IF_HZ } {
	# Procedure called to update IF_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IF_HZ { PARAM_VALUE.IF_HZ } {
	# Procedure called to validate IF_HZ
	return true
}

proc update_PARAM_VALUE.PHASE_POINTS { PARAM_VALUE.PHASE_POINTS } {
	# Procedure called to update PHASE_POINTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PHASE_POINTS { PARAM_VALUE.PHASE_POINTS } {
	# Procedure called to validate PHASE_POINTS
	return true
}

proc update_PARAM_VALUE.SAMPLE_RATE { PARAM_VALUE.SAMPLE_RATE } {
	# Procedure called to update SAMPLE_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAMPLE_RATE { PARAM_VALUE.SAMPLE_RATE } {
	# Procedure called to validate SAMPLE_RATE
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


proc update_MODELPARAM_VALUE.TRACE_POINTS { MODELPARAM_VALUE.TRACE_POINTS PARAM_VALUE.TRACE_POINTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRACE_POINTS}] ${MODELPARAM_VALUE.TRACE_POINTS}
}

proc update_MODELPARAM_VALUE.GROUP_TRACES { MODELPARAM_VALUE.GROUP_TRACES PARAM_VALUE.GROUP_TRACES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GROUP_TRACES}] ${MODELPARAM_VALUE.GROUP_TRACES}
}

proc update_MODELPARAM_VALUE.PHASE_POINTS { MODELPARAM_VALUE.PHASE_POINTS PARAM_VALUE.PHASE_POINTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PHASE_POINTS}] ${MODELPARAM_VALUE.PHASE_POINTS}
}

proc update_MODELPARAM_VALUE.FRAME_WORDS { MODELPARAM_VALUE.FRAME_WORDS PARAM_VALUE.FRAME_WORDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_WORDS}] ${MODELPARAM_VALUE.FRAME_WORDS}
}

proc update_MODELPARAM_VALUE.ACC_SHIFT { MODELPARAM_VALUE.ACC_SHIFT PARAM_VALUE.ACC_SHIFT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ACC_SHIFT}] ${MODELPARAM_VALUE.ACC_SHIFT}
}

proc update_MODELPARAM_VALUE.SAMPLE_RATE { MODELPARAM_VALUE.SAMPLE_RATE PARAM_VALUE.SAMPLE_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAMPLE_RATE}] ${MODELPARAM_VALUE.SAMPLE_RATE}
}

proc update_MODELPARAM_VALUE.TRACE_PERIOD { MODELPARAM_VALUE.TRACE_PERIOD PARAM_VALUE.TRACE_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRACE_PERIOD}] ${MODELPARAM_VALUE.TRACE_PERIOD}
}

proc update_MODELPARAM_VALUE.IF_HZ { MODELPARAM_VALUE.IF_HZ PARAM_VALUE.IF_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IF_HZ}] ${MODELPARAM_VALUE.IF_HZ}
}

