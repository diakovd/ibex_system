 `include "../source/defines.sv"
 `include "../source/peripherial/uart_module/defUART.v"
 
 module UART_emu(
	TX, //TX UART line
	RX //RX UART line
 );
 
 parameter logic [15:0] BaudRate; 
 
 output TX; //TX UART line
 input  RX; //RX UART line
	
 DatBus CPUdat();
 CtrBus CPUctr();

 logic Int;
 logic Rst;
 logic Clk = 0s;
 logic Clk_14MHz = 0;
 logic [31:0] RDdata32;
 logic [7:0] RDdata8;
 logic [7:0] CR;
 logic [7:0] ISR;
 logic [7:0] FCR = 0;
 logic [7:0] ESR = 0;
 logic SetClearTX;
 logic SetClearRX;
 logic addError;
 logic [7:0] RxCntL;
 logic SetRXInt;
  
 int i,indx, len;
 int fd;
 string line;
 string  wstr;

 logic [31:0] dat; 
 logic [31:0] numb; 

 logic [3:0] h; 
 logic [3:0] l; 

 // int h; 
 // int l; 
 
 
 task busWR8;
	input [31:0] adr;
	input [7:0] dat;
 begin
	@(posedge Clk);
	CPUdat.wdata = {dat,dat,dat,dat};
	CPUdat.addr = {adr[31:2],2'b00};
	CPUctr.req = 1;  
	CPUctr.we  = 1;
	CPUdat.be  = (adr[1:0] == 0)? 4'b0001 :
				 (adr[1:0] == 1)? 4'b0010 :
				 (adr[1:0] == 2)? 4'b0100 : 4'b1000;
				 
	@(posedge Clk);

	while(!CPUctr.gnt) @(posedge Clk);
	CPUdat.wdata = 0;
	CPUdat.addr = 0;
	CPUctr.req = 0;  
	CPUctr.we  = 0;
	CPUdat.be  = 4'b0000;
 end 
 endtask

 task busRD8;
	input [31:0] adr;
	output [7:0] data;
 begin
	@(posedge Clk);
	CPUdat.wdata = 0;
	CPUdat.addr = {adr[31:2], 2'b00};
	CPUctr.req = 1;  
	CPUctr.we  = 0;
	CPUdat.be  = (adr[1:0] == 0)? 4'b0001 :
				 (adr[1:0] == 1)? 4'b0010 :
				 (adr[1:0] == 2)? 4'b0100 : 4'b1000;
	
	@(posedge Clk);

	while(!CPUctr.gnt) @(posedge Clk);
	CPUdat.wdata = 0;
	CPUdat.addr = 0;
	CPUctr.req = 0;  
	CPUctr.we  = 0;	
	
	while(!CPUctr.rvalid) @(posedge Clk);
    data = (CPUdat.be == 4'b0001)?  	CPUctr.rdata[7:0]:
		   (CPUdat.be == 4'b0010)?  	CPUctr.rdata[15:8]:
		   (CPUdat.be == 4'b0100)?  	CPUctr.rdata[23:16]:
		   (CPUdat.be == 4'b1000)?  	CPUctr.rdata[31:24]: 8'h00;	
	CPUdat.be  = 0;
 end 
 endtask 
	
 //Tasks to test UART function
 task fun_UART_tst; //
 begin
	
	//Write period val
	CR = 0;
	CR = CR | 8'b01;  //Set Odd parity
	//CR = CR | (1'b1 << 3); //set Rx Data Available Interrupt
	CR = CR | (1'b1 << 4); //set Tx Empty Interrupt
	CR = CR | (1'b1 << 5); //set Rx Error Status Interrupt
	//CR = CR | (1'b1 << 6); //Internal Loop TX to RX
	busWR8(`defU_CR, CR); //Set Odd parity
	busWR8(`defU_DLL,`BR921600); //Set
	
	 busWR8(`defU_FIFOtx,8'h63);
	 busWR8(`defU_FIFOtx,8'h6D);
	 busWR8(`defU_FIFOtx,8'h64);
	 busWR8(`defU_FIFOtx,8'h01);
	 busWR8(`defU_FIFOtx,8'h02);
	
	
	// while(1) begin 
		// if(Int) begin
			// busRD8(`defU_ISR, ISR);
			// if(ISR & 8'b1) begin //Rx data availble
				// // busRD8(`defU_FCR, FCR);
				// // while(!FCR[3]) begin
					// // busRD8(`defU_FIFOrx, RDdata8);
					// // busRD8(`defU_FCR, FCR);
				// // end
				// busRD8(`defU_RxCntL,RxCntL);
				// for (i =0; i < RxCntL; i = i + 1) busRD8(`defU_FIFOrx, RDdata8);
			// end
			
			// if(ISR & 8'b10) begin //Tx FIFO empty
				// i = 0;
				// busRD8(`defU_FCR, FCR);
				// while(!FCR[0]) begin
					// busWR8(`defU_FIFOtx,i); //TX data
					// busRD8(`defU_FCR, FCR);
					// i = i + 1;
				// end		
			// end
			// if(ISR & 8'b100) begin //Rx Error Status
				// busRD8(`defU_ESR, ESR);
			// end
		// end
		
		// if(SetClearTX) begin //TX FIFO Clear
			// FCR = FCR | (1'b1 << 4); //set Tx Empty Interrupt
			// busWR8(`defU_FCR, FCR); //Set Odd parity			
		// end
		
		// if(SetClearRX) begin //RX FIFO Clear
			// FCR = FCR | (1'b1 << 5); //set Rx Empty Interrupt
			// busWR8(`defU_FCR, FCR); //Set Odd parity			
		// end		

		// if(SetRXInt) begin //Rx Data Available Interrupt
			// CR = CR | (1'b1 << 3); //set Rx Data Available Interrupt
			// busWR8(`defU_CR, CR); //Set Odd parity	
			
			// busRD8(`defU_RxCntL,RxCntL);
			// if(RxCntL > 0) begin
				// for (i =0; i < RxCntL; i = i + 1) busRD8(`defU_FIFOrx, RDdata8);
			// end
		// end		

		
		// @(posedge Clk);
		
	// end
	
 end 
 endtask 

 initial begin // clk64
	#(3*(`tm_scale)) Clk = 1;
	forever  #(8*(`tm_scale)) Clk = ~Clk;
 end

 initial begin // clk64
	#(14*(`tm_scale)) Clk_14MHz = 0;
	forever  #(34*(`tm_scale)) Clk_14MHz = ~Clk_14MHz;
 end
	
 UART #(
		.VENDOR("Simulation"),
		.addrBase(0)
		)
 UART_insts(
  	.CPUdat(CPUdat),
	.CPUctr(CPUctr),
 
  	.TX(TX),
	.RX(RX),

	.Int(Int),
	.Rst(Rst),
	.Clk(Clk),		//System Clk
	.Clk_14MHz(Clk_14MHz) 	//14.7456 MHz
 );
 
  initial begin 
	CPUdat.wdata = 0;
	CPUdat.addr = 0;
	CPUctr.req = 0;  
	CPUctr.we  = 0;
	CPUdat.be  = 4'b0000;

 	#(10000*(`tm_scale));
	@(posedge Clk);

	fun_UART_tst();
 end
 
 initial begin
	Rst = 1;
	#(100*(`tm_scale));
	Rst = 0;
 end
 
 endmodule