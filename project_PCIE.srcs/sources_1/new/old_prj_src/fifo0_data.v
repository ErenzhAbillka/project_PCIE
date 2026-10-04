module fifo0_data(
    input wire                  sys_clk,
    input wire                  sys_rst_n,                   
    input wire          [15:0]  amp,
    output reg          [15:0]  fifo0_data
    );
    
    always@(posedge	sys_clk or negedge	sys_rst_n)
	if(sys_rst_n == 'd0)
	   fifo0_data <='d0;
	else 
	   fifo0_data <= amp;
	   
endmodule
