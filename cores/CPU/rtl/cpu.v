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
	
	input wire[31:0] W_DAT_I,
	input W_ACK,
	
	output reg[31:0] W_DAT_O,
	output reg[31:0] W_ADDR
);

reg [4:0] state;

reg [31:0] CP;

reg skip;

reg f_op1, f_op2, f_op3, f_store;

reg f_ack;

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
      end

    `LOAD_INST_2:  
      if (f_ack)
        begin
          state <= `DEC_INST;
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
        state <= `FETCH_OP1_2;
      end

    `FETCH_OP1_2:
      if (f_ack)
      begin
        if (f_op2)
          state <= `FETCH_OP2_1;
        else
          state <= `LOAD_OP2_1;
      end

    `FETCH_OP2_1:
      begin
        state <= `FETCH_OP2_2;
      end

    `FETCH_OP2_2:
      if (f_ack)
        begin
          if (f_op3)
            state <= `FETCH_OP3_1;
          else
            state <= `LOAD_OP2_1;
        end

    `FETCH_OP3_1:
      begin
        state <= `FETCH_OP3_2;
      end

    `FETCH_OP3_2:
      if (f_ack)
        begin
          state <= `LOAD_OP2_1;
        end

    `LOAD_OP2_1:
      begin
        state <= `LOAD_OP2_2;
      end

    `LOAD_OP2_2:
      if (f_ack)
        begin
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
        state <= `STORE_2;
      end

    `STORE_2:
      if (f_ack)
      begin
       state <= `NEXT;
      end

    `NEXT:
      begin
        state <= `INIT;
      end

  endcase
end

endmodule
