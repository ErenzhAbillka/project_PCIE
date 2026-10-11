`timescale 1ns/1ps
module tb_dsp_native;
    reg clk=0, reset_n=0;
    always #2.5 clk=~clk;
    reg [31:0] adc_data=0;
    reg [1:0] adc_user=0;
    reg adc_valid=0;
    wire adc_ready;
    wire [15:0] p_data,p_user;
    wire p_valid,p_ready;
    wire [31:0] lo_data;
    wire [15:0] lo_user;
    wire lo_valid,lo_ready;
    wire [23:0] mi,mq;
    wire [1:0] miu,mqu,fiu,fqu;
    wire miv,mi_ready,mqv,mq_ready;
    wire [15:0] fi,fq;
    wire fiv,fi_ready,fqv,fq_ready;
    wire [31:0] cart,ap;
    wire [1:0] cu,apu;
    wire cv,cr,apv,apr,alignment_error;
    das_phase_source phase_src (.clk(clk),.reset_n(reset_n),.adc_data(adc_data),.adc_user(adc_user),
        .adc_valid(adc_valid),.adc_ready(adc_ready),.phase_data(p_data),.phase_user(p_user),.phase_valid(p_valid),.phase_ready(p_ready));
    das_dds dds (.aclk(clk),.aresetn(reset_n),.s_axis_phase_tdata(p_data),.s_axis_phase_tuser(p_user),
        .s_axis_phase_tvalid(p_valid),.s_axis_phase_tready(p_ready),.m_axis_data_tdata(lo_data),.m_axis_data_tuser(lo_user),
        .m_axis_data_tvalid(lo_valid),.m_axis_data_tready(lo_ready));
    das_iq_mixer mixer (.clk(clk),.reset_n(reset_n),.lo_data(lo_data),.lo_user(lo_user),.lo_valid(lo_valid),.lo_ready(lo_ready),
        .i_data(mi),.i_user(miu),.i_valid(miv),.i_ready(mi_ready),.q_data(mq),.q_user(mqu),.q_valid(mqv),.q_ready(mq_ready));
    das_fir fir_i (.aclk(clk),.aresetn(reset_n),.s_axis_data_tdata(mi),.s_axis_data_tuser(miu),.s_axis_data_tvalid(miv),.s_axis_data_tready(mi_ready),
        .m_axis_data_tdata(fi),.m_axis_data_tuser(fiu),.m_axis_data_tvalid(fiv),.m_axis_data_tready(fi_ready));
    das_fir fir_q (.aclk(clk),.aresetn(reset_n),.s_axis_data_tdata(mq),.s_axis_data_tuser(mqu),.s_axis_data_tvalid(mqv),.s_axis_data_tready(mq_ready),
        .m_axis_data_tdata(fq),.m_axis_data_tuser(fqu),.m_axis_data_tvalid(fqv),.m_axis_data_tready(fq_ready));
    das_iq_join joiner (.clk(clk),.reset_n(reset_n),.i_data(fi),.i_user(fiu),.i_valid(fiv),.i_ready(fi_ready),
        .q_data(fq),.q_user(fqu),.q_valid(fqv),.q_ready(fq_ready),.cartesian_data(cart),.cartesian_user(cu),
        .cartesian_valid(cv),.cartesian_ready(cr),.alignment_error(alignment_error));
    das_cordic cordic (.aclk(clk),.aresetn(reset_n),.s_axis_cartesian_tdata(cart),.s_axis_cartesian_tuser(cu),
        .s_axis_cartesian_tvalid(cv),.s_axis_cartesian_tready(cr),.m_axis_dout_tdata(ap),.m_axis_dout_tuser(apu),
        .m_axis_dout_tvalid(apv),.m_axis_dout_tready(apr));
    integer cycle=0,received=0,checked=0,phase_int,amp_int,expected_phase;
    integer sent=0,dds_count=0,fir_count=0,cart_count=0;
    integer dds_stalls=0,fir_stalls=0,cordic_stalls=0;
    integer first_cycle=-1,last_cycle=0;
    reg stress=0;
    reg [1:0] expected_user;
    reg stalled=0; reg [31:0] held; reg [1:0] held_user;
    assign apr=reset_n && (stress || (cycle%7!=0 && !(cycle>400 && cycle<800)));
    always @(posedge clk) if(reset_n) begin
        cycle<=cycle+1;
        if(adc_valid&&adc_ready) begin
            sent=sent+1; if(first_cycle<0) first_cycle=cycle; last_cycle=cycle;
        end
        if(adc_valid&&!adc_ready) dds_stalls=dds_stalls+1;
        if(miv&&!mi_ready) fir_stalls=fir_stalls+1;
        if(cv&&!cr) cordic_stalls=cordic_stalls+1;
        if(lo_valid&&lo_ready) dds_count=dds_count+1;
        if(fiv&&fi_ready) fir_count=fir_count+1;
        if(cv&&cr) cart_count=cart_count+1;
        if(stalled && (!apv || ap!==held || apu!==held_user)) $fatal(1,"Native pipeline changed held word");
        stalled<=apv&&!apr; held<=ap; held_user<=apu;
        if(alignment_error) $fatal(1,"I/Q metadata diverged");
        if(apv&&apr) begin
            expected_user=received<3200 ? {received%200==119, received%200<120} : 2'b00;
            if(apu!==expected_user) $fatal(1,"Marker mismatch sample %0d got %b expected %b",received,apu,expected_user);
            if(received<3200 && received%800>100) begin
                case(received/800)
                    0:expected_phase=6434; 1:expected_phase=19302;
                    2:expected_phase=-19302; default:expected_phase=-6434;
                endcase
                phase_int=$signed(ap[31:16]); amp_int=ap[15:0];
                if(phase_int<expected_phase-80 || phase_int>expected_phase+80 || amp_int<1740 || amp_int>1840)
                    $fatal(1,"Numerical mismatch n=%0d amp=%0d phase=%0d expected phase=%0d",received,amp_int,phase_int,expected_phase);
                checked=checked+1;
            end
            received=received+1;
        end
    end
    integer n,a; real phi,theta;
    initial begin
        stress=$test$plusargs("stress");
        repeat(32) @(negedge clk); reset_n=1;
        // ADC continues through the off-window interval; guard samples also flush
        // sample-enabled IP pipeline stages after the final measured window.
        for(n=0;n<3264;n=n+1) begin
            case(n/800)
                0:phi=0.7853981633974483; 1:phi=2.356194490192345;
                2:phi=-2.356194490192345; default:phi=-0.7853981633974483;
            endcase
            theta=2.0*3.141592653589793*0.4*n;
            a=$rtoi(4000.0*$cos(theta+phi));
            @(negedge clk); adc_data={{16{1'b0}},a[15:0]}; adc_user=n<3200 ? {n%200==119,n%200<120} : 2'b00; adc_valid=1;
            @(posedge clk); while(!adc_ready) @(posedge clk);
            if(!stress && n%11==0) begin
                @(negedge clk); adc_valid=0; repeat(2) @(negedge clk);
            end
        end
        @(negedge clk); adc_valid=0;
        wait(received>=3200); repeat(32) @(posedge clk);
        if(checked<2700) $fatal(1,"Not enough numerical samples");
        $display("Accepted ADC/DDS/FIR/CORDIC/output: %0d/%0d/%0d/%0d/%0d",sent,dds_count,fir_count,cart_count,received);
        $display("Input cycles=%0d, DDS/FIR/CORDIC stalls=%0d/%0d/%0d",last_cycle-first_cycle+1,dds_stalls,fir_stalls,cordic_stalls);
        if(stress && (last_cycle-first_cycle+1)*5 > sent*8) $fatal(1,"Throughput below 125 MSPS");
        $display("DAS_NATIVE_IQ_TEST_PASS: 3200 samples, four phase quadrants, magnitude, tags and backpressure through real DDS/FIR/CORDIC");
        $finish;
    end
    initial begin #500000; $fatal(1,"Timeout received %0d",received); end
endmodule
