module ALU_tb();

reg [31:0] x, y;
reg carry;

wire ocarry;
wire [31:0] summ;

wire [31:0] mult_h;
wire [31:0] mult_l;

wire [31:0] zand, zor, zxor, znot;

reg fake;

ALU alu1(x, y, carry, summ, ocarry, mult_h, mult_l, zand, zor, zxor, znot);

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


// overflow flag and other flags sets by outher module

`ASSERT(mult_h, 32'hffff_fffe, "Mult hight")
`ASSERT(mult_l, 32'h0000_0001, "Mult low")

x <= 32'b0011_0011_0011_0011_0011_0011_0011_0011;
y <= 32'b1111_0000_1010_0101_1100_1001_0110_1011;

#10 fake <= 1'b1;

`ASSERT(zand, 32'b0011_0000_0010_0001_0000_0001_0010_0011, "AND")
`ASSERT(zor,  32'b1111_0011_1011_0111_1111_1011_0111_1011, "OR")
`ASSERT(zxor, 32'b1100_0011_1001_0110_1111_1010_0101_1000, "XOR")
`ASSERT(znot, 32'b1100_1100_1100_1100_1100_1100_1100_1100, "OR")

end

endmodule
