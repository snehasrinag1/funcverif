`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2025 04:11:04 PM
// Design Name: 
// Module Name: sim_tb
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


module sim_tb;
  
  
  bit [5:0] addr;
  bit  wr,en;
  
  bit clk = 0;
  
  always #20 clk = ~clk;  ///40 ns --> 25 Mhz
   
  task stim_clk ();
    @(posedge clk);    // wait
    addr =$urandom();
    wr = $urandom();
    en = $urandom();
     endtask
  
  
  
  initial begin
    #500;
    $finish();
  end
  
  
  
  initial begin
     for(int i = 0; i< 11 ; i++) 
       begin
      stim_clk();
       $display("Values of addr,wr,en:%0d,%0d,%0d",addr,wr,en);
    end
  end
  
    
endmodule
