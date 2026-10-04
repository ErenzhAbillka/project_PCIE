module	dif_acc 
(
	input	wire				sys_clk,
	input	wire				sys_rst_n,
	input	wire				valid,
	input	wire	[15:0]		amp,
	input	wire	[15:0]		fifo0_data,
	input   wire   [15:0]       fifo1_data,
	output	reg		[15:0]		sub_a,
	output	reg		[15:0]		sub_b,
//	output	wire		[15:0]		sub_a,
//	output	wire		[15:0]		sub_b,		
	output	reg			    	fifo0_wren,
	output	reg				    fifo0_rden,	
	output	reg			      	fifo1_wren,
	output	reg				    fifo1_rden,
	output  wire       [15:0]     last_data,
	output	reg				difacc_valid
	
);
parameter       MAX_CNT  = 100;
//四种状态，使用独热码
parameter   IDLE        = 4'b0001;
parameter   ONE         = 4'b0010;
parameter   TWO         = 4'b0100;
parameter   THREE       = 4'b1000;
//reg   define
reg       [3:0]   state;
reg		[6:0]	  acc_cnt;	
reg     [15:0]    amp_reg;
reg     [15:0]    amp_reg1;
reg     [15:0]    amp_reg2;
reg     [15:0]    amp_reg3;

wire               dif_flag;
reg               valid_reg;     
reg               valid_reg2;    //对valid进行打拍
reg               valid_reg3;    //对valid进行打拍
reg               valid_reg4;    //对valid进行打拍
reg               valid_reg5;    //对valid进行打拍
reg     [15:0]           fifo0_data_reg;
wire              valid_fall; 
wire              valid_reg3_fall;
//对valid进行打拍
always@(posedge	sys_clk or negedge sys_rst_n)begin
	if(sys_rst_n == 'd0)begin
		valid_reg <= 'b0;
		valid_reg2 <= 'b0;
		valid_reg3 <= 'b0;
		valid_reg4 <= 'b0;
		valid_reg5 <= 'b0;		
		end
	else begin
		valid_reg <= valid;
		valid_reg2 <=valid_reg;
		valid_reg3 <=valid_reg2;
		valid_reg4 <=valid_reg3;
		valid_reg5 <= valid_reg4;
		end
  end    
assign	valid_reg3_fall = ~valid_reg3 & valid_reg4;//采集valid_reg3的的下降沿用于使减法器每次差分后清零
assign	valid_fall = ~valid_reg4 & valid_reg5;//采集valid的下降沿用于计算条数和输出最总结果
//对输入的瑞利散射数据进行计数
always@(posedge	sys_clk or negedge	sys_rst_n)
	if(sys_rst_n == 'd0)
		acc_cnt <= 'd0;
	else if(valid_fall & acc_cnt >= (MAX_CNT -1))
		acc_cnt <= 'd0;
	else if(valid_fall)
		acc_cnt <= acc_cnt + 1'd1;
        
//第一段状态机，描述当前状态state如何根据输入跳转到下一状态
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;  //任何情况下只要按复位就回到初始状态
    else    case(state)
                IDLE    :   if(acc_cnt == 1)//判断输入情况
                                state <= ONE;//4'b0010;
                            else
                                state <= IDLE;

                ONE     :   if(acc_cnt >= 2 && acc_cnt <=(MAX_CNT -2))
                                state <= TWO;//4'b0100;
                            else
                                state <= ONE;

                TWO     :   if(acc_cnt == (MAX_CNT -1))
                                state <= THREE;
                            else
                                state <= TWO;
                THREE   :   if(acc_cnt == 0)
                                state <= IDLE;
                            else
                                state <= THREE;                
                //如果状态机跳转到编码的状态之外也回到初始状态
                default :       state <= IDLE;
            endcase
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        fifo0_wren <= 1'b0;
        fifo0_rden <= 1'b0;
        fifo1_wren <= 1'b0;
        fifo1_rden <= 1'b0;
        end
    else    if(state == IDLE)begin
        fifo0_wren <= valid;
        fifo0_rden <= 1'b0;
        fifo1_wren <= 1'b0;
        fifo1_rden <= 1'b0;
        end
    else    if(state == ONE)begin
        fifo0_wren <= valid;
        fifo0_rden <= valid_reg;
        fifo1_wren <= valid_reg5;
        fifo1_rden <= 1'b0;
        end
    else    if(state == TWO)begin
        fifo0_wren <= valid;
        fifo0_rden <= valid_reg;
        fifo1_wren <= valid_reg5;
        fifo1_rden <= valid_reg2;
        end
     else    if(state == THREE)begin
        fifo0_wren <= 1'b0;
        fifo0_rden <= valid_reg;
        fifo1_wren <= 1'b0;
        fifo1_rden <= valid_reg2;
        end
    else begin
        fifo0_wren <= fifo0_wren;
        fifo0_rden <= fifo0_rden;    
        fifo1_wren <= fifo1_wren;    
        fifo1_rden <= fifo1_rden; 
        end

//       
always@(posedge	sys_clk or negedge	sys_rst_n)
	if(sys_rst_n == 'd0)begin
		amp_reg <= 'd0;
        amp_reg1 <= 'd0;
        amp_reg2 <= 'd0;
        end
	else begin
		amp_reg <= amp;		
        amp_reg1 <= amp_reg;
        amp_reg2 <= amp_reg1 ;
        end
always@(posedge	sys_clk or negedge	sys_rst_n)
    if(!sys_rst_n)
       fifo0_data_reg<= 'b0;
    else 
         fifo0_data_reg<= fifo0_data;
assign  dif_flag =(amp_reg2 >= fifo0_data)? 1 : 0;
//assign  sub_a =  fifo0_data ;
//assign  sub_b =  amp_reg2 ;
always@(posedge	sys_clk or negedge	sys_rst_n)begin
	if(sys_rst_n == 'd0)begin
	   	sub_a <= 'd0;
	   	sub_b <= 'd0;
	   	end
	else if (valid_reg3_fall)begin
	   sub_a <= 'd0;
	   sub_b <= 'd0;
	   end
	 else if (state == IDLE)begin
	       if(valid_reg3)begin
	           sub_b <= 'd0;
	           sub_a <= amp_reg2;
	           end
//	       else begin
	           
//	           end
	   end
   else if (dif_flag && valid_reg3)begin
        sub_a <= amp_reg2;
        sub_b <= fifo0_data;end
    else if ((dif_flag == 0) && valid_reg3 )begin
        sub_a <= fifo0_data;
        sub_b <= amp_reg2;
    end
    else begin 
        sub_a <= 'd0;  
        sub_b <= 'd0;  
        end
end

//assign  sub_a = (dif_flag) ? amp_reg2 : fifo0_data ;
//assign  sub_b = (dif_flag) ? fifo0_data : amp_reg2 ;

// assign	difacc_valid = (acc_cnt >= (MAX_CNT -1)) ?  fifo1_rden : 1'd0;
 assign	last_data = (difacc_valid) ?  fifo1_data : 'd0;
always@(posedge	sys_clk or negedge	sys_rst_n)
	if(sys_rst_n == 'd0)
		difacc_valid <= 'd0;
	else if(acc_cnt >= (MAX_CNT -1))
		difacc_valid <= valid_reg5;
    else 
        difacc_valid <= 'd0;
    
endmodule 