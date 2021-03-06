//-------------------------------------------------------------------------
//						mem_monitor - www.verificationguide.com 
//-------------------------------------------------------------------------

class tm_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual ahb3lite_bus vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(tm_seq_item) analysis_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  tm_seq_item trans_collected;

  `uvm_component_utils(tm_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    analysis_port = new("analysis_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb3lite_bus)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MONITOR.HCLK);
	  if(vif.monitor_cb.HTRANS == HTRANS_NONSEQ) begin
		  trans_collected.addr = vif.monitor_cb.HADDR;
		  if(vif.monitor_cb.HWRITE) begin
<<<<<<< HEAD
			trans_collected.cmd  = vif.monitor_cb.HWRITE;
=======
			trans_collected.cmd = vif.monitor_cb.HWRITE;
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
			trans_collected.data = vif.monitor_cb.HWDATA;
		  end
		  if(!vif.monitor_cb.HWRITE) begin
			trans_collected.cmd = 0;
			@(posedge vif.MONITOR.HCLK);
			trans_collected.data = vif.monitor_cb.HRDATA;
		  end
		  analysis_port.write(trans_collected);
      end 
	end
  endtask : run_phase

endclass : tm_monitor
