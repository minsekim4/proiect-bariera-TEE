//prin coverage, putem vedea ce situatii (de exemplu, ce tipuri de tranzactii) au fost generate in simulare; astfel putem masura stadiul la care am ajuns cu verificarea

class coverage_stimuli_externi;
  
    // Avem nevoie de un handle către tranzacția de butoane
  button_transaction trans_covered;
  
  //pentru a se putea vedea valoarea de coverage pentru fiecare element trebuie create mai multe grupuri de coverage, sau trebuie creata o functie de afisare proprie
  covergroup stimuli_cg;
    option.per_instance = 1;

  // adaugati adresele tuturor registrilor pe care ii aveti in DUT (sunt documentati in specificatie)
  
    // 1. Acoperirea butoanelor (Intrare, Iesire, Nimic)
    btn_cp: coverpoint trans_covered.btn_i {
      bins nicio_apasare  = {2'b00};
      bins intrare        = {2'b01};
      bins iesire         = {2'b10};
      illegal_bins eroare = {2'b11}; // Ambele apasate deodata (caz invalid)
    }

    // 2. Acoperirea senzorului
    senzor_cp: coverpoint trans_covered.senzor_proxim_i {
      bins ceva_prezent  = {1};
      bins nimic_prezent = {0};
    }

    // 3. Acoperirea stării parcării (Plină/Goală)
    stare_parcare_cp: coverpoint {trans_covered.parcare_plina, trans_covered.parcare_goala} {
      bins parcare_normala = {2'b00};
      bins parcare_plina   = {2'b10};
      bins parcare_goala   = {2'b01};
    }

    // 4. Acoperirea timpului (Sistem activ vs Inactiv)
    sistem_activ_cp: coverpoint trans_covered.sistem_activ {
      bins activ   = {1};
      bins inactiv = {0};
    }

// CROSS COVERAGE 
 // Vrem să vedem dacă am testat situațiile reale de utilizare:\
 //???acopar eu si incrementarea si decrementarea locurilor libere sau asta se face in alta parte

    // Scenariu: Am încercat să intrăm/ieșim când sistemul era activ/inactiv - legat de timp
    cross_btn_vs_ora: cross btn_cp, sistem_activ_cp {
      // Vrem să vedem neapărat că am încercat să intrăm și când e INACTIV (să vedem dacă bariera rămâne jos)
      bins incercare_inactiv = binsof(btn_cp) intersect {2'b01, 2'b10} && binsof(sistem_activ_cp.inactiv);
    }

    // Scenariu: Am încercat să intrăm când parcarea era PLINĂ?
    cross_intrare_plina: cross btn_cp, stare_parcare_cp, senzor_cp {
      bins intrare_cand_e_plina = binsof(btn_cp.intrare) && 
                                  binsof(stare_parcare_cp.parcare_plina) && 
                                  binsof(senzor_cp.ceva_prezent);
    }

    // Scenariu: avem masina la intrare si la iesire si se apasa butonul
    cross_validare_fizica: cross btn_cp, senzor_cp {
      bins intrare_corecta = binsof(btn_cp.intrare) && binsof(senzor_cp.ceva_prezent);
      bins iesire_corecta  = binsof(btn_cp.iesire) && binsof(senzor_cp.ceva_prezent);
    }
     
    // Verificăm farse: buton apasat fara masina la bariera
    cross_farsa: cross btn_cp, senzor_cp {
      bins farsa_intrare = binsof(senzor_cp.nimic_prezent) && binsof(btn_cp.intrare);
      bins farsa_iesire = binsof(senzor_cp.nimic_prezent) && binsof(btn_cp.iesire);
    }

    //verificam daca 
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