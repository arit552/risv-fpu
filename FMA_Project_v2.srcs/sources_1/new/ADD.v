// FPU ADDITION MODULE
module ADD(Clock, A, B, O);
input Clock; // CLOCK
input [31:0] A, B; //32 BIT INPUT A AND B
output [31:0] O; // 32 BIT OUTPUT

wire [31:0] O; // output declare as a wire
wire [7:0] A_exponent; // 8 bit exponent of A
wire [23:0] A_mantissa;//24 bit mantissaof A
wire [7:0] B_exponent; //8 bit exponent of B
wire [23:0] B_mantissa; //24 bit mantissa of B
reg  O_sign; // 1 bit sign of output
reg [7:0]  O_exponent; //8 bit exponent of output
reg [24:0] O_mantissa; //25 bit mantissa of output

wire A_sign;
wire B_sign;

reg [31:0] IN_A;
reg [31:0] IN_B;
wire [31:0] OUT_O;

assign O[31] = O_sign;
assign O[30:23] = O_exponent;
//assign O[22:0] = o_mantissa;
assign O[22:0] = O_mantissa[22:0];
assign A_sign = A[31];
assign A_exponent[7:0] = A[30:23];
assign A_mantissa[23:0] = {1'b1, A[22:0]}; // 1 hidden bit
assign B_sign = B[31];
assign B_exponent[7:0] = B[30:23];
assign B_mantissa[23:0] = {1'b1, B[22:0]};// 1 hidden bit

//INSTANTIATION	OF ADDER BLOCK
adder ADDITION1(IN_A,IN_B,OUT_O);

 always @ (posedge Clock) begin
// checking with the different different condition 
//If a is NaN or b is zero then return a
if ((A_exponent == 255 && A_mantissa != 0) || (B_exponent == 0) && (B_mantissa == 0)) begin
// make output as A
				O_sign = A_sign;
				O_exponent = A_exponent;
				O_mantissa = A_mantissa;
				
//If b is NaN or a is zero  then return b
end else if ((B_exponent == 255 && B_mantissa != 0) || (A_exponent == 0) && (A_mantissa == 0)) begin
//MAKE OUTPUT AS B
			    O_sign = B_sign;
				O_exponent = B_exponent;
				O_mantissa = B_mantissa;
				
//if a or b is infinity then return infinity(exponent=255)
end else if ((A_exponent == 255) || (B_exponent == 255)) begin
				O_sign = A_sign ^ B_sign;
				O_exponent = 255;
				O_mantissa = 0; //output will be zero 
				
end else begin 
				IN_A = A;
				IN_B = B;
				O_sign = OUT_O[31];
				O_exponent = OUT_O[30:23];
				O_mantissa = OUT_O[22:0];
end
end
endmodule


// adder module to perform addition operation
module adder(a, b, out);
  input  [31:0] a, b;// 32 bit of inputs A and B
  output [31:0] out;// 32 bit of output

// declare the internal connection
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

//INSTATIATION OF NORMLISER BLOCK  of addition
addition_normaliser norm1(.in_e(i_e),.in_m(i_m),.out_e(o_e),.out_m(o_m));

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
      o_mantissa = (o_mantissa >> 1);
    end else if((o_mantissa[23] != 1) && (o_exponent != 0)) begin
      i_e = o_exponent;
      i_m = o_mantissa;
      o_exponent = o_e;
      o_mantissa = o_m;
    end
    end
endmodule

