
module I2C(SDA, SCL, Clk, IRQ_in, RDY_out, Rst);//,\
    inout   SDA;
    output  SCL;
    input Clk;
    input Rst;
    input IRQ_in;
    
 typedef enum 
    {
        idle, st_wait1, st_wait2, 
        st_Start1, st_Start2, st_B_trans, st_Ack1, st_Ack2, st_P
    } fsm_state;
   fsm_state state;        
      
         
 logic [8:0] ctr_SCL;  
 logic str_SCL;  
 logic str_SCL_centr;  
 logic wr_b;
 logic rd_b;        
 logic [7:0] data_b;
 logic [7:0] shift_b; 
 logic [7:0] shift_b_in; 
 logic en_ctr_SCL;
 logic [7:0] ctr_shift;
 logic ack;
 logic SCL;
 logic SDA_sig;
 logic rdy;
 logic rd_en;
 logic set_confing;
 int i;
 logic [4:0] irq_others_sig;
 logic [15:0] out_reg;
 logic [10:0] ctr_wait;              
 logic delay;                
 logic delay_b;
 logic [7:0] irq_sh;  
 logic irq;              
 logic en_SDA = 0;       
                  
 task write;
     input [7:0] data;
     input next_state;
     input en_delay;
     main_fsm_state next_state;
 begin
     data_b   <= data;
     wr_b     <= 1'b1;
     delay_b  <= en_delay;
     state_reg_nm <= next_state;
     state_mn <= wait_rdy_nm;
 end
 endtask
 
 task read_b;
     input next_state;
     input en_delay;
     main_fsm_state next_state;
 begin
     rd_b     <= 1'b1;
     delay_b  <= en_delay;
     state_reg_nm <= next_state;
     state_mn <= wait_rdy_nm;
 end
 endtask
 //\\sign DATA = (en_SDA) ? SDA_sig : 1'bz;
           
 assign SDA =  (en_SDA) ? SDA_sig : 1'bz;

 always @(posedge Clk)
  begin
    if (Rst) begin
        str_SCL <= 1'b0;
        ctr_SCL <= 0;
        str_SCL_centr <= 1'b0;
        en_ctr_SCL <= 1'b0;
        SDA_sig <= 1'b1;
        SCL <= 1'b1;
        ctr_shift <= 0;
        rdy <= 1'b0;
        rd_en <= 1'b0;
        state_mn <= access_del;
        state    <= idle; 
        set_confing <= 1'b0;
        wr_MI <= 1'b0;
        ctr_wait    <= 0;
        delay_b     <= 0;
        delay       <= 0;
        wr_b        <= 1'b0;
        data_b      <= 0;
        irq_sh      <= 0;
        irq     <= 0;
        rd_b    <= 0;
        en_SDA  <= 0;
     end
    else begin


    ///// Byte transmit/receve FSM
        case (state)
            idle: begin
                if (wr_b) begin
                    state <= st_Start1;
                    shift_b <= data_b;
                    ctr_wait <= 0;
                 end
                else if  (str_SCL_centr & (SCL)) begin
                    en_ctr_SCL <= 1'b0;
                    SDA_sig <= 1'b1;// 1'bZ;
                    en_SDA  <= 1'b0;
                end
                rdy <= 1'b0;
              end

            st_Start1: begin
                en_SDA  <= 1'b1;            
                SDA_sig <= 1'b0;
                if (ctr_wait == 240) begin
                    en_ctr_SCL <= 1'b1;
                    state <= st_Start2;
                end
                ctr_wait <= ctr_wait + 1;
            end

            st_Start2: begin
                if(str_SCL_centr) state <= st_B_trans;
                
              end

            st_B_trans: begin
                if (str_SCL_centr & ((SCL & rd_en) | (!(SCL | rd_en)))) begin
                    if (ctr_shift == 7) begin
                        state <= st_Ack1;
                        ctr_shift <= 0;
                     end
                     else  ctr_shift <= ctr_shift + 1;

                    if (rd_en) begin
                        shift_b_in <={shift_b_in[6:0] , SDA};
                    SDA_sig <= 1'b1;// 1'bZ;
                    en_SDA  <= 1'b0;
                    end 
                    else begin
                        SDA_sig <= shift_b[7];
                        en_SDA  <= 1'b1;
                        shift_b[7:1] <= shift_b[6:0];
                    end
                end                
             end

            st_Ack1: begin
                if (str_SCL_centr & !SCL) begin
                    if (rd_en & !delay_b) begin
						SDA_sig <= 1'b0;
						en_SDA  <= 1'b1;
					 end
                    else begin
						SDA_sig <= 1'b1;// 1'bZ;
						en_SDA  <= 1'b0;
					end
                    state <= st_Ack2;
                end
            end

            st_Ack2: begin
                if (str_SCL_centr & ((!rd_en & SCL) | (rd_en & !SCL))) begin
                   // if (!rd_en) begin
						SDA_sig <= 1'b1;// 1'bZ;
						en_SDA  <= 1'b0;
                        if (rd_en) ack <= 0;
                        else       ack <= SDA;
                        state <= st_P;
                        rdy <= 1'b1;
                   // end
                   if (rd_en) begin
                     if (state_reg_nm == read_nm2) input_port0_VV <= shift_b_in;
                     if (state_reg_nm == read_nm3) input_port1_VV <= shift_b_in;
                     if (state_reg_nm == read_nm5) input_port0_MI <= shift_b_in;
                     if (state_reg_nm == idle_mn)  input_port1_MI <= shift_b_in;
                   end
                end                
            end

            st_wait1: begin
                if (str_SCL_centr & SCL) begin
                   en_ctr_SCL  <= 0;
                   rd_en <= 1'b0;
                end
                else if (str_SCL_centr & (!SCL)) begin 
					en_SDA  <= 1'b1;
                     SDA_sig <= 1'b0;
                end

                if (ctr_wait == 420) begin
						SDA_sig <= 1'b1;// 1'bZ;
						en_SDA  <= 1'b0;
                    state       <= st_wait2;
                    ctr_wait    <= 0;
                end
                else ctr_wait <= ctr_wait + 1;
            end

            st_wait2:begin
                if (ctr_wait == 360) begin
                    rdy <= 1'b1;
                    state <= idle;  end 
                else begin
                    ctr_wait <= ctr_wait + 1;
                    state <= st_wait2;
                end 
            end

            st_P: begin
                rdy <= 1'b0;
                if (str_SCL_centr & (!SCL)) begin
                 						
				    en_SDA  <= 1'b1;
                    SDA_sig <= 1'b0;
                    state <= idle;
                    rd_en <= 1'b0;
                 end   
                else if (wr_b) begin
                    state <= st_B_trans;
                    shift_b <= data_b;
                    rd_en <= 1'b0;
                end 
                else if (rd_b) begin
                    state <= st_B_trans;
                    rd_en <= 1'b1;
                end
                else if (delay) begin
                    state       <= st_wait1;
                    if (rd_en) begin
						SDA_sig     <= 1'b0;	
						en_SDA  <= 1'b1;
					end
                    else  begin
						SDA_sig <= 1'b1;// 1'bZ;
						en_SDA  <= 1'b0;
					end
                    ctr_wait    <= 0;
                end
            end
            default: ;
        endcase


//        if (reconfig) set_confing <= 1'b0;
//        else 
            if (state_mn == confing_mn8) set_confing <= 1'b1;

        //// ctr_SCL
        if (en_ctr_SCL) begin
            if (ctr_SCL == 75) begin
                ctr_SCL  <= 0;
                str_SCL  <= 1'b1;
                SCL      <= !SCL; 
             end
            else begin
                ctr_SCL <= ctr_SCL + 1;
                str_SCL <= 1'b0;
            end                    
         end
        else begin
            ctr_SCL <= 0;
            str_SCL <= 1'b0;
            SCL     <= 1'b1;
        end

        if (ctr_SCL == 38)  str_SCL_centr <= 1'b1; 
        else                str_SCL_centr <= 1'b0;
         
    end
  end            

endmodule
