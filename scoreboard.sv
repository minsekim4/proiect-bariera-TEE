//-------------------------------------------------------------------------
//                      APB SCOREBOARD
//-------------------------------------------------------------------------
// Scoreboard-ul preia tranzacțiile APB de la monitor, 
// implementează funcționalitatea DUT-ului folosind registri individuali
// și verifică acuratețea citirilor

class scoreboard_apb;
  
  // mailbox pentru primirea datelor de la monitor
  mailbox apb_mon2scb;
  mailbox button_mon2scb;
  mailbox output_mon2scb;
  
  // numărul de tranzacții procesate
  int no_transactions;

  int tacte_pe_ora =3;
  int counter_tacte = 0;  // counter pentru numărul de tacte primite
  
  // registri folosiți pentru a simula DUT-ul conform specificațiilor
  // Adrese registri:
  // 0x00 - nr_locuri_libere (RO)
  // 0x01 - ora_curenta (RO)
  // 0x02 - ora_start (RW)
  // 0x03 - ora_stop (RW)
  
  bit [7:0] reg_nr_locuri_libere;  // RO - biți 3:0 = numărător
  bit [7:0] reg_ora_curenta;        // RO - biți 4:0 = ora curentă
  bit [7:0] reg_ora_start;          // RW - biți 4:0 = ora start
  bit [7:0] reg_ora_stop;           // RW - biți 4:0 = ora stop
  
  // variabile interne pentru funcționalitate
  int max_locuri = 10;  // numărul maxim de locuri disponibile
  int locuri_ocupate = 0;
  
  // coverage
  //coverage_stimuli_externi colector_coverage;
  
  // constructor
  function new(mailbox apb_mon2scb, mailbox button_mon2scb, mailbox output_mon2scb );
    this.apb_mon2scb = apb_mon2scb;
    this.button_mon2scb = button_mon2scb;
    this.output_mon2scb = output_mon2scb;
    
    // inițializare registri cu valori implicite
    reg_nr_locuri_libere = 8'h00;  // toate locurile sunt libere inițial
    reg_ora_curenta = 8'h00;        // ora curentă = 0
    reg_ora_start = 8'h08;          // ora start = 0xFF (toți biții 4:0 = 1)
    reg_ora_stop = 8'd22;           // ora stop = 0
    
    // coverage
  //  colector_coverage = new();
  endfunction
  
  // task pentru procesarea evenimentelor de la butoane (senzori)
  task proceseaza_buton(transaction_button button_trans);
    // verificăm dacă DUT-ul este activ (ora curentă între ora_start și ora_stop)
    if ((reg_ora_curenta[4:0] >= reg_ora_start[4:0]) && 
        (reg_ora_curenta[4:0] < reg_ora_stop[4:0])) begin
      
      // senzor intrare - creștem numărul de locuri ocupate
      if (button_trans.button_input) begin
        if (locuri_ocupate < max_locuri) begin
          locuri_ocupate++;
          $display("&0t [SCB-INFO] Masina a intrat. Locuri ocupate: %0d/%0d", $time, 
                   locuri_ocupate, max_locuri);
        end else begin
          $display("[SCB-WARN] Parcare plina! Masina nu poate intra.");
        end
      end
      
      // senzor ieșire - scădem numărul de locuri ocupate
      if (button_trans.button_output) begin
        if (locuri_ocupate > 0) begin
          locuri_ocupate--;
          $display("[SCB-INFO] Masina a iesit. Locuri ocupate: %0d/%0d", 
                   locuri_ocupate, max_locuri);
        end else begin
          $display("[SCB-WARN] Eroare: Nu exista masini in parcare, deci nu se va deschide bariera!");
        end
      end
      
      // actualizăm registrul nr_locuri_libere
      reg_nr_locuri_libere[3:0] = max_locuri - locuri_ocupate;
      
    end else begin
      $display("[SCB-INFO] DUT-ul este inactiv (afara orelor de functionare)");
    end
  endtask
  
  // task pentru incrementarea orei curente  
 task incrementare_ora();
  if (reg_ora_curenta[4:0] < 5'd23)  // 23 este ultima oră validă
    reg_ora_curenta[4:0] = reg_ora_curenta[4:0] + 1;
  else
    reg_ora_curenta[4:0] = 5'd0;  // după 23 revine la 0
    
  $display("[SCB-INFO] Ora curenta a fost incrementata la: %0d", 
           reg_ora_curenta[4:0]);
endtask

//////incrementare tacte pentru ore
task proceseaza_tact(transaction_output output_trans);
    // incrementăm counterul de tacte
    counter_tacte++;
    
    $display("[SCB-INFO] Tact primit #%0d", counter_tacte, tacte_pe_ora);
    
    // când am acumulat suficiente tacte, incrementăm ora
    if (counter_tacte >= tacte_pe_ora) begin
      incrementare_ora();
      counter_tacte = 0;  // resetăm counterul
      
    end
endtask
//////////

  // task principal de verificare
  task main;
    transaction_apb trans;
    transaction_button button_trans;
    transaction_output output_trans; 
    
    fork
      // procesare tranzacții APB
      forever begin
        #50;
        
        // preluăm tranzacția de la monitor
        apb_mon2scb.get(trans);
        
        // cazul CITIRE (pwrite = 0)
        if (!trans.pwrite) begin
          case(trans.paddr)
            8'h00: begin  // registrul nr_locuri_libere (RO)
              if (reg_nr_locuri_libere != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at NR_LOCURI_LIBERE register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_nr_locuri_libere, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at NR_LOCURI_LIBERE register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Locuri libere = %0d", 
                         trans.paddr, reg_nr_locuri_libere, trans.prdata, 
                         reg_nr_locuri_libere[3:0]);
                colector_coverage.sample(trans);
              end
            end
            
            8'h01: begin  // registrul ora_curenta (RO)
              if (reg_ora_curenta != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at ORA_CURENTA register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_ora_curenta, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at ORA_CURENTA register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Ora = %0d", 
                         trans.paddr, reg_ora_curenta, trans.prdata, 
                         reg_ora_curenta[4:0]);
                colector_coverage.sample(trans);
              end
            end
            
            8'h02: begin  // registrul ora_start (RW)
              if (reg_ora_start != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at ORA_START register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_ora_start, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at ORA_START register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Ora start = %0d", 
                         trans.paddr, reg_ora_start, trans.prdata, 
                         reg_ora_start[4:0]);
                colector_coverage.sample(trans);
              end
            end
            
            8'h03: begin  // registrul ora_stop (RW)
              if (reg_ora_stop != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at ORA_STOP register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_ora_stop, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at ORA_STOP register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Ora stop = %0d", 
                         trans.paddr, reg_ora_stop, trans.prdata, 
                         reg_ora_stop[4:0]);
                colector_coverage.sample(trans);
              end
            end
            
            default: begin
              $warning("[SCB-WARN] Read from unknown address: %0h", trans.paddr);
            end
          endcase
        end
        
        // cazul SCRIERE (pwrite = 1)
        else if (trans.pwrite) begin
          case(trans.paddr)
            8'h00: begin
              $warning("[SCB-WARN] Write to read-only register NR_LOCURI_LIBERE (Addr=0x00)");
              $warning("\tAttempted to write data = %0h", trans.pwdata);
              // registrul este RO - nu se actualizează
            end
            
            8'h01: begin
              $warning("[SCB-WARN] Write to read-only register ORA_CURENTA (Addr=0x01)");
              $warning("\tAttempted to write data = %0h", trans.pwdata);
              // registrul este RO - nu se actualizează
            end
            
            8'h02: begin
              reg_ora_start = trans.pwdata;
              $display("[SCB-INFO] Write to ORA_START register: Addr = %0h, Data = %0h, Ora start = %0d", 
                       trans.paddr, trans.pwdata, reg_ora_start[4:0]);
             // colector_coverage.sample(trans);
            end
            
            8'h03: begin
              reg_ora_stop = trans.pwdata;
              $display("[SCB-INFO] Write to ORA_STOP register: Addr = %0h, Data = %0h, Ora stop = %0d", 
                       trans.paddr, trans.pwdata, reg_ora_stop[4:0]);
           //   colector_coverage.sample(trans);
            end
            
            default: begin
              $warning("[SCB-WARN] Write to unknown address: %0h with data %0h", 
                       trans.paddr, trans.pwdata);
            end
          endcase
        end
        
        // incrementează contorul de tranzacții
        no_transactions++;
        
        // afișare stare
        $display("[SCB-STATS] Total transactions processed: %0d", no_transactions);
        $display("-------------------------------------------");
      end
      
      // procesare tranzacții de la butoane (senzori)
      forever begin
        button_mon2scb.get(button_trans);
        proceseaza_buton(button_trans);
        display_registers();  // afișăm starea după fiecare eveniment
      end

     // procesare tranzacții de la output (tacte de ceas pentru incrementarea orei)
      forever begin
        output_mon2scb.get(output_trans);
        proceseaza_tact(output_trans);
        display_registers();  // afișăm starea după fiecare tact
        assert (output_trans.numar_locuri_libere == reg_nr_locuri_libere) 
        else $error("&0t valoarea calculata de scoreboard este %0d si valoarea din DUT (colectata de monitor) este %0d", $time, reg_nr_locuri_libere, output_trans.numar_locuri_libere);
     if (output_trans.parcare_goala ==1)

     
     assert (reg_nr_locuri_libere ==0) 
        else $error("&0t valoarea calculata de scoreboard este %0d si valoarea din DUT (colectata de monitor) este %0d", $time, reg_nr_locuri_libere, output_trans.numar_locuri_libere);
  
      end
      
    join
  endtask

  //coverage
  - reg_nr_locuri_libere: 0, val_max, valori_intermediare
  - reg_ore: 0, 23, 3 subintervale divizate egal
  - counter_tacte: 0, val_max, o valoare intermediara
  
  // metodă pentru afișarea tuturor registrilor
  task display_registers();
    $display("========== REGISTER VALUES ==========");
    $display("reg_nr_locuri_libere = 0x%0h (Locuri libere: %0d/%0d)", 
             reg_nr_locuri_libere, reg_nr_locuri_libere[3:0], max_locuri);
    $display("reg_ora_curenta      = 0x%0h (Ora curenta: %0d)", 
             reg_ora_curenta, reg_ora_curenta[4:0]);
    $display("reg_ora_start        = 0x%0h (Ora start: %0d)", 
             reg_ora_start, reg_ora_start[4:0]);
    $display("reg_ora_stop         = 0x%0h (Ora stop: %0d)", 
             reg_ora_stop, reg_ora_stop[4:0]);
    $display("Locuri ocupate: %0d", locuri_ocupate);
    $display("=====================================");
  endtask
  
  // metodă pentru resetarea registrilor
  task reset_registers();
    reg_nr_locuri_libere = 8'h00;
    reg_ora_curenta = 8'h00;
    reg_ora_start = 8'hFF;
    reg_ora_stop = 8'h00;
    locuri_ocupate = 0;
    
    $display("[SCB-INFO] All registers reset to default values");
    display_registers();
  endtask

  //-------------------------------------------------------------------------
//                      COVERAGE CLASS
//-------------------------------------------------------------------------
class coverage_apb;
  
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
  
  // metodă pentru afișarea raportului de coverage
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
// Scoreboard-ul preia tranzacțiile APB de la monitor, 
// implementează funcționalitatea DUT-ului folosind registri individuali
// și verifică acuratețea citirilor

class scoreboard_apb;
  
  // mailbox pentru primirea datelor de la monitor
  mailbox apb_mon2scb;
  mailbox button_mon2scb;
  mailbox output_mon2scb;
  
  // numărul de tranzacții procesate
  int no_transactions;

  int tacte_pe_ora = 3;
  int counter_tacte = 0;  // counter pentru numărul de tacte primite
  
  // registri folosiți pentru a simula DUT-ul conform specificațiilor
  // Adrese registri:
  // 0x00 - nr_locuri_libere (RO)
  // 0x01 - ora_curenta (RO)
  // 0x02 - ora_start (RW)
  // 0x03 - ora_stop (RW)
  
  bit [7:0] reg_nr_locuri_libere;  // RO - biți 3:0 = numărător
  bit [7:0] reg_ora_curenta;        // RO - biți 4:0 = ora curentă
  bit [7:0] reg_ora_start;          // RW - biți 4:0 = ora start
  bit [7:0] reg_ora_stop;           // RW - biți 4:0 = ora stop
  
  // variabile interne pentru funcționalitate
  int max_locuri = 10;  // numărul maxim de locuri disponibile
  int locuri_ocupate = 0;
  
  // coverage
  coverage_apb colector_coverage;
  
  // constructor
  function new(mailbox apb_mon2scb, mailbox button_mon2scb, mailbox output_mon2scb);
    this.apb_mon2scb = apb_mon2scb;
    this.button_mon2scb = button_mon2scb;
    this.output_mon2scb = output_mon2scb;
    
    // inițializare registri cu valori implicite
    reg_nr_locuri_libere = 8'h00;  // toate locurile sunt libere inițial
    reg_ora_curenta = 8'h00;        // ora curentă = 0
    reg_ora_start = 8'h08;          // ora start = 8
    reg_ora_stop = 8'd22;           // ora stop = 22
    
    // coverage
    colector_coverage = new();
  endfunction
  
  // task pentru procesarea evenimentelor de la butoane (senzori)
  task proceseaza_buton(transaction_button button_trans);
    // verificăm dacă DUT-ul este activ (ora curentă între ora_start și ora_stop)
    if ((reg_ora_curenta[4:0] >= reg_ora_start[4:0]) && 
        (reg_ora_curenta[4:0] < reg_ora_stop[4:0])) begin
      
      // senzor intrare - creștem numărul de locuri ocupate
      if (button_trans.button_input) begin
        if (locuri_ocupate < max_locuri) begin
          locuri_ocupate++;
          $display("[SCB-INFO] Masina a intrat. Locuri ocupate: %0d/%0d", 
                   locuri_ocupate, max_locuri);
        end else begin
          $display("[SCB-WARN] Parcare plina! Masina nu poate intra.");
        end
      end
      
      // senzor ieșire - scădem numărul de locuri ocupate
      if (button_trans.button_output) begin
        if (locuri_ocupate > 0) begin
          locuri_ocupate--;
          $display("[SCB-INFO] Masina a iesit. Locuri ocupate: %0d/%0d", 
                   locuri_ocupate, max_locuri);
        end else begin
          $display("[SCB-WARN] Eroare: Nu exista masini in parcare, deci nu se va deschide bariera!");
        end
      end
      
      // actualizăm registrul nr_locuri_libere
      reg_nr_locuri_libere[3:0] = max_locuri - locuri_ocupate;
      
    end else begin
      $display("[SCB-INFO] DUT-ul este inactiv (afara orelor de functionare)");
    end
  endtask
  
  // task pentru incrementarea orei curente  
  task incrementare_ora();
    if (reg_ora_curenta[4:0] < 5'd23)  // 23 este ultima oră validă
      reg_ora_curenta[4:0] = reg_ora_curenta[4:0] + 1;
    else
      reg_ora_curenta[4:0] = 5'd0;  // după 23 revine la 0
      
    $display("[SCB-INFO] Ora curenta a fost incrementata la: %0d", 
             reg_ora_curenta[4:0]);
  endtask
  
  // task pentru procesarea evenimentelor de tact (de la output)
  task proceseaza_tact(transaction_output output_trans);
    // incrementăm counterul de tacte
    counter_tacte++;
    
    $display("[SCB-INFO] Tact primit #%0d (necesare %0d pentru o ora)", 
             counter_tacte, tacte_pe_ora);
    
    // când am acumulat suficiente tacte, incrementăm ora
    if (counter_tacte >= tacte_pe_ora) begin
      incrementare_ora();
      counter_tacte = 0;  // resetăm counterul
      
      // după incrementarea orei, verificăm din nou starea activă/inactivă
      $display("[SCB-INFO] DUT-ul este %s intre orele de functionare", 
               ((reg_ora_curenta[4:0] >= reg_ora_start[4:0]) && 
                (reg_ora_curenta[4:0] < reg_ora_stop[4:0])) ? "activ" : "inactiv");
    end
  endtask
  
  // task principal de verificare
  task main;
    transaction_apb trans;
    transaction_button button_trans;
    transaction_output output_trans;  // declarație pentru tranzacția de output
    
    fork
      // procesare tranzacții APB
      forever begin
        #50;
        
        // preluăm tranzacția de la monitor
        apb_mon2scb.get(trans);
        
        // cazul CITIRE (pwrite = 0)
        if (!trans.pwrite) begin
          case(trans.paddr)
            8'h00: begin  // registrul nr_locuri_libere (RO)
              if (reg_nr_locuri_libere != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at NR_LOCURI_LIBERE register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_nr_locuri_libere, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at NR_LOCURI_LIBERE register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Locuri libere = %0d", 
                         trans.paddr, reg_nr_locuri_libere, trans.prdata, 
                         reg_nr_locuri_libere[3:0]);
              end
            end
            
            8'h01: begin  // registrul ora_curenta (RO)
              if (reg_ora_curenta != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at ORA_CURENTA register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_ora_curenta, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at ORA_CURENTA register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Ora = %0d", 
                         trans.paddr, reg_ora_curenta, trans.prdata, 
                         reg_ora_curenta[4:0]);
              end
            end
            
            8'h02: begin  // registrul ora_start (RW)
              if (reg_ora_start != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at ORA_START register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_ora_start, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at ORA_START register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Ora start = %0d", 
                         trans.paddr, reg_ora_start, trans.prdata, 
                         reg_ora_start[4:0]);
              end
            end
            
            8'h03: begin  // registrul ora_stop (RW)
              if (reg_ora_stop != trans.prdata) begin
                $error("[SCB-FAIL] Read mismatch at ORA_STOP register!");
                $error("\tAddr = %0h, Expected = %0h, Actual = %0h", 
                       trans.paddr, reg_ora_stop, trans.prdata);
              end
              else begin
                $display("[SCB-PASS] Read match at ORA_STOP register");
                $display("\tAddr = %0h, Expected = %0h, Actual = %0h, Ora stop = %0d", 
                         trans.paddr, reg_ora_stop, trans.prdata, 
                         reg_ora_stop[4:0]);
              end
            end
            
            default: begin
              $warning("[SCB-WARN] Read from unknown address: %0h", trans.paddr);
            end
          endcase
        end
        
        // cazul SCRIERE (pwrite = 1)
        else if (trans.pwrite) begin
          case(trans.paddr)
            8'h00: begin
              $warning("[SCB-WARN] Write to read-only register NR_LOCURI_LIBERE (Addr=0x00)");
              $warning("\tAttempted to write data = %0h", trans.pwdata);
              // registrul este RO - nu se actualizează
            end
            
            8'h01: begin
              $warning("[SCB-WARN] Write to read-only register ORA_CURENTA (Addr=0x01)");
              $warning("\tAttempted to write data = %0h", trans.pwdata);
              // registrul este RO - nu se actualizează
            end
            
            8'h02: begin
              reg_ora_start = trans.pwdata;
              $display("[SCB-INFO] Write to ORA_START register: Addr = %0h, Data = %0h, Ora start = %0d", 
                       trans.paddr, trans.pwdata, reg_ora_start[4:0]);
            end
            
            8'h03: begin
              reg_ora_stop = trans.pwdata;
              $display("[SCB-INFO] Write to ORA_STOP register: Addr = %0h, Data = %0h, Ora stop = %0d", 
                       trans.paddr, trans.pwdata, reg_ora_stop[4:0]);
            end
            
            default: begin
              $warning("[SCB-WARN] Write to unknown address: %0h with data %0h", 
                       trans.paddr, trans.pwdata);
            end
          endcase
        end
        
        // incrementează contorul de tranzacții
        no_transactions++;
        
        // afișare stare
        $display("[SCB-STATS] Total transactions processed: %0d", no_transactions);
        $display("-------------------------------------------");
      end
      
      // procesare tranzacții de la butoane (senzori)
      forever begin
        button_mon2scb.get(button_trans);
        proceseaza_buton(button_trans);
        display_registers();  // afișăm starea după fiecare eveniment
        
        // sample pentru coverage
        colector_coverage.sample(reg_nr_locuri_libere[3:0], reg_ora_curenta[4:0], counter_tacte);
      end

      // procesare tranzacții de la output (tacte de ceas pentru incrementarea orei)
      forever begin
        output_mon2scb.get(output_trans);
        proceseaza_tact(output_trans);
        display_registers();  // afișăm starea după fiecare tact
        
        // verificare numar_locuri_libere
        if (output_trans.numar_locuri_libere != reg_nr_locuri_libere[3:0]) begin
          $error("%0t: valoarea calculata de scoreboard este %0d si valoarea din DUT (colectata de monitor) este %0d", 
                 $time, reg_nr_locuri_libere[3:0], output_trans.numar_locuri_libere);
        end
        
        // verificare parcare_goala
        if (output_trans.parcare_goala == 1) begin
          if (reg_nr_locuri_libere[3:0] != 0) begin
            $error("%0t: PARCARE_GOALA activata dar reg_nr_locuri_libere = %0d (expected 0)", 
                   $time, reg_nr_locuri_libere[3:0]);
          end else begin
            $display("[SCB-PASS] Parcare goala detectata corect la timpul %0t", $time);
          end
        end
        
        // sample pentru coverage
        colector_coverage.sample(reg_nr_locuri_libere[3:0], reg_ora_curenta[4:0], counter_tacte);
      end
      
    join
  endtask

  
  // metodă pentru afișarea tuturor registrilor
  task display_registers();
    $display("========== REGISTER VALUES ==========");
    $display("reg_nr_locuri_libere = 0x%0h (Locuri libere: %0d/%0d)", 
             reg_nr_locuri_libere, reg_nr_locuri_libere[3:0], max_locuri);
    $display("reg_ora_curenta      = 0x%0h (Ora curenta: %0d)", 
             reg_ora_curenta, reg_ora_curenta[4:0]);
    $display("reg_ora_start        = 0x%0h (Ora start: %0d)", 
             reg_ora_start, reg_ora_start[4:0]);
    $display("reg_ora_stop         = 0x%0h (Ora stop: %0d)", 
             reg_ora_stop, reg_ora_stop[4:0]);
    $display("Locuri ocupate: %0d", locuri_ocupate);
    $display("Counter tacte: %0d/%0d", counter_tacte, tacte_pe_ora);
    $display("=====================================");
  endtask
  
  // metodă pentru resetarea registrilor
  task reset_registers();
    reg_nr_locuri_libere = 8'h00;
    reg_ora_curenta = 8'h00;
    reg_ora_start = 8'hFF;
    reg_ora_stop = 8'h00;
    locuri_ocupate = 0;
    counter_tacte = 0;
    
    $display("[SCB-INFO] All registers reset to default values");
    display_registers();
  endtask
  
  // metodă pentru afișarea raportului de coverage
  task report_coverage();
    colector_coverage.report_coverage();
  endtask
  
    
endclass