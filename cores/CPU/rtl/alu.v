module ALU(
   input signed [31:0] x,
   input signed [31:0] y,

   input carry,
   
   output wire [31:0] summ,
   output wire ocarry,

   output wire [31:0] mult_h,
   output wire [31:0] mult_l,

   output wire [31:0] zand, zor, zxor, znot,

   output wire [31:0] sub, ashiftl, ashiftr,

   output wire [31:0] lshiftl, lshiftr
);

assign {ocarry, summ} = x + y + carry;
assign {mult_h, mult_l} = x * y;

assign zand = x & y;
assign zor = x | y;
assign zxor = x ^ y;
assign znot = ~x;

assign sub = x - y + carry;

assign ashiftl = x <<< y;
assign ashiftr = x >>> y;

assign lshiftl = x << y;
assign lshiftr = x >> y;

endmodule
