set RV_ROOT "D:/Work/test_pr/ibex-sys/PLD/source/ibex-master"
set SRC     "D:/Work/test_pr/ibex-sys/PLD/source/peripherial/uart_module"

alias c "

	vlog -O0 +acc $SRC/UART.sv
	vlog -O0 +acc $SRC/UART_tb.sv

"
alias s "
	vopt +acc -novopt -O0 work.UART_tb -o UART_tb_opt
	vsim  work.UART_tb_opt -t 1ps
	do D:/Work/test_pr/ibex-sys/PLD/ms/wave_UART_tb.do
	
	run 1 us
	wave zoom full
	"
