//-------------------------------------------------------------------------
//                      www.verificationguide.com
//-------------------------------------------------------------------------
class generator_apb;
  
  // clasa contine doua atribute de tipul "apb_transaction"
  rand transaction_apb trans,tr;
  
  // repeat_count arata numarul de tranzactii care vor fi generate
  int repeat_count;
  
  //tipul de date mailbox, care poate fi vazut ca o structura de tip coada, reprezinta "portul" prin care generatorul trimite date driver-ului.
  //mailbox, to generate and send the packet to driver
  mailbox gen2driv;
  
  //declararea unui eveniment
  event ended;
  
  // constructor
  function new(mailbox gen2driv, event ended);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2driv = gen2driv;
    this.ended    = ended;
    trans = new();  
  endfunction
  
   
  //generatorul aleatorizeaza si transmite spre exterior prin "portul" de tip mailbox continutul tranzactiilor (al caror numar este egal cu repeat_count)
  //main task, generates(create and randomizes) the repeat_count number of transaction packets and puts into mailbox
  task write_reg( bit[7:0] addr_p, bit[7:0] data_p);
    
      if( !trans.randomize() with{
          paddr == addr_p;
          pwdata == data_p;
          pwrite == 1;
    }) 
          $fatal("Gen:: trans randomization failed");   
 // Creăm o copie profundă a tranzacției randomizate
      tr = trans.do_copy();
 // Trimitem copia prin mailbox
          gen2driv.put(tr);
     
           -> ended; 
  endtask
  
          
   task read_reg(  bit[7:0] data_p);
   
      if(!trans.randomize() with{
          pwdata == data_p;
          pwrite == 0;
    }) 
          $fatal("Gen:: trans randomization failed");   
  // Creăm o copie profundă a tranzacției randomizate        
      tr = trans.do_copy();
  // Trimitem copia prin mailbox        
          gen2driv.put(tr);
   
           -> ended; 
  endtask
  
  
  task main();
    repeat(repeat_count) begin
      if (!trans.randomize()) 
        $fatal("Gen:: trans randomization failed");
      
      // Creăm o copie profundă a tranzacției randomizate
      tr = trans.do_copy();
      
      // Trimitem copia prin mailbox
      gen2driv.put(tr);
    end
    // semnalăm sfârșitul generării
    -> ended; 
  endtask
  
endclass