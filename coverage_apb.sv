//prin coverage, putem vedea ce situatii (de exemplu, ce tipuri de tranzactii) au fost generate in simulare; astfel putem masura stadiul la care am ajuns cu verificarea
class coverage_apb;
  
  // obiectul care va fi eșantionat
  transaction_apb trans_covered;
  
  //pentru a se putea vedea valoarea de coverage pentru fiecare element trebuie create mai multe grupuri de coverage, sau trebuie creata o functie de afisare proprie
  covergroup transaction_cg;
    
  //linia de mai jos este adaugata deoarece, daca sunt mai multe instante pentru care se calculeaza coverage-ul, noi vrem sa stim pentru fiecare dintre ele, separat, ce valoare avem.  
    option.per_instance = 1;

    // WRITE (pwrite = 1)
    wr_enable_cp: coverpoint trans_covered.pwrite {
      bins write = {1};
    }

    // READ (pwrite = 0)
    rd_enable_cp: coverpoint trans_covered.pwrite {
      bins read = {0};
    }

    // adresa
    address_cp: coverpoint trans_covered.paddr {
      bins reg_ora_curenta = {0};
      bins reg_nr_locuri_libere = {1};
      bins reg_ora_start = {2};
      bins reg_ora_stop = default; // valoarea 3, atunci cand semnalul adresa estre pe 3 biti
    }

    // tip operatie
    operation_type_cp: coverpoint trans_covered.pwrite {
      bins read  = {0};
      bins write = {1};
    }

    // date scriere
    write_data_cp: coverpoint trans_covered.pwdata {
       //prin linia de mai jos am impartit intervalul de valori in 4 intervale egale
      bins range[4] = {[1:254]};// 1-63;64-127;128-191;192-254
      bins lowest_value = {0};
      bins highest_value = {255};
    }

    // cross coverage vrem sa vedem ca fiecarui registru i s-a aplicat o operatie de scriere si una de citire
    address_operation_cross: cross operation_type_cp, address_cp;

  endgroup

  // constructor
  function new();
    transaction_cg = new();
  endfunction

  // sample
  task sample(transaction_apb trans);
    this.trans_covered = trans;
    transaction_cg.sample();
  endtask:sample

  // afișare coverage
  function void print_coverage();
    $display ("Write coverage = %.2f%%", transaction_cg.wr_enable_cp.get_coverage());
    $display ("Read coverage = %.2f%%", transaction_cg.rd_enable_cp.get_coverage());
    $display ("Address coverage = %.2f%%", transaction_cg.address_cp.get_coverage());
    $display ("Write data coverage = %.2f%%", transaction_cg.write_data_cp.get_coverage());
    $display ("Overall coverage = %.2f%%", transaction_cg.get_coverage());
    $display ("Cross operation = %.2f%%", transaction_cg.address_operation_cross.get_coverage());
    $display ("Operation type = %.2f%%", transaction_cg.operation_type_cp.get_coverage());
  endfunction

endclass