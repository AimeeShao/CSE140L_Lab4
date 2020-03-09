
// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //      
//
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
// bcd2segment
//
// convert binary coded decimal to seven segment display
//
//                        aaa
//                       f   b 
//                       f   b
//                       f   b				
//                        ggg
//                       e   c
//                       e   c
//                       e   c
//                        ddd 
//
// segment[0] - a     segment[3] - d    segment[6] - g
// segment[1] - b     segment[4] - e
// segment[2] - c     segment[5] - f
//
module bcd2segment (
		  output wire [6:0] segment,  // 7 drivers for segment
		  input  wire [3:0] num,      // number to convert
		  input wire enable           // if 1, drive display, else blank
		  );


   wire [6:0] segmentUQ;
   
   // seq.1 add code to generate segment a, b, c, d, e, f, g
   //       replace == by boolean operators: & | ~ ^
   //       5% of the points assigned to lab3
   
   // a
   assign segmentUQ[0] =  ~|(num ^ 4'd0) |
			~|(num ^ 4'd2) |
			~|(num ^ 4'd3) |
			~|(num ^ 4'd5) |
			~|(num ^ 4'd6) |
			~|(num ^ 4'd7) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd9) |
			~|(num ^ 4'd10) |
			~|(num ^ 4'd12) |
			~|(num ^ 4'd14) |
			~|(num ^ 4'd15);

   // b
   assign segmentUQ[1] = ~|(num ^ 4'd0) |
			~|(num ^ 4'd1) |
			~|(num ^ 4'd2) |
			~|(num ^ 4'd3) |
			~|(num ^ 4'd4) |
			~|(num ^ 4'd7) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd9) |
			~|(num ^ 4'd10) |
			~|(num ^ 4'd13);

   // c
   assign segmentUQ[2] = ~|(num ^ 4'd0) |
			~|(num ^ 4'd1) |
			~|(num ^ 4'd3) |
			~|(num ^ 4'd4) |
			~|(num ^ 4'd5) |
			~|(num ^ 4'd6) |
			~|(num ^ 4'd7) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd9) |
			~|(num ^ 4'd10) |
			~|(num ^ 4'd11) |
			~|(num ^ 4'd13);
   
   // d
   assign segmentUQ[3] = ~|(num ^ 4'd0) |
			~|(num ^ 4'd2) |
			~|(num ^ 4'd3) |
			~|(num ^ 4'd5) |
			~|(num ^ 4'd6) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd9) |
			~|(num ^ 4'd11) |
			~|(num ^ 4'd12) |
			~|(num ^ 4'd13) |
			~|(num ^ 4'd14);
   
   // e
   assign segmentUQ[4] = ~|(num ^ 4'd0) |
			~|(num ^ 4'd2) |
			~|(num ^ 4'd6) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd10) |
			~|(num ^ 4'd11) |
			~|(num ^ 4'd12) |
			~|(num ^ 4'd13) |
			~|(num ^ 4'd14) |
			~|(num ^ 4'd15);
   
   // f
   assign segmentUQ[5] = ~|(num ^ 4'd0) |
			~|(num ^ 4'd4) |
			~|(num ^ 4'd5) |
			~|(num ^ 4'd6) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd9) |
			~|(num ^ 4'd10) |
			~|(num ^ 4'd11) |
			~|(num ^ 4'd14) |
			~|(num ^ 4'd15);

   // g
   assign segmentUQ[6] = ~|(num ^ 4'd2) |
			~|(num ^ 4'd3) |
			~|(num ^ 4'd4) |
			~|(num ^ 4'd5) |
			~|(num ^ 4'd6) |
			~|(num ^ 4'd8) |
			~|(num ^ 4'd9) |
			~|(num ^ 4'd10) |
			~|(num ^ 4'd11) |
			~|(num ^ 4'd12) |
			~|(num ^ 4'd13) |
			~|(num ^ 4'd14) |
			~|(num ^ 4'd15);

   assign segment = {7{enable}} & segmentUQ;
   
endmodule

   
   

   
   
   
   
   
   

   
   

