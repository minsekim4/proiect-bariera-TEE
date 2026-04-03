//-------------------------------------------------------------------------
// Tranzactie pentru interfata de iesire
//-------------------------------------------------------------------------

class transaction_iesire;

  
  bit stare_bariera;
  bit [4:0] nr_locuri_libere;
  bit parcare_plina;
  bit parcare_goala;

 
  function void display();
    $display("------ TRANSACTION OUTPUT ------");
    $display("stare_bariera     = %0b", stare_bariera);
    $display("nr_locuri_libere  = %0d", nr_locuri_libere);
    $display("parcare_plina     = %0b", parcare_plina);
    $display("parcare_goala     = %0b", parcare_goala);
    $display("--------------------------------");
  endfunction

    function void post_randomize();
    display();
  endfunction

    //operator de copiere a unui obiect intr-un alt obiect (deep copy)
  function transaction_iesire do_copy();
    transaction_iesire trans;
    trans = new();
    trans.stare_bariera  = this.stare_bariera;
    trans.nr_locuri_libere = this.nr_locuri_libere;
    trans.parcare_plina = this.parcare_plina;
    trans.parcare_goala = this.parcare_goala;
    return trans;
  endfunction

endclass