//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//---------------------------------------------------------------
//including interfcae and testcase files

`include "uvm_macros.svh"
import uvm_pkg::*;

import ahb3lite_pkg::*;

//import top_test_pkg::*;
import top_pkg::*; 
 
 `include "tm_interface.sv"
// `include "tm_base_test.sv"
// `include "tm_wr_rd_test.sv"
//---------------------------------------------------------------
`define SIM

module tbench_top;


  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
  bit reset;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    reset = 1;
    #50 reset =0;
  end
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  ahb3lite_bus bus_if(clk,!reset);
  initial begin
	bus_if.HSEL = 1'b1;
	bus_if.HADDR  = 0;
	bus_if.HWDATA = 0;
	bus_if.HWRITE = 1'b0;
	bus_if.HSIZE = HSIZE_B32;
	bus_if.HBURST = HBURST_SINGLE;
	bus_if.HPROT = HPROT_OPCODE;
	bus_if.HTRANS = HTRANS_IDLE;
	bus_if.HMASTLOCK =  1'b0;
  end
  
  tm_ex_if ex_if();
  initial begin
	ex_if.Evnt0 = 0;
	ex_if.Evnt1 = 0;
	ex_if.Evnt2 = 0;
  end
   
  Timer 
 #(
   .TM_SIZE(32), //conter bit wigh, max = 32 bit   
   .PWM_SIZE(1), //number of PWM output   
   .HADDR_SIZE(8),
   .HDATA_SIZE(32) 	
 ) DUT
 (
	.CPUbus(bus_if.slave),

	.Evnt0(ex_if.Evnt0),
	.Evnt1(ex_if.Evnt1),
	.Evnt2(ex_if.Evnt2),
	.PWM(ex_if.PWM),
	.Int(ex_if.Int)
 );
 
 assign bus_if.HREADY = bus_if.HREADYOUT;
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  // Configuration object for top-level environment
  //top_config top_env_config;

  initial
  begin
    // You can insert code here by setting tb_prepend_to_initial in file common.tpl

    // Create and populate top-level configuration object
    // top_env_config = new("top_env_config");
    // if ( !top_env_config.randomize() )
      // `uvm_error("top_tb", "Failed to randomize top-level configuration object" )

    // top_env_config.vif                 = bus_if;
    // top_env_config.is_active_bus       = UVM_ACTIVE; 
    // top_env_config.checks_enable_bus   = 1;          
    // top_env_config.coverage_enable_bus = 1;          


    // uvm_config_db #(top_config)::set(null, "uvm_test_top", "config", top_env_config);
    // uvm_config_db #(top_config)::set(null, "uvm_test_top.m_env", "config", top_env_config);
    uvm_config_db #(virtual ahb3lite_bus)::set(uvm_root::get(),"*","vif",bus_if);
    uvm_config_db #(virtual tm_ex_if)::set(uvm_root::get(),"*","exif",ex_if);
    // You can insert code here by setting tb_inc_before_run_test in file common.tpl

	//print_config( bit recurse = 0, bit audit = 0 );

    run_test();
  end
  
  // initial begin 
    // uvm_config_db#(virtual ahb3lite_bus)::set(uvm_root::get(),"*","vif",bus_if);
    // //enable wave dump
    // $dumpfile("dump.vcd"); 
    // $dumpvars;
  // end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  // initial begin 
    // run_test();
  // end
  
endmodule