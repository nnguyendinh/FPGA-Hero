module color_picker(
		input color_mode,			//black and white or color?
		input [2:0] color,		// what color?
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue	//blue vga output
   );
	
	parameter BW = 1'b0;
	parameter COLORED = 1'b1;

	parameter BLACK = 3'b000;
	parameter WHITE = 3'b001;
	parameter GRAY = 3'b010;
	parameter BROWN = 3'b011;
	
	parameter GREEN = 3'b000;
	parameter RED = 3'b001;
	parameter YELLOW = 3'b010;
	parameter BLUE = 3'b011;
	parameter ORANGE = 3'b100;
	
	always_comb begin
	
		if (color_mode == BW) begin
			if (color == BLACK) begin
				red <= 4'b0000;
				green <= 4'b0000;
				blue <= 4'b0000;
			end
			else if (color == GRAY) begin
				red <= 4'b1000;
				green <= 4'b1000;
				blue <= 4'b1000;
			end
			else if (color == BROWN) begin
				red <= 4'b0100;
				green <= 4'b0010;
				blue <= 4'b0001;
			end
			else begin
				red <= 4'b1111;
				green <= 4'b1111;
				blue <= 4'b1111;	
			end
		end
		
		// Colored Mode
		else begin
			if (color == GREEN) begin
				red <= 4'b0000;
				green <= 4'b1111;
				blue <= 4'b0000;
			end
			else if (color == RED) begin
				red <= 4'b1111;
				green <= 4'b0000;
				blue <= 4'b0000;
			end
			else if (color == YELLOW) begin
				red <= 4'b1111;
				green <= 4'b1111;
				blue <= 4'b0000;
			end
			else if (color == BLUE) begin
				red <= 4'b0000;
				green <= 4'b0000;
				blue <= 4'b1111;
			end
			else begin
				red <= 4'b1111;
				green <= 4'b1010;
				blue <= 4'b0000;	
			end
		end

	end
endmodule