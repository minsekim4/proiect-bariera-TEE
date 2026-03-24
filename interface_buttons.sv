interface interface_buttons(input logic clk, reset);

  // Declararea semnalelor fizice
  logic btn_intrare;
  logic btn_iesire;
  logic senzor_prox;

  // Clocking block pentru Driver (cel care "apasa" butoanele in simulare)
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    /*  input #1: Spune simulatorului: "Când citești un semnal, uită-te cum era cu o 					unitate de timp înainte de ceas".
		output #1: Spune: "Când schimbi un semnal, fă-o la o unitate de timp după 					   ceas".*/
    //se activeaza exact inainte de frontul pozitiv de ceas
    output btn_intrare;
    output btn_iesire;
    output senzor_prox;
  endclocking

  // Clocking block pentru Monitor (cel care observa cand s-au apasat butoanele)
  clocking monitor_cb @(posedgeinterface interface_buttons(input logic clk, reset);

  // Declararea semnalelor fizice
  logic btn_intrare;
  logic btn_iesire;
  logic senzor_prox;

  // Clocking block pentru Driver (cel care "apasa" butoanele in simulare)
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    /*  input #1: Spune simulatorului: "Când citești un semnal, uită-te cum era cu o 					unitate de timp înainte de ceas".
		output #1: Spune: "Când schimbi un semnal, fă-o la o unitate de timp după 					   ceas".*/
    //se activeaza exact inainte de frontul pozitiv de ceas
    output btn_intrare;
    output btn_iesire;
    output senzor_prox;
  endclocking

  // Clocking block pentru Monitor (cel care observa cand s-au apasat butoanele)
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input btn_intrare;
    input btn_iesire;
    input senzor_prox;
  endclocking

  // Modport-uri
  modport DRIVER  (clocking driver_cb, input clk, reset);
  modport MONITOR (clocking monitor_cb, input clk, reset);

    
    //daca butoanele sunt in 1, oricare din ele, atunci senzorul e in 1
    
    
property p_senzor_activeaza_bariera;
  @(posedge clk) disable iff (reset == 0)
  (senzor_prox == 1) |=> (stare_bariera == 1); 
  
  
  // Daca senzorul detecteaza masina ACUM, la URMATORUL tact bariera trebuie sa fie ridicata
endproperty

asertia_logica_parcare: assert property (p_senzor_activeaza_bariera)
  else $error("EROARE LOGICA: Senzorul a detectat masina, dar bariera a ramas inchisa!");
  
  
endinterface clk);
    default input #1 output #1;
    input btn_intrare;
    input btn_iesire;
    input senzor_prox;
  endclocking

  // Modport-uri
  modport DRIVER  (clocking driver_cb, input clk, reset);
  modport MONITOR (clocking monitor_cb, input clk, reset);

    
    
    
    
property p_senzor_activeaza_bariera;
  @(posedge clk) disable iff (reset == 0)
  (senzor_prox == 1) |=> (stare_bariera == 1); 
  // Daca senzorul detecteaza masina ACUM, la URMATORUL tact bariera trebuie sa fie ridicata
endproperty

asertia_logica_parcare: assert property (p_senzor_activeaza_bariera)
  else $error("EROARE LOGICA: Senzorul a detectat masina, dar bariera a ramas inchisa!");
  
  
endinterface