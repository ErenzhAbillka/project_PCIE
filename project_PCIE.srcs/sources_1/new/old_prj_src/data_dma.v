module	data_dma(  
	input	wire			clk,
	input	wire			rst,
    input   wire            wr_en,
	input	wire	[31:0]	fifo_data,

	
	input  	wire             M_AXIS_tready,	
	output 	wire	[3:0]    M_AXIS_tkeep,
	output 	wire             M_AXIS_tlast,
	output 	wire             M_AXIS_tvalid,
	output 	wire    [31:0]   M_AXIS_tdata,
	output	wire				rd_en
	
);
reg     [15:0]      data;
reg                 tvalid;
reg     [15:0]      hand_cnt;
reg                 tlast;

reg         wr_en_reg;
wire        wr_en_fall;
assign M_AXIS_tkeep=4'b1111;
assign	rd_en = M_AXIS_tvalid && M_AXIS_tready;
assign	M_AXIS_tvalid = tvalid;
assign  M_AXIS_tlast = tlast;
assign	M_AXIS_tdata = fifo_data;

always@(posedge clk or negedge rst)
	if(rst == 'd0)
	   wr_en_reg <= 'b0;
   else 
        wr_en_reg <= wr_en;
              
assign  wr_en_fall = !wr_en && wr_en_reg;

always@(posedge clk or negedge rst)
	if(rst == 'd0)
	   tvalid <= 1'b0;
   else if(hand_cnt == 'd16319 && M_AXIS_tvalid && M_AXIS_tready)
     tvalid <= 1'b0;
   else if(wr_en_fall == 1'b1)
         tvalid <= 1'b1;
         
always@(posedge clk or negedge rst)
	if(rst == 'd0)
	   hand_cnt <= 'd0;
   else if(hand_cnt == 'd16319 && M_AXIS_tvalid && M_AXIS_tready)
     hand_cnt <= 1'b0;
   else if(M_AXIS_tvalid && M_AXIS_tready)
        hand_cnt <=hand_cnt + 1'b1;
always@(posedge clk or negedge rst)
	if(rst == 'd0)
	   tlast <= 1'b0;
   else if(hand_cnt == 'd16319 && M_AXIS_tvalid && M_AXIS_tready)
        tlast <= 1'b0;
   else if(hand_cnt == 'd16318 && M_AXIS_tvalid && M_AXIS_tready)
        tlast <= 1'b1;

always@(posedge clk or negedge rst)
	if(rst == 'd0)
		data <= 'd0;
	else if(tvalid == 1'd1 &&  M_AXIS_tready)
		data <= data + 1'd1;

endmodule