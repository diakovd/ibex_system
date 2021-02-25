
import uvm_pkg::*;
`include "uvm_macros.svh"

class tm_ex_driver extends uvm_driver #(tm_ex_seq_item); 

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual tm_ex_if exif;
  `uvm_component_utils(tm_ex_driver)
    
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
     if(!uvm_config_db#(virtual tm_ex_if)::get(this, "", "exif", exif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".exif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
	  drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task EvntP(input int evT, input int evOnt, input bit [2:0] evEn);
	exif.Evnt0 = evEn[0];
	exif.Evnt1 = evEn[1];
	exif.Evnt2 = evEn[2];
	#(evOnt);
	exif.Evnt0 = 0;
	exif.Evnt1 = 0;
	exif.Evnt2 = 0;
	#(evT - evOnt);
  endtask : EvntP
  
  virtual task drive();
	int i;
	exif.Evnt0 = 0;
	exif.Evnt1 = 0;
	exif.Evnt2 = 0;
	for(i = 0; i < req.num; i = i + 1) EvntP(req.T,req.tOn,req.enEvnt);
  endtask : drive
  
endclass : tm_ex_driver