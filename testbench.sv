//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//tbench_top or testbench top, this is the top most file, in which DUT(Design Under Test) and Verification environment are connected. 
//-------------------------------------------------------------------------

//including interfcae and testcase files


`include "interface_apb.sv"
`include "interface_buttons.sv"
`include "interface_output.sv"

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
`include "random_test.sv"
//`include "test_initial_ridicareBariera.sv"
//`include "wr_rd_test.sv"
//`include "default_rd_test.sv"
//----------------------------------------------------------------


module testbench;
  
  //clock and reset signal declaration
  bit clk;
  bit reset;
  
  //clock generation
  always #5 clk = ~clk;
  
  //reset Generation
  initial begin
    reset = 1;
    #15 reset =0;
  end
  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  interface_apb 	apb_intf	(clk,reset);
  interface_buttons button_intf	(clk,reset);
  interface_output 	output_intf	(clk,reset);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(apb_intf, button_intf, output_intf);//din random_test.sv
  test t2(apb_intf, button_intf, output_intf);//din test_initial_ridicareBariera.sv
  
  //DUT instance, interface signals are connected to the DUT ports
  
    // Instantiere DUT cu parametri redusi pentru simulare rapida
    // 1 ora = 100 tacte. 100 tacte * 10ns = 1000ns per ora simulata.
    sistem_parcare #(
      		.NR_TACTE_SENZOR(8'd10), 
      		.TACTE_PER_ORA	(8'd100), 
      		.NR_TOTAL_LOCURI(8'd15)) 
  	dut (
        	.clk_i				(clk), 
        	.rst_ni				(rst), 
      		.paddr_i			(apb_intf.paddr), 
        	.psel_i				(apb_intf.psel),
      		.penable_i			(apb_intf.penable), 
      		.pwrite_i			(apb_intf.pwrite), 
      		.pwdata_i			(apb_intf.pwdata),
        	.prdata_o			(apb_intf.prdata),
      		.pready_o			(apb_intf.pready), 	
      		.btn_i				(button_intf.btn),
      			//??? aici nu stiu ce sa pun din cauza ca pe interfata button am 2 semnale de intrare butoane iar in dut nu am
        	.senzor_proxim_i	(button_intf.senzor_prox),
      		.stare_bariera_o	(output_intf.stare_bariera),
      		.nr_locuri_libere_o	(output_intf.nr_locuri_libere)
    );
  
  //enabling the wave dump
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
