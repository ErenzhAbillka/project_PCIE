`timescale 1ns/1ps
module tb_tgd_tx_frontend;
    reg ctrl=0; always #5 ctrl=~ctrl;
    reg sample=0; always #4 sample=~sample;
    reg forward=0; initial begin #2;forever #4 forward=~forward;end
    reg reset_n=0,request=0,grant=1,clocks=1,sample_reset=1,arm=0,kill=0;
    wire busy,done,ready,fault,ownership,sclk,sdo,oe,cs,sample_ready,enabled;
    wire [3:0] error;wire [7:0] revision,level;
    wire [15:0] dp,dn;wire dcp,dcn,fp,fn;
    reg [7:0] regs[0:127];reg [15:0] packet=0;
    integer bits=0,j,transactions=0;
    reg read_op=0;reg [6:0] address=0;
    wire sdi=(bits>=8 && bits<16 && read_op) ? regs[address][15-bits] : 1'b0;
    tgd_tx_frontend #(.CTRL_CLK_HZ(1000000),.SPI_CLK_HZ(250000),
        .RESET_HOLD_CYCLES(4),.COMMAND_TIMEOUT_CYCLES(1000),.MAX_POLLS(8)) dut(
        .ctrl_clk(ctrl),.ctrl_reset_n(reset_n),.request(request),.bus_grant(grant),
        .clocks_ready(clocks),.busy(busy),.done(done),.init_ready(ready),
        .init_fault(fault),.error_code(error),.revision_id(revision),.fifo_level(level),
        .spi_ownership(ownership),.spi_sclk(sclk),.spi_sdo(sdo),.spi_oe(oe),
        .spi_cs_n(cs),.spi_sdi(sdi),.sample_clk(sample),.forward_clk(forward),
        .sample_reset(sample_reset),.hardware_arm(arm),.waveform_approved(1'b1),
        .tx_kill(kill),.sample_valid(1'b1),.i_sample(16'h1234),.q_sample(16'habcd),
        .sample_ready(sample_ready),.tx_data_enabled(enabled),.dac_data_p(dp),
        .dac_data_n(dn),.dac_dci_p(dcp),.dac_dci_n(dcn),
        .dac_frame_p(fp),.dac_frame_n(fn));
    always @(negedge cs) begin bits=0;packet=0;read_op=0;address=0;end
    always @(posedge sclk) if(!cs) begin
        if(!ownership) $fatal(1,"SPI bus released in transaction");
        packet={packet[14:0],sdo};
        if(bits==7) begin read_op=packet[7];address=packet[6:0];end
        bits=bits+1;
    end
    always @(posedge cs) if(reset_n && bits!=0) begin
        if(bits!=16) $fatal(1,"wrong DAC SPI transaction length");
        transactions=transactions+1;
        if(!read_op) begin
            regs[address]=packet[7:0];
            if(address==7'h18) regs[address]=packet[1] ? 8'h06 : 8'h00;
        end
    end
    initial begin
        for(j=0;j<128;j=j+1) regs[j]=0;
        regs[7'h7f]=8'h0c;regs[7'h19]=8'h0f;
        #300;@(negedge ctrl);reset_n=1;sample_reset=0;
        @(negedge ctrl);request=1;@(negedge ctrl);request=0;
        wait(done);#0.1;
        if(!ready || fault || error!=0 || revision!=8'h0c || level!=8'h0f)
            $fatal(1,"frontend failed full physical SPI initialization %0h",error);
        wait(sample_ready);repeat(3) @(negedge sample);
        if(enabled || dp!==0) $fatal(1,"unarmed frontend not quiet");
        arm=1;repeat(3) @(negedge sample);
        if(!enabled) $fatal(1,"ready frontend refused arm");
        kill=1;repeat(2) @(negedge sample);#0.1;
        if(enabled || dp!==0) $fatal(1,"kill did not silence real DDR PHY");
        kill=0;@(negedge ctrl);clocks=0;repeat(3) @(negedge ctrl);#0.1;
        if(!fault || error!=9 || ready || sample_ready || enabled)
            $fatal(1,"clock loss failed to invalidate configuration");
        clocks=1;repeat(8) @(negedge ctrl);
        if(ready || !fault) $fatal(1,"clock fault automatically resumed");
        $display("AD9122_FRONTEND_TEST_PASS: full SPI/readbacks/FIFO/CDC/kill/sticky clock fault (%0d transactions)",transactions);
        $finish;
    end
    initial begin #100000; $fatal(1,"frontend test watchdog");end
endmodule
