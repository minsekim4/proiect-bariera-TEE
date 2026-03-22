//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

//aici se declara tipul de data folosit pentru a stoca datele vehiculate intre generator si driver; monitorul, de asemenea, preia datele de pe interfata, le recompune folosind un obiect al acestui tip de data, si numai apoi le proceseaza
class apb_transaction;
  //se declara atributele clasei
  //campurile declarate cu cuvantul cheie rand vor primi valori aleatoare la aplicarea functiei randomize()
  rand bit [7:0] addr;  
  rand bit       wr_rd;
  rand bit [7:0] data;
  rand int delay_between_transaction;

  
  //constrangerile reprezinta un tip de membru al claselor din SystemVerilog, pe langa atribute si metode
  //aceasta constrangere specifica faptul ca se executa fie o scriere, fie o citire
  //constrangerile sunt aplicate de catre compilator atunci cand atributele clasei primesc valori aleatoare in urma folosirii functiei randomize
  constraint delay_c { delay_between_transaction inside {[1:20]}; }
  
     
  
  //aceasta functie este apelata dupa aplicarea functiei randomize() asupra obiectelor apartinand acestei clase
  //aceasta functie afiseaza valorile aleatorizate ale atributelor clasei
  function void post_randomize();
  $display("--------- [Trans] post_randomize ------");
  if(wr_rd) 
    $display("\t addr  = %0h\t wr_rd = SCRIERE\t wdata = %0h \t delay = %0d", addr, data, delay_between_transaction);
  else 
    $display("\t addr  = %0h\t rd_en = CITIRE  \t delay =  %0d", addr, delay_between_transaction);
  $display("-----------------------------------------");
endfunction
  
  //operator de copiere a unui obiect intr-un alt obiect (deep copy)
  function apb_transaction do_copy();
    apb_transaction trans;
    trans = new();
    trans.addr  = this.addr;
    trans.wr_rd = this.wr_rd;
    trans.data = this.data;
	trans.delay_between_transaction = this.delay_between_transaction;
    return trans;
  endfunction
endclass


//paddresa, pwrite, data =>  difera la tranzactii == informatii reale


//psel si penb arata doar daca se poate desfasura