
`timescale 1us/1us

module proc_tb();
  reg clk,rst;
  wire [7:0] gpio;
  wire stall;
  integer inst_count, cycle_count;
  integer trace_file;
  integer i;
  chip c (.clk(clk),.rst(rst),.gpio(gpio));

  initial begin
    $dumpfile("proc_tb.vcd");
    trace_file = $fopen("verilogsim.trace");
    inst_count = 0;
    cycle_count = 0;
    $dumpvars;


    // Needed to see the registers
    for(i = 0; i <= 14; i = i + 1) begin
      $dumpvars(1, c.cpu.register_file.r[i]);
    end


    clk = 0;
    rst = 0;

    // Reset the register file
    #2;
    rst = 1;
    #10;
    rst = 0;

    #35000;
    $display("Instruction Count = %d, cycle Count = %d CPI = %f", inst_count, cycle_count, (1.0 * cycle_count) / (1.0 * inst_count));
    $finish;
  end

  always
    #5 clk = ~clk;


  // CPU trace used to compare against gdb for correctness
  assign stall = c.cpu.decode_logic.force_stall_in_decode;
  always @ (posedge clk) begin
    cycle_count = cycle_count + 1;
    if(!rst) begin // Don't log anything when CPU is being reset
      if(!stall) begin
        inst_count = inst_count + 1;
        $fdisplay(trace_file, "---------------------------");
        $fdisplay(trace_file, "PC: %08x", c.cpu.pc);
        $fdisplay(trace_file, "R0: %08x", c.cpu.register_file.r[0]);
        $fdisplay(trace_file, "R1: %08x", c.cpu.register_file.r[1]);
        $fdisplay(trace_file, "R2: %08x", c.cpu.register_file.r[2]);
        $fdisplay(trace_file, "R3: %08x", c.cpu.register_file.r[3]);
        $fdisplay(trace_file, "R4: %08x", c.cpu.register_file.r[4]);
        $fdisplay(trace_file, "R5: %08x", c.cpu.register_file.r[5]);
        $fdisplay(trace_file, "R6: %08x", c.cpu.register_file.r[6]);
        $fdisplay(trace_file, "R7: %08x", c.cpu.register_file.r[7]);
        $fdisplay(trace_file, "R8: %08x", c.cpu.register_file.r[8]);
        $fdisplay(trace_file, "R9: %08x", c.cpu.register_file.r[9]);
        $fdisplay(trace_file, "R10: %08x", c.cpu.register_file.r[10]);
        $fdisplay(trace_file, "R11: %08x", c.cpu.register_file.r[11]);
        $fdisplay(trace_file, "R12: %08x", c.cpu.register_file.r[12]);
        $fdisplay(trace_file, "R13: %08x", c.cpu.register_file.r[13]);
        $fdisplay(trace_file, "R14: %08x", c.cpu.register_file.r[14]);
      end
    end
  end

endmodule

