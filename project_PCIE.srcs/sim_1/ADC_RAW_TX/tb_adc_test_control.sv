`timescale 1ns/1ps
// Digital controller test: adc_driver and IOBUF are behavioral stand-ins below.
// This validates SPI transactions, mode/stream gating and diagnostics, not I/O
// timing, actual MMCM/IDELAY behavior or PCB signal integrity.
module tb_adc_test_control;
    import adi_pn9_reference::*;
    reg ctrl_clk=0, sample_clk=0;
    always #2.5 ctrl_clk=~ctrl_clk;
    always #4 sample_clk=~sample_clk;
    reg rst_n=0, acquisition_enable=0, test_enable=0, inject_a_error=0;
    reg [13:0] sample_a=14'd1234,sample_b=14'd9876;
    wire [31:0] stream_data,checked_count,error_count;
    wire [1:0] stream_user;
    wire stream_valid,init_done,test_active,test_error,config_locked;
    wire spi_sclk,adc_csb,clock_csb,dac_csb,adc_valid,overflow;
    tri spi_sdio;
    top_layer #(.SPI_CLK_HZ(50000000),.POWERUP_DELAY_CYCLES(4),
        .CLOCK_SETTLE_CYCLES(4),.ADC_TEST_CYCLES(2000),.ADC_SETTLE_CYCLES(24),
        .TRACE_PERIOD(128),.TRACE_POINTS(64),.AOM_WIDTH(4)) dut(
        .ctrl_clk(ctrl_clk),.rst_n(rst_n),.acquisition_enable(acquisition_enable),
        .adc_test_enable(test_enable),.adc_test_active(test_active),
        .adc_test_error(test_error),.adc_test_checked_count(checked_count),
        .adc_test_error_count(error_count),.adc_test_config_locked(config_locked),
        .adc_spi_readback(),
        .tx_enable(1'b0),.tx_abort(1'b0),.tx_init_done(),.tx_fault(),.tx_status(),
        .dac_data_p(),.dac_data_n(),.dac_dci_p(),.dac_dci_n(),.dac_frame_p(),.dac_frame_n(),
        .stream_ready(1'b1),.stream_data(stream_data),.stream_valid(stream_valid),
        .stream_user(stream_user),.aom_pulse(),.adc_fifo_aresetn(),
        .adc_overflow(overflow),.acquisition_active(),
        .adc_data_clk_p(sample_clk),.adc_data_clk_n(~sample_clk),
        .data_pin_p(sample_a ^ (inject_a_error ? 14'd1 : 14'd0)),.data_pin_n(sample_b),
        .adc_data_ch1(),.adc_data_ch2(),.sys_clk(),.adc_data_valid(adc_valid),
        .init_done(init_done),.device_spi_sclk(spi_sclk),.device_spi_sda(spi_sdio),
        .adk_spi_csb(clock_csb),.adc_spi_csb(adc_csb),.dac_spi_csb(dac_csb),.adc_sync());

    wire committed_ramp;
    wire [31:0] adc_words,adc_reads;
    tb_ad9643_spi_model adc_model(.reset_n(rst_n),.sclk(spi_sclk),.cs_n(adc_csb),
        .master_t(dut.spi_sdio_buffer.T),.master_sdi(dut.spi_sdi),.sdio(spi_sdio),
        .committed_ramp(committed_ramp),.write_count(adc_words),.read_count(adc_reads));
    reg [23:0] observed_word=0;
    integer observed_bits=0,clock_words=0,PN9_writes=0,normal_writes=0;
    always @(negedge clock_csb) begin
        observed_word=0; observed_bits=0;
    end
    always @(posedge spi_sclk) begin
        if (!clock_csb) begin
            if(!adc_csb && !clock_csb) $fatal(1,"SPI devices selected together");
            observed_word={observed_word[22:0],spi_sdio};
            observed_bits=observed_bits+1;
        end
    end
    always @(posedge clock_csb) if(rst_n && observed_bits!=0) begin
        if(observed_bits!=24) $fatal(1,"AD9516 write length wrong");
        clock_words=clock_words+1;
    end
    always @(posedge adc_csb) if(rst_n && adc_model.bits==24 && !adc_model.reading) begin
        case(adc_model.packet[23:8])
            16'h0005: if(adc_model.packet[7:0]!=8'h03) $fatal(1,"Both ADC channels not selected");
            16'h000d: begin
                if(adc_model.packet[7:0]==8'h06) PN9_writes=PN9_writes+1;
                else if(adc_model.packet[7:0]==8'h00) normal_writes=normal_writes+1;
                else $fatal(1,"Unexpected ADC test mode");
            end
            16'h0014: if(adc_model.packet[7:0]!=8'h05) $fatal(1,"ADC test inversion/coding changed");
            16'h0016: if(adc_model.packet[7:0]!=8'h00) $fatal(1,"ADC A/B interleave/DCO changed");
        endcase
    end
    reg previous_test=0;
    always @(negedge sample_clk) begin
        if(committed_ramp) begin
            sample_a<=previous_test ? pn9_next(sample_a) : pn9_first(9'h1ff);
            sample_b<=previous_test ? pn9_next(sample_b) : pn9_first(9'h163);
        end else begin sample_a<=sample_a+14'd3; sample_b<=sample_b+14'd7; end
        previous_test<=committed_ramp;
    end
    always @(posedge ctrl_clk) if(rst_n) begin
        if(!dac_csb) $fatal(1,"ADC control unexpectedly selected DAC");
        if(stream_valid && !config_locked) $fatal(1,"Startup/reconfiguration test leaked into stream");
    end
    integer prior_words,prior_PN9_writes;
    reg waveform_started=0;
    always @(posedge sample_clk) begin
        if(!rst_n) waveform_started<=0;
        else if(dut.waveform_run && !waveform_started) begin
            waveform_started<=1;
            #0.1;
            if(!stream_valid || !stream_user[0])
                $fatal(1,"waveform_run did not start on the first warmup-qualified ADC trace point");
        end
    end
    reg [31:0] prior_checked;
    reg [13:0] previous_a,previous_b;
    integer stream_pairs;
    initial begin
        #1; rst_n=0; #30; rst_n=1;
        wait(test_active);
        if(init_done || config_locked || !adc_valid) $fatal(1,"Startup PN9 gating wrong");
        repeat(1600) @(negedge ctrl_clk);
        if(init_done || checked_count<100 || error_count!=0 || test_error)
            $fatal(1,"Startup PN9 checker did not run, checked=%d errors=%d",checked_count,error_count);
        $display("PASS: startup PN9 captured and checked before init_done (%d pairs)",checked_count);
        wait(init_done); repeat(20) @(negedge ctrl_clk);
        if(test_error || error_count!=0 || test_active || config_locked || stream_valid || committed_ramp || clock_words!=76 || adc_words!=23 || adc_reads!=14)
            $fatal(1,"Default normal initialization wrong: clock=%d ADC=%d",clock_words,adc_words);
        $display("PASS: 76 clock writes, 20 startup ADC writes, 3 normal mode writes; normal default");
        prior_checked=checked_count;
        @(negedge ctrl_clk); test_enable=1;
        wait(!init_done); if(config_locked) $fatal(1,"Mode switch incorrectly locked run");
        wait(init_done); repeat(1400) @(negedge ctrl_clk);
        if(!test_active || !committed_ramp || checked_count<=prior_checked || test_error || adc_words!=26 || adc_reads!=21)
            $fatal(1,"Persistent pre-run PN9 failed");
        $display("PASS: persistent PN9 selectable after power-up before acquisition");
        @(negedge ctrl_clk); test_enable=0;
        wait(!init_done); wait(init_done); repeat(20) @(negedge ctrl_clk);
        if(test_error || error_count!=0 || test_active || committed_ramp || config_locked || adc_words!=29 || adc_reads!=28)
            $fatal(1,"Return to normal before run failed");
        prior_PN9_writes=PN9_writes;
        @(negedge ctrl_clk); test_enable=1; acquisition_enable=1;
        repeat(3) @(negedge ctrl_clk);
        if(init_done || config_locked || stream_valid)
            $fatal(1,"Simultaneous mode/start bypassed required reconfiguration");
        wait(init_done); wait(config_locked); wait(stream_valid);
        if(!test_active || !committed_ramp || PN9_writes!=prior_PN9_writes+1 || adc_words!=32 || adc_reads!=35)
            $fatal(1,"Acquisition started in stale ADC mode");
        stream_pairs=0;
        @(negedge sample_clk);
        previous_a=stream_data[13:0]; previous_b=stream_data[29:16];
        repeat(300) begin
            @(negedge sample_clk);
            if(stream_valid) begin
                if(stream_data[13:0] !== pn9_next(previous_a) || stream_data[29:16] !== pn9_next(previous_b))
                    $fatal(1,"Persistent PN9 stream pair order/codes wrong");
                if(stream_data[15:14] !== {2{stream_data[13]}} || stream_data[31:30] !== {2{stream_data[29]}})
                    $fatal(1,"A-low/B-high signed packing wrong");
                previous_a=stream_data[13:0]; previous_b=stream_data[29:16];
                stream_pairs=stream_pairs+1;
            end
        end
        if(stream_pairs!=300 || overflow || !waveform_started) $fatal(1,"Continuous PN9 stream interrupted");
        $display("PASS: simultaneous mode/start settles first; stable PN9 streams A low/B high");
        prior_words=adc_words;
        @(negedge ctrl_clk); test_enable=0; acquisition_enable=0;
        repeat(1600) @(negedge ctrl_clk);
        if(!config_locked || !test_active || !init_done || adc_words!=prior_words || !stream_valid || overflow)
            $fatal(1,"Run lock allowed mode write or spliced stream");
        $display("PASS: mode and acquisition requests cannot change running SPI/stream");
        @(negedge sample_clk); inject_a_error=1;
        @(negedge sample_clk); inject_a_error=0;
        repeat(1400) @(negedge ctrl_clk);
        if(!test_error || error_count==0) $fatal(1,"Injected ADC data error missing from coherent snapshot");
        $display("PASS: injected capture error reaches ctrl-domain status/count snapshot");
        @(negedge ctrl_clk); rst_n=0;
        repeat(5) @(negedge ctrl_clk);
        if(test_error || checked_count!=0 || error_count!=0 || config_locked || init_done || overflow)
            $fatal(1,"System reset failed to clear diagnostics/run lock");
        $display("ADC_TEST_CONTROL_TEST_PASS");
        $finish;
    end
    initial begin #250000; $fatal(1,"ADC controller test timeout"); end
endmodule

module IOBUF(input I,input T,output O,inout IO);
    assign IO=T ? 1'bz : I;
    assign O=IO;
endmodule

module adc_driver #(parameter integer INPUT_DELAY_TAPS=10,
                    parameter real SAMPLE_PHASE_DEG=123.750)(
    input ctrl_clk,rst,capture_enable,adc_data_clk_p,adc_data_clk_n,
    input [13:0] data_pin_p,data_pin_n,
    output [13:0] adc_data_out_ch1,adc_data_out_ch2,
    output adc_data_clk_bufg,adc_data_valid,output dac_forward_clk);
    reg [3:0] capture_sync=0;
    always @(posedge adc_data_clk_p or posedge rst or negedge capture_enable)
        if(rst || !capture_enable) capture_sync<=0;
        else capture_sync<={capture_sync[2:0],capture_enable};
    assign adc_data_clk_bufg=adc_data_clk_p;
    assign adc_data_valid=capture_sync[3];
    assign adc_data_out_ch1=data_pin_p;
    assign adc_data_out_ch2=data_pin_n;
    assign dac_forward_clk=adc_data_clk_p;
endmodule
