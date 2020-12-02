/**
 * Single-port RAM with 1 cycle read/write delay, 32 bit words
 */
`define SRAM_INIT_FILE
`include "../source/defines.sv"
`timescale 1ps/1ps

module ram_1p #(
    parameter string VENDOR = "Xilinx", //optional "IntelFPGA" , "Simulation" 
    parameter int 	 Depth  = 128
) 
(
	DatBus.Slave DatBus,
	CtrBus.Slave CtrBus,
	
   input clk,
   input rst_n
);


generate

if(VENDOR == "Simulation")begin

  localparam int Aw = $clog2(Depth);

  logic [31:0] mem [Depth];

  logic [Aw-1:0] addr_idx;
  assign addr_idx = DatBus.addr[Aw-1+2:2];
 
  always @(posedge clk) begin
    if (CtrBus.req) begin
      if (CtrBus.we) begin
        for (int i = 0; i < 4; i = i + 1) begin
          if (DatBus.be[i] == 1'b1) begin
            mem[addr_idx][i*8 +: 8] <= DatBus.wdata[i*8 +: 8];
          end
        end
      end
      CtrBus.rdata <= mem[addr_idx];
    end
  end
 
  `ifdef SRAM_INIT_FILE
    localparam MEM_FILE = "D:/Work/test_pr/ibex-sys/PLD/sw/program.hex";
    initial begin
      $display("Initializing SRAM from %s", MEM_FILE);
      $readmemh(MEM_FILE, mem);
    end
  `endif

end
else if(VENDOR == "Xilinx")begin

 wire [3:0] wea;
 
 assign wea[0] = DatBus.be[0] & CtrBus.req & CtrBus.we; 
 assign wea[1] = DatBus.be[1] & CtrBus.req & CtrBus.we; 
 assign wea[2] = DatBus.be[2] & CtrBus.req & CtrBus.we; 
 assign wea[3] = DatBus.be[3] & CtrBus.req & CtrBus.we; 

 RAM RAM_inst(
 
    .clka(clk),
    .ena(1'b1),
    .wea(wea),   //(3 DOWNTO 0)
    .addra(DatBus.addr[11:0]), //(11 DOWNTO 0)
    .dina(DatBus.wdata),  //(31 DOWNTO 0)
    .douta(CtrBus.rdata)  //(31 DOWNTO 0)
  );
  
end  
else if(VENDOR == "IntelFPGA")begin

 RAM RAM_inst (
	.address ( DatBus.addr[9:0] ), //(9 DOWNTO 0)
	.byteena ( DatBus.be ),
	.clock ( clk ),
	.data ( DatBus.wdata ),
	.wren ( CtrBus.req & CtrBus.we ),
	.q ( CtrBus.rdata )
	);

end
endgenerate

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      CtrBus.rvalid <= '0;
	  CtrBus.gnt <= 'b0;
    end else begin
      CtrBus.rvalid <= CtrBus.req;
	  CtrBus.gnt    <= CtrBus.req;
    end
  end
 
 assign CtrBus.err = 1'b0;

endmodule

