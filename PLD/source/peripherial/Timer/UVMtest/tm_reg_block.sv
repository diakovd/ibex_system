package regmodel_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class reg_TmVal extends uvm_reg;
   `uvm_object_utils(reg_TmVal)

        uvm_reg_field TmVal_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmVal_f = uvm_reg_field::type_id::create("TmVal_f");
      TmVal_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TmPr extends uvm_reg;
   `uvm_object_utils(reg_TmPr)

        uvm_reg_field TmPr_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmPr_f = uvm_reg_field::type_id::create("TmPr_f");
      TmPr_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TmPrSh extends uvm_reg;
   `uvm_object_utils(reg_TmPrSh)

   rand uvm_reg_field TmPrSh_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmPrSh_f = uvm_reg_field::type_id::create("TmPrSh_f");
      TmPrSh_f.configure(this, 32, 0, "RW", 1, 32'h00, 1, 1, 1);
   endfunction
endclass

class reg_TmCmp extends uvm_reg;
   `uvm_object_utils(reg_TmCmp)

        uvm_reg_field TmCmp_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmCmp_f = uvm_reg_field::type_id::create("TmCmp_f");
      TmCmp_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TmCmpSh extends uvm_reg;
   `uvm_object_utils(reg_TmCmpSh)

   rand uvm_reg_field TmCmpSh_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmCmpSh_f = uvm_reg_field::type_id::create("TmCmpSh_f");
      TmCmpSh_f.configure(this, 32, 0, "RW", 1, 32'h00, 1, 1, 1);
   endfunction
endclass

class reg_TmCap0 extends uvm_reg;
   `uvm_object_utils(reg_TmCap0)

		uvm_reg_field TmCap0_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmCap0_f = uvm_reg_field::type_id::create("TmCap0_f");
      TmCap0_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TmCap1 extends uvm_reg;
   `uvm_object_utils(reg_TmCap1)

		uvm_reg_field TmCap1_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmCap1_f = uvm_reg_field::type_id::create("TmCap1_f");
      TmCap1_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TmCap2 extends uvm_reg;
   `uvm_object_utils(reg_TmCap2)

		uvm_reg_field TmCap2_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmCap2_f = uvm_reg_field::type_id::create("TmCap2_f");
      TmCap2_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TmCap3 extends uvm_reg;
   `uvm_object_utils(reg_TmCap3)

		uvm_reg_field TmCap3_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmCap3_f = uvm_reg_field::type_id::create("TmCap3_f");
      TmCap3_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);
   endfunction
endclass

class reg_TRS extends uvm_reg;
   `uvm_object_utils(reg_TRS)

   rand uvm_reg_field TC; // Timer Clear
   rand uvm_reg_field RC; // Timer Run Bit Clear	
   rand uvm_reg_field RS; // Timer Run Bit set
   
   function new(string name = "reg_TRS");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  this.TC = uvm_reg_field::type_id::create("TC");
	  this.RC = uvm_reg_field::type_id::create("RC");
	  this.RS = uvm_reg_field::type_id::create("RS");
	  
      this.TC.configure(this, 1, 2, "RW", 0, 0, 1, 1, 1);
      this.RC.configure(this, 1, 1, "RW", 0, 0, 1, 1, 1);
      this.RS.configure(this, 1, 0, "RW", 0, 0, 1, 1, 1);
   endfunction
endclass

// class reg_TRS extends uvm_reg;
   // `uvm_object_utils(reg_TRS)

   // rand uvm_reg_field TRS;

   // function new(string name = "");
      // super.new(name, 32, UVM_NO_COVERAGE);
   // endfunction

   // virtual function void build();
	  // TRS = uvm_reg_field::type_id::create("TRS");
      // TRS.configure(this, 32, 0, "RW", 1, 32'h00, 1, 1, 1);
   // endfunction
// endclass

