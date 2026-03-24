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
  
    
    
  property p_full_flag_check;
    @(posedge clk) disable iff (reset == 0) // Proprietate: Daca nr_locuri_libere e 0, parcare_plina trebuie sa fie 1
    (nr_locuri_libere == 0) |-> parcare_plina;
  endproperty

  asertia_parcare_plina: assert property (p_full_flag_check)
    else $error("OUTPUT_ERR: Flag-ul parcare_plina nu corespunde cu numarul de locuri!");
  parcare_plina_C: cover property (p_full_flag_check);

  
  property p_not_full_and_empty;
    @(posedge clk) disable iff (reset == 0)// Proprietate: Parcare_plina si Parcare_goala nu pot fi ambele 1 (decat daca parcarea are capacitate 0)
    !(parcare_plina && parcare_goala);
  endproperty

  asertia_consistenta_stari: assert property (p_not_full_and_empty)
    else $error("OUTPUT_ERR: Eroare logica: Parcare plina si goala in acelasi timp!");
  consistenta_stari_C: cover property (p_not_full_and_empty);
  
  
endinterface