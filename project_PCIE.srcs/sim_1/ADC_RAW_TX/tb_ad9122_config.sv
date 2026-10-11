`timescale 1ns/1ps
module tb_ad9122_config;
    reg clk=0; always #2.5 clk=~clk;
    reg reset_n=0, request=0, clocks_ready=1;
    wire busy,done,configured,cv,cr; wire [3:0] error_code;
    wire [7:0] revision,level,cd; wire [6:0] ca;
    reg ready=1,rv=0,re=0; reg [7:0] rd=0;
    integer mode=0, pending=0, writes=0, reads=0;
    reg [7:0] regs[0:127]; reg saved_read; reg[6:0] saved_addr;
    reg[7:0] saved_data;
    ad9122_config #(.RESET_HOLD_CYCLES(3),.COMMAND_TIMEOUT_CYCLES(20),.MAX_POLLS(3)) dut(
        .clk(clk),.reset_n(reset_n),.request(request),.clocks_ready(clocks_ready),
        .busy(busy),.done(done),.configured(configured),.error_code(error_code),
        .revision_id(revision),.fifo_level(level),.cmd_valid(cv),.cmd_ready(ready),
        .cmd_read(cr),.cmd_address(ca),.cmd_data(cd),.rsp_valid(rv),.rsp_data(rd),.rsp_error(re));
    always @(posedge clk) begin
        rv<=0; re<=0;
        if (!reset_n) begin pending<=0; end
        else if (cv && ready) begin
            saved_read<=cr; saved_addr<=ca; saved_data<=cd; pending<=2;
            if (cr) reads<=reads+1;
            else begin
                writes<=writes+1;
                if (writes==0 && {ca,cd}!==15'h00a0) $fatal(1,"First write is not reset");
                if (writes==1 && {ca,cd}!==15'h0080) $fatal(1,"Reset not released");
            end
        end else if (pending>0) begin
            pending<=pending-1;
            if (pending==1 && mode!=7) begin
                rv<=1; re<=(mode==8);
                if (saved_read) begin
                    rd<=regs[saved_addr];
                    if (mode==2 && saved_addr==7'h18) rd<=8'h00;
                    if (mode==3 && saved_addr==7'h18 && regs[7'h18]==0) rd<=8'h04;
                    if (mode==1 && saved_addr==7'h1C) rd<=8'h01;
                    if (saved_addr==7'h19) begin
                        if (mode==4) rd<=regs[7'h17]==6 ? 8'h07 : 8'h03;
                        else if (mode==5) rd<=8'h00;
                        else rd<=8'h0F;
                    end
                end else begin
                    regs[saved_addr]<=saved_data;
                    if (saved_addr==7'h18) regs[7'h18]<=saved_data[1] ? 8'h04 : 8'h00;
                end
            end
        end
    end
    task run_case(input integer m,input[3:0] expected_error,input bit r1);
        integer n;
        begin
            @(negedge clk); reset_n=0; request=0; mode=m; writes=0; reads=0;
            for(n=0;n<128;n=n+1) regs[n]=0;
            regs[127]=r1 ? 8'h04 : 8'h0C;
            if(m==6) regs[127]=8'hFF;
            repeat(3) @(negedge clk);
            reset_n=1; request=1;
            @(negedge clk); request=0;
            n=0;
            while(!done && n<1500) begin @(negedge clk); n=n+1; end
            if(!done) $fatal(1,"Sequencer hung mode %0d",m);
            if(error_code!==expected_error || configured!==(expected_error==0))
                $fatal(1,"Mode %0d code %h expected %h ready %b",m,error_code,expected_error,configured);
            if(expected_error==0) begin
                if(regs[3]!=0 || regs[7'h1b]!=8'he4 || regs[7'h1c]!=0 ||
                   regs[7'h1d]!=0 || regs[7'h1e]!=1 || regs[7'h0a]!=0)
                    $fatal(1,"Device write sequence does not select signed word x4 external clock");
                if(regs[7'h16]!=(r1 ? 0 : 2)) $fatal(1,"Revision DCI delay mismatch");
                if(regs[7'h18]!=0) $fatal(1,"FIFO request was not cleared");
                if(m==4 && regs[7'h17]!=6) $fatal(1,"FIFO offset adjustment missing");
            end
            @(negedge clk);
        end
    endtask
    initial begin
        run_case(0,0,0); run_case(0,0,1); run_case(4,0,0);
        run_case(1,5,0); run_case(2,6,0); run_case(3,7,0);
        run_case(5,8,0); run_case(6,4,0); run_case(7,2,0); run_case(8,3,0);
        clocks_ready=0; run_case(0,1,0);
        $display("AD9122_CONFIG_TEST_PASS: sequence/readback/R1/R2/adjust/ack/clear/timeout/errors");
        $finish;
    end
    initial begin #100000; $fatal(1,"Global watchdog"); end
endmodule
