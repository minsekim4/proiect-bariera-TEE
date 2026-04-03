//prin coverage, putem vedea ce situatii (de exemplu, ce tipuri de tranzactii) au fost generate in simulare; astfel putem masura stadiul la care am ajuns cu verificarea

class coverage_stimuli_externi;
  
    // Avem nevoie de un handle către tranzacția de butoane
  button_transaction trans_covered;
  
  //pentru a se putea vedea valoarea de coverage pentru fiecare element trebuie create mai multe grupuri de coverage, sau trebuie creata o functie de afisare proprie
  covergroup stimuli_cg;
    option.per_instance = 1;

  
    // 1. Acoperirea buton intrare
    btn_input_cp: coverpoint trans_covered.btn_input {
      bins intrare = {1};
      bins neapasat_i = {0};
    }
    // 2. Acoperire buton iesire
    btn_output_cp: coverpoint trans_covered.btn_output {
      bins iesire = {1};
      bins neapasat_o = {0};
    }
    // 3. Acoperirea senzorului
    senzor_cp: coverpoint trans_covered.senzor_proxim_i {
      bins ceva_prezent  = {1};
      bins nimic_prezent = {0};
    }


// CROSS COVERAGE 
 // Vrem să vedem dacă am testat situațiile reale de utilizare:
 
    // Scenariu: Am apasat si butonul de intrare si de iesire
    cross_btn_i_vs_btn_o: cross btn_input_cp, btn_output_cp {
      //din varianta trecuta
        //bins incercare_inactiv = binsof(btn_cp) intersect {2'b01, 2'b10} && binsof(sistem_activ_cp.inactiv);
        //bins incercare_activ = binsof(btn_cp) intersect {2'b01, 2'b10} && binsof(sistem_activ_cp.activ);
    }

    cross_


  endgroup

  function new();
    stimuli_cg = new();
  endfunction

  // Metoda sample primește tranzacția de la Monitor
  task sample(stimuli_transaction t);
    this.trans_covered = t;
    stimuli_cg.sample();
  endtask: sample

  function void display_stats();
    $display("[%0t] Coverage Stimuli: %.2f%%", $time, stimuli_cg.get_inst_coverage());
  endfunction

endclass: coverage_stimuli_externi