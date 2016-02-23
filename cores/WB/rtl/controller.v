module WB_CONTROLLER(
	input clk,
	input rst,
	
	output wire W_CLK,
	output wire W_RST
);

reg [3:0] t;

assign W_RST = rst;
assign W_CLK = t[3];

always @(posedge clk)
	t = t + 1;
	
	

endmodule
