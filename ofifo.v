// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module ofifo (/*AUTOARG*/
   // Outputs
   ofifo_out, ofifo_full, ofifo_ready, ofifo_valid,
   // Inputs
   clk, reset, ofifo_wr, ofifo_rd, ofifo_in
   );

  parameter col  = 8;
  parameter bw = 16;

  input  clk;
  input  reset;
  input  [col-1:0] ofifo_wr;
  input  ofifo_rd;
  input  [col*bw-1:0] ofifo_in;
  output [col*bw-1:0] ofifo_out;
  output ofifo_full;
  output ofifo_ready;
  output ofifo_valid;

  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg  rd_en;
  
  genvar i;

  assign ofifo_ready = ~empty[col-1] ;
  assign ofifo_full  = |full ;
  assign ofifo_valid = &(~empty) ;

  for (i=0; i<col ; i=i+1) begin : col_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en),
	 .wr(ofifo_wr[i]),
         .o_empty(empty[i]),
         .o_full(full[i]),
	 .in(ofifo_in[(i+1)*bw-1:i*bw]),
	 .out(ofifo_out[(i+1)*bw-1:i*bw]),
         .reset(reset));
  end


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 0;
   end
   else
      
     rd_en <= ofifo_rd;
 
  end


 

endmodule
