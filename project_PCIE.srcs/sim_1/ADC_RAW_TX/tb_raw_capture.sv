`timescale 1ns/1ps
module tb_raw_capture;
    reg clk=0; always #2.5 clk=~clk;
    reg reset_n=0, arm=0, fault=0, adc_valid=0;
    reg [31:0] adc_data=0;
    reg [1:0] adc_user=0;
    wire adc_ready, frame_valid, frame_last, complete, error, sent;
    wire [31:0] frame_data, writer_data, frames_done;
    wire frame_ready, writer_valid, writer_last, framing_error;
    reg writer_ready=0, burst_done=0, traffic=0;
    integer received=0, cycle=0, ack_delay=0, file_handle=0;
    reg [31:0] checksum=0;
    reg previous_stall=0;
    reg [32:0] previous_output;
    raw_trace_capture dut(
        .clk(clk),.reset_n(reset_n),.arm(arm),.input_fault(fault),
        .epoch_cfg(32'h1234),.config_id_cfg(32'habcd),.test_active(1'b1),
        .adc_data(adc_data),.adc_user(adc_user),.adc_valid(adc_valid),.adc_ready(adc_ready),
        .frame_data(frame_data),.frame_valid(frame_valid),.frame_last(frame_last),.frame_ready(frame_ready),
        .capture_complete(complete),.capture_error(error),.frame_sent(sent));
    das_writer_packet packetizer(.clk(clk),.reset_n(reset_n),
        .frame_data(frame_data),.frame_valid(frame_valid),.frame_last(frame_last),.frame_ready(frame_ready),
        .writer_data(writer_data),.writer_valid(writer_valid),.writer_last(writer_last),.writer_ready(writer_ready),
        .burst_done(burst_done),.ddr_frames_done(frames_done),.framing_error(framing_error));

    function automatic [31:0] sample_word(input integer n);
        reg [13:0] a,b;
        begin a=3-n; b=8190-n; sample_word={{2{b[13]}},b,{2{a[13]}},a}; end
    endfunction
    function automatic [31:0] expected_word(input integer n);
        begin
            expected_word=0;
            if(n>=32 && n<16352) expected_word=sample_word(n-32);
            else case(n)
                0,16352: expected_word=32'h52415731;
                2: expected_word=16384;
                3,16357: expected_word=16320;
                5,16356: expected_word=32'h1234;
                6: expected_word=125000000;
                7: expected_word=31250;
                8,14: expected_word=1;
                9: expected_word=15;
                11,16359: expected_word=6;
                12: expected_word=32'habcd;
                13: expected_word=14;
                15,16354,16382: expected_word=32'hffffffff;
                16360: expected_word=checksum;
                16361: expected_word=~checksum;
                16380: expected_word=32'h434f4d54;
                16383: expected_word=32'h454e4421;
                default: expected_word=0;
            endcase
        end
    endfunction
    // A bounded four-beat sink, with stalls within bursts and delayed completion.
    // The final frame publication must wait for the final burst response.
    always @(negedge clk) begin
        cycle=cycle+1;
        burst_done=0;
        if(!reset_n || !traffic) begin writer_ready=0; ack_delay=0; end
        else if(ack_delay>0) begin
            writer_ready=0;
            if(ack_delay==1) burst_done=1;
            ack_delay=ack_delay-1;
        end else writer_ready=(cycle%7!=0 && cycle%11!=0);
    end
    always @(posedge clk) begin
        if(!reset_n) begin received=0; previous_stall=0; end
        else begin
            if(previous_stall && (!frame_valid || {frame_last,frame_data}!==previous_output))
                $fatal(1,"RAW output changed under backpressure");
            previous_stall=frame_valid && !frame_ready;
            previous_output={frame_last,frame_data};
            if(writer_valid && writer_ready) begin
                if(writer_data!==expected_word(received))
                    $fatal(1,"RAW word %0d got=%08x expected=%08x",received,writer_data,expected_word(received));
                if(writer_last!==(received%4==3)) $fatal(1,"Writer four-beat boundary lost");
                if(frame_last!==(received==16383)) $fatal(1,"Frame last misplaced");
                if(file_handle) $fdisplay(file_handle,"%08x",writer_data);
                if(writer_last) ack_delay=(received==16383) ? 17 : 3;
                received=received+1;
            end
            if(frames_done!=0 && received!=16384) $fatal(1,"Premature DDR publication");
        end
    end
    task automatic reset_capture;
        begin
            @(negedge clk); reset_n=0; arm=0; fault=0; adc_valid=0; adc_user=0; traffic=0;
            repeat(5) @(negedge clk);
            reset_n=1; arm=1;
        end
    endtask
    task automatic adc(input [31:0] data,input [1:0] user);
        begin @(negedge clk); adc_valid=1; adc_data=data; adc_user=user; end
    endtask
    task automatic quiet(input integer cycles);
        begin @(negedge clk); adc_valid=0; repeat(cycles) @(negedge clk); end
    endtask
    task automatic expect_rejected;
        begin quiet(20); if(!error || complete || frame_valid || frames_done!=0) $fatal(1,"Malformed capture published"); end
    endtask

    // Router tests are independent of the large raw BRAM capture above.
    reg rrst=0,rstart=0,rraw=0,rtest=0,rtx=0,rtxready=0,rtxfault=0;
    reg [31:0] rdata=32'h76543210;
    reg [1:0] ruser=2;
    reg rv=1, dr=0, dfv=1,dfl=1,fr=0;
    wire fe,tr,txen,locked,mode,cfgerr,rr,drv,dfr,fv,fl;
    wire [31:0] drd,fd; wire [1:0] dru;
    acquisition_router #(.TRACE_POINTS(16),.FRAME_WORDS(128)) router(
        .clk(clk),.reset_n(rrst),.start(rstart),.raw_mode_cfg(rraw),.test_enable_cfg(rtest),.tx_enable_cfg(rtx),
        .epoch_cfg(32'd7),.config_id_cfg(32'd9),.adc_test_active(1'b0),.input_fault(1'b0),
        .tx_init_done(rtxready),.tx_fault(rtxfault),.tx_enable_locked(txen),
        .frontend_enable(fe),.adc_test_request(tr),.mode_locked(locked),.raw_mode_active(mode),.configuration_error(cfgerr),
        .adc_data(rdata),.adc_user(ruser),.adc_valid(rv),.adc_ready(rr),
        .das_adc_data(drd),.das_adc_user(dru),.das_adc_valid(drv),.das_adc_ready(dr),
        .das_frame_data(32'h01234567),.das_frame_valid(dfv),.das_frame_last(dfl),.das_frame_ready(dfr),
        .frame_data(fd),.frame_valid(fv),.frame_last(fl),.frame_ready(fr),
        .raw_capture_complete(),.raw_capture_error(),.raw_frame_sent());
    integer i;
    initial begin
        for(i=0;i<16320;i=i+1) checksum=checksum^sample_word(i);
        reset_capture();
        adc(0,0); adc(sample_word(0),1); adc(sample_word(1),3); expect_rejected(); // early LAST
        reset_capture(); adc(0,0); adc(sample_word(0),1); adc(0,0); expect_rejected(); // broken window
        reset_capture(); adc(0,2); expect_rejected(); // LAST outside window
        reset_capture(); adc(sample_word(0),1); expect_rejected(); // starts in middle
        reset_capture(); adc(0,0); adc(sample_word(0),1);
        @(negedge clk); fault=1; expect_rejected();
        reset_capture(); adc(0,0);
        for(i=0;i<16320;i=i+1) adc(sample_word(i),1);
        expect_rejected(); // missing LAST at exact configured sample count

        reset_capture(); adc(0,0);
        for(i=0;i<16320;i=i+1) adc(sample_word(i),(i==16319)?3:1);
        quiet(5);
        if(!complete || error || sent || frames_done!=0) $fatal(1,"Capture completion is not separated from publication");
        file_handle=$fopen("raw_frame.hex","w");
        if(!file_handle) $fatal(1,"Cannot open RAW golden output");
        traffic=1;
        // Later ADC activity/fault cannot alter the already complete finite buffer.
        fault=1;
        for(i=0;i<100;i=i+1) adc(32'hbadc0ffe,3);
        quiet(5);
        wait(sent); #1;
        if(frames_done!=0) $fatal(1,"Published before final burst response");
        wait(frames_done==1); quiet(30);
        if(error || framing_error || received!=16384 || frame_valid) $fatal(1,"Single-shot did not finish exactly once");
        $fclose(file_handle); file_handle=0;

        @(negedge clk); rrst=1; rstart=1;
        @(negedge clk);
        if(!fe || !locked || mode || cfgerr || !drv || rr || dfr || fd!==32'h01234567 || !fv || !fl)
            $fatal(1,"Default DAS routing failed");
        rraw=1; rtest=1; dr=1; fr=1;
        @(negedge clk);
        if(mode || tr || !rr || !dfr || drd!==rdata || dru!==ruser) $fatal(1,"Mode changed after arm or DAS handshake lost");
        rrst=0; rstart=0; repeat(3) @(negedge clk);
        rrst=1; rraw=0; rtest=1; rstart=1;
        @(negedge clk);
        if(!cfgerr || fe || drv || fv) $fatal(1,"Ramp was allowed into normal DAS");
        rrst=0; rstart=0; rv=0; repeat(3) @(negedge clk);
        rrst=1; rraw=1; rtest=0; rtx=1; rstart=1;
        @(negedge clk);
        if(!txen || fe || cfgerr) $fatal(1,"TX init was not required before capture");
        rtxready=1; @(negedge clk);
        if(!fe || !mode || router.config_locked!==32'h54583031) $fatal(1,"TX profile/ready lock failed");
        rtxfault=1; @(negedge clk);
        if(fe) $fatal(1,"TX fault did not inhibit frontend request");
        $display("RAW_CAPTURE_TEST_PASS: full 64KiB frame, independent payload, stalls, delayed commit, malformed windows, fault and router lock");
        $finish;
    end
    initial begin #10000000; $fatal(1,"RAW test timeout"); end
endmodule
