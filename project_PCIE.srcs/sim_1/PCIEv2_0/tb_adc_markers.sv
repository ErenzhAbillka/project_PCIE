`timescale 1ns/1ps
module tb_adc_markers;
    reg sample_clk=0, ctrl_clk=0;
    always #4 sample_clk=~sample_clk;
    always #2.5 ctrl_clk=~ctrl_clk;
    reg reset_n=0, enable=0, sample_valid=1, output_ready=0;
    reg [13:0] a=0,b=0;
    wire [31:0] source_data, output_data;
    wire [1:0] source_user, output_user;
    wire aom;
    wire source_valid, source_ready, output_valid, overflow, active;
    adc_stream_source source(.sample_clk(sample_clk),.reset_n(reset_n),
        .sample_valid(sample_valid),.enable_async(enable),.ch_a(a),.ch_b(b),
        .stream_ready(source_ready),.stream_data(source_data),
        .stream_valid(source_valid),.stream_user(source_user),.aom_pulse(aom),.overflow(overflow),.active(active));
    das_marker_fifo fifo(.s_axis_aclk(sample_clk),.s_axis_aresetn(reset_n),
        .s_axis_tdata(source_data),.s_axis_tuser(source_user),.s_axis_tvalid(source_valid),.s_axis_tready(source_ready),
        .m_axis_aclk(ctrl_clk),.m_axis_tdata(output_data),
        .m_axis_tuser(output_user),.m_axis_tvalid(output_valid),.m_axis_tready(output_ready));
    reg [31:0] expected[0:80000];
    reg [1:0] tags[0:80000];
    integer pos;
    reg [1:0] src_user_held=0, out_user_held=0;
    integer produced=0, received=0, sample_number=0, previous_sample=-1;
    integer cycle=0, mode=0;
    reg src_stalled=0, out_stalled=0;
    reg [31:0] src_held=0, out_held=0;
    always @(negedge sample_clk) begin
        sample_number=sample_number+1;
        a=(sample_number*37)^14'h1555;
        b=(sample_number*53)^14'h2aaa;
    end
    always @(posedge sample_clk) begin
        if(!reset_n) begin produced=0;previous_sample=-1;src_stalled=0;end
        else begin
            if(src_stalled && (!source_valid || source_data!==src_held || source_user!==src_user_held))
                $fatal(1,"ADC AXIS changed while stalled");
            src_stalled=source_valid&&!source_ready;src_held=source_data;src_user_held=source_user;
            if(source.active && source.enable_sync[1] && !overflow && sample_valid &&
               (!source_valid || source_ready)) begin
                if(previous_sample>=0 && sample_number!=previous_sample+1)
                    $fatal(1,"Nonconsecutive samples before overflow");
                previous_sample=sample_number;
                expected[produced]={{2{b[13]}},b,{2{a[13]}},a};
                pos=(produced-64)%31250;
                tags[produced]=produced<64 ? 2'b00 : {pos==16319,pos<16320};
                produced=produced+1;
            end
        end
    end
    always @(negedge ctrl_clk) begin
        cycle=cycle+1;
        case(mode)
            0: output_ready=0;
            1: output_ready=(cycle%5!=0 && cycle%500>=35);
            2: output_ready=1;
        endcase
    end
    always @(posedge ctrl_clk) begin
        if(!reset_n) begin received=0;out_stalled=0;end
        else begin
            if(out_stalled && (!output_valid || output_data!==out_held || output_user!==out_user_held))
                $fatal(1,"FIFO output changed while stalled");
            out_stalled=output_valid&&!output_ready;out_held=output_data;out_user_held=output_user;
            if(output_valid&&output_ready) begin
                if(received>=produced || output_data!==expected[received] || output_user!==tags[received])
                    $fatal(1,"Native async FIFO data/order mismatch at %0d",received);
                received=received+1;
            end
        end
    end
    initial begin
        #250; reset_n=1;
        repeat(100) @(negedge sample_clk);
        if(source_valid || overflow || active || output_valid) $fatal(1,"Disabled source emitted samples");
        enable=1;mode=1;
        wait(produced>=70000);
        @(negedge sample_clk);enable=0;
        repeat(10) @(negedge sample_clk);
        mode=2;
        wait(received==produced);
        repeat(20) @(negedge ctrl_clk);
        if(overflow || active || source_valid || output_valid || produced<70000)
            $fatal(1,"Continuous streaming/disable drain failed");
        $display("PASS: %0d consecutive signed A/B pairs through real 125-to-200 MHz async FIFO, stalls and clean stop",received);
        reset_n=0;enable=0;mode=0;
        repeat(30) @(negedge sample_clk);reset_n=1;
        repeat(30) @(negedge sample_clk);enable=1;
        wait(overflow);
        repeat(20) @(negedge sample_clk);
        if(active || produced<4096 || produced>4100) $fatal(1,"Overflow did not stop at FIFO capacity: %0d",produced);
        enable=0; mode=2;
        wait(received==produced);
        repeat(30) @(negedge ctrl_clk);
        if(!overflow || output_valid || source_valid) $fatal(1,"Overflow latch or pending-word drain failed");
        enable=1;
        repeat(30) @(negedge sample_clk);
        if(active || source_valid) $fatal(1,"Stream restarted across a lost sample without reset");
        $display("PASS: FIFO-full overflow latches, preserves queued words, and blocks restart until reset");
        reset_n=0;
        repeat(30) @(negedge sample_clk);reset_n=1;
        mode=2;
        wait(received>=100);
        if(overflow) $fatal(1,"Reset failed to clear overflow");
        $display("DAS_ADC_MARKER_FIFO_TEST_PASS");
        $finish;
    end
    initial begin #2000000;$fatal(1,"Timeout");end
endmodule
