
class tm_ex_agent extends uvm_agent;

<<<<<<< HEAD
  uvm_analysis_port #(tm_ex_seq_item) ex_analysis_port;
  //---------------------------------------
  // component instances
  //---------------------------------------
  tm_ex_driver		driver;
  uvm_sequencer#(tm_ex_seq_item) sequencer;
  tm_ex_monitor 	ex_monitor;
  
=======
  uvm_analysis_port #(tm_ex_seq_item) analysis_port;
  //---------------------------------------
  // component instances
  //---------------------------------------
  tm_ex_driver    driver;
  uvm_sequencer#(tm_ex_seq_item) sequencer;
  //bus_monitor   m_monitor;

>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
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
<<<<<<< HEAD
    ex_monitor = tm_ex_monitor::type_id::create("ex_monitor", this);
=======
    //m_monitor = bus_monitor::type_id::create("m_monitor", this);
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945

    //creating driver and sequencer only for ACTIVE agent
    driver    = tm_ex_driver::type_id::create("driver", this);
    sequencer = uvm_sequencer#(tm_ex_seq_item)::type_id::create("sequencer", this);
  endfunction : build_phase

  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
<<<<<<< HEAD

    //ex_monitor.ex_analysis_port.connect(ex_analysis_port);
    driver.seq_item_port.connect(sequencer.seq_item_export);

=======
    // if (m_config.vif == null)
    // `uvm_warning(get_type_name(), "bus virtual interface is not set!")
  
    //m_monitor.vif = m_config.vif;
    //m_monitor.analysis_port.connect(analysis_port);
  
    driver.seq_item_port.connect(sequencer.seq_item_export);
    //driver.vif = m_config.vif;
    // end
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
  endfunction : connect_phase

endclass : tm_ex_agent