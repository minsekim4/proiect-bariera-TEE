//-------------------------------------------------------------------------
//                      COVERAGE CLASS FOR SCOREBOARD
///geminiiiiiiiiiiiii
//-------------------------------------------------------------------------
class scoreboard_coverage;
  
  // covergroup pentru registrul nr_locuri_libere
  covergroup cg_nr_locuri_libere;
    cp_nr_locuri_libere: coverpoint reg_nr_locuri_libere {
      bins zero = {0};
      bins max_val = {10};  // valoarea maximă (toate locurile libere)
      bins intermediare[] = {[1:9]};  // valori intermediare
    }
  endgroup
  
  // covergroup pentru registrul ora_curenta
  covergroup cg_ora_curenta;
    cp_ora_curenta: coverpoint ora_curenta {
      bins zero = {0};
      bins max = {23};
      bins subinterval1 = {[1:7]};   // 1-7
      bins subinterval2 = {[8:15]};  // 8-15
      bins subinterval3 = {[16:22]}; // 16-22
    }
  endgroup
  
  // covergroup pentru counter_tacte
  covergroup cg_counter_tacte;
    cp_counter_tacte: coverpoint counter_tacte {
      bins zero = {0};
      bins max_val = {3};  // valoarea maximă (tacte_pe_ora)
      bins intermediar = {1,2};  // valori intermediare
    }
  endgroup
  
  // variabile pentru sampling
  int reg_nr_locuri_libere;
  int ora_curenta;
  int counter_tacte;
  
  // constructor
  function new();
    cg_nr_locuri_libere = new();
    cg_ora_curenta = new();
    cg_counter_tacte = new();
  endfunction
  
  // metodă pentru sampling
  function void sample(int nr_locuri_libere_val, int ora_curenta_val, int counter_tacte_val);
    reg_nr_locuri_libere = nr_locuri_libere_val;
    ora_curenta = ora_curenta_val;
    counter_tacte = counter_tacte_val;
    
    cg_nr_locuri_libere.sample();
    cg_ora_curenta.sample();
    cg_counter_tacte.sample();
  endfunction
  
  // afișarea raportului de coverage
  function void report_coverage();
    $display("========== COVERAGE REPORT ==========");
    $display("Coverage for nr_locuri_libere: %.2f%%", cg_nr_locuri_libere.get_inst_coverage());
    $display("Coverage for ora_curenta: %.2f%%", cg_ora_curenta.get_inst_coverage());
    $display("Coverage for counter_tacte: %.2f%%", cg_counter_tacte.get_inst_coverage());
    $display("=====================================");
  endfunction
  
endclass 

//-------------------------------------------------------------------------
//                      APB SCOREBOARD
//-------------------------------------------------------------------------
class scoreboard_apb;
  
  mailbox apb_mon2scb;
  mailbox button_mon2scb;
  mailbox output_mon2scb;
  
  int no_transactions;
  int tacte_pe_ora = 3;
  int counter_tacte = 0; 
  
  bit [7:0] reg_nr_locuri_libere;
  bit [7:0] reg_ora_curenta;
  bit [7:0] reg_ora_start;
  bit [7:0] reg_ora_stop;
  
  int max_locuri = 10;
  int locuri_ocupate = 0;
  
  scoreboard_coverage colector_coverage;
  
  function new(mailbox apb_mon2scb, mailbox button_mon2scb, mailbox output_mon2scb);
    this.apb_mon2scb = apb_mon2scb;
    this.button_mon2scb = button_mon2scb;
    this.output_mon2scb = output_mon2scb;
    
    reg_nr_locuri_libere = 8'h00;
    reg_ora_curenta = 8'h00;
    reg_ora_start = 8'h08;
    reg_ora_stop = 8'd22;
    
    colector_coverage = new();
  endfunction
  
  task proceseaza_buton(button_transaction button_trans);
    if ((reg_ora_curenta[4:0] >= reg_ora_start[4:0]) && 
        (reg_ora_curenta[4:0] < reg_ora_stop[4:0])) begin
      
      if (button_trans.button_input) begin
        if (locuri_ocupate < max_locuri) begin
          locuri_ocupate++;
          $display("[SCB-INFO] Masina a intrat. Locuri ocupate: %0d/%0d", locuri_ocupate, max_locuri);
        end
      end
      
      if (button_trans.button_output) begin
        if (locuri_ocupate > 0) begin
          locuri_ocupate--;
          $display("[SCB-INFO] Masina a iesit. Locuri ocupate: %0d/%0d", locuri_ocupate, max_locuri);
        end
      end
      
      reg_nr_locuri_libere[3:0] = max_locuri - locuri_ocupate;
    end
  endtask
  
  task incrementare_ora();
    if (reg_ora_curenta[4:0] < 5'd23)
      reg_ora_curenta[4:0] = reg_ora_curenta[4:0] + 1;
    else
      reg_ora_curenta[4:0] = 5'd0;
  endtask

  task proceseaza_tact(transaction_iesire output_trans);
    counter_tacte++;
    if (counter_tacte >= tacte_pe_ora) begin
      incrementare_ora();
      counter_tacte = 0;
    end
  endtask

  task main;
    transaction_apb trans;
    button_transaction button_trans;
    transaction_iesire output_trans;
    
    fork
      forever begin
        #50;
        apb_mon2scb.get(trans);
        if (!trans.pwrite) begin
            // Logica citire... (păstrată din codul tău)
            no_transactions++;
        end else begin
            if (trans.paddr == 8'h02) reg_ora_start = trans.pwdata;
            if (trans.paddr == 8'h03) reg_ora_stop = trans.pwdata;
            no_transactions++;
        end
      end
      
      forever begin
        button_mon2scb.get(button_trans);
        proceseaza_buton(button_trans);
        colector_coverage.sample(reg_nr_locuri_libere[3:0], reg_ora_curenta[4:0], counter_tacte);
      end

      forever begin
        output_mon2scb.get(output_trans);
        proceseaza_tact(output_trans);
        
        if (output_trans.numar_locuri_libere != reg_nr_locuri_libere[3:0])
          $error("%0t: Mismatch Locuri! SCB:%0d DUT:%0d", $time, reg_nr_locuri_libere[3:0], output_trans.numar_locuri_libere);
          
        colector_coverage.sample(reg_nr_locuri_libere[3:0], reg_ora_curenta[4:0], counter_tacte);
      end
    join
  endtask

  function void report_coverage();
    colector_coverage.report_coverage();
  endfunction

endclass