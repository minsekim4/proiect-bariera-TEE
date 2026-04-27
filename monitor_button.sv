//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//monitorul urmareste traficul de pe interfetele DUT-ului, preia datele verificate si recompune tranzactiile (folosind obiecte ale clasei transaction); in implementarea de fata, datele preluate de pe interfete sunt trimise scoreboardului pentru verificare
//Samples the interface signals, captures into transaction packet and send the packet to scoreboard.

//in macro-ul BUTTON_MON_IF se retine blocul de semnale de unde monitorul extrage datele
`define BUTTON_MON_IF buttons_vif.MONITOR.monitor_cb

class monitor_buttons;
  
  //creating virtual interface handle
  virtual interface_buttons buttons_vif;
  
  //se creaza portul prin care monitorul trimite scoreboardului datele colectate de pe interfata DUT-ului sub forma de tranzactii 
  //creating mailbox handle
  mailbox mon2scb;
  
  //instanta coverage
  coverage_button cov_buttons;
  
  //cand se creaza obiectul de tip monitor (in fisierul environment.sv), interfata de pe care acesta colecteaza date este conectata la interfata reala a DUT-ului
  //constructor
  function new(virtual interface_buttons buttons_vif, mailbox mon2scb);
    
    //getting the interface
    this.buttons_vif = buttons_vif;
    
    //getting the mailbox handles from environment 
    this.mon2scb = mon2scb;
    
    //creare coverage
    cov_buttons = new();
    
  endfunction
  
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    
    forever begin
      
      //se declara si se creaza obiectul de tip tranzactie care va contine datele preluate de pe interfata
      button_transaction trans;
      trans = new();

      //monitorizarea semnalelor sincronizat cu ceasul
      @(buttons_vif.MONITOR.clk);

      //preluarea semnalelor din interfata si salvarea lor in tranzactie
      trans.btn_intrare = `BUTTON_MON_IF.btn_intrare;
      trans.btn_iesire  = `BUTTON_MON_IF.btn_iesire;
      trans.senzor_prox = `BUTTON_MON_IF.senzor_prox;

      // dupa ce s-au retinut informatiile referitoare la o tranzactie, continutul obiectului trans se trimite catre scoreboard
      mon2scb.put(trans);
      
      //sample pentru coverage
      cov_buttons.sample_function(trans);
      
    end
    
  endtask
  
endclass