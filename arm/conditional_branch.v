

// Condition Codes for Branch and IT instructions. Taken from Table 3-38 on
// page 3-35 of the ARM Architecture Ref Man
`define CC_EQ 4'b0000 // Equal                Z set
`define CC_NE 4'b0001 // Not Equal            Z clear
`define CC_CS 4'b0010 // Carry Set            C set
`define CC_CC 4'b0011 // Carry Clear          C clear
`define CC_MI 4'b0100 // Minus/Negative       N set
`define CC_PL 4'b0101 // Plus/Positive        N clear
`define CC_VS 4'b0110 // Overflow             V set
`define CC_VC 4'b0111 // No overflow          V clear
`define CC_HI 4'b1000 // Unsigned Higher      C set and Z clear
`define CC_LS 4'b1001 // Unsigned Lower/same  C clear or Z set
`define CC_GE 4'b1010 // Signed greater/equal N setand V set or N clear and V clear (N == V)
`define CC_LT 4'b1011 // Signed less than     N set and V clear or N clear and V set (N != V)
`define CC_GT 4'b1100 // Signed greater than  Z clear and either N set and V set or N clear and V clear (Z==0,N==V)
`define CC_LE 4'b1101 // Signed less/equal    Z set or N set and V clear or N clear and V set (Z==1 or N != V)
`define CC_AL 4'b1110 // Always
`define CC_AL2 4'b1111 // Alternative instruction, always



module conditional_branch(instruction_encoding, flags, taken) ;

  input [31:0] instruction_encoding;
  input [3:0] flags;
  output reg taken;

  wire n_flag = flags[3];
  wire z_flag = flags[2];
  wire c_flag = flags[1];
  wire v_flag = flags[0];

// Flags are NZCV0
always @ (*)
  case (instruction_encoding[11:8])
    `CC_EQ: begin
      if (z_flag == 1'b1) begin // Z set
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_NE: begin
      if (z_flag == 1'b0) begin // Z clear
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_CS: begin
      if (c_flag == 1'b1) begin // C set
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_CC: begin
      if (c_flag == 1'b0) begin // C clear
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_MI: begin
      if (n_flag == 1'b1) begin // N set
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_PL: begin
      if (n_flag == 1'b0) begin // N Clear
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_VS: begin
      if (v_flag == 1'b1) begin // V set
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_VC: begin
      if (v_flag == 1'b0) begin // V clear
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_HI: begin
      if ((c_flag == 1'b1) && (z_flag == 1'b0)) begin // C set and Z clear
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_LS: begin
      if ((c_flag == 1'b0) || (z_flag == 1'b1)) begin // C clear or Z set
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_GE: begin
      if (v_flag == n_flag) begin // N == V
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_LT: begin
      if (v_flag != n_flag) begin // N != V
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_GT: begin
      if ((z_flag == 1'b0) && (v_flag == n_flag)) begin // Z == 0, N == V
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_LE: begin
      if ((z_flag == 1'b1) && (v_flag != n_flag)) begin // Z == 1, N != V
        taken = 1;
      end else begin
        taken = 0;
      end
    end
    `CC_AL: begin
        taken = 1;
    end
    `CC_AL2: begin
        taken = 1;
    end
    default: begin
    end
  endcase

endmodule
