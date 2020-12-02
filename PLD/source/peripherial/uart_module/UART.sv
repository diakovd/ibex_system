 `include "../source/defines.sv"
 `include "../source/peripherial/uart_module/defUART.v"
 
 //synthesis translate_off 
 // synthesis translate_on

 module UART(
	DatBus.Slave  CPUdat,
	CtrBus.Slave  CPUctr,
 
	output TX,
	input  RX,

	output Int,
	input Rst,
	input Clk,
	input Clk_14MHz 
 );
  
  parameter string VENDOR = "Xilinx"; //optional "IntelFPGA"
  parameter int addrBase = 0;

 CONTROL_REGISTER CR;
 FIFO_STATUS_CONTROL_REGISTER FCR;
 logic [15:0] TxCnt;
 logic [15:0] RxCnt;
 INTERRUPT_STATUS_REGISTER ISR;
 ERROR_STATUS_REGISTER ESR;
 logic [15:0] DLR;
 
 logic wr;
 logic rd;
 logic empty_tx;
 logic empty_tx_m;  	
 logic empty_tx_m1;  	
 logic empty_tx_m2;  
 logic empty_rx_del;

 logic full_rx;
 logic full_rx_m;	
 logic full_rx_m1;	
 logic full_rx_m2; 	

 logic overrunError;
 logic overrunError_del1;
 logic overrunError_del2;
 logic overrunError_del3;
 
 logic parErr;
 logic parErr_del1; 
 logic parErr_del2;
 logic parErr_del3;
 
 logic StpErr; 
 logic StpErr_del1;
 logic StpErr_del2;
 logic StpErr_del3; 
 
 logic BreakErr;
 logic BreakErr_m; 	
 logic BreakErr_m1;  	
 logic BreakErr_m2;
 
 logic StErr;
 logic StErr_del;
 
 logic [7:0] dout_rx;
 logic [7:0] dout_tx;
 logic rd_tx;
 
 logic TXsig;
 logic en_ctr;
 logic [3:0] ctrW;
 logic str;
 logic parity_tx;
 logic [15:0] ctr_tx;
 logic [7:0] dataTX;

logic [7:0] shiftIN;
logic wr_rx;
logic RXsig;
logic en_ctr_rx;
logic [3:0] ctrW_rx;
logic parity_rx;
logic one_half;
logic str_rx;
logic BreakInd;
logic [15:0] ctr_rx;

logic [15:0] BaudRate; 
logic [7:0]  wrdata;
logic [31:0] addr;
logic [1:0] addr_low;
logic [7:0] RDdata;
logic [2:0] ctr_TxFlush;
logic [2:0] ctr_RxFlush;
logic RxFlush;
logic TxFlush;

 typedef enum{
  idle, st1, st2, st3
  } fsm_state; 
 fsm_state state_tx;

 typedef enum{
  idle_rx, st1_rx, st2_rx, st2_2rx, st_Break_rx
  } fsm_state_rx; 
 fsm_state_rx state_rx;

