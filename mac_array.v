// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

   parameter bw = 4;
   parameter psum_bw = 16;
   parameter col = 8;
   parameter row = 8;

   input     clk, reset;
   output [psum_bw*col-1:0] out_s;
   input [row*bw-1:0]	    in_w; // inst[1]:execute, inst[0]: kernel loading
   input [1:0]		    inst_w;
   input [psum_bw*col-1:0]  in_n;
   output [col-1:0]	    valid;
	reg [2*row-1:0] inst_w_array;
	wire [psum_bw*col*(row+1)-1:0] n_s_array;
	wire [row*col-1:0] valid_array;
	

	genvar i;
	generate
   for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
							      .clk    (clk),
							      .reset  (reset),
							      .in_w   (in_w[bw*i-1 : bw*(i-1)]), 
							      .inst_w (inst_w_array[2*i-1 : 2*(i-1)]),        
							      .in_n   (n_s_array[psum_bw*col*i-1 : psum_bw*col*(i-1)]),     
							      .out_s  (n_s_array[psum_bw*col*(i+1)-1 : psum_bw*col*i]), 
							      .valid  (valid_array[col*i-1 : col*(i-1)])
							      );
   end
	endgenerate

   always @ (posedge clk) begin
      // inst_w flows to row0 to row7
      inst_w_array <= {inst_w_array[row*2-1-2 : 0] , inst_w};
   end

endmodule
