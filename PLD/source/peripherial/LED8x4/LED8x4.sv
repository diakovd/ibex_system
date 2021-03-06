
 module LED8x4(
	
	digit1,
	digit2,
	digit3,
	digit4,
	
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
 
 output [3:0] LEDen;
	
 input [7:0] digit1;
 input [7:0] digit2;
 input [7:0] digit3;
 input [7:0] digit4;	
	
 output logic LEDA;
 output logic	LEDB;
 output logic	LEDC;
 output logic	LEDD;
 output logic	LEDE;
 output logic	LEDF;
 output logic	LEDG;
 output logic	LEDDP;
	
 input Clk;
 
 logic [3:0] LEDen = 1;
 logic [31:0] ctr_ref = 0;
 logic [7:0] digit;
 
 always@(posedge Clk) begin
	if(ctr_ref == 5000) begin
		ctr_ref <= 0;
		LEDen <= {LEDen[2:0],LEDen[3]};
	end
	else ctr_ref <= ctr_ref + 1;
 end 
 
 always_comb begin
 
	if(LEDen[0]) 	  digit = digit1;
	else if(LEDen[1]) digit = digit2;
	else if(LEDen[2]) digit = digit3;
	else  			  digit = digit4;
 
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