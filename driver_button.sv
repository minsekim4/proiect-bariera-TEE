//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//driverul preia datele de la generator, la nivel abstract, si le trimite DUT-ului conform protocolului de comunicatie pe interfata respectiva
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 


`define DRIV_IF button_vif.DRIVER.driver_cb

class button_driver;
  
  // --- Atribute ---
  int no_transactions;             // Contor pentru monitorizarea numărului de teste rulate
  virtual interface_buttons button_vif;  // Handle către interfața fizică a sistemului (Virtual Interface)
  mailbox gen2driv;                // Canal de comunicare (FIFO) pentru primirea datelor de la Generator

  // --- Constructor ---
  // Face legătura între Driver și resursele externe
  function new(virtual interface_buttons button_vif, mailbox gen2driv);
    this.button_vif = button_vif;
    this.gen2driv = gen2driv;
  endfunction

  // --- Task: RESET ---
  // Aduce semnalele de intrare ale barierei în 0 
  // atunci când sistemul este resetat hardware.
  task reset;
    wait(!button_vif.reset);        // Așteaptă activarea semnalului de reset
    $display("[DRIVER] Reset detectat - Inițializare semnale...");
    button_vif.button_input    <= 0;
    button_vif.button_output   <= 0;
    button_vif.senzor_proxim_i <= 0;
    wait(button_vif.reset);       // Așteaptă dezactivarea resetului
    $display("[DRIVER] Reset finalizat - Sistem pregătit.");
  endtask

  // --- Task: DRIVE ---
  task drive;
    button_transaction trans;
    
    // 1. Extragerea datelor din Mailbox (operație blocantă până la sosirea datelor)
    gen2driv.get(trans); 
    
    // 2. Sincronizarea cu frontul crescător al ceasului din interfață
    @(posedge button_vif.DRIVER.clk); 
    
    // 3. Aplicarea valorilor pe pinii barierei 
    //`DRIV_IF.button_input    <= trans.button_input;
   // `DRIV_IF.button_output   <= trans.button_output;
   // `DRIV_IF.senzor_proxim_i <= trans.senzor_proxim_i;  
    
    `DRIV_IF.btn_i <= {trans.button_output, trans.button_input}; 
    `DRIV_IF.senzor_proxim_i <= trans.senzor_proxim_i;   
    
    $display("[DRIVER-TX %0d] Input: %0b | Output: %0b | Prox: %0b", 
             no_transactions, trans.button_input, trans.button_output, trans.senzor_proxim_i);
    
    no_transactions++;
  endtask

  // --- Task: MAIN ---
  // Gestionează execuția paralelă a proceselor de livrare date și monitorizare reset.
  task main;
    forever begin
      fork
        // Firul 1: Monitorizarea permanentă a stării de Reset
        wait(button_vif.reset); 

        // Firul 2: Procesarea continuă a tranzacțiilor primite
        forever drive();        
      join_any
      
      // Dacă oricare fir de mai sus se termină , 
      // oprim forțat celelalte procese din acest bloc și reluăm bucla.
      disable fork;
        reset();
    end
  endtask

endclass