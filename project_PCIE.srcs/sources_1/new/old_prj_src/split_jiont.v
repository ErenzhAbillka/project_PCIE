
module split_jiont(
    input                       clk,
    input   [23:0]              data,
    input                       reset,
    output  reg [47:0]          pinjie_data
    );
    wire in[7:0];
    wire out[31:0];
    
always@(posedge clk or  negedge reset)
    if(reset == 1'b0)
        pinjie_data<=0;
        else
          pinjie_data<={{24{data[23]}},data[23:0]};
  
endmodule
