// FPU MULTIPLICATION MODULE
    module MUL(clk, A, B, O);
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
	
	reg [31:0] multiplier_a_in;
    reg [31:0] multiplier_b_in;
    wire [31:0] multiplier_out;
    assign O[31] = o_sign;
    assign O[30:23] = o_exponent;
    assign O[22:0] = o_mantissa[22:0];
    
    assign a_sign = A[31];
    assign a_exponent[7:0] = A[30:23];
    assign a_mantissa[23:0] = {1'b1, A[22:0]};
    
    assign b_sign = B[31];
    assign b_exponent[7:0] = B[30:23];
    assign b_mantissa[23:0] = {1'b1, B[22:0]};      
        
    multiplier multiplication(.a(multiplier_a_in),.b(multiplier_b_in),.out(multiplier_out));
    always @ (posedge clk) begin
    //If a is NaN return NaN
     if (a_exponent == 255 && a_mantissa != 0) begin
	 o_sign = a_sign;
	 o_exponent = 255;
	 o_mantissa = a_mantissa;
	 //If b is NaN return NaN
	 end else if (b_exponent == 255 && b_mantissa != 0) begin
	 o_sign = b_sign;
	 o_exponent = 255;
	 o_mantissa = b_mantissa;
	 //If a or b is 0 return 0
	end else if ((a_exponent == 0) && (a_mantissa == 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
	o_sign = a_sign ^ b_sign;
	o_exponent = 0;
	o_mantissa = 0;
	//if a or b is inf return inf
	end else if ((a_exponent == 255) || (b_exponent == 255)) begin
	o_sign = a_sign;
	o_exponent = 255;
	o_mantissa = 0;
	end else begin // Passed all corner cases
	multiplier_a_in = A;
	multiplier_b_in = B;
	o_sign = multiplier_out[31];
	o_exponent = multiplier_out[30:23];
	o_mantissa = multiplier_out[22:0];
	end
	end
    endmodule
    module multiplier(a, b, out);
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
    reg [47:0] product;
    
      assign out[31] = o_sign;
      assign out[30:23] = o_exponent;
      assign out[22:0] = o_mantissa[22:0];
    
      reg  [7:0] i_e;
      reg  [47:0] i_m;
      wire [7:0] o_e;
      wire [47:0] o_m;
    
      multiplication_normaliser norm1( .in_e(i_e), .in_m(i_m),.out_e(o_e),.out_m(o_m));
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
        o_sign = a_sign ^ b_sign;
        o_exponent = a_exponent + b_exponent - 127;
        product = a_mantissa * b_mantissa;
        ///////////// Normalization//////////////////////
        if(product[47] == 1) begin
        o_exponent = o_exponent + 1;
        product = product >> 1;
        end else if((product[46] != 1) && (o_exponent != 0)) begin
        i_e = o_exponent;
        i_m = product;
        o_exponent = o_e;
        product = o_m;
        end
        o_mantissa = product[46:23];
        end
        endmodule
        