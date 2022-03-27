set RV_ROOT "../../ibex/rtl"
set SRC     "../source"
set VIVpr   "../VIVpr"
set QUApr   "../qua_pr"

alias c "
	vlog -O0 +acc $RV_ROOT/ibex_pkg.sv
	vlog -O0 +acc $RV_ROOT/ibex_tracer_pkg.sv
	
	vlog -O0 +acc $RV_ROOT/ibex_core.sv
	vlog -O0 +acc $RV_ROOT/ibex_if_stage.sv 
	vlog -O0 +acc $RV_ROOT/ibex_id_stage.sv
	vlog -O0 +acc $RV_ROOT/ibex_ex_block.sv
	vlog -O0 +acc $RV_ROOT/ibex_load_store_unit.sv
	vlog -O0 +acc $RV_ROOT/ibex_cs_registers.sv
	vlog -O0 +acc $RV_ROOT/ibex_pmp.sv
	vlog -O0 +acc $RV_ROOT/ibex_prefetch_buffer.sv
	vlog -O0 +acc $RV_ROOT/ibex_alu.sv
	vlog -O0 +acc $RV_ROOT/ibex_compressed_decoder.sv
	vlog -O0 +acc $RV_ROOT/ibex_controller.sv
	vlog -O0 +acc $RV_ROOT/ibex_core_tracing.sv
	vlog -O0 +acc $RV_ROOT/ibex_decoder.sv
	vlog -O0 +acc $RV_ROOT/ibex_fetch_fifo.sv
	vlog -O0 +acc $RV_ROOT/ibex_multdiv_fast.sv
	vlog -O0 +acc $RV_ROOT/ibex_multdiv_slow.sv
	vlog -O0 +acc $RV_ROOT/ibex_register_file_ff.sv
	vlog -O0 +acc $RV_ROOT/ibex_register_file_latch.sv
	vlog -O0 +acc $RV_ROOT/prim_clock_gating.sv

	vlog -O0 +acc $SRC/ram/ram_1p.sv 
	vlog -O0 +acc $SRC/ram/rom_1p.sv +define+Sim
	vlog -O0 +acc $SRC/bus_mux/bus_mux.sv

	#vlog -O0 +acc  $VIVpr/ibex_core_sys_tst.srcs/sources_1/ip/ROM/sim/ROM.v

	#vlog -O0 +acc  $VIVpr/ibex_core_sys_tst.srcs/sources_1/ip/RAM/sim/RAM.v
	#vlog -O0 +acc  $VIVpr/ibex_core_sys_tst.srcs/sources_1/ip/RAM/simulation/blk_mem_gen_v8_4.v
	#vlog -O0 +acc  $VIVpr/ibex_core_sys_tst.srcs/sources_1/ip/RAM/simulation/blk_mem_gen_v8_4.v
	#vlog -O0 +acc  $VIVpr/ibex_core_sys_tst.srcs/sources_1/ip/RAM/RAM_sim_netlist.v
	#vlog -O0 +acc  $VIVpr/ibex_core_sys_tst.srcs/sources_1/ip/RAM/RAM_stub.v	
	
	vlog -O0 +acc $SRC/peripherial/IOmodule/IOmodule.sv
	vlog -O0 +acc $SRC/peripherial/uart_module/UART.sv
	vlog -O0 +acc $SRC/peripherial/uart_module/asinhFIFOa_sim.sv

	vlog -O0 +acc $SRC/peripherial/Timer/Timer.sv
	vlog -O0 +acc $SRC/mtimer/mtimer.sv
	
	vlog -O0 +acc $SRC/peripherial/BootLoader/BootLoader.sv
	vlog -O0 +acc $SRC/peripherial/BootLoader/BootLoader_tb.sv

	vlog -O0 +acc $SRC/peripherial/LED8x4/LED8x4.sv
	vlog -O0 +acc $SRC/peripherial/LED8x4/LED8x8.sv
	
	vlog -O0 +acc $SRC/mtimer/mtimer.sv
	
	vlog -O0 +acc $SRC/ibex_sys.sv +define+Sim 
	vlog -O0 +acc $SRC/tb/ibex_sys_tb.sv 
	vlog -O0 +acc $VIVpr/ibex_sys_atrix7.sv
	
	vlog -O0 +acc $QUApr/ibex_sys_cycloneIV.sv
	vlog -O0 +acc $QUApr/FIFOa.v
	vlog -O0 +acc $QUApr/PLL.v
	vlog -O0 +acc $QUApr/RAM.v
	vlog -O0 +acc $QUApr/RAM_instr.v
	vlog -O0 +acc $QUApr/RAMdp.v

"
alias s "
	vopt +acc -novopt -O0 work.ibex_sys_tb -o ibex_sys_tb_opt
	vsim  work.ibex_sys_tb_opt -t 1ps
	#do wave_ibex_sys_Cyclone.do
	do wave_ibex_sys_Atrix.do
	
	run 1 us
	wave zoom full
	"
