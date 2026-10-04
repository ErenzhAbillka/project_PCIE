`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/28 17:22:26
// Design Name: 
// Module Name: tb_AXI_data_out_0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_AXI_data_out_0(

    );
    reg              clk;
    reg              rst_n;
    reg              fifo_ready;
    wire              valid;     
    wire              last;     
    wire   [31:0]     data;

    // 产生100MHz时钟：每5ns翻转一次，周期10ns。
    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;

    // 模拟复位和FIFO接收行为。
    initial begin
        rst_n      = 1'b0;
        fifo_ready = 1'b0;

        // 保持复位4个时钟下降沿。
        repeat (4) @(negedge clk);
        rst_n = 1'b1;

        // 先不允许FIFO接收，观察valid是否拉高、
        // data是否保持第一份数据。
        repeat (8) @(negedge clk);
        fifo_ready = 1'b1;

        // 允许接收3个点。
        repeat (3) @(negedge clk);

        // 此时第4个点应该带last，暂停5个周期。
        fifo_ready = 1'b0;
        repeat (5) @(negedge clk);

        // 恢复接收。
        fifo_ready = 1'b1;

        // 再模拟多次暂停与恢复。
        repeat (10) begin
            repeat (7) @(negedge clk);
            fifo_ready = 1'b0;

            repeat (3) @(negedge clk);
            fifo_ready = 1'b1;
        end

        // 留足时间让剩下的数据发送完。
        repeat (1200) @(negedge clk);

        $finish;
    end

    AXI_data_out_0  dut(
    .clk(clk),
    .rst_n(rst_n),
    .fifo_ready(fifo_ready),     // FIFO准备信号

    .valid(valid),          // 有效信号
    .last(last),           // 最后一个数据信号
    .data(data)            // 数据信号
    );
endmodule
