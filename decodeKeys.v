
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
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
//
//  decodeKeys
//
// decode the 8 bit ascii input charData when
// charDataValid is asserted.
// specifically, we decode
//   'ESC' 
//   '0-9'
//   '0-5'
//   'CR' - stop (carriage return)
//   '@'
//   'a'
//   'l' 
//   's''S' -- start
//   'n''N' -- select LED 
//
module decodeKeys(
        output wire     det_esc,
        output wire     det_num,
        output wire     det_num0to5, 
        output wire     det_cr,
        output wire     det_atSign,
        output wire     det_A,
        output wire     det_L,
        output wire     det_N,
        output wire     det_S,
        input wire[7:0] charData,
        input wire      charDataValid
    );

   // Key.1 add code to detect input keys
   //   5% of points assigned to Lab3

   // esc - 1b
   assign det_esc = ~|(charData ^ 8'd27) & charDataValid;

   // 0-5
   assign det_num0to5 = 1'b0 & charDataValid;
   
   // 0-9
   assign det_num = 1'b0 &  charDataValid;      

   assign det_cr = ~|(charData ^ 8'd13) & charDataValid;

   // "A/a" = 41/61
   assign det_A = (charData == "a") & charDataValid;
   
   // "L/l" = 4C/6C
   assign det_L = (charData == "l") & charDataValid;

   // "N/n" = 4E/6E
   assign det_N = ~|((charData | 8'b0010_0000) ^ "n") & charDataValid;

   // "S/s" = 53/73
   assign det_S = ~|((charData | 8'b0010_0000) ^ "s") & charDataValid;

   // "@" = 40
   assign det_atSign = (charData == "@") & charDataValid;
   
endmodule
