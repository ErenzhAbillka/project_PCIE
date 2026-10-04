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
		parameter integer C_M00_AXI_DATA_WIDTH	= 32,
		parameter integer C_M00_AXI_AWUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_WUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_RUSER_WIDTH	= 0,
		parameter integer C_M00_AXI_BUSER_WIDTH	= 0
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
		output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
		output wire  m00_axi_awvalid,
		input wire  m00_axi_awready,
		output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
		output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
		output wire  m00_axi_wlast,
		output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
		output wire  m00_axi_wvalid,
		input wire  m00_axi_wready,
		input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
		input wire [1 : 0] m00_axi_bresp,
		input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
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
		output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
		output wire  m00_axi_arvalid,
		input wire  m00_axi_arready,
		input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
		input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
		input wire [1 : 0] m00_axi_rresp,
		input wire  m00_axi_rlast,
		input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser,
		input wire  m00_axi_rvalid,
		output wire  m00_axi_rready          
);

    wire         aw_ready;
    wire         w_ready;
 
    
    wire [1:0]   b_resp;
    wire         b_valid;
 
    reg [31:0]  aw_addr;
    reg [7:0]   aw_len;
    reg [2:0]   aw_size;
    reg [1:0]   aw_burst;
    reg         aw_valid;

    reg [31:0]  w_data;
    reg         w_last;
    reg [3:0]   w_strb;
    reg         w_valid;
 
    reg         b_ready ;  
    
    reg           [31:0]    aw_addr_cnt;

    reg            [1:0]       state, state_next;
    localparam            s0 = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;
    
    always @ (posedge clk , negedge rst_n)
    begin
        if (!rst_n)
            state <= s0;
        else 
            state <= state_next;
    end 
    
    always @(*)
    begin
        case (state)
            s0  :   begin
                        if (i_valid)
                            state_next = s1;
                        else
                            state_next = s0;
                    end 
                    
            s1  :   begin                       //д���ַ��Ϣ
                        if (aw_ready)
                            state_next = s2;
                        else
                            state_next = s1;
                    end 
            s2  :   begin                       //��⵽aw_ready
                        if (i_last)
                            state_next = s3;
                        else
                            state_next = s2;
                    end
            s3  :   begin
                        state_next = s0;
                    end 
            default : begin
                        state_next = 'bx;
                      end 
        endcase
    end 
    
    always @ (posedge clk , negedge rst_n)
    begin
        if (!rst_n)
        begin
           aw_len <= 8'd0;
           aw_size <= 3'd0;
           aw_burst <= 2'b0;
           aw_addr <= 0;
           aw_valid <= 0;
           aw_addr_cnt <= 0;
           
        end
        else case (state_next)
            s0  :   begin
                        
                    end 
            s1  :   begin
                        aw_len <= 8'd3;
                        aw_size <= 3'd2;
                        aw_burst <= 2'b01;
                        aw_valid <= 1;
                        aw_addr <= aw_addr_cnt;
                    end
                    
             s2 :  begin
                        aw_valid <= 0;
                    end 
            s3  :   begin
                        if (aw_addr_cnt <= 32'd4096)
                            aw_addr_cnt <= aw_addr_cnt + 32'd16;
                        else
                            aw_addr_cnt <= 0;
                    end 
            endcase
    end
    
    always @(*) begin
        if (state == 2)
            begin
                w_last = i_last;
                w_valid = i_valid;
                w_data = i_data;
                w_strb = 4'b1111; 
                fifo_ready = m00_axi_wready  ; 
            end
        else
            begin
                w_last = 0;
                w_valid = 0;
                w_data = 0;
                w_strb = 4'b1111; 
                fifo_ready          = 0 ;
            end
    
    
    end  
    
    always @ (posedge clk, negedge rst_n)
    begin
        if (!rst_n)
            b_ready <= 0;
        else 
            b_ready <= 1;
    end 
    
    
     //����ַ������

    reg     [31:0]      ar_addr     ;
    reg     [7:0]       ar_len      ;
    reg     [2:0]       ar_size     ;
    reg     [1:0]       ar_burst    ;
    reg                 ar_valid    ; 
    wire                ar_ready    ; 

    wire    [31:0]      r_data      ; 
    wire                r_resp      ;
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

    always @ (posedge clk, negedge rst_n) begin  :   R_FMS1
        if (~rst_n)
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
                            if (ar_ready)
                                rd_state_n = RD_FIFO;
                            else
                                rd_state_n = RD_ADDR;
            end
            
            RD_FIFO :   begin
                            if (!xdma_valid)
                                rd_state_n = WAIT_XDMA;
                            else
                                rd_state_n = RD_FIFO;            
            end 
            
            default :   begin
                            rd_state_n = 0; 
            end

        endcase 
    end

    always @ (posedge clk, negedge rst_n) begin  :   R_FMS3
        if (~rst_n)
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
    assign r_ready = i_fifo_ready;
    assign rd_data_buff = r_data;
    assign o_valid = r_valid;
    assign o_last = r_last;

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
    
    
        assign m00_axi_txn_done = 0;
        assign m00_axi_error = 0;
        assign m00_axi_awid = 0;
        assign m00_axi_awlock = 0;
        assign m00_axi_awcache = 0;
        assign m00_axi_awprot = 0;
        assign m00_axi_awqos = 0;
        assign m00_axi_awuser = 0;
        assign m00_axi_wuser = 0;
        
        assign m00_axi_arid = 0;
       
        assign m00_axi_arlock = 0;
        assign m00_axi_arcache = 0;
        assign m00_axi_arprot = 0;
        assign m00_axi_arqos = 0;
        assign m00_axi_aruser = 0;
  
endmodule
