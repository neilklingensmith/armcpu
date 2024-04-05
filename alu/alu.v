

`include "alu.vh"

module alu (a, b, func, c_in, out, neg, zero, ovfl, c_out);
  input [31:0] a;
  input [31:0] b;
  input [3:0] func;
  input c_in;
  output reg c_out;
  output reg [31:0] out;
  output zero, neg, ovfl;
  wire [31:0] sum;
  wire [31:0] bn;
  wire unsigned_op, subtract, add_cout, sgn, unsgn;


  always @ (*)
  case(func)
    `ALU_ADD_SIGNED_FUNCTION,
    `ALU_ADD_UNSIGNED_FUNCTION,
    `ALU_SUB_SIGNED_FUNCTION,
    `ALU_SUB_UNSIGNED_FUNCTION: begin
      out = sum;
      c_out = add_cout;
    end
    `ALU_AND_FUNCTION: begin
      c_out = 0;
      out = a & b;
    end
    `ALU_OR_FUNCTION: begin
      c_out = 0;
      out = a | b;
    end
/*
    `ALU_NOT_FUNCTION: begin
      c_out = 0;
      out = ~a;
    end
*/
    `ALU_XOR_FUNCTION: begin
      c_out = 0;
      out = a ^ b;
    end
    `ALU_LEFT_SHIFT_FUNCTION: begin
      {c_out,out} = a << b;
    end
    `ALU_RIGHT_SHIFT_LOGICAL_FUNCTION: begin
      out = a >> b;
    end
    `ALU_RIGHT_SHIFT_ARITHMETIC_FUNCTION: begin
      out = a >>> b;
    end
    `ALU_BYTE_REVERSE: begin
      out = {a[7:0],a[15:8],a[23:16],a[31:24]};
    end
    `ALU_SEXT_BYTE: begin
      out = {{25{a[7]}}, a[6:0]};
    end
    `ALU_SEXT_HALFWORD: begin
      out = {{17{a[15]}}, a[14:0]};
    end
    `ALU_ZEXT_BYTE: begin
      out = {24'b0, a[7:0]};
    end
    `ALU_ZEXT_HALFWORD: begin
      out = {16'b0, a[15:0]};
    end
    default: begin
      c_out = 0; out = a;
    end
  endcase

  assign subtract = (func == `ALU_SUB_SIGNED_FUNCTION) || (func == `ALU_SUB_UNSIGNED_FUNCTION);
  assign unsigned_op = (func == `ALU_SUB_UNSIGNED_FUNCTION) || (func == `ALU_ADD_UNSIGNED_FUNCTION);
//  assign cin = subtract;
  assign bn = (subtract? ~b: b);
  assign {add_cout, sum} = a+bn+(subtract | c_in);
  assign zero = ~(|sum);
  assign sgn  = (sum[31]? (~a[31])&(~bn[31]): a[31]&bn[31] );
  assign unsgn = add_cout^subtract;
  assign ovfl = (unsigned_op ? unsgn : sgn);
  assign neg = (unsigned_op ? unsgn : sum[31]);


endmodule

