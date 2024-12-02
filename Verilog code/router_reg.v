module router_reg(clk,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,
                  parity_done,low_pkt_valid,err,data_out);
                 
input clk,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
input [7:0]data_in;
output reg [7:0]data_out;
output reg  parity_done,low_pkt_valid,err;

reg [7:0]hold_header_byte;
reg [7:0]fifo_full_state;
reg [7:0]internal_parity_byte;
reg [7:0]packet_parity_byte;

// logic for parity done`
 always@(posedge clk)
   begin
     if(!resetn)
       begin
         parity_done <= 1'b0;
       end
      
     else
       
       begin
          
          if(ld_state && fifo_full && !pkt_valid)
            
             parity_done <= 1'b1;
           
          else if(laf_state && low_pkt_valid && !parity_done)
             
             parity_done <= 1'b1;
 
          else 
            
             begin
              
               if(detect_add)
                
                 parity_done <= 1'b0;
                 
             end
             
        end
        
     end
     
// logic for low packet valid
 
  always@(posedge clk)
    begin
      if(!resetn)
        begin
          low_pkt_valid <= 1'b0;
        end
        
        else 
           
           begin
             
              if(rst_int_reg)
                
                low_pkt_valid <= 1'b0;
               
              else if(ld_state==1'b1 && pkt_valid ==1'b0)
                
                 low_pkt_valid <= 1'b1;
                 
           end
           
      end
      
      
  // logic for data_out
      
  always@(posedge clk)
     begin 
        if(!resetn)
          begin
            data_out <= 8'b0;
          end
          
        else
          begin
             
              if(detect_add && pkt_valid)
                
                   hold_header_byte <= data_in;
              
              else if(lfd_state)
               
                   data_out <= hold_header_byte;
                   
              else if(ld_state && !fifo_full)
              
                   data_out <= data_in;
                   
              else if(ld_state && fifo_full)
                  
                   fifo_full_state <= data_in;
                   
              else
                
                 begin 
                    
                     if(laf_state)
                      
                        data_out <= fifo_full_state;
                 end
                   
          end         
                      
     end
     
// logic for internal parity 
     
 always@(posedge clk)
     begin
        if(!resetn)
           begin
             internal_parity_byte <= 8'b0;
           end
			  
			  else if(lfd_state)
                   
                   internal_parity_byte <= internal_parity_byte^hold_header_byte;
                   
              else if(pkt_valid && ld_state && !full_state)
                      
                         internal_parity_byte <= internal_parity_byte^data_in;
           
         else 
           
            begin
              
              if(detect_add)
               
					 begin
					 
                  internal_parity_byte <= 8'b0;
         
                  end    
  
           end
           
      end
      
      
  //logic for packet parity calculation
     
    always@(posedge clk)
     begin
         if(!resetn)
           begin
            packet_parity_byte <= 8'b0;      
           end
       
                    
        else if(ld_state && !pkt_valid)
           
            packet_parity_byte <= data_in;
            
        else 
           
           packet_parity_byte <=packet_parity_byte ;
           
         
      end
  
  //logic for error signal
    
    always@(posedge clk)
      begin
        if(!resetn)
          begin
            err <= 1'b0;
          end
          
          else
            
             begin 
                
                 if(parity_done)
                   
                    begin
                       
                       if(packet_parity_byte != internal_parity_byte)
                       
                         err <= 1'b1;
                       
                       else 
                         
                          err <= 1'b0;
                          
                    end
              
             end         
           
       end
       
       
endmodule   
        
          
                   
       
              
                
                  
        
      



