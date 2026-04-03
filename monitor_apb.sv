//-------------------------------------------------------------------------
// APB MONITOR
//-------------------------------------------------------------------------

`define MON_IF apb_vif.MONITOR.monitor_cb

class monitor_apb;
  
  // virtual interface
  virtual interface_apb apb_vif;
  
  // mailbox catre scoreboard
  mailbox mon2scb;
  
  //coverage
  coverage_apb cov_apb;
  
  // constructor
  function new(virtual interface_apb apb_vif, mailbox mon2scb );
    this.apb_vif = apb_vif;
    this.mon2scb = mon2scb;
    cov_apb = new();
  endfunction
  
  // ---------------- MAIN ----------------
  task main;
    forever begin
      
      transaction_apb trans;
      trans = new();
      
      // asteapta inceput tranzactie (SETUP phase)
      @(posedge apb_vif.clk);
      wait(`MON_IF.psel == 1 && `MON_IF.penable == 0);
      
      // captureaza semnale din SETUP
      trans.paddr  = `MON_IF.paddr;
      trans.pwrite = `MON_IF.pwrite;
      trans.pwdata = `MON_IF.pwdata;
      
      // trece in ENABLE phase
      @(posedge apb_vif.clk);
      wait(`MON_IF.penable == 1 && `MON_IF.pready == 1);
      
      // daca este citire, ia datele
      if (!trans.pwrite) begin
        trans.pwdata = `MON_IF.pwdata;
      end
     
      /*
      //(debug / verificare)
      trans.pready = `MON_IF.pready;
      */
      
      // trimite tranzactia la scoreboard
      mon2scb.put(trans);
      cov_apb.sample(trans);
      // debug
      $display("--------- [MONITOR] ---------");
      $display("\tADDR = %0h", trans.paddr);
      
      if (trans.pwrite)
        $display("\tWRITE DATA = %0h", trans.pwdata);
     
      $display("-----------------------------");
      
    end
  endtask
  
endclass