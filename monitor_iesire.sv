//-------------------------------------------------------------------------
// Monitor pentru interfata de iesire
//-------------------------------------------------------------------------

`define OUTPUT_MON_IF out_vif.MONITOR.monitor_cb

class output_monitor;

  virtual interface_output out_vif;

  mailbox mon2scb;

  // instanta coverage
  coverage_iesire cov_out;

  function new(virtual interface_output out_vif, mailbox mon2scb);
    this.out_vif = out_vif;
    this.mon2scb = mon2scb;

    // creare coverage
    cov_out = new();
  endfunction


  task main;


    forever begin

      
      transaction_iesire trans;
      trans = new();

      @(posedge out_vif.MONITOR.clk);

      trans.stare_bariera    = `OUTPUT_MON_IF.stare_bariera;
      trans.nr_locuri_libere = `OUTPUT_MON_IF.nr_locuri_libere;
      trans.parcare_plina    = `OUTPUT_MON_IF.parcare_plina;
      trans.parcare_goala    = `OUTPUT_MON_IF.parcare_goala;

      // sample coverage
      cov_out.sample_function(trans);

      // trimitere spre scoreboard
      mon2scb.put(trans);

    end

  endtask

endclass
`include "interface_apb.sv"
`include "interface_buttons.sv"

`include "interface_output.sv"