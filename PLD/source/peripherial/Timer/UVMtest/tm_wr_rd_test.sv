

class tm_wr_rd_test extends tm_model_base_test;

  `uvm_component_utils(tm_wr_rd_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  reset_seq			 seq_rst;
  //wr_rd_regmodel_seq seq;
  cnt_to_compReg_init_seq  seq_ctcINIT;
  cnt_to_compReg_RD_seq    seq_ctcRD;
  evnt_seq			 seq_ev;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "tm_wr_rd_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    seq_rst = reset_seq::type_id::create("seq_rst");
    // seq = wr_rd_regmodel_seq::type_id::create("seq");
    seq_ctcINIT = cnt_to_compReg_init_seq::type_id::create("seq_ctcINIT");
    seq_ctcRD   = cnt_to_compReg_RD_seq::type_id::create("seq_ctcRD");
	seq_ev = evnt_seq::type_id::create("evnt_seq");
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);

    phase.raise_objection(this);
	seq_rst.start(env.m_agent.sequencer);

	seq_ctcINIT.start(env.m_agent.sequencer);
	seq_ev.start(env.m_ex_agent.sequencer);
	seq_ctcRD.start(env.m_agent.sequencer);
	
    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase
  
endclass : tm_wr_rd_test