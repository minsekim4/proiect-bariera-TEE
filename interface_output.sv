//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
interface interface_output(input logic clk,reset);
  
  //declaring the signals
  logic 	  stare_bariera;
  logic [4:0] nr_locuri_libere;
  logic		  parcare_plina;
  logic 	  parcare_goala;
  //semnalele din clocking block sunt sincrone cu frontul crescator de ceas
  //driver clocking block

  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input stare_bariera;
    input nr_locuri_libere; 
    input parcare_plina;
    input parcare_goala;
  endclocking
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
endinterface