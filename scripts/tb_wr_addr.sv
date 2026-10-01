`timescale 1ns/1ps
module tb_wr_addr;
reg clk=0; always #5 clk=~clk;
reg rst_n=0;
wire src_valid, src_last, src_ready;
wire [31:0] src_data;
AXI_data_out_0 source(.clk(clk),.rst_n(rst_n),.fifo_ready(src_ready),
    .valid(src_valid),.last(src_last),.data(src_data));
// Behavioral AXIS storage with packet release; not a simulation of vendor IP.
reg [32:0] mem[0:511];
integer wp=0,rp=0,used=0,packets=0;
wire iv=packets>0;
wire il=mem[rp][32]; wire [31:0] idata=mem[rp][31:0];
wire fr;
assign src_ready=used<512;
wire push=src_valid && src_ready;
wire pop=iv && fr;
always @(posedge clk) begin
    if(!rst_n) begin wp<=0;rp<=0;used<=0;packets<=0; end
    else begin
        if(push) begin mem[wp]<={src_last,src_data};wp<=(wp+1)%512;end
        if(pop) rp<=(rp+1)%512;
        used<=used+push-pop;
        packets<=packets+(push && src_last)-(pop && il);
    end
end
wire [31:0] awaddr,wdata,araddr,odata;
wire [7:0] awlen,arlen;
wire [2:0] awsize;
wire [3:0] wstrb;
wire av,wv,wl,br,arv,rr,ov,ol,done,error;
reg awready=0,wready=0,bvalid=0;
reg [1:0] bresp=0;
reg trigger=0,ordy=0,arready=0,rv=0,rl=0;
reg [31:0] rd=0;
reg [1:0] rresp=0;
wr_addr dut(.clk(clk),.rst_n(rst_n),.m00_axi_aclk(clk),.m00_axi_aresetn(rst_n),
    .i_valid(iv),.i_last(il),.i_data(idata),.fifo_ready(fr),
    .xdma_valid(trigger),.i_fifo_ready(ordy),.o_valid(ov),.o_last(ol),.o_data(odata),
    .m00_axi_init_axi_txn(1'b0),.m00_axi_txn_done(done),.m00_axi_error(error),
    .m00_axi_awaddr(awaddr),.m00_axi_awvalid(av),.m00_axi_awready(awready),
    .m00_axi_awlen(awlen),.m00_axi_awsize(awsize),
    .m00_axi_wdata(wdata),.m00_axi_wvalid(wv),.m00_axi_wready(wready),
    .m00_axi_wlast(wl),.m00_axi_wstrb(wstrb),
    .m00_axi_bvalid(bvalid),.m00_axi_bready(br),.m00_axi_bresp(bresp),
    .m00_axi_bid(1'b0),
    .m00_axi_araddr(araddr),.m00_axi_arlen(arlen),.m00_axi_arvalid(arv),.m00_axi_arready(arready),
    .m00_axi_rdata(rd),.m00_axi_rvalid(rv),.m00_axi_rready(rr),.m00_axi_rlast(rl),
    .m00_axi_rresp(rresp),.m00_axi_rid(1'b0));

integer cycle=0,words=0,bursts=0,responses=0,done_count=0,beat=0;
integer delay_b=-1,tail_pause=0,tail_stalls=0;
reg outstanding=0,stalled=0,astalled=0;
reg [31:0] held,heldaddr;
reg heldlast;
reg [15:0] expected=16'h1;
always @(negedge clk) begin
    if(rst_n) begin
        cycle=cycle+1;
        awready=(cycle%5==0);
        wready=(cycle%3!=0);
        if(wv && wl && tail_pause<5) begin
            wready=0;tail_pause=tail_pause+1;tail_stalls=tail_stalls+1;
        end
    end
end
always @(posedge clk) if(rst_n) begin
    if(stalled && (!wv || wdata!==held || wl!==heldlast)) $fatal(1,"W changed under stall");
    if(astalled && (!av || awaddr!==heldaddr)) $fatal(1,"AW changed under stall");
    stalled=wv&&!wready;held=wdata;heldlast=wl;
    astalled=av&&!awready;heldaddr=awaddr;
    if(av&&awready) begin
        if(outstanding) $fatal(1,"New AW before previous response");
        if(awaddr!==bursts*16 || awlen!=3 || awsize!=2) $fatal(1,"Wrong burst address/shape");
        bursts=bursts+1;outstanding=1;beat=0;tail_pause=0;
    end
    if(wv&&wready) begin
        if(!outstanding || beat>3) $fatal(1,"Unexpected W transfer");
        if(wdata!=={16'b0,expected} || wl!==(beat==3) || wstrb!=15) $fatal(1,"Data/last mismatch at %0d",words);
        expected=(expected<<1)|{15'b0,^(expected&16'hb400)};
        beat=beat+1;words=words+1;
        if(wl) delay_b=7;
    end
    if(delay_b>0) delay_b=delay_b-1;
    else if(delay_b==0) begin bvalid<=1;delay_b=-1;end
    if(bvalid&&br) begin responses=responses+1;outstanding=0;bvalid<=0;end
    if(done) done_count=done_count+1;
end

integer j;
initial begin
    repeat(5) @(negedge clk); rst_n=1;
    wait(responses==256);
    repeat(5) @(negedge clk);
    if(words!=1024 || bursts!=256 || done_count!=256 || error || tail_stalls==0 || dut.aw_addr!=0)
        $fatal(1,"Write totals/wrap/error check failed");
    $display("PASS: 1024 LFSR words, 256 bursts, delayed AW/B, stalled packet tails, 4KiB wrap");
    // Trigger drops before the read returns. Transaction must still finish.
    trigger=1;
    wait(arv); @(negedge clk); trigger=0;
    repeat(4) @(negedge clk);
    if(!arv || araddr!=32'hf000 || arlen!=3) $fatal(1,"Read address not retained");
    arready=1; @(negedge clk); arready=0;
    for(j=0;j<4;j=j+1) begin
        rd=32'h12345670+j;rv=1;rl=(j==3);ordy=0;
        repeat(3) @(negedge clk);
        if(!ov || rr || odata!=={rd[7:0],rd[15:8],rd[23:16],rd[31:24]} || ol!==(j==3))
            $fatal(1,"Read output/backpressure failure");
        if(j==3) rresp=2'b10;
        ordy=1; @(negedge clk);rv=0;ordy=0;
    end
    repeat(5) @(negedge clk);
    if(!error || rr || ov || arv) $fatal(1,"Read completion/error failure");
    $display("PASS: read AR stall, early trigger removal, R stalls, byte reversal, response error reporting");
    $finish;
end
initial begin #1000000; $fatal(1,"Timeout"); end
endmodule
