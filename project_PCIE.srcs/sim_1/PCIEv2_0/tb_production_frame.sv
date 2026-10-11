`timescale 1ns/1ps
module tb_production_frame;
    reg clk=0, reset_n=0, valid=0;
    always #2.5 clk=~clk;
    reg [31:0] data=0; reg [1:0] user=0;
    wire ready, fv,fl,err,clipped;
    wire [31:0] fd,groups;
    wire [1:0] banks;
    integer cycles=0,received=0,k,ph;
    reg [31:0] expect_word;
    wire fr=cycles%5!=0;
    das_trace_process dut (.clk(clk),.reset_n(reset_n),.amp_phase_data(data),.sample_user(user),
        .sample_valid(valid),.sample_ready(ready),.phase_start_cfg(16'd16000),.input_fault(1'b0),
        .frame_data(fd),.frame_valid(fv),.frame_last(fl),.frame_ready(fr),.format_error(err),
        .groups_completed(groups),.banks_full(banks),.accumulator_clipped(clipped));
    always @(posedge clk) if(reset_n) begin
        cycles<=cycles+1;
        if(err||clipped) $fatal(1,"Unexpected production status");
        if(fv&&fr) begin
            expect_word=0;
            case(received)
                0:expect_word=32'h44415331; 1:expect_word=0; 2:expect_word=16384;
                3:expect_word=16320; 4:expect_word=100; 5:expect_word=16000;
                6:expect_word=100; 7:expect_word=10000; 8:expect_word=125000000;
                9:expect_word=50000000; 10:expect_word=7; 11:expect_word=13;
                12:expect_word=0; 13:expect_word=31250; 14:expect_word=1; 15:expect_word=32'hffffffff;
                16380:expect_word=32'h434f4d54; 16381:expect_word=0;
                16382:expect_word=32'hffffffff; 16383:expect_word=32'h454e4421;
                default: if(received>=16 && received<16336) begin
                    k=received-16; ph=k<10000 ? (k/100)*200+16000+(k%100) : 0;
                    expect_word={ph[15:0],16'd2};
                end
            endcase
            if(fd!==expect_word || fl!==(received==16383)) $fatal(1,"Production word %0d: got %x expected %x",received,fd,expect_word);
            received=received+1;
        end
    end
    integer t,p,a,angle;
    initial begin
        repeat(16) @(negedge clk); reset_n=1;
        for(t=0;t<100;t=t+1) begin
            for(p=0;p<16320;p=p+1) begin
                a=1000+(p%256)+3*t; angle=t*200+p;
                @(negedge clk); data={angle[15:0],a[15:0]};user={p==16319,1'b1};valid=1;
                @(posedge clk); while(!ready) @(posedge clk);
            end
            @(negedge clk);valid=0;repeat(4) @(negedge clk);
        end
        wait(received==16384);repeat(4) @(posedge clk);
        if(groups!=1) $fatal(1,"Production group count");
        $display("DAS_PRODUCTION_FRAME_PASS: 100 x 16320 samples, ROI at 16000, all 16384 frame words checked");
        $finish;
    end
    initial begin #20000000;$fatal(1,"Production timeout");end
endmodule