class reg_TCFS extends uvm_reg;
   `uvm_object_utils(reg_TCFS)

	uvm_reg_field C3Full;	// Capture3 reg Full
	uvm_reg_field C2Full;	// Capture2 reg Full
	uvm_reg_field C1Full;	// Capture1 reg Full	
	uvm_reg_field C0Full;	// Capture0 reg Full


   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  this.C3Full = uvm_reg_field::type_id::create("C3Full");
	  this.C2Full = uvm_reg_field::type_id::create("C2Full");
	  this.C1Full = uvm_reg_field::type_id::create("C1Full");
	  this.C0Full = uvm_reg_field::type_id::create("C0Full");
	  
      this.C3Full.configure(this, 1, 3, "RO", 0, 0, 1, 1, 1);
      this.C2Full.configure(this, 1, 2, "RO", 0, 0, 1, 1, 1);
      this.C1Full.configure(this, 1, 1, "RO", 0, 0, 1, 1, 1);
      this.C0Full.configure(this, 1, 0, "RO", 0, 0, 1, 1, 1);
   endfunction
endclass

class reg_TRSt extends uvm_reg;
   `uvm_object_utils(reg_TRSt)

    uvm_reg_field TCD;
    uvm_reg_field TR;
 
   function new(string name = "reg_TRSt");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  this.TCD = uvm_reg_field::type_id::create("TCD");
	  this.TR  = uvm_reg_field::type_id::create("TR");


      this.TCD.configure(this, 1, 1, "RO", 0, 0, 1, 1, 1);
      this.TR.configure(this, 1, 0, "RO", 0, 0, 1, 1, 1);	  
   endfunction
endclass

class reg_TMS extends uvm_reg;
   `uvm_object_utils(reg_TMS)

	rand uvm_reg_field EMS;		//External Modulation Synchronization
	rand uvm_reg_field CCE; 	// Continuous Capture Enable
	rand uvm_reg_field StrFC;	// Extended Start Function Control
	rand uvm_reg_field StpFC;	// Extended Stop Function Control
	rand uvm_reg_field CCC;	// Clear on Capture Control
	rand uvm_reg_field STC;			// Shadow Transfer on Clear
	rand uvm_reg_field CCM;			// Capture/Compare Mode
	rand uvm_reg_field SShM;		// Single shot mode
	rand uvm_reg_field TCM;			// Timer Counting Edge/Center aligned Mode

   function new(string name = "reg_TMS");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
   	  this.EMS = uvm_reg_field::type_id::create("EMS");
	  this.CCE = uvm_reg_field::type_id::create("CCE");
	  this.StrFC = uvm_reg_field::type_id::create("StrFC");
	  this.StpFC = uvm_reg_field::type_id::create("StpFC");
	  this.CCC = uvm_reg_field::type_id::create("CCC");
	  this.STC = uvm_reg_field::type_id::create("STC");
	  this.CCM = uvm_reg_field::type_id::create("CCM");
	  this.SShM = uvm_reg_field::type_id::create("SShM");
	  this.TCM = uvm_reg_field::type_id::create("TCM");
   
      this.EMS.configure(this, 1, 10, "RW", 0, 0, 1, 1, 1);
      this.CCE.configure(this, 1, 9, "RW", 0, 0, 1, 1, 1);
      this.StrFC.configure(this, 1, 8, "RW", 0, 0, 1, 1, 1);
      this.StpFC.configure(this, 2, 6, "RW", 0, 0, 1, 1, 1);
      this.CCC.configure(this, 2, 4, "RW", 0, 0, 1, 1, 1);
      this.STC.configure(this, 1, 3, "RW", 0, 0, 1, 1, 1);
      this.CCM.configure(this, 1, 2, "RW", 0, 0, 1, 1, 1);
      this.SShM.configure(this, 1, 1, "RW", 0, 0, 1, 1, 1);
      this.TCM.configure(this, 1, 0, "RW", 0, 0, 1, 1, 1);

   endfunction
endclass

class reg_ECR extends uvm_reg;
   `uvm_object_utils(reg_ECR)

	rand uvm_reg_field E2FC;			// Event 2 Low Pass Filter Configuration
	rand uvm_reg_field E1FC;			// Event 1 Low Pass Filter Configuration
	rand uvm_reg_field E0FC;			// Event 0 Low Pass Filter Configuration
	rand uvm_reg_field E2LS;				// Event 2 Level Selection
	rand uvm_reg_field E1LS;				// Event 1 Level Selection
	rand uvm_reg_field E0LS;				// Event 0 Level Selection
	rand uvm_reg_field E2ES;			// Event 2 Edge Selection
	rand uvm_reg_field E1ES;			// Event 1 Edge Selection
	rand uvm_reg_field E0ES;			// Event 0 Edge Selection


   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	this.E2FC = uvm_reg_field::type_id::create("E2FC");	
	this.E1FC = uvm_reg_field::type_id::create("E1FC");	
	this.E0FC = uvm_reg_field::type_id::create("E0FC");	
	this.E2LS = uvm_reg_field::type_id::create("E2LS");	
	this.E1LS = uvm_reg_field::type_id::create("E1LS");	
	this.E0LS = uvm_reg_field::type_id::create("E0LS");	
	this.E2ES = uvm_reg_field::type_id::create("E2ES");	
	this.E1ES = uvm_reg_field::type_id::create("E1ES");	
	this.E0ES = uvm_reg_field::type_id::create("E0ES");	
   
    this.E2FC.configure(this, 2, 13, "RW", 0, 0, 1, 1, 1);
    this.E1FC.configure(this, 2, 11, "RW", 0, 0, 1, 1, 1);
    this.E0FC.configure(this, 2, 9, "RW", 0, 0, 1, 1, 1);
    this.E2LS.configure(this, 1, 8, "RW", 0, 0, 1, 1, 1);
    this.E1LS.configure(this, 1, 7, "RW", 0, 0, 1, 1, 1);
    this.E0LS.configure(this, 1, 6, "RW", 0, 0, 1, 1, 1);
    this.E2ES.configure(this, 2, 4, "RW", 0, 0, 1, 1, 1);
    this.E1ES.configure(this, 2, 2, "RW", 0, 0, 1, 1, 1);
    this.E0ES.configure(this, 2, 0, "RW", 0, 0, 1, 1, 1);

   endfunction
