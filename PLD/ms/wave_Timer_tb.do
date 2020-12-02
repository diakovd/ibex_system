onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Timer_tb/Evnt2
add wave -noupdate /Timer_tb/Timer_inst/Evnt2LPF
add wave -noupdate /Timer_tb/Evnt1
add wave -noupdate /Timer_tb/Timer_inst/Evnt1LPF
add wave -noupdate /Timer_tb/Evnt0
add wave -noupdate /Timer_tb/Timer_inst/Evnt0LPF
add wave -noupdate -radix hexadecimal /Timer_tb/CPUctr/rdata
add wave -noupdate /Timer_tb/CPUctr/we
add wave -noupdate /Timer_tb/CPUctr/req
add wave -noupdate /Timer_tb/CPUctr/rvalid
add wave -noupdate /Timer_tb/CPUctr/gnt
add wave -noupdate /Timer_tb/CPUctr/err
add wave -noupdate -radix unsigned /Timer_tb/CPUdat/addr
add wave -noupdate -radix hexadecimal /Timer_tb/CPUdat/wdata
add wave -noupdate /Timer_tb/CPUdat/be
add wave -noupdate /Timer_tb/Timer_inst/Rst
add wave -noupdate /Timer_tb/Timer_inst/Int
add wave -noupdate /Timer_tb/PWM
add wave -noupdate /Timer_tb/Timer_inst/pwmOut
add wave -noupdate -divider Events
add wave -noupdate /Timer_tb/Timer_inst/EvStr
add wave -noupdate /Timer_tb/Timer_inst/EvStp
add wave -noupdate /Timer_tb/Timer_inst/EvCap1
add wave -noupdate /Timer_tb/Timer_inst/EvCap0
add wave -noupdate /Timer_tb/Timer_inst/EvGate
add wave -noupdate /Timer_tb/Timer_inst/EvUpDw
add wave -noupdate /Timer_tb/Timer_inst/TmLoad
add wave -noupdate -divider {Tmr cntr}
add wave -noupdate /Timer_tb/Timer_inst/STT
add wave -noupdate /Timer_tb/Timer_inst/PrdMth
add wave -noupdate /Timer_tb/Timer_inst/OneMth
add wave -noupdate /Timer_tb/Timer_inst/ZeroMth
add wave -noupdate /Timer_tb/Timer_inst/TmLoad
add wave -noupdate /Timer_tb/Timer_inst/TmrClear
add wave -noupdate /Timer_tb/Timer_inst/TmrEn
add wave -noupdate /Timer_tb/Timer_inst/CompMth
add wave -noupdate -divider Registes
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmVal
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmPr
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmPrSh
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmCmp
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmCmpSh
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmCap0
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmCap1
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmCap2
add wave -noupdate -radix hexadecimal /Timer_tb/Timer_inst/TmCap3
add wave -noupdate -expand /Timer_tb/Timer_inst/TCFS
add wave -noupdate /Timer_tb/Timer_inst/TRS
add wave -noupdate -expand /Timer_tb/Timer_inst/TRSt
add wave -noupdate /Timer_tb/Timer_inst/TMS
add wave -noupdate /Timer_tb/Timer_inst/ECR
add wave -noupdate /Timer_tb/Timer_inst/CMC
add wave -noupdate /Timer_tb/Timer_inst/ISR
add wave -noupdate /Timer_tb/Timer_inst/IEC
add wave -noupdate /Timer_tb/Timer_inst/IntCl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14411 ps} 0} {{Cursor 2} {65100 ps} 0}
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
WaveRestoreZoom {14131 ps} {17823 ps}
