//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Mon Sep 28 17:36:39 2026
//Host        : WIN-76HS90OBB7Q running 64-bit major release  (build 9200)
//Command     : generate_target xdma_pcie.bd
//Design      : xdma_pcie
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "xdma_pcie,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=xdma_pcie,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=3,da_xdma_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "xdma_pcie.hwdef" *) 
module xdma_pcie
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 ACT_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME C0_DDR4_0, AXI_ARBITRATION_SCHEME RD_PRI_REG, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 9, CS_ENABLED true, CUSTOM_PARTS no_file_loaded, DATA_MASK_ENABLED DM_NO_DBI, DATA_WIDTH 64, MEMORY_PART MT40A512M16HA-083E, MEMORY_TYPE Components, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250" *) output C0_DDR4_0_act_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 ADR" *) output [16:0]C0_DDR4_0_adr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 BA" *) output [1:0]C0_DDR4_0_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 BG" *) output [0:0]C0_DDR4_0_bg;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CK_C" *) output [0:0]C0_DDR4_0_ck_c;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CK_T" *) output [0:0]C0_DDR4_0_ck_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CKE" *) output [0:0]C0_DDR4_0_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CS_N" *) output [0:0]C0_DDR4_0_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DM_N" *) inout [7:0]C0_DDR4_0_dm_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DQ" *) inout [63:0]C0_DDR4_0_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DQS_C" *) inout [7:0]C0_DDR4_0_dqs_c;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DQS_T" *) inout [7:0]C0_DDR4_0_dqs_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 ODT" *) output [0:0]C0_DDR4_0_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 RESET_N" *) output C0_DDR4_0_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME C0_DDR4_S_AXI_0, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, DATA_WIDTH 512, FREQ_HZ 200000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 4, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [31:0]C0_DDR4_S_AXI_0_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARBURST" *) input [1:0]C0_DDR4_S_AXI_0_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARCACHE" *) input [3:0]C0_DDR4_S_AXI_0_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARID" *) input [3:0]C0_DDR4_S_AXI_0_arid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARLEN" *) input [7:0]C0_DDR4_S_AXI_0_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARLOCK" *) input [0:0]C0_DDR4_S_AXI_0_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARPROT" *) input [2:0]C0_DDR4_S_AXI_0_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARQOS" *) input [3:0]C0_DDR4_S_AXI_0_arqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARREADY" *) output C0_DDR4_S_AXI_0_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARSIZE" *) input [2:0]C0_DDR4_S_AXI_0_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 ARVALID" *) input C0_DDR4_S_AXI_0_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWADDR" *) input [31:0]C0_DDR4_S_AXI_0_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWBURST" *) input [1:0]C0_DDR4_S_AXI_0_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWCACHE" *) input [3:0]C0_DDR4_S_AXI_0_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWID" *) input [3:0]C0_DDR4_S_AXI_0_awid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWLEN" *) input [7:0]C0_DDR4_S_AXI_0_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWLOCK" *) input [0:0]C0_DDR4_S_AXI_0_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWPROT" *) input [2:0]C0_DDR4_S_AXI_0_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWQOS" *) input [3:0]C0_DDR4_S_AXI_0_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWREADY" *) output C0_DDR4_S_AXI_0_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWSIZE" *) input [2:0]C0_DDR4_S_AXI_0_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 AWVALID" *) input C0_DDR4_S_AXI_0_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 BID" *) output [3:0]C0_DDR4_S_AXI_0_bid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 BREADY" *) input C0_DDR4_S_AXI_0_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 BRESP" *) output [1:0]C0_DDR4_S_AXI_0_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 BVALID" *) output C0_DDR4_S_AXI_0_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 RDATA" *) output [511:0]C0_DDR4_S_AXI_0_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 RID" *) output [3:0]C0_DDR4_S_AXI_0_rid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 RLAST" *) output C0_DDR4_S_AXI_0_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 RREADY" *) input C0_DDR4_S_AXI_0_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 RRESP" *) output [1:0]C0_DDR4_S_AXI_0_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 RVALID" *) output C0_DDR4_S_AXI_0_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 WDATA" *) input [511:0]C0_DDR4_S_AXI_0_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 WLAST" *) input C0_DDR4_S_AXI_0_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 WREADY" *) output C0_DDR4_S_AXI_0_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 WSTRB" *) input [63:0]C0_DDR4_S_AXI_0_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C0_DDR4_S_AXI_0 WVALID" *) input C0_DDR4_S_AXI_0_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 C0_SYS_CLK_0 CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME C0_SYS_CLK_0, CAN_DEBUG false, FREQ_HZ 100000000" *) input C0_SYS_CLK_0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 C0_SYS_CLK_0 CLK_P" *) input C0_SYS_CLK_0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 diff_clock_rtl_0 CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME diff_clock_rtl_0, CAN_DEBUG false, FREQ_HZ 100000000" *) input [0:0]diff_clock_rtl_0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 diff_clock_rtl_0 CLK_P" *) input [0:0]diff_clock_rtl_0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 rxn" *) input [7:0]pcie_7x_mgt_rtl_0_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 rxp" *) input [7:0]pcie_7x_mgt_rtl_0_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 txn" *) output [7:0]pcie_7x_mgt_rtl_0_txn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 txp" *) output [7:0]pcie_7x_mgt_rtl_0_txp;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET_RTL_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET_RTL_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input reset_rtl_0;

  wire [31:0]C0_DDR4_S_AXI_0_1_ARADDR;
  wire [1:0]C0_DDR4_S_AXI_0_1_ARBURST;
  wire [3:0]C0_DDR4_S_AXI_0_1_ARCACHE;
  wire [3:0]C0_DDR4_S_AXI_0_1_ARID;
  wire [7:0]C0_DDR4_S_AXI_0_1_ARLEN;
  wire [0:0]C0_DDR4_S_AXI_0_1_ARLOCK;
  wire [2:0]C0_DDR4_S_AXI_0_1_ARPROT;
  wire [3:0]C0_DDR4_S_AXI_0_1_ARQOS;
  wire C0_DDR4_S_AXI_0_1_ARREADY;
  wire [2:0]C0_DDR4_S_AXI_0_1_ARSIZE;
  wire C0_DDR4_S_AXI_0_1_ARVALID;
  wire [31:0]C0_DDR4_S_AXI_0_1_AWADDR;
  wire [1:0]C0_DDR4_S_AXI_0_1_AWBURST;
  wire [3:0]C0_DDR4_S_AXI_0_1_AWCACHE;
  wire [3:0]C0_DDR4_S_AXI_0_1_AWID;
  wire [7:0]C0_DDR4_S_AXI_0_1_AWLEN;
  wire [0:0]C0_DDR4_S_AXI_0_1_AWLOCK;
  wire [2:0]C0_DDR4_S_AXI_0_1_AWPROT;
  wire [3:0]C0_DDR4_S_AXI_0_1_AWQOS;
  wire C0_DDR4_S_AXI_0_1_AWREADY;
  wire [2:0]C0_DDR4_S_AXI_0_1_AWSIZE;
  wire C0_DDR4_S_AXI_0_1_AWVALID;
  wire [3:0]C0_DDR4_S_AXI_0_1_BID;
  wire C0_DDR4_S_AXI_0_1_BREADY;
  wire [1:0]C0_DDR4_S_AXI_0_1_BRESP;
  wire C0_DDR4_S_AXI_0_1_BVALID;
  wire [511:0]C0_DDR4_S_AXI_0_1_RDATA;
  wire [3:0]C0_DDR4_S_AXI_0_1_RID;
  wire C0_DDR4_S_AXI_0_1_RLAST;
  wire C0_DDR4_S_AXI_0_1_RREADY;
  wire [1:0]C0_DDR4_S_AXI_0_1_RRESP;
  wire C0_DDR4_S_AXI_0_1_RVALID;
  wire [511:0]C0_DDR4_S_AXI_0_1_WDATA;
  wire C0_DDR4_S_AXI_0_1_WLAST;
  wire C0_DDR4_S_AXI_0_1_WREADY;
  wire [63:0]C0_DDR4_S_AXI_0_1_WSTRB;
  wire C0_DDR4_S_AXI_0_1_WVALID;
  wire C0_SYS_CLK_0_1_CLK_N;
  wire C0_SYS_CLK_0_1_CLK_P;
  wire ddr4_0_C0_DDR4_ACT_N;
  wire [16:0]ddr4_0_C0_DDR4_ADR;
  wire [1:0]ddr4_0_C0_DDR4_BA;
  wire [0:0]ddr4_0_C0_DDR4_BG;
  wire [0:0]ddr4_0_C0_DDR4_CKE;
  wire [0:0]ddr4_0_C0_DDR4_CK_C;
  wire [0:0]ddr4_0_C0_DDR4_CK_T;
  wire [0:0]ddr4_0_C0_DDR4_CS_N;
  wire [7:0]ddr4_0_C0_DDR4_DM_N;
  wire [63:0]ddr4_0_C0_DDR4_DQ;
  wire [7:0]ddr4_0_C0_DDR4_DQS_C;
  wire [7:0]ddr4_0_C0_DDR4_DQS_T;
  wire [0:0]ddr4_0_C0_DDR4_ODT;
  wire ddr4_0_C0_DDR4_RESET_N;
  wire [0:0]diff_clock_rtl_0_1_CLK_N;
  wire [0:0]diff_clock_rtl_0_1_CLK_P;
  wire reset_rtl_0_1;
  wire [0:0]util_ds_buf_IBUF_DS_ODIV2;
  wire [0:0]util_ds_buf_IBUF_OUT;
  wire [7:0]xdma_0_pcie_mgt_rxn;
  wire [7:0]xdma_0_pcie_mgt_rxp;
  wire [7:0]xdma_0_pcie_mgt_txn;
  wire [7:0]xdma_0_pcie_mgt_txp;

  assign C0_DDR4_0_act_n = ddr4_0_C0_DDR4_ACT_N;
  assign C0_DDR4_0_adr[16:0] = ddr4_0_C0_DDR4_ADR;
  assign C0_DDR4_0_ba[1:0] = ddr4_0_C0_DDR4_BA;
  assign C0_DDR4_0_bg[0] = ddr4_0_C0_DDR4_BG;
  assign C0_DDR4_0_ck_c[0] = ddr4_0_C0_DDR4_CK_C;
  assign C0_DDR4_0_ck_t[0] = ddr4_0_C0_DDR4_CK_T;
  assign C0_DDR4_0_cke[0] = ddr4_0_C0_DDR4_CKE;
  assign C0_DDR4_0_cs_n[0] = ddr4_0_C0_DDR4_CS_N;
  assign C0_DDR4_0_odt[0] = ddr4_0_C0_DDR4_ODT;
  assign C0_DDR4_0_reset_n = ddr4_0_C0_DDR4_RESET_N;
  assign C0_DDR4_S_AXI_0_1_ARADDR = C0_DDR4_S_AXI_0_araddr[31:0];
  assign C0_DDR4_S_AXI_0_1_ARBURST = C0_DDR4_S_AXI_0_arburst[1:0];
  assign C0_DDR4_S_AXI_0_1_ARCACHE = C0_DDR4_S_AXI_0_arcache[3:0];
  assign C0_DDR4_S_AXI_0_1_ARID = C0_DDR4_S_AXI_0_arid[3:0];
  assign C0_DDR4_S_AXI_0_1_ARLEN = C0_DDR4_S_AXI_0_arlen[7:0];
  assign C0_DDR4_S_AXI_0_1_ARLOCK = C0_DDR4_S_AXI_0_arlock[0];
  assign C0_DDR4_S_AXI_0_1_ARPROT = C0_DDR4_S_AXI_0_arprot[2:0];
  assign C0_DDR4_S_AXI_0_1_ARQOS = C0_DDR4_S_AXI_0_arqos[3:0];
  assign C0_DDR4_S_AXI_0_1_ARSIZE = C0_DDR4_S_AXI_0_arsize[2:0];
  assign C0_DDR4_S_AXI_0_1_ARVALID = C0_DDR4_S_AXI_0_arvalid;
  assign C0_DDR4_S_AXI_0_1_AWADDR = C0_DDR4_S_AXI_0_awaddr[31:0];
  assign C0_DDR4_S_AXI_0_1_AWBURST = C0_DDR4_S_AXI_0_awburst[1:0];
  assign C0_DDR4_S_AXI_0_1_AWCACHE = C0_DDR4_S_AXI_0_awcache[3:0];
  assign C0_DDR4_S_AXI_0_1_AWID = C0_DDR4_S_AXI_0_awid[3:0];
  assign C0_DDR4_S_AXI_0_1_AWLEN = C0_DDR4_S_AXI_0_awlen[7:0];
  assign C0_DDR4_S_AXI_0_1_AWLOCK = C0_DDR4_S_AXI_0_awlock[0];
  assign C0_DDR4_S_AXI_0_1_AWPROT = C0_DDR4_S_AXI_0_awprot[2:0];
  assign C0_DDR4_S_AXI_0_1_AWQOS = C0_DDR4_S_AXI_0_awqos[3:0];
  assign C0_DDR4_S_AXI_0_1_AWSIZE = C0_DDR4_S_AXI_0_awsize[2:0];
  assign C0_DDR4_S_AXI_0_1_AWVALID = C0_DDR4_S_AXI_0_awvalid;
  assign C0_DDR4_S_AXI_0_1_BREADY = C0_DDR4_S_AXI_0_bready;
  assign C0_DDR4_S_AXI_0_1_RREADY = C0_DDR4_S_AXI_0_rready;
  assign C0_DDR4_S_AXI_0_1_WDATA = C0_DDR4_S_AXI_0_wdata[511:0];
  assign C0_DDR4_S_AXI_0_1_WLAST = C0_DDR4_S_AXI_0_wlast;
  assign C0_DDR4_S_AXI_0_1_WSTRB = C0_DDR4_S_AXI_0_wstrb[63:0];
  assign C0_DDR4_S_AXI_0_1_WVALID = C0_DDR4_S_AXI_0_wvalid;
  assign C0_DDR4_S_AXI_0_arready = C0_DDR4_S_AXI_0_1_ARREADY;
  assign C0_DDR4_S_AXI_0_awready = C0_DDR4_S_AXI_0_1_AWREADY;
  assign C0_DDR4_S_AXI_0_bid[3:0] = C0_DDR4_S_AXI_0_1_BID;
  assign C0_DDR4_S_AXI_0_bresp[1:0] = C0_DDR4_S_AXI_0_1_BRESP;
  assign C0_DDR4_S_AXI_0_bvalid = C0_DDR4_S_AXI_0_1_BVALID;
  assign C0_DDR4_S_AXI_0_rdata[511:0] = C0_DDR4_S_AXI_0_1_RDATA;
  assign C0_DDR4_S_AXI_0_rid[3:0] = C0_DDR4_S_AXI_0_1_RID;
  assign C0_DDR4_S_AXI_0_rlast = C0_DDR4_S_AXI_0_1_RLAST;
  assign C0_DDR4_S_AXI_0_rresp[1:0] = C0_DDR4_S_AXI_0_1_RRESP;
  assign C0_DDR4_S_AXI_0_rvalid = C0_DDR4_S_AXI_0_1_RVALID;
  assign C0_DDR4_S_AXI_0_wready = C0_DDR4_S_AXI_0_1_WREADY;
  assign C0_SYS_CLK_0_1_CLK_N = C0_SYS_CLK_0_clk_n;
  assign C0_SYS_CLK_0_1_CLK_P = C0_SYS_CLK_0_clk_p;
  assign diff_clock_rtl_0_1_CLK_N = diff_clock_rtl_0_clk_n[0];
  assign diff_clock_rtl_0_1_CLK_P = diff_clock_rtl_0_clk_p[0];
  assign pcie_7x_mgt_rtl_0_txn[7:0] = xdma_0_pcie_mgt_txn;
  assign pcie_7x_mgt_rtl_0_txp[7:0] = xdma_0_pcie_mgt_txp;
  assign reset_rtl_0_1 = reset_rtl_0;
  assign xdma_0_pcie_mgt_rxn = pcie_7x_mgt_rtl_0_rxn[7:0];
  assign xdma_0_pcie_mgt_rxp = pcie_7x_mgt_rtl_0_rxp[7:0];
  xdma_pcie_ddr4_0_2 ddr4_0
       (.c0_ddr4_act_n(ddr4_0_C0_DDR4_ACT_N),
        .c0_ddr4_adr(ddr4_0_C0_DDR4_ADR),
        .c0_ddr4_aresetn(1'b0),
        .c0_ddr4_ba(ddr4_0_C0_DDR4_BA),
        .c0_ddr4_bg(ddr4_0_C0_DDR4_BG),
        .c0_ddr4_ck_c(ddr4_0_C0_DDR4_CK_C),
        .c0_ddr4_ck_t(ddr4_0_C0_DDR4_CK_T),
        .c0_ddr4_cke(ddr4_0_C0_DDR4_CKE),
        .c0_ddr4_cs_n(ddr4_0_C0_DDR4_CS_N),
        .c0_ddr4_dm_dbi_n(C0_DDR4_0_dm_n[7:0]),
        .c0_ddr4_dq(C0_DDR4_0_dq[63:0]),
        .c0_ddr4_dqs_c(C0_DDR4_0_dqs_c[7:0]),
        .c0_ddr4_dqs_t(C0_DDR4_0_dqs_t[7:0]),
        .c0_ddr4_odt(ddr4_0_C0_DDR4_ODT),
        .c0_ddr4_reset_n(ddr4_0_C0_DDR4_RESET_N),
        .c0_ddr4_s_axi_araddr(C0_DDR4_S_AXI_0_1_ARADDR),
        .c0_ddr4_s_axi_arburst(C0_DDR4_S_AXI_0_1_ARBURST),
        .c0_ddr4_s_axi_arcache(C0_DDR4_S_AXI_0_1_ARCACHE),
        .c0_ddr4_s_axi_arid(C0_DDR4_S_AXI_0_1_ARID),
        .c0_ddr4_s_axi_arlen(C0_DDR4_S_AXI_0_1_ARLEN),
        .c0_ddr4_s_axi_arlock(C0_DDR4_S_AXI_0_1_ARLOCK),
        .c0_ddr4_s_axi_arprot(C0_DDR4_S_AXI_0_1_ARPROT),
        .c0_ddr4_s_axi_arqos(C0_DDR4_S_AXI_0_1_ARQOS),
        .c0_ddr4_s_axi_arready(C0_DDR4_S_AXI_0_1_ARREADY),
        .c0_ddr4_s_axi_arsize(C0_DDR4_S_AXI_0_1_ARSIZE),
        .c0_ddr4_s_axi_arvalid(C0_DDR4_S_AXI_0_1_ARVALID),
        .c0_ddr4_s_axi_awaddr(C0_DDR4_S_AXI_0_1_AWADDR),
        .c0_ddr4_s_axi_awburst(C0_DDR4_S_AXI_0_1_AWBURST),
        .c0_ddr4_s_axi_awcache(C0_DDR4_S_AXI_0_1_AWCACHE),
        .c0_ddr4_s_axi_awid(C0_DDR4_S_AXI_0_1_AWID),
        .c0_ddr4_s_axi_awlen(C0_DDR4_S_AXI_0_1_AWLEN),
        .c0_ddr4_s_axi_awlock(C0_DDR4_S_AXI_0_1_AWLOCK),
        .c0_ddr4_s_axi_awprot(C0_DDR4_S_AXI_0_1_AWPROT),
        .c0_ddr4_s_axi_awqos(C0_DDR4_S_AXI_0_1_AWQOS),
        .c0_ddr4_s_axi_awready(C0_DDR4_S_AXI_0_1_AWREADY),
        .c0_ddr4_s_axi_awsize(C0_DDR4_S_AXI_0_1_AWSIZE),
        .c0_ddr4_s_axi_awvalid(C0_DDR4_S_AXI_0_1_AWVALID),
        .c0_ddr4_s_axi_bid(C0_DDR4_S_AXI_0_1_BID),
        .c0_ddr4_s_axi_bready(C0_DDR4_S_AXI_0_1_BREADY),
        .c0_ddr4_s_axi_bresp(C0_DDR4_S_AXI_0_1_BRESP),
        .c0_ddr4_s_axi_bvalid(C0_DDR4_S_AXI_0_1_BVALID),
        .c0_ddr4_s_axi_rdata(C0_DDR4_S_AXI_0_1_RDATA),
        .c0_ddr4_s_axi_rid(C0_DDR4_S_AXI_0_1_RID),
        .c0_ddr4_s_axi_rlast(C0_DDR4_S_AXI_0_1_RLAST),
        .c0_ddr4_s_axi_rready(C0_DDR4_S_AXI_0_1_RREADY),
        .c0_ddr4_s_axi_rresp(C0_DDR4_S_AXI_0_1_RRESP),
        .c0_ddr4_s_axi_rvalid(C0_DDR4_S_AXI_0_1_RVALID),
        .c0_ddr4_s_axi_wdata(C0_DDR4_S_AXI_0_1_WDATA),
        .c0_ddr4_s_axi_wlast(C0_DDR4_S_AXI_0_1_WLAST),
        .c0_ddr4_s_axi_wready(C0_DDR4_S_AXI_0_1_WREADY),
        .c0_ddr4_s_axi_wstrb(C0_DDR4_S_AXI_0_1_WSTRB),
        .c0_ddr4_s_axi_wvalid(C0_DDR4_S_AXI_0_1_WVALID),
        .c0_sys_clk_n(C0_SYS_CLK_0_1_CLK_N),
        .c0_sys_clk_p(C0_SYS_CLK_0_1_CLK_P),
        .sys_rst(1'b0));
  xdma_pcie_util_ds_buf_0 util_ds_buf
       (.IBUF_DS_N(diff_clock_rtl_0_1_CLK_N),
        .IBUF_DS_ODIV2(util_ds_buf_IBUF_DS_ODIV2),
        .IBUF_DS_P(diff_clock_rtl_0_1_CLK_P),
        .IBUF_OUT(util_ds_buf_IBUF_OUT));
  xdma_pcie_xdma_0_0 xdma_0
       (.cfg_mgmt_addr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .cfg_mgmt_byte_enable({1'b0,1'b0,1'b0,1'b0}),
        .cfg_mgmt_read(1'b0),
        .cfg_mgmt_type1_cfg_reg_access(1'b0),
        .cfg_mgmt_write(1'b0),
        .cfg_mgmt_write_data({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_arready(1'b0),
        .m_axi_awready(1'b0),
        .m_axi_bid({1'b0,1'b0,1'b0,1'b0}),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid({1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rlast(1'b0),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_rvalid(1'b0),
        .m_axi_wready(1'b0),
        .pci_exp_rxn(xdma_0_pcie_mgt_rxn),
        .pci_exp_rxp(xdma_0_pcie_mgt_rxp),
        .pci_exp_txn(xdma_0_pcie_mgt_txn),
        .pci_exp_txp(xdma_0_pcie_mgt_txp),
        .sys_clk(util_ds_buf_IBUF_DS_ODIV2),
        .sys_clk_gt(util_ds_buf_IBUF_OUT),
        .sys_rst_n(reset_rtl_0_1),
        .usr_irq_req(1'b0));
endmodule
