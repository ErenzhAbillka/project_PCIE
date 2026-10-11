# Source with a synthesized/implemented design open. Check actual report_io.
set actual_pins [dict create]
foreach line [split [report_io -return_string] "\n"] {
 set fields [split $line |]
 if {[llength $fields] > 3} {
  dict set actual_pins [string trim [lindex $fields 2]] [string trim [lindex $fields 1]]
 }
}
foreach {bus pins} {
 pcie_7x_mgt_rtl_0_rxp {F2 H2 K2 M2 P2 T2 V2 Y2}
 pcie_7x_mgt_rtl_0_rxn {F1 H1 K1 M1 P1 T1 V1 Y1}
 pcie_7x_mgt_rtl_0_txp {G4 J4 L4 N4 R4 U4 W4 AA4}
 pcie_7x_mgt_rtl_0_txn {G3 J3 L3 N3 R3 U3 W3 AA3}
} {
 set lane 0
 foreach pin $pins {
  set port [format {%s[%d]} $bus $lane]
  if {![dict exists $actual_pins $port] || [dict get $actual_pins $port] ne $pin} {error "Physical pin mismatch: $port expected $pin"}
  incr lane
 }
}
foreach {port pin} {diff_clock_rtl_0_clk_p[0] P6 diff_clock_rtl_0_clk_n[0] P5 reset_rtl_0 K22 C0_SYS_CLK_0_clk_p E22 C0_SYS_CLK_0_clk_n E23} {
 if {![dict exists $actual_pins $port] || [dict get $actual_pins $port] ne $pin} {error "Physical pin mismatch: $port expected $pin"}
}
puts "PCIE_PHYSICAL_PIN_CHECK_PASS"
foreach p [get_ports] {
 set expected [get_property PACKAGE_PIN $p]
 if {$expected eq "" || ![dict exists $actual_pins $p] || [dict get $actual_pins $p] ne $expected} {
  error "Top-level physical pin mismatch: $p expected $expected"
 }
}
puts "ALL_PHYSICAL_PINS_PASS: [llength [get_ports]] ports"
