
/*
State diagram for the push_fsm

                                        PUSHLIST[0]=1,PUSH_POP=1
                               -----------------------------------
                              /
                             /               PUSHLIST[0]=0          \
                            /                ----\                   \
                           /                |     |
                          /                  \   \/                     \/
   ------- ACTIVE=1  ------                 --------                 ------
  /       \         /      \ PUSHLIST[0]=0 / SHIFT  \ PUSHLIST[0]=1 /      \ 
 |  IDLE   | ----> |  INIT  | ----------->| PUSHLIST | ----------> | DEC_SP |
  \       /         \      /            ---\        /  PUSH_POP=1   \      / 
   -------           ------            /    -------- \               ------
        /\            | PUSHLIST=0    /     ^  ^   /\ \                  |
         \            |---------------      |  |    |  \ PUSHLIST[0]=1   /
          ----        |                 |---|  |    |   \PUSH_POP=0     /
               \      |PUSHLIST=0       |      |    |   |              /
                \     |                 |      |    |   |             /
                 \    |             PUSH_POP=1 \    |   |            /
                  \  \/                 |       \   |   \/          /
                   ------             -----      \ ------          /
                  /      \           /      \     /      \        /
                 |  DONE  |         | INC_SP |<--|STORREG | <-----
                  \      /           \      /     \      / 
                   ------             -----        ------  
*/


