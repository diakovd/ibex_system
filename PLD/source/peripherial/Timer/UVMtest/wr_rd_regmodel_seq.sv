
class wr_rd_regmodel_seq extends uvm_sequence #(tm_seq_item);

  `uvm_object_utils(wr_rd_regmodel_seq)

  top_reg_block       regmodel;
  
  
  uvm_status_e        status;  // Returning access status
  rand uvm_reg_data_t data;    // For passing data

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "wr_rd_regmodel_seq");
    super.new(name);
  endfunction

  task body();

     regmodel.bus.TmPrSh.write(status, 32'h12345678);
     assert(status == UVM_IS_OK);

     regmodel.bus.TmPrSh.read(status, .value(data), .parent(this));
     assert(status == UVM_IS_OK);
    `uvm_info(get_type_name(), $sformatf("data=0x%0h", data), UVM_MEDIUM);

    // Set 0xface as the desired value for timer[1] register
    regmodel.bus.TmPrSh.set(32'h12345678);
    `uvm_info(get_type_name(), $sformatf("desired=0x%0h mirrored=0x%0h", regmodel.bus.TmPrSh.get(), regmodel.bus.TmPrSh.get_mirrored_value()), UVM_MEDIUM)

      

     regmodel.bus.TmCmpSh.write(status, .value('hcd), .parent(this));
     assert(status == UVM_IS_OK);

     regmodel.bus.TmCap0.write(status, .value('hef), .parent(this));
     assert(status == UVM_IS_OK);
     
     regmodel.bus.TmPrSh.read(status, .value(data), .parent(this));
     assert(status == UVM_IS_OK);
  endtask: body


endclass : wr_rd_regmodel_seq

class reset_seq extends uvm_sequence;
   `uvm_object_utils (reset_seq)
   function new (string name = "reset_seq");
      super.new (name);
   endfunction

   virtual ahb3lite_bus vif;

   task body ();
	  if(!uvm_config_db#(virtual ahb3lite_bus)::get(null, "tbench_top", "vif", vif))
		   `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});

      `uvm_info ("RESET", "Running reset ...", UVM_MEDIUM);
	  @(posedge vif.HRESETn);
   endtask
endclass

  //---------------------------------------
  // count external event to compare 0,1 registers test seq's
  //---------------------------------------
class cnt_to_compReg_init_seq extends uvm_sequence;
   `uvm_object_utils (cnt_to_compReg_init_seq)
   function new (string name = "cnt_to_compReg_init_seq");
      super.new (name);
   endfunction

  top_reg_block       regmodel;
  uvm_status_e        status;  // Returning access status
  rand uvm_reg_data_t data;    // For passing data
  uvm_reg_item 	rw;	

   task body ();
	if(!uvm_config_db#(top_reg_block)::get(null, "uvm_test_top", "regmodel", regmodel))
		   `uvm_fatal("NO_VIF",{"regmodel must be set for: ",get_full_name(),".regmodel"});
	
    regmodel.bus.ECR.E0ES.set(2'h1);
    regmodel.bus.ECR.E1ES.set(2'h1);
    regmodel.bus.ECR.E0FC.set(2'h0);
    regmodel.bus.ECR.E1FC.set(2'h0);
	
    regmodel.bus.CMC.CntCapS0.set(2'h1);
    regmodel.bus.CMC.CntCapS1.set(2'h2);

	regmodel.bus.update(status);
    assert(status == UVM_IS_OK);	
	
    regmodel.bus.ECR.read(status, .value(data), .parent(this));
    `uvm_info(get_type_name(), $sformatf("ECR=0x%0h", data), UVM_MEDIUM);
	assert(status == UVM_IS_OK);
	regmodel.bus.ECR.mirror(status,  .parent(this));
	assert(status == UVM_IS_OK);
    `uvm_info(get_type_name(), $sformatf("ECR reg desired=0x%0h mirrored=0x%0h", regmodel.bus.ECR.get(), regmodel.bus.ECR.get_mirrored_value()), UVM_MEDIUM);

    regmodel.bus.CMC.read(status, .value(data), .parent(this));
	assert(status == UVM_IS_OK);
    `uvm_info(get_type_name(), $sformatf("CMC=0x%0h", data), UVM_MEDIUM);
	regmodel.bus.CMC.mirror(status,  .parent(this));
    assert(status == UVM_IS_OK);	
    `uvm_info(get_type_name(), $sformatf("CMC reg desired=0x%0h mirrored=0x%0h", regmodel.bus.CMC.get(), regmodel.bus.CMC.get_mirrored_value()), UVM_MEDIUM);

	
    assert(status == UVM_IS_OK);
   endtask
endclass

class cnt_to_compReg_RD_seq extends uvm_sequence;
   `uvm_object_utils (cnt_to_compReg_RD_seq)
   function new (string name = "cnt_to_compReg_RD_seq");
      super.new (name);
   endfunction

  top_reg_block       regmodel;
  uvm_status_e        status;  // Returning access status
  rand uvm_reg_data_t data;    // For passing data

   task body ();
	if(!uvm_config_db#(top_reg_block)::get(null, "uvm_test_top", "regmodel", regmodel))
		   `uvm_fatal("NO_VIF",{"regmodel must be set for: ",get_full_name(),".regmodel"});


    regmodel.bus.TmCap0.read(status, .value(data), .parent(this));
    assert(status == UVM_IS_OK);
    `uvm_info(get_type_name(), $sformatf("TmCap0=0x%0h", data), UVM_MEDIUM);

    regmodel.bus.TmCap2.read(status, .value(data), .parent(this));
    assert(status == UVM_IS_OK);
    `uvm_info(get_type_name(), $sformatf("TmCap2=0x%0h", data), UVM_MEDIUM);

	 
    assert(status == UVM_IS_OK);
   endtask
endclass