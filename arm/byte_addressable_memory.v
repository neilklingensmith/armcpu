`include "bytememory.v"

module byte_addressable_memory(data_out, data_in, addr, byte_enable, wr, createdump, clk, rst);

   output [31:0] data_out;
   input  [31:0] data_in;
   input  [31:0] addr;
   input  [3:0] byte_enable;
   input        wr;
   input        createdump;
   input        clk;
   input        rst;


   bytememory byte_0_mem(data_out[7:0],   data_in[7:0],   addr[31:0],   byte_enable[0], wr, createdump, clk, rst);
   bytememory byte_1_mem(data_out[15:8],  data_in[15:8],  addr[31:0]+1, byte_enable[1], wr, createdump, clk, rst);
   bytememory byte_2_mem(data_out[23:16], data_in[23:16], addr[31:0]+2, byte_enable[2], wr, createdump, clk, rst);
   bytememory byte_3_mem(data_out[31:24], data_in[31:24], addr[31:0]+3, byte_enable[3], wr, createdump, clk, rst);

endmodule
