 `include "../source/defines.sv"

 module IOmodule (
	DatBus.Slave DatBus,
	CtrBus.Slave CtrBus, 

	//IO out
	output logic [31:0] IO,
	   
	input Rst,	
	input Clk 
 );
  parameter adw = 7;

  always @(posedge Clk) begin
    if (CtrBus.req) begin
      if (CtrBus.we) begin
			if (DatBus.be[0]) IO[7:0]   <= DatBus.wdata[7:0];  
			if (DatBus.be[1]) IO[15:8]  <= DatBus.wdata[15:8];  
			if (DatBus.be[2]) IO[23:16] <= DatBus.wdata[23:16];  
			if (DatBus.be[3]) IO[31:24] <= DatBus.wdata[31:24];  
      end
      CtrBus.rdata <= IO;
    end
  end

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