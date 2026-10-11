`timescale 1ns/1ps
// Production top, IOBUF and ADC primitives. The ideal ADC SPI device checks
// each read's turnaround and all eight returned bits independently of the DUT.
module tb_adc_spi_readback;
    import adi_pn9_reference::*;
    reg ctrl_clk=0,dco=0,rst_n=0,test_enable=0,acquire=0;
    always #2.5 ctrl_clk=~ctrl_clk;
    always #4 dco=~dco;
    reg [13:0] pins=0,a,b;
    initial begin a=pn9_first(9'h1ff);b=pn9_first(9'h163);end;
    wire committed_ramp;
    always @(negedge dco) begin #3.3;pins=a;a=pn9_next(a);end
    always @(posedge dco) begin #3.3;pins=b;b=pn9_next(b);end
    tri sdio;
    wire sclk,adc_cs,clock_cs,dac_cs,ready,locked;
    wire [63:0] readback;
    wire [31:0] writes,reads;
    wire test_error;
    top_layer #(.SPI_CLK_HZ(50000000),.POWERUP_DELAY_CYCLES(4),
        .CLOCK_SETTLE_CYCLES(4),.ADC_TEST_CYCLES(300),.ADC_SETTLE_CYCLES(24)) dut(
        .ctrl_clk(ctrl_clk),.rst_n(rst_n),.acquisition_enable(acquire),
        .adc_test_enable(test_enable),.adc_test_active(),.adc_test_error(test_error),
        .adc_test_checked_count(),.adc_test_error_count(),.adc_test_config_locked(locked),
        .adc_spi_readback(readback),.tx_enable(1'b0),.tx_abort(1'b0),
        .tx_init_done(),.tx_fault(),.tx_status(),.dac_data_p(),.dac_data_n(),
        .dac_dci_p(),.dac_dci_n(),.dac_frame_p(),.dac_frame_n(),
        .stream_ready(1'b1),.stream_data(),.stream_valid(),.stream_user(),.aom_pulse(),
        .adc_fifo_aresetn(),.adc_overflow(),.acquisition_active(),
        .adc_data_clk_p(dco),.adc_data_clk_n(~dco),.data_pin_p(pins),.data_pin_n(~pins),
        .adc_data_ch1(),.adc_data_ch2(),.sys_clk(),.adc_data_valid(),.init_done(ready),
        .device_spi_sclk(sclk),.device_spi_sda(sdio),.adk_spi_csb(clock_cs),
        .adc_spi_csb(adc_cs),.dac_spi_csb(dac_cs),.adc_sync());
    tb_ad9643_spi_model adc_model(.reset_n(rst_n),.sclk(sclk),.cs_n(adc_cs),
        .master_t(dut.spi_sdio_buffer.T),.master_sdi(dut.spi_sdi),.sdio(sdio),
        .committed_ramp(committed_ramp),.write_count(writes),.read_count(reads));
    always @(posedge ctrl_clk) if(rst_n && adc_model.read_drive && readback[56])
        $fatal(1,"Partial ADC dump was marked valid");
    always @(adc_cs or clock_cs or dac_cs) begin
        #0.02;
        if(rst_n && ((!adc_cs && !clock_cs) || (!adc_cs && !dac_cs) || (!clock_cs && !dac_cs)))
            $fatal(1,"ADC read overlapped another SPI device");
        if(rst_n && adc_cs && clock_cs && dac_cs && dut.spi_sdio_buffer.T!==1'b1)
            $fatal(1,"Idle shared SPI bus was not released");
    end
    task check_dump(input expected_target,input [55:0] expected_bytes,input integer expected_reads);
        begin
            if(readback!=={6'b0,expected_target,1'b1,expected_bytes} || reads!=expected_reads)
                $fatal(1,"ADC dump mismatch: got=%h reads=%d expected=%h/%d",
                    readback,reads,{6'b0,expected_target,1'b1,expected_bytes},expected_reads);
        end
    endtask
    task switch_mode(input mode);
        begin
            @(negedge ctrl_clk);test_enable=mode;
            wait(!ready);#0.1;
            if(readback[56]) $fatal(1,"Mode change retained stale valid ADC dump");
            wait(ready);@(negedge ctrl_clk);
        end
    endtask
    integer saved_reads,saved_writes;
    reg [63:0] saved_dump;
    initial begin
        #1;rst_n=0;#30;rst_n=1;
        wait(readback[56]);@(negedge ctrl_clk);
        check_dump(1'b1,56'h00000506000382,7);
        if(ready || !committed_ramp) $fatal(1,"Startup ramp dump did not precede normal mode");
        wait(ready);@(negedge ctrl_clk);
        check_dump(1'b0,56'h00000500000382,14);
        if(test_error || writes!=23 || committed_ramp) $fatal(1,"Readback changed original ADC write sequence");
        $display("PASS: seven ordered 16+8-bit startup/normal reads, ID=82 and target snapshots");
        // Distinct non-palindromic patterns expose missing/MSB/LSB/reversed bits.
        // These are device-model diagnostics, not a proposed ADC configuration.
        adc_model.regs[8'h0b]=8'ha5;
        adc_model.regs[8'h14]=8'hc3;
        adc_model.regs[8'h16]=8'h96;
        adc_model.regs[8'h17]=8'h5a;
        switch_mode(1'b1);
        check_dump(1'b1,56'h5a96c306a50382,21);
        switch_mode(1'b0);
        check_dump(1'b0,56'h5a96c300a50382,28);
        repeat(100) @(negedge ctrl_clk);
        if(test_error) $fatal(1,"Legal PN9/normal transitions introduced a checker error");
        $display("PASS: all eight read bits survive released SDIO; mode change clears stale valid and refreshes dump");
        @(negedge ctrl_clk);acquire=1;
        wait(locked);@(negedge ctrl_clk);
        saved_reads=reads;saved_writes=writes;saved_dump=readback;
        test_enable=1;
        repeat(1200) @(negedge ctrl_clk);
        if(!ready || reads!=saved_reads || writes!=saved_writes || readback!==saved_dump)
            $fatal(1,"Acquisition lock permitted ADC mode/readback traffic");
        $display("PASS: acquisition lock preserves ADC dump and prevents SPI refresh");
        $display("ADC_SPI_READBACK_TEST_PASS");
        $finish;
    end
    initial begin #180000;$fatal(1,"ADC SPI readback test timeout");end
endmodule
