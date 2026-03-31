//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//interfata APB

interface interface_apb(input logic clk,reset);
  
  //semnale fizice
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
    @(posedge clk) disable iff (!reset)//daca psel e activ, in urmatorul tact trebuie sa vina penable (faza de Setup -> Access)
    $rose(psel) |=> penable; //Non-overlapping: Verifică dacă al doilea semnal este adevărat la următorul front de ceas.
  endproperty
  asertia_apb_setup_access: assert property (p_psel_then_penable)
    	else $error("APB_ERR: PENABLE nu a fost activat dupa PSEL!");
  apb_setup_access_C: cover property (p_psel_then_penable);


  property p_penable_needs_psel;
    @(posedge clk) disable iff (!reset)  // penable nu poate fi 1 daca psel e 0
    	penable |-> psel; //Overlapping: Verifică dacă ambele semnale sunt adevărate în același moment (la același front de ceas).
  endproperty
  asertia_apb_valid_enable: assert property (p_penable_needs_psel)
    else $error("APB_ERR: PENABLE activat fara ca PSEL sa fie activat!");
  apb_valid_enable_C: cover property (p_penable_needs_psel);
    

  property psel_fall_penable_fall;
    @(posedge clk) disable iff(!reset) //daca psel e 0, atunci si penable e 0
      $fell(psel) |-> $fell(penable);
  endproperty
  asertia_psel0_penable0: assert property (psel_fall_penable_fall)
    else $error("APB_ERR: PSEL a coborat, dar PENABLE a ramas ridicat!");
  apb_psel0_penable0_C: cover property(psel_fall_penable_fall);
  

  property pready_fall_psel_fall;
    @(posedge clk) disable iff(!reset) // daca pready e 0 atunci si psel e 0
      $fell(pready) |-> $fell(psel);
  endproperty
  asertia_pready0_psel0: assert property (pready_fall_psel_fall)
    else $error("APB_ERR: PSEL este activ fara ca PREADY sa fie activ!");
  apb_pready0_psel0_C: cover property(pready_fall_psel_fall);


  property paddr_stable_whilePSEL;
    @(posedge clk) disable iff(!reset) //adresa trebuie sa fie aceeasi pentru cand psel e activ, si sa se schimbe dupa
      psel |-> $stable(paddr);
  endproperty
  asertia_stable_addr: assert property (paddr_stable_whilePSEL)
    else $error("APB_ERR: PADRR s-a schimbat in timpul tranzactiei active!");
  apb_stable_addr_C: cover property(paddr_stable_whilePSEL);  

  
  property pwrite_pwdataStable;
    @(posedge clk) disable iff(!reset) //pwdata sa fie aceasi cat timp e si psel si pwrite, adica cand scriem
      (psel && pwrite) |-> $stable(pwdata);
  endproperty
  asertia_stable_pwdata: assert property (pwrite_pwdataStable)
    else $error("APB_ERR: PWDATA s-a schimbat in timpul scrierii!");
  apb_stable_pwdata_C: cover property(pwrite_pwdataStable);
   

  property setup_penable;
    @(posedge clk) disable iff(!reset) //setup: daca psel e 1, penable e inca 0 la inceput
      $rose(psel) |-> !penable;
  endproperty
  asertia_penable_setup: assert property (setup_penable)
    else $error("APB_ERR: PENABLE era deja 1 in faza de SETUP!");
  apb_penable_setup_C: cover property(setup_penable);

    
endinterface
    