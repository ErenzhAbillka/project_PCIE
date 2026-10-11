`timescale 1ns/1ps
module tb_adc_ramp_checker;
    reg sample_clk=0, ctrl_clk=0, sample_clock_run=1;
    always #4 if (sample_clock_run) sample_clk=~sample_clk;
    always #2.5 ctrl_clk=~ctrl_clk;
    reg reset_n=0, enable=0, valid=0;
    reg [13:0] a=0,b=0;
    wire error;
    wire [31:0] checked_count,error_count;
    wire small_error;
    wire [3:0] small_checked,small_errors;
    adc_ramp_checker dut(.sample_clk(sample_clk),.reset_n(reset_n),
        .enable_async(enable),.sample_valid(valid),.ch_a(a),.ch_b(b),
        .error(error),.checked_count(checked_count),.error_count(error_count));
    adc_ramp_checker #(.SETTLE_SAMPLES(0),.COUNT_WIDTH(4)) saturated_checker(
        .sample_clk(sample_clk),.reset_n(reset_n),.enable_async(enable),
        .sample_valid(valid),.ch_a(a),.ch_b(b),.error(small_error),
        .checked_count(small_checked),.error_count(small_errors));

    reg [31:0] source_checked=0,source_errors=32'hffffffff;
    reg source_error=0;
    wire snap_error;
    wire [31:0] snap_checked,snap_errors;
    adc_test_snapshot #(.REFRESH_CYCLES(7)) bridge(
        .ctrl_clk(ctrl_clk),.ctrl_reset_n(reset_n),.sample_clk(sample_clk),
        .sample_reset_n(reset_n),.source_error(source_error),
        .source_checked_count(source_checked),.source_error_count(source_errors),
        .error(snap_error),.checked_count(snap_checked),.error_count(snap_errors));
    always @(posedge sample_clk or negedge reset_n) begin
        if (!reset_n) begin
            source_checked<=0; source_errors<=32'hffffffff; source_error<=0;
        end else begin
            source_checked<=source_checked+32'h01010101;
            source_errors<=~(source_checked+32'h01010101);
            source_error<=~source_checked[0];
        end
    end
    integer snapshots=0;
    reg [31:0] last_snapshot=0;
    always @(negedge ctrl_clk) if (reset_n && snap_checked!=0) begin
        if (snap_errors !== ~snap_checked || snap_error !== snap_checked[0])
            $fatal(1,"Torn CDC snapshot: %h %h %b",snap_checked,snap_errors,snap_error);
        if (last_snapshot!=snap_checked) snapshots=snapshots+1;
        last_snapshot=snap_checked;
    end
    task pair(input [13:0] next_a,input [13:0] next_b);
        begin
            @(negedge sample_clk); a=next_a; b=next_b;
            @(posedge sample_clk); #0.1;
        end
    endtask
    integer i;
    reg [13:0] next_a,next_b;
    reg [31:0] remembered_checked,remembered_errors,remembered_snapshot;
    initial begin
        #1; reset_n=0; #23; reset_n=1; enable=1; valid=1;
        next_a=14'd2; next_b=14'd12345;
        for(i=0;i<16450;i=i+1) begin
            pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        end
        if(error || error_count!=0 || checked_count<16384)
            $fatal(1,"Valid decrementing ramps/wrap failed: %d %d",checked_count,error_count);
        $display("PASS: independent A/B seeds and 14-bit wrap, checked=%d",checked_count);
        // A permanent one-code skip produces exactly one bad sample pair.
        next_a=next_a-14'd1;
        pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        for(i=0;i<10;i=i+1) begin
            pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        end
        if(!error || error_count!=1) $fatal(1,"A skip not counted once");
        // B repeat, then continue decrementing from the repeated code.
        next_b=next_b+14'd1;
        pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        if(error_count!=2) $fatal(1,"B repeat not detected");
        // Corrupt both channels together; error_count counts sample pairs.
        next_a=next_a-14'd4; next_b=next_b-14'd7;
        pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        if(error_count!=3) $fatal(1,"Both-channel failure must count as one pair");
        $display("PASS: A skip, B repeat, both-channel fault and sticky error");
        remembered_errors=error_count;
        @(negedge sample_clk); valid=0;
        repeat(6) @(negedge sample_clk);
        next_a=14'd5000; next_b=14'd7777; valid=1;
        for(i=0;i<60;i=i+1) begin
            pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        end
        if(error_count!=remembered_errors || !error)
            $fatal(1,"Invalid-data gap must reseed and retain diagnostic history");
        @(negedge sample_clk); enable=0; valid=0;
        repeat(6) @(negedge sample_clk);
        remembered_checked=checked_count;
        repeat(10) @(negedge sample_clk);
        if(checked_count!=remembered_checked) $fatal(1,"Disabled checker counted data");
        next_a=14'd33; next_b=14'd999; enable=1; valid=1;
        for(i=0;i<60;i=i+1) begin
            pair(next_a,next_b); next_a=next_a-14'd1; next_b=next_b-14'd1;
        end
        if(error_count!=remembered_errors || !error) $fatal(1,"Mode change lost history");
        $display("PASS: invalid/reconfiguration reseed and persistent history");
        // Stop sample clock: outstanding CDC request must not tear/advance counts.
        @(negedge sample_clk); sample_clock_run=0;
        repeat(30) @(negedge ctrl_clk);
        remembered_snapshot=snap_checked;
        repeat(40) @(negedge ctrl_clk);
        if(snap_checked!=remembered_snapshot) $fatal(1,"Snapshot changed while DCO stopped");
        sample_clock_run=1;
        repeat(80) @(negedge ctrl_clk);
        if(snap_checked==remembered_snapshot || snapshots<100)
            $fatal(1,"CDC snapshot failed to resume");
        $display("PASS: coherent asynchronous snapshots and stopped-clock hold/resume");
        @(negedge sample_clk); reset_n=0; enable=0; valid=0;
        #1;
        if(error || checked_count!=0 || error_count!=0 || snap_checked!=0 || snap_errors!=0)
            $fatal(1,"System reset failed to clear diagnostics");
        #16; reset_n=1; enable=1; valid=1; a=123; b=456;
        for(i=0;i<100;i=i+1) pair(14'd123,14'd456);
        if(!small_error || small_checked!=15 || small_errors!=15)
            $fatal(1,"Diagnostic counters wrapped instead of saturating");
        if(!error || error_count<50) $fatal(1,"Constant code falsely passed as ramp");
        $display("PASS: reset clear, constant-code failure, counter saturation");
        $display("ADC_RAMP_CHECKER_TEST_PASS");
        $finish;
    end
    initial begin #500000; $fatal(1,"ADC ramp unit test timeout"); end
endmodule
