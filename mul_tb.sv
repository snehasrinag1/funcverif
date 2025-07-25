`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2025 03:36:51 PM
// Design Name: 
// Module Name: mul_tb
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



module mul_tb;
 int unsigned data1=7;
 int unsigned data2=5;
  int unsigned data3=0;
  int unsigned res=0;  
  int unsigned res1=0;
 
  
  function int unsigned mul(int unsigned a,b);
    return a*b;
  endfunction
  
  function void display_res(int res);
    begin
      data3=data1*data2;
      if(res==data3)
        $display("Test Passed");
      else 
        $display("Test Failed");
    end
    endfunction
      
      
                                
    initial
    begin
      res1= mul(data1,data2);
      display_res(res1);
  end
 endmodule



