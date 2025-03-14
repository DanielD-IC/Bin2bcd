//----------------------------------------------------------------------------//
// File name    : bin2bcd.v
// Author       : Danial Ding
// Email        : 
// Project      : bin2bcd
// Date         : 2025/3/13
// Copyright    : 
// Description  : 
//----------------------------------------------------------------------------//
`timescale 1ns/100ps
module tb();

parameter clk_cyc = 10.0;

reg clk;
reg rstn;
reg [10:0] bin;
reg bin_vld;

reg [3:0] wait_cnt;



always #(clk_cyc/2.0) clk = ~clk;


