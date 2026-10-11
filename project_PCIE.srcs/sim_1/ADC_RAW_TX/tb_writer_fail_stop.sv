`timescale 1ns/1ps
// Actual packetizer + actual AXI writer. The memory slave deliberately stalls
// AW/W and delays B; injected errors must not publish a completed DAS frame.
module tb_writer_fail_stop;
    reg clk=0;
    always #5 clk=~clk;
    reg reset_n=0, source_active=0;
    integer source_words=0, source_limit=32;
    integer failed_burst=-1, corrupt_last_word=-1;
    reg [1:0] injected_response=0;
    wire source_valid=source_active && source_words<source_limit;
    wire source_last=(source_words%8)==7;
    wire source_ready;
    wire [31:0] writer_data;
    wire writer_valid, packet_last, writer_ready, txn_done, writer_error;
    wire writer_last=packet_last ^ (source_words==corrupt_last_word);
    wire [31:0] frames_done;
    wire framing_error;
    das_writer_packet packetizer(
        .clk(clk),.reset_n(reset_n),
        .frame_data(32'habc00000+source_words),.frame_valid(source_valid),
        .frame_last(source_last),.frame_ready(source_ready),
        .writer_data(writer_data),.writer_valid(writer_valid),
        .writer_last(packet_last),.writer_ready(writer_ready),
        .burst_done(txn_done),.ddr_frames_done(frames_done),
        .framing_error(framing_error));

    wire [31:0] awaddr,wdata;
    wire [7:0] awlen;
    wire [2:0] awsize;
    wire [1:0] awburst;
    wire [3:0] wstrb;
    wire awvalid,wvalid,wlast,bready;
    reg awready=0,wready=0,bvalid=0;
    reg [1:0] bresp=0;
    wr_addr #(.WRITE_BASE_ADDR(32'h00100000),.WRITE_WINDOW_BYTES(32'd32)) dut(
        .clk(clk),.rst_n(reset_n),.m00_axi_aclk(clk),.m00_axi_aresetn(reset_n),
        .i_valid(writer_valid),.i_last(writer_last),.i_data(writer_data),.fifo_ready(writer_ready),
        .xdma_valid(1'b0),.i_fifo_ready(1'b1),
        .m00_axi_init_axi_txn(1'b0),.m00_axi_txn_done(txn_done),.m00_axi_error(writer_error),
        .m00_axi_awaddr(awaddr),.m00_axi_awvalid(awvalid),.m00_axi_awready(awready),
        .m00_axi_awlen(awlen),.m00_axi_awsize(awsize),.m00_axi_awburst(awburst),
        .m00_axi_wdata(wdata),.m00_axi_wvalid(wvalid),.m00_axi_wready(wready),
        .m00_axi_wlast(wlast),.m00_axi_wstrb(wstrb),
        .m00_axi_bvalid(bvalid),.m00_axi_bready(bready),.m00_axi_bresp(bresp),.m00_axi_bid(1'b0),
        .m00_axi_arready(1'b0),.m00_axi_rdata(32'b0),.m00_axi_rvalid(1'b0),
        .m00_axi_rlast(1'b0),.m00_axi_rresp(2'b00),.m00_axi_rid(1'b0));

    integer cycle=0,aw_count=0,w_count=0,b_count=0,done_count=0,beat=0,b_delay=-1;
    integer aw_stalls=0,w_stalls=0;
    reg outstanding=0,held_aw=0,held_w=0,held_last;
    reg [31:0] saved_addr,saved_data;
    always @(negedge clk) begin
        if (!reset_n) begin awready=0; wready=0; end
        else begin
            awready=(cycle%4)==0;
            wready=(cycle%3)!=0;
        end
    end
    always @(posedge clk) begin
        if (!reset_n) begin
            source_words<=0; cycle=0; aw_count=0; w_count=0; b_count=0;
            done_count=0; beat=0; b_delay=-1; outstanding=0;
            held_aw=0; held_w=0; bvalid<=0; bresp<=0; aw_stalls=0; w_stalls=0;
        end else begin
            cycle=cycle+1;
            if(source_valid && source_ready) source_words<=source_words+1;
            if(held_aw && (!awvalid || awaddr!==saved_addr)) $fatal(1,"AW changed under backpressure");
            if(held_w && (!wvalid || wdata!==saved_data || wlast!==held_last)) $fatal(1,"W changed under backpressure");
            held_aw=awvalid&&!awready; saved_addr=awaddr;
            held_w=wvalid&&!wready; saved_data=wdata; held_last=wlast;
            if(held_aw) aw_stalls=aw_stalls+1;
            if(held_w) w_stalls=w_stalls+1;
            if(awvalid && awready) begin
                if(outstanding) $fatal(1,"A second AW preceded B completion");
                if(awaddr!==(32'h00100000+(aw_count%2)*16) || awlen!=3 || awsize!=2 || awburst!=1)
                    $fatal(1,"Bad address, wrap, or burst geometry");
                aw_count=aw_count+1; beat=0; outstanding=1;
            end
            if(wvalid && wready) begin
                if(!outstanding || beat>3 || wlast!==(beat==3) || wstrb!=15)
                    $fatal(1,"Accepted AXI burst was not drained as four beats");
                if(wdata!==(32'habc00000+w_count)) $fatal(1,"Unexpected or repeated W data");
                w_count=w_count+1; beat=beat+1;
                if(wlast) begin
                    b_delay=7;
                    bresp<=((aw_count-1)==failed_burst) ? injected_response : 2'b00;
                end
            end
            if(b_delay>0) b_delay=b_delay-1;
            else if(b_delay==0) begin bvalid<=1; b_delay=-1; end
            if(bvalid && bready) begin
                if(!outstanding || beat!=4) $fatal(1,"B completed before four W beats");
                b_count=b_count+1; outstanding=0; bvalid<=0;
            end
            if(txn_done) done_count=done_count+1;
        end
    end

    task reset_case;
        input integer bad_burst;
        input [1:0] response;
        input integer bad_last;
        begin
            @(negedge clk); source_active=0; reset_n=0;
            failed_burst=bad_burst; injected_response=response; corrupt_last_word=bad_last;
            repeat(4) @(negedge clk);
            reset_n=1;
            @(negedge clk); source_active=1;
        end
    endtask

    task expect_fail_stop;
        input integer expected_bursts;
        input integer expected_successes;
        begin
            wait(b_count==expected_bursts);
            repeat(80) @(negedge clk);
            if(!writer_error || framing_error || outstanding || aw_count!=expected_bursts ||
               w_count!=4*expected_bursts || source_words!=4*expected_bursts ||
               done_count!=expected_successes || frames_done!=0 || txn_done ||
               awvalid || wvalid || writer_ready || !source_valid)
                $fatal(1,"Write failure escaped fail-stop or published a frame");
            if(dut.aw_addr!==(32'h00100000+expected_successes*16))
                $fatal(1,"Failed write advanced the ring address");
        end
    endtask

    task expect_success;
        begin
            wait(b_count==8);
            repeat(8) @(negedge clk);
            if(writer_error || framing_error || source_words!=32 || done_count!=8 ||
               frames_done!=4 || dut.aw_addr!=32'h00100000 || aw_stalls==0 || w_stalls==0)
                $fatal(1,"Normal writes, frame publication, reset, or address wrap failed");
        end
    endtask

    initial begin
        reset_case(-1,2'b00,-1); expect_success();
        $display("PASS: normal four-beat writes, AW/W stalls, delayed B, frame counts and ring wrap");
        reset_case(1,2'b10,-1); expect_fail_stop(2,1);
        $display("PASS: final-burst SLVERR blocks frame publication and all subsequent writes");
        reset_case(0,2'b11,-1); expect_fail_stop(1,0);
        $display("PASS: non-final DECERR drains accepted burst and stops before next AW");
        reset_case(-1,2'b00,1); expect_fail_stop(1,0);
        $display("PASS: early source TLAST drains four AXI beats without success publication");
        reset_case(-1,2'b00,3); expect_fail_stop(1,0);
        $display("PASS: missing source TLAST drains four AXI beats without success publication");
        reset_case(-1,2'b00,-1); expect_success();
        $display("WRITER_FAIL_STOP_TEST_PASS: success, SLVERR, DECERR, bad TLAST and reset recovery");
        $finish;
    end
    initial begin #1000000; $fatal(1,"Test timed out"); end
endmodule
