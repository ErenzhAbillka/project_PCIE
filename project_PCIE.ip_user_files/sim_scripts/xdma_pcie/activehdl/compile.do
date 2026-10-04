vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/microblaze_v11_0_0
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/proc_sys_reset_v5_0_13
vlib activehdl/lmb_v10_v3_0_9
vlib activehdl/lmb_bram_if_cntlr_v4_0_15
vlib activehdl/blk_mem_gen_v8_4_2
vlib activehdl/iomodule_v3_1_4
vlib activehdl/gtwizard_ultrascale_v1_7_5
vlib activehdl/xdma_v4_1_2

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap microblaze_v11_0_0 activehdl/microblaze_v11_0_0
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13
vmap lmb_v10_v3_0_9 activehdl/lmb_v10_v3_0_9
vmap lmb_bram_if_cntlr_v4_0_15 activehdl/lmb_bram_if_cntlr_v4_0_15
vmap blk_mem_gen_v8_4_2 activehdl/blk_mem_gen_v8_4_2
vmap iomodule_v3_1_4 activehdl/iomodule_v3_1_4
vmap gtwizard_ultrascale_v1_7_5 activehdl/gtwizard_ultrascale_v1_7_5
vmap xdma_v4_1_2 activehdl/xdma_v4_1_2

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"D:/Xilinxx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinxx/Vivado/2018.3/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Xilinxx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Xilinxx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work microblaze_v11_0_0 -93 \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/2ed1/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_0/sim/bd_8c6a_microblaze_I_0.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_1/sim/bd_8c6a_rst_0_0.vhd" \

vcom -work lmb_v10_v3_0_9 -93 \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/78eb/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_2/sim/bd_8c6a_ilmb_0.vhd" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_3/sim/bd_8c6a_dlmb_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_15 -93 \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/92fd/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_4/sim/bd_8c6a_dlmb_cntlr_0.vhd" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_5/sim/bd_8c6a_ilmb_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_2  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/37c2/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_6/sim/bd_8c6a_lmb_bram_I_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_7/sim/bd_8c6a_second_dlmb_cntlr_0.vhd" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_8/sim/bd_8c6a_second_ilmb_cntlr_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_9/sim/bd_8c6a_second_lmb_bram_I_0.v" \

vcom -work iomodule_v3_1_4 -93 \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/18fc/hdl/iomodule_v3_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/ip/ip_10/sim/bd_8c6a_iomodule_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/bd_0/sim/bd_8c6a.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_0/sim/xdma_pcie_ddr4_0_2_microblaze_mcs.v" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/phy/xdma_pcie_ddr4_0_2_phy_ddr4.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/ip_top/xdma_pcie_ddr4_0_2_phy.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_wtr.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ref.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_rd_wr.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_periodic.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_group.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ecc.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_ctl.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_arb_p.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_arb_c.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_arb_a.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_act_timer.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc_act_rank.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/controller/ddr4_v2_2_mc.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ui/ddr4_v2_2_ui_wr_data.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ui/ddr4_v2_2_ui_rd_data.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ui/ddr4_v2_2_ui_cmd.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ui/ddr4_v2_2_ui.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_ar_channel.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_aw_channel.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_b_channel.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_cmd_arbiter.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_cmd_fsm.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_cmd_translator.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_fifo.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_incr_cmd.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_r_channel.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_w_channel.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_wr_cmd_fsm.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_wrap_cmd.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_a_upsizer.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_register_slice.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axi_upsizer.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_axic_register_slice.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_carry_and.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_carry_latch_and.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_carry_latch_or.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_carry_or.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_command_fifo.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_comparator.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_comparator_sel.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_comparator_sel_static.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_r_upsizer.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi/ddr4_v2_2_w_upsizer.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_addr_decode.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_read.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg_bank.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_top.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_write.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_write.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_sync.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_read.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_pi.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_top.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_cal.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top/xdma_pcie_ddr4_0_2.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top/xdma_pcie_ddr4_0_2_ddr4.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top/xdma_pcie_ddr4_0_2_ddr4_mem_intfc.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal/xdma_pcie_ddr4_0_2_ddr4_cal_riu.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/tb/microblaze_mcs_0.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/sim/xdma_pcie.v" \

vlog -work gtwizard_ultrascale_v1_7_5  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_bit_sync.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gte4_drp_arb.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_reset.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_reset_sync.v" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/fdd8/hdl/gtwizard_ultrascale_v1_7_reset_inv_sync.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/gtwizard_ultrascale_v1_7_gthe3_channel.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/xdma_pcie_xdma_0_0_pcie3_ip_gt_gthe3_channel_wrapper.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/gtwizard_ultrascale_v1_7_gthe3_common.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/xdma_pcie_xdma_0_0_pcie3_ip_gt_gthe3_common_wrapper.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/xdma_pcie_xdma_0_0_pcie3_ip_gt_gtwizard_gthe3.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/xdma_pcie_xdma_0_0_pcie3_ip_gt_gtwizard_top.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/ip_0/sim/xdma_pcie_xdma_0_0_pcie3_ip_gt.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_tph_tbl.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_pipe_lane.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_16k.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_rep_8k.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_req_8k.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_gt_channel.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_pipe_pipeline.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_pipe_misc.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_init_ctrl.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_gt_common.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_8k.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_rep.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_req.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_sync.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram_cpl.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_sys_clk_gen.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_rst.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_txeq.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_clk.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_bram.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_rxeq.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_gtwizard_top.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_wrapper.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_pcie3_uscale_wrapper.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_pcie3_uscale_top.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_phy_sync_cell.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_rxcdrhold.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/source/xdma_pcie_xdma_0_0_pcie3_ip_pcie3_uscale_core_top.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_0/sim/xdma_pcie_xdma_0_0_pcie3_ip.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_1/sim/xdma_v4_1_2_blk_mem_64_reg_be.v" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/ip_2/sim/xdma_v4_1_2_blk_mem_64_noreg_be.v" \

vlog -work xdma_v4_1_2  -sv2k12 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/xdma_v4_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/xdma_v4_1/hdl/verilog/xdma_pcie_xdma_0_0_dma_bram_wrap.sv" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/xdma_v4_1/hdl/verilog/xdma_pcie_xdma_0_0_core_top.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ipshared/54bd/hdl/verilog" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/ip_top" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/rtl/cal" "+incdir+../../../../project_PCIE.srcs/sources_1/bd/xdma_pcie/ip/xdma_pcie_ddr4_0_2/ip_1/rtl/map" \
"../../../bd/xdma_pcie/ip/xdma_pcie_xdma_0_0/sim/xdma_pcie_xdma_0_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/xdma_pcie/ip/xdma_pcie_util_ds_buf_0/util_ds_buf.vhd" \
"../../../bd/xdma_pcie/ip/xdma_pcie_util_ds_buf_0/sim/xdma_pcie_util_ds_buf_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