endclass

class reg_CMC extends uvm_reg;
   `uvm_object_utils(reg_CMC)

	rand uvm_reg_field CntCapS1;		// External Count to Capture 1 selector	
	rand uvm_reg_field CntCapS0;		// External Count to Capture 0 selector	
	rand uvm_reg_field MdlS;			// External Modulation Functionality Selector
	rand uvm_reg_field CntS;			// External Count Selector
	rand uvm_reg_field LdS;			// External Timer Load Functionality Selector
	rand uvm_reg_field UpDwS;			// External Up/Down Functionality Selector
	rand uvm_reg_field GatS;			// External Gate Functionality Selector
	rand uvm_reg_field CapS1;			// External Capture 1 Functionality Selector
	rand uvm_reg_field CapS0;			// External Capture 0 Functionality Selector
	rand uvm_reg_field StpS;			// External Stop Functionality Selector
	rand uvm_reg_field StrtS;			// External Start Functionality Selector


   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	this.CntCapS1 = uvm_reg_field::type_id::create("CntCapS1");		  
	this.CntCapS0 = uvm_reg_field::type_id::create("CntCapS0");		  
	this.MdlS = uvm_reg_field::type_id::create("MdlS");		  
	this.CntS = uvm_reg_field::type_id::create("CntS");		  
	this.LdS = uvm_reg_field::type_id::create("LdS");		  
	this.UpDwS = uvm_reg_field::type_id::create("UpDwS");		  
	this.GatS = uvm_reg_field::type_id::create("GatS");		  
	this.CapS1 = uvm_reg_field::type_id::create("CapS1");		  
	this.CapS0 = uvm_reg_field::type_id::create("CapS0");		  
	this.StpS = uvm_reg_field::type_id::create("StpS");		  
	this.StrtS = uvm_reg_field::type_id::create("StrtS");		  
    
    this.CntCapS1.configure(this, 2, 20, "RW", 0, 0, 1, 1, 1);
    this.CntCapS0.configure(this, 2, 18, "RW", 0, 0, 1, 1, 1);
    this.MdlS.configure(this	, 2, 16, "RW", 0, 0, 1, 1, 1);
    this.CntS.configure(this	, 2, 14, "RW", 0, 0, 1, 1, 1);
    this.LdS.configure(this		, 2, 12, "RW", 0, 0, 1, 1, 1);
    this.UpDwS.configure(this	, 2, 10, "RW", 0, 0, 1, 1, 1);
    this.GatS.configure(this	, 2,  8, "RW", 0, 0, 1, 1, 1);
    this.CapS1.configure(this	, 2,  6, "RW", 0, 0, 1, 1, 1);
    this.CapS0.configure(this	, 2,  4, "RW", 0, 0, 1, 1, 1);
    this.StpS.configure(this	, 2,  2, "RW", 0, 0, 1, 1, 1);
    this.StrtS.configure(this	, 2,  0, "RW", 0, 0, 1, 1, 1);
	
   endfunction
endclass

class reg_ISR extends uvm_reg;
   `uvm_object_utils(reg_ISR)

	uvm_reg_field Ev2DS;			// Event 2 Detection Status
	uvm_reg_field Ev1DS;			// Event 1 Detection Status
	uvm_reg_field Ev0DS;			// Event 0 Detection Status
	uvm_reg_field CMdw;			// Compare Match while Counting Down
	uvm_reg_field CMup;			// Compare Match while Counting Up
	uvm_reg_field OMdw;			// One Match while Counting Down
	uvm_reg_field PMup;			// Period Match while Counting Up

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  this.Ev2DS = uvm_reg_field::type_id::create("Ev2DS");	
	  this.Ev1DS = uvm_reg_field::type_id::create("Ev1DS");	
	  this.Ev0DS = uvm_reg_field::type_id::create("Ev0DS");	
	  this.CMdw  = uvm_reg_field::type_id::create("CMdw");	
	  this.CMup  = uvm_reg_field::type_id::create("CMup");	
	  this.OMdw  = uvm_reg_field::type_id::create("OMdw");	
	  this.PMup  = uvm_reg_field::type_id::create("PMup");	
	  
	  this.Ev2DS.configure(this, 1, 6, "RO", 0, 0, 1, 1, 1);
	  this.Ev1DS.configure(this, 1, 5, "RO", 0, 0, 1, 1, 1);
	  this.Ev0DS.configure(this, 1, 4, "RO", 0, 0, 1, 1, 1);
	  this.CMdw.configure(this,  1, 3, "RO", 0, 0, 1, 1, 1);
	  this.CMup.configure(this,  1, 2, "RO", 0, 0, 1, 1, 1);
	  this.OMdw.configure(this,  1, 1, "RO", 0, 0, 1, 1, 1);
	  this.PMup.configure(this,  1, 0, "RO", 0, 0, 1, 1, 1);
   endfunction
