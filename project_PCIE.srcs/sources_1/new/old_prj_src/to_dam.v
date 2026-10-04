module	to_dma( 
	input	wire			sys_clk,
	input	wire			sys_rst_n,
	input	wire	[31:0]	read_data,
	input  wire            data_valid,
	
	input  	wire            M_AXIS_tready,	
	output 	wire	[3:0]   M_AXIS_tkeep,
	output 	wire             M_AXIS_tlast,
	output 	wire            M_AXIS_tvalid,
	output 	wire    [31:0]  M_AXIS_tdata
    
);
 parameter                    LENGTH = 32640; 
 parameter                    LENGTH_1 = 16320; 
 
reg     [15:0]              wr_en_cnt;
reg     [15:0]              valid_cnt;
reg                         tlast;
reg     [31:0]              t_data;
reg                         t_valid;
reg                         t_valid_reg;

assign M_AXIS_tkeep=4'b1111;
assign	M_AXIS_tlast = tlast;
//assign	M_AXIS_tvalid = t_valid_reg;
//assign	M_AXIS_tdata = t_data;
assign	M_AXIS_tvalid = t_valid;
assign	M_AXIS_tdata = read_data;
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
          t_valid <= 'd0;
    else if(M_AXIS_tready)
        t_valid <= data_valid;
    else 
        t_valid <= 'd0;
 end
 always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
        t_valid_reg <= 'd0;
    else 
        t_valid_reg <= t_valid;
 end
        
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
        t_data <= 'd0;
    else if(t_valid && M_AXIS_tready )
        t_data <= read_data;
    else 
        t_data <= 'd0;
     end
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
        valid_cnt <= 'd0;
    else if (valid_cnt ==( LENGTH_1 -  1) )
        valid_cnt <= 'd0;
    else if (t_valid)
        valid_cnt <= valid_cnt + 1;
    else 
        valid_cnt <= valid_cnt;    
end
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
        tlast <= 'b0;
    else if (valid_cnt ==( LENGTH_1 -  2)) 
        tlast <= 'b1;
    else if ( valid_cnt == ( LENGTH_1 -  1))
        tlast <= 'b0;
    else
        tlast <= 'b0;
end
endmodule
