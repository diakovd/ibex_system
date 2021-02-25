
class tm_agent extends uvm_agent;

  // uvm_analysis_port #(tm_seq_item) analysis_port;
  //---------------------------------------
  // component instances
  //---------------------------------------
  tm_driver    driver;
  tm_sequencer sequencer;
  tm_monitor  monitor;
  
  local int m_is_active = -1;
  
  `uvm_component_utils(tm_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = tm_monitor::type_id::create("monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    driver    = tm_driver::type_id::create("driver", this);
    sequencer = tm_sequencer::type_id::create("sequencer", this);
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);

    driver.seq_item_port.connect(sequencer.seq_item_export);
	
  endfunction : connect_phase


endclass : tm_agent