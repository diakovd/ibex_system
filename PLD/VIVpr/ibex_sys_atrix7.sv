`include "../source/defines.sv"

`timescale 1 ps / 1 ps

 module ibex_sys_atrix7(

	output TX,
	input  RX,
	
//	output [31:0] LED,

    input   Clk_14_7456MHz,
    input   sys_rst_n	 
 );
 parameter VENDOR = "Xilinx"; //optional "Simulation"
 parameter int    MEM_SIZE  = 4 * 1024; // 4 kB
 
 logic      Clk;
 wire       Rstn;

 wire [31:0] LED;
  
generate

if(VENDOR == "Xilinx") begin

 PLL PLL_inst
 (
  // Clock out ports
  .clk_out1(Clk),
  .reset(1'b0),
  .clk_in1(Clk_14_7456MHz)
  );
end
else if(VENDOR == "Simulation") begin
 
 initial Clk = 0;
 always #5000 Clk <= ~Clk; 

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
	.clk_sys(Clk)
 );

 endmodule