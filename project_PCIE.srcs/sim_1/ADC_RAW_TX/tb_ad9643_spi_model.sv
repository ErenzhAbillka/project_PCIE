`timescale 1ns/1ps
// Shared ideal AD9643 three-wire SPI model. Read data is driven only after
// the 16-bit instruction; assertions also observe the FPGA IOBUF turnaround.
module tb_ad9643_spi_model(
    input reset_n,sclk,cs_n,master_t,master_sdi,
    inout sdio,
    output reg committed_ramp=0,
    output integer write_count=0,read_count=0
);
    reg [7:0] regs[0:255];
    reg [23:0] packet=0;
    reg [12:0] address=0;
    reg reading=0,read_drive=0,read_bit=0,pending_ramp=0;
    integer bits=0,j;
    assign sdio=(!cs_n && read_drive) ? read_bit : 1'bz;
    task clear_registers;
        begin
            for(j=0;j<256;j=j+1) regs[j]=0;
            regs[8'h01]=8'h82;
            pending_ramp=0; committed_ramp=0;
        end
    endtask
    function [12:0] expected_address(input integer index);
        case(index%7)
            0: expected_address=13'h001;
            1: expected_address=13'h005;
            2: expected_address=13'h00b;
            3: expected_address=13'h00d;
            4: expected_address=13'h014;
            5: expected_address=13'h016;
            default: expected_address=13'h017;
        endcase
    endfunction
    initial clear_registers();
    always @(negedge reset_n) begin clear_registers(); read_drive=0; end
    always @(negedge cs_n) begin bits=0;packet=0;reading=0;read_drive=0;end
    always @(posedge sclk) if(!cs_n) begin
        if(bits<16 || !reading) begin
            if(master_t!==1'b0 || (sdio!==1'b0 && sdio!==1'b1))
                $fatal(1,"ADC instruction/write data not driven by FPGA");
        end else if(master_t!==1'b1 || sdio!==read_bit || master_sdi!==read_bit)
            $fatal(1,"ADC readback did not traverse released IOBUF and O path");
        packet={packet[22:0],sdio};
        bits=bits+1;
        if(bits==16) begin
            reading=packet[15]; address=packet[12:0];
            if(packet[14:13]!=0 || address>255)
                $fatal(1,"Unsupported ADC SPI instruction: %h",packet[15:0]);
            if(reading && address!==expected_address(read_count))
                $fatal(1,"ADC dump address/order wrong: index=%d address=%h",read_count,address);
        end
    end
    always @(negedge sclk) if(!cs_n && reading) begin
        if(bits>=16 && bits<24) begin
            #0.01; read_bit=regs[address][23-bits]; read_drive=1;
        end else if(bits==24) begin #0.01;read_drive=0;end
    end
    always @(posedge cs_n) begin
        read_drive=0;
        if(reset_n && bits!=0) begin
            if(bits!=24) $fatal(1,"AD9643 frame must have 16 instruction + 8 data clocks");
            if(reading) read_count=read_count+1;
            else begin
                write_count=write_count+1;
                if(address==0 && packet[7:0]==8'h3c) clear_registers();
                else regs[address]=packet[7:0];
                if(address==13'h00d) pending_ramp=packet[7:0]==8'h06;
                if(address==13'h0ff && packet[7:0]==8'h01) committed_ramp=pending_ramp;
            end
        end
    end
endmodule
