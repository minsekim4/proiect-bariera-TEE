class coverage_extern;
  
  // Avem nevoie de un handle către tranzacția de butoane
  // (Presupun că se numește button_transaction, conform tab-urilor tale)
  button_transaction trans_covered;
  
  covergroup stimuli_externi_cg;
    option.per_instance = 1;

    // 1. Coverpoint pentru butonul de intrare
    btn_intrare_cp: coverpoint trans_covered.btn_intrare {
      bins apasat = {1};
      bins liber   = {0};
    }

    // 2. Coverpoint pentru butonul de ieșire
    btn_iesire_cp: coverpoint trans_covered.btn_iesire {
      bins apasat = {1};
      bins liber   = {0};
    }

    // 3. Coverpoint pentru senzorul de proximitate
    senzor_prox_cp: coverpoint trans_covered.senzor_prox {
      bins masina_prezenta = {1};
      bins fara_masina      = {0};
    }

    // --- CROSS COVERAGE (Partea cea mai importantă) ---
    // Vrem să vedem dacă am testat situațiile reale de utilizare:

    // Verificăm dacă am avut scenariul: Masină la barieră + Apăsare buton intrare
    cross_intrare_valida: cross senzor_prox_cp, btn_intrare_cp {
      bins intrare_corecta = binsof(senzor_prox_cp.masina_prezenta) && binsof(btn_intrare_cp.apasat);
    }

    // Verificăm dacă am avut scenariul: Masină la barieră + Apăsare buton ieșire
    cross_iesire_valida: cross senzor_prox_cp, btn_iesire_cp {
      bins iesire_corecta = binsof(senzor_prox_cp.masina_prezenta) && binsof(btn_iesire_cp.apasat);
    }

    // Verificăm dacă am testat tentativa de fraudă: Buton apăsat FĂRĂ mașină la barieră
    cross_tentativa_frauda: cross senzor_prox_cp, btn_intrare_cp {
      bins frauda_intrare = binsof(senzor_prox_cp.fara_masina) && binsof(btn_intrare_cp.apasat);
    }

  endgroup

  function new();
    stimuli_externi_cg = new();
  endfunction

  task sample(button_transaction trans_covered); 
    this.trans_covered = trans_covered; 
    stimuli_externi_cg.sample(); 
  endtask: sample   

  function void print_coverage();
    $display("--- Coverage Stimuli Externi ---");
    $display("Buton Intrare Coverage  = %.2f%%", stimuli_externi_cg.btn_intrare_cp.get_coverage());
    $display("Senzor Prox Coverage    = %.2f%%", stimuli_externi_cg.senzor_prox_cp.get_coverage());
    $display("Scenariu Intrare Valida = %.2f%%", stimuli_externi_cg.cross_intrare_valida.get_coverage());
    $display("Total Coverage Extern   = %.2f%%", stimuli_externi_cg.get_coverage());
  endfunction

endclass: coverage_extern