//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Sun Oct  4 16:03:09 2026
//Host        : WIN-76HS90OBB7Q running 64-bit major release  (build 9200)
//Command     : generate_target xdma_pcie_wrapper.bd
//Design      : xdma_pcie_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module xdma_pcie_wrapper
   (C0_DDR4_0_act_n,
    C0_DDR4_0_adr,
    C0_DDR4_0_ba,
    C0_DDR4_0_bg,
    C0_DDR4_0_ck_c,
    C0_DDR4_0_ck_t,
    C0_DDR4_0_cke,
    C0_DDR4_0_cs_n,
    C0_DDR4_0_dm_n,
    C0_DDR4_0_dq,
    C0_DDR4_0_dqs_c,
    C0_DDR4_0_dqs_t,
    C0_DDR4_0_odt,
    C0_DDR4_0_reset_n,
    C0_SYS_CLK_0_clk_n,
    C0_SYS_CLK_0_clk_p,
    adc_data_clk_n_0,
    adc_data_clk_p_0,
    adc_spi_csb,
    adc_sync,
    adk_spi_csb,
    dac_spi_csb,
    data_pin_n_0,
    data_pin_p_0,
    device_spi_sclk,
    device_spi_sda,
    diff_clock_rtl_0_clk_n,
    diff_clock_rtl_0_clk_p,
    pcie_7x_mgt_rtl_0_rxn,
    pcie_7x_mgt_rtl_0_rxp,
    pcie_7x_mgt_rtl_0_txn,
    pcie_7x_mgt_rtl_0_txp,
    reset_rtl_0);
  output C0_DDR4_0_act_n;
  output [16:0]C0_DDR4_0_adr;
  output [1:0]C0_DDR4_0_ba;
  output [0:0]C0_DDR4_0_bg;
  output [0:0]C0_DDR4_0_ck_c;
  output [0:0]C0_DDR4_0_ck_t;
  output [0:0]C0_DDR4_0_cke;
  output [0:0]C0_DDR4_0_cs_n;
  inout [7:0]C0_DDR4_0_dm_n;
  inout [63:0]C0_DDR4_0_dq;
  inout [7:0]C0_DDR4_0_dqs_c;
  inout [7:0]C0_DDR4_0_dqs_t;
  output [0:0]C0_DDR4_0_odt;
  output C0_DDR4_0_reset_n;
  input C0_SYS_CLK_0_clk_n;
  input C0_SYS_CLK_0_clk_p;
  input adc_data_clk_n_0;
  input adc_data_clk_p_0;
  output adc_spi_csb;
  output adc_sync;
  output adk_spi_csb;
  output dac_spi_csb;
  input [13:0]data_pin_n_0;
  input [13:0]data_pin_p_0;
  output device_spi_sclk;
  inout device_spi_sda;
  input [0:0]diff_clock_rtl_0_clk_n;
  input [0:0]diff_clock_rtl_0_clk_p;
  input [7:0]pcie_7x_mgt_rtl_0_rxn;
  input [7:0]pcie_7x_mgt_rtl_0_rxp;
  output [7:0]pcie_7x_mgt_rtl_0_txn;
  output [7:0]pcie_7x_mgt_rtl_0_txp;
  input reset_rtl_0;

  wire C0_DDR4_0_act_n;
  wire [16:0]C0_DDR4_0_adr;
  wire [1:0]C0_DDR4_0_ba;
  wire [0:0]C0_DDR4_0_bg;
  wire [0:0]C0_DDR4_0_ck_c;
  wire [0:0]C0_DDR4_0_ck_t;
  wire [0:0]C0_DDR4_0_cke;
  wire [0:0]C0_DDR4_0_cs_n;
  wire [7:0]C0_DDR4_0_dm_n;
  wire [63:0]C0_DDR4_0_dq;
  wire [7:0]C0_DDR4_0_dqs_c;
  wire [7:0]C0_DDR4_0_dqs_t;
  wire [0:0]C0_DDR4_0_odt;
  wire C0_DDR4_0_reset_n;
  wire C0_SYS_CLK_0_clk_n;
  wire C0_SYS_CLK_0_clk_p;
  wire adc_data_clk_n_0;
  wire adc_data_clk_p_0;
  wire adc_spi_csb;
  wire adc_sync;
  wire adk_spi_csb;
  wire dac_spi_csb;
  wire [13:0]data_pin_n_0;
  wire [13:0]data_pin_p_0;
  wire device_spi_sclk;
  wire device_spi_sda;
  wire [0:0]diff_clock_rtl_0_clk_n;
  wire [0:0]diff_clock_rtl_0_clk_p;
  wire [7:0]pcie_7x_mgt_rtl_0_rxn;
  wire [7:0]pcie_7x_mgt_rtl_0_rxp;
  wire [7:0]pcie_7x_mgt_rtl_0_txn;
  wire [7:0]pcie_7x_mgt_rtl_0_txp;
  wire reset_rtl_0;

  xdma_pcie xdma_pcie_i
       (.C0_DDR4_0_act_n(C0_DDR4_0_act_n),
        .C0_DDR4_0_adr(C0_DDR4_0_adr),
        .C0_DDR4_0_ba(C0_DDR4_0_ba),
        .C0_DDR4_0_bg(C0_DDR4_0_bg),
        .C0_DDR4_0_ck_c(C0_DDR4_0_ck_c),
        .C0_DDR4_0_ck_t(C0_DDR4_0_ck_t),
        .C0_DDR4_0_cke(C0_DDR4_0_cke),
        .C0_DDR4_0_cs_n(C0_DDR4_0_cs_n),
        .C0_DDR4_0_dm_n(C0_DDR4_0_dm_n),
        .C0_DDR4_0_dq(C0_DDR4_0_dq),
        .C0_DDR4_0_dqs_c(C0_DDR4_0_dqs_c),
        .C0_DDR4_0_dqs_t(C0_DDR4_0_dqs_t),
        .C0_DDR4_0_odt(C0_DDR4_0_odt),
        .C0_DDR4_0_reset_n(C0_DDR4_0_reset_n),
        .C0_SYS_CLK_0_clk_n(C0_SYS_CLK_0_clk_n),
        .C0_SYS_CLK_0_clk_p(C0_SYS_CLK_0_clk_p),
        .adc_data_clk_n_0(adc_data_clk_n_0),
        .adc_data_clk_p_0(adc_data_clk_p_0),
        .adc_spi_csb(adc_spi_csb),
        .adc_sync(adc_sync),
        .adk_spi_csb(adk_spi_csb),
        .dac_spi_csb(dac_spi_csb),
        .data_pin_n_0(data_pin_n_0),
        .data_pin_p_0(data_pin_p_0),
        .device_spi_sclk(device_spi_sclk),
        .device_spi_sda(device_spi_sda),
        .diff_clock_rtl_0_clk_n(diff_clock_rtl_0_clk_n),
        .diff_clock_rtl_0_clk_p(diff_clock_rtl_0_clk_p),
        .pcie_7x_mgt_rtl_0_rxn(pcie_7x_mgt_rtl_0_rxn),
        .pcie_7x_mgt_rtl_0_rxp(pcie_7x_mgt_rtl_0_rxp),
        .pcie_7x_mgt_rtl_0_txn(pcie_7x_mgt_rtl_0_txn),
        .pcie_7x_mgt_rtl_0_txp(pcie_7x_mgt_rtl_0_txp),
        .reset_rtl_0(reset_rtl_0));
endmodule
