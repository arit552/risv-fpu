//FLOATING POINT SUBTRATION MODULE CODE
   module SUB(clk, A, B, O);
   input clk;
   input [31:0] A, B;
   output [31:0] O;

   wire [31:0] O;
   wire [7:0] a_exponent;
   wire [23:0] a_mantissa;
   wire [7:0] b_exponent;
   wire [23:0] b_mantissa;

   reg        o_sign;
   reg [7:0]  o_exponent;
   reg [24:0] o_mantissa;

   wire a_sign; 
   wire b_sign;
   reg [31:0] sub_a_in;
   reg [31:0] sub_b_in;
   wire [31:0] sub_out; 
   assign O[31] = o_sign;
   assign O[30:23] = o_exponent;
   assign O[22:0] = o_mantissa[22:0];
   
   assign a_sign = A[31];
   assign a_exponent[7:0] = A[30:23];
   assign a_mantissa[23:0] = {1'b1, A[22:0]};
   
   assign b_sign = B[31];
   assign b_exponent[7:0] = B[30:23];
   assign b_mantissa[23:0] = {1'b1, B[22:0]};
   sub subtractor(.a(sub_a_in),.b(sub_b_in),.out(sub_out));
     always @ (posedge clk) begin
     //If a is NaN or b is zero return a
     if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
     o_sign = a_sign;
     o_exponent = a_exponent;
     o_mantissa = a_mantissa;
     //If b is NaN or a is zero return b
     end else if ((b_exponent == 255 && b_mantissa != 0) || (a_exponent == 0) && (a_mantissa == 0)) begin
     o_sign = b_sign;
     o_exponent = b_exponent;
     o_mantissa = b_mantissa;
     //if a or b is infinity return infinity
     end else if ((a_exponent == 255) || (b_exponent == 255)) begin
     o_sign = a_sign ^ b_sign;
     o_exponent = 255;
     o_mantissa = 0;
     end else begin // Passed all corner cases
     sub_a_in = A;
     sub_b_in = {~B[31], B[30:0]};
     o_sign = sub_out[31];
     o_exponent = sub_out[30:23];
     o_mantissa = sub_out[22:0];
     end
     end 
     endmodule
     module sub(a, b, out);
     input  [31:0] a, b;
     output [31:0] out;
     
     wire [31:0] out;
     reg a_sign;
     reg [7:0] a_exponent;
     reg [23:0] a_mantissa;
     reg b_sign;
     reg [7:0] b_exponent;
     reg [23:0] b_mantissa;
     
       reg o_sign;
       reg [7:0] o_exponent;
       reg [24:0] o_mantissa;
     
       reg [7:0] diff;
       reg [23:0] tmp_mantissa;
       reg [7:0] tmp_exponent;
     
     
       reg  [7:0] i_e;
       reg  [24:0] i_m;
       wire [7:0] o_e;
       wire [24:0] o_m;
       sub_normaliser norm1(.in_e(i_e),.in_m(i_m),.out_e(o_e),.out_m(o_m));
       
       assign out[31] = o_sign;
       assign out[30:23] = o_exponent;
       assign out[22:0] = o_mantissa[22:0];
       
       always @ ( * ) begin
       a_sign = a[31];
       if(a[30:23] == 0) begin
       a_exponent = 8'b00000001;
       a_mantissa = {1'b0, a[22:0]};
       end else begin
       a_exponent = a[30:23];
       a_mantissa = {1'b1, a[22:0]};
       end
       b_sign = b[31];
       if(b[30:23] == 0) begin
       b_exponent = 8'b00000001;
       b_mantissa = {1'b0, b[22:0]};
       end else begin
       b_exponent = b[30:23];
       b_mantissa = {1'b1, b[22:0]};
       end
       if (a_exponent == b_exponent) begin // Equal exponents
       o_exponent = a_exponent;
       if (a_sign == b_sign) begin // Equal signs = add
       o_mantissa = a_mantissa + b_mantissa;
       //Signify to shift
        o_mantissa[24] = 1;
        o_sign = a_sign;
        end else begin // Opposite signs = subtract
        if(a_mantissa > b_mantissa) begin
        o_mantissa = a_mantissa - b_mantissa;
        o_sign = a_sign;
        end else begin
        o_mantissa = b_mantissa - a_mantissa;
        o_sign = b_sign;
        end
        end
        end else begin //Unequal exponents
        if (a_exponent > b_exponent) begin // A is bigger
        o_exponent = a_exponent;
        o_sign = a_sign;
        diff = a_exponent - b_exponent;
        tmp_mantissa = b_mantissa >> diff;
        if (a_sign == b_sign)
        o_mantissa = a_mantissa + tmp_mantissa;
        else
        o_mantissa = a_mantissa - tmp_mantissa;
        end else if (a_exponent < b_exponent) begin // B is bigger
        o_exponent = b_exponent;
        o_sign = b_sign;
        diff = b_exponent - a_exponent;
        tmp_mantissa = a_mantissa >> diff;
        if (a_sign == b_sign) begin
        o_mantissa = b_mantissa + tmp_mantissa;
        end else begin
        o_mantissa = b_mantissa - tmp_mantissa;
        end
        end
        end
        if(o_mantissa[24] == 1) begin
        o_exponent = o_exponent + 1;
        o_mantissa = o_mantissa >> 1;
        end else if((o_mantissa[23] != 1) && (o_exponent != 0)) begin
        i_e = o_exponent;
        i_m = o_mantissa;
        o_exponent = o_e;
        o_mantissa = o_m;
        end
        end
        endmodule  