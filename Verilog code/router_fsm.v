module   router_fsm(clk,rstn,pkt_vld,busy,parity_done,data_in,fifo_full,soft_rst_0,soft_rst_1,soft_rst_2,low_pkt_vld,
                     fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
                 
parameter decode_address  = 4'b0001;
parameter wait_till_empty = 4'b0010;
parameter load_first_data = 4'b0011;
parameter load_data       = 4'b0100;
parameter load_parity     = 4'b0101;
parameter fifo_full_state = 4'b0110;
parameter load_after_full = 4'b0111;
parameter check_parity_error = 4'b1000;


 input clk,rstn,pkt_vld,parity_done;
 input soft_rst_0,soft_rst_1,soft_rst_2;
 input fifo_full,low_pkt_vld;
 input fifo_empty_0,fifo_empty_1,fifo_empty_2;
 input [1:0] data_in;
 output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;
 
 reg [3:0] state,next_state;
  
 always@(posedge clk)
  begin
   if(!rstn)
     state <= decode_address;
   
   else if((soft_rst_0 && (data_in==2'b00)) || (soft_rst_1 && (data_in==2'b01))||(soft_rst_2 && (data_in==2'b10)))
     state <= decode_address;
	  
    
   else 
     state <= next_state;
     
  end
  
 always@(*)
   begin
     
	  next_state = decode_address;
	  
     case(state)
     
      decode_address : begin
                        
                        if((pkt_vld & (data_in[1:0] == 2'b00) & fifo_empty_0) ||
                           (pkt_vld & (data_in[1:0] == 2'b01) & fifo_empty_1) ||
                           (pkt_vld & (data_in[1:0] == 2'b10) & fifo_empty_2) )
                            
                         next_state = load_first_data;
                         
                        else if((pkt_vld & (data_in[1:0] == 2'b00) & ~fifo_empty_0) ||
                                (pkt_vld & (data_in[1:0] == 2'b01) & ~fifo_empty_1) ||
                                (pkt_vld & (data_in[1:0] == 2'b10) & ~fifo_empty_2) ) 
 
								 next_state = wait_till_empty;
  			 
  			 
								else 
  			    
								 next_state = decode_address;
							end
  			   
    load_first_data : 
      			
      			next_state = load_data;
      			
    load_data       :  
	              
			begin
    			
    			if(!fifo_full && !pkt_vld)
    			
    			  next_state = load_parity;
    			  
    			else if(fifo_full)
    			  
    			  next_state = fifo_full_state;
    			  
    			else
    			    
    			    next_state = load_data;
    		   end
    			    
    load_parity     : begin
	 
    
								next_state = check_parity_error;
    
							 end
		  
    check_parity_error  : begin
     				
     			   if(!fifo_full)
     			   
     			    next_state = decode_address;
     			    
     			   else if(fifo_full)
     			    
     			     next_state = fifo_full_state;
     			     
     			  end
     			  
    fifo_full_state  : begin
    			
    			if(!fifo_full)
    			
    			  next_state = load_after_full;
    			 
    			 else
    			    
    			    next_state = fifo_full_state;
    			    
    		       end
    		       
   load_after_full : begin
	
	          if(parity_done)
   			 
   			   next_state = decode_address;
   			 
   			 else if(!parity_done && !low_pkt_vld)
   			   
   			   next_state = load_data;
   			   
   			 else if(!parity_done && low_pkt_vld)	
   			   
   			   next_state = load_parity;
   			   
   			 
   			   
   		     end
   		     
   		     
  wait_till_empty : begin
  			
  			 if( (fifo_empty_0 &&(data_in[1:0] == 2'b00)) || (fifo_empty_1 &&(data_in[1:0] == 2'b01)) || (fifo_empty_2 &&(data_in[1:0] == 2'b10)) )
  			  
  			  next_state = load_first_data;
  			  
  			 else
  			  
  			   next_state = wait_till_empty;
  	
  	        end
 
   default : 
	          next_state = decode_address;
				 
   endcase
  end
  
	assign busy = ( state == load_first_data ) || ( state == load_parity ) || ( state == check_parity_error ) || 
                 ( state == fifo_full_state ) || ( state == load_after_full ) || ( state == wait_till_empty ) ? 1 :0;

	assign detect_add =  ( state == decode_address )?1:0;
	assign ld_state   =  ( state == load_data  )?1:0;
	assign laf_state  =  ( state == load_after_full )?1:0;
	assign full_state =  ( state == fifo_full_state )?1:0;
	assign write_enb_reg = ( state == load_data) ||  ( state == load_parity) || ( state == load_after_full)?1:0;
	assign rst_int_reg =  ( state == check_parity_error)?1:0;
	assign lfd_state = (state == load_first_data)?1:0;

endmodule
    
    			
    
     			
    			



