`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/26/2025 08:07:18 PM
// Design Name: 
// Module Name: env
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


// Code your testbench here
// or browse Examples

module add
  (
    input [3:0] a,b,
    output reg [4:0] sum,
    input clk
  );
  
   always@(posedge clk)
    begin
      sum <= a + b;
    end
endmodule

class transaction;
  
  randc bit[3:0]a;
  randc bit [3:0]b;
  bit [4:0] sum;
  bit clk;
  
  //method to access current value of transaction class
  function void display();
    $display("a: %0d b:%0d",a,b);
  endfunction
  
  function transaction copy(); //creating a deep copy
    copy=new();
    copy.a=this.a;
    copy.b=this.b;
    copy.sum=this.sum;
  endfunction
  
endclass



class generator;

  transaction trans;
  mailbox #(transaction) g2d;
  event done;
  
  function new(mailbox #(transaction) g2d);
    this.g2d = g2d;
    trans = new(); //for deep copy
  endfunction
  
  task run();
    for(int i=0;i<10;i++)
      begin
        assert(trans.randomize()) else $display ("Randomization of packet unsuccessful");
        $display("[GEN] DATA SENT TO DRIVER");
        g2d.put(trans.copy); //sending copy of the object(instead of object itself), this will allow us to have an independent object for each transaction
        trans.display();
      #20; 
      end
    //->done;
      endtask
endclass




interface add_if;
  logic[3:0]a;
  logic[3:0]b;
  logic [4:0]sum;
  logic clk;
  
  //modport DRV(output a,b,input sum,clk);
endinterface


class driver;
  
  virtual add_if aif;
  mailbox #(transaction) g2d;
  transaction datac;
  
  function new(mailbox #(transaction) g2d);
    this.g2d=g2d;
  endfunction
  
  task run();
    forever begin
      g2d.get(datac);
      repeat (2)@(posedge aif.clk);
      aif.a <=datac.a;
      aif.b <=datac.b;
      $display("[DRV] Driver triggered");
    end
  endtask
endclass


class monitor;
  
  mailbox #(transaction) m2s;
  transaction dutin;
  virtual add_if aif;
  
  function new( mailbox #(transaction) m2s);
    this.m2s=m2s;
  endfunction
  
  task run();
    dutin=new();
    forever begin
      repeat (2)@(posedge aif.clk)
      dutin.a = aif.a;
      dutin.b = aif.b;
      dutin.sum = aif.sum;
      $display("[MON] DATA SENT TO SCOREBOARD");
      dutin.display();
      m2s.put(dutin);
    end
  endtask
endclass

class scoreboard;

 mailbox #(transaction) m2s;
  transaction dmon;
  virtual add_if aif;
  
  function new( mailbox #(transaction) m2s);
    this.m2s=m2s;
  endfunction

  task compare(input transaction trans);
    if((trans.sum)==(trans.a+trans.b))
      $display("[SCO]:SUM RESULT MATCH");
    else 
      $error("[SCO]:SUM RESULT MISMATCH");
  endtask
  
  task run();
    forever begin
      m2s.get(dmon);
      $display("[SCO]: DATA RECEIVED FROM MONITOR");
      dmon.display();
      compare(dmon);
      #40;
    end
  endtask
  
  
  
endclass
  
  
module tb;
  
  add_if aif();
  generator g;
  mailbox #(transaction) g2d;
  mailbox #(transaction) m2s;
  driver d;
  monitor m;
  scoreboard s;
  event done;
  
  add dut (aif.a, aif.b, aif.sum, aif.clk );
  
  initial begin
    aif.clk <=0;
  end
  
    always #10 aif.clk<= ~aif.clk;
  
  initial begin
    g2d=new();
    g=new(g2d);
    d=new(g2d);
    d.aif=aif;
    m2s=new();
    m=new(m2s);//connecting the driver and interface
    s=new(m2s);
    m.aif=aif; //connecting the monitor to the interface
    
    
    done =g.done;
  end
  
  initial begin
    fork
      g.run();
      d.run();
      m.run();
      s.run();
          join
    //wait(done.triggered);
    #100;
    $finish();
      end
  
    
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #100;
    $finish();
  end
endmodule