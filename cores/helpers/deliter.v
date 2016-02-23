module DELITER(clk, sig);
input wire clk;
output wire sig;

parameter freq = 4;

reg [31:0] sum;

assign sig = sum[freq];

always @ (posedge clk) 
begin
	sum = sum + 1;
end
endmodule