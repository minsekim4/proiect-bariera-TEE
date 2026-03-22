class button_transaction;
  rand bit button_input;
  rand bit button_output;
  // --- Parametri de timp pentru simularea butonului ---
  
  //rand bit       hold_cycles;  // Cat timp sta "apasat" semnalul de wr sau rd
  
  rand bit senzor_proxim_i; // 1 = masina detectata, 0 = nu exista masina
 // rand int car_leave_delay; //timp cât stă mașina sub barieră

  // --- Constrangeri ---


  // Limitam distanta intre apasari
  constraint button_input { 
    dist { 0 := 95, 1 := 5 };
  }
  
  constraint button_output { 
    dist { 0 := 95, 1 := 5 };
  }
  
  // Daca butonul este apasat, masina trebuie sa fie prezenta
  constraint prox_c {
    button_input | button_output -> senzor_proxim_i == 1;
  }


  // --- Metode ---

   function void post_randomize();
    $display("--------- [Trans] ---------");
    $display(" button_input: %0b | button_output: %0b | prox_sensor: %0b ",
              button_input, button_output, senzor_proxim_i);
    $display("---------------------------");
  endfunction


  function button_transaction do_copy();
    button_transaction trans;
    trans = new();

    trans.button_input          = this.button_input;
    trans.button_output         = this.button_output;
    trans.senzor_proxim_i       = this.senzor_proxim_i;

    return trans;
  endfunction

endclass