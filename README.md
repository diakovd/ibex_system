## IBEX system
Purpose of this progect to do minimal microcontroller system runing on FPGA device like NIOS from IntelFPGA or Xilinx's Microblaze.
Intend this system:
- Open sorce base core - there for using RISC-V ISA
- low area in FPGA
- minimal needs of ROM, RAM for code memory 
- easy and light IDE toolchane
- core must be writen on System Verilog 

For this requements was choosen IBEX core (https://github.com/lowRISC/ibex.git) and IDE Segger Embeded Studio.
I made some bug fix when testing IBEX core, so for this project take IBEX core from this : https://github.com/diakovd/ibex.git

## IBEX system consyst
- RAM for program code and data storage - 8k byte
- bus_mux module swith control signal to specific perepherial
- Timer module
- UART Universal Asynchronous Receiver/Transmitter 
- UART bootLoader for fast update program to RAM memory
- IO module - 32 bit out register 
 
 ![Alt text](https://github.com/diakovd/ibex_system/blob/main/sys.jpg?raw=true "Title")
 
## Pinout
	TX, RX - UART line
	Clk_14_7456MHz - clock 14.7456MHz for URAT module 
    clk_sys - system clock for IBEX core (30MHz for EP4CE10E22C8) 
	rst_sys_n - system reset
	LED - 32 bit IO module out
	
## Folders
- source - IBEX system(ibex_sys.sv) and perepherial modules  
- ms - contane .tcl scripts for modelsim simulation
- qua_pr - EP4CE10E22C8 FPGA board wrapper (ibex_sys_cycloneIV.sv), also contane EP4CE10E22C8 specific RAM, FIFO and PLL
- VIVpr  - xc7a15t FPGA board wrapper (ibex_sys_atrix7.sv), also contane xc7a15t specific RAM, FIFO and PLL
- sw - hello word project for Segger Embeded Studio for RISC-V. This project wait interrupt from Timer and on interrupt send hello word through UART

## Bus description
IBEX core have instruction and data bus. Instruction bus conneted directly to RAM memory what contane program code, after start IBEX read instruction through this intrface.
Data bus using for access program data and perepherial modules. 
Data bus devided to two interface:
	DatBus (addr, wdata, be) connected to all perepherial; 
	CtrBus (rdata, we, req, rvalid, gnt, err) what swithing in bus_mux module to specific perepherial

## Step to add new perepherial
1. Great wrapper with DatBus, CtrBus interfase in port list of module   
2. Instance module to ibex_sys.sv
3. In defines.sv add base address and size on system bus 
	`define addrBASE_new (`addrBASE_Timer + `size_Timer)
	`define size_new 	   32'h00020
4. Add swithing in bus_mux.sv
		add to port list: CtrBus.Master new_CtrBus
		add variable:  logic sel_new;
		add swithing for all signal: (sel_new)?  new_CtrBus."" : 32'd0; 
		add control signal enabeling: new_CtrBus.we  = data_CtrBus.we  & sel_new;
		add address selection by same way as for other modules in // CPU address MUX section
5. Declare new_CtrBus in ibex_sys.sv and make connection betwin new module and bus_mux  
6. Software: add in ibex_core.h  Memory map for new module:
	#define new_BASE_ADDR (Timer_BASE_ADDR + Timer_SIZE)
	#define new_SIZE   0x00050
7. Add helper define
	#define new_REG(offset)  _REG32(new_BASE_ADDR, offset)	
	
## Python scripts tools for convertion hex pogram files
1. To convert pogram in intel hex format generated by Segger Studio to:
- .mif IntelFPGA memory intialisation file use IHEXtoMIF.py 
- .hex systemverilog memory intialisation file use IHEXtoSVhex.py
- .coe Xilinx memory intialisation file use IHEXtoCOE.py
2. To reload pogram hex under power 
	run IHEXtoSVhex.py;
	set in UARTboot.py "COMx" number
	connect uart to board
	run UARTboot.py what send SVhex to IBEX system RAM memory 

## License

Unless otherwise noted, everything in this repository is covered by the Apache
License, Version 2.0 (see LICENSE for full text).
 
