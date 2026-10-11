`timescale 1ns/1ps
module tb_tgd_tx_sample_path;
    reg clk=0; always #4 clk=~clk;
    reg reset_n=0,run=0,arm=0,configured=1,approved=1,kill=0;
    wire active,valid,gate,start,enable,started,done;
    wire [31:0] index;
    wire signed [15:0] i_data,q_data;
    integer gates=0,starts=0;
    reg counting=0;
    tgd_tx_sample_path dut(.sample_clk(clk),.reset_n(reset_n),.run(run),
        .hardware_arm(arm),.tx_kill(kill),.dac_configured(configured),
        .waveform_approved(approved),.active(active),.sample_valid(valid),
        .sweep_gate(gate),.sweep_start(start),.sample_index(index),
        .i_sample(i_data),.q_sample(q_data),.tx_data_enable(enable),
        .shot_started(started),.shot_done(done));
    always @(posedge clk) begin
        #0.1;
        if(counting && reset_n) begin
            if(start) starts=starts+1;
            if(gate) begin
                if(!valid || index!=gates) $fatal(1,"lost/repeated chirp sample %0d %0d",gates,index);
                if(index==0 && (i_data!==16'sd30000 || q_data!==0))
                    $fatal(1,"phase-zero first sample missing");
                if(index==2499 && i_data===0 && q_data===0) $fatal(1,"last chirp sample truncated");
                gates=gates+1;
            end else if(i_data!==0 || q_data!==0) $fatal(1,"ungated IQ leaked");
        end
    end
    initial begin
        repeat(5) @(negedge clk); reset_n=1;run=1;
        repeat(8) @(negedge clk);
        if(started || enable || i_data!==0 || q_data!==0) $fatal(1,"default disarm failed");
        counting=1;arm=1;
        wait(done); @(negedge clk);
        if(gates!=2500 || starts!=1 || !started || !enable) $fatal(1,"incomplete single shot");
        // Keep run asserted for >2 periods. Kill/release cannot re-arm it.
        repeat(35000) @(negedge clk);
        kill=1;repeat(3) @(negedge clk);
        if(enable) $fatal(1,"kill failed");
        kill=0;repeat(35000) @(negedge clk);
        if(gates!=2500 || starts!=1 || active) $fatal(1,"single shot automatically repeated");
        counting=0;reset_n=0;repeat(3) @(negedge clk);reset_n=1;
        wait(start);@(negedge clk);
        if(!started) $fatal(1,"reset did not re-arm");
        kill=1;#0.1;if(enable) $fatal(1,"active shot kill failed");
        kill=0;repeat(5) @(negedge clk);
        if(!started) $fatal(1,"kill cleared consumed-shot latch");
        $display("AD9122_SAMPLE_TEST_PASS: full 2500 samples/last IQ/single shot/kill/reset");
        $finish;
    end
    initial begin #1000000; $fatal(1,"sample test watchdog");end
endmodule
