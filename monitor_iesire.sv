//-------------------------------------------------------------------------
// Monitor pentru interfata de iesire
//-------------------------------------------------------------------------

`define OUTPUT_MON_IF out_vif.MONITOR.monitor_cb

class output_monitor;


  virtual interface_output out_vif;

  
  mailbox mon2scb;

  
  function new(virtual interface_output out_vif, mailbox mon2scb);
    this.out_vif = out_vif;
    this.mon2scb = mon2scb;
  endfunction

  task main;

    output_transaction trans;

    forever begin

      trans = new();

      
      @(posedge out_vif.MONITOR.clk);

      
      trans.stare_bariera    = `OUTPUT_MON_IF.stare_bariera;
      trans.nr_locuri_libere = `OUTPUT_MON_IF.nr_locuri_libere;
      trans.parcare_plina    = `OUTPUT_MON_IF.parcare_plina;
      trans.parcare_goala    = `OUTPUT_MON_IF.parcare_goala;

     
      mon2scb.put(trans);

    end

  endtask

endclass