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

module dictrl(
        output    dicSelectLEDdisp, //select LED
	output 	  dicRun,           // clock should run
	output	  alarm_ena,	    // should see alarm
	output 	  ld_time,	    // should be loading time
	output	  ld_alarm,	    // should be loading alarm
	output 	  dicDspMtens,
	output 	  dicDspMones,
	output 	  dicDspStens,
	output 	  dicDspSones,
        output    dicLdMtens,
        output    dicLdMones,
        output    dicLdStens,
        output    dicLdSones,
		
        input 	    rx_data_rdy,// new data from uart rdy
        input [7:0] rx_data,    // new data from uart
        input 	  rst,
	input 	  clk
    );
	
    wire   det_num;
    wire   det_num0to5;
    wire   det_cr;
    wire   det_atSign;
    wire   det_A;
    wire   det_L;
    wire   det_S;
   
    // added outputs for momre states
    decodeKeys dek ( 
        .det_num(det_num),
        .det_num0to5(det_num0to5),
        .det_cr(det_cr),
        .det_atSign(det_atSign),
        .det_A(det_A),
        .det_L(det_L),
	.det_S(det_S),             
        .det_N(dicSelectLEDdisp),
	.charData(rx_data),      .charDataValid(rx_data_rdy)
    );

    // added inputs for more states and output ldT
    dicClockFsm dicfsm (
            .dicRun(dicRun),
	    .alarm_ena(alarm_ena),
	    .ld_time(ld_time),
	    .ld_alarm(ld_alarm),
            .dicDspMtens(dicDspMtens), .dicDspMones(dicDspMones),
            .dicDspStens(dicDspStens), .dicDspSones(dicDspSones),
	    .dicLdMtens(dicLdMtens), .dicLdMones(dicLdMones),
	    .dicLdStens(dicLdStens), .dicLdSones(dicLdSones),
	    .det_num(det_num),
            .det_num0to5(det_num0to5),
            .det_cr(det_cr),
            .det_atSign(det_atSign),
            .det_A(det_A),
            .det_L(det_L),
            .det_S(det_S), 
            .rst(rst),
            .clk(clk)
    );
   
endmodule


