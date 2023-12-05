module sfu1(/*AUTOARG*/
	   // Outputs
	   ofifo_rd, psum_mem_rd, psum_mem_wr, psum_mem_din,
	   // Inputs
	   clk, reset, acc, relu, ofifo_out, ofifo_valid, psum_mem_dout
	   );

   parameter col = 8;
   parameter psum_bw = 16;

   input clk, reset;
   input acc, relu;

   input [col*psum_bw-1:0] ofifo_out;
   input 		   ofifo_valid;
   output 		   ofifo_rd, 

			   output psum_mem_rd;
   output reg 			  psum_mem_wr;
   input [col*psum_bw-1:0] 	  psum_mem_dout;
   output reg [col*psum_bw-1:0]   psum_mem_din;


   assign psum_mem_rd = ofifo_valid;
   assign ofifo_rd = ofifo_valid;
   assign out = psum_q;   

   always @(posedge clk) begin
      if(reset)
	psum_mem_wr <= 0;
      else
	psum_mem_wr <= psum_mem_rd;
   end

   genvar 			  i;

   for (i = 0; i < col; i=i+1) begin: acc_col
      always @(posedge clk) begin
	 if(acc) 
	   psum_mem_din[(i+1)*psum_bw-1:i*psum_bw] <= psum_mem_dout[(i+1)*psum_bw-1:i*psum_bw] + ofifo_out[(i+1)*psum_bw-1:i*psum_bw];
	 if(relu) 
	   psum_mem_din[(i+1)*psum_bw-1:i*psum_bw] <= (psum_mem_dout[(i+1)*psum_bw-1:i*psum_bw] > 0)?psum_mem_dout[(i+1)*psum_bw-1:i*psum_bw]:{(psum_bw){1'b0}};  	
      end
   
end

   always @(posedge reset or posedge clk) begin
      if(reset)
	psum_q <= 0;
      else
	if(acc)
	  psum_q <= psum_q + in;
	else if(relu)
	  psum_q <= (psum_q < thres) ? 0 : psum_q;
   end
   
endmodule
