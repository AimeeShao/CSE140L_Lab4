
module didp (
	    output [3:0] di_iMtens,  // current 10's minutes
	    output [3:0] di_iMones,  // current 1's minutes
	    output [3:0] di_iStens,  // current 10's second
	    output [3:0] di_iSones,  // current 1's second

	    output reg [3:0] alarm_10m,  // current alarms 10's minutes
	    output reg [3:0] alarm_1m,  // current alarms 1's minutes
	    output reg [3:0] alarm_10s,  // current alarms 10's second
	    output reg [3:0] alarm_1s,  // current alarms 1's second

            output       o_oneSecPluse,
            output [4:0] L3_led,     // LED Output

		//loading clock or alarm
	    input	 ld_time,
	    input	 ld_alarm,
            input        ldMtens,
            input        ldMones,
            input        ldStens,
            input        ldSones,
	    input	 valid_num,
	    input [3:0]  ld_num,

	    input	 trig,

            input        dicSelectLEDdisp,
	    input 	     dicRun,      // 1: clock should run, 0: clock freeze	
            input        i_oneSecPluse, // 0.5 sec on, 0.5 sec off		
	    input 	     i_oneSecStrb,  // one strobe per sec
	    input 	     rst,
	    input 	     clk 	  
	);

    assign o_oneSecPluse = i_oneSecPluse | ~(dicRun);
    wire clkSecStrb = i_oneSecStrb & dicRun;

    //(dp.1) change this line and add code to set 3 more wires: StensIs5, MonesIs9, MtensIs5
    //   these 4 wires determine if digit reaches 5 or 9.  10% of points assigned to Lab3
    wire SonesIs9 = ~|(di_iSones ^ 4'd9);
    wire StensIs5 = ~|(di_iStens ^ 4'd5);
    wire MonesIs9 = ~|(di_iMones ^ 4'd9);
    wire MtensIs5 = ~|(di_iMtens ^ 4'd5);

    //(dp.2) add code to set 3 more wires: rollStens, rollMones, rollMtens
    //   these 4 wires determine if digit shall be rolled back to 0 : 10% of points assigned to Lab3
    
    // Each digts rolls only if all the digits on the right are maxed at 5 or 9
    wire rollSones = SonesIs9;
    wire rollStens = StensIs5 & SonesIs9;
    wire rollMones = MonesIs9 & StensIs5 & SonesIs9;
    wire rollMtens = MtensIs5 & MonesIs9 & StensIs5 & SonesIs9;

    //(dp.3) add code to set 3 more wires: countEnStens, countEnMones, countEnMtens
    //   these 4 wires generate a strobe to advance counter: 10% of points assigned to Lab3

    // counter is enabled when the digit to the right needs to roll to 0.
    wire countEnSones = clkSecStrb; // enable the counter Sones
    wire countEnStens = rollSones & clkSecStrb;
    wire countEnMones = rollStens & clkSecStrb;
    wire countEnMtens = rollMones & clkSecStrb;
 
    //(dp.4) add code to set sTensDin, mOnesDin, mTensDin
    //   0% of points assigned to Lab3, used in Lab4
    wire [3:0] sOnesDin = (ldSones) ? (valid_num) ? ld_num : di_iSones : 4'b0;
    wire [3:0] sTensDin = (ldStens) ? (valid_num) ? ld_num : di_iStens : 4'b0;
    wire [3:0] mOnesDin = (ldMones) ? (valid_num) ? ld_num : di_iMones : 4'b0;
    wire [3:0] mTensDin = (ldMtens) ? (valid_num) ? ld_num : di_iMtens : 4'b0;
   		
    //(dp.5) add code to generate digital clock output: di_iStens, di_iMones di_iMtens 
    //   20% of points assigned to Lab3
    // Added ld_time for .ld and .ce
    countrce didpsones (.q(di_iSones),          .d(sOnesDin), 
                        .ld(rollSones|(ld_time & ldSones)),
			.ce(countEnSones|(ld_time & ldSones)), 
                        .rst(rst),              .clk(clk));
    countrce didpstens (.q(di_iStens),          .d(sTensDin), 
                        .ld(rollStens|(ld_time & ldStens)), 
			.ce(countEnStens|(ld_time & ldStens)), 
                        .rst(rst),              .clk(clk));
    countrce didpmones (.q(di_iMones),          .d(mOnesDin), 
                        .ld(rollMones|(ld_time & ldMones)),
			.ce(countEnMones|(ld_time & ldMones)), 
                        .rst(rst),              .clk(clk));
    countrce didpmtens (.q(di_iMtens),          .d(mTensDin), 
                        .ld(rollMtens|(ld_time & ldMtens)),
			.ce(countEnMtens|(ld_time & ldMtens)), 
                        .rst(rst),              .clk(clk));
    
    // load alarm. reset -> all = 0, else depends on load
    always @(*) begin
	if (rst) begin
	   alarm_10m <= 4'b0;
	   alarm_1m <= 4'b0;
	   alarm_10s <= 4'b0;
	   alarm_1s <= 4'b0;
	end else begin
	   alarm_10m <= (ld_alarm & ldMtens & valid_num)? ld_num: alarm_10m;
	   alarm_1m <= (ld_alarm & ldMones & valid_num)? ld_num: alarm_1m;
	   alarm_10s <= (ld_alarm & ldStens & valid_num)? ld_num: alarm_10s;
	   alarm_1s <= (ld_alarm & ldSones & valid_num)? ld_num: alarm_1s;
	end
    end

    ledDisplay ledDisp00 (
        .L3_led(L3_led),
        .di_Mtens(di_iMtens),
        .di_Mones(di_iMones),
        .di_Stens(di_iStens),
        .di_Sones(di_iSones),
        .dicSelectLEDdisp(dicSelectLEDdisp),
	.dicRun(dicRun),
	.trig(trig),
        .oneSecPluse(o_oneSecPluse),
        .rst(rst),
        .clk(clk)
    );
endmodule

//
// LED display
// select what to display on the real LEDs
// 10's minutes, 1's minutes
// 10's seconds, 1's seconds
// dicSelectLEDdisp will move from one to another.
//
module ledDisplay (
        output[4:0] L3_led,
        input [3:0] di_Mtens,
        input [3:0] di_Mones,
        input [3:0] di_Stens,
        input [3:0] di_Sones,
        input  dicSelectLEDdisp, //1: LED is move to display the next digit of clk 
	input  dicRun,
	input  trig,
        input  oneSecPluse,
        input  rst,
        input  clk
    );
	
	//dp.6 add code to select output to LED	
    //     10% of points assigned to lab3
    reg  [1:0] selLed;

    // generate 2 bit counter from module
    wire [1:0] Led_next;
    N_bit_counter #(2) countLED (
        .result (Led_next)         , // Output
        .r1 (selLed)               , // input
        .up (1'b1)                  //1: count up, 0: count down
    );

    always @(posedge clk) begin
        if (rst)
            selLed <= 2'b00;
        else begin
            if (dicSelectLEDdisp)
                selLed <= Led_next;
        end
    end

    assign L3_led = (trig) ? 
	(dicRun) ? (oneSecPluse) ? 5'b11111 : 5'b0 :
	5'b11111 :
        ~|(selLed ^ 2'b00) ? {oneSecPluse, di_Sones} :
        ~|(selLed ^ 2'b01) ? {oneSecPluse, di_Stens} :
        ~|(selLed ^ 2'b10) ? {oneSecPluse, di_Mones} :
        {oneSecPluse, di_Mtens};

endmodule
