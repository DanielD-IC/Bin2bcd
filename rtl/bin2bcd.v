//----------------------------------------------------------------------------//
// File name    : bin2bcd.v
// Author       : Danial Ding
// Email        : 
// Project      : bin2bcd
// Date         : 2025/3/13
// Copyright    : 
// Description  : 
//----------------------------------------------------------------------------//
module bin2bcd(

      input        clk,
      input        rstn,
      input        bin_vld,
      input [10:0] bin,

      output  [16:0]  bcd, // (sign, bcd_thousand, bcd_hundred, bcd_ten, bcd)
      output          bcd_vld

);

//wire [9:0] bin_abs_w;

/******************************************************************************/

//pipeline design: data and abs, calc bcd_th, calc bcd_hu, calc bcd_ten, calc bcd

/******************************************************************************/

reg [4:0] bcd_pipeline_cyc;  
always @(posedge clk or rstn)begin
     if(!rstn)begin
          bcd_pipeline_cyc <= 'd0;
     end else
	  bcd_pipeline_cyc <= { bcd_pipeline_cyc[3:0], bin_vld };

end


/******************************************************************************/

//calc data abs and calc bin sign (pipeline first step)

/******************************************************************************/

wire [9:0] bin_abs_w;
reg  [9:0] bin_abs  ;
reg  bin_sign;

