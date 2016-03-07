`define STATE_INIT 2'b00
`define STATE_W_FETCH 2'b01
`define STATE_END 2'b10


module FETCH(
  input clk,
  input f_enable,
  input write_mode,
  input [31:0] addr,
  input [31:0] data_i,
  input [1:0] thread,
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
reg [1:0] state; // 0: 0 -- read input | 1 -- fetch; 1: 00 
reg [1:0] w_state;
reg w_buff;
reg w_ack_local;

wire [4:0] reg_select;

assign reg_select = {thread, addr[2:0]}; 

reg [31:0] registers[32];

initial
begin
 data_o <= 0;
end

always @(posedge clk)
begin
  if (f_enable)
    case (state)
      `STATE_INIT:
        begin
	  if (addr[31:28] == 4'b11)
	  begin
	    if (write_mode)
	      registers[reg_select] <= data_i;
	    else
	      data_o <= registers[reg_select];
	    ack <= 1;
	    state <= `STATE_END;
	  end
	  else
	  begin
            read_from_bus <= 1;
	    state <= `STATE_W_FETCH;
	  end
       end
      `STATE_W_FETCH: // load from WBUS
       begin
         if (w_ack_local)
         begin
          data_o <= w_buff;
	  ack <= 1;
          state <= `STATE_END;
        end
       end
     `STATE_END:
       begin
        ack <= 0;
	state <= `STATE_INIT;
       end
     endcase
end

always @(posedge W_CLK)
begin
  if (read_from_bus)
   case (w_state)
     2'b00:
       begin
	 W_ADDR <= addr;
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
    default:
     w_ack_local <= 0;
   endcase
end

endmodule
