
EXEFILE := proc_tb

proc_tb.vcd: proc_tb
	./$(EXEFILE)


proc_tb: rf.v alu.v proc.v proc_tb.v control.v
	iverilog -Wall -o $(EXEFILE) proc_tb.v



run:
	gtkwave $(EXEFILE).vcd

clean:
	rm -f $(EXEFILE)
