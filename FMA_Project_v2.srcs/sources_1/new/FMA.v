// FMA Block
module FMA(clk, A, B, C, Z);
     input clk; 
     input [31:0] A, B, C; 
     wire [31:0] OP;
     output [31:0] Z; 
     
        
    MUL M1(clk, A, B, OP);
   
    ADD A1(clk, OP, C, Z);
    
endmodule