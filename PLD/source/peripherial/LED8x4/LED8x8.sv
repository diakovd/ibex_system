
 module LED8x8(
	
	digit1,
	digit2,
	digit3,
	digit4,
	digit5,
	digit6,
	digit7,
	digit8,
	
	LEDen,
	
	LEDA,
	LEDB,
	LEDC,
	LEDD,
	LEDE,
	LEDF,
	LEDG,
	LEDDP,
	
	Clk,
 );
 
 output [7:0] LEDen;
	
 input [7:0] digit1;
 input [7:0] digit2;
 input [7:0] digit3;
 input [7:0] digit4;	
 input [7:0] digit5;
 input [7:0] digit6;
 input [7:0] digit7;
 input [7:0] digit8;	
	
 output logic LEDA  = 1;
 output logic LEDB  = 1;
 output logic LEDC  = 1;
 output logic LEDD  = 1;
 output logic LEDE  = 1;
 output logic LEDF  = 1;
 output logic LEDG  = 1;
 output logic LEDDP = 1;
	
 input Clk;
 
 logic [7:0] digitEn = 1;
 logic [31:0] ctr_ref = 0;
 logic [7:0] digit;
 
 assign LEDen = ~digitEn;
 
 always@(posedge Clk) begin
	if(ctr_ref == 50000) begin
		ctr_ref <= 0;
		digitEn <= {digitEn[6:0],digitEn[7]};
	end
	else ctr_ref <= ctr_ref + 1;
 end 
 
 always_comb begin
 
	if(digitEn[0]) 	    digit = digit1;
	else if(digitEn[1]) digit = digit2;
	else if(digitEn[2]) digit = digit3;
	else if(digitEn[3]) digit = digit4;
	else if(digitEn[4]) digit = digit5;
	else if(digitEn[5]) digit = digit6;
	else if(digitEn[6]) digit = digit7;
	else  			    digit = digit8;
 
	case(digit)
		8'h30: begin
			LEDA <= 0;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 0;
			LEDE <= 0;
			LEDF <= 0;
			LEDG <= 1;	
		end
		8'h31: begin
			LEDA <= 1;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 1;
			LEDE <= 1;
			LEDF <= 1;
			LEDG <= 1;	
		end
		8'h32: begin
			LEDA <= 0;
			LEDB <= 0;
			LEDC <= 1; 
			LEDD <= 0;
			LEDE <= 0;
			LEDF <= 1;
			LEDG <= 0;	
		end
		8'h33: begin
			LEDA <= 0;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 0;
			LEDE <= 1;
			LEDF <= 1;
			LEDG <= 0;	
		end
		8'h34: begin
			LEDA <= 1;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 1;
			LEDE <= 1;
			LEDF <= 0;
			LEDG <= 0;	
		end
		8'h35: begin
			LEDA <= 0;
			LEDB <= 1;
			LEDC <= 0; 
			LEDD <= 0;
			LEDE <= 1;
			LEDF <= 0;
			LEDG <= 0;	
		end
		8'h36: begin
			LEDA <= 0;
			LEDB <= 1;
			LEDC <= 0; 
			LEDD <= 0;
			LEDE <= 0;
			LEDF <= 0;
			LEDG <= 0;	
		end
		8'h37: begin
			LEDA <= 0;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 1;
			LEDE <= 1;
			LEDF <= 1;
			LEDG <= 1;	
		end
		8'h38: begin
			LEDA <= 0;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 0;
			LEDE <= 0;
			LEDF <= 0;
			LEDG <= 0;	
		end
		8'h39: begin
			LEDA <= 0;
			LEDB <= 0;
			LEDC <= 0; 
			LEDD <= 0;
			LEDE <= 1;
			LEDF <= 0;
			LEDG <= 0;	
		end
		default: begin
			LEDA <= 1;
			LEDB <= 1;
			LEDC <= 1; 
			LEDD <= 1;
			LEDE <= 1;
			LEDF <= 1;
			LEDG <= 1;	
		end
	endcase
 end
 endmodule 