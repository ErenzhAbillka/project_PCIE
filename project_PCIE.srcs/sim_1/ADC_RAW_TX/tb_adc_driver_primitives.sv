`timescale 1ns/1ps
// Actual UltraScale UNISIM primitives with ideal differential pins. Checks
// DDR lane order, pipeline validity and CLKOUT1's 90-degree relative phase.
// This is an ideal timing model; it does not replace the board eye/tap scan.
module tb_adc_driver_primitives;
    reg ctrl_clk=0,dco=0,rst=1,capture_enable=0;
    always #2.5 ctrl_clk=~ctrl_clk;
    always #4 dco=~dco;
    reg [13:0] pins=0;
    // The B driver executes once before the first A driver; offset its seed.
    reg [13:0] pattern_a=14'd10,pattern_b=14'd3011;
    // AD9643 normal interleave: A before rising DCO; B before falling DCO.
    // Leave 0.7 ns of ideal setup at the unshifted incoming DCO edge.
    always @(negedge dco) begin
        #3.3; pins=pattern_a; pattern_a=pattern_a-14'd1;
    end
    always @(posedge dco) begin
        #3.3; pins=pattern_b; pattern_b=pattern_b-14'd1;
    end
    wire [13:0] a,b;
    wire sample_clk,valid,dac_clk;
    adc_driver dut(.ctrl_clk(ctrl_clk),.rst(rst),.capture_enable(capture_enable),
        .adc_data_clk_p(dco),.adc_data_clk_n(~dco),.data_pin_p(pins),.data_pin_n(~pins),
        .adc_data_out_ch1(a),.adc_data_out_ch2(b),.adc_data_clk_bufg(sample_clk),
        .adc_data_valid(valid),.dac_forward_clk(dac_clk));
    real last_sample_edge=-1000.0;
    integer measured_phase=0;
    always @(posedge sample_clk) last_sample_edge=$realtime;
    always @(posedge dac_clk) if(valid) begin
        if(($realtime-last_sample_edge)<1.99 || ($realtime-last_sample_edge)>2.01)
            $fatal(1,"DAC forwarded phase differs from +90 degrees: %0.3f ns",$realtime-last_sample_edge);
        measured_phase=measured_phase+1;
    end
    integer i;
    reg [13:0] previous_a,previous_b;
    initial begin
        #150; rst=0;
        #1000;
        if(valid) $fatal(1,"Capture valid asserted while disabled");
        capture_enable=1;
        wait(valid);
        repeat(4) @(negedge sample_clk);
        previous_a=a; previous_b=b;
        for(i=0;i<17000;i=i+1) begin
            @(negedge sample_clk);
            if(!valid || a!==(previous_a-14'd1) || b!==(previous_b-14'd1))
                $fatal(1,"Actual primitive capture lost ramp pair: a=%h prev=%h b=%h prev=%h",a,previous_a,b,previous_b);
            if((b-a)!==14'd3000) $fatal(1,"A/B DDR phase/order wrong: a=%h b=%h",a,b);
            previous_a=a; previous_b=b;
        end
        if(measured_phase<16990) $fatal(1,"DAC phase clock did not run continuously");
        $display("PASS: actual IBUFDS/IDELAYE3/IDDRE1 captures A rising/B falling through wrap");
        $display("PASS: actual MMCME3_ADV/BUFG CLKOUT1 remains +2 ns from 125 MHz sys_clk");
        capture_enable=0; #0.1;
        if(valid) $fatal(1,"Capture disable did not asynchronously invalidate pipeline");
        #40; capture_enable=1; wait(valid);
        rst=1; #0.1;
        if(valid) $fatal(1,"ADC reset did not invalidate capture");
        $display("ADC_DRIVER_PRIMITIVES_TEST_PASS");
        $finish;
    end
    initial begin #250000; $fatal(1,"ADC primitive test timeout"); end
endmodule
