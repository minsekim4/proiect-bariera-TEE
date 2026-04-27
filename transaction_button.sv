//-------------------------------------------------------------------------
// Transaction pentru interfata de butoane
//-------------------------------------------------------------------------

class button_transaction;

  // semnal pentru butonul de intrare
  rand bit button_input;
  
  // semnal pentru butonul de iesire
  rand bit button_output;
  
  // senzor de proximitate:
  // 1 = masina detectata
  // 0 = nu exista masina
  rand bit senzor_proxim_i;
  


  //-------------------------------------------------------------------------
  // Constrangeri
  //-------------------------------------------------------------------------

  // butonul de intrare este apasat rar
  constraint button_input_c {
    button_input dist {0 := 95, 1 := 5};
  }

  // butonul de iesire este apasat rar
  constraint button_output_c {
    button_output dist {0 := 95, 1 := 5};
  }

  // daca unul dintre butoane este apasat,
  // masina trebuie sa fie detectata de senzor
  constraint prox_c {
    (button_input || button_output) -> (senzor_proxim_i == 1);
  }


  //-------------------------------------------------------------------------
  // Afisare dupa randomizare
  //-------------------------------------------------------------------------

  function void post_randomize();

    $display("--------- BUTTON TRANSACTION ---------");
    $display("button_input    = %0b", button_input);
    $display("button_output   = %0b", button_output);
    $display("senzor_proxim_i = %0b", senzor_proxim_i);
    $display("--------------------------------------");

  endfunction


  //-------------------------------------------------------------------------
  // Deep Copy
  //-------------------------------------------------------------------------

  // operator de copiere a unui obiect intr-un alt obiect
  function button_transaction do_copy();

    button_transaction trans;
    trans = new();

    trans.button_input    = this.button_input;
    trans.button_output   = this.button_output;
    trans.senzor_proxim_i = this.senzor_proxim_i;

    return trans;

  endfunction

endclass