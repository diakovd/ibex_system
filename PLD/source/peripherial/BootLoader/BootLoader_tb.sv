 `include "../source/defines.sv"
 `include "../source/peripherial/uart_module/defUART.v"
 `timescale 1 ps / 1 ps
 
 module BootLoader_tb(
	TX //TX UART line
 );
 parameter logic [7:0] STPbyte;
 parameter logic [7:0] ONbyte;
 parameter logic [15:0] BaudRate; 
 
 output TX; //RX UART line
	
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
	busWR8(`defU_DLL,`BR1843200); //Set
	
	
	#10000000;
	for (i =0; i < 33; i = i + 1) busWR8(`defU_FIFOtx,STPbyte);	

	#10000000;
	fd = $fopen("../sw/program.hex","r");

	//count number of byte
	numb = 0;
	$fgets(line, fd);
	if(line[0] == "@") begin
		while(!$feof(fd)) begin
			$fgets(line, fd);
			len = line.len() - 1;
			for(i = 0; i < len; i = i + 1) begin
				if(line[i] != " ") numb = numb + 1;
			end
		end
	end
	$fclose(fd);
	numb = numb/2;

	fd = $fopen("../sw/program.hex","r");
	//send start address
	$fgets(line, fd);
	$display (line);
	if(line[0] == "@") begin
		for(i = 1; i < 9; i = i + 2) begin
			$sscanf(line[9 - i - 1],"%x", h);
			$sscanf(line[9 - i],"%x", l);
			busWR8(`defU_FIFOtx,{h,l});
//			$display (h);
//			$display (l);
		end
	end
	
	//send number of byte
	if(line[0] == "@") begin
		for(i = 1; i < 9; i = i + 2) begin
			busWR8(`defU_FIFOtx,numb[7:0]);
			numb = {8'h00,numb[31:8]};
		end
	end	
	
	//send .hex
	while(!$feof(fd)) begin
		$fgets(line, fd);
		indx = 0;
		len = line.len();
		while(len > (indx + 7)) begin
			// for(i = 0; i < 8; i = i + 2) begin
				// $sscanf(line[indx + 7 - i - 1],"%d", h);
				// $sscanf(line[indx + 7 - i],"%d", l);
				
				// busRD8(`defU_FCR, FCR);
				// while(FCR[0]) busRD8(`defU_FCR, FCR);
				// busWR8(`defU_FIFOtx,{h,l});
			// end
			for(i = 0; i < 8; i = i + 1) begin
				$sscanf(line[indx + i],"%h", l);
				@(posedge Clk);
				dat = {dat[31 - 4:0],l}; 
			end

			for(i = 0; i < 4; i = i + 1) begin
				busRD8(`defU_FCR, FCR);
				while(FCR[0]) busRD8(`defU_FCR, FCR);
				busWR8(`defU_FIFOtx,dat[7:0]);
				dat = {8'h00,dat[31:8]};
			end

			indx = indx + 9;
			@(posedge Clk);
		end		
	end

	busRD8(`defU_FCR, FCR);
	while(!FCR[1]) busRD8(`defU_FCR, FCR);
	
	#10000000;
	for (i =0; i < 33; i = i + 1) busWR8(`defU_FIFOtx,ONbyte);	
	
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
	#3000 Clk = 1;
	forever  #8000 Clk = ~Clk;
 end

 initial begin // clk64
	#14000 Clk_14MHz = 0;
	forever  #34000 Clk_14MHz = ~Clk_14MHz;
 end
	
 UART UART_insts(
  	.CPUdat(CPUdat),
	.CPUctr(CPUctr),
 
  	.TX(TX),
	.RX(),

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

 	#10000000;
	@(posedge Clk);

	fun_UART_tst();
 end
 
 initial begin
	Rst = 1;
	#100000;
	Rst = 0;
 end
 
 endmodule