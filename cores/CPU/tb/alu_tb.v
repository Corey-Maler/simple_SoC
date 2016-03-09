module ALU_tb();

reg [31:0] x, y;
reg carry;

wire ocarry;
wire [31:0] summ;

wire [31:0] mult_h;
wire [31:0] mult_l;

wire [31:0] zand, zor, zxor, znot;

wire [31:0] sub, ashiftl, ashiftr;

wire [31:0] lshiftl, lshiftr;

reg fake;

ALU alu1(x, y, carry, summ, ocarry, mult_h, mult_l, zand, zor, zxor, znot, sub, ashiftl, ashiftr, lshiftl, lshiftr);

initial
begin

x <= 32'd2;
y <= 32'd6;
carry <= 0;

#10 fake <= 1'b1;

`ASSERT(summ, 32'd8, "Check summ")
`ASSERT(mult_h, 32'h0000_0000, "Mult hight")
`ASSERT(mult_l, 32'd12, "Mult low")

carry <= 1;

#10 fake <= 1'b1;

`ASSERT(summ, 32'd9, "Check summ with carry")
`ASSERT(ocarry, 1'b0, "Check zero carry")
`ASSERT(mult_h, 32'h0000_0000, "Mult hight (ignore carry)")
`ASSERT(mult_l, 32'd12, "Mult low (ignore carry)")

carry <= 0;
x <= 32'hffff_ffff;
y <= 32'hffff_ffff;

#10 fake <= 1'b1;

`ASSERT(ocarry, 1'b1, "Carry must be high")


x <= 32'h7fff_ffff; // unsigned mult
y <= 32'h7fff_ffff;
// overflow flag and other flags sets by outher module

#10 fake <= 1'b1;

`ASSERT(mult_h, 32'h3fff_ffff, "Mult hight")
`ASSERT(mult_l, 32'h0000_0001, "Mult low")

x <= 32'b0011_0011_0011_0011_0011_0011_0011_0011;
y <= 32'b1111_0000_1010_0101_1100_1001_0110_1011;

#10 fake <= 1'b1;

`ASSERT(zand, 32'b0011_0000_0010_0001_0000_0001_0010_0011, "AND")
`ASSERT(zor,  32'b1111_0011_1011_0111_1111_1011_0111_1011, "OR")
`ASSERT(zxor, 32'b1100_0011_1001_0110_1111_1010_0101_1000, "XOR")
`ASSERT(znot, 32'b1100_1100_1100_1100_1100_1100_1100_1100, "OR")

x <= 10;
y <= -20;

#10 fake <= 1'b1;

`ASSERT(summ, -32'd10, "Check substruction")
`ASSERT(sub, 32'd30, "Check SUB")

x <= 32'sb1000_0000_0000_0000_0000_0011_0000_0001;
y <= 32'h0000_0002;

#10 fake <= 1'b1;

`ASSERT(ashiftl, 32'b0000_0000_0000_0000_0000_1100_0000_0100, "Shift left")
`ASSERT(ashiftr, 32'b1110_0000_0000_0000_0000_0000_1100_0000, "Shift left")
`ASSERT(lshiftl, 32'b0000_0000_0000_0000_0000_1100_0000_0100, "Shift left")
`ASSERT(lshiftr, 32'b0010_0000_0000_0000_0000_0000_1100_0000, "Shift left")

end

endmodule
