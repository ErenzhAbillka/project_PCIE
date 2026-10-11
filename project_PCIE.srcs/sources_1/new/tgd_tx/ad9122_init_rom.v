`timescale 1ns/1ps
`default_nettype none
// AD9122 Rev. B register map, word mode, two's complement, external DACCLK.
// fDATA=DCI=125 MHz, DACCLK=500 MHz, HB1 x2, HB2 x2, HB3 bypass.
// This ROM describes device setup; writes alone do not establish readiness.
module ad9122_init_rom (
    input wire [4:0] index,
    output reg [6:0] address,
    output reg [7:0] data,
    output wire last
);
    assign last = (index == 5'd16);
    always @* begin
        address = 7'h00; data = 8'h80;
        case (index)
             0: begin address=7'h00; data=8'hA0; end // SDIO bidirectional, reset.
             1: begin address=7'h00; data=8'h80; end // Release soft reset.
             2: begin address=7'h03; data=8'h00; end // 16-bit word, I first, signed.
             3: begin address=7'h04; data=8'h00; end
             4: begin address=7'h05; data=8'h00; end
             5: begin address=7'h08; data=8'hA0; end // Vendor external DACCLK profile.
             6: begin address=7'h0A; data=8'h00; end // Disable DAC PLL.
             7: begin address=7'h0C; data=8'h00; end
             8: begin address=7'h0D; data=8'h00; end
             9: begin address=7'h10; data=8'h00; end // Sync logic disabled.
            10: begin address=7'h11; data=8'h00; end
            11: begin address=7'h1B; data=8'hE4; end // Bypass premod/sinc/NCO/phase.
            12: begin address=7'h1C; data=8'h00; end // HB1 x2, mode 0.
            13: begin address=7'h1D; data=8'h00; end // HB2 x2, mode 0.
            14: begin address=7'h1E; data=8'h01; end // HB3 bypass, total x4.
            15: begin address=7'h36; data=8'h01; end // Commit inactive NCO word.
            16: begin address=7'h36; data=8'h00; end
        endcase
    end
endmodule
`default_nettype wire
