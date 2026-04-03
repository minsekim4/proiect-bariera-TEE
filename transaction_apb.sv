//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

//aici se declara tipul de pwdata folosit pentru a stoca datele vehiculate intre generator si driver; monitorul, de asemenea, preia datele de pe interfata, le recompune folosind un obiect al acestui tip de pwdata, si numai apoi le proceseaza
class transaction_apb;
  //se declara atributele clasei
  //campurile declarate cu cuvantul cheie rand vor primi valori aleatoare la aplicarea functiei randomize()
  rand bit [7:0] paddr;  
  rand bit       pwrite; // 1: scriere; 0: citire
  rand bit [7:0] pwdata;
  rand int delay_between_transaction;

  
  //constrangerile reprezinta un tip de membru al claselor din SystemVerilog, pe langa atribute si metode
  //aceasta constrangere specifica faptul ca se executa fie o scriere, fie o citire
  //constrangerile sunt aplicate de catre compilator atunci cand atributele clasei primesc valori aleatoare in urma folosirii functiei randomize
  constraint delay_c { delay_between_transaction inside {[1:20]}; }
  
     
  
  //aceasta functie este apelata dupa aplicarea functiei randomize() asupra obiectelor apartinand acestei clase
  //aceasta functie afiseaza valorile aleatorizate ale atributelor clasei
  function void post_randomize();
  $display("--------- [Trans] post_randomize ------");
  if(pwrite) 
    $display("\t paddr  = %0h\t pwrite = SCRIERE\t wpwdata = %0h \t delay = %0d", paddr, pwdata, delay_between_transaction);
  else 
    $display("\t paddr  = %0h\t rd_en = CITIRE  \t delay =  %0d", paddr, delay_between_transaction);
  $display("-----------------------------------------");
endfunction
  
  //operator de copiere a unui obiect intr-un alt obiect (deep copy)
  function transaction_apb do_copy();
    transaction_apb trans;
    trans = new();
    trans.paddr  = this.paddr;
    trans.pwrite = this.pwrite;
    trans.pwdata = this.pwdata;
	trans.delay_between_transaction = this.delay_between_transaction;
    return trans;
  endfunction
endclass


//ppaddresa, pwrite, pwdata =>  difera la tranzactii == informatii reale


//psel si penb arata doar daca se poate desfasura