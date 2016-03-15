`define INIT        5'd0
`define LOAD_INST_1 5'd1
`define LOAD_INST_2 5'd2
`define DEC_INST    5'd3
`define FETCH_OP1_1 5'd4
`define FETCH_OP1_2 5'd5
`define FETCH_OP2_1 5'd6
`define FETCH_OP2_2 5'd7
`define FETCH_OP3_1 5'd8
`define FETCH_OP3_2 5'd9
// never load Z
`define LOAD_OP2_1  5'd10
`define LOAD_OP2_2  5'd11
`define LOAD_OP3_1  5'd12
`define LOAD_OP3_2  5'd13
`define COMPUTE     5'd14
`define STORE_1     5'd15
`define STORE_2     5'd16
`define NEXT        5'd17


module CPU (
	input clk,
	input W_RST,
	input W_CLK,
	
	input wire[31:0] W_DATA_I,
	input W_ACK,
	
	output reg[31:0] W_DATA_O,
	output reg[31:0] W_ADDR,
	output W_WRITE
);

reg [4:0] state;

reg [31:0] CP;
reg [31:0] command;
reg [31:0] op1, op2, st_op;

reg [31:0] reg_a, reg_b, reg_c;

reg skip;

reg f_op1, f_op2, f_op3, f_store;

reg f_enable;
reg f_write_mode;
reg f_ack;


reg [31:0] f_data_o;

reg thread;

reg [31:0] addr;
// wire f_ack;

FETCH fetch_module(
	clk, 
	f_enable, 
	f_write_mode,
	addr,
	f_data_i,
	thread,
	f_data_o,
	f_ack,

	W_CLK,
	W_ACK,
	W_DATA_I,
	W_DATA_O,
	W_ADDR,
	W_WRITE);

initial
begin
  thread <= 2'b0;
end


always @(posedge clk)
begin
  case (state)
    `INIT:
      begin
        // check interrupts
        state <= `LOAD_INST_1;  
      end

    `LOAD_INST_1:
      begin
        state <= `LOAD_INST_2;
	
	//
	addr <= PC;
	f_enable <= 1'b1;
	f_write_mode <= 1'b0;
      end

    `LOAD_INST_2:  
      if (f_ack)
        begin
          state <= `DEC_INST;
	  f_enable <= 1'b0;
	  command <= f_data_o;
        end

    `DEC_INST:
      begin
        if (skip)
        begin
          CP <= CP + 32'd4;
          state <= `INIT;
        end
        else
        if (f_op1)
          state <= `FETCH_OP1_1;
        else
          state <= `COMPUTE;
      end

    `FETCH_OP1_1:
      begin
        f_enable <= 1'b1;
	addr <= CP + 32'h1;

        state <= `FETCH_OP1_2;
      end

    `FETCH_OP1_2:
      if (f_ack)
      begin
        f_enable <= 1'b0;
	st_op <= f_data_o;


        if (f_op2)
          state <= `FETCH_OP2_1;
        else
          state <= `LOAD_OP2_1;
      end

    `FETCH_OP2_1:
      begin
        f_enable <= 1'b1;
	addr <= CP + 32'h2;
        state <= `FETCH_OP2_2;
      end

    `FETCH_OP2_2:
      if (f_ack)
        begin
	  f_enable <= 1'b0;
	  op1 <= f_data_o;

          if (f_op3)
            state <= `FETCH_OP3_1;
          else
            state <= `LOAD_OP2_1;
        end

    `FETCH_OP3_1:
      begin
        f_enable <= 1'b1;
	addr <= CP + 32'h3;
        state <= `FETCH_OP3_2;
      end

    `FETCH_OP3_2:
      if (f_ack)
        begin
	  f_enable <= 1'b0;
	  op2 <= f_data_o;
          state <= `LOAD_OP2_1;
        end

    `LOAD_OP2_1:
      begin
        addr <= op1;
	f_enable <= 1'b1;
        state <= `LOAD_OP2_2;
      end

    `LOAD_OP2_2:
      if (f_ack)
        begin
	  f_enable <= 1'b1;
	  reg_a <= f_data_o;

          if (f_op3)
       	    state <= `LOAD_OP3_1;
          else
           state <= `COMPUTE;
        end

    `LOAD_OP3_1:
      begin
        state <= `LOAD_OP3_2;
      end

    `LOAD_OP3_2:
      if (f_ack)
      begin
        f_enable <= 1'b0;
	reg_b <= f_data_o;
        state <= `COMPUTE;  
      end

    `COMPUTE:
      begin
        if (f_store)
          state <= `STORE_1;
        else
          state <= `NEXT;
      end

    `STORE_1:
      begin
        f_enable <= 1'b1;
        f_write_enable <= 1'b1;
	f_data_i <= reg_c;

        state <= `STORE_2;
      end

    `STORE_2:
      if (f_ack)
      begin
        f_enable <= 1'b0;
        f_write_enable <= 1'b0;

        state <= `NEXT;
      end

    `NEXT:
      begin
        state <= `INIT;
      end

  endcase
end

endmodule
