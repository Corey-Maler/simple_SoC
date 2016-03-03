module fetch_tb;

reg clk;

reg f_enable;
reg write_mode;
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

FETCH fetch1(clk, f_enable, write_mode, addr, data_i, data_o, ack, W_CLK, W_ACK, W_DATA_I, W_DATA_O, W_ADDR, W_WRITE);


initial
begin
  $display("CPU | Fetch		testbench");

  clk <= 0;
  #10 clk <= 1;
  #10 clk <= 0;
  if (data_o != 32'd24)
  begin
    $display("ERROR!");
    $finish;
  end
  #10 clk <= 1;
  #10 clk <= 0;



  $finish;
end

endmodule
