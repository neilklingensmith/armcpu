
`include "alu.vh"
/*
*   control:
*    000  add, signed
*    001  subtract, signed
*    010  add, unsigned
*    011  subtract, unsigned
* --------------------------------------------
*    100  AND
*    101  OR
*    110  XOR
*    111  NOR
*/  
module alu(a,b,control,c,zero,neg,ovfl,ce,test);
parameter BITS = 3;
input [BITS-1:0] a, b;
input [3:0] control;
output [BITS-1:0] c;
output [BITS:0] ce;
output zero, neg, ovfl, test;

wire [BITS:0] ae,be;
assign ae = {a[BITS-1],a};
assign be = {b[BITS-1],b};
assign ce = (subtract?ae-be:ae+be);
assign test = ce != {sum[BITS-1],sum};

wire subtract;
assign subtract = control[0];

// add-subtract unit
wire [BITS-1:0] sum;
wire [BITS-1:0] bn;
wire cin, cout;
assign cin = subtract;
assign bn = (subtract? ~b: b);
assign {cout, sum} = a+bn+cin;

// logic unit
reg [BITS-1:0] out;
always
    case (control[1:0])
    2'b00: out = a&b;
    2'b01: out = a|b;
    2'b10: out = a^b;
    2'b11: out = ~(a|b);
    endcase

`define ALU_ADD_SIGNED_FUNCTION              4'b0000
`define ALU_ADD_UNSIGNED_FUNCTION            4'b0001
`define ALU_SUB_SIGNED_FUNCTION              4'b0010
`define ALU_SUB_UNSIGNED_FUNCTION            4'b0011
`define ALU_AND_FUNCTION                     4'b0100
`define ALU_OR_FUNCTION                      4'b0101
`define ALU_XOR_FUNCTION                     4'b0110
`define ALU_NOR_FUNCTION                     4'b0111
`define ALU_RIGHT_SHIFT_LOGICAL_FUNCTION     4'b1000
`define ALU_RIGHT_SHIFT_ARITHMETIC_FUNCTION  4'b1001
`define ALU_LEFT_SHIFT_FUNCTION              4'b1010
`define ALU_BYTE_REVERSE                     4'b1011
`define ALU_NOT_FUNCTION                     4'b1100


wire zero, sgn, unsgn;
assign zero = ~(|sum);
assign sgn  = (sum[BITS-1]? (~a[BITS-1])&(~bn[BITS-1]): a[BITS-1]&bn[BITS-1] );
assign unsgn = cout^subtract;
assign ovfl = (control[1]? unsgn: sgn);
assign neg = (control[1]? unsgn: sum[BITS-1]);

assign c = ((control[2] | control[3]) ? out: sum);

endmodule
