# aclk {FREQ_HZ 200000000 CLK_DOMAIN xdma_pcie_ddr4_0_2_c0_ddr4_ui_clk PHASE 0.00} aclk1 {FREQ_HZ 125000000 CLK_DOMAIN xdma_pcie_xdma_0_0_axi_aclk PHASE 0.000}
# Clock Domain: xdma_pcie_ddr4_0_2_c0_ddr4_ui_clk
create_clock -name aclk -period 5.000 [get_ports aclk]
# Clock Domain: xdma_pcie_xdma_0_0_axi_aclk
create_clock -name aclk1 -period 8.000 [get_ports aclk1]
# Generated clocks
