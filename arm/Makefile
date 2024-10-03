
EXEFILE := proc_tb

proc_tb.vcd: proc_tb
	./$(EXEFILE)


proc_tb: rf.v alu.v proc.v proc_tb.v control.v
	iverilog -Wall -o $(EXEFILE) alu.v byte_addressable_memory.v chip.v conditional_branch.v control.v proc.v push_fsm.v proc_tb.v



run:
	gtkwave $(EXEFILE).vcd

clean:
	rm -f $(EXEFILE)