module push_fsm (clk, rst, active, register_list, base_register, dmem_write_enable, rf_read_0, rf_read_1, rf_write, rf_write_enable, alu_control, alu_input_0, alu_input_1, rf_data_in_select, dmem_byte_enable, done, push_pop, save_new_pc_from_dmem_out);

  parameter IDLE = 7'b0000001, INIT = 7'b0000010, SHIFT_PUSHLIST = 7'b0000100, DEC_SP = 7'b0001000, STOREREG = 7'b0010000,  DONE = 7'b0100000, INC_SP = 7'b1000000;

  input clk, rst, active, push_pop;
  input [15:0] register_list;
  input [3:0] base_register;
  output reg [3:0] rf_read_0, rf_read_1, rf_write;
  output reg [3:0] dmem_byte_enable;
  output reg [2:0] alu_control;
  output reg rf_write_enable, dmem_write_enable;
  output reg [31:0] alu_input_0, alu_input_1;
  output reg [1:0] rf_data_in_select;
  output reg done;
  output reg save_new_pc_from_dmem_out;
  reg [15:0] push_list, new_push_list;
  reg [3:0] reg_num, new_reg_num;
  reg [6:0] state, next_state;

  integer i;

  // Next state logic
  always @ (state or active or register_list or push_list) begin :FSM_COMBO
    case(state)
      IDLE: if(active == 1'b1) begin
              next_state = INIT;
            end else begin
              next_state = IDLE;
            end
      INIT: if (push_list == 16'b0) begin
              next_state = DONE;
            end else if (push_list[0] == 1'b0) begin
              next_state = SHIFT_PUSHLIST;
            end else if (push_list[0] == 1'b1 && push_pop ==1'b1) begin
              next_state = DEC_SP;
            end else begin
              next_state = STOREREG;
            end
      SHIFT_PUSHLIST: if (push_list == 16'b0) begin
                        next_state = DONE;
                      end else if (push_list[0] == 1'b0) begin
                        next_state = SHIFT_PUSHLIST;
                      end else if(push_list[0] == 1'b1 && push_pop == 1'b1) begin
                        next_state = DEC_SP;
                      end else begin
                        next_state = STOREREG;
                      end
      DEC_SP: next_state = STOREREG;
      INC_SP: next_state = SHIFT_PUSHLIST;
      STOREREG: if (push_pop == 1'b1) begin
                  next_state = SHIFT_PUSHLIST;
                end else begin
                  next_state = INC_SP;
                end
      DONE: next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end

  // Sequential Logic
  always @ (posedge clk) begin: FSM_SEQ
    if(rst == 1'b1) begin
      state <= IDLE;
      push_list <= 16'b0;
    end else begin
      state <= next_state;
      push_list <= new_push_list;
      reg_num <= new_reg_num;
    end
  end

  // Output Logic
//  always @ (posedge clk or push_list) begin : OUTPUT_LOGIC
  always @ (*) begin : OUTPUT_LOGIC
/*
    if (rst == 1'b1) begin
      rf_read_0 = 4'b0;
      rf_read_1 = 4'b0;
      rf_write = 4'b0;
      alu_control = 3'b0;
      rf_write_enable = 1'b0;
      dmem_write_enable = 1'b0;
      alu_input_0 = 32'b0;
      alu_input_1 = 32'b0;
      rf_data_in_select = 2'b0;
      done = 1'b0;
    end else begin
*/
      case (state)
        IDLE: begin
          new_reg_num = push_pop ? -1 : 0;
          if (push_pop == 1'b1) begin
            // For push instruction, push the registers in forward order
            new_push_list = register_list;
          end else begin
            // For pop instruction, bit reverse the register list to pop in reverse
            for (i = 0; i < 16; i = i+1) begin
              new_push_list[i] = register_list[15-i]; // or whatever
            end
          end
          dmem_byte_enable = 4'b0;
          rf_read_0 = 4'b0;
          rf_read_1 = 4'b0;
          rf_write = 4'b0;
          alu_control = 3'b0;
          rf_write_enable = 1'b0;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'b0;
          rf_data_in_select = 2'b0;
          done = 1'b0;
          save_new_pc_from_dmem_out = 1'b0;
        end
        INIT: begin
          new_reg_num = -1;
          new_push_list = register_list;
          dmem_byte_enable = 4'b0;
          rf_read_0 = 4'b0;
          rf_read_1 = 4'b0;
          rf_write = 4'b0;
          alu_control = 3'b0;
          rf_write_enable = 1'b0;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'b0;
          rf_data_in_select = 2'b0;
          done = 1'b0;
          save_new_pc_from_dmem_out = 1'b0;
        end
        SHIFT_PUSHLIST: begin
          new_reg_num = push_pop ? reg_num + 1 : reg_num - 1;
          new_push_list = {1'b0, push_list[15:1]};
          dmem_byte_enable = 4'b0;
          rf_read_0 = 4'b0;
          rf_read_1 = 4'b0;
          rf_write = 4'b0;
          alu_control = 3'b0;
          rf_write_enable = 1'b0;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'b0;
          rf_data_in_select = 2'b0;
          done = 1'b0;
          save_new_pc_from_dmem_out = 1'b0;
        end
        DEC_SP: begin
          new_reg_num = reg_num;
          new_push_list = push_list;
          dmem_byte_enable = 4'b0;
          rf_read_0 = base_register;
          rf_read_1 = 4'b0;
          rf_write = base_register;
          alu_control = `ALU_SUB_UNSIGNED_FUNCTION;
          rf_write_enable = 1'b1;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'd4;
          rf_data_in_select = 2'b10;
          done = 1'b0;
          save_new_pc_from_dmem_out = 1'b0;
        end
        INC_SP: begin
          new_reg_num = reg_num;
          new_push_list = push_list;
          dmem_byte_enable = 4'b0;
          rf_read_0 = base_register;
          rf_read_1 = 4'b0;
          rf_write = base_register;
          alu_control = `ALU_ADD_UNSIGNED_FUNCTION;
          rf_write_enable = 1'b1;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'd4;
          rf_data_in_select = 2'b10;
          done = 1'b0;
          save_new_pc_from_dmem_out = 1'b0;
        end

        STOREREG: begin
          new_reg_num = reg_num;
          new_push_list = push_list;
          dmem_byte_enable = 4'hf;
          rf_read_0 = base_register;
          rf_read_1 = reg_num;
          rf_write = push_pop ? 4'bx : reg_num;
          alu_control = 3'b0;
          rf_write_enable = ~push_pop ; // If pushing, don't write to register file. If popping, we do write.
          dmem_write_enable = push_pop; // If pushing, write to mem. If popping, don't write to mem.
          alu_input_0 = 32'b0;
          alu_input_1 = 32'b0;
          rf_data_in_select = 2'b0;
          done = 1'b0;
          save_new_pc_from_dmem_out = (reg_num == 4'hf) & (push_pop == 1'b0) & (push_list != 0);
        end
        DONE: begin
          new_reg_num = reg_num;
          new_push_list = push_list;
          dmem_byte_enable = 4'b0;
          rf_read_0 = 4'b0;
          rf_read_1 = 4'b0;
          rf_write = 4'b0;
          alu_control = 3'b0;
          rf_write_enable = 1'b0;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'b0;
          rf_data_in_select = 2'b0;
          done = 1'b1;
          save_new_pc_from_dmem_out = 1'b0;
        end
        default: begin
          new_reg_num = -1;
          new_push_list = 16'b0;
          dmem_byte_enable = 4'b0;
          rf_read_0 = 4'b0;
          rf_read_1 = 4'b0;
          rf_write = 4'b0;
          alu_control = 3'b0;
          rf_write_enable = 1'b0;
          dmem_write_enable = 1'b0;
          alu_input_0 = 32'b0;
          alu_input_1 = 32'b0;
          rf_data_in_select = 2'b0;
          done = 1'b0;
          save_new_pc_from_dmem_out = 1'b0;
        end
      endcase
//    end
  end
endmodule
