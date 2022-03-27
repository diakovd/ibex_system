// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
 `include "../source/defines.sv"
 `include "../source/bus_mux/ahb3lite_bus/ahb3lite_bus.sv" 
 
// synthesis translate_off
`define defSIM
// synthesis translate_on
 import ahb3lite_pkg::*;
 
 module ibex_sys (
	output TX,
	input  RX,
	
    output [31:0] IO,
	
	output [7:0] LEDen,
	output	LEDA,
	output	LEDB,
	output	LEDC,
	output	LEDD,
	output	LEDE,
	output	LEDF,
	output	LEDG,
	output	LEDDP,
	
	output [1:0] PWM,
	input  [1:0] Evnt,
	
	input Clk_14_7456MHz,
	input clk_sys,
	input rst_sys_n
 );
 
`ifdef Sim 
    parameter string  VENDOR = "Xilinx"; //optional "IntelFPGA" , "Simulation", "Xilinx" 
`else 
    parameter         VENDOR = "Xilinx"; //optional "IntelFPGA" , "Simulation", "Xilinx" 
`endif	

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
 logic Int_Timer1;
 logic RstBoot;

 logic [63:0] dgt1_8;

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
 CtrBus mtimer_CtrBus();	
 ahb3lite_bus tm0_Bus(clk_sys,rst_sys_n);
 ahb3lite_bus tm1_Bus(clk_sys,rst_sys_n);

  ibex_core #(
     .PMPEnable                ( 0            ),
     .PMPGranularity           ( 0            ),
     .PMPNumRegions            ( 4            ),
     .MHPMCounterNum           ( 0            ),
     .MHPMCounterWidth         ( 40           ),
     .RV32E                    ( 0            ),
     .RV32M                    ( 1            ),
     .MultiplierImplementation ( "Fast"       ),  
     .DmHaltAddr(32'h00000000),
     .DmExceptionAddr(32'h00000000)
  ) u_core (
     .clk_i                 (clk_sys),
     .rst_ni                (rst_sys_n & !RstBoot),

     .test_en_i             (1'b0),

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

     .debug_req_i           (1'b0),

     .fetch_enable_i        (1'b1),
     .core_sleep_o          ()
  );

// wire [31 : 0] probe0;
// wire [31 : 0] probe1;
// wire [31 : 0] probe2;
// wire [15 : 0] probe3;

 // ila_0 ila_0_inst(
    // .clk(clk_sys),

    // .probe0(probe0),
    // .probe1(probe1),
    // .probe2(probe2),
    // .probe3(probe3)
 // );

 // assign probe0 = instr_DatBus.addr;
 // assign probe1 = instr_CtrBus.rdata;
 // assign probe2 = 0;
 // assign probe3[0] = instr_CtrBus.req;
 // assign probe3[1] = instr_CtrBus.gnt;
 // assign probe3[2] = instr_CtrBus.rvalid;
 // assign probe3[3] = instr_CtrBus.err;
 // assign probe3[15:4] = 0;
 
 bus_mux bus_mux_inst(
 	.data_DatBus(data_DatBus.Slave),
	.data_CtrBus(data_CtrBus.Slave),
	.RAM_CtrBus(RAM_CtrBus.Master),
	.IO_CtrBus(IO_CtrBus.Master),
	.UART0_CtrBus(UART0_CtrBus.Master),
	.mtimer_CtrBus(mtimer_CtrBus.Master),
	.tm0_Bus(tm0_Bus.master),
	.tm1_Bus(tm1_Bus.master),

	.Rst(!rst_sys_n | RstBoot),
	.Clk(clk_sys)
 );
 
  // SRAM block for instruction 
  rom_1p #(
	.VENDOR(VENDOR),
    .Depth(MEM_SIZE)
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
   .IO(IO),
   .dgt1_8(dgt1_8),
   
   .Rst(!rst_sys_n | RstBoot),	
   .Clk(clk_sys)
 );
 
 LED8x8 LED8x8_inst(
	.digit1(dgt1_8[7:0]),
	.digit2(dgt1_8[15:8]),
	.digit3(dgt1_8[23:16]),
	.digit4(dgt1_8[31:24]),
	.digit5(dgt1_8[39:32]),
	.digit6(dgt1_8[47:40]),
	.digit7(dgt1_8[55:48]),
	.digit8(dgt1_8[63:56]),
	
	.LEDen(LEDen),
	.LEDA(LEDA),
	.LEDB(LEDB),
	.LEDC(LEDC),
	.LEDD(LEDD),
	.LEDE(LEDE),
	.LEDF(LEDF),
	.LEDG(LEDG),
	.LEDDP(LEDDP),
	
	.Clk(clk_sys)
 );

 mtimer #(
		.addrBase(`addrBASE_mtimer)
		)
 mtimer_inst(
	.CPUdat(data_DatBus.Slave),
	.CPUctr(mtimer_CtrBus.Slave),
	
	.Int(Int_mtimer),
	.Rst(!rst_sys_n),
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

 Timer #(
			.TM_SIZE(32),    		   
			.PWM_SIZE(1), 		     
			.BASE(`addrBASE_Timer),
			.HADDR_SIZE(32),     
			.HDATA_SIZE(32)      
		) 
 // .addrBase(`addrBASE_Timer),.bw(32))
 Timer_inst (
	// .CPUdat(data_DatBus.Slave),
	// .CPUctr(Timer_CtrBus.Slave),
	.CPUbus(tm0_Bus.slave),

	.Evnt0(Evnt[0]),
	.Evnt1(Evnt[1]),
	.Evnt2(1'b0),
	.PWM(),
	
	.Int(Int_Timer)
	// .Rst(!rst_sys_n | RstBoot),
	// .Clk(clk_sys)
 );
 assign tm0_Bus.HREADY = tm0_Bus.HREADYOUT;
 
 Timer
	#(
		.TM_SIZE(32),    		   
		.PWM_SIZE(2), 		     
		.BASE(`addrBASE_Timer1),
		.HADDR_SIZE(32),     
		.HDATA_SIZE(32)      
	)
// #(.addrBase(`addrBASE_Timer1),.bw(32),.bwPWM(2)) 
 Timer1_inst (
	// .CPUdat(data_DatBus.Slave),
	// .CPUctr(Timer1_CtrBus.Slave),
	.CPUbus(tm1_Bus.slave),

	.Evnt0(1'b0),
	.Evnt1(1'b0),
	.Evnt2(1'b0),
	.PWM(PWM),
	
	.Int(Int_Timer1)
	// .Rst(!rst_sys_n | RstBoot),
	// .Clk(clk_sys)
 );
 assign tm1_Bus.HREADY = tm1_Bus.HREADYOUT;

endmodule
