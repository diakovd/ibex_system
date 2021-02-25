//-------------------------------------------------------------------------
//						mem_interface - www.verificationguide.com
//-------------------------------------------------------------------------

interface mem_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  logic [1:0] addr;
  logic wr_en;
  logic rd_en;
  logic [7:0] wdata;
  logic [7:0] rdata;
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output addr;
    output wr_en;
    output rd_en;
    output wdata;
    input  rdata;  
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input addr;
    input wr_en;
    input rd_en;
    input wdata;
    input rdata;  
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
endinterface

/************************************************
 * AHB3 Lite Package
 */
package ahb3lite_pkg;
  //HTRANS
  parameter [1:0] HTRANS_IDLE   = 2'b00,
                  HTRANS_BUSY   = 2'b01,
                  HTRANS_NONSEQ = 2'b10,
                  HTRANS_SEQ    = 2'b11;

  //HSIZE
  parameter [2:0] HSIZE_B8    = 3'b000,
                  HSIZE_B16   = 3'b001,
                  HSIZE_B32   = 3'b010,
                  HSIZE_B64   = 3'b011,
                  HSIZE_B128  = 3'b100, //4-word line
                  HSIZE_B256  = 3'b101, //8-word line
                  HSIZE_B512  = 3'b110,
                  HSIZE_B1024 = 3'b111,
                  HSIZE_BYTE  = HSIZE_B8,
                  HSIZE_HWORD = HSIZE_B16,
                  HSIZE_WORD  = HSIZE_B32,
                  HSIZE_DWORD = HSIZE_B64;

  //HBURST
  parameter [2:0] HBURST_SINGLE = 3'b000,
                  HBURST_INCR   = 3'b001,
                  HBURST_WRAP4  = 3'b010,
                  HBURST_INCR4  = 3'b011,
                  HBURST_WRAP8  = 3'b100,
                  HBURST_INCR8  = 3'b101,
                  HBURST_WRAP16 = 3'b110,
                  HBURST_INCR16 = 3'b111;

  //HPROT
  parameter [3:0] HPROT_OPCODE         = 4'b0000,
                  HPROT_DATA           = 4'b0001,
                  HPROT_USER           = 4'b0000,
                  HPROT_PRIVILEGED     = 4'b0010,
                  HPROT_NON_BUFFERABLE = 4'b0000,
                  HPROT_BUFFERABLE     = 4'b0100,
                  HPROT_NON_CACHEABLE  = 4'b0000,
                  HPROT_CACHEABLE      = 4'b1000;

  //HRESP
  parameter       HRESP_OKAY  = 1'b0,
                  HRESP_ERROR = 1'b1;

endpackage

/************************************************
 * AHB3 Lite Interface
 */
 `ifndef AHB3_INTERFACES
 `define AHB3_INTERFACES

interface ahb3lite_bus #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32
)
(
  input logic HCLK,HRESETn
);
  logic                   HSEL;
  logic [HADDR_SIZE -1:0] HADDR;
  logic [HDATA_SIZE -1:0] HWDATA;
  logic [HDATA_SIZE -1:0] HRDATA;
  logic                   HWRITE;
  logic [            2:0] HSIZE;
  logic [            3:0] HBURST;
  logic [            3:0] HPROT;
  logic [            1:0] HTRANS;
  logic                   HMASTLOCK;
  logic                   HREADY;
  logic                   HREADYOUT;
  logic                   HRESP;

//`ifdef SIM
  // Master CB Interface Definitions
  clocking driver_cb @(posedge HCLK);
	  default input #1 output #1; 	
      output HSEL;
      output HADDR;
      output HWDATA;
      input  HRDATA;
      output HWRITE;
      output HSIZE;
      output HBURST;
      output HPROT;
      output HTRANS;
      output HMASTLOCK;
      input  HREADY;
      input  HRESP;
  endclocking

  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input HCLK,HRESETn);

  // Slave Interface Definitions
  clocking monitor_cb @(posedge HCLK);
	  default input #1 output #1;
      input HSEL;
      input HADDR;
      input HWDATA;
      input HRDATA;
      input HWRITE;
      input HSIZE;
      input HBURST;
      input HPROT;
      input HTRANS;
      input HMASTLOCK;
      input HREADY;
      input HREADYOUT;
      input HRESP;
  endclocking

  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input HCLK,HRESETn);
//`endif

  modport master (
      input  HRESETn,
      input  HCLK,
      output HSEL,
      output HADDR,
      output HWDATA,
      input  HRDATA,
      output HWRITE,
      output HSIZE,
      output HBURST,
      output HPROT,
      output HTRANS,
      output HMASTLOCK,
      input  HREADY,
      input  HRESP
  );

  modport slave (
      input  HRESETn,
      input  HCLK,
      input  HSEL,
      input  HADDR,
      input  HWDATA,
      output HRDATA,
      input  HWRITE,
      input  HSIZE,
      input  HBURST,
      input  HPROT,
      input  HTRANS,
      input  HMASTLOCK,
      input  HREADY,
      output HREADYOUT,
      output HRESP
  );
endinterface
 
interface tm_ex_if #(
  parameter PWM_SIZE = 1
);
 	logic Evnt0;
	logic Evnt1;
	logic Evnt2;
	logic [PWM_SIZE - 1:0] PWM;
	logic Int;
endinterface

`endif
