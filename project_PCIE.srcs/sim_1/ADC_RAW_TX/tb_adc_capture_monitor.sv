`timescale 1ns/1ps
module tb_adc_capture_monitor;
    reg ctrl_clk = 0;
    reg sample_clk = 0;
    reg sample_clock_enabled = 0;
    reg reset_n = 0;
    reg run = 0;
    reg sample_valid = 0;
    wire fault;
    wire production_fault;
    always #2.5 ctrl_clk = ~ctrl_clk;
    always #4 begin
        if (sample_clock_enabled) sample_clk = ~sample_clk;
        else sample_clk = 0;
    end
    adc_capture_monitor #(.WATCHDOG_CYCLES(16)) dut (
        .ctrl_clk(ctrl_clk), .reset_n(reset_n), .run(run),
        .sample_clk(sample_clk), .sample_valid(sample_valid), .fault(fault)
    );
    adc_capture_monitor production_defaults (
        .ctrl_clk(ctrl_clk), .reset_n(reset_n), .run(run),
        .sample_clk(sample_clk), .sample_valid(sample_valid), .fault(production_fault)
    );

    task wait_control;
        input integer cycles;
        begin
            repeat (cycles) @(posedge ctrl_clk);
            #0.1;
        end
    endtask
    task expect_no_fault;
        input integer cycles;
        integer n;
        begin
            for (n=0; n<cycles; n=n+1) begin
                wait_control(1);
                if (fault !== 1'b0) $fatal(1, "Unexpected capture fault at %t", $time);
                if (production_fault !== 1'b0) $fatal(1, "Unexpected production capture fault at %t", $time);
            end
        end
    endtask
    task expect_fault_within;
        input integer cycles;
        integer n;
        begin
            n=0;
            while (fault !== 1'b1 && n<cycles) begin
                wait_control(1);
                n=n+1;
            end
            if (fault !== 1'b1) $fatal(1, "Missing capture fault after %0d cycles", cycles);
        end
    endtask
    task restart;
        begin
            @(negedge ctrl_clk);
            reset_n=0; run=0; sample_valid=0; sample_clock_enabled=0;
            wait_control(4);
            if (fault !== 1'b0) $fatal(1, "Reset failed to clear capture fault");
            @(negedge ctrl_clk);
            reset_n=1;
        end
    endtask
    task start_running;
        begin
            @(negedge ctrl_clk);
            sample_clock_enabled=1; sample_valid=1; run=1;
            expect_no_fault(40);
        end
    endtask

    initial begin
        restart();
        // A run request before SPI/DCO readiness must not start the watchdog.
        run=1;
        expect_no_fault(5000);
        sample_clock_enabled=1;
        expect_no_fault(40);
        run=0; sample_valid=1;
        expect_no_fault(40);
        sample_clock_enabled=0;
        expect_no_fault(40);
        $display("PASS: startup without DCO and idle valid do not arm capture monitor");

        restart();
        start_running();
        expect_no_fault(2000);
        $display("PASS: normal 125 MHz sampling on independent 200 MHz control clock");
        @(negedge ctrl_clk);
        sample_valid=0;
        expect_fault_within(4);
        sample_valid=1;
        wait_control(80);
        if (!fault) $fatal(1, "Capture fault cleared without reset after valid recovery");
        $display("PASS: valid drop latches fault across recovery");

        restart();
        start_running();
        // Keep valid high deliberately: the heartbeat must catch a dead clock.
        @(negedge sample_clk);
        sample_clock_enabled=0;
        expect_fault_within(20);
        sample_clock_enabled=1;
        wait_control(80);
        if (!fault) $fatal(1, "Capture fault cleared without reset after clock recovery");
        $display("PASS: halted sample clock latches fault even with valid stuck high");

        restart();
        start_running();
        // A legitimate short CDC heartbeat gap below the watchdog bound is safe.
        @(negedge sample_clk);
        sample_clock_enabled=0;
        expect_no_fault(6);
        sample_clock_enabled=1;
        expect_no_fault(80);
        $display("PASS: short heartbeat gap stays below configured watchdog limit");

        restart();
        start_running();
        expect_no_fault(200);
        @(negedge sample_clk);
        sample_clock_enabled=0;
        wait_control(4095);
        if (production_fault) $fatal(1, "Production watchdog expired before the synchronized heartbeat timeout");
        wait_control(6);
        if (!production_fault) $fatal(1, "Production watchdog failed at the default 4096-cycle limit");
        restart();
        start_running();
        if (production_fault) $fatal(1, "Production watchdog failed to restart after reset");
        $display("PASS: production default 4096-cycle watchdog and reset recovery");
        $display("ADC_CAPTURE_MONITOR_TEST_PASS: startup, valid drop, halted clock, sticky fault, reset, normal run");
        $finish;
    end
    initial begin
        #100000;
        $fatal(1, "Capture monitor test timed out");
    end
endmodule
