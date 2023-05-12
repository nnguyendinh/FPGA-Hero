module hardcoded_vga(
		input vgaclk,           //input pixel clock: how fast should this be?
		input rst,              //synchronous reset
		input [9:0] switches,
		output hsync,			//horizontal sync out
		output vsync,			//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue,	//blue vga output
		output [19:0] score_		//output to tell when blanking for RAM purposes
   );
	
	/*
			Col1 Col2 Col3 Col4
	
	Beat1		x					x
		↓
		↓
	Beat2					x
		↓
		↓
	Beat3			x			
		↓
		↓	
	Beat4	x		x		
		↓
		↓
	wrap up to top
	*/
	
	// ROM regs to read notes file
	reg [7:0] ROM_address = 0;
	reg [3:0] note_line;
	notes_ROM note_reader(ROM_address, vgaclk, note_line);
		
	// Regs to hold the position of beat 1 - 4
	reg [9:0] beat_pos1 = 0;
	reg [9:0] beat_pos2 = 160;
	reg [9:0] beat_pos3 = 320;
	reg [9:0] beat_pos4 = 480;
	
	// Regs to hold whether there is a note at that beat or not
	reg [3:0] beat_notes1 = 4'b1111;
	reg [3:0] beat_notes2 = 4'b1111;
	reg [3:0] beat_notes3 = 4'b1111;
	reg [3:0] beat_notes4 = 4'b1111;
	
	// Track Button Deletions
	reg [3:0] button_deletions = 4'b0000;
	
	// Pixel speed and note length constants
	localparam PIXELSPEED = 5;
	localparam NOTELENGTH = 150;
	
	//	Video protocol constants
	localparam HPIXELS = 640;  // horizontal pixels per line
	localparam HPULSE = 96; 	// hsync pulse length
	localparam HBP = 48; 	    // end of horizontal back porch
	localparam HFP = 16; 	    // beginning of horizontal front porch
	
	localparam VLINES = 480;   // scanlines per frame (aka the # of vertical pixels)
	localparam VPULSE = 2; 	// vsync pulse length
	localparam VBP = 33; 		// end of vertical back porch
	localparam VFP = 10; 	    // beginning of vertical front porch
	
	// registers for storing the horizontal & vertical counters
	reg [9:0] hc;
	reg [9:0] vc;
	
	// Score for seven seg display
	reg [19:0] score = 0;
	assign score_ = score;
	
	// Color picker definitions
	reg color_mode;
	reg [2:0] color;
	
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
	
	color_picker picker_of_colors(color_mode,	color, red,	green, blue);

    //Counter block: change hc and vc correspondingly to the current state.
	always @(posedge vgaclk) begin
		 //reset condition
		if (rst == 1) begin
			hc <= 0;
			vc <= 0;
		end
		else begin
			//DONE: Implement logic to move counters properly!
			if (hc >= HPIXELS + HPULSE + HBP + HFP - 1) begin
				hc <= 0;
				if (vc >= VLINES + VPULSE + VBP + VFP - 1) begin
					vc <= 0;
				end
				else begin
					vc <= vc + 1'b1;
				end
			end
			else begin
				hc <= hc + 1'b1;
			end
			
		end
	end

	assign hsync = (hc >= HPIXELS + HFP && hc < HPIXELS + HFP + HPULSE) ? 0 : 1;	
	assign vsync = (vc >= VLINES + VFP && vc < VLINES + VFP + VPULSE) ? 0 : 1;	
	
	// Update beat notes and positions during vsync
	always @(posedge vsync, posedge rst) begin
	
		if (rst == 1) begin
			beat_pos1 <= 0;
			beat_pos2 <= 160;
			beat_pos3 <= 320;
			beat_pos4 <= 480;
			
			beat_notes1 <= 4'b1111;
			beat_notes2 <= 4'b1111;
			beat_notes3 <= 4'b1111;
			beat_notes4 <= 4'b1111;
			
			ROM_address <= 0;
			
			score <= 0;
		end
		
		else begin
			// Increment the score once every frame
			score <= score + 1;
		
			// Once a beat goes off the right boundary, 
			// reset it and read new line from ROM
			if (beat_pos1 >= 639 + NOTELENGTH) begin
				beat_pos1 <= 0;
				beat_notes1 <= note_line;
				ROM_address <= ROM_address + 1'b1;
				button_deletions[0] <= 0;
			end
			
			// If still within boundary, update beat position
			else begin
				beat_pos1 <= beat_pos1 + PIXELSPEED;
			end
			
			if (beat_pos2 >= 639 + NOTELENGTH) begin
				beat_pos2 <= 0;
				beat_notes2 <= note_line;
				ROM_address <= ROM_address + 1'b1;
				button_deletions[1] <= 0;
			end
			else begin
				beat_pos2 <= beat_pos2 + PIXELSPEED;
			end
			
			if (beat_pos3 >= 639 + NOTELENGTH) begin
				beat_pos3 <= 0;
				beat_notes3 <= note_line;
				ROM_address <= ROM_address + 1'b1;
				button_deletions[2] <= 0;
			end
			else begin
				beat_pos3 <= beat_pos3 + PIXELSPEED;
			end
			
			if (beat_pos4 >= 639 + NOTELENGTH) begin
				beat_pos4 <= 0;
				beat_notes4 <= note_line;
				ROM_address <= ROM_address + 1'b1;
				button_deletions[3] <= 0;
			end
			else begin
				beat_pos4 <= beat_pos4 + PIXELSPEED;
			end
			
			if (beat_pos1 >= 480 && beat_pos1 < 480 + NOTELENGTH && switches[0]) begin
				button_deletions[0] <= 1;
			end
			if (beat_pos2 >= 480 && beat_pos2 < 480 + NOTELENGTH && switches[1]) begin
				button_deletions[1] <= 1;
			end
			if (beat_pos3 >= 480 && beat_pos3 < 480 + NOTELENGTH && switches[2]) begin
				button_deletions[2] <= 1;
			end
			if (beat_pos4 >= 480 && beat_pos4 < 480 + NOTELENGTH && switches[3]) begin
				button_deletions[3] <= 1;
			end
		end
	end

    //RGB output block: set red, green, blue outputs here.
	always_comb begin
		// check if we're within vertical active video range
		if (hc <= HPIXELS && vc <= VLINES) begin
		
			// If on the note active line, display white
			if (hc >= 480 && hc < 485) begin
				color_mode <= BW;
				color <= WHITE;
			end

			// If on beats 1-4, display appropriate color based on which column note is in
			else if (hc < beat_pos1 && hc > (beat_pos1 < NOTELENGTH ? 0 : beat_pos1 - NOTELENGTH)
					&& beat_notes1[vc / 120]) begin
				if (button_deletions[0] == 1) begin
					color_mode <= BW;
					color <= WHITE;
				end
				else begin
					color_mode <= COLORED;
					color <= vc / 120;
				end
			end
			else if (hc < beat_pos2 && hc > (beat_pos2 < NOTELENGTH ? 0 : beat_pos2 - NOTELENGTH)
						&& beat_notes2[vc / 120]) begin
				if (button_deletions[1] == 1) begin
					color_mode <= BW;
					color <= WHITE;
				end
				else begin
					color_mode <= COLORED;
					color <= vc / 120;
				end
			end
			else if (hc < beat_pos3 && hc > (beat_pos3 < NOTELENGTH ? 0 : beat_pos3 - NOTELENGTH)
						&& beat_notes3[vc / 120]) begin
				if (button_deletions[2] == 1) begin
					color_mode <= BW;
					color <= WHITE;
				end
				else begin
					color_mode <= COLORED;
					color <= vc / 120;
				end
			end
			else if (hc < beat_pos4 && hc > (beat_pos4 < NOTELENGTH ? 0 : beat_pos4 - NOTELENGTH)
						&& beat_notes4[vc / 120]) begin
				if (button_deletions[3] == 1) begin
					color_mode <= BW;
					color <= WHITE;
				end
				else begin
					color_mode <= COLORED;
					color <= vc / 120;
				end
			end
			
			// If directly on a beat line, display gray
			else if (hc == beat_pos1 || hc == beat_pos2 || hc == beat_pos3 || hc == beat_pos4) begin
				color_mode <= BW;
				color <= GRAY;
			end
			
			// Display brown as the background
			else begin
				color_mode <= BW;
				color <= BROWN;
			end
		
		end
		// If not in active vga video range, display black
		else begin
			color_mode <= BW;
			color <= BLACK;
		end
	end

endmodule
