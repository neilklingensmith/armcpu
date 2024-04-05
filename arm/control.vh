

`ifndef _control_vh_
`define _control_vh_


`define INST_ENCODING_SHIFT_IMMEDIATE_MOV       32'bxxxxxxxxxxxxxxxx000xxxxxxxxxxxxx
`define INST_ENCODING_LOAD_FROM_LITERAL_POOL    32'bxxxxxxxxxxxxxxxx01001xxxxxxxxxxx
`define INST_ENCODING_SPECIAL_DATA_PROCESSING   32'bxxxxxxxxxxxxxxxx010001xxxxxxxxxx
`define INST_ENCODING_BRANCH_EXCHANGE           32'bxxxxxxxxxxxxxxxx01000111xxxxxxxx
`define INST_ENCODING_DATA_PROCESSING_REGISTER  32'bxxxxxxxxxxxxxxxx010000xxxxxxxxxx
`define INST_ENCODING_ADD_SUB_REGISTER          32'bxxxxxxxxxxxxxxxx000110xxxxxxxxxx
`define INST_ENCODING_ADD_SUB_IMMEDIATE         32'bxxxxxxxxxxxxxxxx000111xxxxxxxxxx
`define INST_ENCODING_ADD_SUB_CMP_MOV_IMMEDIATE 32'bxxxxxxxxxxxxxxxx001xxxxxxxxxxxxx
`define INST_ENCODING_ADD_TO_PC_OR_SP           32'bxxxxxxxxxxxxxxxx1010xxxxxxxxxxxx
`define INST_ENCODING_LD_ST_STACK               32'bxxxxxxxxxxxxxxxx1001xxxxxxxxxxxx
`define INST_ENCODING_ADJUST_SP                 32'bxxxxxxxxxxxxxxxx10110000xxxxxxxx
`define INST_ENCODING_BYTE_REVERSE              32'bxxxxxxxxxxxxxxxx10111010xxxxxxxx
`define INST_ENCODING_SIGN_ZERO_EXTEND          32'bxxxxxxxxxxxxxxxx10110010xxxxxxxx
`define INST_ENCODING_LD_ST_WORD_BYTE_IMM_OFF   32'bxxxxxxxxxxxxxxxx011xxxxxxxxxxxxx
`define INST_ENCODING_WFE                       32'bxxxxxxxxxxxxxxxx1011111100100000
`define INST_ENCODING_PUSH                      32'bxxxxxxxxxxxxxxxx1011010xxxxxxxxx
`define INST_ENCODING_POP                       32'bxxxxxxxxxxxxxxxx1011110xxxxxxxxx
`define INST_ENCODING_UNCONDITIONAL_BRANCH      32'bxxxxxxxxxxxxxxxx11100xxxxxxxxxxx
`define INST_ENCODING_CONDITIONAL_BRANCH        32'bxxxxxxxxxxxxxxxx1101xxxxxxxxxxxx

// 32-bit instructions
`define INST_ENCODING_BRANCH_AND_LINK           32'b11xxxxxxxxxxxxxx11110xxxxxxxxxxx

// Data Processing Register Opcodes
`define DATA_PROCESSING_REGISTER_OPCODE_AND    4'b0000
`define DATA_PROCESSING_REGISTER_OPCODE_EOR    4'b0001
`define DATA_PROCESSING_REGISTER_OPCODE_LSL    4'b0010
`define DATA_PROCESSING_REGISTER_OPCODE_LSR    4'b0011
`define DATA_PROCESSING_REGISTER_OPCODE_ASR    4'b0100
`define DATA_PROCESSING_REGISTER_OPCODE_ADC    4'b0101
`define DATA_PROCESSING_REGISTER_OPCODE_SBC    4'b0110
`define DATA_PROCESSING_REGISTER_OPCODE_ROR    4'b0111
`define DATA_PROCESSING_REGISTER_OPCODE_TST    4'b1000
`define DATA_PROCESSING_REGISTER_OPCODE_RSB    4'b1001
`define DATA_PROCESSING_REGISTER_OPCODE_CMP    4'b1010
`define DATA_PROCESSING_REGISTER_OPCODE_CMN    4'b1011
`define DATA_PROCESSING_REGISTER_OPCODE_ORR    4'b1100
`define DATA_PROCESSING_REGISTER_OPCODE_MUL    4'b1101
`define DATA_PROCESSING_REGISTER_OPCODE_BIC    4'b1110
`define DATA_PROCESSING_REGISTER_OPCODE_MVN    4'b1111

`define NEW_PC_PLUS_2        3'b000
`define NEW_PC_PLUS_4        3'b001
`define NEW_PC_BX            3'b010
`define NEW_PC_BRANCH        3'b011
`define NEW_PC_COND_BRANCH   3'b100
`define NEW_PC_BRANCH_LINK   3'b101
`define NEW_PC_POP           3'b110


`endif


