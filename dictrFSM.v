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
//Finite State Machine of Control Path
// using 3 always 
module dicClockFsm (
		output reg dicRun,     // clock is running
		output reg alarm_ena,  // alarm is enabled
		output reg ld_time,    // we are loading time
		output reg ld_alarm,   // we are loading alarm
		output reg dicLdMtens,
		output reg dicLdMones,
		output reg dicLdStens,
		output reg dicLdSones,
		output reg dicDspMtens,
		output reg dicDspMones,
		output reg dicDspStens,
		output reg dicDspSones,
        input      det_num,    // 0-9 detected
        input      det_num0to5, // 0-5 detected
        input      det_cr,
        input      det_atSign, // @ detected
        input      det_A,      // A/a detected
        input      det_L,      // L/l detected
        input      det_S,      // S/s detected
		input      rst,
		input      clk
    );

    reg  cState;
    reg  nState;

    // adding set T and A states
    reg [1:0] setT_cState;
    reg [1:0] setT_nStates;

    reg [1:0] setA_cState;
    reg [1:0] setA_nState;

    // only 2 states:
    //  RUN: dicRun = 1;  dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1;
    //  STOP: dicRun = 0; dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1;
    localparam
    STOP    =1'b0, 
    RUN     =1'b1;

    // adding local params for T and A states
    TMTENS = 2'b00;
    TMONES = 2'b01;
    TSTENS = 2'b10;
    TSONES = 2'b11;
    AMTENS = 2'b00;
    AMONES = 2'b01;
    ASTENS = 2'b10;
    ASONES = 2'b11;   
   
    //
    // state machine next state
    //
    //FSM.1 add code to set nState to STOP or RUN
    //      if det_S -- nState = RUN
    //      if det_cr -- nState = STOP
    //
    //      if det_
    //      5% of points assigned to lab3
    always @(*) begin
        if (rst) // if reset, next state is STOP
	        nState = STOP;
        else begin
        	case (cState) // if running and CR, then stop. if stopped and S/s, then run.
	           RUN: nState = (det_cr) ? STOP : RUN;
		   STOP: nState = (det_S) ? RUN : STOP;
		endcase
	end

	if (
    end

    //
    // state machine outputs
    //
    //FSM.2 add code to set the output signals of 
    //      STOP and RUN states
	//      5% of points assigned to Lab3
    always @(*) begin
        dicRun = 0;
        dicDspMtens = 0;
        dicDspMones = 0;
        dicDspStens = 0;
        dicDspSones = 0;
        case (cState)
	    STOP : begin // Stop displays all, but does not run
	        dicRun = 0;
	        dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 1;
	        dicDspSones = 1;
	    end
	    RUN : begin // Run displays all and runs
	        dicRun = 1;
	        dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 1;
	        dicDspSones = 1;
	    end
        endcase
   end

   always @(posedge clk) begin
      cState <= nState;
   end
   
endmodule
