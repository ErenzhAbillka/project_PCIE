// Independent simulation reference: ADI axi_ad9643_pnmon.v (hdl_2016_r1).
// Published 30-bit parallel equations, unlike the DUT's serial 15-bit predictor.
// Physical output format is fixed at AD9643 0x14=05, raw XOR 14'h3fff.
package adi_pn9_reference;
    function automatic [29:0] adi_pn9_30(input [8:0] state);
        begin
            adi_pn9_30[29] = state[8] ^ state[4];
            adi_pn9_30[28] = state[7] ^ state[3];
            adi_pn9_30[27] = state[6] ^ state[2];
            adi_pn9_30[26] = state[5] ^ state[1];
            adi_pn9_30[25] = state[4] ^ state[0];
            adi_pn9_30[24] = state[3] ^ state[8] ^ state[4];
            adi_pn9_30[23] = state[2] ^ state[7] ^ state[3];
            adi_pn9_30[22] = state[1] ^ state[6] ^ state[2];
            adi_pn9_30[21] = state[0] ^ state[5] ^ state[1];
            adi_pn9_30[20] = state[8] ^ state[0];
            adi_pn9_30[19] = state[7] ^ state[8] ^ state[4];
            adi_pn9_30[18] = state[6] ^ state[7] ^ state[3];
            adi_pn9_30[17] = state[5] ^ state[6] ^ state[2];
            adi_pn9_30[16] = state[4] ^ state[5] ^ state[1];
            adi_pn9_30[15] = state[3] ^ state[4] ^ state[0];
            adi_pn9_30[14] = state[2] ^ state[3] ^ state[8] ^ state[4];
            adi_pn9_30[13] = state[1] ^ state[2] ^ state[7] ^ state[3];
            adi_pn9_30[12] = state[0] ^ state[1] ^ state[6] ^ state[2];
            adi_pn9_30[11] = state[8] ^ state[0] ^ state[4] ^ state[5] ^ state[1];
            adi_pn9_30[10] = state[7] ^ state[8] ^ state[3] ^ state[0];
            adi_pn9_30[9] = state[6] ^ state[7] ^ state[2] ^ state[8] ^ state[4];
            adi_pn9_30[8] = state[5] ^ state[6] ^ state[1] ^ state[7] ^ state[3];
            adi_pn9_30[7] = state[4] ^ state[5] ^ state[0] ^ state[6] ^ state[2];
            adi_pn9_30[6] = state[3] ^ state[8] ^ state[5] ^ state[1];
            adi_pn9_30[5] = state[2] ^ state[4] ^ state[7] ^ state[0];
            adi_pn9_30[4] = state[1] ^ state[3] ^ state[6] ^ state[8] ^ state[4];
            adi_pn9_30[3] = state[0] ^ state[2] ^ state[5] ^ state[7] ^ state[3];
            adi_pn9_30[2] = state[8] ^ state[1] ^ state[6] ^ state[2];
            adi_pn9_30[1] = state[7] ^ state[0] ^ state[5] ^ state[1];
            adi_pn9_30[0] = state[6] ^ state[8] ^ state[0];
        end
    endfunction
    function automatic [13:0] pn9_first(input [8:0] state);
        reg [29:0] words;
        begin words=adi_pn9_30(state); pn9_first=words[28:15]^14'h3fff; end
    endfunction
    function automatic [13:0] pn9_next(input [13:0] raw);
        begin pn9_next=pn9_first(raw[8:0]^9'h1ff); end
    endfunction
endpackage
