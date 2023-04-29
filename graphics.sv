module graphics(
		input vgaclk,           //input pixel clock: how fast should this be?
		input blank
   );	
	
	reg [127:0] data;
	reg [4:0] rdaddress;
	reg [4:0] wraddress;
	reg wren;
	reg [127:0] q;
	
	ram ram_saver(vgaclk, data, rdaddress, wraddress, wren, q);
	
	always @(posedge vgaclk) begin
		if (blank == 0) begin
			data <= 0;
			rdaddress <= 0;
			wraddress <= 0;
			wren <= 0;
		end
		else begin
			if (wraddress < 20) begin
				data <= 0;
		end
	
	// Step 1. Get saving to Ram and falling working
	/*
		 1.1: 


	*/

	// Step 2. Get saving to ROM and reading working

	// Step 3. Get blocks to dissappear when button pressed

	// Step 4. Get missing block to give miss

	// Step 4. Get button dissappearing to trigger scoreboard

	// Step 5. Get guitar to trigger scoreboard

	// Setp 6. Get miss

endmodule
