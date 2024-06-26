// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [33:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg [bw*row-1:0] D_xmem_q1 = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem, D_xmem1;
reg [psum_bw*col-1:0] answer, answer1;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name, w_file_name1;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out, sfp_out1;

integer x_file, x_scan_file ; // file_handler
integer x_file1, x_scan_file1 ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer w_file1, w_scan_file1 ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer acc_file1, acc_scan_file1 ; // file_handler
integer out_file1, out_scan_file1 ; // file_handler
integer captured_data; 
integer captured_data1; 
integer t, i, j, k, kij;
integer error, error1;

assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance0 (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
  	.D(D_xmem_q), 
  	.sfu_out(sfp_out), 
	.reset(reset)); 

core  #(.bw(bw), .col(col), .row(row)) core_instance1 (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid1),
  	.D(D_xmem_q1), 
  	.sfu_out(sfp_out1), 
	.reset(reset)); 


initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  D_xmem1   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("./data/tile0/activation.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  x_file1 = $fopen("./data/tile1/activation.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file1 = $fscanf(x_file1,"%s", captured_data1);
  x_scan_file1 = $fscanf(x_file1,"%s", captured_data1);
  x_scan_file1 = $fscanf(x_file1,"%s", captured_data1);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); x_scan_file1 = $fscanf(x_file1,"%32b", D_xmem1); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "./data/tile0/weight0.txt";
     1: w_file_name = "./data/tile0/weight1.txt";
     2: w_file_name = "./data/tile0/weight2.txt";
     3: w_file_name = "./data/tile0/weight3.txt";
     4: w_file_name = "./data/tile0/weight4.txt";
     5: w_file_name = "./data/tile0/weight5.txt";
     6: w_file_name = "./data/tile0/weight6.txt";
     7: w_file_name = "./data/tile0/weight7.txt";
     8: w_file_name = "./data/tile0/weight8.txt";
    endcase

    case(kij)
     0: w_file_name1 = "./data/tile1/weight0.txt";
     1: w_file_name1 = "./data/tile1/weight1.txt";
     2: w_file_name1 = "./data/tile1/weight2.txt";
     3: w_file_name1 = "./data/tile1/weight3.txt";
     4: w_file_name1 = "./data/tile1/weight4.txt";
     5: w_file_name1 = "./data/tile1/weight5.txt";
     6: w_file_name1 = "./data/tile1/weight6.txt";
     7: w_file_name1 = "./data/tile1/weight7.txt";
     8: w_file_name1 = "./data/tile1/weight8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    w_file1 = $fopen(w_file_name1, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file1 = $fscanf(w_file1,"%s", captured_data1);
    w_scan_file1 = $fscanf(w_file1,"%s", captured_data1);
    w_scan_file1 = $fscanf(w_file1,"%s", captured_data1);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   





    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); w_scan_file1 = $fscanf(w_file1,"%32b", D_xmem1); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1;     
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Kernel data writing to L0 ///////
    A_xmem = 11'b10000000000;

    for (i=0; i<col; i=i+1) begin
      #0.5 clk = 1'b0; l0_rd = 0; l0_wr = 1; WEN_xmem = 1; CEN_xmem = 0; if (i>0) A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; CEN_xmem = 1; A_xmem = 0; l0_wr = 0;
    #0.5 clk = 1'b1;
    /////////////////////////////////////



    /////// Kernel loading to PEs ///////
    for (j=0; j<col; j=j+1) begin
      #0.5 clk = 1'b0; l0_rd = 1; load = 1;
      #0.5 clk = 1'b1;
    end
    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Activation data writing to L0 ///////
    A_xmem = 11'b00000000000;

    #0.5 clk = 1'b0; WEN_xmem = 1; CEN_xmem = 0;
    #0.5 clk = 1'b1;
    for (k=0; k<len_nij; k=k+1) begin
      #0.5 clk = 1'b0; l0_wr = 1; WEN_xmem = 1; CEN_xmem = 0; if (k>0) A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; CEN_xmem = 1; A_xmem = 0; l0_wr = 1;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0; l0_wr = 0;
    #0.5 clk = 1'b1;
    /////////////////////////////////////



    /////// Execution ///////
    for (i=0; i<len_nij; i=i+1) begin
      #0.5 clk = 1'b0; l0_rd = 1; execute = 1;
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; l0_rd = 0; execute = 0;
    #0.5 clk = 1'b1;

    for (i=0; i<len_nij; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;
    end 
    /////////////////////////////////////



    //////// OFIFO READ ////////
    // Ideally, OFIFO should be read while execution, but we have enough ofifo
    // depth so we can fetch out after execution.
    #0.5 clk = 1'b0; ofifo_rd = 1;
    #0.5 clk = 1'b1;
    for (i=0; i<len_nij-1; i=i+1) begin
      #0.5 clk = 1'b0; ofifo_rd = 1; WEN_pmem = 0; CEN_pmem = 0; if(i>0) A_pmem = A_pmem + 1;
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; ofifo_rd = 0; WEN_pmem = 0; CEN_pmem = 0; A_pmem = A_pmem + 1;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0; WEN_pmem = 1; CEN_pmem = 1; A_pmem = A_pmem + 1;
    #0.5 clk = 1'b1;
    /////////////////////////////////////


  end  // end of kij loop


  ////////// Accumulation /////////
  acc_file = $fopen("./data/tile0/acc_address.txt", "r");
  out_file = $fopen("./data/tile0/out.txt", "r");  
  acc_file1 = $fopen("./data/tile1/acc_address.txt", "r");
  out_file1 = $fopen("./data/tile1/out.txt", "r");  

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file1 = $fscanf(out_file1,"%s", answer1); 
  out_scan_file1 = $fscanf(out_file1,"%s", answer1); 
  out_scan_file1 = $fscanf(out_file1,"%s", answer1); 

  error1 = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 

    if (i>0) begin
     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       if (sfp_out == answer)
         $display("tile 0 %2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("tile 0 %2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %128b", sfp_out);
         $display("answer: %128b", answer);
         error = 1;
       end
    end

    if (i>0) begin
     out_scan_file1 = $fscanf(out_file1,"%128b", answer1); // reading from out file to answer
       if (sfp_out1 == answer1)
         $display("tile 1 %2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("tile 1 %2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %128b", sfp_out1);
         $display("answer: %128b", answer1);
         error1 = 1;
       end
    end
   
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  

    for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
        if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); acc_scan_file1 = $fscanf(acc_file1,"%11b", A_pmem); end
                       else  begin CEN_pmem = 1; WEN_pmem = 1; end

        if (j>0)  acc = 1;  
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0;
    #0.5 clk = 1'b1; 
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   D_xmem_q1   <= D_xmem1;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
end


endmodule




