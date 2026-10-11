`timescale 1ns/1ps
module tb_ad9122_spi_master;
    reg clk=0; always #2.5 clk=~clk;
    reg rn=0,valid=0,read_cmd=0;reg[6:0] addr=0;reg[7:0] data=0;
    wire ready,rv,err,sclk,cs,so,oe;wire[7:0] rd;
    reg[7:0] slave_byte=8'ha5;
    wire si=(dut.bit_index<8) ? slave_byte[dut.bit_index] : 1'b0;
    reg[15:0] packet;integer edges;
    ad9122_spi_master #(.HALF_CYCLES(2)) dut(.clk(clk),.reset_n(rn),
        .cmd_valid(valid),.cmd_ready(ready),.cmd_read(read_cmd),.cmd_address(addr),
        .cmd_data(data),.rsp_valid(rv),.rsp_data(rd),.rsp_error(err),
        .sclk(sclk),.cs_n(cs),.sdio_out(so),.sdio_oe(oe),.sdio_in(si));
    always @(negedge cs) begin packet=0;edges=0;end
    always @(posedge sclk) if(!cs) begin
        if(read_cmd && edges>=8 && oe) $fatal(1,"SDIO not released for read");
        if((!read_cmd || edges<8) && !oe) $fatal(1,"Instruction/write not driven");
        packet={packet[14:0],so}; edges=edges+1;
    end
    task transfer(input bit r,input[6:0] a,input[7:0] d);
        begin
            @(negedge clk);read_cmd=r;addr=a;data=d;valid=1;
            @(negedge clk);valid=0;
            while(!rv) @(negedge clk);
            if(edges!=16 || !cs || oe || sclk || err) $fatal(1,"Bad SPI frame/idle");
            if(packet[15:8]!=={r,a}) $fatal(1,"Bad SPI instruction");
            if(!r && packet[7:0]!==d) $fatal(1,"Bad SPI data order");
            if(r && rd!==slave_byte) $fatal(1,"Bad read byte %h",rd);
        end
    endtask
    initial begin
        repeat(3) @(negedge clk);rn=1;
        transfer(0,7'h03,8'hd2);transfer(1,7'h7f,0);
        slave_byte=8'h0c; transfer(1,7'h18,0);
        $display("AD9122_SPI_TEST_PASS: 16 clocks/MSB/mode0/3-wire direction/readback");$finish;
    end
    initial begin #10000;$fatal(1,"SPI watchdog");end
endmodule
