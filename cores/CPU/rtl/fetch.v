module FETCH(
  input clk,
  input f_enable,
  input write_mode,
  input [31:0] addr,
  input [31:0] data_i,
  output reg [31:0] data_o,
  output reg ack,

  input W_CLK,
  input W_ACK,
  input [31:0] W_DATA_I,
  output reg [31:0] W_DATA_O,
  output reg [31:0] W_ADDR,
  output reg W_WRITE
);

reg read_from_bus;
reg state; // 0: 0 -- read input | 1 -- fetch; 1: 00 
reg [1:0] w_state;
reg w_buff;
reg w_ack_local;

initial
begin
 data_o <= 0;
end

always @(posedge clk)
begin

  if (f_enable)
  if (state[0] == 0)
  begin
    data_o <= 32'd234;
    read_from_bus <= 1;

    state <= 1;
  end
  else
  begin
   if (w_ack_local)
   begin
     data_o <= w_buff;
     state <= 0;
   end
  end
end

always @(posedge W_CLK)
begin
  case (w_state)
    2'b00:
      begin
        w_ack_local <= 0;
	w_state <= 2'b01;
      end
    2'b01:
     if (W_ACK) // wait W_BUS ack
       begin
         w_buff <= W_DATA_I;
         w_ack_local <= 1;
	 w_state <= 2'b10;
       end
    2'b10:
     begin
       w_ack_local <= 0;
       w_state <= 2'b00;
     end
end

endmodule
