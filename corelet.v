module corelet(/*AUTOARG*/
   // Outputs
   sfu_out, ofifo_valid, ofifo_out,
   // Inputs
   clk, reset, inst, relu, l0_in, sfu_in
   );
   parameter psum_bw = 16;
   parameter bw = 4;
   parameter row = 8;
   parameter col = 8;

   /*
inst_q[33] = acc_q;        inst_q[32] = CEN_pmem_q;
inst_q[31] = WEN_pmem_q;   inst_q[30:20] = A_pmem_q;
inst_q[19]   = CEN_xmem_q; inst_q[18]   = WEN_xmem_q;
inst_q[17:7] = A_xmem_q;   inst_q[6]   = ofifo_rd_q;
inst_q[5]   = ififo_wr_q;  inst_q[4]   = ififo_rd_q;
inst_q[3]   = l0_rd_q;     inst_q[2]   = l0_wr_q;
inst_q[1]   = execute_q;   inst_q[0]   = load_q; 
*/

   input     clk, reset;
   input [33:0]	inst;
   input	relu;
   
   input [row*bw-1:0] l0_in;

   input [psum_bw*col-1 : 0] sfu_in;
   output [psum_bw*col-1 : 0] sfu_out;

   output		      ofifo_valid;
   output [psum_bw*col-1 : 0] ofifo_out;

   /*AUTOREG*/   
   wire [psum_bw*col-1:0] in_n;

   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			l0_full;		// From l0_inst of l0.v
   wire [row*bw-1:0]	l0_out;			// From l0_inst of l0.v
   wire			l0_ready;		// From l0_inst of l0.v
   wire			ofifo_full;		// From ofifo_inst of ofifo.v
   wire			ofifo_ready;		// From ofifo_inst of ofifo.v
   wire [psum_bw*col-1:0] out_s;		// From mac_array_inst of mac_array.v
   wire [col-1:0]	valid;			// From mac_array_inst of mac_array.v
	wire [1:0]  inst_w;
   // End of automatics


   //l0 
   assign l0_wr = inst[2];
   assign l0_rd = inst[3];

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
	      .l0_in			(l0_in[row*bw-1:0]));

   //mac_array
   assign inst_w = inst[1:0];
   assign in_n = 128'b0;
   mac_array #(/*AUTOINSTPARAM*/
	       // Parameters
	       .bw			(bw),
	       .psum_bw			(psum_bw),
	       .col			(col),
	       .row			(row)) mac_array_inst(
						 // Inputs
						 .in_w       (l0_out[row*bw-1:0]), // from l0
						 /*AUTOINST*/
							      // Outputs
							      .out_s		(out_s[psum_bw*col-1:0]),
							      .valid		(valid[col-1:0]),
							      // Inputs
							      .clk		(clk),
							      .reset		(reset),
							      .inst_w		(inst_w[1:0]),
							      .in_n		(in_n[psum_bw*col-1:0])
									);
   
   //ofifo
   assign ofifo_rd = inst[6];
   ofifo #(/*AUTOINSTPARAM*/
	   // Parameters
	   .col				(col),
	   .bw			  	(psum_bw)) ofifo_inst(
                        // Inputs
                        .ofifo_in		(out_s[psum_bw*col-1:0]), // from mac_array
                        .ofifo_wr		(valid[col-1:0]),         // from mac_array
                        /*AUTOINST*/
							 // Outputs
							 .ofifo_out		(ofifo_out[col*psum_bw-1:0]),
							 .ofifo_full		(ofifo_full),
							 .ofifo_ready		(ofifo_ready),
							 .ofifo_valid		(ofifo_valid),
							 // Inputs
							 .clk			(clk),
							 .reset			(reset),
							 .ofifo_rd		(ofifo_rd));

   //sfu
   genvar		      i;
   assign acc = inst[33];
   assign thres = 16'b0;
	generate
   for (i=1; i < col+1 ; i=i+1) begin : col_num
      sfu #(/*AUTOINSTPARAM*/
	    // Parameters
	    .bw				(bw),
	    .psum_bw			(psum_bw)) sfu_instance(
					    // Outputs
					    .sfu_out(sfu_out[i*psum_bw-1 : (i-1)*psum_bw]),
					    // Inputs
					    .clk(clk),
					    .reset(reset),
					    .relu(relu),
					    .acc(acc),
					    .sfu_in(sfu_in[i*psum_bw-1 : (i-1)*psum_bw]), 
					    .thres(thres)
					    );
   end
	endgenerate
   
endmodule // corelet
