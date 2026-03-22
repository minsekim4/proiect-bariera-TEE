//-------------------------------------------------------------------------
//						www.verificationguide.com
/*
are un mailbox
	un eveniment
	un constructor
    
task main: repeta de x ori, trans.randomize -  daca cumva se intampla sa am eroare in acea fct, dam si noi eroare (poate da eroare fct de aleatorizare a datelor cand atunci cand se folosesc constrangerile (ex vr ca adresa sa fie mai mica ca 3 si mai mare ca 6 => eroare))

generatorul vede de x ori, le aleatorizeaza, le face o copie, si se transmite la mailbox  -- schema bloc pe tableta

*/
//-------------------------------------------------------------------------
class generator;
  
  //clasa contine doua atribute de tipul "transaction"
  rand transaction trans,tr;
  
  //repeat_count arata numarul de tranzactii care vor fi generate
  int  repeat_count;
  
  //tipul de date mailbox, care poate fi vazut ca o structura de tip coada, reprezinta "portul" prin care generatorul trimite date driver-ului.
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //declararea unui eveniment
  event ended;
  
  //constructor
  function new(mailbox gen2driv,event ended);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
    this.ended    = ended;
    trans = new();
  endfunction
  
  //generatorul aleatorizeaza si transmite spre exterior prin "portul" de tip mailbox continutul tranzactiilor (al caror numar este egal cu repeat_count)
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
  task main();
    repeat(repeat_count) begin
    	if( !trans.randomize() ) 
          $fatal("Gen:: trans randomization failed");      
    	tr = trans.do_copy();
    	gen2driv.put(tr);
    end
    //se semnaleaza sfarsitul transmiterii datelor de catre generator
    -> ended; 
  endtask
  
endclass