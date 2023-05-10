module hardcoded_vga(
		input vgaclk,           //input pixel clock: how fast should this be?
		input rst,              //synchronous reset
		output hsync,			//horizontal sync out
		output vsync,			//vertical sync out
		output reg [3:0] red,	//red vga output
		output reg [3:0] green, //green vga output
		output reg [3:0] blue,	//blue vga output
		output reg [19:0] score			//output to tell when blanking for RAM purposes
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
	
	localparam PIXELSPEED = 5;
	localparam NOTELENGTH = 150;
	
	//	Video protocol constants
    // You can find these described in the VGA specification for 640x480
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
	
	//score = 0;
	
	reg color_mode;
	reg color;
	
	parameter BW = 0;
	parameter COLORED = 1;

	parameter BLACK = 0;
	parameter WHITE = 1;
	parameter GRAY = 2;
	
	parameter GREEN = 0;
	parameter RED = 1;
	parameter YELLOW = 2;
	parameter BLUE = 3;
	parameter ORANGE = 4;
	
	
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
	always @(posedge vsync) begin
	
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
			score <= score + 1;
		
			if (beat_pos1 >= 639 + NOTELENGTH) begin
				beat_pos1 <= 0;
				beat_notes1 <= note_line;
				ROM_address <= ROM_address + 1'b1;
			end
			else begin
				beat_pos1 <= beat_pos1 + PIXELSPEED;
			end
			
			if (beat_pos2 >= 639 + NOTELENGTH) begin
				beat_pos2 <= 0;
				beat_notes2 <= note_line;
				ROM_address <= ROM_address + 1'b1;
			end
			else begin
				beat_pos2 <= beat_pos2 + PIXELSPEED;
			end
			
			if (beat_pos3 >= 639 + NOTELENGTH) begin
				beat_pos3 <= 0;
				beat_notes3 <= note_line;
				ROM_address <= ROM_address + 1'b1;
			end
			else begin
				beat_pos3 <= beat_pos3 + PIXELSPEED;
			end
			
			if (beat_pos4 >= 639 + NOTELENGTH) begin
				beat_pos4 <= 0;
				beat_notes4 <= note_line;
				ROM_address <= ROM_address + 1'b1;
			end
			else begin
				beat_pos4 <= beat_pos4 + PIXELSPEED;
			end
		end
	end

    //RGB output block: set red, green, blue outputs here.
	always_comb begin
		// check if we're within vertical active video range
		if (hc <= HPIXELS && vc <= VLINES) begin

			if (hc < beat_pos1 && hc > (beat_pos1 < NOTELENGTH ? 0 : beat_pos1 - NOTELENGTH)
					&& beat_notes1[vc / 120]) begin
				//red <= 4'b1111;
				//green <= 4'b1111;
				//blue <= 4'b0000;
				color_mode <= COLORED;
				color <= vc / 120;
			end
			
			else if (hc < beat_pos2 && hc > (beat_pos2 < NOTELENGTH ? 0 : beat_pos2 - NOTELENGTH)
						&& beat_notes2[vc / 120]) begin
				//red <= 4'b0000;
				//green <= 4'b1111;
				//blue <= 4'b0000;
				color_mode <= COLORED;
				color <= vc / 120;
			end
			
			else if (hc < beat_pos3 && hc > (beat_pos3 < NOTELENGTH ? 0 : beat_pos3 - NOTELENGTH)
						&& beat_notes3[vc / 120]) begin
				//red <= 4'b0000;
				//green <= 4'b0000;
				//blue <= 4'b1111;
				color_mode <= COLORED;
				color <= vc / 120;
			end
			
			else if (hc < beat_pos4 && hc > (beat_pos4 < NOTELENGTH ? 0 : beat_pos4 - NOTELENGTH)
						&& beat_notes4[vc / 120]) begin
				//red <= 4'b1111;
				//green <= 4'b0000;
				//blue <= 4'b0000;
				color_mode <= COLORED;
				color <= vc / 120;
			end
			
			else if (hc == beat_pos1 || hc == beat_pos2 || hc == beat_pos3 || hc == beat_pos4) begin
				//red <= 4'b1000;
				//green <= 4'b1000;
				//blue <= 4'b1000;
				color_mode <= BW;
				color <= GRAY;
			end
			
			else begin
				//red <= 4'b1111;
				//green <= 4'b1111;
				//blue <= 4'b1111;
				color_mode <= BW;
				color <= WHITE;
			end
		
		end
		else begin
			//red <= 4'b0000;
			//green <= 4'b0000;
			//blue <= 4'b0000;
			color_mode <= BW;
			color <= BLACK;
		end
	end

endmodule
