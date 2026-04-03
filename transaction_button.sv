//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------
class button_generator;
  rand button_transaction trans, trans_aux; // Obiectul cu datele de test
  int repeat_count;              // Numărul de pachete de generat
  mailbox gen2driv;              // Cutia poștală către Driver
  event ended;                   // Semnal de finalizare test

  function new(mailbox gen2driv, event ended);
    this.gen2driv = gen2driv;
    this.ended    = ended;
  endfunction

  task main();
    repeat(repeat_count) begin
      trans = new();             // Creează un pachet nou
      if( !trans.randomize() )   // Generare valori aleatorii (0/1)
          $fatal("Eroare Randomizare!");     
      trans_aux = trans.do_copy();
     // gen2driv.put(trans.do_copy()); // Trimite o copie la Driver
      gen2driv.put(trans_aux);
    end
    -> ended; // Anunță că a terminat toate pachetele
  endtask
  
  task single_transaction(bit input_button, bit output_button, bit sensor_proximity);
      trans = new();             // Creează un pachet nou
    if( !trans.randomize() with {button_input == input_button; button_output == output_button; senzor_proxim_i == sensor_proximity;})  
          $fatal("Eroare Randomizare!");     
      trans_aux = trans.do_copy();
     // gen2driv.put(trans.do_copy()); // Trimite o copie la Driver
      gen2driv.put(trans_aux);
  endtask
endclass