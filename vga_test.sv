module vga_test(switches, reset, clock, hsync, vsync, red, green, blue, leds, dig0, dig1, dig2, dig3, dig4, dig5);
	input [9:0] switches;
	input reset;
	input clock;
	output reg hsync;			//horizontal sync out
	output reg vsync;			//vertical sync out
	output reg [3:0] red;	//red vga output
	output reg [3:0] green; //green vga output
	output reg [3:0] blue;	//blue vga output
	output [9:0] leds;
	output [7:0] dig0;
	output [7:0] dig1;
	output [7:0] dig2;
	output [7:0] dig3;
	output [7:0] dig4;
	output [7:0] dig5;
	
	reg [19:0] score;
	
	reg vgaClock;

	pll vga_generator(clock, vgaClock);
	
	hardcoded_vga UUT(vgaClock, !reset, switches, hsync, vsync, red, green, blue, score);
	
	sevenSegDisp scoreboard(score, dig5, dig4, dig3, dig2, dig1, dig0);
	
	
	
endmodule