onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /UART_tb/busRD8/data
add wave -noupdate /UART_tb/FCR
add wave -noupdate /UART_tb/ISR
add wave -noupdate /UART_tb/CPUctr/rdata
add wave -noupdate /UART_tb/CPUctr/we
add wave -noupdate /UART_tb/CPUctr/req
add wave -noupdate /UART_tb/CPUctr/rvalid
add wave -noupdate /UART_tb/CPUctr/gnt
add wave -noupdate /UART_tb/CPUctr/err
add wave -noupdate -radix unsigned /UART_tb/CPUdat/addr
add wave -noupdate /UART_tb/CPUdat/wdata
add wave -noupdate /UART_tb/CPUdat/be
add wave -noupdate /UART_tb/UART_inst/Int
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /UART_tb/UART_inst/addr
add wave -noupdate -radix unsigned /UART_tb/UART_inst/wrdata
add wave -noupdate /UART_tb/UART_inst/wr
add wave -noupdate /UART_tb/UART_inst/rd
add wave -noupdate -divider {New Divider}
add wave -noupdate /UART_tb/addError
add wave -noupdate -radix unsigned /UART_tb/TX
add wave -noupdate /UART_tb/RX
add wave -noupdate /UART_tb/UART_inst/state_tx
add wave -noupdate -radix unsigned /UART_tb/UART_inst/BaudRate
add wave -noupdate -radix unsigned /UART_tb/UART_inst/ctr_tx
add wave -noupdate /UART_tb/UART_inst/en_ctr
add wave -noupdate -radix unsigned /UART_tb/UART_inst/ctrW
add wave -noupdate -divider {New Divider}
add wave -noupdate /UART_tb/UART_inst/state_rx
add wave -noupdate -radix unsigned /UART_tb/UART_inst/shiftIN
add wave -noupdate /UART_tb/UART_inst/wr_rx
add wave -noupdate /UART_tb/UART_inst/rd_tx
add wave -noupdate /UART_tb/UART_inst/fifo_tx_inst/wr_en
add wave -noupdate -divider Registers
add wave -noupdate /UART_tb/UART_inst/CR
add wave -noupdate /UART_tb/UART_inst/FCR
add wave -noupdate /UART_tb/UART_inst/TxCnt
add wave -noupdate /UART_tb/UART_inst/RxCnt
add wave -noupdate /UART_tb/UART_inst/ISR
add wave -noupdate -expand /UART_tb/UART_inst/ESR
add wave -noupdate /UART_tb/UART_inst/DLR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {276769 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2625 ns}
