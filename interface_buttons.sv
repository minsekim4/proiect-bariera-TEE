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
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input btn_intrare;
    input btn_iesire;
    input senzor_prox;
  endclocking

  // Modport-uri
  modport DRIVER  (clocking driver_cb, input clk, reset);
  modport MONITOR (clocking monitor_cb, input clk, reset);

    
    
    
    
    

  property p_no_simultaneous_btns;
    @(posedge clk) disable iff (reset == 0)// Proprietate: Nu se pot apasa ambele butoane in acelasi timp
    !(btn_intrare && btn_iesire);
  endproperty

  asertia_butoane_mutuala: assert property (p_no_simultaneous_btns)
    else $error("BUTTONS_ERR: Intrare si Iesire activate simultan!");
  butoane_mutuala_C: cover property (p_no_simultaneous_btns);

  
  property p_sensor_active;
    @(posedge clk) disable iff (reset == 0)// Proprietate: Daca senzorul de proximitate e activ, bariera ar trebui sa reactioneze (verificare logica)
    senzor_prox |= house_is_occupied; //verificam daca senzorul produce un eveniment
  endproperty
endinterface