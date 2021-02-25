`ifndef TMRDEF_H
`define TMRDEF_H
 
 `define aw	32

 `define dTRS 		`aw'd00
 `define dTCFS 		`aw'd01
 `define dTRSt 		`aw'd02
 `define dTMS 		`aw'd03
 `define dECR 		`aw'd04
 `define dCMC 		`aw'd05
 `define dISR 		`aw'd06
 `define dIEC 		`aw'd07
 `define dISC 		`aw'd08
 `define dPLC		`aw'd09
 `define dTmVal 	`aw'd10
 `define dTmPr  	`aw'd11
 `define dTmPrSh 	`aw'd12
 `define dTmCap0	`aw'd13
 `define dTmCap1	`aw'd14
 `define dTmCap2	`aw'd15
 `define dTmCap3	`aw'd16
 `define dTmC1mC0	`aw'd17
 `define dTmC3mC2 	`aw'd18
 `define dTmCmp 	`aw'd19
 `define dTmCmpSh	`aw'd20


 
 typedef struct packed{
	reg [28:0] bit31_3; //r
	reg TC;			// Timer Clear
	reg RC;			// Timer Run Bit Clear	
	reg RS;			// Timer Run Bit set
 } Timer_Run_Set;	// TRS

 typedef struct packed{
	reg [27:0] bit31_4; //r
	reg C3Full;			// Capture3 reg Full
	reg C2Full;			// Capture2 reg Full
	reg C1Full;			// Capture1 reg Full	
	reg C0Full;			// Capture0 reg Full
 } Timer_Capture_Flags_Status;	// TCFS

 typedef struct packed{
	reg [29:0] bit31_2; //r
	reg TCD;		// Timer Counting Direction
	reg TR;			// This field indicates if the timer is running
 } Timer_Run_Status;	// TRSt

 typedef struct packed{
	reg [19:0] bit31_12; //r
	reg EMS;			//External Modulation Synchronization
	reg CCE; 			// Continuous Capture Enable
	reg StrFC;	// Extended Start Function Control
	reg [1:0] StpFC;	// Extended Stop Function Control
	reg [1:0] CCC;		// Clear on Capture Control
	reg STC;			// Shadow Transfer on Clear
	reg CCM;			// Capture/Compare Mode
	reg SShM;			// Single shot mode
	reg TCM;			// Timer Counting Edge/Center aligned Mode
 } Timer_Mode_Setting;	// TMS

 typedef struct packed{
	reg [28:0] bit31_3; //r
	reg [1:0] E2FC;			// Event 2 Low Pass Filter Configuration
	reg [1:0] E1FC;			// Event 1 Low Pass Filter Configuration
	reg [1:0] E0FC;			// Event 0 Low Pass Filter Configuration
	reg E2LS;				// Event 2 Level Selection
	reg E1LS;				// Event 1 Level Selection
	reg E0LS;				// Event 0 Level Selection
	reg [1:0] E2ES;			// Event 2 Edge Selection
	reg [1:0] E1ES;			// Event 1 Edge Selection
	reg [1:0] E0ES;			// Event 0 Edge Selection
 } Event_control_register;	// 

 typedef struct packed{
	reg [9:0] 	bit31_18; //r
	reg [1:0] CntCapS1;			// External Count to Capture 1 selector	
	reg [1:0] CntCapS0;			// External Count to Capture 0 selector	
	reg [1:0] MdlS;				// External Modulation Functionality Selector
	reg [1:0] CntS;				// External Count Selector
	reg [1:0] LdS;				// External Timer Load Functionality Selector
	reg [1:0]   UpDwS;			// External Up/Down Functionality Selector
	reg [1:0]   GatS;			// External Gate Functionality Selector
	reg [1:0] 	CapS1;			// External Capture 1 Functionality Selector
	reg [1:0] 	CapS0;			// External Capture 0 Functionality Selector
	reg [1:0] 	StpS;			// External Stop Functionality Selector
	reg [1:0] 	StrtS;			// External Start Functionality Selector
 } Connection_Matrix_Control;	// 

 typedef struct packed{
	reg [24:0] bit31_24;//r
	// reg EvCC;			// Clear on Capture event
	reg Ev2DS;			// Event 2 Detection Status
	reg Ev1DS;			// Event 1 Detection Status
	reg Ev0DS;			// Event 0 Detection Status
	reg CMdw;			// Compare Match while Counting Down
	reg CMup;			// Compare Match while Counting Up
	reg OMdw;			// One Match while Counting Down
	reg PMup;			// Period Match while Counting Up
 } Interrupt_Status_register;	// 

 typedef struct packed{
	reg [24:0] bit31_24;//r
	// reg EvCCEn;			// Clear on Capture event enable
	reg Ev2DSEn;		// Event 2 Detection Status enable
	reg Ev1DSEn;		// Event 1 Detection Status enable
	reg Ev0DSEn;		// Event 0 Detection Status enable
	reg CMdwEn;			// Compare Match while Counting Down enable
	reg CMupEn;			// Compare Match while Counting Up enable
	reg OMdwEn;			// One Match while Counting Down enable
	reg PMupEn;			// Period Match while Counting Up enable
 } Interrupt_Enable_Control;	//  
 
  typedef struct packed{
	// reg [1:0] bit31; //r
	reg [31:0] OPL;				// Output Passive Level
 } Passive_Level_Config;	// PLC

`endif