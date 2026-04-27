//prin coverage, putem vedea ce situatii (de exemplu, ce tipuri de tranzactii) au fost generate in simulare; astfel putem masura stadiul la care am ajuns cu verificarea

class coverage_button;
  
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
      bins apasat_intrare = binsof(btn_input_cp.intrare) && binsof(btn_output_cp.neapasat_o);
      bins apasat_iesire = binsof(btn_input_cp.neapasat_i) && binsof(btn_output_cp.iesire);
      bins apasat_ambele = binsof(btn_input_cp.intrare) && binsof(btn_output_cp.iesire);
    }

    //Scenariu: Am apasat butonul de intrare si se activeaza senzorul
    cross_btn_i_vs_senzor: cross btn_input_cp, senzor_cp{
      bins intrare_valida = binsof(btn_input_cp.intrare) && binsof(senzor_cp.ceva_prezent);
      bins intrare_gresita = binsof(btn_input_cp.intrare) && binsof(senzor_cp.nimic_prezent);
    }
    //Scenariu: Am apasat butonul de iesire si se activeaza senzorul
    cross_btn_o_vs_senzor: cross btn_output_cp, senzor_cp{
      bins iesire_valida = binsof(btn_output_cp.iesire) && binsof(senzor_cp.ceva_prezent);
      bins iesire_gresita = binsof(btn_output_cp.iesire) && binsof(senzor_cp.nimic_prezent);      
    }
   
  endgroup

  function new();
    stimuli_cg = new();
  endfunction

  // Metoda sample primește tranzacția de la Monitor
  task sample(button_transaction t);
    this.trans_covered = t;
    stimuli_cg.sample();
  endtask: sample

  function void display_stats();
    $display("[%0t] Coverage Stimuli: %.2f%%", $time, stimuli_cg.get_inst_coverage());
  endfunction

endclass: coverage_button

   