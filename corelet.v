module corelet(/*AUTOARG*/
   // Outputs
   ofifo_full, ofifo_ready, l0_out, l0_full, l0_ready, psum_mem_rd,
   psum_mem_wr, psum_mem_din,
   // Inputs
   clk, reset, acc, relu, inst_w, mode, l0_in, l0_rd, l0_wr,
   psum_mem_dout
   );
   parameter psum_bw = 16;
   parameter bw = 4;
   parameter row = 8;
   parameter col = 8;

   input clk,reset;
   input acc,relu;
   
   input [1:0] inst_w;
   input       mode;  

   output      ofifo_full;
   output      ofifo_ready;
   
   input [row*bw-1:0] l0_in;
   input 	l0_rd;
   input 	l0_wr;
   output [row*bw-1:0] l0_out;
   output 	       l0_full;
   output 	       l0_ready;
   
   output 	       psum_mem_rd;
   output 	       psum_mem_wr;
   input [col*psum_bw-1:0] psum_mem_dout;
   output [col*psum_bw-1:0] psum_mem_din;

   reg [psum_bw*col-1:0] 	    in_n = 0;
   
   /*AUTOREG*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [col*bw-1:0]	ofifo_out;		// From ofifo_inst of ofifo.v
   wire			ofifo_rd;		// From sfu_inst of sfu.v
   wire			ofifo_valid;		// From ofifo_inst of ofifo.v
   wire [psum_bw*col-1:0] out_s;		// From mac_array_inst of mac_array.v
   wire [col-1:0]	valid;			// From mac_array_inst of mac_array.v
   // End of automatics

   l0 l0_inst(/*AUTOINST*/
	      // Outputs
	      .l0_out			(l0_out[row*bw-1:0]),
	      .l0_full			(l0_full),
	      .l0_ready			(l0_ready),
	      // Inputs
	      .clk			(clk),
	      .l0_wr			(l0_wr),
	      .l0_rd			(l0_rd),
	      .reset			(reset),
	      .mode			(mode),
	      .l0_in			(l0_in[row*bw-1:0]));

   ofifo ofifo_inst(
		    // Inputs
		    .ofifo_in		(out_s[psum_bw*col-1:0]),
		    .ofifo_wr		(valid[col-1:0]),
		    /*AUTOINST*/
		    // Outputs
		    .ofifo_out		(ofifo_out[col*bw-1:0]),
		    .ofifo_full		(ofifo_full),
		    .ofifo_ready	(ofifo_ready),
		    .ofifo_valid	(ofifo_valid),
		    // Inputs
		    .clk		(clk),
		    .reset		(reset),
		    .ofifo_rd		(ofifo_rd));

   mac_array mac_array_inst(
			    // Inputs
			    .in_w               (l0_out[row*bw-1:0]),
                            /*AUTOINST*/
			    // Outputs
			    .out_s		(out_s[psum_bw*col-1:0]),
			    .valid		(valid[col-1:0]),
			    // Inputs
			    .clk		(clk),
			    .reset		(reset),
			    .inst_w		(inst_w[1:0]),
			    .in_n		(in_n[psum_bw*col-1:0]));
   
   sfu sfu_inst(/*AUTOINST*/
		// Outputs
		.ofifo_rd		(ofifo_rd),
		.psum_mem_rd		(psum_mem_rd),
		.psum_mem_wr		(psum_mem_wr),
		.psum_mem_din		(psum_mem_din[col*psum_bw-1:0]),
		// Inputs
		.clk			(clk),
		.reset			(reset),
		.acc			(acc),
		.relu			(relu),
		.ofifo_out		(ofifo_out[col*psum_bw-1:0]),
		.ofifo_valid		(ofifo_valid),
		.psum_mem_dout		(psum_mem_dout[col*psum_bw-1:0]));
   
endmodule // corelet
