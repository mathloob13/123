module router_top(clk,rstn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,
		  data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,busy,error);
		  
input  clk,rstn,read_enb_0,read_enb_1,read_enb_2,pkt_valid ;
input  [7:0] data_in;
output  [7:0] data_out_0,data_out_1,data_out_2;
output  valid_out_0,valid_out_1,valid_out_2,busy,error;

wire [2:0] write_enb;
wire  empty_0,empty_1,empty_2;
wire  full_0,full_1,full_2;
/*wire  soft_reset_0,soft_reset_1,soft_reset_2;
wire  fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state;
wire  rst_int_reg,parity_done,low_packet_valid,write_enb_reg;*/
wire [7:0] data_out;

router_fifo FIFO_0( .clk(clk),
                   .resetn(rstn),
						 .write_enb(write_enb[0]), //wr
                   .soft_reset(soft_reset_0),
                   .read_enb(read_enb_0),  //rd
                   .datain(data_out),
                   .dataout(data_out_0),
                   .full(full_0),
                   .empty(empty_0),
                   .lfd_state(lfd_state) );
                   
							   
router_fifo FIFO_1( .clk(clk),
                   .resetn(rstn),
          	       .write_enb(write_enb[1]), //wr
                   .soft_reset(soft_reset_1),
                   .read_enb(read_enb_1),  //rd
                   .datain(data_out),
                   .dataout(data_out_1),
                   .full(full_1),
                   .empty(empty_1),
                   .lfd_state(lfd_state) );
                   
                   
router_fifo FIFO_2( .clk(clk),
                   .resetn(rstn),
          	       .write_enb(write_enb[2]), //wr
                   .soft_reset(soft_reset_2),
                   .read_enb(read_enb_2),  //rd
                   .datain(data_out),
                   .dataout(data_out_2),
                   .full(full_2),
                   .empty(empty_2),
                   .lfd_state(lfd_state) );
                   
                   
 
 router_fsm FSM( .clk(clk),
                 .busy(busy),
                 .rstn(rstn),
                 .pkt_vld(pkt_valid),   	
                 .parity_done(parity_done),
                 .data_in(data_in[1:0]),
                 .fifo_full(fifo_full),
                 .soft_rst_0(soft_reset_0),
                 .soft_rst_1(soft_reset_1),
                 .soft_rst_2(soft_reset_2),
                 .low_pkt_vld(low_pkt_valid),
                 .fifo_empty_0(empty_0),
                 .fifo_empty_1(empty_1),
                 .fifo_empty_2(empty_2),
                 .detect_add(detect_add),
                 .ld_state(ld_state),
                 .laf_state(laf_state),
                 .full_state(full_state),
                 .write_enb_reg(write_enb_reg),
                 .rst_int_reg(rst_int_reg),
                 .lfd_state(lfd_state)  );
                 
              
 router_sync SYNCHRONISER (.clk(clk),
									.resetn(rstn),
									.detect_add(detect_add),
									.write_enb_reg(write_enb_reg),
									.read_enb_0(read_enb_0),	
									.read_enb_1(read_enb_1),
									.read_enb_2(read_enb_2),
									.empty_0(empty_0),
									.empty_1(empty_1),
									.empty_2(empty_2),
									.full_0(full_0),  
									.full_1(full_1),
									.full_2(full_2),
									.datain(data_in[1:0]),
									.vld_out_0(valid_out_0),
									.vld_out_1(valid_out_1),
									.vld_out_2(valid_out_2),
									.write_enb(write_enb),
									.fifo_full(fifo_full),
									.soft_reset_0(soft_reset_0),
									.soft_reset_1(soft_reset_1),
									.soft_reset_2(soft_reset_2) );
                   	   
               
 router_reg REGISTER  (.clk(clk),	
                       .resetn(rstn),
                       .pkt_valid(pkt_valid),
                       .data_in(data_in),
                       .fifo_full(fifo_full),
                       .rst_int_reg(rst_int_reg),
                       .detect_add(detect_add),
                       .ld_state(ld_state),
                       .laf_state(laf_state),
                       .full_state(full_state),
                       .lfd_state(lfd_state),
                       .parity_done(parity_done),
                       .low_pkt_valid(low_pkt_valid),
                       .err(error),
                       .data_out(data_out) );
   
/*	property p1;
		@(posedge clock) pkt_valid |=> busy;
	endproperty
	
	property p2;
		@(posedge clock) busy |=> $stable(data_in);
	endproperty
	
	property p3;
		@(posedge clock) valid_out |-> ##[0:29] read_enb;
	endproperty
	
	property p4;
		@(posedge clock) pkt_valid |-> ##3 valid_out;
	endproperty
	
	property p5;
		@(posedge clock) !valid_out |=> !read_enb;
	endproperty
	
	A1 : assert property (p1);
	A2 : assert property (p2);
	A3 : assert property (p3);
	A4 : assert property (p4);
	A5 : assert property (p5);
		
 */
 
 
	property p1;
			@(posedge clk)  $rose(src_inf.pkt_valid) |=> $rose(src_inf.busy);
	endproperty
	
	property p2;
		@(posedge clk) src_inf.busy |=> $stable(src_inf.data_in);
	endproperty
	
	property p3;
		@(posedge clk) 	 $rose(dst_inf0.valid_out) |-> ##[0:29] dst_inf0.read_enb;
	endproperty

	property p4;
		@(posedge clk) 	 $rose(dst_inf1.valid_out) |-> ##[0:29] dst_inf1.read_enb;
	endproperty

	property p5;
		@(posedge clk) 	 $rose(dst_inf2.valid_out) |-> ##[0:29] dst_inf2.read_enb;
	endproperty
	
	property p6;
		@(posedge clk) 	 $rose(src_inf.pkt_valid) |-> ##3 (dst_inf0.valid_out)|(dst_inf1.valid_out)|(dst_inf2.valid_out);
	endproperty
	
	property p7;
		@(posedge clk)  $fell(dst_inf0.valid_out) |=> $fell(dst_inf0.read_enb);
	endproperty

	property p8;
		@(posedge clk) 	 $fell(dst_inf1.valid_out) |=> $fell(dst_inf1.read_enb);
	endproperty

	property p9;
		@(posedge clk) 	 $fell(dst_inf2.valid_out) |=> $fell(dst_inf2.read_enb);
	endproperty


	
	A1 : assert property (p1);
	A2 : assert property (p2);
	A3 : assert property (p3);
	A4 : assert property (p4);
	A5 : assert property (p5);
	A6 : assert property (p6);
	A7 : assert property (p7);
	A8 : assert property (p8);
	A9 : assert property (p9);


 
 
 
 endmodule                    
                   



