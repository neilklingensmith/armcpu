


module rf(a0, a1, write_reg, data_in, we,q0, q1, clk, rst);

  input [3:0] a0, a1, write_reg;
  input [31:0] data_in;
  output [31:0] q0, q1;
  input clk, rst, we;

  reg [31:0] r[0:14];

  always @ (posedge clk) begin
    if (rst) begin
      r[0] <= 31'b0;
      r[1] <= 31'b0;
      r[2] <= 31'b0;
      r[3] <= 31'b0;
      r[4] <= 31'b0;
      r[5] <= 31'b0;
      r[6] <= 31'b0;
      r[7] <= 31'b0;
      r[8] <= 31'b0;
      r[9] <= 31'b0;
      r[10] <= 31'b0;
      r[11] <= 31'b0;
      r[12] <= 31'b0;
      r[13] <= 31'b0;
      r[14] <= 31'b0;
    end

    if (we) begin
      r[write_reg] <= data_in;
    end
  end

  assign q0 = r[a0];
  assign q1 = r[a1];

endmodule

