
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
// clock enabled counter
//
module countrce #(parameter WIDTH = 4)
   (
    output reg [WIDTH-1:0] q,
    input wire [WIDTH-1:0] d,
    input wire             ld, // load the counter
    input wire		       ce, //clock enable
    input wire		       rst, // synchronous reset
    input wire		       clk
    );

    // count.1 add code to replace q+1
    //         20% of points assigned to Lab3

    wire [WIDTH-1:0] q_next;

    defparam count00.N = WIDTH;
    // generate 4 bit counter module and get q_next as output
    N_bit_counter count00(
        .result (q_next)          , // Output
        .r1 (q)                   , // input
        .up (1'b1)                  //1: count up, 0: count down
    );

    // sequential logic
    always @(posedge clk) begin   
        if (rst)
            q <= {WIDTH{1'b0}};
        else begin
            if (~ce)
                q <= q;
            else begin
                if (ld)
                    q <= d;
                else
                    q <= q_next; // **** replace this
            end
        end
   end

endmodule

