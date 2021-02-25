

//=========================================================================
// mem_sequence - random stimulus 
//=========================================================================
class tm_ex_sequence extends uvm_sequence#(tm_ex_seq_item);
  
  `uvm_object_utils(tm_ex_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "tm_ex_sequence");
    super.new(name);
  endfunction
  

  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
   repeat(2) begin
    req = tm_ex_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass
//=========================================================================

//=========================================================================
// init_sequence - "write" followed by "read" 
//=========================================================================
class evnt_seq extends uvm_sequence#(tm_ex_seq_item);
  
  `uvm_object_utils(evnt_seq)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "evnt_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.num==10;req.T==100;req.tOn==25;req.enEvnt==3'b111;})
    `uvm_do_with(req,{req.num==10;req.T==200;req.tOn==75;req.enEvnt==3'b111;})
  endtask
endclass
//=========================================================================
