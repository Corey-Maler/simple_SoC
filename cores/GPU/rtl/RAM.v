module V_RAM(
	input clk,
	input [15:0] data_a, data_b,
	input [11:0] addr_a, addr_b,
	input	we_a, we_b,
	output reg [15:0] q_a, q_b
);

reg [15:0] RAM [128 * 32];

initial
begin
	RAM[0] = 16'h00_57; // W
	RAM[1] = 16'h00_61; // a
 	RAM[2] = 16'h00_6B; // k
	RAM[3] = 16'h00_65; // e
 	RAM[4] = 16'h00_20; // <space>
	RAM[5] = 16'h00_75; // u
	RAM[6] = 16'h00_70; // p
	RAM[7] = 16'h00_2C; // ,
	RAM[8] = 16'h00_20; // <space>
	RAM[9] = 16'h00_4E; // N
	RAM[10] = 16'h00_65; // e
	RAM[11] = 16'h00_6F; // o
	RAM[12] = 16'h02_5F; // _ [blink]
end

	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			RAM[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= RAM[addr_a];
		end
	end
	
	// Port B
	always @ (posedge clk)
	begin
		if (we_b)
		begin
			RAM[addr_b] <= data_b;
			q_b <= data_b;
		end
		else
		begin
			q_b <= RAM[addr_b];
		end
	end
endmodule