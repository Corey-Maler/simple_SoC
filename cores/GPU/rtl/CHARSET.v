module CHARSET(clk, addr, q);
input clk;
input [11:0] addr;
output reg [7:0] q;

reg [7:0] chart[4096];

initial $readmemh("charset.hex", chart);

/*
initial
begin
	chart[0] = 128'b0;

	chart[1] = 128'b00000000_00000000_00000000_00000000_00000000_00000000_01111100_10000010_10101010_10000010_10000010_10111010_10010010_10000010_10000010_01111110;
	
	chart[2] = 128'b0;

	chart[3] = 128'b0;
end
*/

always @(posedge clk)
begin
	q <= chart[addr];
end

endmodule