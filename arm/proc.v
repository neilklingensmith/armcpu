
`include "control.vh"
`include "alu.vh"

module proc(clk, rst, addr, data_out, data_in, io_en);
  input clk, rst;

  output wire [31:0] addr, data_out,  data_in;
  output wire io_en;

  wire [31:0] instruction, dmem_out;
  wire [3:0] rf_read_0, rf_read_1, rf_write_reg;
  wire [31:0] rf_out_0, rf_out_1;
  wire rf_write_enable, alu_carry_in;
  wire [3:0] alu_ctrl;
  wire [31:0] alu_out, immediate;
  wire alu_c_out, alu_neg, alu_zero, alu_ovfl;
  wire [31:0] alu_input_0, alu_input_1;
  wire [1:0] rf_data_in_select;
  wire [3:0] newflags;
  wire [3:0] dmem_byte_enable;
  wire dmem_write_enable, dmem_create_dump;
  wire force_stall_in_decode;
  wire save_new_pc_from_dmem_out;
  reg [31:0] shifted_dmem_out;
  wire [1:0] dmem_out_byte_select;
  reg [31:0] new_pc;
  reg [31:0] new_pc_pop_register;
  wire [2:0] new_pc_select;

  reg [3:0] flags; // NZCV
  reg [31:0] pc;
  reg [31:0] rf_data_in;


  assign addr = alu_out;
  assign data_out = rf_out_1;
  assign io_en =  (|addr[31:24]) & dmem_write_enable;

  always @ (posedge clk) begin
    if(rst) begin
      pc <= 32'h0;
      new_pc_pop_register <= 32'b0;
      flags <= 0;
    end else if(force_stall_in_decode == 1'b0) begin
      pc <= new_pc;
      new_pc_pop_register <= save_new_pc_from_dmem_out ? shifted_dmem_out : new_pc_pop_register;
      flags <= newflags;
    end else begin
      pc <= pc; // if force_stall_in_decode is 1, don't update the PC
      new_pc_pop_register <= save_new_pc_from_dmem_out ? shifted_dmem_out : new_pc_pop_register;
    end
  end

  always @(*)
    case(new_pc_select)
    `NEW_PC_PLUS_2: begin
        new_pc = 2 + pc;
    end
    `NEW_PC_PLUS_4: begin
        new_pc = 4 + pc;
    end
    `NEW_PC_BX: begin
        new_pc = {rf_out_0[31:1] , 1'b0}; // Discard LSB, which is 1 to indicate thumb mode
    end
    `NEW_PC_BRANCH: begin
        new_pc = pc + {{20{instruction[10]}}, instruction[10:0],1'b0} + 4;
    end
    `NEW_PC_COND_BRANCH: begin
        new_pc = pc + {{23{instruction[7]}}, instruction[7:0],1'b0} + 4;
    end
    `NEW_PC_BRANCH_LINK: begin
        new_pc = 4 + pc + {{7{instruction[10]}}, instruction[10], ~(instruction[10] ^ instruction[29]),~(instruction[10] ^ instruction[27]), instruction[9:0], instruction[26:16], 1'b0};
    end
    `NEW_PC_POP: begin
        new_pc = {new_pc_pop_register[31:1], 1'b0};
    end
    default: begin
        new_pc = 32'b0;
    end
    endcase

  // Fetch
  memory2c imem (.data_out(instruction), .data_in(32'b0), .addr(pc), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));

  control decode_logic(.clk(clk),
                       .rst(rst),
                       .instruction_encoding(instruction),
                       .rf_read_0(rf_read_0),
                       .rf_read_1(rf_read_1),
                       .rf_write(rf_write_reg),
                       .rf_write_enable(rf_write_enable),
                       .rf_data_in_select(rf_data_in_select),
                       .alu_input_0(alu_input_0),
                       .alu_input_1(alu_input_1),
                       .alu_control(alu_ctrl),
                       .rf_out_0(rf_out_0),
                       .rf_out_1(rf_out_1),
                       .pc(pc),
                       .new_pc_select(new_pc_select),
                       .immediate(immediate),
                       .dmem_write_enable(dmem_write_enable),
                       .dmem_byte_enable(dmem_byte_enable),
                       .dmem_create_dump(dmem_create_dump),
                       .dmem_out_byte_select(dmem_out_byte_select),
                       .force_stall_in_decode(force_stall_in_decode),
                       .flags(flags), 
                       .alu_carry_in(alu_carry_in),
                       .save_new_pc_from_dmem_out(save_new_pc_from_dmem_out));

  rf register_file (.a0(rf_read_0), .a1(rf_read_1), .write_reg(rf_write_reg), .data_in(rf_data_in), .we(rf_write_enable), .q0(rf_out_0), .q1(rf_out_1), .clk(clk), .rst(rst));

  // Execute
  alu alu (.a(alu_input_0), .b(alu_input_1), .func(alu_ctrl), .c_in(alu_carry_in), .out(alu_out), .neg(alu_neg), .zero(alu_zero), .ovfl(alu_ovfl), .c_out(alu_c_out));

  assign newflags = {alu_neg, alu_zero, alu_c_out, alu_ovfl};

  // Mem
  byte_addressable_memory dmem(.data_out(dmem_out),
                               .data_in(rf_out_1),
                               .addr(alu_out[31:0]),
                               .byte_enable(dmem_byte_enable),
                               .wr(dmem_write_enable),
                               .createdump(dmem_create_dump),
                               .clk(clk),
                               .rst(rst));

  always @ (*)
    case(dmem_out_byte_select)
      2'b00: begin
        shifted_dmem_out = dmem_out;
      end
      2'b01: begin
        shifted_dmem_out = {8'b0, dmem_out[31:8]};
      end
      2'b10: begin
        shifted_dmem_out = {16'b0, dmem_out[31:16]};
      end
      2'b11: begin
        shifted_dmem_out = {24'b0,dmem_out[31:24]};
      end
      default: begin
        shifted_dmem_out = dmem_out;
      end
    endcase

  // Writeback
  always @ (*)
    case(rf_data_in_select)
      2'b00: begin
        rf_data_in = shifted_dmem_out;
      end
      2'b01: begin
        rf_data_in = rf_out_0;
      end
      2'b10: begin
        rf_data_in = alu_out;
      end
      2'b11: begin
        rf_data_in = immediate;
      end
      default: begin
        rf_data_in = alu_out;
      end
    endcase



endmodule
