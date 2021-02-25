
class tm_ex_seq_item extends uvm_sequence_item;

  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand int num; 	//number of pulse 
  rand int T;		//period of pulse in sim time unit
  rand int tOn;  	//pulse width in sim time unit
  rand bit [2:0]  enEvnt; //event enable, send pulse to Event 2 - 0
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(tm_ex_seq_item)
    `uvm_field_int(num,UVM_ALL_ON)
    `uvm_field_int(T,UVM_ALL_ON)
    `uvm_field_int(tOn,UVM_ALL_ON)
    `uvm_field_int(enEvnt,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "tm_ex_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  //constraint wr_rd_c { wr_en != rd_en; }; 
  
endclass