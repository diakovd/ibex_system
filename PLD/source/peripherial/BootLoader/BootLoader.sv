// This module is debug purpose to load program.hex file in to memory instruction throw UART
// BootLoader listening UART RX line. When recive 32 Stop Byte it set active reset to sysytem
// After this it waiting program.hex file
// Receiving file loading to memory instruction
// When memory is loaded BootLoader wait 32 On Byte and set inactive reset to system 
// UART format |Start bit|8 bit data|Parity Odd Bit|Stop bit|
// BaudRate setting in parameter "BaudRate"
// 9600	 BaudRate = 768
// 14400 BaudRate =	512
// 19200 BaudRate =	384
// 28800 BaudRate =	256
// 38400 BaudRate =	192
// 57600 BaudRate =	128
// 76800 BaudRate =	96
// 115200 BaudRate = 64
// 230400 BaudRate = 32
// 460800 BaudRate = 16
// 921600 BaudRate = 8

`include "../source/defines.sv"
// `include "defines.sv"

 module BootLoader(
	input RX, //RX UART line
		
	DatBus.Master CPUdat,
	CtrBus.Master CPUctr,
		
	output logic Rst_out,
	input Rst,
	input Clk_14MHz,
	input Clk 
 );
 parameter logic [7:0] STPbyte = 8'h55;
 parameter logic [7:0] ONbyte = 8'hAA;
 parameter logic [15:0] BaudRate = 4; 

 logic [4:0] ctrRst;
 logic [1:0] ctrW;
 logic [31:0] StartAddr; //starting adress memory instruction
 logic [31:0] numB; // number of byte to write memory instruction
 logic [31:0] ctrB; // ctr of byte to write memory instruction
 
 typedef enum{
  idle_rx, st1_rx, st2_rx, st2_2rx, st_Break_rx
  } fsm_state_rx; 
 fsm_state_rx state_rx;

 typedef enum{
  idle, st1, st2, st3, st4
  } fsm_state; 
 fsm_state state;

 typedef enum{
  waitRst, waitRst_st1, waitRst_st2, waitOn_st1
  } fsm_stateRst; 
 fsm_stateRst stateRst;

 logic [7:0] shiftIN;
 logic wr_rx;
 logic wr_rx_del;
 logic wr_rx_del1;
 logic wr_rx_del2;
 logic wr_rx_del3;
 logic en_ctr_rx;
 logic [3:0] ctrW_rx;
 logic parity_rx;
 logic one_half;
 logic str_rx;
 logic BreakInd;
 logic [15:0] ctr_rx;
 logic parErr;
 logic StpErr;
 logic wr;
 logic BreakErr;
 logic full_rx;
 logic [7:0] dataRx;
 logic en_dat;
 
 always @(posedge Clk) begin
  if(Rst) begin
	state   <= idle;
	stateRst<= waitRst; 
	ctrRst  <= 0;
	Rst_out <= 0;
	ctrW	<= 0;
	ctrB 	<= 0;
	wr		<= 0;
	StartAddr <= 0;
  end
  else begin

	case(stateRst)
		waitRst : begin
			if(en_dat)begin
				if(dataRx == STPbyte) begin
					stateRst <= waitRst_st1;
					ctrRst <= ctrRst + 1;
				end
				else ctrRst <= 0;
			end
			else ctrRst <= 0;
			Rst_out   <= 0;
		end

		waitRst_st1:begin // wait minimum five Stop Byte
			if(en_dat)begin 
				if(dataRx == STPbyte) begin
					if(ctrRst == 5'b11111) begin
						stateRst  <= waitRst_st2; //five contenisly Stop Byte revived
						ctrRst 	  <= 0;
					end
					else ctrRst <= ctrRst + 1; 
				end
				else stateRst <= waitRst;
			end
		end
		
		waitRst_st2:begin // wait Stop Byte and's
			if(en_dat)begin 
				if(dataRx != STPbyte) begin
					stateRst  <= waitOn_st1; // to wait On Byte
					Rst_out   <= 1;
				end
			end
		end

		waitOn_st1:begin // wait minimum five On Byte
			if(en_dat)begin 
				if(dataRx == ONbyte) begin
					if(ctrRst == 5'b11111) begin
						stateRst  <= waitRst; //five contenisly On Byte revived
						ctrRst <= 0;
					end
					else ctrRst <= ctrRst + 1; 
				end
				else ctrRst <= 0;
			end
		end
	
		default:;
	endcase
	
	
	wr_rx_del  <= wr_rx;
	wr_rx_del1 <= wr_rx_del;
	wr_rx_del2 <= wr_rx_del1;
	wr_rx_del3 <= wr_rx_del2;
	
	if(!wr_rx_del3 & wr_rx_del2) en_dat <= 1;
						   else en_dat <= 0;
	
	case(state)
		idle:begin
			if(Rst_out) begin
				StartAddr[31:24] <= dataRx;
				ctrW  <= ctrW + 1;
				state <= st1;
			end
			ctrB <= 0;
		end
	
		st1:begin
			if(Rst_out) begin
				if(en_dat)begin
					StartAddr <= {dataRx, StartAddr[31:8]};
					
					if(ctrW == 3) begin
						state <= st2;
						ctrW  <= 0;
					end
					else ctrW  <= ctrW + 1;
				end
			end
			else state <= idle;
		end
		
		st2:begin //recive numB adress
			if(Rst_out) begin
				if(en_dat)begin
					numB <= {dataRx, numB[31:8]};
					
					if(ctrW == 3) begin
						state <= st3;
						ctrW  <= 0;
					end
					else ctrW  <= ctrW + 1;
				end
			end
			else state <= idle;
		end

		st3:begin //recive data
			if(Rst_out) begin
				if(en_dat)begin
					if(ctrB < numB) wr   <= 1;
				end
				else wr <= 0;

				if(wr) ctrB <= ctrB + 1;
			end
			else begin
				state <= idle;
				ctrB <= 0;
				wr <= 0;
			end
		end
		
		st4:begin //wait On Byte
			if(!Rst_out) state <= idle;
  		    wr <= 0;
		end

		default:;
	endcase
  end
 end
 
 assign CPUdat.addr = {StartAddr[31 - 2:0],2'b00} + ctrB;
 assign CPUdat.wdata = {dataRx,dataRx,dataRx,dataRx};
 assign CPUctr.we   = wr;
 assign CPUctr.req  = wr;
 assign CPUdat.be[0] = (CPUdat.addr[1:0] == 0)? 1: 0;
 assign CPUdat.be[1] = (CPUdat.addr[1:0] == 1)? 1: 0;
 assign CPUdat.be[2] = (CPUdat.addr[1:0] == 2)? 1: 0;
 assign CPUdat.be[3] = (CPUdat.addr[1:0] == 3)? 1: 0;
 
 //UART RX 
 //RX FSM
 always @(posedge Clk_14MHz) begin
	if(Rst) begin
		state_rx 	<= idle_rx;
		en_ctr_rx	<= 0;
		ctrW_rx		<= 0;
		parity_rx	<= 0;
		one_half	<= 1;
		wr_rx		<= 0;
		str_rx		<= 0;
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
				str_rx	<= 1;
			end
			else if(!one_half & ctr_rx == (BaudRate*2 - 1)) begin
				ctr_rx 	<= 0;
				str_rx	<= 1;
			end
			else begin
				ctr_rx <= ctr_rx + 1;
				str_rx <= 0;
			end	
		end
		else begin
			ctr_rx 	<= 0;
			str_rx	<= 0;
		end
	
		case(state_rx)
			idle_rx: begin
				if(!RX) begin // detect start bit
					en_ctr_rx 	<= 1;
					state_rx 	<= st1_rx;
				end
				else en_ctr_rx 	<= 0;
				wr_rx 	  <= 0;
				parity_rx <= 0;
				one_half  <= 1;
				ctrW_rx	  <= 0;
				parErr	 	<= 0;
				StpErr	 	<= 0;
				BreakInd 	<= 0;
			end
			
			st1_rx: begin
				if(str_rx) begin //Check start bit
					one_half <= 0;
					if(!RX) state_rx <= st2_rx; 
					else begin // error start bit
						state_rx 	<= idle_rx; 
						en_ctr_rx 	<= 0;
					end
					BreakInd <= BreakInd | RX;
				end
				else en_ctr_rx 	<= 1;
			end

			st2_rx: begin 
				if(str_rx) begin //Shift RX data
					if(ctrW_rx == 8) begin  //8 bit RX shift in 
						if(parity_rx == !RX) state_rx <= st2_2rx; // Odd parity
						else begin //detect parity error
							parErr	 <= 1;
							if(!BreakInd) state_rx <= st_Break_rx;  
							else state_rx <= idle_rx;		
						end
					end
					else begin
						shiftIN[ctrW_rx] <= RX;
						parity_rx <= parity_rx~^RX;
						ctrW_rx <= ctrW_rx + 1;
					end
					BreakInd <= BreakInd | RX;
				end
				else en_ctr_rx 	<= 1;
			end
			
			st2_2rx: begin
				if(str_rx) begin
					if(RX) begin // check stop bit
						dataRx <= shiftIN;
						wr_rx <= 1; // data receive  
						state_rx <= idle_rx;
					end
					else begin
						StpErr	 <= 1;
						if(!BreakInd) state_rx <= st_Break_rx;  
						else state_rx <= idle_rx;						
					end
				end
				else en_ctr_rx 	<= 1;
			end
			
			st_Break_rx: begin
				if(RX) begin
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