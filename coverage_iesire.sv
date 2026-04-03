//-------------------------------------------------------------------------
// Coverage pentru interfata de iesire
//-------------------------------------------------------------------------

`define NR_TOTAL_LOCURI 15
class coverage;
  
  
  output_transaction trans_covered;
  
  
  covergroup output_transaction_cg;

    option.per_instance = 1;

    
    stare_bariera_cp : coverpoint trans_covered.stare_bariera {
      bins bariera_inchisa = {0};
      bins bariera_deschisa = {1};
    }

    
    nr_locuri_libere_cp : coverpoint trans_covered.nr_locuri_libere {

      bins parcare_goala = {0};        
      bins parcare_plina = {`NR_TOTAL_LOCURI};         

      bins intervale[3]= {[1:`NR_TOTAL_LOCURI-1]};
    }

    
    parcare_plina_cp : coverpoint trans_covered.parcare_plina {
      bins false = {0};
      bins true  = {1};
    }

    
    parcare_goala_cp : coverpoint trans_covered.parcare_goala {
      bins false = {0};
      bins true  = {1};
    }


    stare_parcare_cross : cross parcare_plina_cp, parcare_goala_cp{
      illegal_bins situatie_imposibila =  binsof(parcare_plina_cp.true) && binsof(parcare_goala_cp.true);
    }

    parcare_libera_goala_cross : cross nr_locuri_libere_cp, parcare_goala_cp{
      illegal_bins situatie_imposibila2 = binsof(nr_locuri_libere_cp.intervale[0]) && binsof(parcare_goala_cp.true);
    }

  endgroup


  
  function new();
    output_transaction_cg = new();
  endfunction


  
  task sample_function(output_transaction trans_covered);
    this.trans_covered = trans_covered;
    output_transaction_cg.sample();
  endtask

  function void print_coverage();
    $display("Stare bariera coverage = %.2f%%", output_transaction_cg.stare_bariera_cp.get_coverage());
    $display("Nr locuri libere coverage = %.2f%%", output_transaction_cg.nr_locuri_libere_cp.get_coverage());
    $display("Parcare plina coverage = %.2f%%", output_transaction_cg.parcare_plina_cp.get_coverage());
    $display("Parcare goala coverage = %.2f%%", output_transaction_cg.parcare_goala_cp.get_coverage());
    $display("Overall coverage = %.2f%%", output_transaction_cg.get_coverage());
  endfunction

endclass : coverage