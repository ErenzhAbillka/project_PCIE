# 差分引脚
set_property PACKAGE_PIN E22 [get_ports c0_sys_clk_p]
set_property PACKAGE_PIN E23 [get_ports c0_sys_clk_n]

set_property IOSTANDARD DIFF_SSTL12 \
    [get_ports {c0_sys_clk_p c0_sys_clk_n}]