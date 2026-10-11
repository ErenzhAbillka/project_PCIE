`timescale 1ns/1ps
module tb_adc_ramp_checker;
    import adi_pn9_reference::*;
    reg sample_clk=0, ctrl_clk=0, sample_clock_run=1;
    always #4 if (sample_clock_run) sample_clk=~sample_clk;
    always #2.5 ctrl_clk=~ctrl_clk;
    reg reset_n=0, enable=0, valid=0;
    reg [13:0] a=0,b=0;
    wire error;
    wire [31:0] checked_count,error_count;
    wire small_error;
    wire [3:0] small_checked,small_errors;
    adc_pn9_checker dut(.sample_clk(sample_clk),.reset_n(reset_n),
        .enable_async(enable),.sample_valid(valid),.ch_a(a),.ch_b(b),
        .error(error),.checked_count(checked_count),.error_count(error_count));
    adc_pn9_checker #(.SETTLE_SAMPLES(0),.COUNT_WIDTH(4)) saturated_checker(
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
    integer i,j,expected_bad;
    reg [13:0] next_a,next_b,observed_a,observed_b,repeated_a,repeated_b;
    reg [31:0] remembered_checked,remembered_errors,remembered_snapshot;
    task restart;
        begin
            @(negedge sample_clk); reset_n=0;enable=0;valid=0;
            repeat(4) @(negedge sample_clk);
            reset_n=1;enable=1;valid=1;
            next_a=pn9_first(9'h1ff);next_b=pn9_first(9'h163);
            for(j=0;j<60;j=j+1) begin
                pair(next_a,next_b);next_a=pn9_next(next_a);next_b=pn9_next(next_b);
            end
            if(error || error_count!=0) $fatal(1,"Good PN9 setup failed");
        end
    endtask
    // Mode 0 repeat each word twice; 1 skip permanently; 2 one bit;
    // 3 constant legitimate PN9 word; 4 wrong output-format mask.
    task negative_stream(input integer mode);
        begin
            restart();expected_bad=0;remembered_checked=checked_count;
            repeated_a=next_a;repeated_b=next_b;
            for(i=0;i<1024;i=i+1) begin
                case(mode)
                    0: begin
                        observed_a=repeated_a;observed_b=repeated_b;
                        if(i%2==1) begin repeated_a=pn9_next(repeated_a);repeated_b=pn9_next(repeated_b);end
                    end
                    1: begin observed_a=pn9_next(next_a);observed_b=next_b;end
                    2: begin observed_a=next_a ^ ((i==100)?14'h0001:14'h0000);observed_b=next_b;end
                    3: begin observed_a=repeated_a;observed_b=repeated_b;end
                    4: begin observed_a=next_a^14'h2000;observed_b=next_b^14'h2000;end
                endcase
                if(observed_a!=next_a || observed_b!=next_b) expected_bad=expected_bad+1;
                pair(observed_a,observed_b);
                next_a=pn9_next(next_a);next_b=pn9_next(next_b);
            end
            if(!error || expected_bad==0 || error_count!=expected_bad || checked_count-remembered_checked!=1024)
                $fatal(1,"Frozen-state negative mode %0d got checked=%0d errors=%0d expected=%0d",
                       mode,checked_count-remembered_checked,error_count,expected_bad);
        end
    endtask
    initial begin
        restart();
        for(i=0;i<17000;i=i+1) begin
            pair(next_a,next_b);next_a=pn9_next(next_a);next_b=pn9_next(next_b);
        end
        if(error || error_count!=0 || checked_count<17000)
            $fatal(1,"Independent ADI PN9 across full cycles failed: %d %d",checked_count,error_count);
        if(snapshots<100) $fatal(1,"Snapshot bridge did not run");
        $display("PASS: independent ADI PN9, two seeds, >=17000 predictions over 511-word cycles");
        // Both-channel corruption is one error per pair. The next good word
        // must pass without observed-word reseeding or an extra recovery error.
        remembered_errors=error_count;
        pair(next_a^14'h0010,next_b^14'h0200);
        next_a=pn9_next(next_a);next_b=pn9_next(next_b);
        pair(next_a,next_b);next_a=pn9_next(next_a);next_b=pn9_next(next_b);
        if(!error || error_count!=remembered_errors+1) $fatal(1,"Pair error counted twice or predictor reseeded");
        // An active valid gap is itself a failure; expected state stays frozen.
        remembered_errors=error_count;
        @(negedge sample_clk);valid=0;
        repeat(3) begin @(posedge sample_clk);#0.1;@(negedge sample_clk);end
        valid=1;
        // Resume the exact next predicted words. Set them on this falling edge
        // to avoid inserting an extra sample between the gap and pair().
        a=next_a;b=next_b;@(posedge sample_clk);#0.1;
        next_a=pn9_next(next_a);next_b=pn9_next(next_b);
        if(error_count!=remembered_errors+3 || !error) $fatal(1,"Valid gap was filtered or predictor advanced/relocked");
        remembered_errors=error_count;
        @(negedge sample_clk);enable=0;
        a=next_a;b=next_b;next_a=pn9_next(next_a);next_b=pn9_next(next_b);
        for(i=0;i<8;i=i+1) begin pair(next_a,next_b);next_a=pn9_next(next_a);next_b=pn9_next(next_b);end
        @(negedge sample_clk);valid=0;
        remembered_checked=checked_count;
        repeat(8) @(negedge sample_clk);
        if(checked_count!=remembered_checked) $fatal(1,"Disabled checker counted data");
        enable=1;valid=1;next_a=pn9_first(9'h111);next_b=pn9_first(9'h123);
        for(i=0;i<60;i=i+1) begin pair(next_a,next_b);next_a=pn9_next(next_a);next_b=pn9_next(next_b);end
        if(!error || error_count!=remembered_errors) $fatal(1,"Mode reentry did not reseed or lost sticky history: got=%0d expected=%0d",error_count,remembered_errors);
        $display("PASS: one error per pair, frozen-state valid-gap failure, explicit mode reentry preserves history");
        @(negedge sample_clk);sample_clock_run=0;
        repeat(30) @(negedge ctrl_clk);remembered_snapshot=snap_checked;
        repeat(40) @(negedge ctrl_clk);
        if(snap_checked!=remembered_snapshot) $fatal(1,"Snapshot changed while DCO stopped");
        sample_clock_run=1;repeat(80) @(negedge ctrl_clk);
        if(snap_checked==remembered_snapshot) $fatal(1,"Snapshot did not resume");
        $display("PASS: coherent asynchronous snapshots and stopped-clock hold/resume");
        for(integer mode=0;mode<5;mode=mode+1) negative_stream(mode);
        $display("PASS: repeat2, skip, single-bit, constant and wrong-format failures match independent frozen predictions");
        // No all-zero normalized LFSR seed is allowed, even though it predicts
        // an apparently consistent constant sequence forever.
        @(negedge sample_clk);reset_n=0;enable=0;valid=0;
        repeat(4) @(negedge sample_clk);reset_n=1;enable=1;valid=1;
        for(i=0;i<100;i=i+1) pair(14'h3fff,14'h3fff);
        if(!error || error_count==0) $fatal(1,"Zero PN9 seed accepted");
        // Corrupt every bit of a legitimate first word. Feed each corrupted
        // seed only until seeded, so this checks the seed consistency itself.
        for(i=0;i<14;i=i+1) begin
            @(negedge sample_clk);reset_n=0;enable=0;valid=0;
            repeat(4) @(negedge sample_clk);reset_n=1;enable=1;valid=1;
            a=pn9_first(9'h1ff)^(14'h0001<<i);b=pn9_first(9'h163);
            wait(dut.seeded);#0.1;
            if(!error || error_count!=1 || checked_count!=0)
                $fatal(1,"Malformed seed bit %0d escaped initial consistency check",i);
        end
        restart();
        for(i=0;i<100;i=i+1) pair(next_a^14'h0010,next_b^14'h0200);
        if(!small_error || small_checked!=15 || small_errors!=15)
            $fatal(1,"Diagnostic counters wrapped instead of saturating");
        @(negedge sample_clk);reset_n=0;#0.1;
        if(error || checked_count!=0 || error_count!=0 || snap_checked!=0 || snap_errors!=0)
            $fatal(1,"System reset failed to clear diagnostics");
        $display("PASS: zero/bit-corrupted seeds rejected, pair counters saturate, reset clears history");
        $display("ADC_RAMP_CHECKER_TEST_PASS"); // Historical runner marker; test is PN9.
        $finish;
    end
    initial begin #500000;$fatal(1,"ADC PN9 unit test timeout");end
endmodule

