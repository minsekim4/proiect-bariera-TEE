//-------------------------------------------------------------------------
//                      www.verificationguide.com
//-------------------------------------------------------------------------

`define DRIV_IF apb_vif.DRIVER.driver_cb

class driver_apb;
  
  // contor tranzactii
  int no_transactions;
  
  // virtual interface
  virtual interface_apb apb_vif;
  
  // mailbox
  mailbox gen2driv;
  
  // constructor
  function new(virtual interface_apb apb_vif, mailbox gen2driv);
    this.apb_vif = apb_vif;
    this.gen2driv = gen2driv;
  endfunction
  
  // ---------------- RESET ----------------
  task reset;
    wait(!apb_vif.reset);
    $display("--------- [DRIVER] Reset Started ---------");
    
    `DRIV_IF.psel    <= 0;
    `DRIV_IF.penable <= 0;
    `DRIV_IF.paddr   <= 0; 
    `DRIV_IF.pwrite  <= 0;
    `DRIV_IF.pwdata  <= 0;
          
    wait(apb_vif.reset);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  // ---------------- DRIVE ----------------
  task drive;
    transaction_apb trans;
    
    // asteapta iesirea din reset
    wait(apb_vif.reset);
    
    // ia tranzactia de la generator
    gen2driv.get(trans);
    
    $display("--------- [DRIVER-TRANSFER: %0d] ---------", no_transactions);
    
    // delay intre tranzactii
    repeat(trans.delay_between_transaction)
      @(posedge apb_vif.clk);
    
    // ================= SETUP PHASE =================
    `DRIV_IF.psel    <= 1;
    `DRIV_IF.penable <= 0;
    `DRIV_IF.paddr   <= trans.paddr;
    `DRIV_IF.pwrite  <= trans.pwrite;
    `DRIV_IF.pwdata  <= trans.pwdata;
    
    @(posedge apb_vif.clk);
    
    // ================= ENABLE PHASE =================
    `DRIV_IF.penable <= 1;
    
    // asteapta ready de la DUT
    @(posedge apb_vif.clk iff apb_vif.pready == 1);
    
    // ================= END TRANSFER =================
    `DRIV_IF.psel    <= 0;
    `DRIV_IF.penable <= 0;    
    
    // afisare
    $display("\tADDR = %0h", trans.paddr);
    
    if (trans.pwrite)
      $display("\tWRITE DATA = %0h", trans.pwdata);
    else
      $display("\tREAD DATA = %0h", apb_vif.prdata);
    
    $display("-----------------------------------------");
    
    no_transactions++;
  endtask
  
  // ---------------- MAIN ----------------
  task main;
    forever begin
      fork
        // Thread reset
        begin
          wait(apb_vif.reset);
        end
        
        // Thread drive
        begin
          forever
            drive();
        end
        
      join_any
      disable fork;
        reset();
    end
  endtask
        
endclass