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
  
    
    
     
  
  property p_psel_then_penable;
    @(posedge clk) disable iff (reset == 0)// Proprietate: Daca psel e activ, in urmatorul tact trebuie sa vina penable (faza de Setup -> Access)
    $rose(psel) |=> penable;
  endproperty

  asertia_apb_setup_access: assert property (p_psel_then_penable)
    	else $error("APB_ERR: PENABLE nu a activat dupa PSEL!");
  apb_setup_access_C: cover property (p_psel_then_penable);


  property p_penable_needs_psel;
    @(posedge clk) disable iff (reset == 0)  // Proprietate: PENABLE nu poate fi 1 daca PSEL este 0
    	penable |-> psel;
  endproperty

  asertia_apb_valid_enable: assert property (p_penable_needs_psel)
    else $error("APB_ERR: PENABLE activat fara PSEL!");
  apb_valid_enable_C: cover property (p_penable_needs_psel);
    
    //cand psel=0, penable e 0 
    // $fell(psel) Â- $fel(penable)
    // $fell(pready) Â- $fel(psell)
    // psel - $stable(paddr)
    //psel && pwrite - $stable(paddr) && $stable(pwdata)
    //rose (psel) Â !enable 
    //uita-te la regulile din pdf
    
endinterface
    