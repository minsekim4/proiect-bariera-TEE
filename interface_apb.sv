//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//interfata APB

interface interface_apb(input logic clk,reset);
  
  //declaring the signals
    logic [7:0]	 prdata;
    logic 	     pready;
    logic 	     psel;
    logic        penable; 
    logic [1:0]  paddr; 
    logic  	     pwrite;
    logic [7:0]  pwdata;
  //semnalele din clocking block sunt sincrone cu frontul crescator de ceas
  //driver clocking block
  clocking driver_cb @(posedge clk);
    //semnalele de intrare sunt citite o unitate de timp inainte frontului de ceas, iar semnalele de iesire sunt citite o unitate de timp dupa frontul de ceas; astfel se elimina situatiile in care se fac scrieri sau citiri in acelasi timp
    default input #1 output #1;
    input 	prdata;
    input 	pready;
    output  psel;
    output  penable; 
    output 	paddr; 
    output 	pwrite;
    output  pwdata;
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input prdata;
    input pready;
    input psel;
    input penable; 
    input paddr; 
    input pwrite;
    input pwdata;  
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
endinterface