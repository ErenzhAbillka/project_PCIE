`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/01 10:43:54
// Design Name: 
// Module Name: read_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module wr_addr #
(
		parameter integer C_M00_AXI_ID_WIDTH	= 1,
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_DATA_WIDTH	= 32
	)

(
    input                       clk,
    input                       rst_n,
    
    input                       i_valid,
    input                       i_last,
    input   [31:0]              i_data,
    output  reg              fifo_ready,
    
    input                   xdma_valid,
    input                   i_fifo_ready,
    output                  o_valid,
    output                  o_last,
    output  [31:0]          o_data,
    
    
    //AXI����    
        input wire  m00_axi_init_axi_txn,
		output wire  m00_axi_txn_done,
		output wire  m00_axi_error,
		input wire  m00_axi_aclk,
		input wire  m00_axi_aresetn,
		output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
		output wire [7 : 0] m00_axi_awlen,
		output wire [2 : 0] m00_axi_awsize,
		output wire [1 : 0] m00_axi_awburst,
		output wire  m00_axi_awlock,
		output wire [3 : 0] m00_axi_awcache,
		output wire [2 : 0] m00_axi_awprot,
		output wire [3 : 0] m00_axi_awqos,
		output wire  m00_axi_awvalid,
		input wire  m00_axi_awready,
		output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
		output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
		output wire  m00_axi_wlast,
		output wire  m00_axi_wvalid,
		input wire  m00_axi_wready,
		input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
		input wire [1 : 0] m00_axi_bresp,
		input wire  m00_axi_bvalid,
		output wire  m00_axi_bready,
		output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
		output wire [7:0] m00_axi_arlen,
		output wire [2 : 0] m00_axi_arsize,
		output wire [1 : 0] m00_axi_arburst,
		output wire  m00_axi_arlock,
		output wire [3 : 0] m00_axi_arcache,
		output wire [2 : 0] m00_axi_arprot,
		output wire [3 : 0] m00_axi_arqos,
		output wire  m00_axi_arvalid,
		input wire  m00_axi_arready,
		input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
		input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
		input wire [1 : 0] m00_axi_rresp,
		input wire  m00_axi_rlast,
		input wire  m00_axi_rvalid,
		output wire  m00_axi_rready          
);

    // Fixed 32-bit AXI master: four beats per packet, 4 KiB write window.
    // clk and m00_axi_aclk MUST be the same clock; this is not a CDC bridge.
    wire reset_n = rst_n & m00_axi_aresetn;
    localparam [1:0] IDLE = 0, ADDRESS = 1, DATA = 2, RESPONSE = 3;
    reg [1:0] state;
    reg [31:0] aw_addr;
    reg [1:0] beat;
    reg write_done;
    reg write_error;
    reg read_error;
    wire aw_ready;
    wire [1:0] b_resp;
    wire b_valid;
    wire [7:0] aw_len = 8'd3;
    wire [2:0] aw_size = 3'd2;
    wire [1:0] aw_burst = 2'b01;
    wire aw_valid = reset_n && (state == ADDRESS);
    wire [31:0] w_data = i_data;
    wire w_valid = reset_n && (state == DATA) && i_valid;
    wire w_last = (beat == 2'd3);
    wire [3:0] w_strb = 4'b1111;
    wire b_ready = reset_n && (state == RESPONSE);

    always @* fifo_ready = reset_n && (state == DATA) && m00_axi_wready;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            aw_addr <= 0;
            beat <= 0;
            write_done <= 0;
            write_error <= 0;
        end else begin
            write_done <= 0;
            case (state)
                IDLE: if (i_valid) state <= ADDRESS;
                ADDRESS: if (aw_valid && aw_ready) begin
                    beat <= 0;
                    state <= DATA;
                end
                DATA: if (w_valid && m00_axi_wready) begin
                    // Preserve AXI burst length even if the source TLAST is wrong.
                    if (i_last != w_last) write_error <= 1;
                    if (w_last) state <= RESPONSE;
                    else beat <= beat + 1'b1;
                end
                RESPONSE: if (b_valid && b_ready) begin
                    write_done <= 1;
                    if (b_resp != 2'b00) write_error <= 1;
                    aw_addr <= (aw_addr == 32'h00000ff0) ? 0 : aw_addr + 32'd16;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // Preserve the original host-to-FPGA readback contract:
    // one four-beat read at 0xF000 per trigger, with byte reversal.
    reg     [31:0]      ar_addr     ;
    reg     [7:0]       ar_len      ;
    reg     [2:0]       ar_size     ;
    reg     [1:0]       ar_burst    ;
    reg                 ar_valid    ; 
    wire                ar_ready    ; 

    wire    [31:0]      r_data      ; 
    wire    [1:0]       r_resp      ;
    wire                r_last      ;
    wire                r_valid     ;
    wire                r_ready     ;

    reg     [2:0]       rd_state_c  ; 
    reg     [2:0]       rd_state_n  ;
    reg     [31:0]      rd_addr_buff;
    wire     [31:0]      rd_data_buff;


    reg     [31:0]      num_rd_cnt  ;

    localparam  WAIT_XDMA   = 0,            //״̬
                RD_ADDR     = 1,
                RD_FIFO     = 2,
                RD_DATA     = 3,
                RD_LAST     = 4,
                RD_STOP     = 5;

    always @ (posedge clk, negedge reset_n) begin  :   R_FMS1
        if (~reset_n)
            rd_state_c <= WAIT_XDMA;
        else
            rd_state_c <= rd_state_n;
    end

    always @ (*) begin  :   R_FMS2
        case (rd_state_c)
            WAIT_XDMA   :   begin
                                if (xdma_valid)                        //��⵽д��� xdma_valid
                                    rd_state_n = RD_ADDR;
                                else
                                    rd_state_n = WAIT_XDMA;
            end

            RD_ADDR :   begin
                            if (ar_valid && ar_ready)
                                rd_state_n = RD_FIFO;
                            else
                                rd_state_n = RD_ADDR;
            end
            
            RD_FIFO :   begin
                            if (r_valid && r_ready && r_last)
                                rd_state_n = RD_STOP;
                            else
                                rd_state_n = RD_FIFO;            
            end 
            
            RD_STOP: begin
                if (!xdma_valid) rd_state_n = WAIT_XDMA;
                else rd_state_n = RD_STOP;
            end
            default :   begin
                            rd_state_n = 0; 
            end

        endcase 
    end

    always @ (posedge clk, negedge reset_n) begin  :   R_FMS3
        if (~reset_n)
            begin
                ar_addr         <= 0;
                ar_burst        <= 0;
                ar_size         <= 0;
                ar_valid        <= 0;
                ar_len          <= 0;

                rd_addr_buff    <= 32'hF000;
            end
        else
            case (rd_state_n)
                WAIT_XDMA   :   begin
                                    ar_valid        <= 0        ;                                  
                end

                RD_ADDR :   begin                               //����ַ��ar��Ϣ
                            
                                ar_valid    <= 1            ;
                                ar_addr     <= rd_addr_buff ;
                                ar_burst    <= 2'b01        ;
                                ar_len      <= 8'd3         ;
                                ar_size     <= 3'b010       ;  
                end
                
                RD_FIFO :   begin
                                ar_valid        <= 0        ;     
                end 

            endcase 
    end
    
    //������ С������ת���
    assign o_data = {   rd_data_buff[7:0]   ,
                        rd_data_buff[15:8]  ,
                        rd_data_buff[23:16] ,
                        rd_data_buff[31:24] 
                    };

    //r_ready ����
    assign r_ready = reset_n && (rd_state_c == RD_FIFO) && i_fifo_ready;
    assign rd_data_buff = r_data;
    assign o_valid = reset_n && (rd_state_c == RD_FIFO) && r_valid;
    assign o_last = o_valid && r_last;

    assign m00_axi_wdata      = w_data        ;
	assign m00_axi_wvalid     = w_valid       ;
	assign m00_axi_wlast      = w_last        ;
	assign m00_axi_wstrb      = w_strb        ;
	
	assign m00_axi_awaddr     = aw_addr       ;
	assign m00_axi_awlen      = aw_len        ;
	assign m00_axi_awsize     = aw_size       ;
	assign m00_axi_awburst    = aw_burst      ;
	assign m00_axi_awvalid    = aw_valid      ;
	assign aw_ready         = m00_axi_awready ;

	assign b_resp           = m00_axi_bresp   ;
	assign b_valid          = m00_axi_bvalid  ;
	assign m00_axi_bready     = b_ready       ;
	
	
	assign m00_axi_araddr     = ar_addr       ;
    assign m00_axi_arlen      = ar_len        ;
    assign m00_axi_arsize     = ar_size       ;
    assign m00_axi_arburst    = ar_burst      ;
    assign m00_axi_arvalid    = ar_valid      ;
    assign ar_ready         = m00_axi_arready ;
    
    assign r_data           = m00_axi_rdata   ;
    assign r_last           = m00_axi_rlast   ;
    assign r_resp           = m00_axi_rresp   ;
    assign r_valid          = m00_axi_rvalid  ;
    assign m00_axi_rready     = r_ready       ;
    
    
        assign m00_axi_txn_done = write_done;
        assign m00_axi_error = write_error | read_error;
        assign m00_axi_awid = 0;
        assign m00_axi_awlock = 0;
        assign m00_axi_awcache = 0;
        assign m00_axi_awprot = 0;
        assign m00_axi_awqos = 0;
        
        assign m00_axi_arid = 0;
       
        assign m00_axi_arlock = 0;
        assign m00_axi_arcache = 0;
        assign m00_axi_arprot = 0;
        assign m00_axi_arqos = 0;
  
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) read_error <= 0;
        else if (r_valid && r_ready && r_resp != 2'b00) read_error <= 1;
    end
endmodule
