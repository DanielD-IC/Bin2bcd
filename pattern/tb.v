//----------------------------------------------------------------------------//
// File name    : bin2bcd.v
// Author       : Danial Ding
// Email        : 
// Project      : tb.v
// Date         : 2025/3/13
// Copyright    : 
// Description  : including fixed test and random text
//----------------------------------------------------------------------------//

`timescale 1ns / 10ps

module tb();

parameter   cyc_time = 10.0;

reg             clk, rstn   ;
reg     [10:0]  bin         ;
reg             bin_vld     ;

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
        rand_val = $random() % 256; // rand_val is [0-256]
        if(rand_val <= 128)     //50 percent no waiting
            wait_cnt = 0;
        else if(rand_val <= (128+64)) //25 percent waiting 1 clk
            wait_cnt = 1;
        else if(rand_val <= (128+64+32)) // 12.5 percent waiting 2 lck
            wait_cnt = 2;
        else
            wait_cnt = rand_val[3:0];// 12.5 percent waiting 0-15 clk

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
        if(rand_val <= 128)// 50 percent waiting 0-15 clk
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
    $display("bin2bcd sim pass.");
    $finish();
end



bin2bcd u_bin2bcd(
    .bin     (bin       ),
    .bin_vld (bin_vld   ),
                      
    .bcd     (bcd_dut   ),
    .bcd_vld (bcd_vld_dut),
                      
    .clk     (clk       ),
    .rstn    (rstn      ) 
);


endmodule

