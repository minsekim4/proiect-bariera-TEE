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

    
property butoanele_activeaza_senzorul;
  @(posedge clk) disable iff(!reset)
    (btn_intrare || btn_iesire) |-> (senzor_prox);//daca butoanele sunt in 1, oricare din ele, atunci senzorul e in 1
endproperty    
asertia_butoane1_senzor1: assert property (butoanele_activeaza_senzorul)
  else $error("EROARE LOGICA: Buton apasat dar senzor = 0!");
butoane1_senzor1_C: cover property(butoanele_activeaza_senzorul);

   
endinterface