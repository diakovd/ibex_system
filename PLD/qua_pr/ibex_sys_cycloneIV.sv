`include "../source/defines.sv"

`timescale 1 ps / 1 ps

 module ibex_sys_cycloneIV(
 
	output TX,
	input  RX,
//	output [31:0] LED,
    input Clk,
    input   sys_rst_n	 
 );
 parameter string VENDOR    = "IntelFPGA"; //optional "Simulation" 
 parameter int    MEM_SIZE  = 4 * 2048; // 8 kB
 
 logic      Clk_14_7456MHz;
 logic 		Clk_sys;
 wire       Rstn;

 wire [31:0] LED;
 
generate

if(VENDOR == "IntelFPGA") begin

 PLL PLL_inst (
	.areset ( 1'b0),
	.inclk0 ( Clk ),
	.c0 ( Clk_14_7456MHz ),
	.c1 ( Clk_sys )	
	);

end
else if(VENDOR == "Simulation") begin
 
 initial Clk_14_7456MHz = 0;
 always #34000 Clk_14_7456MHz <= ~Clk_14_7456MHz; 
 
 assign Clk_sys = Clk;

end
endgenerate

 ibex_sys #(
	.VENDOR(VENDOR),
	.MEM_SIZE(MEM_SIZE)
 )
 ibex_sys_inst(
    .TX(TX),
    .RX(RX),
	.LED(LED),
	.rst_sys_n(sys_rst_n),
	.Clk_14_7456MHz(Clk_14_7456MHz),
	.clk_sys(Clk_sys)
 );

 endmodule