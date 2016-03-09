`define INIT      4'b0
`define LOAD_INST 4'h1
`define DEC_INST  4'h2
`define FETCH_OP1 4'h3
`define FETCH_OP2 4'h4
`define FETCH_OP3 4'h5
// never load Z
`define LOAD_OP2  4'h6
`define LOAD_OP3  4'h7
`define COMPUTE   4'h8
`define STORE     4'h9
`define NEXT      4'ha


module CPU (
	input clk,
	input W_RST,
	input W_CLK,
	
	input wire[31:0] W_DAT_I,
	input W_ACK,
	
	output reg[31:0] W_DAT_O,
	output reg[31:0] W_ADDR
);

reg [3:0] state;

reg [31:0] CP;

reg skip;

reg f_op1, f_op2, f_op3;

always @(posedge clk)
begin
 case (state)
   `INIT:
     // check interrupts
     state <= `LOAD_INST;  
   `LOAD_INST:
     begin


       state <= `DEC_INST;
     end
   `DEC_INST:
     begin
       if (skip):
       begin
         CP <= CP + 32'd4;
         state <= `LOAD_INST;
       end
       else:
       if (f_op1):
         state <= `FETCH_OP1;
       else:
         state <= `COMPUTE;
     end
   `FETCH_OP1:
     begin
       // if FETCH_ACK
       if (f_op2):
         state <= `FETCH_OP2;
       else:
         state <= `LOAD_OP1;

     end
   `FETCH_OP2:
     begin

       if (f_op3):
         state <= `FETCH_OP3;
       else:
         state <= `LOAD_OP1;

     end
   `FETCH_OP3:
     begin


       state <= `LOAD_OP1;
     end
   `LOAD_OP2:
     begin
       if (f_op2):
       	 state <= `LOAD_OP2;
       else:
         state <= `LOAD_COMPUTE;
     end
   `LOAD_OP3:
     begin

       state <= `COMPUE;  
     end
   `COMPUTE:
     begin


       if (f_store):
         state <= `STORE;
       else
         state <= `NEXT;
     end
   `STORE:
     begin
     
       state <= `NEXT;
     end
   `NEXT:
     begin
       
       state <= `INOT;
     end

  endcase
end

endmodule
