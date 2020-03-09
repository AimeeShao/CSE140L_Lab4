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

		output reg alarmDspMtens,
		output reg alarmDspMones,
		output reg alarmDspStens,
		output reg alarmDspSones,
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

    reg  n_alarm_ena;

    // state 0: STOP, state 1: RUN
    // state 2: LT_10M, state 3: LT_1M, state 4: LT_10S, state 5: LT_1S
    // state 6: LA_10M, state 7: LA_1M, state 8: LA_10S, state 9: LA_1S
    reg [3:0] cState;
    reg [3:0] nState;

    //  outputs
    //  RUN: dicRun = 1;  dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1; ld_time = 0; ld_alarm = 0;
    //  STOP: dicRun = 0; dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1; ld_time = 0; ld_alarm = 0;
    //  LT_10M: dicDspMtens = 1; dicDspMones = 0; dicDspStens = 0; dicDspSones= 0; ld_time = 1; ld_alarm = 0; dicLdMtens = 1; dicLdMones = 0; dicLdStens = 0; dicLdSones = 0;
    //  LT_1M: dicDspMtens = 1; dicDspMones = 1; dicDspStens = 0; dicDspSones= 0; ld_time = 1; ld_alarm = 0; dicLdMtens = 0; dicLdMones = 1; dicLdStens = 0; dicLdSones = 0;
    //  LT_10S: dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 0; ld_time = 1; ld_alarm = 0; dicLdMtens = 0; dicLdMones = 0; dicLdStens = 1; dicLdSones = 0;
    //  LT_1S: dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1; ld_time = 1; ld_alarm = 0; dicLdMtens = 0; dicLdMones = 0; dicLdStens = 0; dicLdSones = 1;
    //  LA_10M: alarmDspMtens = 1; alarmDspMones = 0; alarmDspStens = 0; alarmDspSones= 0; ld_time = 0; ld_alarm = 1; dicLdMtens = 1; dicLdMones = 0; dicLdStens = 0; dicLdSones = 0;
    //  LA_1M: alarmDspMtens = 1; alarmDspMones = 1; alarmDspStens = 0; alarmDspSones= 0; ld_time = 0; ld_alarm = 1; dicLdMtens = 0; dicLdMones = 1; dicLdStens = 0; dicLdSones = 0;
    //  LA_10S: alarmDspMtens = 1; alarmDspMones = 1; alarmDspStens = 1; alarmDspSones= 0; ld_time = 0; ld_alarm = 1; dicLdMtens = 0; dicLdMones = 0; dicLdStens = 1; dicLdSones = 0;
    //  LA_1S: alarmDspMtens = 1; alarmDspMones = 1; alarmDspStens = 1; alarmDspSones= 1; ld_time = 0; ld_alarm = 1; dicLdMtens = 0; dicLdMones = 0; dicLdStens = 0; dicLdSones = 1;
    //  WAIT: displays all = 1; ld_time = 0; ld_alarm = 0; dicLdMtens = 0; dicLdMones = 0; dicLdStens = 0; dicLdSones = 0;
    //  Exception
    //  alarm_ena: alarmDspMtens = 1; alarmDspMones = 1; alarmDspStens = 1; alarmDspSones= 1;
    //  ~alarm_ena: if RUN or STOP: alarmDspMtens = 0; alarmDspMones = 0; alarmDspStens = 0; alarmDspSones= 0;

    localparam
    STOP    =4'b0, 
    RUN     =4'b1,
    LT_10M = 4'b2,
    LT_1M = 4'b3,
    LT_10S = 4'b4,
    LT_1S = 4'b5,   
    LT_10M = 4'b6,
    LT_1M = 4'b7,
    LT_10S = 4'b8,
    LT_1S = 4'b9,
    WAIT = 4'b10,

    // OFF and ON for alarm_ena
    OFF = 1'b0,
    ON = 1'b1;
   
    //
    // state machine next state
    //
    //FSM.1 add code to set nState to STOP or RUN
    //      if det_S -- nState = RUN
    //      if det_cr -- nState = STOP
    //	    if det_atSign -- trigger alarm_ena
    //      if det_L -- nState = LT_10M
    //	    if det_A -- nState = LA_10M
    //      5% of points assigned to lab3
    always @(*) begin
        if (rst) begin // if reset, next state is STOP, alarm_ena is off
	        nState = STOP;
		n_alarm_ena = OFF;
	end else begin
	   if (det_atSign) // trigger alarm
		n_alarm_ena = (alarm_ena)? OFF: ON;

	   // cState: nState if condition
	   // RUN: STOP if det_cr, LT_10M if det_L, LA_10M if det_A
	   // STOP: RUN if det_S, LT_10M if det_L, LA_10M if det_A
	   // LT_.. and LA_..: next stage if (det_num) or (det_num0to5)
	   // WAIT: RUN if det_S, STOP if det_cr
	   case (cState)
		RUN: nState = (det_cr) ? STOP : (det_L) ? LT_10M : (det_A) ? LA_10M : RUN;
		STOP: nState = (det_S) ? RUN : (det_L) ? LT_10M : (det_A) ? LA_10M : STOP;
		LT_10M: nState = (det_num0to5) ? LT_1M : LT_10M;
		LT_1M: nState = (det_num) ? LT_10S : LT_1M;
		LT_10S: nState = (det_num0to5) ? LT_1S : LT_10S;
		LT_1S: nState = (det_num) ? WAIT : LT_1S;
		LA_10M: nState = (det_num0to5) ? LA_1M : LA_10M;
		LA_1M: nState = (det_num) ? LA_10S : LA_1M;
		LA_10S: nState = (det_num0to5) ? LA_1S : LA_10S;
		LA_1S: nState = (det_num) ? WAIT : LA_1S;
		WAIT: nState = (det_S) ? RUN : (det_CR) ? STOP : WAIT;
	   endcase
    end

    //
    // state machine outputs
    //
    //FSM.2 add code to set the output signals of 
    //      STOP and RUN states
	//      5% of points assigned to Lab3
    always @(*) begin
        case (cState)
	    STOP : begin // Stop displays all, but does not run
	        dicRun = 0;
	        dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 1;
	        dicDspSones = 1;
	        alarmDspMtens = alarm_ena;
	        alarmDspMones = alarm_ena;
	        alarmDspStens = alarm_ena;
	        alarmDspSones = alarm_ena;
		ld_time = 0;
		ld_alarm = 0;
	    end
	    RUN : begin // Run displays all and runs
	        dicRun = 1;
	        dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 1;
	        dicDspSones = 1;
	        alarmDspMtens = alarm_ena;
	        alarmDspMones = alarm_ena;
	        alarmDspStens = alarm_ena;
	        alarmDspSones = alarm_ena;
		ld_time = 0;
		ld_alarm = 0;
	    end

	    // load clock, affects clock display
	    LT_10M: begin
		dicDspMtens = 1;
	        dicDspMones = 0;
	        dicDspStens = 0;
	        dicDspSones = 0;
		dicLdMtens = 1;
		dicLdMones = 0;
		dicLdStens = 0;
		dicLdSones = 0;
	    end
	    LT_1M: begin 
		dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 0;
	        dicDspSones = 0;
		dicLdMtens = 0;
		dicLdMones = 1;
		dicLdStens = 0;
		dicLdSones = 0;
	    end
	    LT_10S: begin
		dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 1;
	        dicDspSones = 0;
		dicLdMtens = 0;
		dicLdMones = 0;
		dicLdStens = 1;
		dicLdSones = 0;
	    end
	    LT_1S: begin
		dicDspMtens = 1;
	        dicDspMones = 1;
	        dicDspStens = 1;
	        dicDspSones = 1;
		dicLdMtens = 0;
		dicLdMones = 0;
		dicLdStens = 0;
		dicLdSones = 1;
	    end

	    // load alarm, affects alarm display
	    LA_10M: begin
		alarmDspMtens = 1;
	        alarmDspMones = 0;
	        alarmDspStens = 0;
	        alarmDspSones = 0;
		dicLdMtens = 1;
		dicLdMones = 0;
		dicLdStens = 0;
		dicLdSones = 0;
	    end
	    LA_1M: begin 
		alarmDspMtens = 1;
	        alarmDspMones = 1;
	        alarmDspStens = 0;
	        alarmDspSones = 0;
		dicLdMtens = 0;
		dicLdMones = 1;
		dicLdStens = 0;
		dicLdSones = 0;
	    end
	    LA_10S: begin
		alarmDspMtens = 1;
	        alarmDspMones = 1;
	        alarmDspStens = 1;
	        alarmDspSones = 0;
		dicLdMtens = 0;
		dicLdMones = 0;
		dicLdStens = 1;
		dicLdSones = 0;
	    end
	    LA_1S: begin
		alarmDspMtens = 1;
	        alarmDspMones = 1;
	        alarmDspStens = 1;
	        alarmDspSones = 1;
		dicLdMtens = 0;
		dicLdMones = 0;
		dicLdStens = 0;
		dicLdSones = 1;
	    end

	    WAIT: begin
		dicLdMtens = 0;
		dicLdMones = 0;
		dicLdStens = 0;
		dicLdSones = 0;
		ld_time = 0;
		ld_alarm = 0;
	    end
        endcase
	
	// change alarm display based on alarm_ena
	if (alarm_ena) begin // all display on
	    	alarmDspMtens = 1;
	        alarmDspMones = 1;
	        alarmDspStens = 1;
	        alarmDspSones = 1;
	end
   end

   always @(posedge clk) begin
      cState <= nState;
      alarm_ena <= n_alarm_ena;
   end
   
endmodule
