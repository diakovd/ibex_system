// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3_AR72010 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sun Mar 27 13:00:30 2022
// Host        : DT running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/pr/ibex-sys/PLD/VIVpr/ibex_system.srcs/sources_1/ip/RAMdp/RAMdp_stub.v
// Design      : RAMdp
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3_AR72010" *)
module RAMdp(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[3:0],addra[12:0],dina[31:0],douta[31:0],clkb,web[3:0],addrb[12:0],dinb[31:0],doutb[31:0]" */;
  input clka;
  input [3:0]wea;
  input [12:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  input clkb;
  input [3:0]web;
  input [12:0]addrb;
  input [31:0]dinb;
  output [31:0]doutb;
endmodule
