
`include "push_fsm.v"
`include "conditional_branch.v"
`include "control.vh"


module control(clk, rst, instruction_encoding, rf_read_0, rf_read_1, rf_write, rf_write_enable, rf_data_in_select, alu_input_0, alu_input_1, alu_control, rf_out_0, rf_out_1, pc, new_pc_select, immediate, dmem_byte_enable, dmem_write_enable, dmem_create_dump, dmem_out_byte_select, force_stall_in_decode, flags, alu_carry_in, save_new_pc_from_dmem_out) ;

  input alu_c_out, clk, rst;
  input [3:0] flags;
  input [31:0] instruction_encoding, rf_out_0, rf_out_1, pc;
  output reg [3:0] rf_read_0, rf_read_1, rf_write;
  output reg [3:0] alu_control;
  output reg rf_write_enable, dmem_write_enable, dmem_create_dump;
  output reg [31:0] alu_input_0, alu_input_1, immediate;
  output reg [2:0] new_pc_select;
  output reg [1:0] rf_data_in_select, dmem_out_byte_select;
  output reg [3:0] dmem_byte_enable;
  output reg force_stall_in_decode;
  output reg alu_carry_in;
  output save_new_pc_from_dmem_out;

  reg push_fsm_active, push_fsm_push_pop;
  reg [15:0] push_fsm_register_list;
  reg [3:0] push_fsm_base_register;
  wire push_fsm_dmem_write_enable, push_fsm_rf_write_enable, push_fsm_done, branch_taken;
  wire [3:0] push_fsm_rf_read_0, push_fsm_rf_read_1, push_fsm_rf_write;
  wire [2:0] push_fsm_alu_control;
  wire [31:0] push_fsm_alu_input_0, push_fsm_alu_input_1;
  wire [31:0] push_fsm_new_pc;
  wire [1:0] push_fsm_rf_data_in_select;
  wire [3:0] push_fsm_dmem_byte_enable;

push_fsm pfsm (.clk(clk), .rst(rst), .active(push_fsm_active),
               .register_list(push_fsm_register_list),
               .base_register(push_fsm_base_register),
               .dmem_write_enable(push_fsm_dmem_write_enable),
               .rf_read_0(push_fsm_rf_read_0),
               .rf_read_1(push_fsm_rf_read_1),
               .rf_write(push_fsm_rf_write),
               .rf_write_enable(push_fsm_rf_write_enable),
               .alu_control(push_fsm_alu_control),
               .alu_input_0(push_fsm_alu_input_0),
               .alu_input_1(push_fsm_alu_input_1),
               .rf_data_in_select(push_fsm_rf_data_in_select),
               .dmem_byte_enable(push_fsm_dmem_byte_enable),
               .done(push_fsm_done), 
               .push_pop(push_fsm_push_pop),
               .save_new_pc_from_dmem_out(save_new_pc_from_dmem_out));


// Branch taken/not taken logic for conditional branch instructions
conditional_branch branch_decision_logic(.instruction_encoding(instruction_encoding),
                                         .flags(flags), .taken(branch_taken)) ;

  always @ (*)
    casex(instruction_encoding)
      // 16-bit instruction encodings

      `INST_ENCODING_LD_ST_WORD_BYTE_IMM_OFF: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        force_stall_in_decode = 1'b0;
        dmem_write_enable = ~instruction_encoding[11]; // Write to dmem if 'L' bit in the instruction is clear
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = {1'b0, instruction_encoding[5:3]};
        rf_read_1 = {1'b0, instruction_encoding[2:0]};
        rf_write = {1'b0,instruction_encoding[2:0]};
        rf_write_enable = instruction_encoding[11]; // Write to reg file if 'L' bit in the intruction is set
        alu_control = `ALU_ADD_SIGNED_FUNCTION;
        alu_input_0 = rf_out_0;

        if(instruction_encoding[12] == 1'b0) begin
          alu_input_1 = {25'b0,instruction_encoding[10:6],2'b0}; // Load word: Zero extend immediate and align to 4-byte boundary
          dmem_byte_enable = 4'hf;
          dmem_out_byte_select = 2'b0;
        end else begin
          alu_input_1 = {27'b0,instruction_encoding[10:6]} & 32'hfffffffc; // Load byte: Zero extend immediate, unaligned
          dmem_byte_enable = (1<<instruction_encoding[7:6]);
          dmem_out_byte_select = instruction_encoding[7:6];
        end
        rf_data_in_select = 2'b0;
        immediate = 32'bx;
        push_fsm_push_pop = 1'bx;
      end
      `INST_ENCODING_LOAD_FROM_LITERAL_POOL: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'hf;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = 4'bxxxx;
        rf_read_1 = 4'bxxxx;
        rf_write = {1'b0,instruction_encoding[10:8]};
        rf_write_enable = 1;
        alu_control = `ALU_ADD_UNSIGNED_FUNCTION;
        alu_input_0 = ((pc & 32'hfffffffc) + 32'h4);
        alu_input_1 = {22'b0,instruction_encoding[7:0],2'b0};
        rf_data_in_select = 2'b0;
        immediate = 32'bx;
        push_fsm_push_pop = 1'bx;
        end
      `INST_ENCODING_PUSH: begin
        push_fsm_base_register = 4'd13;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = {1'b0, instruction_encoding[8], 6'b0, instruction_encoding[7:0]};
        push_fsm_active = 1'b1;
        force_stall_in_decode = ~push_fsm_done;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = push_fsm_dmem_write_enable;
        dmem_byte_enable = push_fsm_dmem_byte_enable;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = push_fsm_rf_read_0;
        rf_read_1 = push_fsm_rf_read_1;
        rf_write = push_fsm_rf_write;
        rf_write_enable = push_fsm_rf_write_enable;
        alu_control = push_fsm_alu_control;
        alu_input_0 = rf_out_0;
        alu_input_1 = push_fsm_alu_input_1;
        rf_data_in_select = push_fsm_rf_data_in_select;
        immediate = 32'bx;
        push_fsm_push_pop = 1'b1;
        end
      `INST_ENCODING_POP: begin
        push_fsm_base_register = 4'd13;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = {instruction_encoding[8], 7'b0, instruction_encoding[7:0]};
        push_fsm_active = 1'b1;
        force_stall_in_decode = ~push_fsm_done;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = push_fsm_dmem_write_enable;
        dmem_byte_enable = push_fsm_dmem_byte_enable;
        new_pc_select = instruction_encoding[8] ? `NEW_PC_POP :`NEW_PC_PLUS_2;
        rf_read_0 = push_fsm_rf_read_0;
        rf_read_1 = push_fsm_rf_read_1;
        rf_write = push_fsm_rf_write;
        rf_write_enable = push_fsm_rf_write_enable;
        alu_control = push_fsm_alu_control;
        alu_input_0 = rf_out_0;
        alu_input_1 = push_fsm_alu_input_1;
        rf_data_in_select = push_fsm_rf_data_in_select;
        immediate = 32'bx;
        push_fsm_push_pop = 1'b0;
        end


      `INST_ENCODING_ADD_SUB_CMP_MOV_IMMEDIATE: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_1 = {4'bxxxx};
        rf_read_0 = {1'b0,instruction_encoding[10:8]};
        alu_input_0 = rf_out_0;
        immediate = {24'b0, instruction_encoding[7:0]};

        // Opcode field
        if (instruction_encoding[12:11] == 2'b00) begin // MOV instructions
          alu_input_1 = 32'bx;
          rf_data_in_select = 2'b11; // Select immediate input field
          rf_write = {1'b0,instruction_encoding[10:8]};
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
          rf_write_enable = 1;
        end else if (instruction_encoding[12:11] == 2'b01) begin // CMP instructions
          alu_input_1 = immediate;
          rf_data_in_select = 2'bxx;
          rf_write = {4'bxxxx};
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
          rf_write_enable = 0;
        end else if (instruction_encoding[12:11] == 2'b10) begin // ADD instructions
          alu_input_1 = immediate;
          rf_data_in_select = 2'b10;
          rf_write = {1'b0,instruction_encoding[10:8]};
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
          rf_write_enable = 1;
        end else if (instruction_encoding[12:11] == 2'b11) begin // SUB instructions
          alu_input_1 = immediate;
          rf_data_in_select = 2'b10;
          rf_write = {1'b0,instruction_encoding[10:8]};
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
          rf_write_enable = 1;
        end
        end
      `INST_ENCODING_ADD_SUB_REGISTER: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;

        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = {1'b0,instruction_encoding[2:0]};
        rf_read_1 = {1'b0,instruction_encoding[8:6]};
        rf_read_0 = {1'b0,instruction_encoding[5:3]};
        rf_write_enable = 1;
        alu_input_0 = rf_out_0;
        alu_input_1 = rf_out_1;
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
        
        if (instruction_encoding[9] == 1'b0) begin // MOV instructions
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
        end else if (instruction_encoding[9] == 1'b1) begin // ADD instructions, p 4-22
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
        end

        end
      `INST_ENCODING_ADD_TO_PC_OR_SP: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = {1'b0,instruction_encoding[10:8]};
        rf_read_1 = 4'bxxxx;
        rf_read_0 = 13;
        rf_write_enable = 1;
        alu_input_0 = instruction_encoding[11] ? rf_out_0 : pc;
        alu_input_1 = {22'b0,instruction_encoding[7:0],2'b00};
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
        
        alu_control = `ALU_ADD_SIGNED_FUNCTION;

        end
      `INST_ENCODING_LD_ST_STACK: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = ~instruction_encoding[11];
        dmem_byte_enable = 4'hf;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = {1'b0,instruction_encoding[10:8]};
        rf_read_1 = {1'b0,instruction_encoding[10:8]};
        rf_read_0 = 13; // Get SP value from reg file
        rf_write_enable = instruction_encoding[11];
        alu_input_0 = rf_out_0;
        alu_input_1 = {22'b0,instruction_encoding[7:0],2'b00};
        rf_data_in_select = 2'b00;
        immediate = 32'bx;
        
        alu_control = `ALU_ADD_UNSIGNED_FUNCTION;


      end
      `INST_ENCODING_ADD_SUB_IMMEDIATE: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = {1'b0,instruction_encoding[2:0]};
        rf_read_1 = 4'bxxxx;
        rf_read_0 = {1'b0,instruction_encoding[5:3]};
        rf_write_enable = 1;
        alu_input_0 = rf_out_0;
        alu_input_1 = { 29'b0, instruction_encoding[8:6]};
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
        
        if (instruction_encoding[9] == 1'b0) begin // MOV instructions
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
        end else if (instruction_encoding[9] == 1'b1) begin // ADD instructions, p 4-22
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
        end

        end
      `INST_ENCODING_SHIFT_IMMEDIATE_MOV: begin
        push_fsm_base_register = 4'bxxxx;
        push_fsm_push_pop = 1'bx;
        alu_carry_in = 1'b0;
        if(instruction_encoding[12:11] == 2'b00) begin
          // MOV/LSL instruction
          dmem_create_dump = 1'b0;
          push_fsm_register_list = 16'bx;
          push_fsm_active = 1'b0;
          force_stall_in_decode = 1'b0;
          dmem_out_byte_select = 2'bx;
          dmem_write_enable = 0;
          dmem_byte_enable = 4'b0;
          new_pc_select = `NEW_PC_PLUS_2;
          rf_read_0 = {1'b0,instruction_encoding[5:3]};
          rf_read_1 = 4'bxxxx;
          rf_write = {1'b0,instruction_encoding[2:0]};
          rf_write_enable = 1;
          alu_control = `ALU_LEFT_SHIFT_FUNCTION;
          alu_input_0 = rf_out_0;
          alu_input_1 = {27'b0,instruction_encoding[10:6]};
          rf_data_in_select = 2'b10;
          immediate = 32'bx;
        end else if (instruction_encoding[12:11] == 2'b01) begin
          // LSR instruction
          dmem_create_dump = 1'b0;
          push_fsm_register_list = 16'bx;
          push_fsm_active = 1'b0;
          force_stall_in_decode = 1'b0;
          dmem_out_byte_select = 2'bx;
          dmem_write_enable = 0;
          dmem_byte_enable = 4'b0;
          new_pc_select = `NEW_PC_PLUS_2;
          rf_read_0 = {1'b0,instruction_encoding[5:3]};
          rf_read_1 = 4'bxxxx;
          rf_write = {1'b0,instruction_encoding[2:0]};
          rf_write_enable = 1;
          alu_control = `ALU_RIGHT_SHIFT_LOGICAL_FUNCTION;
          alu_input_0 = rf_out_0;
          alu_input_1 = {27'b0,instruction_encoding[10:6]};
          rf_data_in_select = 2'b10;
          immediate = 32'bx;
        end else if (instruction_encoding[12:11] == 2'b10) begin
          // ASR instruction
          dmem_create_dump = 1'b0;
          push_fsm_register_list = 16'bx;
          push_fsm_active = 1'b0;
          force_stall_in_decode = 1'b0;
          dmem_out_byte_select = 2'bx;
          dmem_write_enable = 0;
          dmem_byte_enable = 4'b0;
          new_pc_select = `NEW_PC_PLUS_2;
          rf_read_0 = {1'b0,instruction_encoding[5:3]};
          rf_read_1 = 4'bxxxx;
          rf_write = {1'b0,instruction_encoding[2:0]};
          rf_write_enable = 1;
          alu_control = `ALU_RIGHT_SHIFT_ARITHMETIC_FUNCTION;
          alu_input_0 = rf_out_0;
          alu_input_1 = {27'b0,instruction_encoding[10:6]};
          rf_data_in_select = 2'b10;
          immediate = 32'bx;
        end else begin
          // Default case, shouldn't be used
          dmem_create_dump = 1'bx;
          push_fsm_register_list = 16'bx;
          push_fsm_active = 1'bx;
          force_stall_in_decode = 1'bx;
          dmem_out_byte_select = 2'bx;
          dmem_write_enable = 1'bx;
          dmem_byte_enable = 4'bxxxx;
          new_pc_select = `NEW_PC_PLUS_2;
          rf_read_0 = {1'b0,instruction_encoding[5:3]};
          rf_read_1 = 4'bxxxx;
          rf_write = {1'b0,instruction_encoding[2:0]};
          rf_write_enable = 1'bx;
          alu_control = `ALU_RIGHT_SHIFT_ARITHMETIC_FUNCTION;
          alu_input_0 = 32'bx;
          alu_input_1 = 32'bx;
          rf_data_in_select = 2'bxx;
          immediate = 32'bx;
        end
      end
      `INST_ENCODING_DATA_PROCESSING_REGISTER: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 1'b0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = {1'b0,instruction_encoding[2:0]};
        rf_read_0 = {1'b0,instruction_encoding[2:0]};
        rf_read_1 = {1'b0,instruction_encoding[5:3]};
        rf_write_enable = 1'b1;
        alu_input_0 = rf_out_0;
        alu_input_1 = rf_out_1;
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
        
        alu_control = 4'bxxxx;
        if(instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_AND) begin
          alu_control = `ALU_AND_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_EOR) begin
          alu_control = `ALU_XOR_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_LSL) begin
          alu_control = `ALU_LEFT_SHIFT_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_LSR) begin
          alu_control = `ALU_RIGHT_SHIFT_LOGICAL_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_ASR) begin
          alu_control = `ALU_RIGHT_SHIFT_ARITHMETIC_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_ADC) begin
          alu_carry_in = flags[1];
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_SBC) begin
          // UNIMPLEMENTED
          $display("Encountered unimplemented data processing register instruction");
          #11;
          $finish;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_ROR) begin
          // UNIMPLEMENTED
          $display("Encountered unimplemented data processing register instruction");
          #11;
          $finish;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_TST) begin
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_RSB) begin // (aka NEG), page 4-249
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
          alu_input_0 = 32'b0;
          alu_input_1 = rf_out_1;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_CMP) begin
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
          rf_write_enable = 1'b0;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_CMN) begin
          // UNIMPLEMENTED
          $display("Encountered unimplemented data processing register instruction");
          #11;
          $finish;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_ORR) begin
          alu_control = `ALU_OR_FUNCTION;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_MUL) begin
          // UNIMPLEMENTED
          $display("Encountered unimplemented data processing register instruction");
          #11;
          $finish;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_BIC) begin
          // UNIMPLEMENTED
          $display("Encountered unimplemented data processing register instruction");
          #11;
          $finish;
        end else if (instruction_encoding[9:6] == `DATA_PROCESSING_REGISTER_OPCODE_MVN) begin
          // UNIMPLEMENTED
          $display("Encountered unimplemented data processing register instruction");
          #11;
          $finish;
        end
      end
      `INST_ENCODING_BRANCH_EXCHANGE: begin
        push_fsm_base_register = 4'bxxxx;
        push_fsm_push_pop = 1'bx;

        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        rf_read_0 = instruction_encoding[6:3]; // Read the Link register
        rf_read_1 = 4'bxxxx;
        rf_write = 4'bxxxx; // Write to the LR, R14
        rf_write_enable = 1'b0;
        alu_control = 4'bxxxx;
        alu_input_0 = 32'bx;
        alu_input_1 = 32'bx;
        rf_data_in_select = 2'b11;
        immediate = (pc + 4) | 1 ; // Value to write to the LR, setting the low-order bit to indicatte thumb mode
        new_pc_select = `NEW_PC_BX;
      end
      `INST_ENCODING_SPECIAL_DATA_PROCESSING: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;

        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = {instruction_encoding[7],instruction_encoding[2:0]};
        rf_read_0 = instruction_encoding[6:3];
        rf_read_1 = 4'bxxxx;
        immediate = 32'bx;
        
        if (instruction_encoding[9:8] == 2'b10) begin // MOV instructions
          rf_write_enable = 1'b1;
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
          alu_input_0 = rf_out_0;
          alu_input_1 = rf_out_1;
          rf_data_in_select = 2'b01;
        end else if (instruction_encoding[9:8] == 2'b00) begin // ADD instructions, p 4-22
          rf_read_1 = {instruction_encoding[7],instruction_encoding[2:0]};
          rf_write_enable = 1'b1;
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
          alu_input_0 = rf_out_0;
          alu_input_1 = rf_out_1;
          rf_data_in_select = 2'b10;
        end else if (instruction_encoding[9:8] == 2'b01) begin // CMP instructions
          rf_read_1 = {instruction_encoding[7],instruction_encoding[2:0]};
          rf_write_enable = 1'b0;
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
          alu_input_0 = rf_out_0;
          alu_input_1 = rf_out_1;
          rf_data_in_select = 2'bxx;
        end else begin
          $display("Encountered unimplemented special data processing instruction");
          $display("INST: %08x", instruction_encoding);
          $display("PC:   %08x", pc);
          #11
          $finish;
        end

        end
      `INST_ENCODING_BYTE_REVERSE: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'h0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = {1'b0,instruction_encoding[5:3]};
        rf_read_1 = 4'bxxxx;
        rf_write = {1'b0,instruction_encoding[2:0]};
        rf_write_enable = 1'b1;
        alu_control = `ALU_BYTE_REVERSE;
        alu_input_0 = rf_out_0;
        alu_input_1 = 32'bx;
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
      end
      `INST_ENCODING_SIGN_ZERO_EXTEND: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'h0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = {1'b0,instruction_encoding[5:3]};
        rf_read_1 = 4'bxxxx;
        rf_write = {1'b0,instruction_encoding[2:0]};
        rf_write_enable = 1'b1;
        alu_input_0 = rf_out_0;
        alu_input_1 = 32'bx;
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
        if(instruction_encoding[7:6] == 2'b00) begin // Sign extend halfword
          alu_control = `ALU_SEXT_HALFWORD;
        end else if (instruction_encoding[7:6] == 2'b01) begin // Sign extend byte
          alu_control = `ALU_SEXT_BYTE;
        end else if (instruction_encoding[7:6] == 2'b10) begin // Zero extend halfword
          alu_control = `ALU_ZEXT_HALFWORD;
        end else if (instruction_encoding[7:6] == 2'b11) begin // Zero extend halfword
          alu_control = `ALU_ZEXT_BYTE;
        end 
      end
      `INST_ENCODING_ADJUST_SP: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_write = 4'd13; // Write to stack pointer
        rf_read_1 = 4'bxxxx;
        rf_read_0 = 4'd13;
        rf_write_enable = 1;
        alu_input_0 = rf_out_0;
        alu_input_1 = {23'b0,instruction_encoding[6:0], 2'b0};
        rf_data_in_select = 2'b10;
        immediate = 32'bx;
        
        if (instruction_encoding[7] == 1'b1) begin // SUB instructions
          alu_control = `ALU_SUB_SIGNED_FUNCTION;
        end else if (instruction_encoding[7] == 1'b1) begin
          alu_control = `ALU_ADD_SIGNED_FUNCTION;
        end

        end
      `INST_ENCODING_WFE: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b1;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = 4'b0000;
        rf_read_1 = 4'b0000;
        rf_write = 0000;
        rf_write_enable = 1'b0;
        alu_control = `ALU_ADD_SIGNED_FUNCTION;
        alu_input_0 = rf_out_0;
        alu_input_1 = rf_out_1;
        rf_data_in_select = 2'bx;
        immediate = 32'bx;
        #11;
        $display("got WFE instruction");
        $finish;
        end

      `INST_ENCODING_UNCONDITIONAL_BRANCH: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'h0;
        new_pc_select = `NEW_PC_BRANCH;
        rf_read_0 = 4'bxxxx;
        rf_read_1 = 4'bxxxx;
        rf_write = 4'bx;
        rf_write_enable = 1'b0;
        alu_control = `ALU_ADD_SIGNED_FUNCTION;
        alu_input_0 = 32'bx;
        alu_input_1 = 32'bx;
        rf_data_in_select = 2'b0;
        immediate = 32'bx;
      end


      `INST_ENCODING_CONDITIONAL_BRANCH: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'h0;
        rf_read_0 = 4'bxxxx;
        rf_read_1 = 4'bxxxx;
        rf_write = 4'bx;
        rf_write_enable = 1'b0;
        alu_control = `ALU_ADD_SIGNED_FUNCTION;
        alu_input_0 = 32'bx;
        alu_input_1 = 32'bx;
        rf_data_in_select = 2'b0;
        immediate = 32'bx;

        if(branch_taken == 1'b1) begin
          new_pc_select = `NEW_PC_COND_BRANCH;
        end else begin
          new_pc_select = `NEW_PC_PLUS_2;
        end

      end
      // 32-bit instruction encodings
      `INST_ENCODING_BRANCH_AND_LINK: begin
        push_fsm_base_register = 4'bxxxx;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        push_fsm_push_pop = 1'bx;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        rf_read_0 = 4'bxxxx;
        rf_read_1 = 4'bxxxx;
        rf_write = 4'd14; // Write to the LR, R14
        rf_write_enable = 1'b1;
        alu_control = 4'bxxxx;
        alu_input_0 = 32'bx;
        alu_input_1 = 32'bx;
        rf_data_in_select = 2'b11;
        immediate = (pc + 4) | 1 ; // Value to write to the LR, setting the low-order bit to indicatte thumb mode
//        new_pc = 4 + pc + {{7{instruction_encoding[10]}}, instruction_encoding[10], ~(instruction_encoding[10] ^ instruction_encoding[29]),~(instruction_encoding[10] ^ instruction_encoding[27]), instruction_encoding[9:0], instruction_encoding[26:16], 1'b0};
        new_pc_select = `NEW_PC_BRANCH_LINK;
        end
      default: begin
        $display("Default case reached in control.v pc = %08x", pc);
        #2
        $finish;
        alu_carry_in = 1'b0;
        dmem_create_dump = 1'b0;
        push_fsm_register_list = 16'bx;
        push_fsm_active = 1'b0;
        force_stall_in_decode = 1'b0;
        dmem_out_byte_select = 2'b0;
        dmem_write_enable = 0;
        dmem_byte_enable = 4'b0;
        new_pc_select = `NEW_PC_PLUS_2;
        rf_read_0 = 4'b0000;
        rf_read_1 = 4'b0000;
        rf_write = 4'b0000;
        rf_write_enable = 1'b0;
        alu_control = `ALU_ADD_SIGNED_FUNCTION;
        alu_input_0 = rf_out_0;
        alu_input_1 = rf_out_1;
        rf_data_in_select = 2'bx;
        immediate = 32'bx;
        end

    endcase


endmodule

