`timescale 1ns/1ps
// Actual UltraScale UNISIM primitives with ideal differential pins. Checks
// DDR lane order, pipeline validity and CLKOUT1's 90-degree relative phase.
// This is an ideal timing model; it does not replace the board eye/tap scan.
module tb_adc_driver_primitives;
    import adi_pn9_reference::*;
    reg ctrl_clk=0,dco=0,rst=1,capture_enable=0;
    always #2.5 ctrl_clk=~ctrl_clk;
    always #4 dco=~dco;
    reg [13:0] pins=0;
    reg repeat_pairs=0;
    integer dco_cycle=0;
    always @(negedge dco) dco_cycle=dco_cycle+1;
    // B starts at phase194, A at17; B executes one extra word first.
    // The captured lane relationship must therefore remain exactly +178 phases.
    reg [13:0] pattern_a,pattern_b;
    reg [13:0] cycle_words[0:510];
    integer phase_a=0,phase_b=0,expected_bad=0,init_i;
    initial begin
        cycle_words[0]=pn9_first(9'h1ff);
        for(init_i=1;init_i<511;init_i=init_i+1) cycle_words[init_i]=pn9_next(cycle_words[init_i-1]);
        pattern_a=cycle_words[17];pattern_b=cycle_words[194];
    end
    // AD9643 normal interleave: A before rising DCO; B before falling DCO.
    // Leave 0.7 ns of ideal setup at the unshifted incoming DCO edge.
    always @(negedge dco) begin
        #3.3; pins=pattern_a;
        if(!repeat_pairs || dco_cycle[0]) pattern_a=pn9_next(pattern_a);
    end
    always @(posedge dco) begin
        #3.3; pins=pattern_b;
        if(!repeat_pairs || dco_cycle[0]) pattern_b=pn9_next(pattern_b);
    end
    wire [13:0] a,b;
    wire sample_clk,valid,dac_clk;
    adc_driver dut(.ctrl_clk(ctrl_clk),.rst(rst),.capture_enable(capture_enable),
        .adc_data_clk_p(dco),.adc_data_clk_n(~dco),.data_pin_p(pins),.data_pin_n(~pins),
        .adc_data_out_ch1(a),.adc_data_out_ch2(b),.adc_data_clk_bufg(sample_clk),
        .adc_data_valid(valid),.dac_forward_clk(dac_clk));
    reg checker_reset_n=0;
    wire checker_error;
    wire [31:0] checked_count,error_count;
    adc_pn9_checker pn9_check_inst(.sample_clk(sample_clk),.reset_n(checker_reset_n),
        .enable_async(1'b1),.sample_valid(valid),.ch_a(a),.ch_b(b),
        .error(checker_error),.checked_count(checked_count),.error_count(error_count));
    real last_sample_edge=-1000.0;
    integer measured_phase=0,dco_edges=0,sample_edges=0;
    always @(posedge dco) dco_edges=dco_edges+1;
    always @(posedge sample_clk) begin
        if(valid) begin
            if(($realtime-last_sample_edge)<7.99 || ($realtime-last_sample_edge)>8.01)
                $fatal(1,"ADC sample clock period is not the incoming 8 ns DCO period");
            sample_edges=sample_edges+1;
        end
        last_sample_edge=$realtime;
    end
    always @(posedge dac_clk) if(valid) begin
        if(($realtime-last_sample_edge)<1.99 || ($realtime-last_sample_edge)>2.01)
            $fatal(1,"DAC forwarded phase differs from +90 degrees: %0.3f ns",$realtime-last_sample_edge);
        measured_phase=measured_phase+1;
    end
    integer i,prior_dco_edges,prior_sample_edges;
    reg [31:0] prior_checked,prior_errors;
    reg [13:0] previous_a,previous_b;
    initial begin
        #150; rst=0;
        #1000;
        if(valid) $fatal(1,"Capture valid asserted while disabled");
        capture_enable=1;
        wait(valid);
        repeat(4) @(negedge sample_clk);
        checker_reset_n=1;
        prior_dco_edges=dco_edges; prior_sample_edges=sample_edges;
        previous_a=a; previous_b=b;
        for(i=0;i<17000;i=i+1) begin
            @(negedge sample_clk);
            if(!valid || a!==pn9_next(previous_a) || b!==pn9_next(previous_b))
                $fatal(1,"Actual primitive capture lost PN9 pair: a=%h prev=%h b=%h prev=%h",a,previous_a,b,previous_b);
            phase_a=-1;phase_b=-1;
            for(init_i=0;init_i<511;init_i=init_i+1) begin
                if(a==cycle_words[init_i]) phase_a=init_i;
                if(b==cycle_words[init_i]) phase_b=init_i;
            end
            if(phase_a<0 || phase_b<0 || (phase_b-phase_a+511)%511!=178)
                $fatal(1,"A/B DDR phase/order wrong: phases=%0d/%0d",phase_a,phase_b);
            previous_a=a; previous_b=b;
        end
        if(measured_phase<16990) $fatal(1,"DAC phase clock did not run continuously");
        if(dco_edges-prior_dco_edges!=17000 || sample_edges-prior_sample_edges!=17000)
            $fatal(1,"ADC MMCM did not preserve one sample clock cycle per DCO cycle");
        if(checker_error || error_count!=0 || checked_count<16384)
            $fatal(1,"Production checker rejected actual DDR PN9: checked=%d errors=%d",checked_count,error_count);
        $display("PASS: actual IBUFDS/IDELAYE3/IDDRE1 captures A rising/B falling through full PN9 cycles");
        $display("PASS: incoming DCO and sample clock stay 1:1; production checker accepts full-rate DDR PN9");
        $display("PASS: actual MMCME3_ADV/BUFG CLKOUT1 remains +2 ns from 125 MHz sys_clk");
        capture_enable=0; #0.1;
        if(valid) $fatal(1,"Capture disable did not asynchronously invalidate pipeline");
        // Keep real differential DDR pins, but repeat each A/B code for two
        // DCO cycles. This is an injected failure, never an accepted ADC mode.
        checker_reset_n=0; repeat_pairs=1;
        #40; capture_enable=1; wait(valid);
        repeat(8) @(negedge sample_clk);
        checker_reset_n=1;
        wait(checked_count!=0);
        // Compare the production predictor against an independent expected
        // sequence, without adapting to any of the observed repeated words.
        @(negedge sample_clk);prior_checked=checked_count;prior_errors=error_count;
        // The predictor's frozen states identify where this deliberately bad
        // stream was seeded; all future expected words use the ADI equations.
        previous_a=pn9_first(pn9_check_inst.state_a);
        previous_b=pn9_first(pn9_check_inst.state_b);
        expected_bad=0;
        for(i=0;i<1024;i=i+1) begin
            if(a!==previous_a || b!==previous_b) expected_bad=expected_bad+1;
            @(posedge sample_clk);#0.1;
            previous_a=pn9_next(previous_a);previous_b=pn9_next(previous_b);
            @(negedge sample_clk);
        end
        if(checked_count-prior_checked!=1024 || error_count-prior_errors!=expected_bad || expected_bad<1000 || !checker_error)
            $fatal(1,"Two-cycle DDR repeat did not match frozen-reference rejection: checked=%d errors=%d expected=%d sticky=%b",
                checked_count-prior_checked,error_count-prior_errors,expected_bad,checker_error);
        $display("PASS: actual DDR two-cycle repeat rejected over 1024 frozen predictions, errors=%0d",expected_bad);
        rst=1; #0.1;
        if(valid) $fatal(1,"ADC reset did not invalidate capture");
        $display("ADC_DRIVER_PRIMITIVES_TEST_PASS");
        $finish;
    end
    initial begin #250000; $fatal(1,"ADC primitive test timeout"); end
endmodule
