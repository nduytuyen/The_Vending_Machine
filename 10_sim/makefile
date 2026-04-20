# Author: Hai Cao
# Copyright 2024

.PHONY: sim
sim:
	@xrun -access +rwc -f ./flist

.PHONY: wave
wave:
	@(simvision wave.shm &)


.PHONY: gui
gui:
	@xrun -gui -access +rwc -f ./flist -input restore.tcl


.PHONY: clean
clean:
	@echo "-> CLEAN"
	@rm -rf x* *.vcd *.shm *.log

.PHONY: create
create:
	@rm -f flist
	@echo "-> DANG TAO FLIST CHO MOI TRUONG OOP..."
	@echo "-sv" >> flist
	@echo "-timescale 1ns/100ps" >> flist
	@echo "+incdir+../" >> flist
	@echo "" >> flist
	@echo "# CHI BIEN DICH CAC TOP-LEVEL FILES" >> flist
	@echo "../00_src/vending_machine.sv" >> flist
	@echo "../01_bench/tbench.sv" >> flist
	@echo "-> DA TAO XONG FLIST CHUAN!"
