`timescale 1ns / 1ps
module tb_adc;
    reg ctrl_clk = 0;
    always #2.5 ctrl_clk = ~ctrl_clk;
    reg rst_n = 0;
    reg dco = 0;
    reg dco_run = 0;
    reg [13:0] data_p = 0;
    wire [13:0] ch1, ch2;
    wire sample_clk, valid, done, sclk, adk_cs, adc_cs, dac_cs, adc_sync;
    tri sdio;
    top_layer #(
        .SPI_CLK_HZ(10000000),
        .POWERUP_DELAY_CYCLES(20),
        .CLOCK_SETTLE_CYCLES(40),
        .ADC_TEST_CYCLES(80),
        .ADC_SETTLE_CYCLES(20)
    ) dut (
        .ctrl_clk(ctrl_clk), .rst_n(rst_n),
        .acquisition_enable(1'b1), .stream_ready(1'b1),
        .adc_data_clk_p(dco), .adc_data_clk_n(~dco),
        .data_pin_p(data_p), .data_pin_n(~data_p),
        .adc_data_ch1(ch1), .adc_data_ch2(ch2), .sys_clk(sample_clk),
        .adc_data_valid(valid), .init_done(done),
        .device_spi_sclk(sclk), .device_spi_sda(sdio),
        .adk_spi_csb(adk_cs), .adc_spi_csb(adc_cs),
        .dac_spi_csb(dac_cs), .adc_sync(adc_sync)
    );

    // Isolate the DDR/SPI logic from analog MMCM lock/phase simulation.
    // Real MMCM clock insertion and phase are checked by routed timing.
    initial begin
        force dut.adc_driver_inst.adc_clk_raw = dco;
        force dut.adc_driver_inst.adc_clk_locked = dco_run & rst_n;
    end
    reg [23:0] clock_expected [0:75];
    reg [23:0] adc_expected [0:22];
    reg [23:0] rx_word;
    integer bit_count = 0;
    integer clock_count = 0;
    integer adc_count = 0;
    integer checked_pairs = 0;
    reg checking = 0;
    time calibration_end, clock_end, test_end, last_sclk;

    initial begin
        $readmemh("../sim/clock_expected.mem", clock_expected);
        adc_expected[0]=24'h000503; adc_expected[1]=24'h00003c;
        adc_expected[2]=24'h000018; adc_expected[3]=24'h000503;
        adc_expected[4]=24'h000800; adc_expected[5]=24'h001000;
        adc_expected[6]=24'h000d0f; adc_expected[7]=24'h001405;
        adc_expected[8]=24'h001600; adc_expected[9]=24'h001700;
        adc_expected[10]=24'h00180f; adc_expected[11]=24'h001900;
        adc_expected[12]=24'h001a00; adc_expected[13]=24'h001bff;
        adc_expected[14]=24'h001cff; adc_expected[15]=24'h001d55;
        adc_expected[16]=24'h001e00; adc_expected[17]=24'h001fff;
        adc_expected[18]=24'h0020ff; adc_expected[19]=24'h00ff01;
        adc_expected[20]=24'h000503; adc_expected[21]=24'h000d00;
        adc_expected[22]=24'h00ff01;
    end

    always @(negedge adk_cs or negedge adc_cs) begin
        if (checking) begin
            if ((!adk_cs && !adc_cs) || !dac_cs || sclk !== 0)
                $fatal(1,"SPI selection/idle violation");
            if (!adk_cs && clock_count == 72 && $time-calibration_end < 200)
                $fatal(1,"VCO calibration wait missing");
            if (!adc_cs && adc_count == 0 && $time-clock_end < 200)
                $fatal(1,"Clock settling wait missing");
            if (!adc_cs && adc_count == 20 && $time-test_end < 400)
                $fatal(1,"Ramp observation wait missing");
            bit_count = 0;
            rx_word = 0;
            last_sclk = $time;
        end
    end
    always @(posedge sclk) begin
        if (checking) begin
            if ($time-last_sclk < 50 || (adk_cs && adc_cs))
                $fatal(1,"SPI half-period or CS violation");
            if (sdio !== 0 && sdio !== 1) $fatal(1,"Undriven SPI bit");
            rx_word = {rx_word[22:0],sdio};
            bit_count = bit_count + 1;
            last_sclk = $time;
        end
    end
    always @(negedge sclk) begin
        if (checking && rst_n && !(adk_cs && adc_cs)) begin
            if ($time-last_sclk < 50) $fatal(1,"SPI high pulse too short");
            last_sclk = $time;
        end
    end
    always @(posedge adk_cs) begin
        if (checking && rst_n) begin
            if (bit_count != 24 || clock_count >= 76)
                $fatal(1,"Clock transaction length/count");
            if (rx_word !== clock_expected[clock_count])
                $fatal(1,"Clock register %0d: %h",clock_count,rx_word);
            if (clock_count == 71) calibration_end = $time;
            clock_count = clock_count + 1;
            if (clock_count == 76) clock_end = $time;
        end
    end
    always @(posedge adc_cs) begin
        if (checking && rst_n) begin
            if (clock_count != 76 || bit_count != 24 || adc_count >= 23)
                $fatal(1,"ADC transaction order/length/count");
            if (rx_word !== adc_expected[adc_count])
                $fatal(1,"ADC register %0d: %h",adc_count,rx_word);
            adc_count = adc_count + 1;
            if (adc_count == 20) test_end = $time;
        end
    end

    // Exercise all 14 bits with distinct A/B patterns and a 125 MHz DCO.
    // Drive early enough to include the real UNISIM IDELAYE3 propagation.
    reg [13:0] next_a, next_b, previous_a=0, previous_b=0;
    reg [13:0] held_a, held_b;
    integer sample_number=0;
    initial forever begin
        wait(dco_run);
        next_a = (sample_number * 37) ^ 14'h1555;
        next_b = (sample_number * 53) ^ 14'h2aaa;
        data_p = next_a;
        #3.5 dco = 1;
        #0.4;
        if (valid) begin
            if (ch1 !== previous_a || ch2 !== previous_b)
                $fatal(1,"DDR pair %0d: A=%h/%h B=%h/%h",
                       sample_number,ch1,previous_a,ch2,previous_b);
            checked_pairs = checked_pairs + 1;
        end
        #0.1 data_p = next_b;
        #3.5 dco = 0;
        #0.1;
        held_a = ch1; held_b = ch2;
        #0.4;
        if (valid && (ch1 !== held_a || ch2 !== held_b))
            $fatal(1,"Outputs changed on falling edge");
        previous_a = next_a;
        previous_b = next_b;
        sample_number = sample_number + 1;
    end

    task restart;
        begin
            checking = 0;
            rst_n = 0;
            #30;
            if (done !== 0 || valid !== 0 || adk_cs !== 1 || adc_cs !== 1 || sclk !== 0)
                $fatal(1,"Reset failed");
            if (sdio !== 1'bz || dac_cs !== 1 || adc_sync !== 0)
                $fatal(1,"Idle pin state failed");
            clock_count=0; adc_count=0; bit_count=0;
            checking=1;
            rst_n=1;
        end
    endtask

    initial begin
        #250; // Let the FPGA simulation GSR complete.
        restart();
        // No DCO at all: configuration must still complete.
        wait(done); #5;
        if (clock_count != 76 || adc_count != 23 || valid !== 0)
            $fatal(1,"Initialization depends on DCO, or valid asserted too early");
        dco_run=1;
        wait(checked_pairs >= 100);
        // Abort in the middle of a transaction, then initialize again.
        restart();
        wait(!adk_cs);
        repeat(7) @(posedge sclk);
        #1 restart();
        wait(done);
        wait(valid);
        repeat(20) @(posedge sample_clk);
        if (clock_count != 76 || adc_count != 23)
            $fatal(1,"Restart did not replay complete configuration");
        if (checked_pairs < 100) $fatal(1,"DDR check never ran");
        $display("PASS: 76 clock + 23 ADC writes, startup without DCO, SPI timing, reset restart, %0d DDR pairs",checked_pairs);
        $finish;
    end
    initial begin
        #2000000;
        $fatal(1,"Simulation timeout");
    end
endmodule

