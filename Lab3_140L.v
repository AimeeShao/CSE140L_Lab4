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
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

module Lab3_140L (
		input wire       rst,             // reset signal (active high)
		input wire       clk,             // global clock
		input wire       bu_rx_data_rdy,  // data from the uart ready
		input wire [7:0] bu_rx_data,      // data from the uart
		output wire 	 L3_tx_data_rdy,  // data rdy to display
		output wire[7:0] L3_tx_data,      // data to display
		output wire[4:0] L3_led,          //5 LED control - 1: on, 0, off
		output wire      oneSecPluse,     //Generate 0.5 sec high and 0.5 sec low    	  
		output wire[6:0] L3_segment1,     //not used in Lab-2
		output wire[6:0] L3_segment2,     //not used in Lab-2
		output wire[6:0] L3_segment3,     //not used in Lab-2
		output wire[6:0] L3_segment4,     //not used in Lab-2

		output wire[3:0] di_Mtens,        //not used in Lab-2
		output wire[3:0] di_Mones,        //not used in Lab-2
		output wire[3:0] di_Stens,        //not used in Lab-2
		output wire[3:0] di_Sones,        //not used in Lab-2
		output wire[3:0] di_AMtens,       //not used in Lab-2
		output wire[3:0] di_AMones,       //not used in Lab-2
		output wire[3:0] di_AStens,       //not used in Lab-2
		output wire[3:0] di_ASones        //not used in Lab-2
    );
    wire[7:0] rx_data;
    wire rx_data_rdy;
    regrce #(8) Lab3U00 (
    .q(rx_data),
    .d(bu_rx_data),
    .ce(bu_rx_data_rdy),    //clock enable
    .rst(rst),              // synchronous reset
    .clk(clk)
    );
    regrce #(1) Lab3U01 (
    .q(rx_data_rdy),
    .d(bu_rx_data_rdy),
    .ce(1'b1),           //clock enable
    .rst(rst),           // synchronous reset
    .clk(clk)
    );
     
    // generate a sync signal
    //
    //                  | < ------- 1 sec -------|
    //
    //   oneSecStrb_____/----\_________......____/----\_______
    //
    //        clk  ___/--\__/--\__/--\.......__/--\__/--
    //
    wire l_oneSecPluse, l_oneSecStrb;
    Half_Sec_Pulse_Per_Sec secuu0 (
			.i_rst (rst),       //reset
			.i_clk (clk),       //system clk 12MHz 
            .o_sec_tick (l_oneSecPluse),
			.o_sec_enab (l_oneSecStrb)
        );

    wire dicSelectLEDdisp, dicRun;
    wire alarm_ena, ld_time, ld_alarm;
    wire dicDspMtens, dicDspMones, dicDspStens, dicDspSones; //1:display, 0: don't display
    wire dicLdMtens, dicLdMones, dicLdStens, dicLdSones;     //1:load clk digit, 0: don't load
    wire alarmDspMtens, alarmDspMones, alarmDspStens, alarmDspSones; //1:display, 0: don't display
    wire [3:0] alarm_10m;
    wire [3:0] alarm_1m;
    wire [3:0] alarm_10s;
    wire [3:0] alarm_1s;

    dictrl dictrluu0(
        .dicSelectLEDdisp(dicSelectLEDdisp),
	    .dicRun(dicRun),             // clock should run
	    .alarm_ena(alarm_ena),	 // alarm should be on
	    .ld_time(ld_time),		 // loading time
	    .ld_alarm(ld_alarm),	 // loading alarm

	    .dicDspMtens(dicDspMtens),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspMones(dicDspMones),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspStens(dicDspStens),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspSones(dicDspSones),   // 1: update 7 segment; 0: freeze 7 segment display

	    .dicLdMtens(ld_Mtens),
	    .dicLdMones(ld_Mones),
	    .dicLdStens(ld_Stens),
	    .dicLdSones(ld_Sones),

	    .alarmDspMtens(alarmDspMtens),
	    .alarmDspMones(alarmDspMones),
	    .alarmDspStens(alarmDspStens),
	    .alarmDspSones(alarmDspSones),
		
        .rx_data_rdy(rx_data_rdy),// new data from uart rdy
        .rx_data(rx_data),        // new data from uart
        .rst(rst),
	    .clk(clk)
    );

   assign dicLdMtens = ld_Mtens & rx_data_rdy;
   assign dicLdMones = ld_Mones & rx_data_rdy;
   assign dicLdStens = ld_Stens & rx_data_rdy;
   assign dicLdSones = ld_Sones & rx_data_rdy;

   didp didpuu0(
        // output
	    .di_iMtens(di_Mtens), // current 10's minutes
	    .di_iMones(di_Mones), // current 1's minutes
	    .di_iStens(di_Stens), // current 10's second
	    .di_iSones(di_Sones), // current 1's second

	// alarm output
	    .alarm_10m(alarm_10m), // current alarm 10's minutes
	    .alarm_1m(alarm_1m), // current alarm 1's minutes
	    .alarm_10s(alarm_10s), // current alarm 10's seconds
	    .alarm_1s(alarm_1s), // current alarm 1's seconds
	  
        .o_oneSecPluse(oneSecPluse),
        .L3_led(L3_led),
		
		//loading clock or alarm
	.ld_time(ld_time),
	.ld_alarm(ld_alarm),
        .ldMtens(dicLdMtens),
        .ldMones(dicLdMones),
        .ldStens(dicLdStens),
        .ldSones(dicLdSones),
	    .ld_num(rx_data[3:0]), 
		
        .dicSelectLEDdisp(dicSelectLEDdisp),		
	    .dicRun(dicRun),                // 1: clock runs, 0: clock freeze 
        .i_oneSecPluse(l_oneSecPluse),	// 0.5 sec on, 0.5sec off
	    .i_oneSecStrb(l_oneSecStrb),    // one strobe per sec
	    .rst(rst),
	    .clk(clk) 	  
	);

    // convert to the presentation of 7 segment display
    bcd2segment dec0 (.segment(L3_segment1), .num(di_Sones), .enable(dicDspSones));
    bcd2segment dec1 (.segment(L3_segment2), .num(di_Stens), .enable(dicDspStens));
    bcd2segment dec2 (.segment(L3_segment3), .num(di_Mones), .enable(dicDspMones));
    bcd2segment dec3 (.segment(L3_segment4), .num(di_Mtens), .enable(dicDspMtens));

    wire [7:0] b1 = (alarm_ena & alarmDspMtens)? {4'b0011, alarm_10m} : "-";
    wire [7:0] b2 = (alarm_ena & alarmDspMones)? {4'b0011, alarm_1m} : "-";
    wire [7:0] b3 = (alarm_ena & alarmDspMones)? ":": "-";
    wire [7:0] b4 = (alarm_ena & alarmDspStens)? {4'b0011, alarm_10s} : "-";
    wire [7:0] b5 = (alarm_ena & alarmDspSones)? {4'b0011, alarm_1s} : "-";
    wire [7:0] b6 = (trig)? "T": (alarm_ena)? "@" : "-";

    assign trig = (alarm_ena) & ~|(alarm_10m ^ di_Mtens) & ~|(alarm_1m ^ di_Mones) & ~|(alarm_10s ^ di_Stens) & ~|(alarm_1s ^ di_Sones);

    dispString dspStr (
		  .rdy(L3_tx_data_rdy)
        , .dOut(L3_tx_data)
		, .b0("A") 
		, .b1(b1)
		, .b2(b2)
		, .b3(b3)
		, .b4(b4) 
		, .b5(b5)
		, .b6(b6)
		, .b7(8'h0d)
		, .go(l_oneSecStrb)	
		, .rst(rst)
		, .clk(clk)
    );
	
endmodule // Lab2_140L
