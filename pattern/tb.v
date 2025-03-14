//----------------------------------------------------------------------------//
// File name    : .v
// Author       : asic_service 
// Email        : 
// Project      : 
// Created      : 
// Copyright    : 
// Description  : 
//----------------------------------------------------------------------------//

`timescale 1ns / 10ps

module tb();

parameter   cyc_time = 10.0;

reg             clk, rstn   ;
reg     [10:0]  bin         ;
reg             bin_vld     ;

wire    [16:0]  bcd_dut     ;
wire            bcd_vld_dut ;
wire    [16:0]  bcd_model   ;
wire            bcd_vld_model;

reg     [15:0]  cnt         ;
reg     [15:0]  rand_val    ;
reg     [3:0]   wait_cnt    ;

always #(cyc_time / 2.0)  clk = ~clk;

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
end


initial begin
    clk     = 0;
    rstn    = 0;
    bin     = 0;
    bin_vld = 0;
    
    repeat(10) @(posedge clk); #1;
    rstn    = 1;

    //--- fixed test
    repeat(2) @(posedge clk); #1;
    for(cnt=0; cnt<2048; cnt=cnt+1) begin
        bin_vld = 1;
        if(cnt == (1<<10))  //-1024
            bin = 0;
        else
            bin = cnt;
        @(posedge clk); #1;
    end
    bin_vld = 0;
    wait_cnt= 0;

    //--- random test(more bin_vld)
    for(cnt=0; cnt<((1<<11)-1); cnt=cnt+1) begin
        rand_val = $random() % 256;
        if(rand_val <= 128)
            wait_cnt = 0;
        else if(rand_val <= (128+64))
            wait_cnt = 1;
        else if(rand_val <= (128+64+32))
            wait_cnt = 2;
        else
            wait_cnt = rand_val[3:0];

        if(wait_cnt != 0) begin
            repeat(wait_cnt) @(posedge clk);
            #1;
        end

        bin_vld = 1'b1;
        if(cnt == (1<<10))
            bin = 0;
        else
            bin = cnt[10:0];

        @(posedge clk); #1;
        bin_vld = 1'b0;
    end

    //--- random test(less bin_vld)
    for(cnt=0; cnt<((1<<11)-1); cnt=cnt+1) begin
        rand_val = $random() % 256;
        if(rand_val <= 128)
            wait_cnt = rand_val[3:0];
        else if(rand_val <= (128+64))
            wait_cnt = 2;
        else if(rand_val <= (128+64+32))
            wait_cnt = 1;
        else
            wait_cnt = 0;

        if(wait_cnt != 0) begin
            repeat(wait_cnt) @(posedge clk);
            #1;
        end

        bin_vld = 1'b1;
        if(cnt == (1<<10))
            bin = 0;
        else
            bin = cnt[10:0];

        @(posedge clk); #1;
        bin_vld = 1'b0;
    end

    repeat(10) @(posedge clk);
    $display("Info: bin2bcd sim pass.");
    $finish();
end


bin2bcd_model #(.PIPE_STAGE(4)) u_bin2bcd_model(
    .bin     (bin       ),
    .bin_vld (bin_vld   ),
                      
    .bcd     (bcd_model ),
    .bcd_vld (bcd_vld_model),
                      
    .clk     (clk       ),
    .rstn    (rstn      ) 
);

bin2bcd u_bin2bcd(
    .bin     (bin       ),
    .bin_vld (bin_vld   ),
                      
    .bcd     (bcd_dut   ),
    .bcd_vld (bcd_vld_dut),
                      
    .clk     (clk       ),
    .rstn    (rstn      ) 
);



//--- check result ---//

always @(posedge clk or negedge rstn)
if(~rstn) begin

end else if(bcd_vld_model) begin
    if((bcd_vld_model !== bcd_vld_dut) || (bcd_model !== bcd_dut)) begin
        #1;
        $display("Info: bin2bcd sim fail.");
        $finish();
    end
end


endmodule

