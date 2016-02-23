module DIGITS (
	input clk,

	// wishbone
	input W_RST,
	input W_CLK,
	input wire[31:0] W_ADDR,
	input wire[31:0] W_DAT_I,
	
	output reg[31:0] W_DAT_O,
	output wire W_ACK,
	
	output reg[7:0] hex,
	output reg[7:0] dig
);

parameter addr = 32'h0000_0000;

reg ack;
reg [31:0] data;
wire [3:0] char;
reg [31:0] new_data;

assign char = data[3:0];
assign W_ACK = ack;
initial
begin
	data = 32'h01234567;
	dig = ~8'b0000_0001;
end


always @(posedge W_CLK)
begin
	new_data = W_DAT_I;
end

always @(posedge clk)
begin
	if (dig == ~8'b0000_0010)
		data = new_data;
	else
		data = {data[3:0], data[31:4]};
		
	dig = {dig[0], dig[7:1]};
	case (char)
			0: hex<=8'b00000011;
			1: hex<=8'b10011111;
			2: hex<=8'b00100101;
			3: hex<=8'b00001101;
			4: hex<=8'b10011001;
			5: hex<=8'b01001001;  
			6: hex<=8'b01000001; 
			7: hex<=8'b00011111;
			8: hex<=8'b00000001;
			9: hex<=8'b00001001;
			10:hex<=8'b00010001;
			11:hex<=8'b11000001;
			12:hex<=8'b01100011;
			13:hex<=8'b10000101;
			14:hex<=8'b01100001;
			15:hex<=8'b01110001;
	endcase
end

endmodule