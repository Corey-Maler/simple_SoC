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
reg ccolor;
wire [15:0] char_code;

wire [9:0] rx;
wire [8:0] ry;

reg flipVenable;
reg flipHenable;

// temporary
assign R = ccolor;
assign G = ccolor;
assign B = ccolor;

reg ss;

wire [7:0] sline;

initial
begin
	res_x <= 799;
	res_y <= 479;
	flipVenable <= 1'b1;
	flipHenable <= 1'b0;
end

flipV Flip(clk, res_x, res_y, x, y, flipVenable, flipHenable, rx, ry);

//			  clk, 	data_a, 	data_b,  	addr_a,					addr_b,				we_a, 	we_b, 	q_a,       	q_b (not used)
V_RAM vram(clk, 	16'b0,  	cc_code, 	{ry[7:4], rx[8:3]}, 	16'h0, 	1'b0, 	1'b0,  	char_code);

CHARSET charset(clk, {char_code[7:0], ry[3:0]}, sline);

always @(posedge clk)
	ccolor <= sline[3'b111 - rx[2:0] + 3'b001] ? 1'b0 : 1'b1;

endmodule