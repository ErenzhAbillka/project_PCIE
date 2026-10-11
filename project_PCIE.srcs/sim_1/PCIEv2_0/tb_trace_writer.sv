`timescale 1ns/1ps
module tb_trace_writer;
    reg clk=0, reset_n=0;
    always #2.5 clk=~clk;
    reg [31:0] data=0;
    reg [1:0] user=0;
    reg valid=0;
    wire ready;
    wire [31:0] fdata, wdata;
    wire fvalid, flast, fready, wvalid, wlast, wready;
    wire format_error, packet_error, axi_error, burst_done, clipped;
    wire [31:0] groups, frames;
    wire [1:0] banks;
    das_trace_process #(.TRACE_POINTS(32),.GROUP_TRACES(4),.PHASE_POINTS(4),
                        .FRAME_WORDS(64),.ACC_SHIFT(0),.TRACE_PERIOD(48)) dut (
        .clk(clk),.reset_n(reset_n),.amp_phase_data(data),.sample_user(user),
        .sample_valid(valid),.sample_ready(ready),.phase_start_cfg(16'd3),.input_fault(1'b0),
        .frame_data(fdata),.frame_valid(fvalid),.frame_last(flast),.frame_ready(fready),
        .format_error(format_error),.groups_completed(groups),.banks_full(banks),.accumulator_clipped(clipped));
    das_writer_packet packet (.clk(clk),.reset_n(reset_n),.frame_data(fdata),.frame_valid(fvalid),
        .frame_last(flast),.frame_ready(fready),.writer_data(wdata),.writer_valid(wvalid),
        .writer_last(wlast),.writer_ready(wready),.burst_done(burst_done),.ddr_frames_done(frames),.framing_error(packet_error));
    wire [31:0] awaddr, axi_data;
    wire [7:0] awlen; wire [2:0] awsize;
    wire awvalid, awready, axi_valid, axi_ready, axi_last, bready;
    reg bvalid=0;
    integer cycle=0, awcount=0, wcount=0, responses=0, burst_beat=0;
    integer response_delay=-1;
    assign awready=cycle%7 != 0;
    assign axi_ready=cycle>1200 && cycle%5!=0 && cycle%13!=0;
    wr_addr #(.WRITE_BASE_ADDR(32'h100000),.WRITE_WINDOW_BYTES(32'h200)) writer (
        .clk(clk),.rst_n(reset_n),.i_valid(wvalid),.i_last(wlast),.i_data(wdata),.fifo_ready(wready),
        .xdma_valid(1'b0),.i_fifo_ready(1'b1),.m00_axi_init_axi_txn(1'b0),
        .m00_axi_aclk(clk),.m00_axi_aresetn(reset_n),.m00_axi_txn_done(burst_done),.m00_axi_error(axi_error),
        .m00_axi_awaddr(awaddr),.m00_axi_awlen(awlen),.m00_axi_awsize(awsize),.m00_axi_awvalid(awvalid),.m00_axi_awready(awready),
        .m00_axi_wdata(axi_data),.m00_axi_wvalid(axi_valid),.m00_axi_wready(axi_ready),.m00_axi_wlast(axi_last),
        .m00_axi_bid(1'b0),.m00_axi_bresp(2'b00),.m00_axi_bvalid(bvalid),.m00_axi_bready(bready),
        .m00_axi_arready(1'b1),.m00_axi_rid(1'b0),.m00_axi_rdata(32'b0),.m00_axi_rresp(2'b0),.m00_axi_rlast(1'b0),.m00_axi_rvalid(1'b0));
    function [31:0] expected;
        input integer g,k;
        integer p,ph;
        begin
            expected=0;
            case(k)
                0:expected=32'h44415331; 1:expected=g; 2:expected=64;
                3:expected=32; 4:expected=4; 5:expected=3; 6:expected=4; 7:expected=16;
                8:expected=125000000; 9:expected=50000000; 10:expected=0; 11:expected=13;
                12:expected=0; 13:expected=48; 14:expected=1; 15:expected=~g;
                60:expected=32'h434f4d54; 61:expected=g; 62:expected=~g; 63:expected=32'h454e4421;
                default: if(k>=16 && k<48) begin
                    p=k-16; ph=p<16 ? g*1000+(p/4)*100+(p%4)+3 : 0;
                    expected={ph[15:0],16'd9};
                end
            endcase
        end
    endfunction
    reg stalled=0; reg [31:0] held_data; reg held_last;
    reg saw_full_backpressure=0;
    always @(posedge clk) if(reset_n) begin
        cycle<=cycle+1;
        if(valid && !ready && banks==3) saw_full_backpressure<=1;
        if(stalled && (!fvalid || fdata!==held_data || flast!==held_last)) $fatal(1,"AXIS hold failed");
        stalled<=fvalid&&!fready; held_data<=fdata; held_last<=flast;
        if(awvalid&&awready) begin
            if(awaddr!==32'h100000+(awcount%32)*16 || awlen!=3 || awsize!=2) $fatal(1,"Writer address/length %x at burst %0d",awaddr,awcount);
            awcount=awcount+1; burst_beat=0;
        end
        if(axi_valid&&axi_ready) begin
            if(axi_data!==expected(wcount/64,wcount%64)) $fatal(1,"Payload %0d got %x expected %x",wcount,axi_data,expected(wcount/64,wcount%64));
            if(axi_last !== (burst_beat==3)) $fatal(1,"AXI WLAST mismatch");
            if(axi_last) response_delay=4;
            burst_beat=burst_beat+1; wcount=wcount+1;
        end
        if(response_delay==0) begin bvalid<=1; response_delay=-1; end
        else if(response_delay>0) response_delay=response_delay-1;
        if(bvalid&&bready) begin bvalid<=0; responses=responses+1; end
        if(format_error||packet_error||axi_error||clipped) $fatal(1,"Unexpected status error");
    end
    task send(input [31:0] d,input [1:0] u);
        begin
            @(negedge clk); data=d; user=u; valid=1;
            @(posedge clk); while(!ready) @(posedge clk);
            @(negedge clk); valid=0;
            if(cycle%3==0) @(negedge clk);
        end
    endtask
    integer g,t,p,a,ph;
    initial begin
        repeat(16) @(negedge clk); reset_n=1;
        for(g=0;g<4;g=g+1) for(t=0;t<4;t=t+1) begin
            for(p=0;p<32;p=p+1) begin
                a=100+g*7+t*3+p; ph=g*1000+t*100+p;
                send({ph[15:0],a[15:0]},{p==31,1'b1});
            end
            send(32'h12345678,2'b00);
        end
        wait(frames==4); repeat(5) @(posedge clk);
        if(wcount!=256 || groups!=4 || responses!=64 || !saw_full_backpressure) $fatal(1,"Incomplete run");
        $display("DAS_TRACE_WRITER_TEST_PASS: exact difference/phase alignment, ping-pong stalls, packet WLAST, write-ring wrap, BRESP completion");
        $finish;
    end
    initial begin #1000000; $fatal(1,"Timeout"); end
endmodule
