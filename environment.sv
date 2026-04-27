//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//in mediul de verificare se instantiaza toate componentele de verificare
`include "transaction_apb.sv"
`include "button_transaction.sv"
`include "transaction_iesire.sv"

`include "generator_apb.sv"
`include "button_generator.sv"

`include "driver_apb.sv"
`include "button_driver.sv"


`include "coverage_apb.sv"
`include "coverage_button.sv"
`include "coverage_iesire.sv"
`include "scoreboard_coverage.sv"


`include "monitor_apb.sv"
`include "monitor_buttons.sv"
`include "output_monitor.sv"


`include "scoreboard.sv"

class environment;
  
  virtual interface_buttons btn_int;
  virtual interface_apb apb_int;
  virtual interface_output output_int;
  
  //componentele de verificare sunt declarate
  //generator and driver instance
  generator_apb  apb_gen;
  driver_apb     apb_driv;
  monitor_apb apb_mon;
  
  
  button_generator button_gen;
  button_driver button_drv;
  monitor_buttons mon_btn;
  
  output_monitor output_mon;
  

//  scoreboard scb;
  
  //mailbox handle's
  mailbox apb_gen2driv;
  mailbox apb_mon2scb;
  
  mailbox but_gen2drv;
  mailbox but_mon2scb;
  
  mailbox iesire_mon2scb;
  
  
  //event for synchronization between generator and test
  event apb_gen_ended, btn_gen_ended;
  
  
  //constructor
  function new(
    virtual interface_buttons btn_int,
    virtual interface_apb apb_int,
    virtual interface_output output_int
  );
    //get the interface from test
    this.btn_int    = btn_int;
    this.apb_int    = apb_int;
    this.output_int = output_int;
    
    //creating the mailbox (Same handle will be shared across generator and driver)
    // APB
    apb_gen2driv   = new();
    apb_mon2scb    = new();

    // Buttons
    but_gen2drv    = new();
    but_mon2scb    = new();

    // Output
    iesire_mon2scb = new();
    
    //componentele de verificare sunt create
    //creating generator and driver
    //APB
    apb_gen  = new(apb_gen2driv,apb_gen_ended);
    apb_driv = new(apb_int,apb_gen2driv);
    apb_mon  = new(apb_int,apb_mon2scb);
    
      // Buttons
    button_gen = new(but_gen2drv, btn_gen_ended);
    button_drv = new(btn_int, but_gen2drv);
    mon_btn    = new(btn_int, but_mon2scb);

    // Output
    output_mon = new(output_int, iesire_mon2scb);

    // Scoreboard
    //scb = new(...);
    //de continuat cu restul componentelor de verificare conform figurii

  endfunction
  
  //
  task pre_test();
    fork
    apb_driv.reset();
    button_drv.reset();
    join

  endtask
  
  task test();
    fork 
    // APB
      apb_gen.main();
      apb_driv.main();
      apb_mon.main();

      // Buttons
      button_gen.main();
      button_drv.main();
      mon_btn.main();

      // Output
      output_mon.main();

      // Scoreboard
      //scb.main();

      
      //de continuat cu apelarea functiilor main pentru toate componentele de verificare create de mine si de colegi
    join_any
  endtask
  
  task post_test();
//    wait(gen_ended.triggered);
    //se urmareste ca toate datele generate sa fie transmise la DUT si sa ajunga si la scoreboard
    //wait(gen.repeat_count == driv.no_transactions);
    //wait(gen.repeat_count == scb.no_transactions);
    #4000;
  endtask  
  
  function report();
    // coverage APB
    apb_mon.cov_apb.print_coverage();

    // coverage Buttons
    mon_btn.cvg.print_coverage();

    // coverage Output
    output_mon.cov_out.print_coverage();

    // coverage scoreboard
    //scb.colector_coverage.print_coverage();

    //de continuat pentru celelalte doua monitoare
   // scb.colector_coverage.print_coverage();
  endfunction
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
    report();
    //linia de mai jos este necesara pentru ca simularea sa sa termine
    $finish;
  endtask
  
endclass

