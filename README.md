# ece284_Final_Project
Project: VGGNet on 2D systolic array and mapping on Cyclone IV GX


Part1. Train VGG16 with quantization-aware training (15%)

     - Train for 4-bit input activation and 4-bit weight to achieve >90% accuracy.

     - But, this time, reduce a certain convolution layer's input channel numbers to be 8 and output channel numbers to be 8.

     - Also, remove the batch normalization layer after the squeezed convolution.

      e.g., replace "conv -> relu -> batchnorm" with "conv -> relu"

     - This layer will be mapped on your 8x8 2D systolic array. Thus, reducing to 8 channels helps your layer's mapping in an array nicely without tiling.

     - This time, compute your "psum_recovered" such as HW5 including ReLU and compare with your prehooked input for the next layer (instead of your computed psum_ref).

     - [hint] It is recommended not to reduce the input channel of Conv layer at too early layer position because the early layer's feature map size (nij) is large incurring long verification cycles.

       (recommended location: around 27-th layer, e.g., features[27] for VGGNet)

     - Measure of success: accuracy >90%  with 8 input/output channels + error < 10^-3 for psum_recorvered for VGGNet.

 

Part2. Complete RTL core design connecting the following blocks: (10%)

     - 2D array with mac units 

     - Scratchpad memories for 1. activation & weight (input) SRAM, and 2. psum SRAM (for psum you might need multiple banks)

     - L0 and output FIFO (Note you do not use IFIFO in this project because the weight will be given from west to east via L0)

     - Special function processor (for accumulation and ReLU)

     - On the other hand, a corelet.v includes all the other blocks (e.g., L0, 2d PE array, ofifo) other than SRAMs.

       As only corelet.v will be applied on the FPGA board, the above hierarchy helps Part5.

     - Measure of success: Completion of your entire core design, and no compilation error after all the connection

 

Part3. Test bench generation to run following stages: (20%)

     - Please use the testbench template (core_tb.v in the "project" directory in git)

     - Your testbench has accessibility to the ports of your core.v (So, your testbench is a sort of controller)

     - Complete the following stages: (Note you need to verify only 1 layer, which is 8x8 channels, not all the layers)

       1) Input SRAM loading for weight and activation (e.g., from DRAM, which is emulated by your testbench)

       2) Kernel data loading to PE register (via L0)

       3) L0 data loading

       4) Execution with PEs 

       5) Psum movement to psum SRAM (via OFIFO)

       6) Accumulation in SFU and store back to psum SRAM

       7) ReLU in SFU and store back to psum SRAM

       8) Generating text stimulus vector (input.txt, weight.txt) and expected output (output.txt) text files for the squeezed layer as you did in HW7.

       9) Apply the stimulus text file to your testbench (core_tb.v) to run all the stages described in Part3.

      10) Verify your results are the same as the expected output text file.

     Measure of success:

     - generation of your stimulus and expected output files, and zero verification error compared output.txt.

     - TA will test your design with their own input.txt, weight.txt, and output.txt and it must pass. 

 

Part4. Mapping on FPGA (Cyclone IV GX EP4CGX150DF31I7AD)  (5%)

(More details will be given in upcoming classes)

     - Installation guideline is given in Pages / Course resources tab.

     - Map your corelet.v (NOT core.v) on FPGA via Quartus Prime 19.1.

     - Complete synthesis and placement/route.

     - Measure your frequency at the slow corner.

     - Measure your power with a 20% input activity factor. 

     - Note this is not frequency competition. This is just for students to go through the entire step.

     - This is only required for Vanilla version only. Feel free to extend this part to +alpha if you can show some improvement with this.

     Measure of success: reporting the final frequency + power numbers + and specs in TOPs/W, TOPs/mm2 and TOPS/s.

 

Part5. Multi-channel implementation in each PE (10%)

     - You are supposed to implement the execution of multi-channel in each PE, and modify all the corresponding implementations (array, core, and so on) in verilog / testbench / verification.

     - Please listen to the explanation in class.

     - You could choose any channel number to be processed in each PE, e.g., 2 / 4 / 8. B

     - But, 8 X 8 PE should be maintained. So, you could compute 16 input channel and 8 output channels if you choose 2 input channels per PE.

     - Thus, you should train your another model to have the target number of channels as you did in part 1.

     Measure of success: zero verification error of rtl results compared to the estimated results from pytorch sim. (Does not require FPGA mapping)

     - TA will test your design with their own input.txt, weight.txt, and output.txt and it must pass. 

 

Part6. +alpha (15% + 10% bonus)

    - Add anything else for example:

      1) any techniques that you learn from the course, or

      2) technique from your own idea, or

      3) thorough verification, e.g., for multiple layers or tiled layers, or

      4) mapping other networks, e.g., NLP, or

      5) reconfiguration between weight and output stationary, or

      6) scalable design, e.g., multi-core for tiled layer processing, or

      7) others.

      - Since the verification for this part is subjective to your enhancements and ideas, do your own verification as per your changes and present your results   

     NOTE: If your enhanced RTL can be mapped to FPGA, you can report how much TOPS/watt, TOPS/area and TOPS/s improved over vanilla version can be reported 

 

Part7. Poster and Report (25%)

      - Poster days are Dec 5 and Dec 7. Please come to Henry Booker room (2pm) on the 2nd floor of Jacobs Hall.

      - There is no strict format for poster presentation. Please see the example poster Poster.pdf Download Poster.pdf 

      - On poster day, elevator speech 3min + 30s Q&A (stop watch will be given + hard stop) per team

      - You may take a note for the other team’s research on the poster day

      - On Dec 7th, once the poster session (in the Henry Booker room) ends, come to the class room (CSB) 002 by 2:55 pm for course evaluation & quiz (bring your hand-written note and laptop) 

      - Focus on your unique strength (+alpha part)

      - Skip general intro / general motivation / do not explain common parts

      - Explain idea concisely and prove the efficacy

      - Summary table to show:

        1) Frequency, power, accuracy, and other specs (TOPS/w, GOPs/s, # of gates)

        2) Verification result 

        3) Benefit of your idea