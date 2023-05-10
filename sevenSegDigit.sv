module sevenSegDigit(input [3:0] decimalNum, output reg [7:0] dispBits);
	//Note that it is legal to do input/output and bitwidth declarations within the port list like above!

	always_comb begin 
		//Remember we can only use reg logic in always blocks. 
		//always_comb is similar to always@(*) but it is a compiler directive that will cause a compilation error if the logic inside is not actually combinational. 
		//As such, when we want to use combinational logic, it is better practice to use always_comb to catch errors!
		/*
		----------PART TWO----------
		Your logic to convert decimal number to the bits corresponding to a seven-seg goes here.
		4 bit input -> values from 0 to 15. We can only display 0 to 9 but you should still deal with cases where 10-15 are passed in. In this case, set it so the display is just blank.
		We reccomend a case statement. Make sure all of the cases have outputs assigned.
		----------PART TWO----------
		*/
		
		case (decimalNum)
			0: begin
				dispBits = 8'b11000000;
			end
			1: begin
				dispBits = 8'b11111001;
			end
			2: begin
				dispBits = 8'b10100100;
			end
			3: begin
				dispBits = 8'b10110000;
			end
			4: begin
				dispBits = 8'b10011001;
			end
			5: begin
				dispBits = 8'b10010010;
			end
			6: begin
				dispBits = 8'b10000010;
			end
			7: begin
				dispBits = 8'b11111000;
			end
			8: begin
				dispBits = 8'b10000000;
			end
			9: begin
				dispBits = 8'b10010000;
			end
			default:
				dispBits = 8'b11111111;

		endcase
		
		
	end

endmodule