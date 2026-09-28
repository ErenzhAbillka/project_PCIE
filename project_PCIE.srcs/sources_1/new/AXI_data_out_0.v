module AXI_data_out_0(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            fifo_ready,     // FIFO准备信号

    output  reg             valid,          // 有效信号
    output  wire             last,           // 最后一个数据信号
    output  wire     [31:0]  data            // 数据信号
    );

    // 设计10位计数器，一个采样点占32位，高位补零
    reg     [9:0]   count;
    reg     [15:0]  lfsr;                   // 线性反馈移位寄存器
    reg             finished;

    // 模拟16位赋值结果，高位16位补零
    assign data = {16'd0, lfsr};

    // 每包4个点，第4个点标记last
    assign last = valid && (count[1:0] == 2'd3);

    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            valid       <= 1'b0;
            // lfsr        <= 16'd0;
            finished    <= 1'b0;
            count       <= 10'd0;
        end 
        else if (fifo_ready) begin 
            valid <= 1'b1;
            
            if (valid && fifo_ready) begin
                if (count == 10'd1023) begin 
                    valid <= 1'b0;
                    finished <= 1'b1;
                end
                else begin 
                    count <= count + 1;

                    // 奇数1 -> 结果为1
                    // 偶数1 -> 结果为0
                    lfsr <= {
                        lfsr[14:0],
                        lfsr[15] ^ lfsr[13] 
                                 ^ lfsr[12] 
                                 ^ lfsr[10]
                    };
                end
            end
        end
    end
endmodule
