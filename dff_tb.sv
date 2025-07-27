`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 12:14:16 PM
// Design Name: D-flip flop verification
// Module Name: dff_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dff(dff_if vif);
  
  always@(posedge vif.clk)
    begin
      if(vif.rst ==1'b1)
        vif.dout <=1'b0;
      else 
        vif.dout <=vif.din;
    end
endmodule
  
  interface dff_if;
    logic clk;
    logic rst;
    logic din;
    logic dout;
    
  endinterface
  
  class transaction;// transaction class
  
  rand bit din;
  bit dout;
  
  
  function transaction copy(); //deep copy
    copy=new();
    copy.din = this.din;
    copy.dout = this.dout;
  endfunction
  
  function void display(input string tag); 
    $display("[%0s]: DIN :%0b DOUT:%0b",tag,din,dout);
  endfunction
  
endclass

class generator; //generator class generates transactions
  
  transaction tr;
  mailbox #(transaction) g2d; //for driver
  mailbox #(transaction) g2s; //for scoreboard
  int count; // stilmulus count
  event sconext; //sense completion of scoreboard work
  event done; //trigger once requested number of simulus is applied
  
  
  function  new(mailbox #(transaction) g2d, mailbox #(transaction)g2s);
    this.g2d=g2d;
    this.g2s=g2s;
    tr=new();
    endfunction
  
  task run();
    
    repeat(count)
      begin
      assert(tr.randomize()) else $display("Randomization of transaction unsuccessful");
        g2d.put(tr.copy); //sending deep copy of transaction 
    g2s.put(tr.copy);
    tr.display("GEN");
        @(sconext);
      end
    ->done;
  endtask
endclass
    
///////////////////////////////////////////////////////////////////////////////    
    class driver;
     transaction dc;
      mailbox #(transaction) g2d;
      virtual dff_if vif;
      
      function new(mailbox #(transaction)g2d);
        this.g2d=g2d;
      endfunction
      
      task reset();
        vif.rst<=1'b1;
        repeat(5)@(posedge vif.clk);
        vif.rst<=1'b0;
        @(posedge vif.clk);
        $display ("[DRV]: RESET OF D-FF DONE");
      endtask
      
      task run();
       forever begin
         g2d.get(dc);
         vif.din<=dc.din;
         @(posedge vif.clk);
         dc.display("DRV");
         vif.din<=1'b0;
         @(posedge vif.clk);
       end
      endtask
    endclass
         
//////////////////////////////////////////////////////////////////////////      
      
 class monitor;
   
   transaction dc; //to store data from DUT in the form of transaction
   mailbox #(transaction) m2s; //mailbox to send data from monitor to scoreboard
   virtual dff_if vif;// connection to interface
   
   
   function new(mailbox #(transaction) m2s);
     this.m2s=m2s;
   endfunction
   
   
   task run();
     dc=new();
     forever begin
       repeat(2) @(posedge vif.clk);
       dc.dout = vif.dout;
       m2s.put(dc);
       dc.display("MON");
     end
   endtask
 endclass

////////////////////////////////////////////////////////////////////////
   
  class scoreboard;
    
  transaction mdata; //to store data received from monitor
  transaction gdata; // to store data from generator
    mailbox #(transaction) g2s;
    mailbox #(transaction) m2s;
    event sconext;
    
    function new(mailbox #(transaction) m2s, mailbox #(transaction)g2s);
      this.m2s=m2s;
      this.g2s=g2s;
    endfunction
    
    task run();
      forever begin
        m2s.get(mdata);
        g2s.get(gdata);
        mdata.display("SCO");
        gdata.display("REF");
        if (mdata.dout == gdata.din)
        $display("[SCO] : DATA MATCHED"); // Compare data and display the result
      else
        $display("[SCO] : DATA MISMATCHED");
        $display("----------------------------------");
        ->sconext;
        end
     endtask
 endclass          
        
//////////////////////////////////////////////////////////////////////////
                   
                   
class environment;
  
 generator gen;
 driver drv;
 monitor mon;
 scoreboard sco;
  
 event next;// gen->sco
  
  mailbox #(transaction) g2d; // gen-drv
  mailbox #(transaction) m2s; //mon-sco
  mailbox #(transaction) g2s; //gen-sco
  
  virtual dff_if vif;
  
  function new(virtual dff_if vif);
  g2d = new();
  g2s = new();
  
  gen = new(g2d,g2s);
  drv= new(g2d);
  
  m2s=new();
  mon =new(m2s);
  sco= new(m2s,g2s);
  
  this.vif=vif;
  drv.vif=this.vif;
  mon.vif=this.vif;
  
  gen.sconext=next;
  sco.sconext=next;
  
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass

///////////////////////////////////////////////////////////////////////////
    
  
 module dff_tb;
   
   dff_if vif();
   
   dff dut(vif);
   
   initial begin
     vif.clk<=0;
   end
   
   always #10 vif.clk<=~vif.clk;
   
   environment env;
   
   initial begin
     env =new(vif);
     env.gen.count=30;
     env.run();
   end
   
   initial begin
     $dumpfile("dump.vcd");
     $dumpvars;
   end
 endmodule
   
  
  
   
