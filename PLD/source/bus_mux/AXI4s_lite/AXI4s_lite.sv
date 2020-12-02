
 //TASK AXI4s_lite
  
 // AXI4 lite slave to parallel interface /////////////////

 logic [31: 0] addr;
 logic [31: 0] data;
 logic wr;
  
 logic enAddr = 0;
 logic enData = 0;

 logic axi_awready = 0;

 logic axi_wready = 0;
 logic [1 : 0] axi_bresp = 0;
 logic axi_bvalid = 0;

 logic axi_arready = 0;
 logic [31 : 0] axi_rdata = 0;
 logic [1 : 0] axi_rresp = 0;
 logic axi_rvalid = 0;
 logic [3:0] be;
 
 typedef enum{
  idle_AXI4, stWR1_AXI4, stRD1_AXI4
  } fsm_state_AXI4; 
 fsm_state_AXI4 state_AXI4;
 
 task AXI4s_lite; // AXI4 lite slave to parallel interface
  //parallel interface
 begin

	if(Rst) begin
		//AXI4s.awaddr = 0;  // AXI Write address. The write address bus gives the address of the write transaction.
		//AXI4s.wdata = 0;  // Write data
		//AXI4s.wstrb = 0; // [3 : 0] Write strobes. This signal indicates which byte lanes to update in memory.

		//AXI4s.wvalid = 0; // Write valid. This signal indicates that valid write data and strobes are available.
		//AXI4s.awvalid = 0; //Write address valid. This signal indicates that a valid write address and control information are available
		AXI4s.bvalid = 0;// Write response valid. This signal indicates that a valid write response is available
		AXI4s.bresp  = 0; // Write response. This signal indicates the status of the write transaction
								// 00 = OKAY (normal response)
								// 10 = SLVERR (error condition)
								// 11 = DECERR (not issued by core)
		AXI4s.wready  = 0; // Write ready. This signal indicates that the slave can accept the write data.
		AXI4s.awready = 0; // Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals. 
		  
		/// read 
		//AXI4s.araddr  = 0; //Read address. The read address bus gives the address of a read transaction.
		// AXI4s.arvalid = 0; //Read address valid

		// AXI4s.bready = 0; //Response ready. This signal indicates that the master can accept the response information.
		// AXI4s.rready = 0; //Read ready. This signal indicates that the master can accept the read data and response information.
		AXI4s.rvalid = 0; //Read valid. This signal indicates that the required read data is available and the read transfer can complete.
		AXI4s.rresp  = 0;  // Read response. This signal indicates the status of
						  //the read transfer.
						  //00 = OKAY (normal response)
						  //10 = SLVERR (error condition)
						  //11 = DECERR (not issued by core)
		AXI4s.rdata   = 0; // Read data.
		AXI4s.arready = 0; // Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
		be			  <= 0;
	end
	else begin
	
		case (state_AXI4)
			idle_AXI4: begin
				if(AXI4s.bready) begin
					if(AXI4s.awvalid) begin
						addr  <= AXI4s.awaddr;
						AXI4s.awready <= 1; 
						enAddr = 1;
					end
					if(AXI4s.wvalid) begin
						data  <= AXI4s.wdata;
						AXI4s.wready <= 1;
						enData = 1;
					end
					
					if(enAddr & enData) begin
						wr 			 <= 1;
						be			 <= AXI4s.wstrb;
						AXI4s.bvalid <= 1;
						state_AXI4   <= stWR1_AXI4;
					end
					
				end
			end

			stWR1_AXI4: begin
					enAddr = 0;
					enData = 0;
					AXI4s.awready<= 0;
					AXI4s.wready <= 0;
					wr 			 <= 0;
					be			 <= 0;
					AXI4s.bvalid <= 0;

					state_AXI4   <= idle_AXI4;
			end

			default: state_AXI4 <= idle_AXI4;
		endcase
		AXI4s.rvalid <= AXI4s.arvalid;
	end
 end
 endtask
