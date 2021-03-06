
 `include "../source/defines.sv"
 `include "../source/peripherial/Timer/TmrDef.sv"
 //`include "../source/bus_mux/ahb3lite_bus/ahb3lite_bus.sv" 
 // `include "defines.sv"
 // `include "TmrDef.sv"  
 import ahb3lite_pkg::*;
 
 module  Timer
 #(
  parameter BASE 		  	  = 0,  // base addr on bus
  parameter TM_SIZE    		  = 32, //conter bit wigh, max = 32 bit   
  parameter PWM_SIZE 		  = 1, //number of PWM output   
  parameter HADDR_SIZE        = 8,
  parameter HDATA_SIZE        = 32
 )
 (
	ahb3lite_bus.slave  CPUbus,

	input Evnt0,
	input Evnt1,
	input Evnt2,
	output [PWM_SIZE - 1:0] PWM,

	output Int
 );
 
  localparam BE_SIZE    = HDATA_SIZE/8;
  localparam ABITS_LSB  = $clog2(BE_SIZE);


 logic [TM_SIZE - 1:0] TmVal; //Timer Value
 logic [TM_SIZE - 1:0] TmPr;  //Timer Period Value
 logic [TM_SIZE - 1:0] TmPrSh;//This register contains the value for the timer period that is going to be transferred into the Period Value field when the next shadow 
 logic [TM_SIZE - 1:0] TmCap0; //Timer Capture Register
 logic [TM_SIZE - 1:0] TmCap1; //Timer Capture Register
 logic [TM_SIZE - 1:0] TmCap2; //Timer Capture Register
 logic [TM_SIZE - 1:0] TmCap3; //Timer Capture Register
 logic [TM_SIZE - 1:0] TmCmp[PWM_SIZE];  //This register contains the value for the timer comparison.
 logic [TM_SIZE - 1:0] TmCmpSh[PWM_SIZE];//Timer Shadow Compare Value
 logic [TM_SIZE - 1:0] TmC1mC0; //Timer Capture1 minus Capture0 register
 logic [TM_SIZE - 1:0] TmC3mC2; //Timer Capture3 minus Capture2 Register logic TmCmp
 logic [TM_SIZE - 1:0] TmCmpRD;
 
 Timer_Run_Set TRS;
 Timer_Capture_Flags_Status TCFS;
 Timer_Run_Status TRSt;
 Timer_Mode_Setting TMS;
 Event_control_register ECR;
 Connection_Matrix_Control CMC; 
 Interrupt_Status_register ISR;
 Interrupt_Status_register IntCl; //Interrupt Status Clear
 Interrupt_Enable_Control IEC;
 Passive_Level_Config PLC;

 logic TmrEn;
 logic [PWM_SIZE - 1:0] CompMth;
 logic ZeroMth;
 logic PrdMth;
 logic OneMth;
 logic CntDIR_chg;
 logic TmLoad;
 logic TmrClear;
 logic EvStr;
 logic EvStp;
 logic EvGate;
 logic EvCnt;
 logic ClearCap;
 logic EvCap0;// EvCap0;
 logic EvCap1;// EvCap1
 logic wr;
 logic rd;
 logic EvUpDw;
 logic STT; //Shadow transfer trigger
 logic Evnt0LPF = 0; 
 logic Evnt1LPF = 0; 
 logic Evnt2LPF = 0; 
 logic Evnt0LPF_del;
 logic Evnt1LPF_del;
 logic Evnt2LPF_del;
 logic Evnt0Edg;
 logic Evnt1Edg;
 logic Evnt2Edg;
 logic Evnt0Lvl;
 logic Evnt1Lvl;
 logic Evnt2Lvl;
 logic EvCntCapS0;
 logic EvCntCapS1;
 
 logic [2:0] ctrLPF0 = 0;
 logic [2:0] ctrLPF1 = 0;
 logic [2:0] ctrLPF2 = 0;
 
 logic [2:0] numLPF0;
 logic [2:0] numLPF1;
 logic [2:0] numLPF2;
 
 logic Cap0wr;
 logic Cap1wr;
 logic Cap2wr;
 logic Cap3wr;
 
 logic [PWM_SIZE - 1:0] pwmOut;
 logic [PWM_SIZE - 1:0] pwmOut_del;
 logic EvMod;
 logic [PWM_SIZE - 1:0] pwmStp;
 
 logic [9:0] addr; 
 logic [31:0] addrNoB; 
 
 int j,k,m,f,i;
 
 //Bus Registers Write/Read
 always @(posedge CPUbus.HCLK)
    if (CPUbus.HREADY) wr <= CPUbus.HSEL & CPUbus.HWRITE & (CPUbus.HTRANS != HTRANS_BUSY) & (CPUbus.HTRANS != HTRANS_IDLE);
    else         wr <= 1'b0;

 always @(posedge CPUbus.HCLK)
    if (CPUbus.HREADY) rd <= CPUbus.HSEL & ~CPUbus.HWRITE & (CPUbus.HTRANS != HTRANS_BUSY) & (CPUbus.HTRANS != HTRANS_IDLE);
    else               rd <= 1'b0;
 
   //store write address
 always @(posedge CPUbus.HCLK)
    if (CPUbus.HREADY) begin
		addrNoB =  CPUbus.HADDR - BASE;
		addr 	<= addrNoB[HADDR_SIZE - 1 : ABITS_LSB];
	end
 //AHB bus response
 assign CPUbus.HRESP = HRESP_OKAY; //always OK
 assign CPUbus.HREADYOUT = 1'b1;
 
 always@ (posedge CPUbus.HCLK) begin
	if(!CPUbus.HRESETn)	begin
	   TmPr  	<= 0;
	   TmPrSh 	<= 0;
	   TRS 		<= 0;
	   TMS 		<= 0;
	   ECR 		<= 0;
	   CMC 		<= 0;
	   IEC 		<= 0;
	   TCFS.C0Full <= 0;
	   TCFS.C1Full <= 0;
	   TCFS.C2Full <= 0;
	   TCFS.C3Full <= 0;
	   PLC		<= 0;	
	   
	   for (m = 0; m < PWM_SIZE; m++) begin	
		   TmCmp[m] 	<= 0;
		   TmCmpSh[m]	<= 0;	   
	   end
	end
	else begin
		if (wr) begin
			if(addr == `dTmPr) 				     TmPr <= CPUbus.HWDATA[TM_SIZE-1:0];
			else if(!TRSt.TR & addr == `dTmPrSh) TmPr <= CPUbus.HWDATA[TM_SIZE-1:0];	
		end
		else if(TRSt.TR & STT) TmPr <= TmPrSh; // Timer shadow trasfer

		if (wr & addr == `dTmPrSh) TmPrSh	<= CPUbus.HWDATA[TM_SIZE-1:0];
		
		for (j = 0; j < PWM_SIZE; j++) begin
				if (wr) begin
					if(addr == (`dTmCmp + 2*j)) 		  		 TmCmp[j] <= CPUbus.HWDATA[TM_SIZE-1:0];
					else if(!TRSt.TR & addr == (`dTmCmpSh+ 2*j)) TmCmp[j] <= CPUbus.HWDATA[TM_SIZE-1:0];
				end
				else if(TRSt.TR & STT) TmCmp[j] <= TmCmpSh[j]; 
				
				if (wr & addr == (`dTmCmp + 2*j + 1)) TmCmpSh[j] <= CPUbus.HWDATA[TM_SIZE-1:0];
		 end

		if (wr & addr == `dTRS) TRS <= CPUbus.HWDATA;
								  else TRS <= 0;

		if (wr & addr == `dTMS) TMS <= CPUbus.HWDATA;

		if (wr & addr == `dECR) ECR <= CPUbus.HWDATA;

		if (wr & addr == `dCMC) CMC <= CPUbus.HWDATA;

		if (wr & addr == `dIEC) IEC <= CPUbus.HWDATA;

		if (wr & addr == `dISC) IntCl <= CPUbus.HWDATA;
		else IntCl <= 0;

		if (wr & addr == `dPLC) PLC <= CPUbus.HWDATA;
		
		if(Cap0wr) 					   TCFS.C0Full <= 1;
		else if(rd & addr == `dTmCap0) TCFS.C0Full <= 0;

		if(Cap1wr) 					   TCFS.C1Full <= 1;
		else if(rd & addr == `dTmCap1) TCFS.C1Full <= 0;

		if(Cap2wr) 						TCFS.C2Full <= 1;
		else if(rd & addr == `dTmCap2) TCFS.C2Full <= 0;

		if(Cap3wr) 					   TCFS.C3Full <= 1;
		else if(rd & addr == `dTmCap3) TCFS.C3Full <= 0;

	end
 end
 

 
 always_comb begin
 
	if     (addr == `dTmVal)  CPUbus.HRDATA <= TmVal;	
	else if(addr == `dTmPr)   CPUbus.HRDATA <= TmPr;	
	else if(addr == `dTmPrSh) CPUbus.HRDATA <= TmPrSh;	
	else if(addr == `dTmCap0) CPUbus.HRDATA <= TmCap0;	
	else if(addr == `dTmCap1) CPUbus.HRDATA <= TmCap1;	
	else if(addr == `dTmCap2) CPUbus.HRDATA <= TmCap2;	
	else if(addr == `dTmCap3) CPUbus.HRDATA <= TmCap3;	
	else if(addr == `dTRS)    CPUbus.HRDATA <= TRS;	
	else if(addr == `dTCFS)   CPUbus.HRDATA <= TCFS;	
	else if(addr == `dTRSt)   CPUbus.HRDATA <= TRSt;	
	else if(addr == `dTMS)    CPUbus.HRDATA <= TMS;	
	else if(addr == `dECR)    CPUbus.HRDATA <= ECR;
	else if(addr == `dCMC) 	  CPUbus.HRDATA <= CMC;
	else if(addr == `dISR)    CPUbus.HRDATA <= ISR;
	else if(addr == `dIEC)    CPUbus.HRDATA <= IEC;
	else if(addr == `dPLC)    CPUbus.HRDATA <= PLC;
	else if(addr == `dTmC1mC0)CPUbus.HRDATA <= TmC1mC0;	
	else if(addr == `dTmC3mC2)CPUbus.HRDATA <= TmC3mC2;	
	else if(addr >= `dTmCmp)  CPUbus.HRDATA <= TmCmpRD;
	else CPUbus.HRDATA <= 0; 	

	for (k = 0; k < PWM_SIZE; k++) begin
		if(addr == (`dTmCmp + 2*k)) TmCmpRD <= TmCmp[k];
		else if (addr == (`dTmCmp + 2*k + 1)) TmCmpRD <=  TmCmpSh[k];
		else TmCmpRD <= 0; 
	end	
	
 end
 
 
 always_comb begin

	for (f = 0; f < PWM_SIZE; f++) begin
		if(TmVal == TmCmp[f]) CompMth[f] = 1; // Timer Compare match		
						 else CompMth[f] = 0;
	end	
	
	if(TmVal == 0) ZeroMth = 1; // Timer Zero match 		
			  else ZeroMth = 0;
	 
	if(TmVal == TmPr) PrdMth = 1; // Timer Period match
				 else PrdMth = 0;
								   
	if(TmVal == 1) OneMth = 1;  // Timer one match 
			  else OneMth = 0;	
			  
	//Up/Down Functionality Selector	
	if(TMS.TCM)  TRSt.TCD <= CntDIR_chg;
	else TRSt.TCD <= EvUpDw; //External Up/Down				  
			  
	//Shadow transfer trigger
	if((PrdMth & !TRSt.TCD) | (ZeroMth & TRSt.TCD) | !TRSt.TR)  STT = 1;  //Shadow transfer trigger // (CC4yTIMER.TVAL == 0)
	else STT = 0;	

 end	
	
 assign Cap0wr = (TMS.CCE)? EvCap0 :
				 (!(TCFS.C0Full & TCFS.C1Full))? EvCap0 : 0;	

 assign Cap1wr = (TMS.CCE & TCFS.C0Full)? EvCap0 :
				 (!TMS.CCE & (TCFS.C0Full & !TCFS.C1Full))? EvCap0 : 0;	

 assign Cap2wr = (TMS.CCE)? EvCap1 :
				 (!(TCFS.C2Full & TCFS.C3Full))? EvCap1 : 0;	

 assign Cap3wr = (TMS.CCE & TCFS.C2Full)? EvCap1 :
				 (!TMS.CCE & (TCFS.C2Full & !TCFS.C3Full))? EvCap1 : 0;	

	
 always@ (posedge CPUbus.HCLK) begin
	if(!CPUbus.HRESETn)	begin
		ISR  <= 0;
		TmCap0 <= 0;		 
		TmCap1 <= 0;		 
		TmCap2 <= 0;		 
		TmCap3 <= 0;
		TmC1mC0	<= 0;	 
		TmC3mC2	<= 0;	 
	end
	else begin
		
		//External Capture
		if(CMC.CntCapS0 == 0) begin // capture mode
			if (Cap0wr) TmCap0 <= TmVal; 
			if (Cap1wr) TmCap1 <= TmCap0;
		end
		else begin // count external event into capture 0 - 1 register
			if(TRSt.TR & PrdMth) begin // clear TmCap0 and save TmCap0 value to TmCap1
				TmCap1 <= TmCap0;
				TmCap0 <= 0;
			end
			else if(EvCntCapS0) TmCap0 <= TmCap0 + 1; 
		end
		if(CMC.CntCapS1 == 0) begin  // capture mode
			if (Cap2wr) TmCap2 <= TmVal; 
			if (Cap3wr) TmCap3 <= TmCap2; 
		end
		else begin // count external event into capture 2 - 3 register
			if(TRSt.TR & PrdMth) begin // clear TmCap2 and save TmCap2 value to TmCap3
				TmCap3 <= TmCap2;
				TmCap2 <= 0;
			end
			else if(EvCntCapS1) TmCap2 <= TmCap2 + 1;
		end
		
		if(TmCap1 <= TmCap0) TmC1mC0 <= TmCap0 - TmCap1;
		else TmC1mC0 <= TmPr + TmCap0 - TmCap1 + 1;

		if(TmCap3 <= TmCap2) TmC3mC2 <= TmCap2 - TmCap3;
		else TmC3mC2 <= TmPr + TmCap2 - TmCap3 + 1;
		
		//Interrupt Request Generation
		if(IEC.Ev2DSEn & Evnt2Edg) ISR.Ev2DS = 1; // Event 1 Detection Status
		else if(IntCl.Ev2DS) 	   ISR.Ev2DS = 0; 

		if(IEC.Ev1DSEn & Evnt1Edg) ISR.Ev1DS = 1; // Event 1 Detection Status
		else if(IntCl.Ev1DS) 	   ISR.Ev1DS = 0; 

		if(IEC.Ev0DSEn & Evnt0Edg) ISR.Ev0DS = 1; // Event 0 Detection Status
		else if(IntCl.Ev0DS) 	   ISR.Ev0DS = 0; 

		if(IEC.CMdwEn & (TmrEn & CompMth &  TRSt.TCD)) ISR.CMdw = 1; // Compare Match while Counting Down
		else if(IntCl.CMdw) 					 	   ISR.CMdw = 0; 

		if(IEC.CMupEn & (TmrEn & CompMth & !TRSt.TCD)) ISR.CMup = 1; // Compare Match while Counting Up
		else if(IntCl.CMup)  					       ISR.CMup = 0; 

		if(IEC.OMdwEn & (TmrEn & OneMth &  TRSt.TCD)) ISR.OMdw = 1; //One Match while Counting Down
		else if(IntCl.OMdw) 	 				      ISR.OMdw = 0; 

		if(IEC.PMupEn & (TmrEn & PrdMth & !TRSt.TCD)) ISR.PMup = 1; // Period Match while Counting Up
		else if(IntCl.PMup) 	 					  ISR.PMup = 0;	
	end
 end
 
 assign Int = ISR.Ev2DS | ISR.Ev1DS | ISR.Ev0DS | ISR.CMdw | ISR.CMup | ISR.OMdw | ISR.PMup; 
 
 //Low Pass Filter for Event 0 - 2 
 always@(posedge CPUbus.HCLK) begin
	if (!CPUbus.HRESETn) begin
		Evnt0LPF	<= 0;
		Evnt1LPF	<= 0;
		Evnt2LPF	<= 0;
		ctrLPF0 	<= 0;
		ctrLPF1 	<= 0;
		ctrLPF2 	<= 0;
	end
	else begin
		//Low Pass Filter Event 0
		if(ECR.E0FC == 0)      numLPF0 = 0; 
		else if(ECR.E0FC == 1) numLPF0 = 3;
		else if(ECR.E0FC == 2) numLPF0 = 5;
		else if(ECR.E0FC == 3) numLPF0 = 7;		
		
		if(Evnt0 != Evnt0LPF) begin
			if(ctrLPF0 == numLPF0) begin
				Evnt0LPF <= Evnt0; 
				ctrLPF0 <= 0;
			end
			else ctrLPF0 <= ctrLPF0 + 1; // count filter delay when input changed 	
		end
		else ctrLPF0 <= 0; // clear ctr when input = output

		//Low Pass Filter Event 2
		if(ECR.E1FC == 0)      numLPF1 = 0; 
		else if(ECR.E1FC == 1) numLPF1 = 3;
		else if(ECR.E1FC == 2) numLPF1 = 5;
		else if(ECR.E1FC == 3) numLPF1 = 7;		

		if(Evnt1 != Evnt1LPF) begin
			if(ctrLPF1 == numLPF1) begin
				Evnt1LPF <= Evnt1; 
				ctrLPF1 <= 0;
			end
			else ctrLPF1 <= ctrLPF1 + 1; // count filter delay when input changed 	
		end
		else ctrLPF1 <= 0; // clear ctr when input = output

		//Low Pass Filter Event 3
		if(ECR.E2FC == 0)      numLPF2 = 0; 
		else if(ECR.E2FC == 1) numLPF2 = 3;
		else if(ECR.E2FC == 2) numLPF2 = 5;
		else if(ECR.E2FC == 3) numLPF2 = 7;	
		
		if(Evnt2 != Evnt2LPF) begin
			if(ctrLPF2 == numLPF2) begin
				Evnt2LPF <= Evnt2; 
				ctrLPF2 <= 0;
			end
			else ctrLPF2 <= ctrLPF2 + 1; // count filter delay when input changed 	
		end
		else ctrLPF2 <= 0; // clear ctr when input = output
	end	
 end     
 
 //Configures the edge or level 
 always@(posedge CPUbus.HCLK) begin
	if(!CPUbus.HRESETn) begin
		Evnt0Edg <= 0;
		Evnt1Edg <= 0;
		Evnt2Edg <= 0;
		
		Evnt0Lvl <= 0;
		Evnt1Lvl <= 0;
		Evnt2Lvl <= 0;
	end
	else begin
		Evnt0LPF_del <= Evnt0LPF;
		Evnt1LPF_del <= Evnt1LPF;
		Evnt2LPF_del <= Evnt2LPF;
	
		if      (ECR.E0ES == 0) Evnt0Edg <= 0;// No action
		else if (ECR.E0ES == 1) Evnt0Edg <= Evnt0LPF & !Evnt0LPF_del; // Signal active on rising edge
		else if (ECR.E0ES == 2) Evnt0Edg <= !Evnt0LPF & Evnt0LPF_del; // Signal active on falling edge
		else if (ECR.E0ES == 3) Evnt0Edg <= (Evnt0LPF & !Evnt0LPF_del)|(!Evnt0LPF & Evnt0LPF_del); // Signal active on both edges

		if      (ECR.E1ES == 0) Evnt1Edg <= 0;// No action
		else if (ECR.E1ES == 1) Evnt1Edg <= Evnt1LPF & !Evnt1LPF_del; // Signal active on rising edge
		else if (ECR.E1ES == 2) Evnt1Edg <= !Evnt1LPF & Evnt1LPF_del; // Signal active on falling edge
		else if (ECR.E1ES == 3) Evnt1Edg <= (Evnt1LPF & !Evnt1LPF_del)|(!Evnt1LPF & Evnt1LPF_del); // Signal active on both edges

		if      (ECR.E2ES == 0) Evnt2Edg <= 0;// No action
		else if (ECR.E2ES == 1) Evnt2Edg <= Evnt2LPF & !Evnt2LPF_del; // Signal active on rising edge
		else if (ECR.E2ES == 2) Evnt2Edg <= !Evnt2LPF & Evnt2LPF_del; // Signal active on falling edge
		else if (ECR.E2ES == 3) Evnt2Edg <= (Evnt2LPF & !Evnt2LPF_del)|(!Evnt2LPF & Evnt2LPF_del); // Signal active on both edges

		if      (ECR.E0LS == 0) Evnt0Lvl <= Evnt0LPF;// Active on HIGH level
		else if (ECR.E0LS == 1) Evnt0Lvl <= !Evnt0LPF;// Active on LOW level

		if      (ECR.E1LS == 0) Evnt1Lvl <= Evnt1LPF;// Active on HIGH level
		else if (ECR.E1LS == 1) Evnt1Lvl <= !Evnt1LPF;// Active on LOW level

		if      (ECR.E2LS == 0) Evnt2Lvl <= Evnt2LPF;// Active on HIGH level
		else if (ECR.E2LS == 1) Evnt2Lvl <= !Evnt2LPF;// Active on LOW level
		
	end
 end 
 
 assign ClearCap = (TMS.CCC == 0)? 0 :
				   (TMS.CCC == 1)? Cap0wr | Cap2wr :
				   (TMS.CCC == 2)? Cap1wr | Cap3wr :
				   (TMS.CCC == 3)? Cap0wr | Cap2wr | Cap1wr | Cap3wr : 0;

 assign EvStr = (CMC.StrtS == 0)?  0 :
			    (CMC.StrtS == 1)? Evnt0Edg :
			    (CMC.StrtS == 2)? Evnt1Edg :
			    (CMC.StrtS == 3)? Evnt2Edg : 0;

 assign EvStp = (CMC.StpS == 0)?  0 :
			    (CMC.StpS == 1)? Evnt0Edg :
			    (CMC.StpS == 2)? Evnt1Edg :
			    (CMC.StpS == 3)? Evnt2Edg : 0;

 assign EvGate = (CMC.GatS == 0)?  0 :
			     (CMC.GatS == 1)? Evnt0Lvl :
			     (CMC.GatS == 2)? Evnt1Lvl :
			     (CMC.GatS == 3)? Evnt2Lvl : 0;

 assign EvCnt = (CMC.CntS == 0)?  0 :
			    (CMC.CntS == 1)? Evnt0Edg :
			    (CMC.CntS == 2)? Evnt1Edg :
			    (CMC.CntS == 3)? Evnt2Edg : 0;
				
 assign EvCap0 = (CMC.CapS0 == 0)?  0 :
			     (CMC.CapS0 == 1)? Evnt0Edg :
			     (CMC.CapS0 == 2)? Evnt1Edg :
			     (CMC.CapS0 == 3)? Evnt2Edg : 0;

 assign EvCap1 = (CMC.CapS1 == 0)?  0 :
			     (CMC.CapS1 == 1)? Evnt0Edg :
			     (CMC.CapS1 == 2)? Evnt1Edg :
			     (CMC.CapS1 == 3)? Evnt2Edg : 0;				

 assign EvCntCapS0 = (CMC.CntCapS0 == 0)?  0 :
					 (CMC.CntCapS0 == 1)? Evnt0Edg :
					 (CMC.CntCapS0 == 2)? Evnt1Edg :
					 (CMC.CntCapS0 == 3)? Evnt2Edg : 0;

 assign EvCntCapS1 = (CMC.CntCapS1 == 0)?  0 :
					 (CMC.CntCapS1 == 1)? Evnt0Edg :
					 (CMC.CntCapS1 == 2)? Evnt1Edg :
					 (CMC.CntCapS1 == 3)? Evnt2Edg : 0;
				
 assign EvUpDw = (CMC.UpDwS == 0)?  0 :
			     (CMC.UpDwS == 1)? Evnt0Lvl :
			     (CMC.UpDwS == 2)? Evnt1Lvl :
			     (CMC.UpDwS == 3)? Evnt2Lvl : 0;

 assign TmLoad = (CMC.LdS == 0)?  0 :
			     (CMC.LdS == 1)? Evnt0Edg :
			     (CMC.LdS == 2)? Evnt1Edg :
			     (CMC.LdS == 3)? Evnt2Edg : 0; 

 assign EvMod = (CMC.MdlS == 0)?  0 :
			    (CMC.MdlS == 1)? Evnt0Lvl :
			    (CMC.MdlS == 2)? Evnt1Lvl :
			    (CMC.MdlS == 3)? Evnt2Lvl : 0; 
 
 assign TmrClear = TRS.TC | (EvStr & TMS.StrFC) | (EvStp & TMS.StpFC[0]) | (EvStp & TMS.StpFC[1]) | ClearCap; // Clear timer

 assign	TmrEn = (CMC.GatS != 0)? EvGate :    //External Gate Functionality enabled
				(CMC.CntS != 0)? EvCnt  : 1; //External Count enabled


 always@ (posedge CPUbus.HCLK) begin
	if(!CPUbus.HRESETn) begin
		TRSt.bit31_2 <= 0;	
		TRSt.TR 	 <= 0;		
		TmVal 		 <= 0;
		CntDIR_chg   <= 0;
	end
	else begin
	 //Starting/Stopping, Clear the Timer //////////////////////
		if(TRS.RS | EvStr) TRSt.TR = 1;
		else if(TRS.RC | //stop by software
				(EvStp & !TMS.StpFC[0]) | //stop from external event
				((TmrEn & ZeroMth & !TMS.TCM) & TMS.SShM) |  // stop in singl shot mode whith Edge aligned mode  
				((TmrEn & ZeroMth & TRSt.TCD) & TMS.SShM))   // stop in singl shot mode whith Center aligned mode 
			TRSt.TR = 0;	

	 // TIMER	
		if(TmrClear) begin 
			if (TRSt.TCD) TmVal <= TmPr; // count down set to period 
					 else TmVal <= 0;	// count up set to zero
		end
		else if(TRSt.TR) begin // TIMER ON
			if(TmLoad) begin //External Timer Load Functionality 
				if(TRSt.TCD) TmVal <= TmPr; 
						else TmVal <= TmCmp[0];
			end
			else if(TmrEn) begin // & FTClk
				if(ZeroMth &  TRSt.TCD) begin //(TmVal == 0) zero math and count down
					if(TMS.TCM) begin //Center aligned mode
						CntDIR_chg <= 0;
						TmVal <= TmVal + 1;
					end
					else TmVal <= TmPr; //Edge aligned mode
				end
				else if(PrdMth &  !TRSt.TCD) begin // Period match and cont up      // (TmVal ==  TmPr - 1)  
					if(TMS.TCM) begin //Center aligned mode
						CntDIR_chg <= 1;  		
						TmVal <= TmVal - 1;
					end
					else TmVal <= 0; //Edge aligned mode
				end
				else begin
						if(TRSt.TCD) TmVal <= TmVal - 1; // Timer is counting down
								else TmVal <= TmVal + 1; // Timer is counting up
				end	
			end
		end 
		
		//PWM output generation (compare mode)
		for (i = 0; i < PWM_SIZE; i++) begin
			if(TRSt.TR) begin
				if(pwmStp[i]) begin // modulation event is used to clear
					pwmOut[i] = 0; 
				end
				else if(TmrEn) begin 
					if(TMS.TCM) begin
						if (CompMth[i])  pwmOut[i] = !pwmOut[i];
						else if(ZeroMth) pwmOut[i] = 0;
					end
					else begin
						if(TRSt.TCD) begin
							if (CompMth[i])  pwmOut[i] = 0;
							else if(ZeroMth) pwmOut[i] = 1;
						end
						else begin
							if (CompMth[i]) pwmOut[i] = 1;
							else if(PrdMth) pwmOut[i] = 0;
						end
					end
				end
			end
			else begin
				if(TmVal > TmCmp[i]) pwmOut[i] = 1;		
							    else pwmOut[i] = 0;
			end	
		
			//External Modulation Synchronization
			pwmOut_del[i] <= pwmOut[i];
			if(TMS.EMS) begin //synchronized with the PWM signal
				if(EvMod & (!pwmOut[i] & pwmOut_del[i])) pwmStp[i] = 1;
				else if(!EvMod) pwmStp[i] = 0;
			end
			else begin
				if(EvMod) pwmStp[i] = 1; //not synchronized
				else pwmStp[i] = 0; 
			end
		end

	end
 end
 
 //OUTPUT	
 generate
	genvar z;
	for (z = 0; z < PWM_SIZE; z++) begin :PWMout
		assign PWM[z] = (PLC.OPL[z])? !pwmOut[z] : pwmOut[z];	
	end
 endgenerate
 
 endmodule