module CPU (
	input clk,
	input W_RST,
	input W_CLK,
	
	input wire[31:0] W_DAT_I,
	input W_ACK,
	
	output reg[31:0] W_DAT_O,
	output reg[31:0] W_ADDR
);

reg [31:0] temp;

initial
begin
	W_DAT_O = 32'h01234567;
end

always @(posedge clk)
begin
	temp = temp + 1;
end

always @(posedge temp[20])
begin
	W_DAT_O = W_DAT_O + 1;
end

endmodule