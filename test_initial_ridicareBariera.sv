//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
// Test pentru scenariul:
// Ridicarea barierei -> stare de asteptare -> verificare senzor ->
// coborarea barierei
//-------------------------------------------------------------------------

`include "environment.sv"

program test(
  interface_buttons button_intf,
  interface_apb apb_intf,
  interface_output output_intf
);


  class my_button_trans extends button_transaction;

    int count = 0;

    function void pre_randomize();

      
      btn_intrare.rand_mode(0);
      btn_iesire.rand_mode(0);
      senzor_prox.rand_mode(0);


      if (count < 5) begin
        //ridicarea a barierei
        btn_intrare = 1;
        btn_iesire  = 0;
        senzor_prox = 1;
      end
      else begin
        //coborarea a barierei
        btn_intrare = 0;
        btn_iesire  = 0;
        senzor_prox = 0;
      end

      count++;

    endfunction

  endclass


  //-------------------------------------------------------------------------
  // Declaram environment-ul
  //-------------------------------------------------------------------------

  environment env;
  my_button_trans my_tr;


  initial begin

    env = new(btn_int, apb_int, output_int);
    my_tr = new();
    //env.apb_gen.write_reg(2,14);
    env.button_gen.repeat_count = 10;
    env.button_gen.trans = my_tr;
    env.run();

  end

endprogram