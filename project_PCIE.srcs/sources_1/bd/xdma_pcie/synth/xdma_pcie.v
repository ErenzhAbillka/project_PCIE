//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Wed Sep 30 19:06:26 2026
//Host        : WIN-76HS90OBB7Q running 64-bit major release  (build 9200)
//Command     : generate_target xdma_pcie.bd
//Design      : xdma_pcie
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "xdma_pcie,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=xdma_pcie,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=18,numReposBlks=18,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,da_board_cnt=3,da_xdma_cnt=1,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "xdma_pcie.hwdef" *) 
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 C0_SYS_CLK_0 CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME C0_SYS_CLK_0, CAN_DEBUG false, FREQ_HZ 100000000" *) input C0_SYS_CLK_0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 C0_SYS_CLK_0 CLK_P" *) input C0_SYS_CLK_0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 diff_clock_rtl_0 CLK_N" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME diff_clock_rtl_0, CAN_DEBUG false, FREQ_HZ 100000000" *) input [0:0]diff_clock_rtl_0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 diff_clock_rtl_0 CLK_P" *) input [0:0]diff_clock_rtl_0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 rxn" *) input [7:0]pcie_7x_mgt_rtl_0_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 rxp" *) input [7:0]pcie_7x_mgt_rtl_0_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 txn" *) output [7:0]pcie_7x_mgt_rtl_0_txn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt_rtl_0 txp" *) output [7:0]pcie_7x_mgt_rtl_0_txp;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET_RTL_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET_RTL_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input reset_rtl_0;

  wire [31:0]AXI_data_out_0_0_data;
  wire AXI_data_out_0_0_last;
  wire AXI_data_out_0_0_valid;
  wire C0_SYS_CLK_0_1_CLK_N;
  wire C0_SYS_CLK_0_1_CLK_P;
  wire [0:0]Net;
  wire [31:0]axi_smc_M00_AXI_ARADDR;
  wire [1:0]axi_smc_M00_AXI_ARBURST;
  wire [3:0]axi_smc_M00_AXI_ARCACHE;
  wire [7:0]axi_smc_M00_AXI_ARLEN;
  wire [0:0]axi_smc_M00_AXI_ARLOCK;
  wire [2:0]axi_smc_M00_AXI_ARPROT;
  wire [3:0]axi_smc_M00_AXI_ARQOS;
  wire axi_smc_M00_AXI_ARREADY;
  wire [2:0]axi_smc_M00_AXI_ARSIZE;
  wire axi_smc_M00_AXI_ARVALID;
  wire [31:0]axi_smc_M00_AXI_AWADDR;
  wire [1:0]axi_smc_M00_AXI_AWBURST;
  wire [3:0]axi_smc_M00_AXI_AWCACHE;
  wire [7:0]axi_smc_M00_AXI_AWLEN;
  wire [0:0]axi_smc_M00_AXI_AWLOCK;
  wire [2:0]axi_smc_M00_AXI_AWPROT;
  wire [3:0]axi_smc_M00_AXI_AWQOS;
  wire axi_smc_M00_AXI_AWREADY;
  wire [2:0]axi_smc_M00_AXI_AWSIZE;
  wire axi_smc_M00_AXI_AWVALID;
  wire axi_smc_M00_AXI_BREADY;
  wire [1:0]axi_smc_M00_AXI_BRESP;
  wire axi_smc_M00_AXI_BVALID;
  wire [511:0]axi_smc_M00_AXI_RDATA;
  wire axi_smc_M00_AXI_RLAST;
  wire axi_smc_M00_AXI_RREADY;
  wire [1:0]axi_smc_M00_AXI_RRESP;
  wire axi_smc_M00_AXI_RVALID;
  wire [511:0]axi_smc_M00_AXI_WDATA;
  wire axi_smc_M00_AXI_WLAST;
  wire axi_smc_M00_AXI_WREADY;
  wire [63:0]axi_smc_M00_AXI_WSTRB;
  wire axi_smc_M00_AXI_WVALID;
  wire [31:0]axis_data_fifo_0_m_axis_tdata;
  wire axis_data_fifo_0_m_axis_tlast;
  wire axis_data_fifo_0_m_axis_tvalid;
  wire axis_data_fifo_0_s_axis_tready;
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
  wire ddr4_0_c0_ddr4_ui_clk;
  wire ddr4_0_c0_ddr4_ui_clk_sync_rst;
  wire ddr4_0_c0_init_calib_complete;
  wire [0:0]diff_clock_rtl_0_1_CLK_N;
  wire [0:0]diff_clock_rtl_0_1_CLK_P;
  wire [0:0]one_dout;
  wire [0:0]perst_invert_Res;
  wire reset_rtl_0_1;
  wire [0:0]util_ds_buf_IBUF_DS_ODIV2;
  wire [0:0]util_ds_buf_IBUF_OUT;
  wire [0:0]vio_readback_probe_out0;
  wire wr_addr_0_fifo_ready;
  wire [31:0]wr_addr_0_m00_axi_ARADDR;
  wire [1:0]wr_addr_0_m00_axi_ARBURST;
  wire [3:0]wr_addr_0_m00_axi_ARCACHE;
  wire [0:0]wr_addr_0_m00_axi_ARID;
  wire [7:0]wr_addr_0_m00_axi_ARLEN;
  wire wr_addr_0_m00_axi_ARLOCK;
  wire [2:0]wr_addr_0_m00_axi_ARPROT;
  wire [3:0]wr_addr_0_m00_axi_ARQOS;
  wire wr_addr_0_m00_axi_ARREADY;
  wire [2:0]wr_addr_0_m00_axi_ARSIZE;
  wire wr_addr_0_m00_axi_ARVALID;
  wire [31:0]wr_addr_0_m00_axi_AWADDR;
  wire [1:0]wr_addr_0_m00_axi_AWBURST;
  wire [3:0]wr_addr_0_m00_axi_AWCACHE;
  wire [0:0]wr_addr_0_m00_axi_AWID;
  wire [7:0]wr_addr_0_m00_axi_AWLEN;
  wire wr_addr_0_m00_axi_AWLOCK;
  wire [2:0]wr_addr_0_m00_axi_AWPROT;
  wire [3:0]wr_addr_0_m00_axi_AWQOS;
  wire wr_addr_0_m00_axi_AWREADY;
  wire [2:0]wr_addr_0_m00_axi_AWSIZE;
  wire wr_addr_0_m00_axi_AWVALID;
  wire [0:0]wr_addr_0_m00_axi_BID;
  wire wr_addr_0_m00_axi_BREADY;
  wire [1:0]wr_addr_0_m00_axi_BRESP;
  wire wr_addr_0_m00_axi_BVALID;
  wire [31:0]wr_addr_0_m00_axi_RDATA;
  wire [0:0]wr_addr_0_m00_axi_RID;
  wire wr_addr_0_m00_axi_RLAST;
  wire wr_addr_0_m00_axi_RREADY;
  wire [1:0]wr_addr_0_m00_axi_RRESP;
  wire wr_addr_0_m00_axi_RVALID;
  wire [31:0]wr_addr_0_m00_axi_WDATA;
  wire wr_addr_0_m00_axi_WLAST;
  wire wr_addr_0_m00_axi_WREADY;
  wire [3:0]wr_addr_0_m00_axi_WSTRB;
  wire wr_addr_0_m00_axi_WVALID;
  wire wr_addr_0_m00_axi_error;
  wire wr_addr_0_m00_axi_txn_done;
  wire [31:0]wr_addr_0_o_data;
  wire wr_addr_0_o_last;
  wire wr_addr_0_o_valid;
  wire [63:0]xdma_0_M_AXI_ARADDR;
  wire [1:0]xdma_0_M_AXI_ARBURST;
  wire [3:0]xdma_0_M_AXI_ARCACHE;
  wire [3:0]xdma_0_M_AXI_ARID;
  wire [7:0]xdma_0_M_AXI_ARLEN;
  wire xdma_0_M_AXI_ARLOCK;
  wire [2:0]xdma_0_M_AXI_ARPROT;
  wire xdma_0_M_AXI_ARREADY;
  wire [2:0]xdma_0_M_AXI_ARSIZE;
  wire xdma_0_M_AXI_ARVALID;
  wire [63:0]xdma_0_M_AXI_AWADDR;
  wire [1:0]xdma_0_M_AXI_AWBURST;
  wire [3:0]xdma_0_M_AXI_AWCACHE;
  wire [3:0]xdma_0_M_AXI_AWID;
  wire [7:0]xdma_0_M_AXI_AWLEN;
  wire xdma_0_M_AXI_AWLOCK;
  wire [2:0]xdma_0_M_AXI_AWPROT;
  wire xdma_0_M_AXI_AWREADY;
  wire [2:0]xdma_0_M_AXI_AWSIZE;
  wire xdma_0_M_AXI_AWVALID;
  wire [3:0]xdma_0_M_AXI_BID;
  wire xdma_0_M_AXI_BREADY;
  wire [1:0]xdma_0_M_AXI_BRESP;
  wire xdma_0_M_AXI_BVALID;
  wire [255:0]xdma_0_M_AXI_RDATA;
  wire [3:0]xdma_0_M_AXI_RID;
  wire xdma_0_M_AXI_RLAST;
  wire xdma_0_M_AXI_RREADY;
  wire [1:0]xdma_0_M_AXI_RRESP;
  wire xdma_0_M_AXI_RVALID;
  wire [255:0]xdma_0_M_AXI_WDATA;
  wire xdma_0_M_AXI_WLAST;
  wire xdma_0_M_AXI_WREADY;
  wire [31:0]xdma_0_M_AXI_WSTRB;
  wire xdma_0_M_AXI_WVALID;
  wire xdma_0_axi_aclk;
  wire xdma_0_axi_aresetn;
  wire [7:0]xdma_0_pcie_mgt_rxn;
  wire [7:0]xdma_0_pcie_mgt_rxp;
  wire [7:0]xdma_0_pcie_mgt_txn;
  wire [7:0]xdma_0_pcie_mgt_txp;
  wire xdma_0_user_lnk_up;
  wire [0:0]xdma_reset_invert_Res;
  wire [18:0]zero_19_dout;
  wire [0:0]zero_1_dout;
  wire [31:0]zero_32_dout;
  wire [3:0]zero_4_dout;

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
  assign C0_SYS_CLK_0_1_CLK_N = C0_SYS_CLK_0_clk_n;
  assign C0_SYS_CLK_0_1_CLK_P = C0_SYS_CLK_0_clk_p;
  assign diff_clock_rtl_0_1_CLK_N = diff_clock_rtl_0_clk_n[0];
  assign diff_clock_rtl_0_1_CLK_P = diff_clock_rtl_0_clk_p[0];
  assign pcie_7x_mgt_rtl_0_txn[7:0] = xdma_0_pcie_mgt_txn;
  assign pcie_7x_mgt_rtl_0_txp[7:0] = xdma_0_pcie_mgt_txp;
  assign reset_rtl_0_1 = reset_rtl_0;
  assign xdma_0_pcie_mgt_rxn = pcie_7x_mgt_rtl_0_rxn[7:0];
  assign xdma_0_pcie_mgt_rxp = pcie_7x_mgt_rtl_0_rxp[7:0];
  xdma_pcie_AXI_data_out_0_0_0 AXI_data_out_0_0
       (.clk(ddr4_0_c0_ddr4_ui_clk),
        .data(AXI_data_out_0_0_data),
        .fifo_ready(axis_data_fifo_0_s_axis_tready),
        .last(AXI_data_out_0_0_last),
        .rst_n(Net),
        .valid(AXI_data_out_0_0_valid));
  xdma_pcie_axi_smc_0 axi_smc
       (.M00_AXI_araddr(axi_smc_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_smc_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_smc_M00_AXI_ARCACHE),
        .M00_AXI_arlen(axi_smc_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_smc_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_smc_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_smc_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_smc_M00_AXI_ARREADY),
        .M00_AXI_arsize(axi_smc_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(axi_smc_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_smc_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_smc_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_smc_M00_AXI_AWCACHE),
        .M00_AXI_awlen(axi_smc_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_smc_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_smc_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_smc_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_smc_M00_AXI_AWREADY),
        .M00_AXI_awsize(axi_smc_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(axi_smc_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_smc_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_smc_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_smc_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_smc_M00_AXI_RDATA),
        .M00_AXI_rlast(axi_smc_M00_AXI_RLAST),
        .M00_AXI_rready(axi_smc_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_smc_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_smc_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_smc_M00_AXI_WDATA),
        .M00_AXI_wlast(axi_smc_M00_AXI_WLAST),
        .M00_AXI_wready(axi_smc_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_smc_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_smc_M00_AXI_WVALID),
        .S00_AXI_araddr(xdma_0_M_AXI_ARADDR),
        .S00_AXI_arburst(xdma_0_M_AXI_ARBURST),
        .S00_AXI_arcache(xdma_0_M_AXI_ARCACHE),
        .S00_AXI_arid(xdma_0_M_AXI_ARID),
        .S00_AXI_arlen(xdma_0_M_AXI_ARLEN),
        .S00_AXI_arlock(xdma_0_M_AXI_ARLOCK),
        .S00_AXI_arprot(xdma_0_M_AXI_ARPROT),
        .S00_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_arready(xdma_0_M_AXI_ARREADY),
        .S00_AXI_arsize(xdma_0_M_AXI_ARSIZE),
        .S00_AXI_arvalid(xdma_0_M_AXI_ARVALID),
        .S00_AXI_awaddr(xdma_0_M_AXI_AWADDR),
        .S00_AXI_awburst(xdma_0_M_AXI_AWBURST),
        .S00_AXI_awcache(xdma_0_M_AXI_AWCACHE),
        .S00_AXI_awid(xdma_0_M_AXI_AWID),
        .S00_AXI_awlen(xdma_0_M_AXI_AWLEN),
        .S00_AXI_awlock(xdma_0_M_AXI_AWLOCK),
        .S00_AXI_awprot(xdma_0_M_AXI_AWPROT),
        .S00_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_awready(xdma_0_M_AXI_AWREADY),
        .S00_AXI_awsize(xdma_0_M_AXI_AWSIZE),
        .S00_AXI_awvalid(xdma_0_M_AXI_AWVALID),
        .S00_AXI_bid(xdma_0_M_AXI_BID),
        .S00_AXI_bready(xdma_0_M_AXI_BREADY),
        .S00_AXI_bresp(xdma_0_M_AXI_BRESP),
        .S00_AXI_bvalid(xdma_0_M_AXI_BVALID),
        .S00_AXI_rdata(xdma_0_M_AXI_RDATA),
        .S00_AXI_rid(xdma_0_M_AXI_RID),
        .S00_AXI_rlast(xdma_0_M_AXI_RLAST),
        .S00_AXI_rready(xdma_0_M_AXI_RREADY),
        .S00_AXI_rresp(xdma_0_M_AXI_RRESP),
        .S00_AXI_rvalid(xdma_0_M_AXI_RVALID),
        .S00_AXI_wdata(xdma_0_M_AXI_WDATA),
        .S00_AXI_wlast(xdma_0_M_AXI_WLAST),
        .S00_AXI_wready(xdma_0_M_AXI_WREADY),
        .S00_AXI_wstrb(xdma_0_M_AXI_WSTRB),
        .S00_AXI_wvalid(xdma_0_M_AXI_WVALID),
        .S01_AXI_araddr(wr_addr_0_m00_axi_ARADDR),
        .S01_AXI_arburst(wr_addr_0_m00_axi_ARBURST),
        .S01_AXI_arcache(wr_addr_0_m00_axi_ARCACHE),
        .S01_AXI_arid(wr_addr_0_m00_axi_ARID),
        .S01_AXI_arlen(wr_addr_0_m00_axi_ARLEN),
        .S01_AXI_arlock(wr_addr_0_m00_axi_ARLOCK),
        .S01_AXI_arprot(wr_addr_0_m00_axi_ARPROT),
        .S01_AXI_arqos(wr_addr_0_m00_axi_ARQOS),
        .S01_AXI_arready(wr_addr_0_m00_axi_ARREADY),
        .S01_AXI_arsize(wr_addr_0_m00_axi_ARSIZE),
        .S01_AXI_arvalid(wr_addr_0_m00_axi_ARVALID),
        .S01_AXI_awaddr(wr_addr_0_m00_axi_AWADDR),
        .S01_AXI_awburst(wr_addr_0_m00_axi_AWBURST),
        .S01_AXI_awcache(wr_addr_0_m00_axi_AWCACHE),
        .S01_AXI_awid(wr_addr_0_m00_axi_AWID),
        .S01_AXI_awlen(wr_addr_0_m00_axi_AWLEN),
        .S01_AXI_awlock(wr_addr_0_m00_axi_AWLOCK),
        .S01_AXI_awprot(wr_addr_0_m00_axi_AWPROT),
        .S01_AXI_awqos(wr_addr_0_m00_axi_AWQOS),
        .S01_AXI_awready(wr_addr_0_m00_axi_AWREADY),
        .S01_AXI_awsize(wr_addr_0_m00_axi_AWSIZE),
        .S01_AXI_awvalid(wr_addr_0_m00_axi_AWVALID),
        .S01_AXI_bid(wr_addr_0_m00_axi_BID),
        .S01_AXI_bready(wr_addr_0_m00_axi_BREADY),
        .S01_AXI_bresp(wr_addr_0_m00_axi_BRESP),
        .S01_AXI_bvalid(wr_addr_0_m00_axi_BVALID),
        .S01_AXI_rdata(wr_addr_0_m00_axi_RDATA),
        .S01_AXI_rid(wr_addr_0_m00_axi_RID),
        .S01_AXI_rlast(wr_addr_0_m00_axi_RLAST),
        .S01_AXI_rready(wr_addr_0_m00_axi_RREADY),
        .S01_AXI_rresp(wr_addr_0_m00_axi_RRESP),
        .S01_AXI_rvalid(wr_addr_0_m00_axi_RVALID),
        .S01_AXI_wdata(wr_addr_0_m00_axi_WDATA),
        .S01_AXI_wlast(wr_addr_0_m00_axi_WLAST),
        .S01_AXI_wready(wr_addr_0_m00_axi_WREADY),
        .S01_AXI_wstrb(wr_addr_0_m00_axi_WSTRB),
        .S01_AXI_wvalid(wr_addr_0_m00_axi_WVALID),
        .aclk(ddr4_0_c0_ddr4_ui_clk),
        .aclk1(xdma_0_axi_aclk),
        .aresetn(Net));
  xdma_pcie_axis_data_fifo_0_0 axis_data_fifo_0
       (.m_axis_tdata(axis_data_fifo_0_m_axis_tdata),
        .m_axis_tlast(axis_data_fifo_0_m_axis_tlast),
        .m_axis_tready(wr_addr_0_fifo_ready),
        .m_axis_tvalid(axis_data_fifo_0_m_axis_tvalid),
        .s_axis_aclk(ddr4_0_c0_ddr4_ui_clk),
        .s_axis_aresetn(Net),
        .s_axis_tdata(AXI_data_out_0_0_data),
        .s_axis_tlast(AXI_data_out_0_0_last),
        .s_axis_tready(axis_data_fifo_0_s_axis_tready),
        .s_axis_tvalid(AXI_data_out_0_0_valid));
  xdma_pcie_ddr4_0_2 ddr4_0
       (.c0_ddr4_act_n(ddr4_0_C0_DDR4_ACT_N),
        .c0_ddr4_adr(ddr4_0_C0_DDR4_ADR),
        .c0_ddr4_aresetn(Net),
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
        .c0_ddr4_s_axi_araddr(axi_smc_M00_AXI_ARADDR),
        .c0_ddr4_s_axi_arburst(axi_smc_M00_AXI_ARBURST),
        .c0_ddr4_s_axi_arcache(axi_smc_M00_AXI_ARCACHE),
        .c0_ddr4_s_axi_arid(1'b0),
        .c0_ddr4_s_axi_arlen(axi_smc_M00_AXI_ARLEN),
        .c0_ddr4_s_axi_arlock(axi_smc_M00_AXI_ARLOCK),
        .c0_ddr4_s_axi_arprot(axi_smc_M00_AXI_ARPROT),
        .c0_ddr4_s_axi_arqos(axi_smc_M00_AXI_ARQOS),
        .c0_ddr4_s_axi_arready(axi_smc_M00_AXI_ARREADY),
        .c0_ddr4_s_axi_arsize(axi_smc_M00_AXI_ARSIZE),
        .c0_ddr4_s_axi_arvalid(axi_smc_M00_AXI_ARVALID),
        .c0_ddr4_s_axi_awaddr(axi_smc_M00_AXI_AWADDR),
        .c0_ddr4_s_axi_awburst(axi_smc_M00_AXI_AWBURST),
        .c0_ddr4_s_axi_awcache(axi_smc_M00_AXI_AWCACHE),
        .c0_ddr4_s_axi_awid(1'b0),
        .c0_ddr4_s_axi_awlen(axi_smc_M00_AXI_AWLEN),
        .c0_ddr4_s_axi_awlock(axi_smc_M00_AXI_AWLOCK),
        .c0_ddr4_s_axi_awprot(axi_smc_M00_AXI_AWPROT),
        .c0_ddr4_s_axi_awqos(axi_smc_M00_AXI_AWQOS),
        .c0_ddr4_s_axi_awready(axi_smc_M00_AXI_AWREADY),
        .c0_ddr4_s_axi_awsize(axi_smc_M00_AXI_AWSIZE),
        .c0_ddr4_s_axi_awvalid(axi_smc_M00_AXI_AWVALID),
        .c0_ddr4_s_axi_bready(axi_smc_M00_AXI_BREADY),
        .c0_ddr4_s_axi_bresp(axi_smc_M00_AXI_BRESP),
        .c0_ddr4_s_axi_bvalid(axi_smc_M00_AXI_BVALID),
        .c0_ddr4_s_axi_rdata(axi_smc_M00_AXI_RDATA),
        .c0_ddr4_s_axi_rlast(axi_smc_M00_AXI_RLAST),
        .c0_ddr4_s_axi_rready(axi_smc_M00_AXI_RREADY),
        .c0_ddr4_s_axi_rresp(axi_smc_M00_AXI_RRESP),
        .c0_ddr4_s_axi_rvalid(axi_smc_M00_AXI_RVALID),
        .c0_ddr4_s_axi_wdata(axi_smc_M00_AXI_WDATA),
        .c0_ddr4_s_axi_wlast(axi_smc_M00_AXI_WLAST),
        .c0_ddr4_s_axi_wready(axi_smc_M00_AXI_WREADY),
        .c0_ddr4_s_axi_wstrb(axi_smc_M00_AXI_WSTRB),
        .c0_ddr4_s_axi_wvalid(axi_smc_M00_AXI_WVALID),
        .c0_ddr4_ui_clk(ddr4_0_c0_ddr4_ui_clk),
        .c0_ddr4_ui_clk_sync_rst(ddr4_0_c0_ddr4_ui_clk_sync_rst),
        .c0_init_calib_complete(ddr4_0_c0_init_calib_complete),
        .c0_sys_clk_n(C0_SYS_CLK_0_1_CLK_N),
        .c0_sys_clk_p(C0_SYS_CLK_0_1_CLK_P),
        .sys_rst(perst_invert_Res));
  xdma_pcie_ila_readback_0 ila_readback
       (.clk(ddr4_0_c0_ddr4_ui_clk),
        .probe0(wr_addr_0_o_data),
        .probe1(wr_addr_0_o_valid),
        .probe2(wr_addr_0_o_last),
        .probe3(wr_addr_0_m00_axi_error),
        .probe4(wr_addr_0_m00_axi_txn_done));
  xdma_pcie_one_0 one
       (.dout(one_dout));
  xdma_pcie_perst_invert_0 perst_invert
       (.Op1(reset_rtl_0_1),
        .Res(perst_invert_Res));
  xdma_pcie_rst_ddr_0 rst_ddr
       (.aux_reset_in(xdma_reset_invert_Res),
        .dcm_locked(ddr4_0_c0_init_calib_complete),
        .ext_reset_in(ddr4_0_c0_ddr4_ui_clk_sync_rst),
        .mb_debug_sys_rst(zero_1_dout),
        .peripheral_aresetn(Net),
        .slowest_sync_clk(ddr4_0_c0_ddr4_ui_clk));
  xdma_pcie_util_ds_buf_0 util_ds_buf
       (.IBUF_DS_N(diff_clock_rtl_0_1_CLK_N),
        .IBUF_DS_ODIV2(util_ds_buf_IBUF_DS_ODIV2),
        .IBUF_DS_P(diff_clock_rtl_0_1_CLK_P),
        .IBUF_OUT(util_ds_buf_IBUF_OUT));
  xdma_pcie_vio_pcie_0 vio_pcie
       (.clk(xdma_0_axi_aclk),
        .probe_in0(xdma_0_user_lnk_up),
        .probe_in1(xdma_0_axi_aresetn));
  xdma_pcie_vio_readback_0 vio_readback
       (.clk(ddr4_0_c0_ddr4_ui_clk),
        .probe_in0(ddr4_0_c0_init_calib_complete),
        .probe_in1(wr_addr_0_m00_axi_error),
        .probe_out0(vio_readback_probe_out0));
  xdma_pcie_wr_addr_0_0 wr_addr_0
       (.clk(ddr4_0_c0_ddr4_ui_clk),
        .fifo_ready(wr_addr_0_fifo_ready),
        .i_data(axis_data_fifo_0_m_axis_tdata),
        .i_fifo_ready(one_dout),
        .i_last(axis_data_fifo_0_m_axis_tlast),
        .i_valid(axis_data_fifo_0_m_axis_tvalid),
        .m00_axi_aclk(ddr4_0_c0_ddr4_ui_clk),
        .m00_axi_araddr(wr_addr_0_m00_axi_ARADDR),
        .m00_axi_arburst(wr_addr_0_m00_axi_ARBURST),
        .m00_axi_arcache(wr_addr_0_m00_axi_ARCACHE),
        .m00_axi_aresetn(Net),
        .m00_axi_arid(wr_addr_0_m00_axi_ARID),
        .m00_axi_arlen(wr_addr_0_m00_axi_ARLEN),
        .m00_axi_arlock(wr_addr_0_m00_axi_ARLOCK),
        .m00_axi_arprot(wr_addr_0_m00_axi_ARPROT),
        .m00_axi_arqos(wr_addr_0_m00_axi_ARQOS),
        .m00_axi_arready(wr_addr_0_m00_axi_ARREADY),
        .m00_axi_arsize(wr_addr_0_m00_axi_ARSIZE),
        .m00_axi_arvalid(wr_addr_0_m00_axi_ARVALID),
        .m00_axi_awaddr(wr_addr_0_m00_axi_AWADDR),
        .m00_axi_awburst(wr_addr_0_m00_axi_AWBURST),
        .m00_axi_awcache(wr_addr_0_m00_axi_AWCACHE),
        .m00_axi_awid(wr_addr_0_m00_axi_AWID),
        .m00_axi_awlen(wr_addr_0_m00_axi_AWLEN),
        .m00_axi_awlock(wr_addr_0_m00_axi_AWLOCK),
        .m00_axi_awprot(wr_addr_0_m00_axi_AWPROT),
        .m00_axi_awqos(wr_addr_0_m00_axi_AWQOS),
        .m00_axi_awready(wr_addr_0_m00_axi_AWREADY),
        .m00_axi_awsize(wr_addr_0_m00_axi_AWSIZE),
        .m00_axi_awvalid(wr_addr_0_m00_axi_AWVALID),
        .m00_axi_bid(wr_addr_0_m00_axi_BID),
        .m00_axi_bready(wr_addr_0_m00_axi_BREADY),
        .m00_axi_bresp(wr_addr_0_m00_axi_BRESP),
        .m00_axi_bvalid(wr_addr_0_m00_axi_BVALID),
        .m00_axi_error(wr_addr_0_m00_axi_error),
        .m00_axi_init_axi_txn(zero_1_dout),
        .m00_axi_rdata(wr_addr_0_m00_axi_RDATA),
        .m00_axi_rid(wr_addr_0_m00_axi_RID),
        .m00_axi_rlast(wr_addr_0_m00_axi_RLAST),
        .m00_axi_rready(wr_addr_0_m00_axi_RREADY),
        .m00_axi_rresp(wr_addr_0_m00_axi_RRESP),
        .m00_axi_rvalid(wr_addr_0_m00_axi_RVALID),
        .m00_axi_txn_done(wr_addr_0_m00_axi_txn_done),
        .m00_axi_wdata(wr_addr_0_m00_axi_WDATA),
        .m00_axi_wlast(wr_addr_0_m00_axi_WLAST),
        .m00_axi_wready(wr_addr_0_m00_axi_WREADY),
        .m00_axi_wstrb(wr_addr_0_m00_axi_WSTRB),
        .m00_axi_wvalid(wr_addr_0_m00_axi_WVALID),
        .o_data(wr_addr_0_o_data),
        .o_last(wr_addr_0_o_last),
        .o_valid(wr_addr_0_o_valid),
        .rst_n(Net),
        .xdma_valid(vio_readback_probe_out0));
  xdma_pcie_xdma_0_0 xdma_0
       (.axi_aclk(xdma_0_axi_aclk),
        .axi_aresetn(xdma_0_axi_aresetn),
        .cfg_mgmt_addr(zero_19_dout),
        .cfg_mgmt_byte_enable(zero_4_dout),
        .cfg_mgmt_read(zero_1_dout),
        .cfg_mgmt_type1_cfg_reg_access(zero_1_dout),
        .cfg_mgmt_write(zero_1_dout),
        .cfg_mgmt_write_data(zero_32_dout),
        .m_axi_araddr(xdma_0_M_AXI_ARADDR),
        .m_axi_arburst(xdma_0_M_AXI_ARBURST),
        .m_axi_arcache(xdma_0_M_AXI_ARCACHE),
        .m_axi_arid(xdma_0_M_AXI_ARID),
        .m_axi_arlen(xdma_0_M_AXI_ARLEN),
        .m_axi_arlock(xdma_0_M_AXI_ARLOCK),
        .m_axi_arprot(xdma_0_M_AXI_ARPROT),
        .m_axi_arready(xdma_0_M_AXI_ARREADY),
        .m_axi_arsize(xdma_0_M_AXI_ARSIZE),
        .m_axi_arvalid(xdma_0_M_AXI_ARVALID),
        .m_axi_awaddr(xdma_0_M_AXI_AWADDR),
        .m_axi_awburst(xdma_0_M_AXI_AWBURST),
        .m_axi_awcache(xdma_0_M_AXI_AWCACHE),
        .m_axi_awid(xdma_0_M_AXI_AWID),
        .m_axi_awlen(xdma_0_M_AXI_AWLEN),
        .m_axi_awlock(xdma_0_M_AXI_AWLOCK),
        .m_axi_awprot(xdma_0_M_AXI_AWPROT),
        .m_axi_awready(xdma_0_M_AXI_AWREADY),
        .m_axi_awsize(xdma_0_M_AXI_AWSIZE),
        .m_axi_awvalid(xdma_0_M_AXI_AWVALID),
        .m_axi_bid(xdma_0_M_AXI_BID),
        .m_axi_bready(xdma_0_M_AXI_BREADY),
        .m_axi_bresp(xdma_0_M_AXI_BRESP),
        .m_axi_bvalid(xdma_0_M_AXI_BVALID),
        .m_axi_rdata(xdma_0_M_AXI_RDATA),
        .m_axi_rid(xdma_0_M_AXI_RID),
        .m_axi_rlast(xdma_0_M_AXI_RLAST),
        .m_axi_rready(xdma_0_M_AXI_RREADY),
        .m_axi_rresp(xdma_0_M_AXI_RRESP),
        .m_axi_rvalid(xdma_0_M_AXI_RVALID),
        .m_axi_wdata(xdma_0_M_AXI_WDATA),
        .m_axi_wlast(xdma_0_M_AXI_WLAST),
        .m_axi_wready(xdma_0_M_AXI_WREADY),
        .m_axi_wstrb(xdma_0_M_AXI_WSTRB),
        .m_axi_wvalid(xdma_0_M_AXI_WVALID),
        .pci_exp_rxn(xdma_0_pcie_mgt_rxn),
        .pci_exp_rxp(xdma_0_pcie_mgt_rxp),
        .pci_exp_txn(xdma_0_pcie_mgt_txn),
        .pci_exp_txp(xdma_0_pcie_mgt_txp),
        .sys_clk(util_ds_buf_IBUF_DS_ODIV2),
        .sys_clk_gt(util_ds_buf_IBUF_OUT),
        .sys_rst_n(reset_rtl_0_1),
        .user_lnk_up(xdma_0_user_lnk_up),
        .usr_irq_req(zero_1_dout));
  xdma_pcie_xdma_reset_invert_0 xdma_reset_invert
       (.Op1(xdma_0_axi_aresetn),
        .Res(xdma_reset_invert_Res));
  xdma_pcie_zero_1_0 zero_1
       (.dout(zero_1_dout));
  xdma_pcie_zero_19_0 zero_19
       (.dout(zero_19_dout));
  xdma_pcie_zero_32_0 zero_32
       (.dout(zero_32_dout));
  xdma_pcie_zero_4_0 zero_4
       (.dout(zero_4_dout));
endmodule
