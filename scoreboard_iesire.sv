//-------------------------------------------------------------------------
// Scoreboard pentru iesiri
//-------------------------------------------------------------------------

class scoreboard;

  mailbox mon2scb;

  int no_transactions;

 
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction


  task main;

    transaction trans;

    forever begin

      mon2scb.get(trans);

      
      trans.display();

      
      if(trans.parcare_plina && trans.parcare_goala)
        $error("EROARE: Parcarea nu poate fi si plina si goala!");

      
      if(trans.nr_locuri_libere == 0 && !trans.parcare_plina)
        $error("EROARE: Parcarea ar trebui sa fie plina!");

      if(trans.nr_locuri_libere == 15 && !trans.parcare_goala)
        $error("EROARE: Parcarea ar trebui sa fie goala!");

     
      $display("SCB OK -> locuri libere = %0d", trans.nr_locuri_libere);

      no_transactions++;

    end

  endtask

endclass