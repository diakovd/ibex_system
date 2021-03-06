 `include "../source/defines.sv"

 module IOmodule (
	DatBus.Slave DatBus,
	CtrBus.Slave CtrBus, 

	//IO out
	output [31:0] IO,
	output [63:0] dgt1_8,	   
	   
	input Rst,	
	input Clk 
 );
  parameter nw = 3;

  logic [31:0] IOreg[nw];

  always @(posedge Clk) begin
    if (CtrBus.req) begin
      if (CtrBus.we) begin
			if (DatBus.be[0]) IOreg[DatBus.addr[3:2]][7:0]   <= DatBus.wdata[7:0];  
			if (DatBus.be[1]) IOreg[DatBus.addr[3:2]][15:8]  <= DatBus.wdata[15:8];  
			if (DatBus.be[2]) IOreg[DatBus.addr[3:2]][23:16] <= DatBus.wdata[23:16];  
			if (DatBus.be[3]) IOreg[DatBus.addr[3:2]][31:24] <= DatBus.wdata[31:24];  
      end
      CtrBus.rdata <= IOreg[DatBus.addr[2]];
    end
  end
  
  assign IO 		   = IOreg[0];
  assign dgt1_8[31:0]  = IOreg[1];
  assign dgt1_8[63:32] = IOreg[2];

  always_ff @(posedge Clk or posedge Rst) begin
    if (Rst) begin
      CtrBus.rvalid <= '0;
	  CtrBus.gnt    <= 'b0;
    end else begin
      CtrBus.rvalid <= CtrBus.req;
	  CtrBus.gnt 	<= CtrBus.req;
    end
  end
 
  assign CtrBus.err = 0;
 
 endmodule