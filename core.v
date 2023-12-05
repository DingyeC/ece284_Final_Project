module core(/*AUTOARG*/
   // Outputs
   sfu_out, ofifo_valid,
   // Inputs
   clk, reset, inst, D
   );

parameter bw = 4;
parameter col = 8;
parameter row = 8;
parameter psum_bw = 16;

input clk, reset;
input [34:0] inst;

input [bw*row-1:0] D;

output [col*psum_bw-1:0] sfu_out;
output ofifo_valid;

/*AUTOREG*/

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [psum_bw*col-1:0]	ofifo_out;		// From corelet_instance of corelet.v
wire [psum_bw*col-1:0]  sfu_in;
wire [row*bw-1:0]       l0_in;
// End of automatics 

corelet #(/*AUTOINSTPARAM*/
	  // Parameters
	  .psum_bw			(psum_bw),
	  .bw				(bw),
	  .row				(row),
	  .col				(col)) corelet_instance(/*AUTOINST*/
								// Outputs
								.sfu_out	(sfu_out[psum_bw*col-1:0]),
								.ofifo_valid	(ofifo_valid),
								.ofifo_out	(ofifo_out[psum_bw*col-1:0]),
								// Inputs
								.clk		(clk),
								.reset		(reset),
								.inst		(inst[33:0]),
								.relu		(relu),
								.l0_in		(l0_in[row*bw-1:0]),
								.sfu_in		(sfu_in[psum_bw*col-1:0]));

assign xmem_A   = inst[17:7];
assign WEN_xmem = inst[18];
assign CEN_xmem = inst[19];
assign pmem_A   = inst[30:20];
assign WEN_pmem = inst[31];
assign CEN_pmem = inst[32];

//Activation & Weight SRAM
sram_32b_w2048 #(.num(2048)) xmem_sram(
    .CLK(clk),
    .WEN(WEN_xmem),
    .CEN(CEN_xmem),
    .D(D),
    .A(xmem_A),
    .Q(l0_in)
);

//Psum SRAM
sram_128b_w2048 #(.num(2048)) pmem_sram(
    .CLK(clk),
    .WEN(WEN_pmem),
    .CEN(CEN_pmem),
    .D(ofifo_out),
    .A(pmem_A),
    .Q(sfu_in)
);

endmodule
