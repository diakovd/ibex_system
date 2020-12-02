 `include "D:/Work/test_pr/ibex-sys/PLD/source/defines.sv"
 `include "D:/Work/test_pr/ibex-sys/PLD/source/peripherial/Timer/TmrDef.sv"
   
  module Timer_tb;


 DatBus CPUdat();
 CtrBus CPUctr();	 
 
 logic Evnt0;
 logic Evnt1;
 logic Evnt2;
 logic PWM;

 logic Int;
 logic Rst;
 logic Clk;
 
 logic [31:0] RDdata;
 logic [31:0] TMS;
 logic [31:0] IEC;
 logic [31:0] ISC;
 logic [31:0] ECR;
 logic [31:0] CMC;
 
 int i;
 
 task busWR32;
	input [31:0] adr;
	input [31:0] dat;
 begin
	@(posedge Clk);
	CPUdat.wdata = dat;
	CPUdat.addr = adr;
	CPUctr.req = 1;  
	CPUctr.we  = 1;
	CPUdat.be  = 4'b1111;
	
	@(posedge Clk);

	while(!CPUctr.gnt) @(posedge Clk);
	CPUdat.wdata = 0;
	CPUdat.addr = 0;
	CPUctr.req = 0;  
	CPUctr.we  = 0;
	CPUdat.be  = 4'b0000;
 end 
 endtask
 
 task busRD32;
	input [13:0] adr;
 begin
	@(posedge Clk);
	CPUdat.wdata = 0;
	CPUdat.addr = adr;
	CPUctr.req = 1;  
	CPUctr.we  = 0;
	CPUdat.be  = 4'b1111;
	
	@(posedge Clk);

	while(!CPUctr.gnt) @(posedge Clk);
	CPUdat.wdata = 0;
	CPUdat.addr = 0;
	CPUctr.req = 0;  
	CPUctr.we  = 0;	
	
	while(!CPUctr.rvalid) @(posedge Clk);
	RDdata = CPUctr.rdata;
	CPUdat.be  = 4'b1111;
 end 
 endtask 
 
 
 //Tasks to test Timers function
 task fun_Timer_tst; // testing sa Timer/Capture/Counter
 begin
	
	//Write period val
	busWR32(`dTmPr,32'h000000ff);
	busWR32(`dTmPrSh,32'h000000ff);

	//Set Interrupt 
	IEC = 0;	
	//IEC = 1'b1; //Period match
	// IEC = IEC | (1'b1 << 1); //One match
	// IEC = IEC | (1'b1 << 2); //Compare Match while Counting Up
	// IEC = IEC | (1'b1 << 3); //Compare Match while Counting Down
	IEC = IEC | (1'b1 << 4); //Event 0 Detection Status
	// IEC = IEC | (1'b1 << 5); //Event 1 Detection Status
	IEC = IEC | (1'b1 << 6); //Event 2 Detection Status
	
	busWR32(`dIEC, IEC);
	
	//Set Timer mode
	TMS = 1'b0; //Set TCM Center aligned mode
	//TMS = TMS | (1'b1 << 1); //Single shot mode
	TMS = TMS | (2'b11 << 4); //Clear on Capture Control
	//TMS = TMS | (2'b00 << 6); //Extended Stop Function Control
	//TMS = TMS | (1'b0 << 8); //Extended Start Function Control
	//TMS = TMS | (1'b1 << 9); //Continuous Capture Enable
	busWR32(`dTMS, TMS); 

	//Event control
	ECR =  2'b01; //Event 0 Edge Selection
	ECR = ECR | (2'b01 << 2); //Event 1 Edge Selection
	ECR = ECR | (2'b01 << 4); //Event 2 Edge Selection
	ECR = ECR | (1'b1 << 6); //Event 0 Level Selection
	ECR = ECR | (1'b1 << 7); //Event 1 Level Selection
	ECR = ECR | (1'b1 << 8); //Event 2 Level Selection
	ECR = ECR | (2'b11 << 9);  // Event 0 Low Pass Filter Configuration
	ECR = ECR | (2'b11 << 11); // Event 1 Low Pass Filter Configuration
	ECR = ECR | (2'b11 << 13); // Event 2 Low Pass Filter Configuration
	
	busWR32(`dECR, ECR); 
	
	//Connection Matrix Control
	CMC = 0;
//	CMC =  CMC | 2'b11; //StrtS to Event0-2
//	CMC =  CMC | (2'b10 << 2); //EvStp to Event0-2
	CMC =  CMC | (2'b01 << 4); //CapS0 to Event0-2
	CMC =  CMC | (2'b11 << 6); //CapS1 to Event0-2
//	CMC =  CMC | (2'b10 << 8); //GatS to Event0-2
//	CMC =  CMC | (2'b01 << 10); //UpDwS to Event0-2
//	CMC =  CMC | (2'b10 << 12); //LdS to Event0-2
//	CMC =  CMC | (2'b01 << 14); //CntS to Event0-2
	busWR32(`dCMC, CMC); 

	//Set Timer Run Bist
	busWR32(`dTRS, 32'h00000001);
	
	@(posedge Clk);
	busRD32(`dTRSt); //Read Timer Run Status
	
	while(1) begin
		//wait Int
		while(!Int) @(posedge Clk);
		busRD32(`dISR);

		//Clear Interrupt
		if(RDdata & 32'h1) busWR32(`dISC, 1'b1); //Period match Clear Interrupt 
		else if(RDdata & 32'h2) busWR32(`dISC, (1'b1 << 1)); //One Match Clear Interrupt 
		else if(RDdata & 32'h4) busWR32(`dISC, (1'b1 << 2)); //Compare Match Up Clear Interrupt 
		else if(RDdata & 32'h8) busWR32(`dISC, (1'b1 << 3)); //Compare Match Down Clear Interrupt 
		else if(RDdata & 32'h10) begin
			busWR32(`dISC, (1'b1 << 4)); //Event 0 to cap0 1
			busRD32(`dTCFS);
		//	if(RDdata & 32'h2) 		busRD32(`dTmCap1); 
		//	else if(RDdata & 32'h1)  busRD32(`dTmCap0);
		end
		else if(RDdata & 32'h20) busWR32(`dISC, (1'b1 << 5)); //Event 1
		else if(RDdata & 32'h40) begin
			busWR32(`dISC, (1'b1 << 6)); //Event 2 to cap2 3
			busRD32(`dTCFS);
		//	if(RDdata & 32'h8) 		busRD32(`dTmCap3); 
		//	else if(RDdata & 32'h4)  busRD32(`dTmCap2);
		end

		
		@(posedge Clk);
		busRD32(`dTRSt); //Read Timer Run Status
		
		//Set Timer Run Bit
		//busWR32(`dTRS, 32'h00000001);		
		
		//Clear Timer Run Bit
		//busWR32(`dTRS, 32'h00000002);

		//busRD32(`dTmVal);
		//if(RDdata != 0) busWR32(`dTRS, 32'h00000004); //Clear Timer 
	end

 end 
 endtask 

 task fun_Compare_tst; // testing Compare mode 
 begin

	//Write period val
	busWR32(`dTmPr,32'h000000ff);
	busWR32(`dTmPrSh,32'h000000ff);
	//Write period val
	busWR32(`dTmCmp,  32'h0000007f);
	busWR32(`dTmCmpSh,32'h0000007f);

	//Set Timer mode
	TMS = 1'b1; //Set TCM Center aligned mode
	TMS = TMS | (1'b0 << 10); //External Modulation Synchronization
	busWR32(`dTMS, TMS); 

	//Event control
	ECR =  2'b00; //Event 0 Edge Selection
	ECR = ECR | (2'b01 << 2); //Event 1 Edge Selection
	busWR32(`dECR, ECR); 
	
	//Connection Matrix Control
	CMC = 0;
	CMC =  CMC | (2'b10 << 16); //External Modulation Functionality Selector
	busWR32(`dCMC, CMC); 
	
	//Set Interrupt 
	IEC = 0;	
	IEC = IEC | (1'b1 << 2); //Compare Match while Counting Up
	IEC = IEC | (1'b1 << 3); //Compare Match while Counting Down
	IEC = IEC | (1'b1 << 5); //Event 1 Detection Status
	busWR32(`dIEC, IEC);	
	
	//Passive Level Config
	busWR32(`dPLC,1'b0);

	//Set Timer Run Bist
	busWR32(`dTRS, 32'h00000001);
	
	while(1) begin
		//wait Int
		while(!Int) @(posedge Clk);
		busRD32(`dISR);	
		
		//Clear Interrupt
		if     (RDdata & 32'h4) busWR32(`dISC, (1'b1 << 2)); //Compare Match Up Clear Interrupt 
		else if(RDdata & 32'h8) busWR32(`dISC, (1'b1 << 3)); //Compare Match Down Clear Interrupt 
		else if(RDdata & 32'h20) busWR32(`dISC, (1'b1 << 5)); //Event 1
	end
	
 end 
 endtask 
 
 Timer Timer_inst(
	.CPUdat(CPUdat),
	.CPUctr(CPUctr),

	.Evnt0(Evnt0),
	.Evnt1(Evnt1),
	.Evnt2(Evnt2),
	.PWM(PWM),
	
	.Int(Int),
	.Rst(Rst),
	.Clk(Clk)
 );

 initial begin 
	CPUdat.wdata = 0;
	CPUdat.addr = 0;
	CPUctr.req = 0;  
	CPUctr.we  = 0;
	CPUdat.be  = 4'b0000;

 	#100;
	@(posedge Clk);

	fun_Timer_tst();
//	fun_Compare_tst();
	
	
 end

 initial begin // clk64
	#14 Clk = 1;
	forever  #8 Clk = ~Clk;
 end
	 
 initial begin
	Evnt0 = 0;
	Evnt1 = 0;
	Evnt2 = 0; 
	Rst   = 1;

	#100;
	Rst = 0;

	#15000;
	for(i = 0; i < 10; i = i + 1) begin
		Evnt0 = 1;
		#1000;
		Evnt0 = 0;	
		#1000;
	end
	
	#21000; //compare tst
	Evnt1 = 1;
	#15000;
	Evnt1 = 0;	

	// for(i = 0; i < 10; i = i + 1) begin //timer test
		// Evnt1 = 1;
		// #1000;
		// Evnt1 = 0;	
		// #1000;
	// end
	
	#15000;
	for(i = 0; i < 10; i = i + 1) begin
		Evnt2 = 1;
		#1000;
		Evnt2 = 0;	
		#1000;
	end
 end
	 
 endmodule