create_clock -period 67.820 -name clk14_745 [get_ports Clk_14_7456MHz]
set_false_path -from [get_ports sys_rst_n]

set_property PACKAGE_PIN V13 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]

set_property PACKAGE_PIN A16 [get_ports Clk_14_7456MHz]
set_property PACKAGE_PIN V2 [get_ports TX]
set_property PACKAGE_PIN W2 [get_ports RX]

set_property IOSTANDARD LVCMOS33 [get_ports Clk_14_7456MHz]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports TX]
set_property IOSTANDARD LVCMOS33 [get_ports RX]