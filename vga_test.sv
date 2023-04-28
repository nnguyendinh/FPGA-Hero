module vga_test(reset, clock, hsync, vsync, red, green, blue);
	input reset;
	input clock;
	output reg hsync;			//horizontal sync out
	output reg vsync;			//vertical sync out
	output reg [3:0] red;	//red vga output
	output reg [3:0] green; //green vga output
	output reg [3:0] blue;	//blue vga output
	reg blank;
	
	reg vgaClock;

	pll vga_generator(clock, vgaClock);
	
	hardcoded_vga UUT(vgaClock, reset, hsync, vsync, red, green, blue, blank);
	
	
	
endmodule