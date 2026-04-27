class coverage_apb;
  
  // covergroup pentru registrul nr_locuri_libere
  covergroup cg_nr_locuri_libere;
    cp_nr_locuri_libere: coverpoint reg_nr_locuri_libere {
      bins zero = {0};
      bins max_val = {10};  // valoarea maximă (toate locurile libere)
      bins intermediare[] = {[1:9]};  // valori intermediare
    }
  endgroup
  
  // covergroup pentru registrul ora_curenta
  covergroup cg_ora_curenta;
    cp_ora_curenta: coverpoint ora_curenta {
      bins zero = {0};
      bins max = {23};
      bins subinterval1 = {[1:7]};   // 1-7
      bins subinterval2 = {[8:15]};  // 8-15
      bins subinterval3 = {[16:22]}; // 16-22
    }
  endgroup
  
  // covergroup pentru counter_tacte
  covergroup cg_counter_tacte;
    cp_counter_tacte: coverpoint counter_tacte {
      bins zero = {0};
      bins max_val = {3};  // valoarea maximă (tacte_pe_ora)
      bins intermediar = {1,2};  // valori intermediare
    }
  endgroup
  
  // variabile pentru sampling
  int reg_nr_locuri_libere;
  int ora_curenta;
  int counter_tacte;
  
  // constructor
  function new();
    cg_nr_locuri_libere = new();
    cg_ora_curenta = new();
    cg_counter_tacte = new();
  endfunction
  
  // metodă pentru sampling
  function void sample(int nr_locuri_libere_val, int ora_curenta_val, int counter_tacte_val);
    reg_nr_locuri_libere = nr_locuri_libere_val;
    ora_curenta = ora_curenta_val;
    counter_tacte = counter_tacte_val;
    
    cg_nr_locuri_libere.sample();
    cg_ora_curenta.sample();
    cg_counter_tacte.sample();
  endfunction
  
  //afișarea raportului de coverage
  function void report_coverage();
    $display("========== COVERAGE REPORT ==========");
    $display("Coverage for nr_locuri_libere: %.2f%%", cg_nr_locuri_libere.get_inst_coverage());
    $display("Coverage for ora_curenta: %.2f%%", cg_ora_curenta.get_inst_coverage());
    $display("Coverage for counter_tacte: %.2f%%", cg_counter_tacte.get_inst_coverage());
    $display("=====================================");
  endfunction
  
endclass