//Bus Registers Write/Read
 assign wr = CPUctr.req & CPUctr.we & CPUctr.gnt;
 
 assign wrdata = (CPUdat.be == 4'b0001)?  CPUdat.wdata[7:0]:
				 (CPUdat.be == 4'b0010)?  CPUdat.wdata[15:8]:
				 (CPUdat.be == 4'b0100)?  CPUdat.wdata[23:16]:
				 (CPUdat.be == 4'b1000)?  CPUdat.wdata[31:24]: 8'h00;

 assign addr_low = 	(CPUdat.be == 4'b0001)?  2'h0:
					(CPUdat.be == 4'b0010)?  2'h1:
					(CPUdat.be == 4'b0100)?  2'h2:
					(CPUdat.be == 4'b1000)?  2'h3: 2'h0;
					
assign addr = {CPUdat.addr[31 :2], addr_low} - addrBase;	
					
//write registers
 always @(posedge Clk) begin
	if(Rst) begin
		CR <= 0;
		FCR.TxClear <= 0;
		FCR.RxClear <= 0;
		FCR.TxEmpty <= 0;
		ISR  <= 0;	
		DLR  <= 0;
		RxFlush <= 0;
		TxFlush <= 0;
		ESR		<= 0;
		rd 	<= 0;
	end
	else begin 
		rd <= CPUctr.req & !CPUctr.we & CPUctr.gnt;

		if (wr & addr == `defU_CR)  CR  <= wrdata;
		if (wr & addr == `defU_FCR) begin
			FCR.TxClear <= wrdata[4];
			FCR.RxClear <= wrdata[5];
		end
		else begin
			FCR.TxClear <= 0;
			FCR.RxClear <= 0;
		end
		if (wr & addr == `defU_DLL)  DLR[7:0]  <= wrdata;
		if (wr & addr == `defU_DLH)  DLR[15:0] <= wrdata;
	
		if(FCR.TxClear) ctr_TxFlush <= 3'b111;
		else if(ctr_TxFlush > 0) begin
			ctr_TxFlush <= ctr_TxFlush - 1;
			TxFlush <= 1;
		end
		else TxFlush <= 0;

		if(FCR.RxClear) ctr_RxFlush <= 3'b111;
		else if(ctr_RxFlush > 0) begin
			ctr_RxFlush <= ctr_RxFlush - 1;
			RxFlush <= 1;
		end
		else RxFlush <= 0;	
	
		// Tx Empty Interrupt
		empty_tx_m  <= empty_tx;  	
		empty_tx_m1 <= empty_tx_m;  	
		empty_tx_m2 <= empty_tx_m1;  	
		FCR.TxEmpty <= empty_tx_m2;
		if(!FCR.TxEmpty & empty_tx_m2 & CR.TxInt) ISR.TxInt <= 1;
		else if(rd & addr == `defU_ISR) 		      ISR.TxInt <= 0;	

		// Rx not Empty Interrupt
		empty_rx_del <= FCR.RxEmpty;  	
		if(!FCR.RxEmpty & empty_rx_del & CR.RxInt) ISR.RxInt <= 1;
		else if(rd & addr == `defU_ISR) 		       ISR.RxInt <= 0;	


		full_rx_m  <= full_rx;  	
		full_rx_m1 <= full_rx_m;  	
		full_rx_m2 <= full_rx_m1;  	
		FCR.RxFull <= full_rx_m2;

		//LINE STATUS
		//Rx FIFO Overrun
		overrunError_del1 <= overrunError;
		overrunError_del2 <= overrunError_del1;
		overrunError_del3 <= overrunError_del2;
		if(!overrunError_del3 & overrunError_del2) ESR.Ovrn <= 1;
		else if(rd & addr == `defU_ESR) 		       ESR.Ovrn <= 0;	
		
		//Rx Parity Error
		parErr_del1 <= parErr;
		parErr_del2 <= parErr_del1;
		parErr_del3 <= parErr_del2;
		if(!parErr_del3 & parErr_del2) ESR.Prt <= 1;
		else if(rd & addr == `defU_ESR)    ESR.Prt <= 0;	
		
		//Rx Frame Error
		StpErr_del1 <= StpErr;
		StpErr_del2 <= StpErr_del1;
		StpErr_del3 <= StpErr_del2;
		if(!StpErr_del3 & StpErr_del2) ESR.Frm <= 1;
		else if(rd & addr == `defU_ESR)    ESR.Frm <= 0;	
		
		BreakErr_m  <= BreakErr;  	
		BreakErr_m1 <= BreakErr_m;  	
		BreakErr_m2 <= BreakErr_m1;  	
		ESR.Brk 	<= BreakErr_m2;

		StErr_del <= StErr;
		if((!StErr_del & StErr) & CR.ErrInt) ISR.ErrInt <= 1;
		else if(rd & addr == `defU_ISR)          ISR.ErrInt <= 0;	
		
		CPUctr.rvalid <= CPUctr.req;
	    CPUctr.gnt <= CPUctr.req;
	end
 end

 assign FCR.TxComp = (state_tx == idle)? 1'b1 : 1'b0; 

 assign CPUctr.err = 0;

 assign StErr = ESR.Ovrn | ESR.Prt | ESR.Frm;   
 assign Int = ISR.RxInt | ISR.TxInt | ISR.ErrInt ;//| IntTxTrig | IntRxTrig;
 

 //Read registers
 always_comb begin
 
 	if     (addr == `defU_FIFOrx) RDdata <= dout_rx;	
 	else if(addr == `defU_CR)  	  RDdata <= CR;	
	else if(addr == `defU_FCR)    RDdata <= FCR;	
	else if(addr == `defU_TxCntL) RDdata <= TxCnt[7:0];	
	else if(addr == `defU_TxCntH) RDdata <= TxCnt[15:8];	
	else if(addr == `defU_RxCntL) RDdata <= RxCnt[7:0];	
	else if(addr == `defU_RxCntH) RDdata <= RxCnt[15:8];	
	else if(addr == `defU_ISR)    RDdata <= ISR;	
	else if(addr == `defU_ESR)    RDdata <= ESR;	
	else if(addr == `defU_DLL)    RDdata <= DLR[7:0];	
	else if(addr == `defU_DLH)    RDdata <= DLR[15:8];	
	else RDdata <= 0;
 
 end

 assign CPUctr.rdata = {RDdata,RDdata,RDdata,RDdata};
 
generate
if(VENDOR == "Xilinx") begin
// synthesis read_comments_as_HDL on
// FIFOa fifo_tx_inst(
// synthesis read_comments_as_HDL off

//synthesis translate_off 
 asinhFIFOa_sim fifo_tx_inst(
// synthesis translate_on
  .din(wrdata),
  .wr_en(wr & addr == `defU_FIFOtx),
  .wr_clk(Clk),
  .full(FCR.TxFull),
  .wr_data_count(TxCnt),
  .rst(Rst | TxFlush),

  .dout(dout_tx),
  .rd_en(rd_tx),
  .rd_clk(Clk_14MHz),
  .empty(empty_tx),
  .rd_data_count()
); 

end
else if(VENDOR == "IntelFPGA") begin
 FIFOa fifo_tx_inst (
	.data (wrdata),
	.wrreq ( wr & addr == `defU_FIFOtx ),
	.wrclk ( Clk ),
	.wrfull ( FCR.TxFull ),
	.wrusedw ( TxCnt ),
	.aclr ( Rst | TxFlush ),

	.q ( dout_tx ),
	.rdreq ( rd_tx ),
	.rdclk ( Clk_14MHz ),
	.rdempty ( empty_tx ),
	.rdusedw ( )
	);
end
endgenerate
 // assign DatL = (LCR[`defU_DatL] == 0)? 4'h5: 
			   // (LCR[`defU_DatL] == 1)? 4'h6:
		       // (LCR[`defU_DatL] == 2)? 4'h7:
		       // (LCR[`defU_DatL] == 3)? 4'h8: 4'h8;

 // assign Divisor = {DLH, DLL}; 
 // assign Prescaler = ((16 - SCR) + CPR[`defU_CPRN]) << CPR[`defU_CPRM]; 
 assign BaudRate  =	DLR; 

 //TX FSM 
 always @(posedge Clk_14MHz) begin
	if(Rst) begin
		state_tx  <= idle;
		TXsig	  <= 1;
		en_ctr 	  <= 0;
		ctrW	  <= 0;
		rd_tx	  <= 0;
		str 	  = 0; 
		parity_tx <= 0;
	end
	else begin
	
		//butrate counter
		if(en_ctr) begin
			if(ctr_tx == (BaudRate*2 - 1)) begin
				ctr_tx 	<= 0;
				str		= 1;
			end
			else begin
				ctr_tx <= ctr_tx + 1;
				str		= 0;
			end
		end
		else begin
			ctr_tx 	<= 0;
			str		= 0;
		end

		case(state_tx)
			idle: begin
				if(!empty_tx) begin
					TXsig		<= 0; //Start BIT

					dataTX 		<= dout_tx;
					en_ctr 		<= 1;
					rd_tx 		<= 1;
					
					state_tx 	<= st1;
				end
			end
			
			st1: begin
				if(str) begin //Change TX on strobe 
					if(ctrW == 8) begin // 8bit was send, 
						if(CR.PrTp != 0) begin // check if need of parity
							if     (CR.PrTp == 1) TXsig <= !parity_tx;  // Odd parity
							else if(CR.PrTp == 2) TXsig <= parity_tx;   // Even parity
							else if(CR.PrTp == 3) TXsig <= 1'b1;		// Mark
							else if(CR.PrTp == 4) TXsig <= 1'b0;        // Space
							
							state_tx <= st2;
						end
						else begin // send stop bit
							TXsig 	 <= 1;
							state_tx <= st3;
						end
					end
					else begin  // shift data to TX
						TXsig <= dataTX[ctrW];
						parity_tx <= parity_tx~^dataTX[ctrW];
						ctrW <= ctrW + 1;
					end
				end
				en_ctr <= 1;
				rd_tx  <= 0;
			end

			st2: begin  // send stop bit, after parity bit 
				if(str) begin
					TXsig <= 1;
					state_tx <= st3;
				end
				en_ctr <= 1;
			end

			st3: begin 
				if(str) begin
					if(!empty_tx) begin //Send next byte
						dataTX <= dout_tx;
						rd_tx <= 1;							

						TXsig		<= 0;
						en_ctr 		<= 1;
						state_tx 	<= st1;
					end
					else begin //Go to wait data
						en_ctr 	  <= 0;
						state_tx  <= idle;
					end
					ctrW	<= 0;
					parity_tx <= 0;
				end
			end
			default:;
		endcase
	end
 end

 assign TX = TXsig;

generate
if(VENDOR == "Xilinx") begin
// synthesis read_comments_as_HDL on
// FIFOa fifo_rx_inst(
// synthesis read_comments_as_HDL off

//synthesis translate_off 
 asinhFIFOa_sim fifo_rx_inst(
// synthesis translate_on
  .din(shiftIN),
  .wr_en(wr_rx),
  .wr_clk(Clk_14MHz),
  .full(full_rx),
  .wr_data_count(),
  .rst(Rst | RxFlush),

  .dout(dout_rx),
  .rd_en(rd & addr == `defU_FIFOrx),
  .rd_clk(Clk),
  .empty(FCR.RxEmpty),
  .rd_data_count(RxCnt)
); 
end
else if(VENDOR == "IntelFPGA") begin
 FIFOa fifo_rx_inst (
	.data (shiftIN),
	.wrreq ( wr_rx ),
	.wrclk ( Clk_14MHz ),
	.wrfull ( full_rx ),
	.wrusedw ( ),
	.aclr (Rst | RxFlush),

	.q ( dout_rx ),
	.rdreq ( rd & addr == `defU_FIFOrx ),
	.rdclk ( Clk ),
	.rdempty ( FCR.RxEmpty ),
	.rdusedw ( RxCnt )
	);
end
endgenerate

 assign RXsig = (CR.InLoop)? TXsig : RX;

//RX FSM
 always @(posedge Clk_14MHz) begin
	if(Rst) begin
		state_rx 	<= idle_rx;
		en_ctr_rx	<= 0;
		ctrW_rx		<= 0;
		parity_rx	<= 0;
		one_half	<= 1;
		wr_rx		<= 0;
		str_rx		= 0;
		overrunError <= 0;
		parErr	 	<= 0;
		StpErr	 	<= 0;
		BreakInd	<= 0;
		BreakErr 	<= 0;
	end
	else begin
	
		//butrate counter
		if(en_ctr_rx) begin
			if(one_half & ctr_rx == (BaudRate - 1)) begin
				ctr_rx 	<= 0;
				str_rx	= 1;
			end
			else if(!one_half & ctr_rx == (BaudRate*2 - 1)) begin
				ctr_rx 	<= 0;
				str_rx	= 1;
			end
			else begin
				ctr_rx <= ctr_rx + 1;
				str_rx = 0;
			end	
		end
		else begin
			ctr_rx 	<= 0;
			str_rx	= 0;
		end
	
		case(state_rx)
			idle_rx: begin
				if(!RXsig) begin // detect start bit
					en_ctr_rx 	<= 1;
					state_rx 	<= st1_rx;
				end
				wr_rx 	  <= 0;
				parity_rx <= 0;
				one_half  <= 1;
				ctrW_rx	  <= 0;
				overrunError <= 0;
				parErr	 	<= 0;
				StpErr	 	<= 0;
				BreakInd 	<= 0;
			end
			
			st1_rx: begin
				if(str_rx) begin //Check start bit
					one_half <= 0;
					if(!RXsig) state_rx <= st2_rx; 
					else begin // error start bit
						state_rx 	<= idle_rx; 
						en_ctr_rx 	<= 0;
					end
					BreakInd <= BreakInd | RXsig;
				end
			end

			st2_rx: begin 
				if(str_rx) begin //Shift RX data
					if(ctrW_rx == 8) begin  //8 bit RX shift in 
						if(CR.PrTp != 0) begin	// check parity bit
							if     (CR.PrTp == 1 & parity_rx == !RXsig) state_rx <= st2_2rx; // Odd parity
							else if(CR.PrTp == 2 & parity_rx ==  RXsig) state_rx <= st2_2rx; // Even parity
							else if(CR.PrTp == 3 & RXsig == 1'b1)   	state_rx <= st2_2rx; // Mark
							else if(CR.PrTp == 4 & RXsig == 1'b0)   	state_rx <= st2_2rx; // Space			
							else begin //detect parity error
								parErr	 <= 1;
								if(!BreakInd) state_rx <= st_Break_rx;  
								else state_rx <= idle_rx;		
							end
						end
						else if(RXsig) begin // check stop bit
							if(!full_rx) wr_rx <= 1; // data receive  
							else  overrunError <= 1;
							state_rx <= idle_rx;
						end
						else begin
							StpErr	 <= 1;
							if(!BreakInd) state_rx <= st_Break_rx;  
							else state_rx <= idle_rx;						
						end
					end
					else begin
						shiftIN[ctrW_rx] <= RXsig;
						parity_rx <= parity_rx~^RXsig;
						ctrW_rx <= ctrW_rx + 1;
					end
					BreakInd <= BreakInd | RXsig;
				end
			end
			
			st2_2rx: begin
				if(str_rx) begin
					if(RXsig) begin // check stop bit
						if(!full_rx) wr_rx <= 1; // data receive  
						else  overrunError <= 1;
						state_rx <= idle_rx;
					end
					else begin
						StpErr	 <= 1;
						if(!BreakInd) state_rx <= st_Break_rx;  
						else state_rx <= idle_rx;						
					end
				end
			end
			
			st_Break_rx: begin
				if(RXsig) begin
					BreakErr <= 0;
					state_rx <= idle_rx;	
				end
				else BreakErr <= 1;
			end
			default:;
		endcase
	end
 end
 
 endmodule