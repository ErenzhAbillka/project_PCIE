module random_gen(
	input	wire			sys_clk,
	input	wire			sys_rst_n,
	
	output	reg		[15:0]	data
);
parameter KEEP = 2'b00;
parameter SUB	= 2'b01;
parameter ADD	= 2'b10;
parameter MULT	= 2'b11;

reg	[15:0]	cnt;
wire [4:0]	judge;
reg	[1:0]	mode;
	
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 'd0) 
		cnt <= 'd200;
	else
		cnt <= cnt + 1'b1;
		
assign	judge = cnt[3:0] + data[3:0];

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 'd0) 
		mode <= 2'b11;
	else if(judge >= 'd15)
		if(judge <= 'd26)
			mode <= 2'b10;
		else 
			mode <= 2'b11;
	else if(judge >= 'd3)
		mode <= 2'b01;
	else
		mode <= 2'b00;

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 'd0) 
		data <= 'd100;
	else
		case (mode) 
			ADD:
				data <= data + cnt[9:0];
			SUB:
				data <= data - cnt[9:0];
			MULT:
				data <= data <<< 3;
			KEEP:
				data <= data;
		endcase
endmodule

				
			

		




