`define MTIMER_MTIME        32'h00
`define MTIMER_MTIME_LO     32'h00
`define MTIMER_MTIME_HI     32'h04
`define MTIMER_MTIMECMP     32'h08
`define MTIMER_MTIMECMP_LO  32'h08
`define MTIMER_MTIMECMP_HO  32'h0c


 module mtimer
 (
 	DatBus.Slave CPUdat,
	CtrBus.Slave CPUctr,
	
	output logic Int,
	input  Rst,
	input  Clk
 );
 
 parameter int addrBase = 0;
  
 logic [63:0]  mtime;
 logic [63:0]  mtimecmp;
 
 logic [31:0] wrdata;
 logic [31:0] addr;
 logic [31:0] RDdata;
 logic [31:0] addr_rd;
 logic [1:0] addr_low;
 logic rd, wr;
 
//Bus Registers Write/Read
assign wrdata = CPUdat.wdata;	

assign addr_low = 	(CPUdat.be == 4'b0001)?  2'h0:
					(CPUdat.be == 4'b0010)?  2'h1:
					(CPUdat.be == 4'b0100)?  2'h2:
					(CPUdat.be == 4'b1000)?  2'h3: 2'h0;
					
assign addr = {CPUdat.addr[31 :2], addr_low} - addrBase;
assign wr = CPUctr.req & CPUctr.we & CPUctr.gnt;
assign CPUctr.gnt = 1;

always @(posedge Clk) rd <= CPUctr.req & !CPUctr.we & CPUctr.gnt;
assign CPUctr.rdata = RDdata;

always @(posedge Clk) begin
	if(CPUctr.req & CPUctr.gnt) CPUctr.rvalid 	<= 1;
	else 						CPUctr.rvalid 	<= 0;
	addr_rd <= addr;
end

 
 //write registers
 always @(posedge Clk) begin
	if(Rst) begin
		mtime	 <= 0;
		mtimecmp <= 0;
	end
	else begin 
		if 		(wr & addr == `MTIMER_MTIME_HI)    mtime[63:32]  	<= wrdata;
		else if (wr & addr == `MTIMER_MTIME_LO)    mtime[31:0]   	<= wrdata;
		else mtime <= mtime + 1;
		
		if (wr & addr == `MTIMER_MTIMECMP_HO) 		mtimecmp[63:32]	<= wrdata;
		else if (wr & addr == `MTIMER_MTIMECMP_LO) 	mtimecmp[31:0] 	<= wrdata;

		if(mtimecmp > 0) begin
			if(mtime >= mtimecmp) 	Int <= 1'b1;
			else 					Int <= 1'b0;
		end
	end
  end
  
 //Read registers
 always_comb begin
 
 	if     (addr_rd == `MTIMER_MTIME_HI) 	RDdata <= mtime[63:32];	
 	else if(addr_rd == `MTIMER_MTIME_LO)  	RDdata <= mtime[31:0];	
	else if(addr_rd == `MTIMER_MTIMECMP_HO) RDdata <= mtimecmp[63:32];	
	else if(addr_rd == `MTIMER_MTIMECMP_LO) RDdata <= mtimecmp[31:0];	
	else RDdata <= 0;
 
 end
 
 endmodule