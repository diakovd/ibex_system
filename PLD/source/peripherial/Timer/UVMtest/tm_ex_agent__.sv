
class tm_ex_agent extends uvm_agent;

  uvm_analysis_port #(tm_ex_seq_item) analysis_port;
  //---------------------------------------
  // component instances
  //---------------------------------------
  tm_ex_driver    driver;
  uvm_sequencer#(tm_ex_seq_item) sequencer;
  //bus_monitor   m_monitor;

  `uvm_component_utils(tm_ex_agent)
  
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
    //m_monitor = bus_monitor::type_id::create("m_monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    driver    = tm_ex_driver::type_id::create("driver", this);
    sequencer = uvm_sequencer#(tm_ex_seq_item)::type_id::create("sequencer", this);
  endfunction : build_phase

  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    // if (m_config.vif == null)
    // `uvm_warning(get_type_name(), "bus virtual interface is not set!")
  
    //m_monitor.vif = m_config.vif;
    //m_monitor.analysis_port.connect(analysis_port);
  
    driver.seq_item_port.connect(sequencer.seq_item_export);
    //driver.vif = m_config.vif;
    // end
  endfunction : connect_phase

endclass : tm_ex_agent