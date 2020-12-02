module asinhFIFOa_sim
  #(
	parameter bw_addr = 7, 	// addr in wight
	parameter bw = 32, 		// data in wight
	parameter alfull = 30   // 
   )
   (rst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty,
    rd_data_count,
    wr_data_count,
    wr_rst,
    rd_rst);
	
  input rst;
  input wr_clk;
  input rd_clk;
  input [bw - 1:0]din;
  input wr_en;
  input rd_en;
  output [bw - 1:0]dout;
  output full;
  output empty;
  output [bw_addr  : 0] rd_data_count;
  output [bw_addr  : 0] wr_data_count;
  input wr_rst;
  input rd_rst;

 reg [bw_addr - 1:0] ctrWr_WRs;
 reg [bw_addr - 1:0] ctrRd_WRs;
 reg [bw_addr - 1:0] ctrRd_WRs_s1;
 reg [bw_addr - 1:0] ctrRd_WRs_s2;

 reg [bw_addr - 1:0] ctrWr_RDs;
 reg [bw_addr - 1:0] ctrRd_RDs;
 reg [bw_addr - 1:0] ctrWr_RDs_s1;
 reg [bw_addr - 1:0] ctrWr_RDs_s2;
 
 reg full;
 reg empty;

 reg [bw - 1:0] dataWR;
 reg wr_RDs;
 reg rd_WRs;
 
 reg  [bw - 1:0] ram [(2**bw_addr)-1:0];
 wire [bw - 1:0] dout;   

 assign wr_data_count = (ctrWr_WRs >= ctrRd_WRs)?  (ctrWr_WRs - ctrRd_WRs): (ctrWr_WRs + (2**bw_addr - ctrRd_WRs));
 assign rd_data_count = (ctrWr_WRs >= ctrRd_WRs)?  (ctrWr_RDs - ctrRd_RDs): (ctrWr_RDs + (2**bw_addr - ctrRd_RDs));

 always @(posedge wr_clk) begin
	if (wr_en) ram[ctrWr_WRs] <= din;
 end
 
 assign dout = ram[ctrRd_RDs];
						
 always @(posedge wr_clk) begin
	if(rst)begin
		ctrWr_WRs <= 0;
		full    <= 0;
		rd_WRs 	<= 0;
		ctrRd_WRs_s1 <= 0;
		ctrRd_WRs_s2 <= 0;
		ctrRd_WRs <= 0;
	end
	else begin
		if (wr_en) begin
			if (ctrRd_WRs == (ctrWr_WRs + 1'b1)) full  <= 1;
											else full  <= 0;
			ctrWr_WRs <= ctrWr_WRs + 1;
		end
		else if (rd_WRs) full  <= 0;
		
		//sinhro ctrRd_RDs on write side
		ctrRd_WRs_s1 <= ctrRd_RDs;	
		ctrRd_WRs_s2 <= ctrRd_WRs_s1;	
		ctrRd_WRs <= ctrRd_WRs_s2;
		
		if (ctrRd_WRs != ctrRd_WRs_s2) rd_WRs <= 1;
								  else rd_WRs <= 0;

	end
 end

 always @(posedge rd_clk) begin
	if(rst)begin
		ctrRd_RDs <= 0;
		ctrWr_RDs_s1 <= 0;
		ctrWr_RDs_s2 <= 0;
		ctrWr_RDs <= 0;
		empty  	  <= 1;
		wr_RDs 	  <= 0;
	end
	else begin
		if (rd_en) begin
			if (ctrWr_RDs == (ctrRd_RDs + 1'b1)) empty <= 1;
											else empty <= 0;
			ctrRd_RDs <= ctrRd_RDs + 1;
		end
		else if(wr_RDs)  empty <= 0;

		//sinhro ctrWr_WRs on read side
		ctrWr_RDs_s1 <= ctrWr_WRs;	
		ctrWr_RDs_s2 <= ctrWr_RDs_s1;	
		ctrWr_RDs    <= ctrWr_RDs_s2;	
		if (ctrWr_RDs != ctrWr_RDs_s2) wr_RDs <= 1;
								  else wr_RDs <= 0;
	end	
 end


endmodule