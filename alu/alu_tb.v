


`timescale 1ms/10us
`include "alu.v"

module alu_tb();

  reg [31:0] a;
  reg [31:0] b;
  reg [2:0] func;
  wire [31:0] out;
  wire cout;
  integer i;
  integer result;
  integer in1;
  integer in2;
  integer sum;
  alu alu_under_test(a,b, func, out, cout);

  initial begin

    // Test the + function
    for (i=0; i<600; i=i+1)
        begin
        a = $urandom % 32'hffffffff;
        b = $urandom % 32'hffffffff;
        func = `ALU_ADD_FUNCTION;
        #2;

        result = out;
        in1 = a;
        in2 = b;
        sum = a+b;
        $display("a = %x b = %x out = %x sum = %x", a, b, out, sum);

        if (result != (in1+in2))
        begin
          $display("ERROR!!!");
          $finish;
        end
    end
    $finish;
  end

endmodule
