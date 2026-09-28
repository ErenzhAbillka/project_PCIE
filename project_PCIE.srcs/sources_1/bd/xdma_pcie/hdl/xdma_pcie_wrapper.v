//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Mon Sep 28 17:36:39 2026
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
    C0_DDR4_S_AXI_0_araddr,
    C0_DDR4_S_AXI_0_arburst,
    C0_DDR4_S_AXI_0_arcache,
    C0_DDR4_S_AXI_0_arid,
    C0_DDR4_S_AXI_0_arlen,
    C0_DDR4_S_AXI_0_arlock,
    C0_DDR4_S_AXI_0_arprot,
    C0_DDR4_S_AXI_0_arqos,
    C0_DDR4_S_AXI_0_arready,
    C0_DDR4_S_AXI_0_arsize,
    C0_DDR4_S_AXI_0_arvalid,
    C0_DDR4_S_AXI_0_awaddr,
    C0_DDR4_S_AXI_0_awburst,
    C0_DDR4_S_AXI_0_awcache,
    C0_DDR4_S_AXI_0_awid,
    C0_DDR4_S_AXI_0_awlen,
    C0_DDR4_S_AXI_0_awlock,
    C0_DDR4_S_AXI_0_awprot,
    C0_DDR4_S_AXI_0_awqos,
    C0_DDR4_S_AXI_0_awready,
    C0_DDR4_S_AXI_0_awsize,
    C0_DDR4_S_AXI_0_awvalid,
    C0_DDR4_S_AXI_0_bid,
    C0_DDR4_S_AXI_0_bready,
    C0_DDR4_S_AXI_0_bresp,
    C0_DDR4_S_AXI_0_bvalid,
    C0_DDR4_S_AXI_0_rdata,
    C0_DDR4_S_AXI_0_rid,
    C0_DDR4_S_AXI_0_rlast,
    C0_DDR4_S_AXI_0_rready,
    C0_DDR4_S_AXI_0_rresp,
    C0_DDR4_S_AXI_0_rvalid,
    C0_DDR4_S_AXI_0_wdata,
    C0_DDR4_S_AXI_0_wlast,
    C0_DDR4_S_AXI_0_wready,
    C0_DDR4_S_AXI_0_wstrb,
    C0_DDR4_S_AXI_0_wvalid,
    C0_SYS_CLK_0_clk_n,
    C0_SYS_CLK_0_clk_p,
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
  input [31:0]C0_DDR4_S_AXI_0_araddr;
  input [1:0]C0_DDR4_S_AXI_0_arburst;
  input [3:0]C0_DDR4_S_AXI_0_arcache;
  input [3:0]C0_DDR4_S_AXI_0_arid;
  input [7:0]C0_DDR4_S_AXI_0_arlen;
  input [0:0]C0_DDR4_S_AXI_0_arlock;
  input [2:0]C0_DDR4_S_AXI_0_arprot;
  input [3:0]C0_DDR4_S_AXI_0_arqos;
  output C0_DDR4_S_AXI_0_arready;
  input [2:0]C0_DDR4_S_AXI_0_arsize;
  input C0_DDR4_S_AXI_0_arvalid;
  input [31:0]C0_DDR4_S_AXI_0_awaddr;
  input [1:0]C0_DDR4_S_AXI_0_awburst;
  input [3:0]C0_DDR4_S_AXI_0_awcache;
  input [3:0]C0_DDR4_S_AXI_0_awid;
  input [7:0]C0_DDR4_S_AXI_0_awlen;
  input [0:0]C0_DDR4_S_AXI_0_awlock;
  input [2:0]C0_DDR4_S_AXI_0_awprot;
  input [3:0]C0_DDR4_S_AXI_0_awqos;
  output C0_DDR4_S_AXI_0_awready;
  input [2:0]C0_DDR4_S_AXI_0_awsize;
  input C0_DDR4_S_AXI_0_awvalid;
  output [3:0]C0_DDR4_S_AXI_0_bid;
  input C0_DDR4_S_AXI_0_bready;
  output [1:0]C0_DDR4_S_AXI_0_bresp;
  output C0_DDR4_S_AXI_0_bvalid;
  output [511:0]C0_DDR4_S_AXI_0_rdata;
  output [3:0]C0_DDR4_S_AXI_0_rid;
  output C0_DDR4_S_AXI_0_rlast;
  input C0_DDR4_S_AXI_0_rready;
  output [1:0]C0_DDR4_S_AXI_0_rresp;
  output C0_DDR4_S_AXI_0_rvalid;
  input [511:0]C0_DDR4_S_AXI_0_wdata;
  input C0_DDR4_S_AXI_0_wlast;
  output C0_DDR4_S_AXI_0_wready;
  input [63:0]C0_DDR4_S_AXI_0_wstrb;
  input C0_DDR4_S_AXI_0_wvalid;
  input C0_SYS_CLK_0_clk_n;
  input C0_SYS_CLK_0_clk_p;
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
  wire [31:0]C0_DDR4_S_AXI_0_araddr;
  wire [1:0]C0_DDR4_S_AXI_0_arburst;
  wire [3:0]C0_DDR4_S_AXI_0_arcache;
  wire [3:0]C0_DDR4_S_AXI_0_arid;
  wire [7:0]C0_DDR4_S_AXI_0_arlen;
  wire [0:0]C0_DDR4_S_AXI_0_arlock;
  wire [2:0]C0_DDR4_S_AXI_0_arprot;
  wire [3:0]C0_DDR4_S_AXI_0_arqos;
  wire C0_DDR4_S_AXI_0_arready;
  wire [2:0]C0_DDR4_S_AXI_0_arsize;
  wire C0_DDR4_S_AXI_0_arvalid;
  wire [31:0]C0_DDR4_S_AXI_0_awaddr;
  wire [1:0]C0_DDR4_S_AXI_0_awburst;
  wire [3:0]C0_DDR4_S_AXI_0_awcache;
  wire [3:0]C0_DDR4_S_AXI_0_awid;
  wire [7:0]C0_DDR4_S_AXI_0_awlen;
  wire [0:0]C0_DDR4_S_AXI_0_awlock;
  wire [2:0]C0_DDR4_S_AXI_0_awprot;
  wire [3:0]C0_DDR4_S_AXI_0_awqos;
  wire C0_DDR4_S_AXI_0_awready;
  wire [2:0]C0_DDR4_S_AXI_0_awsize;
  wire C0_DDR4_S_AXI_0_awvalid;
  wire [3:0]C0_DDR4_S_AXI_0_bid;
  wire C0_DDR4_S_AXI_0_bready;
  wire [1:0]C0_DDR4_S_AXI_0_bresp;
  wire C0_DDR4_S_AXI_0_bvalid;
  wire [511:0]C0_DDR4_S_AXI_0_rdata;
  wire [3:0]C0_DDR4_S_AXI_0_rid;
  wire C0_DDR4_S_AXI_0_rlast;
  wire C0_DDR4_S_AXI_0_rready;
  wire [1:0]C0_DDR4_S_AXI_0_rresp;
  wire C0_DDR4_S_AXI_0_rvalid;
  wire [511:0]C0_DDR4_S_AXI_0_wdata;
  wire C0_DDR4_S_AXI_0_wlast;
  wire C0_DDR4_S_AXI_0_wready;
  wire [63:0]C0_DDR4_S_AXI_0_wstrb;
  wire C0_DDR4_S_AXI_0_wvalid;
  wire C0_SYS_CLK_0_clk_n;
  wire C0_SYS_CLK_0_clk_p;
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
        .C0_DDR4_S_AXI_0_araddr(C0_DDR4_S_AXI_0_araddr),
        .C0_DDR4_S_AXI_0_arburst(C0_DDR4_S_AXI_0_arburst),
        .C0_DDR4_S_AXI_0_arcache(C0_DDR4_S_AXI_0_arcache),
        .C0_DDR4_S_AXI_0_arid(C0_DDR4_S_AXI_0_arid),
        .C0_DDR4_S_AXI_0_arlen(C0_DDR4_S_AXI_0_arlen),
        .C0_DDR4_S_AXI_0_arlock(C0_DDR4_S_AXI_0_arlock),
        .C0_DDR4_S_AXI_0_arprot(C0_DDR4_S_AXI_0_arprot),
        .C0_DDR4_S_AXI_0_arqos(C0_DDR4_S_AXI_0_arqos),
        .C0_DDR4_S_AXI_0_arready(C0_DDR4_S_AXI_0_arready),
        .C0_DDR4_S_AXI_0_arsize(C0_DDR4_S_AXI_0_arsize),
        .C0_DDR4_S_AXI_0_arvalid(C0_DDR4_S_AXI_0_arvalid),
        .C0_DDR4_S_AXI_0_awaddr(C0_DDR4_S_AXI_0_awaddr),
        .C0_DDR4_S_AXI_0_awburst(C0_DDR4_S_AXI_0_awburst),
        .C0_DDR4_S_AXI_0_awcache(C0_DDR4_S_AXI_0_awcache),
        .C0_DDR4_S_AXI_0_awid(C0_DDR4_S_AXI_0_awid),
        .C0_DDR4_S_AXI_0_awlen(C0_DDR4_S_AXI_0_awlen),
        .C0_DDR4_S_AXI_0_awlock(C0_DDR4_S_AXI_0_awlock),
        .C0_DDR4_S_AXI_0_awprot(C0_DDR4_S_AXI_0_awprot),
        .C0_DDR4_S_AXI_0_awqos(C0_DDR4_S_AXI_0_awqos),
        .C0_DDR4_S_AXI_0_awready(C0_DDR4_S_AXI_0_awready),
        .C0_DDR4_S_AXI_0_awsize(C0_DDR4_S_AXI_0_awsize),
        .C0_DDR4_S_AXI_0_awvalid(C0_DDR4_S_AXI_0_awvalid),
        .C0_DDR4_S_AXI_0_bid(C0_DDR4_S_AXI_0_bid),
        .C0_DDR4_S_AXI_0_bready(C0_DDR4_S_AXI_0_bready),
        .C0_DDR4_S_AXI_0_bresp(C0_DDR4_S_AXI_0_bresp),
        .C0_DDR4_S_AXI_0_bvalid(C0_DDR4_S_AXI_0_bvalid),
        .C0_DDR4_S_AXI_0_rdata(C0_DDR4_S_AXI_0_rdata),
        .C0_DDR4_S_AXI_0_rid(C0_DDR4_S_AXI_0_rid),
        .C0_DDR4_S_AXI_0_rlast(C0_DDR4_S_AXI_0_rlast),
        .C0_DDR4_S_AXI_0_rready(C0_DDR4_S_AXI_0_rready),
        .C0_DDR4_S_AXI_0_rresp(C0_DDR4_S_AXI_0_rresp),
        .C0_DDR4_S_AXI_0_rvalid(C0_DDR4_S_AXI_0_rvalid),
        .C0_DDR4_S_AXI_0_wdata(C0_DDR4_S_AXI_0_wdata),
        .C0_DDR4_S_AXI_0_wlast(C0_DDR4_S_AXI_0_wlast),
        .C0_DDR4_S_AXI_0_wready(C0_DDR4_S_AXI_0_wready),
        .C0_DDR4_S_AXI_0_wstrb(C0_DDR4_S_AXI_0_wstrb),
        .C0_DDR4_S_AXI_0_wvalid(C0_DDR4_S_AXI_0_wvalid),
        .C0_SYS_CLK_0_clk_n(C0_SYS_CLK_0_clk_n),
        .C0_SYS_CLK_0_clk_p(C0_SYS_CLK_0_clk_p),
        .diff_clock_rtl_0_clk_n(diff_clock_rtl_0_clk_n),
        .diff_clock_rtl_0_clk_p(diff_clock_rtl_0_clk_p),
        .pcie_7x_mgt_rtl_0_rxn(pcie_7x_mgt_rtl_0_rxn),
        .pcie_7x_mgt_rtl_0_rxp(pcie_7x_mgt_rtl_0_rxp),
        .pcie_7x_mgt_rtl_0_txn(pcie_7x_mgt_rtl_0_txn),
        .pcie_7x_mgt_rtl_0_txp(pcie_7x_mgt_rtl_0_txp),
        .reset_rtl_0(reset_rtl_0));
endmodule
