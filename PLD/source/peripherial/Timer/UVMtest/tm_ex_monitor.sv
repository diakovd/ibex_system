//-------------------------------------------------------------------------
//						mem_monitor - www.verificationguide.com 
//-------------------------------------------------------------------------

class tm_ex_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual tm_ex_if exif;
  
  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(tm_ex_seq_item) ex_analysis_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  tm_ex_seq_item ex_m_data;

  `uvm_component_utils(tm_ex_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    ex_m_data = new();
    ex_analysis_port = new("ex_analysis_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual tm_ex_if)::get(this, "", "exif", exif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".exif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  // rand int num; 	//number of pulse 
  // rand int T;		//period of pulse in sim time unit
  // rand int tOn;  	//pulse width in sim time unit
  // rand bit [2:0]  enEvnt; //event enable, send pulse to Event 2 - 0

  virtual task run_phase(uvm_phase phase);
	int num = 0;
	int T  = 0;
	int tOn  = 0;
	
	wait(exif.Evnt0 | exif.Evnt1 | exif.Evnt2);
    forever begin
		
		while(exif.Evnt0 | exif.Evnt1 | exif.Evnt2) begin
			#1;
			tOn = tOn + 1;
		end

		num = num + 1;
        ex_m_data.num = num;
        ex_m_data.T   = T;
        ex_m_data.T   = T;
 		ex_m_data.enEvnt = {exif.Evnt2,exif.Evnt1,exif.Evnt0};
		ex_analysis_port.write(ex_m_data);
		
		
		T = tOn;
		while(!exif.Evnt0 & !exif.Evnt1 & !exif.Evnt2) begin
			#1;
			T = T + 1;
		end
    end 
  endtask : run_phase

endclass : tm_ex_monitor