endclass

class reg_IEC extends uvm_reg;
   `uvm_object_utils(reg_IEC)

	rand uvm_reg_field Ev2DSEn;		// Event 2 Detection Status enable
	rand uvm_reg_field Ev1DSEn;		// Event 1 Detection Status enable
	rand uvm_reg_field Ev0DSEn;		// Event 0 Detection Status enable
	rand uvm_reg_field CMdwEn;		// Compare Match while Counting Down enable
	rand uvm_reg_field CMupEn;		// Compare Match while Counting Up enable
	rand uvm_reg_field OMdwEn;		// One Match while Counting Down enable
	rand uvm_reg_field PMupEn;		// Period Match while Counting Up enable


   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  this.Ev2DSEn = uvm_reg_field::type_id::create("Ev2DSEn");	
	  this.Ev1DSEn = uvm_reg_field::type_id::create("Ev1DSEn");	
	  this.Ev0DSEn = uvm_reg_field::type_id::create("Ev0DSEn");	
	  this.CMdwEn = uvm_reg_field::type_id::create("CMdwEn");	
	  this.CMupEn = uvm_reg_field::type_id::create("CMupEn");	
	  this.OMdwEn = uvm_reg_field::type_id::create("OMdwEn");	
	  this.PMupEn = uvm_reg_field::type_id::create("PMupEn");	

	  this.Ev2DSEn.configure(this	, 1,  6, "RW", 0, 0, 1, 1, 1);
	  this.Ev1DSEn.configure(this	, 1,  5, "RW", 0, 0, 1, 1, 1);
	  this.Ev0DSEn.configure(this	, 1,  4, "RW", 0, 0, 1, 1, 1);
	  this.CMdwEn.configure(this	, 1,  3, "RW", 0, 0, 1, 1, 1);
	  this.CMupEn.configure(this	, 1,  2, "RW", 0, 0, 1, 1, 1);
	  this.OMdwEn.configure(this	, 1,  1, "RW", 0, 0, 1, 1, 1);
	  this.PMupEn.configure(this	, 1,  0, "RW", 0, 0, 1, 1, 1);
	  
   endfunction
endclass

class reg_ISC extends uvm_reg;
   `uvm_object_utils(reg_ISC)

   rand uvm_reg_field ISC_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  ISC_f = uvm_reg_field::type_id::create("ISC_f");
      ISC_f.configure(this, 32, 0, "RW", 1, 32'h00, 1, 1, 1);
   endfunction
endclass

class reg_PLC extends uvm_reg;
   `uvm_object_utils(reg_PLC)

   rand uvm_reg_field PLC_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  PLC_f = uvm_reg_field::type_id::create("PLC_f");
      PLC_f.configure(this, 32, 0, "RW", 1, 32'h00, 1, 1, 1);
   endfunction
endclass



class reg_TmC1mC0 extends uvm_reg;
   `uvm_object_utils(reg_TmC1mC0)

        uvm_reg_field TmC1mC0_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  TmC1mC0_f = uvm_reg_field::type_id::create("TmC1mC0_f");
      TmC1mC0_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);	
   endfunction
