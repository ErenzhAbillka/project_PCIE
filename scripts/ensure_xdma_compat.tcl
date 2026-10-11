# The installed legacy XDMA driver requires user BAR0 and control BAR1.
# Keep the ADC/RAW/TX and DDR paths intact; terminate user accesses in BRAM.
set_property -dict [list CONFIG.axilite_master_en true \
    CONFIG.axilite_master_scale Kilobytes CONFIG.axilite_master_size 32] [get_bd_cells xdma_0]

set compat_ctrl [get_bd_cells -quiet compat_bram_ctrl]
set compat_mem [get_bd_cells -quiet compat_bram]
if {![llength $compat_ctrl] && ![llength $compat_mem]} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 compat_bram_ctrl
    set_property -dict [list CONFIG.PROTOCOL AXI4LITE CONFIG.DATA_WIDTH 32 \
        CONFIG.SINGLE_PORT_BRAM 1] [get_bd_cells compat_bram_ctrl]
    create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 compat_bram
    set_property -dict [list CONFIG.Memory_Type Single_Port_RAM \
        CONFIG.Use_Byte_Write_Enable true CONFIG.Byte_Size 8 \
        CONFIG.EN_SAFETY_CKT false] [get_bd_cells compat_bram]
    connect_bd_intf_net [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins compat_bram_ctrl/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins compat_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins compat_bram/BRAM_PORTA]
    connect_bd_net [get_bd_pins xdma_0/axi_aclk] [get_bd_pins compat_bram_ctrl/s_axi_aclk]
    connect_bd_net [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins compat_bram_ctrl/s_axi_aresetn]
    create_bd_addr_seg -range 32K -offset 0 [get_bd_addr_spaces xdma_0/M_AXI_LITE] \
        [get_bd_addr_segs compat_bram_ctrl/S_AXI/Mem0] SEG_compat_bram
} elseif {![llength $compat_ctrl] || ![llength $compat_mem]} {
    error "Incomplete XDMA compatibility BRAM: restore both cells before building"
}
