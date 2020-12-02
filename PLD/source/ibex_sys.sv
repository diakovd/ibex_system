// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
 `include "../source/defines.sv"

// synthesis translate_off
`define defSIM
// synthesis translate_on

`timescale 1 ps / 1 ps

 module ibex_sys (
	output TX,
	input  RX,
    output [31:0] LED,
	input Clk_14_7456MHz,
	input clk_sys,
	input rst_sys_n
 );
  parameter string 		 VENDOR    = "Xilinx"; //optional "IntelFPGA"
  parameter int          MEM_SIZE  = 4 * 1024; // 4 kB

  // Instruction connection to SRAM
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // Data connection to SRAM
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic  [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  // SRAM arbiter
  logic [31:0] mem_addr;
  logic        mem_req;
  logic        mem_write;
  logic  [3:0] mem_be;
  logic [31:0] mem_wdata;
  logic        mem_rvalid;
  logic [31:0] mem_rdata;

 logic Int_UART;
 logic Int_Timer;
 logic RstBoot;

 // CPUdataMemBus 	CPUdataMem();
 // RAMbus  		Data_RAMbus();
 // AXI4bus 		AXI4busIO();
 
 DatBus instr_DatBus();
 CtrBus instr_CtrBus();	

 DatBus Boot_DatBus();
 CtrBus Boot_CtrBus();	

 DatBus data_DatBus();
 CtrBus data_CtrBus();	

 CtrBus IO_CtrBus();
 CtrBus RAM_CtrBus();
 CtrBus UART0_CtrBus();
 CtrBus Timer_CtrBus();

  ibex_core #(
     .PMPEnable                ( 0            ),
     .PMPGranularity           ( 0            ),
     .PMPNumRegions            ( 4            ),
     .MHPMCounterNum           ( 0            ),
     .MHPMCounterWidth         ( 40           ),
     .RV32E                    ( 0            ),
     .RV32M                    ( 1            ),
     .MultiplierImplementation ( "fast"       ),  
     .DmHaltAddr(32'h00000000),
     .DmExceptionAddr(32'h00000000)
  ) u_core (
     .clk_i                 (clk_sys),
     .rst_ni                (rst_sys_n & !RstBoot),

     .test_en_i             ('b0),

     .hart_id_i             (32'b0),
     // First instruction executed is at 0x0 
     .boot_addr_i           (32'h00000000),

     .instr_req_o           (instr_CtrBus.req),
     .instr_gnt_i           (instr_CtrBus.gnt),
     .instr_rvalid_i        (instr_CtrBus.rvalid),
     .instr_addr_o          (instr_DatBus.addr),
     .instr_rdata_i         (instr_CtrBus.rdata),
     .instr_err_i           (instr_CtrBus.err),

     .data_req_o            (data_CtrBus.req),
     .data_gnt_i            (data_CtrBus.gnt),
     .data_rvalid_i         (data_CtrBus.rvalid),
     .data_we_o             (data_CtrBus.we),
     .data_be_o             (data_DatBus.be),
     .data_addr_o           (data_DatBus.addr),
     .data_wdata_o          (data_DatBus.wdata),
     .data_rdata_i          (data_CtrBus.rdata),
     .data_err_i            (data_CtrBus.err),

     .irq_software_i        (Int_UART),
     .irq_timer_i           (Int_Timer),
     .irq_external_i        (1'b0),
     .irq_fast_i            (15'b0),
     .irq_nm_i              (1'b0),

     .debug_req_i           ('b0),

     .fetch_enable_i        ('b1),
     .core_sleep_o          ()
  );

 bus_mux bus_mux_inst(
 	.data_DatBus(data_DatBus.Slave),
	.data_CtrBus(data_CtrBus.Slave),
	.RAM_CtrBus(RAM_CtrBus.Master),
	.IO_CtrBus(IO_CtrBus.Master),
	.UART0_CtrBus(UART0_CtrBus.Master),
	.Timer_CtrBus(Timer_CtrBus.Master),

	.Rst(!rst_sys_n | RstBoot),
	.Clk(clk_sys)
 );
 
  // SRAM block for instruction 
  rom_1p #(
	.VENDOR(VENDOR),
    .Depth(MEM_SIZE / 4)
  ) u_ram_instr
  (
	.CPUdat(instr_DatBus.Slave),
	.CPUCtr(instr_CtrBus.Slave),
	
	.RAM_DatBus(data_DatBus.Slave),
	.RAM_CtrBus(RAM_CtrBus.Slave),
	
	.BootDat(Boot_DatBus.Slave),
	.BootCtr(Boot_CtrBus.Slave),
	
	.RstBoot(RstBoot),
    .clk(clk_sys),
    .rst_n(rst_sys_n)
  );
   
 assign instr_DatBus.be = 4'hf;
 assign instr_DatBus.wdata = 32'h00000000;
 assign instr_CtrBus.we = 1'b0;
  
  // SRAM block for data storage
  // ram_1p #(
	// .VENDOR(VENDOR),
    // .Depth(MEM_SIZE / 4)
  // ) u_ram_data
  // (
	// .DatBus(data_DatBus.Slave),
	// .CtrBus(RAM_CtrBus.Slave),
	
    // .clk(clk_sys),
    // .rst_n(rst_sys_n)
  // );  
  
 IOmodule IOmodule_inst(
   .DatBus(data_DatBus.Slave),
   .CtrBus(IO_CtrBus.Slave),

   //IO out
   .IO(LED),
   
   .Rst(!rst_sys_n | RstBoot),	
   .Clk(clk_sys)
 );

 UART #(
		.VENDOR(VENDOR),
		.addrBase(`addrBASE_UART0)
		)
 UART_inst(
	.CPUdat(data_DatBus.Slave),
	.CPUctr(UART0_CtrBus.Slave),

  	.TX(TX),
	.RX(RX),
	
	.Int(Int_UART),
	.Rst(!rst_sys_n),
	.Clk(clk_sys),
	.Clk_14MHz(Clk_14_7456MHz) 	//14.7456 MHz	
	
 );

 BootLoader  #(
	.STPbyte(8'h55),
	.ONbyte( 8'hAA),
	.BaudRate(8) //921600
 )
 
 BootLoader_inst(
	.RX(RX), //RX UART line
	
	.CPUdat(Boot_DatBus.Master),
	.CPUctr(Boot_CtrBus.Master),
	
	.Rst_out(RstBoot),//Reset system when loading memory instruction
	.Rst(!rst_sys_n),
	.Clk_14MHz(Clk_14_7456MHz),
	.Clk(clk_sys)
 );

 Timer #(`addrBASE_Timer) Timer_inst (
	.CPUdat(data_DatBus.Slave),
	.CPUctr(Timer_CtrBus.Slave),

	.Evnt0(1'b0),
	.Evnt1(1'b0),
	.Evnt2(1'b0),
	.PWM(),
	
	.Int(Int_Timer),
	.Rst(!rst_sys_n | RstBoot),
	.Clk(clk_sys)
 );
  
endmodule
