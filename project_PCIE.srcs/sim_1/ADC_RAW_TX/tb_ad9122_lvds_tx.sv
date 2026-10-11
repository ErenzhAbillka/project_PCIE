`timescale 1ns/1ps
module tb_ad9122_lvds_tx;
    reg clk=0; always #4 clk=~clk;
    reg fclk=0; initial begin #2;forever #4 fclk=~fclk;end
    reg reset=1,enable=0,valid=1;
    reg signed[15:0] i=16'h1234,q=16'habcd;
    wire[15:0] dp,dn;wire cp,cn,fp,fn;
    ad9122_lvds_tx dut(.sample_clk(clk),.forward_clk(fclk),.reset(reset),
        .data_enable(enable),.sample_valid(valid),.i_sample(i),.q_sample(q),
        .dac_data_p(dp),.dac_data_n(dn),.dac_dci_p(cp),.dac_dci_n(cn),
        .dac_frame_p(fp),.dac_frame_n(fn));
    task check_pair(input[15:0] exp_i,input[15:0] exp_q);
        begin
            @(posedge cp); #0.1;
            if(dp!==exp_i || dn!==~exp_i || fp!==0 || fn!==1 || cn!==0)
                $fatal(1,"I/DCI high mismatch %h/%h expected %h",dp,dn,exp_i);
            @(negedge cp); #0.1;
            if(dp!==exp_q || dn!==~exp_q || cn!==1)
                $fatal(1,"Q/DCI low mismatch %h expected %h",dp,exp_q);
        end
    endtask
    initial begin
        #250;@(negedge clk);reset=0;
        repeat(6) @(negedge clk);check_pair(0,0);
        @(negedge clk);enable=1;repeat(2) @(negedge clk);
        repeat(4) check_pair(16'h1234,16'habcd);
        @(negedge clk);valid=0;repeat(2) @(negedge clk);check_pair(0,0);
        @(negedge clk);valid=1;enable=0;repeat(2) @(negedge clk);check_pair(0,0);
        $display("AD9122_PHY_TEST_PASS: real UltraScale primitives/I-high/Q-low/DCI+90/zero gate");$finish;
    end
    initial begin #2000;$fatal(1,"PHY watchdog");end
endmodule
