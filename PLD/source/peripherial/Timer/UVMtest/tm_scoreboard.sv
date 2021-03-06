//-------------------------------------------------------------------------
//						mem_scoreboard - www.verificationguide.com 
//-------------------------------------------------------------------------

`uvm_analysis_imp_decl(_bus)
`uvm_analysis_imp_decl(_ex_bus)

class tm_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
  tm_seq_item 		pkt_bus[$];
  tm_ex_seq_item 	pkt_ex_bus[$];
  
  //---------------------------------------
  // regmodel 
  //---------------------------------------
  top_reg_block     regmodel;
  uvm_reg       	regs;
  uvm_status_e  	status;
  rand uvm_reg_data_t data;
  
  int num = 0;
  int T  = 0;
  int tOn  = 0;
  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  uvm_analysis_imp_bus#(tm_seq_item,    tm_scoreboard)    bus_collected_export;
  uvm_analysis_imp_ex_bus#(tm_ex_seq_item, tm_scoreboard) ex_bus_collected_export;
  `uvm_component_utils(tm_scoreboard)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local memory
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      bus_collected_export    = new("bus_collected_export", this);
      ex_bus_collected_export = new("ex_bus_collected_export", this);
      //foreach(sc_tm[i]) sc_tm[i] = 8'hFF;
  endfunction: build_phase
  
  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write_bus(tm_seq_item pkt);
    //pkt.print();
    pkt_bus.push_back(pkt);
  endfunction : write_bus

  virtual function void write_ex_bus(tm_ex_seq_item pkt);
    //pkt.print();
    pkt_ex_bus.push_back(pkt);
  endfunction : write_ex_bus

  //---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local memory)
  // local memory will be updated on the write operation.
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
  
	fork
		rx_pkt_bus();
		rx_pkt_ex_bus();
	join

  endtask : run_phase
  
  virtual task rx_pkt_bus();
	tm_seq_item tm_pkt;
	if(!uvm_config_db#(top_reg_block)::get(null, "uvm_test_top", "regmodel", regmodel))
	   `uvm_fatal("NO_VIF",{"regmodel must be set for: ",get_full_name(),".regmodel"});
	//	regmodel.get_registers(regs);
	
	forever begin
      wait(pkt_bus.size() > 0);
	  tm_pkt = pkt_bus.pop_front();
	  if(tm_pkt.cmd) begin //wrire bus
		`uvm_info(get_type_name(),$sformatf("------ :: WRITE DATA       :: ------"),UVM_LOW)
	  end
	  else begin //read bus
		regs = regmodel.default_map.get_reg_by_offset(tm_pkt.addr);
		if(tm_pkt.addr == 'h34) begin
			if(tm_pkt.data == num) begin
			  `uvm_info(get_type_name(),$sformatf("------ :: TmCap0 Match number of Event :: ------"),UVM_LOW)
			  `uvm_info(get_type_name(),$sformatf("Expected : %0h Actual : %0h",num,tm_pkt.data),UVM_LOW)
			  `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
			end
			else begin
			  `uvm_error(get_type_name(),"------ :: TmCap0 MisMatch number of Event:: ------")
			  `uvm_info(get_type_name(),$sformatf("Addr: %0h",tm_pkt.addr),UVM_LOW)
			  `uvm_info(get_type_name(),$sformatf("Expected : %0h Actual : %0h",num,tm_pkt.data),UVM_LOW)
			  `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
			end
		end
		else begin
			if(regs.get() == tm_pkt.data) begin
			  `uvm_info(get_type_name(),$sformatf("------ :: READ DATA Match :: ------"),UVM_LOW)
			  `uvm_info(get_type_name(),$sformatf("Addr: %0h",tm_pkt.addr),UVM_LOW)
			  `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",regs.get(),tm_pkt.data),UVM_LOW)
			  `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
			end
			else begin
			  `uvm_error(get_type_name(),"------ :: READ DATA MisMatch :: ------")
			  `uvm_info(get_type_name(),$sformatf("Addr: %0h",tm_pkt.addr),UVM_LOW)
			  `uvm_info(get_type_name(),$sformatf("Expected Data: %0h Actual Data: %0h",regs.get(),tm_pkt.data),UVM_LOW)
			  `uvm_info(get_type_name(),"------------------------------------",UVM_LOW)
			end
		end

	  end
	end
  endtask : rx_pkt_bus

  virtual task rx_pkt_ex_bus();
    tm_ex_seq_item tm_pkt_ex; 
	forever begin
      wait(pkt_ex_bus.size() > 0);
	  tm_pkt_ex = pkt_ex_bus.pop_front();
	
	  num = tm_pkt_ex.num;
      T   = tm_pkt_ex.T;
	  tOn = tm_pkt_ex.tOn; 
	  
      `uvm_info(get_type_name(),$sformatf("num: %0h T: %0h tOn: %0h",num,T,tOn),UVM_LOW)
	  
	end
  endtask : rx_pkt_ex_bus
    
endclass : tm_scoreboard