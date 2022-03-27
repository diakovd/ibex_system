/**
 * Single-port RAM with 1 cycle read/write delay, 32 bit words
 */
`define SRAM_INIT_FILE
`include "../source/defines.sv"

module rom_1p #(
`ifdef Sim 
    parameter string  VENDOR = "Xilinx", //optional "IntelFPGA" , "Simulation", "Xilinx" 
`else 
    parameter         VENDOR = "Xilinx", //optional "IntelFPGA" , "Simulation", "Xilinx" 
`endif	
    parameter int Depth = 128
) 
(
	DatBus.Slave CPUdat,
	CtrBus.Slave CPUCtr,

	DatBus.Slave RAM_DatBus,
	CtrBus.Slave RAM_CtrBus,

	DatBus.Slave BootDat,
	CtrBus.Slave BootCtr,
		
	input RstBoot,

	input clk,
	input rst_n
);
 localparam int Aw = $clog2(Depth/4);

 wire rsta_busy;

 logic [Aw-1:0] addr_idx;
 logic req_idx;
 logic we_idx;
 logic [3:0] be_idx;
 logic [31:0] wdata_idx;
 logic [31:0] rdata_idx;
  
 assign addr_idx = (RstBoot)? BootDat.addr[Aw-1+2:2] : CPUdat.addr[Aw-1+2:2];
 assign req_idx  = (RstBoot)? BootCtr.req : CPUCtr.req;
 assign we_idx   = (RstBoot)? BootCtr.we  : CPUCtr.we;
 assign be_idx   = (RstBoot)? BootDat.be  : BootDat.be;
 assign wdata_idx = (RstBoot)? BootDat.wdata : CPUdat.wdata;

generate
if(VENDOR == "Simulation")begin
  logic [31:0] mem [Depth];

  always @(posedge clk) begin
    if (we_idx & req_idx) begin //port a
        if (be_idx[0] == 1'b1) mem[addr_idx[Aw-1+2:0]][7:0]   <=  wdata_idx[7:0];
        if (be_idx[1] == 1'b1) mem[addr_idx[Aw-1+2:0]][15:8]  <=  wdata_idx[15:8];
        if (be_idx[2] == 1'b1) mem[addr_idx[Aw-1+2:0]][23:16] <=  wdata_idx[23:16];
        if (be_idx[3] == 1'b1) mem[addr_idx[Aw-1+2:0]][31:24] <=  wdata_idx[31:24];
    end
	else if(RAM_CtrBus.req & RAM_CtrBus.we) begin
        if (RAM_DatBus.be[0] == 1'b1) mem[RAM_DatBus.addr[Aw-1+2:2]][7:0]   <=  RAM_DatBus.wdata[7:0];
        if (RAM_DatBus.be[1] == 1'b1) mem[RAM_DatBus.addr[Aw-1+2:2]][15:8]  <=  RAM_DatBus.wdata[15:8];
        if (RAM_DatBus.be[2] == 1'b1) mem[RAM_DatBus.addr[Aw-1+2:2]][23:16] <=  RAM_DatBus.wdata[23:16];
        if (RAM_DatBus.be[3] == 1'b1) mem[RAM_DatBus.addr[Aw-1+2:2]][31:24] <=  RAM_DatBus.wdata[31:24];
	end
	rdata_idx <= mem[addr_idx[Aw-1:0]];
	RAM_CtrBus.rdata <= mem[RAM_DatBus.addr[Aw-1+2:2]];
  end

 assign CPUCtr.rdata  = rdata_idx;
 assign BootCtr.rdata = rdata_idx;
  
 
  `ifdef SRAM_INIT_FILE
    localparam MEM_FILE = "../sw/Dhry/PyTools/program.hex";
    initial begin
      $display("Initializing instruction RAM from %s", MEM_FILE);
      $readmemh(MEM_FILE, mem);
    end
  `endif
  
end
else if(VENDOR == "Xilinx")begin

 wire [3:0] wea;
 wire [3:0] web;
 
 assign wea[0] = (RstBoot)? BootDat.be[0] & BootCtr.req & BootCtr.we : CPUdat.be[0] & CPUCtr.req & CPUCtr.we; 
 assign wea[1] = (RstBoot)? BootDat.be[1] & BootCtr.req & BootCtr.we : CPUdat.be[1] & CPUCtr.req & CPUCtr.we; 
 assign wea[2] = (RstBoot)? BootDat.be[2] & BootCtr.req & BootCtr.we : CPUdat.be[2] & CPUCtr.req & CPUCtr.we; 
 assign wea[3] = (RstBoot)? BootDat.be[3] & BootCtr.req & BootCtr.we : CPUdat.be[3] & CPUCtr.req & CPUCtr.we; 

 assign web[0] = RAM_DatBus.be[0] & RAM_CtrBus.req & RAM_CtrBus.we; 
 assign web[1] = RAM_DatBus.be[1] & RAM_CtrBus.req & RAM_CtrBus.we; 
 assign web[2] = RAM_DatBus.be[2] & RAM_CtrBus.req & RAM_CtrBus.we; 
 assign web[3] = RAM_DatBus.be[3] & RAM_CtrBus.req & RAM_CtrBus.we; 

 // RAM_instr RAM_inst(
 
    // .clka(clk),
// //    .ena(1'b1),
    // .wea(wea),   //(3 DOWNTO 0)
    // .addra(addr_idx[Aw-1+2:0]), //(11 DOWNTO 0)
    // .dina(wdata_idx),  //(31 DOWNTO 0)
    // .douta(rdata_idx)  //(31 DOWNTO 0)
  // );
 // assign  CPUCtr.rdata  = rdata_idx;
 // assign  BootCtr.rdata = rdata_idx;	
// */  

 RAMdp RAM_inst(
	.addra(addr_idx[Aw-1:0]),
	.dina(wdata_idx),
	.wea(wea),
	.douta(rdata_idx),
	.clka(clk),

	.addrb(RAM_DatBus.addr[Aw-1+2:2]),
	.dinb(RAM_DatBus.wdata),
	.web(web),
	.doutb(RAM_CtrBus.rdata),
	.clkb(clk)
 );
 
 assign CPUCtr.rdata  = rdata_idx;
 assign BootCtr.rdata = rdata_idx;
  
end  
else if(VENDOR == "IntelFPGA")begin

 RAMdp RAM_inst(
	.address_a(addr_idx),
	.data_a(wdata_idx),
	.wren_a((RstBoot)? BootCtr.req & BootCtr.we : 1'b0),
	.byteena_a((RstBoot)? BootDat.be :  CPUdat.be),
	.q_a(rdata_idx),
	.address_b(RAM_DatBus.addr[Aw-1+2:2]),
	.data_b(RAM_DatBus.wdata),
	.wren_b(RAM_CtrBus.req & RAM_CtrBus.we),
	.byteena_b(RAM_DatBus.be),
	.q_b(RAM_CtrBus.rdata),

	.clock(clk)
	);
	
 assign  CPUCtr.rdata  = rdata_idx;
 assign  BootCtr.rdata = rdata_idx;	

end
endgenerate



  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      CPUCtr.rvalid <= '0;
	  CPUCtr.gnt <= 'b0;

      BootCtr.rvalid <= '0;
	  BootCtr.gnt <= 'b0;
    end else begin
      CPUCtr.rvalid <= CPUCtr.req;
	  CPUCtr.gnt <= CPUCtr.req;// & !rsta_busy;

      BootCtr.rvalid <= BootCtr.req;
	  BootCtr.gnt <= BootCtr.req;// & !rsta_busy;
    end
  end
 
 assign CPUCtr.err = 1'b0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RAM_CtrBus.rvalid <= '0;
	  RAM_CtrBus.gnt <= 'b0;
    end else begin
      RAM_CtrBus.rvalid <= RAM_CtrBus.req;
	  RAM_CtrBus.gnt    <= RAM_CtrBus.req;
    end
  end
 
 assign RAM_CtrBus.err = 1'b0;
 
endmodule

