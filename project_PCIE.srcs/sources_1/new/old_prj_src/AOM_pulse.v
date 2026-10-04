module  AOM_pulse(
    input                    sys_clk ,
    input                    sys_rst_n,
   
   
    output      reg                  AOM_pulse,//Êä³ö¸øAOMµÄ
    output      reg                  data_valid,
    output      wire         [15:0]        out_valid_cnt,
    output      wire         [15:0]        out_AOM_cnt
);

 parameter                    LENGTH = 32640; 
 
 reg        [15:0]            valid_cnt;
 reg       [15:0]            AOM_cnt;
 assign     out_valid_cnt = valid_cnt;
 assign     out_AOM_cnt   = AOM_cnt;
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n==1'b0)
        AOM_cnt<=1'd0;
    else if(AOM_cnt>=16'd62499)
        AOM_cnt<=16'd0;     
    else
         AOM_cnt<=AOM_cnt+1;
end
/***************************AOM_pulse*********************************/  
always@(posedge sys_clk or  negedge sys_rst_n)begin
    if(sys_rst_n==1'b0)    
        AOM_pulse<=0;
    else if(AOM_cnt==62499)
        AOM_pulse<=0;
    else if(AOM_cnt>=62475)
        AOM_pulse<=1;
    else 
        AOM_pulse<=AOM_pulse;
end 
/***************************data_valid*********************************/  
always@(posedge sys_clk or  negedge sys_rst_n)begin
    if(sys_rst_n==1'b0)    
        valid_cnt<=0;
    else if(valid_cnt==LENGTH-1)
        valid_cnt<=0;
    else if(data_valid==1)
        valid_cnt<=valid_cnt + 1;
    else 
        valid_cnt<=valid_cnt;
end 
always@(posedge sys_clk or  negedge sys_rst_n)begin
    if(sys_rst_n==1'b0)    
        data_valid<=0;
    else if(valid_cnt==LENGTH-1)
        data_valid<=0;
    else if(AOM_pulse==1)
        data_valid<= 1;
    else 
        data_valid<=data_valid;
end 

endmodule 