endclass

class reg_TmC3mC2 extends uvm_reg;
   `uvm_object_utils(reg_TmC3mC2)

        uvm_reg_field TmC3mC2_f;

   function new(string name = "");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
	  TmC3mC2_f = uvm_reg_field::type_id::create("TmC3mC2_f");
      TmC3mC2_f.configure(this, 32, 0, "RO", 1, 32'h00, 0, 0, 1);	
   endfunction
endclass


class bus_reg_block extends uvm_reg_block;
   `uvm_object_utils(bus_reg_block)

   reg_TmVal 	TmVal;
   reg_TmPr 	TmPr;
   rand reg_TmPrSh 	TmPrSh;
   reg_TmCmp 	TmCmp;
   rand reg_TmCmpSh TmCmpSh;
   reg_TmCap0 	TmCap0;
   reg_TmCap1 	TmCap1;
   reg_TmCap2 	TmCap2;
   reg_TmCap3 	TmCap3;
   rand reg_TRS 	TRS;
   reg_TCFS 	TCFS;
   reg_TRSt 	TRSt;
   rand reg_TMS 	TMS;
   rand reg_ECR 	ECR;
   rand reg_CMC 	CMC;
   reg_ISR 	ISR;
   rand reg_IEC 	IEC;
   rand reg_ISC 	ISC;
   rand reg_PLC 	PLC;
   reg_TmC1mC0	TmC1mC0;
   reg_TmC3mC2	TmC3mC2;

   uvm_reg_map bus_map; 

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      TmVal = reg_TmVal::type_id::create("TmVal");
      TmVal.configure(this);
      TmVal.build();

      TmPr = reg_TmPr::type_id::create("TmPr");
      TmPr.configure(this);
      TmPr.build();

      TmPrSh = reg_TmPrSh::type_id::create("TmPrSh");
      TmPrSh.configure(this);
      TmPrSh.build();

      TmCmp = reg_TmCmp::type_id::create("TmCmp");
      TmCmp.configure(this);
      TmCmp.build();

      TmCmpSh = reg_TmCmpSh::type_id::create("TmCmpSh");
      TmCmpSh.configure(this);
      TmCmpSh.build();

      TmCap0 = reg_TmCap0::type_id::create("TmCap0");
      TmCap0.configure(this);
      TmCap0.build();

      TmCap1 = reg_TmCap1::type_id::create("TmCap1");
      TmCap1.configure(this);
      TmCap1.build();

      TmCap2 = reg_TmCap2::type_id::create("TmCap2");
      TmCap2.configure(this);
      TmCap2.build();

      TmCap3 = reg_TmCap3::type_id::create("TmCap3");
      TmCap3.configure(this);
      TmCap3.build();

      TRS = reg_TRS::type_id::create("TRS");
      TRS.configure(this);
      TRS.build();

      TCFS = reg_TCFS::type_id::create("TCFS");
      TCFS.configure(this);
      TCFS.build();

      TRSt = reg_TRSt::type_id::create("TRSt");
      TRSt.configure(this);
      TRSt.build();

      TMS = reg_TMS::type_id::create("TMS");
      TMS.configure(this);
      TMS.build();

      ECR = reg_ECR::type_id::create("ECR");
      ECR.configure(this);
      ECR.build();

      CMC = reg_CMC::type_id::create("CMC");
      CMC.configure(this);
      CMC.build();

      ISR = reg_ISR::type_id::create("ISR");
      ISR.configure(this);
      ISR.build();

      IEC = reg_IEC::type_id::create("IEC");
      IEC.configure(this);
      IEC.build();

      ISC = reg_ISC::type_id::create("ISC");
      ISC.configure(this);
      ISC.build();

      PLC = reg_PLC::type_id::create("PLC");
      PLC.configure(this);
      PLC.build();

      TmC1mC0 = reg_TmC1mC0::type_id::create("TmC1mC0");
      TmC1mC0.configure(this);
      TmC1mC0.build();

      TmC3mC2 = reg_TmC3mC2::type_id::create("TmC3mC2");
      TmC3mC2.configure(this);
      TmC3mC2.build();


      bus_map = create_map("bus_map", 'h0, 4, UVM_LITTLE_ENDIAN);
      default_map = bus_map;

      bus_map.add_reg(TRS,  'h0, "RO");
      bus_map.add_reg(TCFS,  'h4, "RO");
      bus_map.add_reg(TRSt,  'h8, "RW");
      bus_map.add_reg(TMS,  'hc, "RO");
      bus_map.add_reg(ECR,  'h10, "RW");
      bus_map.add_reg(CMC,  'h14, "RW");
      bus_map.add_reg(ISR,  'h18, "RO");
      bus_map.add_reg(IEC,  'h1c, "RO");
      bus_map.add_reg(ISC,  'h20, "RO");
      bus_map.add_reg(PLC,  'h24, "RW");
      bus_map.add_reg(TmVal, 'h28, "RO");
      bus_map.add_reg(TmPr, 'h2c, "RO");
      bus_map.add_reg(TmPrSh, 'h30, "RW");
      bus_map.add_reg(TmCap0, 'h34, "RW");
      bus_map.add_reg(TmCap1, 'h38, "RW");
      bus_map.add_reg(TmCap2, 'h3c, "RO");
      bus_map.add_reg(TmCap3, 'h40, "RW");
      bus_map.add_reg(TmC1mC0, 'h44, "RO");
      bus_map.add_reg(TmC3mC2, 'h48, "RO");
      bus_map.add_reg(TmCmp,   'h4c, "RW");
      bus_map.add_reg(TmCmpSh, 'h50, "RW");

      lock_model();
   endfunction
endclass

class top_reg_block extends uvm_reg_block;
   `uvm_object_utils(top_reg_block)

   bus_reg_block bus; 

   uvm_reg_map bus_map; 

   function new(string name = "");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      bus = bus_reg_block::type_id::create("bus");
      bus.configure(this);
      bus.build();

      bus_map = create_map("bus_map", 'h0, 4, UVM_LITTLE_ENDIAN,1);
      default_map = bus_map;

      bus_map.add_submap(bus.bus_map, 'h0);

      lock_model();
   endfunction
endclass

endpackage: regmodel_pkg
