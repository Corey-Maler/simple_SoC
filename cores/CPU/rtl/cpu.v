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

reg f_enable;
reg write_mode;

reg W_WRITE;

reg [31:0] addr;
reg [31:0] data_i;
wire [31:0] data_o;

reg [1:0] thread;

wire ack;

FETCH fetch1 (clk, f_enable, write_mode,  addr, data_i, thread, data_o, ack, W_CLK,  W_ACK, W_DAT_I, W_DAT_O, W_ADDR, W_WRITE);

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