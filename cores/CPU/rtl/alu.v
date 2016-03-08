module ALU(
   input [31:0] x,
   input [31:0] y,

   input carry,
   
   output wire [31:0] summ,
   output wire ocarry,

   output wire [31:0] mult_h,
   output wire [31:0] mult_l,

   output wire [31:0] zand, zor, zxor, znot
);

assign {ocarry, summ} = x + y + carry;
assign {mult_h, mult_l} = x * y;

assign zand = x & y;
assign zor = x | y;
assign zxor = x ^ y;
assign znot = ~x;

endmodule
