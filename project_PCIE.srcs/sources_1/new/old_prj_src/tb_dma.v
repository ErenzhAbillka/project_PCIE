module	tb_dma(  
	input	wire			clk,
	input	wire			rst,
	input  wire            data_valid,
    input   wire   [15:0]   last_data,
	output 	wire    [15:0]  cnt_out,
//	output 	reg             last_vld,
	input  	wire            M_AXIS_tready,	
	output 	wire	[3:0]   M_AXIS_tkeep,
	output 	wire             M_AXIS_tlast,
	output 	wire            M_AXIS_tvalid,
	output 	wire    [31:0]  M_AXIS_tdata
);
reg	[19:0]	aom_cnt;
reg	[15:0]	data_cnt;
//reg         data_valid;
reg [15:0]  data;
reg         aom_pulse;
reg         pw_flag_reg1;
reg         pw_flag_reg2;
reg         pw_flag_reg3;
reg [15:0]   tx_cnt;
wire		data_last;
//wire        pw_flag;
//assign  pw_flag = 1'b1;

 parameter                    LENGTH = 32640; 
assign M_AXIS_tkeep=4'b1111;
assign	M_AXIS_tvalid = data_valid;
assign	M_AXIS_tlast = data_last;
assign	M_AXIS_tdata = data;
assign cnt_out = data_cnt;
//always@(posedge clk or negedge rst)
//	if(rst == 'd0) begin
//	   pw_flag_reg1 <= 1'd0;
//	   pw_flag_reg2 <= 1'd0;
//	   pw_flag_reg3 <= 1'd0;
//   end
//   else begin
//        pw_flag_reg1 <= pw_flag;     
//        pw_flag_reg2 <= pw_flag_reg1;
//        pw_flag_reg3 <= pw_flag_reg2;  
//   end  
   


//always@(posedge clk or negedge rst)
//	if(rst == 'd0)
//		aom_cnt <= 'd0;
//    else if(pw_flag_reg3 == 1'd0 || aom_cnt >= 'd249999)
//        aom_cnt <= 'd0;
//	else
//		aom_cnt <= aom_cnt + 1'd1;

//always@(posedge clk or negedge rst)
//	if(rst == 'd0)
//		aom_pulse <= 1'd0;
////	else if(tx_cnt >= 'd50)
////		aom_pulse <= 1'd0;
//	else if(aom_cnt >= 'd249974)
//		aom_pulse <= 1'd1;
//	else 
//		aom_pulse <= 1'd0;

assign	data_last = (data_cnt >= (LENGTH - 1) & data_valid == 1'd1);


//always@(posedge clk or negedge rst)
//	if(rst == 'd0)
//	   last_vld<='d0;
//	 else if(data_last)
//	    last_vld<='d1;
//always@(posedge clk or negedge rst)
//	if(rst == 'd0)
//		data_valid <= 1'd0;
//	else if( data_last == 1'd1)
//		data_valid <= 1'd0;
//	else if(aom_pulse == 1'd1)
//		data_valid <= 1'd1;

always@(posedge clk or negedge rst)
	if(rst == 'd0)
		data_cnt <= 'd0;
	else if(data_last == 1'd1)
		data_cnt <= 'd0;
	else if(data_valid == 1'd1 && M_AXIS_tready)
		data_cnt <= data_cnt + 1'd1;
    else
        data_cnt <= data_cnt;

always@(posedge clk or negedge rst)
	if(rst == 'd0)
		data <= 'd0;
	else if(data_valid == 1'd1 &&  M_AXIS_tready)
//		data <= data + 1'd1;
		data <= last_data;
    else
        data <= data;

//always@(posedge clk or negedge rst)
//	if(rst == 'd0)
//	   tx_cnt <= 'd0;
//    else if(tx_cnt >= 'd50)
//        tx_cnt <= 'd50;
//    else if(data_last == 1'd1)
//        tx_cnt <= tx_cnt + 1'd1;


endmodule