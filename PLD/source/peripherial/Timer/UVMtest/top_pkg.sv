// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: top_pkg.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-04-18-EP on Wed Feb 10 06:12:12 2021
//=============================================================================
// Description: Package for top
//=============================================================================

package top_pkg;

  `include "uvm_macros.svh"

  import uvm_pkg::*;
  import regmodel_pkg::*;
  import ahb3lite_pkg::*;

  `include "tm_seq_item.sv"
  `include "tm_ex_seq_item.sv"
  `include "tm_driver.sv"
  `include "tm_ex_driver.sv"
  `include "tm_monitor.sv"
<<<<<<< HEAD
  `include "tm_ex_monitor.sv"
  `include "tm_sequencer.sv"
//  `include "bus_coverage.sv"
  `include "tm_ex_agent.sv"
  `include "tm_agent.sv"
  //`include "bus_seq_lib.sv"
  `include "reg2bus_adapter.sv"
//  `include "bus_env_coverage.sv"
  `include "tm_scoreboard.sv"
=======
  `include "tm_sequencer.sv"
//  `include "bus_coverage.sv"
  `include "tm_agent.sv"
  `include "tm_ex_agent.sv"
  //`include "bus_seq_lib.sv"
  `include "reg2bus_adapter.sv"
//  `include "bus_env_coverage.sv"
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
  `include "tm_env.sv"
  `include "wr_rd_regmodel_seq.sv"
  `include "tm_ex_sequence.sv"
  `include "tm_base_test.sv"
  `include "tm_wr_rd_test.sv"


//  `include "top_config.sv"
//  `include "top_seq_lib.sv"
//  `include "top_env.sv"

endpackage : top_pkg

