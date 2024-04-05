
`ifndef _alu_vh_
`define _alu_vh_

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
//`define ALU_NOT_FUNCTION                     4'b1100
`define ALU_SEXT_BYTE                        4'b1100
`define ALU_SEXT_HALFWORD                    4'b1101
`define ALU_ZEXT_BYTE                        4'b1110
`define ALU_ZEXT_HALFWORD                    4'b1111


`endif

