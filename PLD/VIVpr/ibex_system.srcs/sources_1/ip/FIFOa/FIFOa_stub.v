// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3_AR72010 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sun Mar 27 13:00:12 2022
// Host        : DT running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/pr/ibex-sys/PLD/VIVpr/ibex_system.srcs/sources_1/ip/FIFOa/FIFOa_stub.v
// Design      : FIFOa
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3_AR72010" *)
module FIFOa(wr_clk, wr_rst, rd_clk, rd_rst, din, wr_en, rd_en, 
  dout, full, empty, rd_data_count, wr_data_count)
/* synthesis syn_black_box black_box_pad_pin="wr_clk,wr_rst,rd_clk,rd_rst,din[7:0],wr_en,rd_en,dout[7:0],full,empty,rd_data_count[7:0],wr_data_count[7:0]" */;
  input wr_clk;
  input wr_rst;
  input rd_clk;
  input rd_rst;
  input [7:0]din;
  input wr_en;
  input rd_en;
  output [7:0]dout;
  output full;
  output empty;
  output [7:0]rd_data_count;
  output [7:0]wr_data_count;
endmodule
