`timescale 1ns/1ps
// Actual production top, ADC primitives, DAC frontend/SPI/PHY, LFM and ROM.
// Behavioral AD9643/AD9122 devices provide ideal pins and real shared tri SDIO.
module tb_top_shared_spi_tx;
    reg ctrl_clk=0,dco=0,rst_n=0,acquire=0,tx_enable=0,tx_abort=0;
    always #2.5 ctrl_clk=~ctrl_clk;
    always #4 dco=~dco;
    reg [13:0] adc_pins=0,pattern_a=14'd10,pattern_b=14'd3011;
    reg pending_ramp=0,committed_ramp=0;
    always @(negedge dco) begin
        #3.3; adc_pins=pattern_a;
        pattern_a=committed_ramp ? pattern_a-14'd1 : pattern_a+14'd3;
    end
    always @(posedge dco) begin
        #3.3; adc_pins=pattern_b;
        pattern_b=committed_ramp ? pattern_b-14'd1 : pattern_b+14'd7;
    end
    tri sdio;
    wire sclk,adc_cs,clock_cs,dac_cs,adc_ready,adc_valid,tx_ready,tx_fault,locked;
    wire [31:0] status,stream_data;
    wire [1:0] stream_user;
    wire stream_valid,sample_clk;
    wire [15:0] dp,dn;
    wire dcp,dcn,fp,fn;
    top_layer #(.SPI_CLK_HZ(50000000),.POWERUP_DELAY_CYCLES(4),
        .CLOCK_SETTLE_CYCLES(4),.ADC_TEST_CYCLES(300),.ADC_SETTLE_CYCLES(24),
        .TX_SINE_MEM("sine_4096.mem")) dut(
        .ctrl_clk(ctrl_clk),.rst_n(rst_n),.acquisition_enable(acquire),
        .adc_test_enable(1'b0),.adc_test_active(),.adc_test_error(),
        .adc_test_checked_count(),.adc_test_error_count(),.adc_test_config_locked(locked),
        .tx_enable(tx_enable),.tx_abort(tx_abort),.tx_init_done(tx_ready),
        .tx_fault(tx_fault),.tx_status(status),.dac_data_p(dp),.dac_data_n(dn),
        .dac_dci_p(dcp),.dac_dci_n(dcn),.dac_frame_p(fp),.dac_frame_n(fn),
        .stream_ready(1'b1),.stream_data(stream_data),.stream_valid(stream_valid),
        .stream_user(stream_user),.aom_pulse(),.adc_fifo_aresetn(),.adc_overflow(),
        .acquisition_active(),.adc_data_clk_p(dco),.adc_data_clk_n(~dco),
        .data_pin_p(adc_pins),.data_pin_n(~adc_pins),.adc_data_ch1(),.adc_data_ch2(),
        .sys_clk(sample_clk),.adc_data_valid(adc_valid),.init_done(adc_ready),
        .device_spi_sclk(sclk),.device_spi_sda(sdio),.adk_spi_csb(clock_cs),
        .adc_spi_csb(adc_cs),.dac_spi_csb(dac_cs),.adc_sync());
    // Shorten only a passive reset delay, keeping all production sequencing.
    defparam dut.tx_frontend_inst.RESET_HOLD_CYCLES=4;

    reg [23:0] adc_packet=0;
    integer adc_bits=0,adc_words=0,clock_words=0;
    always @(negedge adc_cs or negedge clock_cs) begin adc_packet=0;adc_bits=0;end
    always @(posedge sclk) if(!adc_cs || !clock_cs) begin
        adc_packet={adc_packet[22:0],sdio};adc_bits=adc_bits+1;
    end
    always @(posedge adc_cs) if(rst_n && adc_bits!=0) begin
        if(adc_bits!=24) $fatal(1,"ADC shared SPI length wrong");
        adc_words=adc_words+1;
        if(adc_packet[23:8]==16'h000d) pending_ramp=adc_packet[7:0]==8'h0f;
        if(adc_packet==24'h00ff01) committed_ramp=pending_ramp;
    end
    always @(posedge clock_cs) if(rst_n && adc_bits!=0) begin
        if(adc_bits!=24) $fatal(1,"Clock shared SPI length wrong");
        clock_words=clock_words+1;
    end

    reg [7:0] regs[0:127];
    reg [15:0] dac_packet=0;
    reg [6:0] dac_address=0;
    reg dac_read=0,read_drive=0,read_bit=0;
    integer dac_bits=0,dac_words=0,dac_reads=0,i;
    assign sdio=(!dac_cs && read_drive) ? read_bit : 1'bz;
    always @(negedge dac_cs) begin
        dac_bits=0;dac_packet=0;dac_read=0;read_drive=0;
        if(!adc_ready || !adc_valid || committed_ramp || dut.adc_test_active)
            $fatal(1,"DAC initialization acquired bus before stable normal ADC mode");
    end
    always @(posedge sclk) if(!dac_cs) begin
        if(dac_bits>=8 && dac_read) begin
            if(dut.dac_oe || dut.spi_sdio_buffer.T!==1'b1 || sdio!==read_bit || dut.spi_sdi!==read_bit)
                $fatal(1,"DAC readback did not traverse tri-state IOBUF/O path");
        end
        dac_packet={dac_packet[14:0],sdio};
        if(dac_bits==7) begin dac_read=dac_packet[7];dac_address=dac_packet[6:0];end
        dac_bits=dac_bits+1;
    end
    // Mode-0 turnaround: device begins driving only after instruction fall 8.
    always @(negedge sclk) if(!dac_cs && dac_read) begin
        if(dac_bits>=8 && dac_bits<16) begin
            #0.01; read_bit=regs[dac_address][15-dac_bits]; read_drive=1;
        end else if(dac_bits==16) begin #0.01;read_drive=0;end
    end
    always @(posedge dac_cs) begin
        read_drive=0;
        if(rst_n && dac_bits!=0) begin
            if(dac_bits!=16) $fatal(1,"DAC shared SPI length wrong");
            dac_words=dac_words+1;
            if(dac_read) dac_reads=dac_reads+1;
            else begin
                regs[dac_address]=dac_packet[7:0];
                if(dac_address==7'h18) regs[dac_address]=dac_packet[1] ? 8'h06 : 8'h00;
            end
        end
    end
    always @(adc_cs or clock_cs or dac_cs) begin
        #0.02;
        if(rst_n && ((!adc_cs && !clock_cs) || (!adc_cs && !dac_cs) || (!clock_cs && !dac_cs)))
            $fatal(1,"ADC, AD9516 and DAC chip selects overlapped");
    end
    integer launches=0,nonzero_halfwords=0,chirp_pairs=0;
    reg ready_observed=0,shot_previous=0;
    always @(posedge ctrl_clk) begin
        if(!rst_n) ready_observed<=0;
        else begin
            if(tx_ready) ready_observed<=1;
            if(tx_enable && locked && !ready_observed && !tx_ready)
                $fatal(1,"Acquisition run bypassed DAC ready return handshake");
        end
    end
    always @(posedge sample_clk or negedge rst_n) begin
        if(!rst_n || !dut.adc_fifo_aresetn) begin shot_previous<=0;launches=0;chirp_pairs=0;end
        else begin
            if(dut.tx_shot_started && !shot_previous) begin
                launches=launches+1;
                if(!ready_observed || !dut.dac_sample_ready || !locked)
                    $fatal(1,"First waveform preceded DAC sample_ready/control acknowledgement");
            end
            shot_previous<=dut.tx_shot_started;
            if(dut.tx_sample_inst.sample_valid && dut.tx_sample_inst.sweep_gate) chirp_pairs=chirp_pairs+1;
        end
    end
    always @(posedge sample_clk or negedge sample_clk) begin
        #0.1;
        if(rst_n && dp!=0) begin
            nonzero_halfwords=nonzero_halfwords+1;
            if(!tx_enable || !ready_observed || !dut.tx_shot_started)
                $fatal(1,"Unexpected DAC data while disabled/unready/unstarted");
        end
    end
    task reset_system;
        begin
            @(negedge ctrl_clk);rst_n=0;acquire=0;tx_enable=0;tx_abort=0;
            pending_ramp=0;committed_ramp=0;
            repeat(45) @(negedge ctrl_clk);
            rst_n=1;
            wait(adc_ready);repeat(20) @(negedge ctrl_clk);
        end
    endtask
    integer first_dac_words,first_adc_words,first_clock_words,first_nonzero;
    initial begin
        for(i=0;i<128;i=i+1) regs[i]=0;
        regs[7'h7f]=8'h0c;regs[7'h19]=8'h0f;
        reset_system();
        repeat(1000) @(negedge ctrl_clk);
        if(dac_words!=0 || launches!=0 || dp!==16'd0 || tx_ready || tx_fault)
            $fatal(1,"Default disabled TX was not silent");
        $display("PASS: default TX disabled has zero DAC SPI transactions and zero data");
        first_adc_words=adc_words;first_clock_words=clock_words;
        @(negedge ctrl_clk);tx_enable=1;acquire=1;
        wait(tx_ready);wait(locked);wait(dut.tx_shot_started);
        if(dac_words!=31 || dac_reads!=10 || status[23:16]!=8'h0c || status[15:8]!=8'h0f || tx_fault)
            $fatal(1,"Real shared-SDIO initialization/readbacks failed: status=%h writes=%d reads=%d",status,dac_words,dac_reads);
        if(adc_words!=first_adc_words || clock_words!=first_clock_words)
            $fatal(1,"ADC/clock SPI changed during DAC initialization");
        wait(nonzero_halfwords>50);
        $display("PASS: exclusive shared SPI and tri-state readback, revision=0C/FIFO=0F; ready precedes run");
        @(negedge ctrl_clk);tx_abort=1;
        repeat(20) @(negedge sample_clk);
        if(!tx_fault || tx_ready || status[7:4]!=4'hf || dp!==16'd0)
            $fatal(1,"TX abort did not latch fault/silence DAC");
        first_dac_words=dac_words;first_nonzero=nonzero_halfwords;
        @(negedge ctrl_clk);tx_abort=0;tx_enable=0;
        repeat(20) @(negedge ctrl_clk);tx_enable=1;
        repeat(65000) @(negedge sample_clk);
        if(!tx_fault || dac_words!=first_dac_words || launches!=1 || nonzero_halfwords!=first_nonzero)
            $fatal(1,"Sticky abort allowed SPI retry or waveform replay");
        $display("PASS: abort stays sticky and cannot resend SPI/waveform after request toggles");
        // A fresh system reset permits exactly one complete 2500-pair chirp.
        reset_system();first_dac_words=dac_words;first_nonzero=nonzero_halfwords;
        @(negedge ctrl_clk);tx_enable=1;acquire=1;
        wait(tx_ready);wait(dut.tx_shot_done);repeat(10) @(negedge sample_clk);
        if(tx_fault || chirp_pairs!=2500 || launches!=1 || nonzero_halfwords==first_nonzero)
            $fatal(1,"One-shot TX01 completion wrong: fault=%b pairs=%d launches=%d nonzero=%d before=%d",tx_fault,chirp_pairs,launches,nonzero_halfwords,first_nonzero);
        if(dac_words!=first_dac_words+31) $fatal(1,"Second epoch DAC initialization count wrong");
        first_nonzero=nonzero_halfwords;
        repeat(65000) @(negedge sample_clk);
        if(launches!=1 || chirp_pairs!=2500 || nonzero_halfwords!=first_nonzero || dp!==16'd0)
            $fatal(1,"Held run replayed a completed waveform");
        $display("PASS: system reset re-arms one complete 2500-pair TX01 chirp, held run never replays");
        $display("TOP_SHARED_SPI_TX_TEST_PASS");
        $finish;
    end
    initial begin #1800000;$fatal(1,"Shared-SPI top integration timeout");end
endmodule
