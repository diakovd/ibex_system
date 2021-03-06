
// `include "tm_agent.sv"
// `include "tm_scoreboard.sv"

class tm_model_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  virtual ahb3lite_bus     vif;
  virtual tm_ex_if     	  exif;

  top_reg_block	regmodel;  
  
  reg2bus_adapter             	   m_reg2bus;                  
  uvm_reg_predictor #(tm_seq_item) m_bus2reg_predictor;        
  tm_agent      m_agent;
  tm_ex_agent   m_ex_agent;

<<<<<<< HEAD
  tm_scoreboard tm_scb;
=======

//  tm_scoreboard tm_scb;
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
//  bus_env		m_bus_env;

  
  `uvm_component_utils(tm_model_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - crate the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_agent = tm_agent::type_id::create("m_agent", this);
    m_ex_agent = tm_ex_agent::type_id::create("m_ex_agent", this);
<<<<<<< HEAD
    tm_scb  = tm_scoreboard::type_id::create("tm_scb", this);
=======
 //   tm_scb  = tm_scoreboard::type_id::create("tm_scb", this);
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
	
	regmodel = top_reg_block::type_id::create("regmodel");
	regmodel.build();
	regmodel.lock_model();
	
    m_reg2bus           = reg2bus_adapter ::type_id::create("m_reg2bus", this);
    m_bus2reg_predictor = uvm_reg_predictor #(tm_seq_item)::type_id::create("m_bus2reg_predictor", this);
	
	uvm_config_db #(top_reg_block)::set(null, "uvm_test_top", "regmodel", regmodel);
	
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
<<<<<<< HEAD
    m_agent.monitor.analysis_port.connect(tm_scb.bus_collected_export);
    m_ex_agent.ex_monitor.ex_analysis_port.connect(tm_scb.ex_bus_collected_export);

=======
    //m_agent.monitor.analysis_port.connect(tm_scb.item_collected_export);
>>>>>>> a5fb7fa1b2e5dbb97f76ff515ded9d7d47ea5945
    m_agent.monitor.analysis_port.connect(m_bus2reg_predictor.bus_in);
    
	m_bus2reg_predictor.map = regmodel.bus_map;
	m_bus2reg_predictor.adapter = m_reg2bus;
	
	regmodel.default_map.set_sequencer(m_agent.sequencer, m_reg2bus);
    //regmodel.default_map.set_auto_predict(0);
	
  endfunction : connect_phase

endclass : tm_model_env