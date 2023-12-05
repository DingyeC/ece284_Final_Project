// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module l0 (/*AUTOARG*/
   // Outputs
   l0_out, l0_full, l0_ready,
   // Inputs
   clk, l0_wr, l0_rd, reset, mode, l0_in
   );

  parameter row  = 8;
  parameter bw = 4;

  input  clk;
  input  l0_wr;
  input  l0_rd;
  input  reset;
  input mode;
  input  [row*bw-1:0] l0_in;
  output [row*bw-1:0] l0_out;
  output l0_full;
  output l0_ready;

  wire [row-1:0] empty;
  wire [row-1:0] full;
  reg [row-1:0] rd_en;

  genvar i;

  assign l0_ready = ~l0_full ;
  assign l0_full  = |(full) ;


  for (i=0; i<row ; i=i+1) begin : row_num
      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd_en[i]),
	 .wr(l0_wr),
         .o_empty(empty[i]),
         .o_full(full[i]),
	 .in(l0_in[(i+1)*bw-1:i*bw]),
	 .out(l0_out[(i+1)*bw-1:i*bw]),
         .reset(reset));
  end

   always @ (posedge clk) begin
      if (reset) begin
	 rd_en <= 8'b00000000;
      end
      else
	if(mode) begin
	   rd_en <= {(row){l0_rd}};
	end
	else begin
	   rd_en <= {rd_en[row-2:0],l0_rd};
	end
   end

endmodule
