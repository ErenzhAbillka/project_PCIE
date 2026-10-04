module to_adder(
    input wire                  sys_clk,
    input wire                  sys_rst_n,                   
    input wire          [15:0]  subber_s,
    output reg          [15:0]  adder_a
    );
    
    always@(posedge	sys_clk or negedge	sys_rst_n)
	if(sys_rst_n == 'd0)
	   adder_a <='d0;
	else 
	   adder_a <= subber_s;
	   
endmodule
