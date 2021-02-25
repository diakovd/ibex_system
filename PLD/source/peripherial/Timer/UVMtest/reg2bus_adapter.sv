// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: bus_adapter.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2016-04-18-EP on Wed Feb 10 06:12:12 2021
//=============================================================================
// Description: Environment for reg2 bus_adapter.sv

//=============================================================================

`ifndef REG2BUS_ADAPTER_SV
`define REG2BUS_ADAPTER_SV

// You can insert code here by setting adapter_inc_before_class in file bus.tpl

class reg2bus_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2bus_adapter)

  extern function new(string name = "");

  // You can remove reg2bus and bus2reg by setting adapter_generate_methods_inside_class = no in file bus.tpl

  extern function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  extern function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

  // You can insert code here by setting adapter_inc_inside_class in file bus.tpl

endclass : reg2bus_adapter 


function reg2bus_adapter::new(string name = "");
   super.new(name);
endfunction : new


// You can remove reg2bus and bus2reg by setting adapter_generate_methods_after_class = no in file bus.tpl

function uvm_sequence_item reg2bus_adapter::reg2bus(const ref uvm_reg_bus_op rw);
  tm_seq_item bus = tm_seq_item::type_id::create("bus");
  bus.cmd  = (rw.kind == UVM_READ) ? 0 : 1;
  bus.addr = rw.addr;                      
  bus.data = rw.data;                      
  `uvm_info(get_type_name(), $sformatf("reg2bus rw::kind: %s, addr: %d, data: %h, status: %s", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)
  return bus;
endfunction : reg2bus


function void reg2bus_adapter::bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
  tm_seq_item bus;
  if (!$cast(bus, bus_item))
    `uvm_fatal(get_type_name(),"Provided bus_item is not of the correct type")
  rw.kind   = bus.cmd ? UVM_WRITE : UVM_READ;
  rw.addr   = bus.addr;
  rw.data   = bus.data;
  rw.status = UVM_IS_OK;
  `uvm_info(get_type_name(), $sformatf("bus2reg rw::kind: %s, addr: %d, data: %h, status: %s", rw.kind, rw.addr, rw.data, rw.status), UVM_HIGH)
endfunction : bus2reg


// You can insert code here by setting adapter_inc_after_class in file bus.tpl


`endif // REG2BUS_ADAPTER_SV

