//-------------------------------------------------------------------------
//						mem_driver - www.verificationguide.com
//-------------------------------------------------------------------------
import uvm_pkg::*;
`include "uvm_macros.svh"

`define DRIV_IF vif.driver_cb

class tm_driver extends uvm_driver #(tm_seq_item); 

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual ahb3lite_bus vif;
  `uvm_component_utils(tm_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual ahb3lite_bus)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      //drive();
	  drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    if(req.cmd) begin // write operation
	  @(posedge vif.DRIVER.HCLK);
		vif.driver_cb.HSEL <= 1'b1;
		vif.driver_cb.HADDR  <= req.addr;
		vif.driver_cb.HWDATA <= 0;
		vif.driver_cb.HWRITE <= 1'b1;
		vif.driver_cb.HSIZE <= HSIZE_B32;
		vif.driver_cb.HBURST <= HBURST_SINGLE;
		vif.driver_cb.HPROT <= HPROT_OPCODE;
		vif.driver_cb.HTRANS <= HTRANS_NONSEQ;
		vif.driver_cb.HMASTLOCK <=  1'b0;
	  @(posedge vif.DRIVER.HCLK);
		vif.driver_cb.HSEL <= 1'b1;
		vif.driver_cb.HADDR  <= 0;
		vif.driver_cb.HWDATA <= req.data;
		vif.driver_cb.HWRITE <= 1'b0;
		vif.driver_cb.HSIZE <= HSIZE_B32;
		vif.driver_cb.HBURST <= HBURST_SINGLE;
		vif.driver_cb.HPROT <= HPROT_OPCODE;
		vif.driver_cb.HTRANS <= HTRANS_IDLE;
		vif.driver_cb.HMASTLOCK <=  1'b0;
	  while(!(vif.driver_cb.HREADY)) @(posedge vif.HCLK);
    end
    else if(!req.cmd) begin //read operation
	  @(posedge vif.HCLK);
		vif.DRIVER.driver_cb.HSEL   <= 1'b1;
		vif.DRIVER.driver_cb.HADDR  <= req.addr;
		vif.DRIVER.driver_cb.HWDATA <= 0;
		vif.DRIVER.driver_cb.HWRITE <= 1'b0;
		vif.DRIVER.driver_cb.HSIZE  <= HSIZE_B32;
		vif.DRIVER.driver_cb.HBURST <= HBURST_SINGLE;
		vif.DRIVER.driver_cb.HPROT  <= HPROT_OPCODE;
		vif.DRIVER.driver_cb.HTRANS <= HTRANS_NONSEQ;
		vif.DRIVER.driver_cb.HMASTLOCK <=  1'b0;
	  @(posedge vif.DRIVER.HCLK);
		vif.DRIVER.driver_cb.HSEL   <= 1'b1;
		vif.DRIVER.driver_cb.HADDR  <= 0;
		vif.DRIVER.driver_cb.HWDATA <= req.data;
		vif.DRIVER.driver_cb.HWRITE <= 1'b0;
		vif.DRIVER.driver_cb.HSIZE  <= HSIZE_B32;
		vif.DRIVER.driver_cb.HBURST <= HBURST_SINGLE;
		vif.DRIVER.driver_cb.HPROT  <= HPROT_OPCODE;
		vif.DRIVER.driver_cb.HTRANS <= HTRANS_IDLE;
		vif.DRIVER.driver_cb.HMASTLOCK <=  1'b0;
	  @(posedge vif.DRIVER.HCLK);
		while(!(vif.DRIVER.driver_cb.HREADY)) @(posedge vif.DRIVER.HCLK);
		req.data = vif.HRDATA;
     end
    
  endtask : drive
  
endclass : tm_driver