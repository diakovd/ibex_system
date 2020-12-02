`ifndef IBEXSIS_DEFINES_H
`define IBEXSIS_DEFINES_H


 //adsress defintion
 `define addrBASE_RAM  		32'h1000
 `define size_RAM			32'h1000
 `define addrBASE_IOmodule 	(`addrBASE_RAM + `size_RAM)
 `define size_IOmodule 		32'h00004

 `define addrBASE_UART0  (`addrBASE_IOmodule + `size_IOmodule)
 `define size_UART0 	   32'h00010

 `define addrBASE_Timer (`addrBASE_UART0 + `size_UART0)
 `define size_Timer 	   32'h00020


 // interface defintion
 
 interface AXI4bus #(parameter dw = 32, parameter aw = 32, parameter sw = 4);
    // AXI4 lite slave interface
  logic [aw - 1 : 0]  awaddr;
  logic [dw - 1 : 0]  wdata;
  logic [sw - 1 : 0]  wstrb;
   
  logic  wvalid;
  logic  awvalid;
  logic  bvalid;
  logic [1 : 0]  bresp;

  logic  wready;
  logic  awready;

  logic [aw - 1 : 0]  araddr;
  logic  arvalid;

  logic  bready;
  logic  rready;
  logic  rvalid;
  logic [1 : 0]  rresp;
   
  logic [dw - 1 : 0]  rdata;
  logic  arready;

  //IO out
  logic [dw - 1:0] IO;
  
  modport Master (
	  output  awaddr,
	  output  wdata,
	  output  wstrb,
	   
	  output  wvalid,
	  output  awvalid,
	  input   bvalid,
	  input   bresp,

	  input  wready,
	  input  awready,

	  output  araddr,
	  output  arvalid,

	  output  bready,
	  output  rready,
	  input   rvalid,
	  input   rresp,
	   
	  input  rdata,
	  input  arready
  );
	  
  modport Slave (
	  input  awaddr,
	  input  wdata,
	  input  wstrb,
	   
	  input   wvalid,
	  input   awvalid,
	  output  bvalid,
	  output  bresp,

	  output  wready,
	  output  awready,

	  input  araddr,
	  input  arvalid,

	  input   bready,
	  input   rready,
	  output  rvalid,
	  output  rresp,
	   
	  output  rdata,
	  output  arready
  );
endinterface

 interface DatBus #(parameter dw = 32, parameter aw = 32, parameter sw = 4);
    logic [aw - 1 : 0] addr;
    logic [dw - 1 : 0] wdata;
    logic [sw - 1 : 0] be;
	
	modport Master(
		output addr,
		output wdata,
		output be
    );
	  
    modport Slave(
		input addr,
		input wdata,
		input be
    );
 endinterface

 interface CtrBus #(parameter dw = 32);
    logic [dw - 1 : 0] rdata;
    logic we;
    logic req;
    logic rvalid;
    logic gnt;
	logic err;
	
	modport Master(
		input rdata,
		output we,
		output req,
		input rvalid,
		input gnt,
		input err		
    );
	  
    modport Slave(
		output rdata,
		input we,
		input req,
		output rvalid,
		output gnt,
		output err	
    );
 endinterface

	
 interface WBbus #(parameter dw = 32, parameter aw = 32, parameter sw = 4);
	//WB BUS
    logic [dw - 1:0] wb_dat_wr;
    logic [dw - 1:0] wb_dat_rd;
    logic [aw - 1:0] wb_adr;
    logic [sw - 1:0] wb_be;
    logic wb_stb;
    logic wb_ack;
    logic wb_we;
endinterface

	
 interface CPUdataMemBus #(parameter dw = 32, parameter aw = 32, parameter sw = 4);
    // AXI4 lite slave interface
    logic        data_req;
    logic        data_gnt;
    logic        data_rvalid;
    logic        data_we;
    logic [sw - 1:0] data_be;
    logic [aw - 1:0] data_addr;
    logic [dw - 1:0] data_wdata;
    logic [dw - 1:0] data_rdata;
    logic        data_err ;

  modport Master (
    // Data memory interface
    output  data_req ,
    input   data_gnt ,
    input   data_rvalid ,
    output  data_we ,
    output  data_be ,
    output  data_addr ,
    output  data_wdata ,
    input   data_rdata ,
    input   data_err   
    );
  modport Slave (
      // Data memory interface
    input    data_req ,
    output   data_gnt ,
    output   data_rvalid ,
    input    data_we ,
    input    data_be ,
    input    data_addr ,
    input    data_wdata ,
    output   data_rdata ,
    output   data_err 
    );
endinterface

 interface RAMbus #(parameter dw = 32, parameter aw = 32, parameter sw = 4);

    logic            req ;
    logic            we ;
    logic [sw - 1:0] be ;
    logic [aw - 1:0] addr ;
    logic [dw - 1:0] wdata ;
    logic            rvalid ;
    logic [dw - 1:0] rdata ;

  modport Master (
    output req ,
    output we ,
    output be ,
    output addr ,
    output wdata ,
    input  rvalid ,
    input  rdata 
    );
  modport Slave (
    input  req ,
    input  we ,
    input  be ,
    input  addr ,
    input  wdata ,
    output rvalid ,
    output rdata 
    );
endinterface

`endif