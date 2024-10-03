


module directmapped(clk, rst, addr, din, dout, we);

  input wire clk, rst;
  input wire [31:0]addr;
  input wire [31:0]din;
  input wire we;
  output wire [31:0]dout;

  parameter LOG_NUM_BYTES_PER_LINE = 5;
  parameter LOG_NUM_LINES = 9;
  parameter NUM_BYTES_PER_LINE = (1<<LOG_NUM_BYTES_PER_LINE);
  parameter NUM_LINES = (1<<LOG_NUM_LINES);

  reg valid[0:NUM_LINES-1];
  reg [32-LOG_NUM_LINES-LOG_BYTES_PER_LINE:0]tag[0:NUM_LINES-1];
  reg data [7:0][0:NUM_LINES-1][0:NUM_BYTES_PER_LINE-1];


  always @(posedge clk) begin
    if(rst) begin
      for (i=0; i<NUM_LINES; i=i+1)  begin
        valid[i] = 1'b0;
        tag[i] = 0;
        for (j=0; j<NUM_BYTES_PER_LINE; j=j+1)  begin
          data[i][j] = 8'b0;
        end
      end
    end
  end

endmodule



