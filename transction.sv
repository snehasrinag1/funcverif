`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Snehasri Roberts
// 
// Create Date: 07/26/2025 02:51:36 PM
// Design Name: tb
// Module Name: transction
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Generates data(in transaction class) and moves it from generator to driver with the help of a mailbox
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


class transaction;

  rand bit[3:0]din1,din2;
  bit [4:0]dout;
 endclass


class generator;
  
  transaction t;
  mailbox g2d;
  
  function new(mailbox g2d);
    this.g2d=g2d;
  endfunction
  
  task main();
    
    for(int i=0;i<10;i++)
      begin
        t=new();
        assert(t.randomize()) else $display("Randomization failed");
        $display("[GEN]: Data sent: din1:%0d din2:%0d",t.din1,t.din2);
        g2d.put(t);
        #10;
      end
        endtask
        endclass

 class driver;
   
   transaction dc;// data container for receiving data from generator and storing it
   mailbox g2d;
   
   function new(mailbox g2d);
     this.g2d=g2d;
   endfunction
   
   task main();
     forever begin
       g2d.get(dc);
       $display("[DRV] Data received din1:%0d, din2:%0d",dc.din1,dc.din2);
       #10;
     end
   endtask
 endclass


module tb;
  generator g;
  driver d;
  mailbox g2d;
  
  initial begin
    g2d=new();
    g=new(g2d);
    d=new(g2d);
 
  
  fork
    g.main();  // we need to hold simulation until all proccesses finish
    d.main();
  join
  end
endmodule
