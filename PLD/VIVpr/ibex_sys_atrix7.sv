`include "../source/defines.sv"

`timescale 1 ps / 1 ps

 module ibex_sys_atrix7(

	output TX,
	input  RX,
	
	input  Clk125M,
	input  Rst_n 
 );
 parameter VENDOR = "Xilinx"; //optional "Simulation"
 parameter int    MEM_SIZE  = 32 * 1024; // 4 kB
 
 logic      Clk;
 logic 		Clk_14_7456MHz; 
 wire       Rstn;

 wire [31:0] LED;
  
generate

if(VENDOR == "Xilinx") begin

 PLL PLL_inst
 (
  // Clock out ports
  .clk_out1(Clk),
  .clk_out2(Clk_14_7456MHz),
  .reset(1'b0),
  .clk_in1(Clk125M)
  );
end
else if(VENDOR == "Simulation") begin
 
 initial Clk = 0;
 always #4000 Clk <= ~Clk; 

 initial Clk_14_7456MHz = 0;
 always #34000 Clk_14_7456MHz <= ~Clk_14_7456MHz;

end
endgenerate
 
 ibex_sys #(
	.VENDOR(VENDOR),
	.MEM_SIZE(MEM_SIZE)
 ) 
 ibex_sys_inst(
    .TX(TX),
    .RX(RX),
	//.LED(LED),
	.rst_sys_n(Rst_n),
	.Clk_14_7456MHz(Clk_14_7456MHz),
	.clk_sys(Clk)
 );

 endmodule