assign bin_abs_w = (bin[10])? ((~{bin[9:0]}) + 1'b1) : bin[9:0] ;//if bin[10] = 1 indicate the bin is minus

always @(posedge clk or rstn)begin
     if(!rstn)begin
        bin_abs <=  'd0;
	bin_sign <= 'b0;
     end else if (bin_vld)begin
	bin_abs <= bin_abs_w;//store bin_abs
	bin_sign <= bin[10] ;//bin[10] 0 or 1;
     end
end

/******************************************************************************/

//calc bcd_thousand               (pipeline second step)

/******************************************************************************/

wire [10:0] abs_sub_1000;

reg  bin_sign_tra0;
reg  [9:0]  res_th; //res after sub 1000
reg  bcd_th;  //bcd_thousand


assign abs_sub_1000 = {1'b0, bin_abs} - 11'd1000;

always @(posedge clk or rstn)begin
       if(!rstn)begin
          bcd_th <= 'd0;
          res_th <= 'd0;

       end else if(bcd_pipeline_cyc[0])begin
	      bin_sign_tra0 <= bin_sign;//tra bin_sign

	   if(abs_sub_1000 == 0)begin //no minus
               res_th       <= abs_sub_1000[9:0];
               bcd_th       <= 'd1;
           end else begin // minus
               res_th       <= bin_abs;
               bcd_th       <= 4'd0; 
           end

       end

end

/******************************************************************************/

//calc bcd_hundred               (pipeline third step)

/******************************************************************************/

reg [6:0] res_hu;// the max is 128 so width is [6:0]
reg [3:0] bcd_hu;
reg [3:0] bcd_th_tra0;
reg bin_sign_tra1;


wire [10:0] abs_sub_900;
wire [10:0] abs_sub_800;
wire [10:0] abs_sub_700;
wire [10:0] abs_sub_600;
wire [10:0] abs_sub_500;
wire [10:0] abs_sub_400;
wire [10:0] abs_sub_300;
wire [10:0] abs_sub_200;
wire [10:0] abs_sub_100;

assign abs_sub_900 = {1'b0, res_th} - 11'd900;
assign abs_sub_800 = {1'b0, res_th} - 11'd800;
assign abs_sub_700 = {1'b0, res_th} - 11'd700;
assign abs_sub_600 = {1'b0, res_th} - 11'd600;
assign abs_sub_500 = {1'b0, res_th} - 11'd500;
assign abs_sub_400 = {1'b0, res_th} - 11'd400;
assign abs_sub_300 = {1'b0, res_th} - 11'd300;
assign abs_sub_200 = {1'b0, res_th} - 11'd200;
assign abs_sub_100 = {1'b0, res_th} - 11'd100;

always @(posedge clk or rstn)begin
       if(!rstn)begin
           res_hu <= 'd0;
	   bcd_hu <= 'b0;
	   bin_sign_tra1 <= 'b0;
       end else if (bcd_pipeline_cyc[1])begin

           bin_sign_tra1 <= bin_sign_tra0;
	   bcd_th_tra0   <= bcd_th       ;

           if(abs_sub_900[10] == 0)begin
                res_hu <= abs_sub_900[6:0];
                bcd_hu <= 4'd9;
           end else if (abs_sub_800[10] == 0)begin
                res_hu <= abs_sub_800[6:0];
                bcd_hu <= 4'd8;
	   end else if (abs_sub_700[10] == 0)begin
                res_hu <= abs_sub_700[6:0];
                bcd_hu <= 4'd7;
	   end else if (abs_sub_600[10] == 0)begin
                res_hu <= abs_sub_600[6:0];
                bcd_hu <= 4'd6;
	   end  else if (abs_sub_500[10] == 0)begin
                res_hu <= abs_sub_500[6:0];
                bcd_hu <= 4'd5;
	   end  else if (abs_sub_400[10] == 0)begin
                res_hu <= abs_sub_400[6:0];
                bcd_hu <= 4'd4;
	   end  else if (abs_sub_300[10] == 0)begin
                res_hu <= abs_sub_300[6:0];
                bcd_hu <= 4'd3;
	   end  else if (abs_sub_200[10] == 0)begin
                res_hu <= abs_sub_200[6:0];
                bcd_hu <= 4'd2;
	   end  else if (abs_sub_100[10] == 0)begin
                res_hu <= abs_sub_100[6:0];
                bcd_hu <= 4'd1;
           end else begin
		res_hu <= res_th[6:0];
                bcd_hu <= 4'd0;
	   end

       end

end

/******************************************************************************/

//calc bcd_ten               (pipeline fourth step)

/******************************************************************************/

reg [3:0] res_ten;// the max is 16 so width is [3:0]
reg [3:0] bcd_ten;
reg [3:0] bcd_th_tra1;
reg [3:0] bcd_hu_tra0;

reg bin_sign_tra2;

wire [7:0] abs_sub_90;
wire [7:0] abs_sub_80;
wire [7:0] abs_sub_70;
wire [7:0] abs_sub_60;
wire [7:0] abs_sub_50;
wire [7:0] abs_sub_40;
wire [7:0] abs_sub_30;
wire [7:0] abs_sub_20;
wire [7:0] abs_sub_10;


assign abs_sub_90 = {1'b0, res_hu} - 11'd90;
assign abs_sub_80 = {1'b0, res_hu} - 11'd80;
assign abs_sub_70 = {1'b0, res_hu} - 11'd70;
assign abs_sub_60 = {1'b0, res_hu} - 11'd60;
assign abs_sub_50 = {1'b0, res_hu} - 11'd50;
assign abs_sub_40 = {1'b0, res_hu} - 11'd40;
assign abs_sub_30 = {1'b0, res_hu} - 11'd30;
assign abs_sub_20 = {1'b0, res_hu} - 11'd20;
assign abs_sub_10 = {1'b0, res_hu} - 11'd10;


always @(posedge clk or rstn)begin
       if(!rstn)begin
           res_ten <= 'd0;
	   bcd_ten <= 'd0;
	   bcd_th_tra1 <= 'd0;
	   bcd_hu_tra0 <= 'd0;
	   bin_sign_tra2 <= 'b0;
       end else if (bcd_pipeline_cyc[2])begin

           bin_sign_tra2 <= bin_sign_tra1;
	   bcd_th_tra1   <= bcd_th_tra0  ;
	   bcd_hu_tra0   <= bcd_hu       ;

           if(abs_sub_90[7] == 0)begin
                res_ten <= abs_sub_90[3:0];
                bcd_ten <= 4'd9;
           end else if (abs_sub_80[7] == 0)begin
                res_ten <= abs_sub_80[3:0];
                bcd_ten <= 4'd8;
	   end else if (abs_sub_70[7] == 0)begin
                res_ten <= abs_sub_70[3:0];
                bcd_ten <= 4'd7;
	   end else if (abs_sub_60[7] == 0)begin
                res_ten <= abs_sub_60[3:0];
                bcd_ten <= 4'd6;
	   end  else if (abs_sub_50[7] == 0)begin
                res_ten <= abs_sub_50[3:0];
                bcd_ten <= 4'd5;
	   end  else if (abs_sub_40[7] == 0)begin
                res_ten <= abs_sub_40[3:0];
                bcd_ten <= 4'd4;
	   end  else if (abs_sub_30[7] == 0)begin
                res_ten <= abs_sub_30[3:0];
                bcd_ten <= 4'd3;
	   end  else if (abs_sub_20[7] == 0)begin
                res_ten <= abs_sub_20[3:0];
                bcd_ten <= 4'd2;
	   end  else if (abs_sub_10[7] == 0)begin
                res_ten <= abs_sub_10[3:0];
                bcd_ten <= 4'd1;
           end else begin
		res_ten <= res_th[3:0];
                bcd_ten <= 4'd0;
	   end

       end

end


/******************************************************************************/

//calc bcd output               (pipeline fifth step)

/******************************************************************************/

assign bcd_vld = bcd_pipeline_cyc[3];
assign bcd = {bin_sign_tra2, 3'h0, bcd_th_tra1, bcd_hu_tra0, bcd_ten, res_ten};

endmodule

