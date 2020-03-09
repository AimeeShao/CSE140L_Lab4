//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// --------------------------------------------------------------------
//           
//                     Lih-Feng Tsaur
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
// Example:
//  wire [10:0] i_count, o_count;
//  N_bit_counter #(11) count00(
//    .resuu<lt (o_count)       , // Output
//    .r1 (i_count)             , // input
//    .up (1'b1)                  //1: count up, 0: count down
//  );
//
//  NOTE:  Don't turn on USE_HALF_ADDER, it is for illustration only
// Revision History : 0.0
//---------------------------------------------------------------------
module N_bit_counter #(parameter N = 4)(
output [N-1:0] result , // Output
input  [N-1:0] r1     , // input
input          up
);

// Internal variables
wire     [N-1:0]      ci       ;

assign result[0] = ~r1[0];
genvar i;
generate
    for (i = 1; i < N; i=i+1) 
    begin : counter_gen_label	
        assign ci[i] = (up)? &r1[i-1:0] : ~|r1[i-1:0];
        xor (result[i], r1[i], ci[i]);
    end
endgenerate

endmodule 