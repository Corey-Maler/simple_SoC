module GPU_core(
	input clk,
	
	// ~ wishbone. Somethink like wishbone
	input wire [31:0] W_ADDR,
	input wire [31:0] W_DAT_I,
	input wire W_CLK,
	input wire W_RST,
	
	output reg [31:0] W_DAT_O,
	output reg W_ACK,
	
	// monitor connection
	
	input [9:0] x,
	input [8:0] y,
	
	output R,
	output G,
	output B,
	
	output reg [9:0] res_x,
	output reg [8:0] res_y
);


reg [3:0] cbyte;
reg [15:0] cc_code;
reg [15:0] ccolor;
wire [15:0] char_code;

assign R = ccolor;
assign G = ccolor;
assign B = ccolor;

reg ss;

wire [7:0] sline;

initial
begin
	res_x <= 799;
	res_y <= 479;
end

//			  clk, 	data_a, 	data_b,  	addr_a,					addr_b,				we_a, 	we_b, 	q_a,       	q_b (not used)
V_RAM vram(clk, 	16'b0,  	cc_code, 	{4'd240 - y[7:4], x[8:3]}, 	16'h0, 	1'b0, 	1'b0,  	char_code);

CHARSET charset(clk, {char_code[7:0], 4'd240 - y[3:0]}, sline);

always @(posedge clk)
	ccolor <= sline[3'b111 - x[2:0] - 1] ? 16'h0000 : 16'hFFFF;

endmodule