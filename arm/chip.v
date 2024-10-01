


`include "alu.v"
`include "rf.v"
`include "memory2c.v"
`include "control.v"
`include "byte_addressable_memory.v"
`include "control.vh"

`include "proc.v"


module chip(clk, rst, gpio);

  input clk, rst;
  output reg [7:0] gpio;

  wire [31:0] addr, cpu_data_out, cpu_data_in;
  wire io_en;

  proc cpu (.clk(clk),
            .rst(rst),
            .addr(addr),
            .data_out(cpu_data_out),
            .data_in(cpu_data_in),
            .io_en(io_en));

  
  always @ (posedge clk) begin
    if(rst) begin
      gpio <= 8'h0;
    end else if (io_en == 1'b1) begin
      gpio = cpu_data_out[7:0];
    end else begin
      gpio = gpio;
    end
  end



endmodule
