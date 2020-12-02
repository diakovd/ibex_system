set RV_ROOT "D:/Work/test_pr/ibex-sys/PLD/source/ibex-master"
set SRC     "D:/Work/test_pr/ibex-sys/PLD/source/peripherial/Timer"

alias c "

	vlog -O0 +acc $SRC/Timer.sv
	vlog -O0 +acc $SRC/Timer_tb.sv

"
alias s "
	vopt +acc -novopt -O0 work.Timer_tb -o Timer_tb_opt
	vsim  work.Timer_tb_opt -t 1ps
	do D:/Work/test_pr/ibex-sys/PLD/ms/wave_Timer_tb.do
	
	run 1 us
	wave zoom full
	"
