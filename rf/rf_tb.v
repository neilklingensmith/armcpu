
`timescale 100us/10us
`include "rf.v"


module rf_tb();

  reg [31:0] data_in;
  reg [2:0] a0, a1, write_reg;
  reg  we, clk, rst;
  wire [31:0] q0, q1;
  integer i;
  integer result;
  integer in1;
  integer in2;
  integer sum;

  rf rf_under_test( .a0(a0), .a1(a1), .write_reg(write_reg), .data_in(data_in), .we(we), .q0(q0), .q1(q1), .clk(clk), .rst(rst));

  initial begin
    $dumpfile("rf_tb.vcd");
    $dumpvars;

    // Needed to see the registers
    for(i = 0; i < 8; i = i + 1) begin
      $dumpvars(1, rf_under_test.r[i]);
    end

    clk = 0;
    rst = 0;
    we = 0;
    write_reg = 3'b0;
    a0 = 3'b0;
    a1 = 3'b0;

    // Reset the register file
    #2;
    rst = 1;
    #10;
    rst = 0;



    for (i=0; i<600; i=i+1)
    begin
      a0 = 3'b000; a1 = 3'b000; we = 1; write_reg = 3'b000; data_in = 32'hfffffffe; #5;
      a0 = 3'b000; a1 = 3'b000; we = 1; write_reg = 3'b001; data_in = 32'hffff0000; #5;
      a0 = 3'b000; a1 = 3'b000; we = 1; write_reg = 3'b010; data_in = 32'h0000ffff; #5;
      a0 = 3'b001; a1 = 3'b010; we = 1; write_reg = 3'b000; data_in = 32'hfffffffe; #5;
      $finish;
    end
  end

  always
    #5 clk = ~clk;

endmodule


