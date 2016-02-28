module flipV(
	input clk,
	input [9:0] res_x,
	input [8:0] res_y,
	input [9:0] ix,
	input [8:0] iy,
	
	input enableV,
	input enableH,
	output reg [9:0] ox,
	output reg [8:0] oy
);

always @(posedge clk)
begin
	if (enableV)
		oy <= res_y - iy;
	else
		oy <= iy;
		
	if (enableH)
		ox <= res_x - ix;
	else
		ox <= ix;
end

endmodule