//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//tranzactiile din acest text se genereaza complet aleatoriu (singura constrangere fiind in fisierul transaction.sv, aceasta asigurand functionalitatea corecta a DUT-ului)
`include "environment.sv"
program test(  interface_buttons apb_intf,
     interface_apb button_intf,
     interface_output output_intf);
  
  //declaring environment instance
  environment env;
  
  initial begin
    //creating environment
    env = new(apb_intf, button_intf, output_intf);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.gen.repeat_count = 4;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram