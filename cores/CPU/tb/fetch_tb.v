module fetch_tb;

reg clk;
reg f_enable;
reg write_mode;
reg [1:0] thread;
reg [31:0] addr;
reg [31:0] data_i;
wire ack;

wire [31:0] data_o;

reg W_CLK;
wire [31:0] W_ADDR;
wire [31:0] W_DATA_O;
wire W_WRITE;

reg W_ACK;
reg [31:0] W_DATA_I;

FETCH fetch1(clk, f_enable, write_mode, addr, data_i, thread, data_o, ack, W_CLK, W_ACK, W_DATA_I, W_DATA_O, W_ADDR, W_WRITE);


initial
begin:tb

  clk <= 0;
  thread = 0;

  // write registers

  f_enable <= 1;
  write_mode <= 1;
  addr <= 32'hFFFF_FFF0; // r0
  data_i <= 32'h1111_1111;
  
  #10 clk <= 1'b1;

  #10 clk <= 0;

  `ASSERT(ack, 1'b1, "reg write must be in one tick")
  f_enable <= 0;

  #10 clk <= 1;

  #10 clk <= 0;

  `ASSERT(ack, 1'b0, "ack must be reseted to zero")

  f_enable <= 1'b1;
  addr <= 32'hFFFF_FFF1; // r1
  data_i <= 32'h2222_1111;

  #10 clk <= 1'b1;

  #10 clk <= 0;

  `ASSERT(ack, 1'b1, "set another register")
  f_enable <= 1'b0;

  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b0, "ack must be reseted")

  thread <= 2'b01; // switch to another thread

  addr <= 32'hFFFF_FFF0; // r0 thread 2
  data_i <= 32'h1111_22222;

  f_enable <= 1;

  #10 clk <= 1;
  #10 clk <= 0;

  // fast forward
  addr <= 32'hFFFF_FFF1; // r1 thread 2
  data_i <= 32'h2222_2222;

  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b1, "setup second reg in second thread")

  f_enable <= 0;

  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b0, "registers setted all must be clean here")
  
  // ------------ //
  // cheking read //
  // ------------ //

  write_mode <= 0;
  f_enable <= 1;
  thread <= 0;
  addr <= 32'hFFFF_FFF0;

  #10 clk <= 1;
  #10 clk <= 0;
  `ASSERT(ack, 1'b1, "read from register ack in 1 tick")
  `ASSERT(data_o, 32'h1111_1111, "checking read from register")

  // fast forward read

  thread <= 1;
  addr <= 32'hFFFF_FFF1;
  
  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(data_o, 32'h2222_2222, "checking read r1 thread 1")
  f_enable <= 0;

  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b0, "all clearing")

  #10 clk <= 1;
  #10 clk <= 0;

  // -----
  // checking RAM
  //

  W_ACK <= 0; 

  write_mode <= 1;
  addr <= 32'h0000_0001;
  f_enable <= 1;
  data_i <= 32'h0000_0011;

  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(W_ADDR, 32'hxxxx_xxxx, "do not use bus before W_ACK")

  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b0, "fetch must not set ACK before W_ACK")
  
  W_CLK <= 1;
  
  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b0, "fetch still must not set ACK before W_ACK")
  `ASSERT(W_ADDR, 32'h0000_0001, "Set address on W_ACK")
  `ASSERT(W_DATA_O, 32'h0000_0011, "Set data on W_ACK")
  `ASSERT(W_WRITE, 1'b1, "Writing mode")

  #10 clk <= 1;
  W_CLK <= 0;

  #10 clk <= 0;
  W_CLK <= 1;

  #10 W_CLK <= 0;
  `ASSERT(ack, 1'b0, "fetch still must not set ACK before W_ACK")
  W_ACK <= 1'b1;

  #10 W_CLK <= 1;
  #10 W_CLK <= 0;

  W_ACK <= 1'b0;

  #10 clk <= 1;
  #10 clk <= 0;

  #10 W_CLK <= 1;
  #10 W_CLK <= 0;
  
  #10 clk <= 1;
  #10 clk <= 0;

  `ASSERT(ack, 1'b1, "Command done")
  `ASSERT(W_ADDR, 32'hz, "Buss unsetted")

  $finish;
end

endmodule
