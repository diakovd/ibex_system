`include "../source/defines.sv"
`include "../source/bus_mux/ahb3lite_bus/ahb3lite_bus.sv" 
 // `include "defines.sv"

 module bus_mux(
	DatBus.Slave  data_DatBus,
	CtrBus.Slave  data_CtrBus,
	CtrBus.Master RAM_CtrBus,
	CtrBus.Master IO_CtrBus,
	CtrBus.Master UART0_CtrBus,
	ahb3lite_bus.master tm0_Bus,
	ahb3lite_bus.master tm1_Bus,
	 
	input Rst,
	input Clk 
 );

 logic sel_RAM; // data memory section  
 logic sel_IO;  
 logic sel_UART0;
 logic sel_Timer;
 logic sel_Timer1;

 assign data_CtrBus.rdata = (sel_RAM)? RAM_CtrBus.rdata :
							(sel_IO)?  IO_CtrBus.rdata  :
							(sel_UART0)?  UART0_CtrBus.rdata :  
							(sel_Timer)?  tm0_Bus.HRDATA : 
							(sel_Timer1)? tm1_Bus.HRDATA : 32'd0; 
 
 assign data_CtrBus.rvalid = (sel_RAM)? RAM_CtrBus.rvalid :
							 (sel_IO)?  IO_CtrBus.rvalid  :
							 (sel_UART0)?  UART0_CtrBus.rvalid :  
							 (sel_Timer)?  tm0_Bus.HREADY : 
							 (sel_Timer1)? tm1_Bus.HREADY : 1'd0; 

 assign data_CtrBus.gnt = (sel_RAM)? RAM_CtrBus.gnt :
						  (sel_IO)?  IO_CtrBus.gnt  : 
 						  (sel_UART0)?  UART0_CtrBus.gnt : 
 						  (sel_Timer)?  !tm0_Bus.HRESP : 
 						  (sel_Timer1)? !tm1_Bus.HRESP : 1'd0; 

 assign data_CtrBus.err = (sel_RAM)? RAM_CtrBus.err :
						  (sel_IO)?  IO_CtrBus.err  :
						  (sel_UART0)?  UART0_CtrBus.err : 
 						  (sel_Timer)?  tm0_Bus.HRESP  : 
 						  (sel_Timer1)? tm1_Bus.HRESP : 32'd0;
 
 assign RAM_CtrBus.we  = data_CtrBus.we  & sel_RAM;
 assign RAM_CtrBus.req = data_CtrBus.req & sel_RAM;
 
 // always_ff @(posedge Clk or posedge Rst) begin
	// if (Rst) RAM_CtrBus.gnt <= 'b0;
    // else 	 RAM_CtrBus.gnt <= RAM_CtrBus.req;
 // end
  
 assign IO_CtrBus.we  = data_CtrBus.we  & sel_IO;
 assign IO_CtrBus.req = data_CtrBus.req & sel_IO;
 
 assign UART0_CtrBus.we  = data_CtrBus.we  & (sel_UART0);
 assign UART0_CtrBus.req = data_CtrBus.req & (sel_UART0);

 assign tm0_Bus.HWRITE  = data_CtrBus.we;
 assign tm0_Bus.HTRANS = {data_CtrBus.req & (sel_Timer), 1'b0};
 assign tm0_Bus.HSEL   = sel_Timer;
 assign tm0_Bus.HWDATA = data_DatBus.wdata;
 assign tm0_Bus.HADDR  = data_DatBus.addr;

 assign tm1_Bus.HWRITE  = data_CtrBus.we;
 assign tm1_Bus.HTRANS = {data_CtrBus.req & (sel_Timer1), 1'b0};
 assign tm1_Bus.HSEL   = sel_Timer1;
 assign tm1_Bus.HWDATA = data_DatBus.wdata;
 assign tm1_Bus.HADDR  = data_DatBus.addr;
 
 always_comb begin
	// CPU address MUX
	if(data_DatBus.addr  >= (`addrBASE_Timer1)) begin 
		sel_IO  <= 0;
		sel_RAM <= 0;
		sel_UART0  <= 0;
		sel_Timer  <= 0;
		sel_Timer1 <= 1;
	end		
	else if(data_DatBus.addr  >= (`addrBASE_Timer)) begin 
		sel_IO  <= 0;
		sel_RAM <= 0;
		sel_UART0  <= 0;
		sel_Timer  <= 1;
		sel_Timer1 <= 0;
	end	
	else if(data_DatBus.addr  >= `addrBASE_UART0) begin 
		sel_IO  <= 0;
		sel_RAM <= 0;
		sel_UART0  <= 1;
		sel_Timer  <= 0;
		sel_Timer1 <= 0;
	end
	else if(data_DatBus.addr  >= `addrBASE_IOmodule) begin 
		sel_IO  <= 1;
		sel_RAM <= 0;
		sel_UART0  <= 0;
		sel_Timer  <= 0;
		sel_Timer1 <= 0;
	end	
	else if(data_DatBus.addr  >= `addrBASE_RAM) begin 
		sel_IO  <= 0;
		sel_RAM <= 1;
		sel_UART0  <= 0;
		sel_Timer  <= 0;
		sel_Timer1 <= 0;
	end	
	else begin
		sel_IO  <= 0;
		sel_RAM <= 1; //read rom from data request
		sel_UART0  <= 0;
		sel_Timer  <= 0;
		sel_Timer1 <= 0;
	end
 end
   
 endmodule