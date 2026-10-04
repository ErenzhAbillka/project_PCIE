module	fifo2_read( 
	input	wire			sys_clk,
	input	wire			sys_rst_n,
	input	wire	[31:0]	fifo_data,
	input  wire            wr_en,
		
	output	reg				read_en,
    output 	wire    [31:0]   read_data,
    output  wire            data_valid
);
 parameter                    LENGTH = 32640; 
 parameter                    LENGTH_1 = 16320; 
reg     data_valid_reg ;
reg     [15:0]              wr_en_cnt;
reg     [15:0]              rd_en_cnt;
/*always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
        read_data <= 'd0;
    else if (read_en)
        read_data <= fifo_data;
    else
        read_data <= 'd0;
  end  */    
assign              data_valid = read_en;
assign    read_data =  fifo_data;
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n) 
        wr_en_cnt <= 'd0;
    else if(wr_en_cnt ==( LENGTH -  1) )
        wr_en_cnt <= 'd0;
    else if (wr_en)
        wr_en_cnt <= wr_en_cnt + 1;
    else 
        wr_en_cnt <= wr_en_cnt;
end

always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n)
        rd_en_cnt <= 'd0;
    else if (rd_en_cnt == ( LENGTH_1 -  1))
        rd_en_cnt <= 'd0;
    else if (read_en)
        rd_en_cnt <= rd_en_cnt + 1;
end
always @(posedge sys_clk or posedge sys_rst_n) begin
    if (!sys_rst_n) 
          read_en <= 'd0;
      else if (rd_en_cnt == ( LENGTH_1 -  1))
         read_en <= 'd0;
      else if (wr_en_cnt ==( LENGTH -  1))
        read_en <= 'd1;
 end

endmodule
