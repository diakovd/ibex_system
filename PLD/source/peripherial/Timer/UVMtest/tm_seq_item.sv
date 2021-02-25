//-------------------------------------------------------------------------
//						mem_seq_item - www.verificationguide.com 
//-------------------------------------------------------------------------

class tm_seq_item extends uvm_sequence_item;

  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand bit [31:0] addr;
  rand bit        cmd;
  rand bit [31:0] data;
  //bit      [31:0] rdata;

  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(tm_seq_item)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(cmd,UVM_ALL_ON)
    //`uvm_field_int(wdata,UVM_ALL_ON)
  `uvm_object_utils_end
  // `uvm_object_utils(tm_seq_item)


  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "tm_seq_item");
    super.new(name);
  endfunction
  
  //---------------------------------------
  //constaint, to generate any one among write and read
  //---------------------------------------
  //constraint wr_rd_c { wr_en != rd_en; }; 
  
endclass