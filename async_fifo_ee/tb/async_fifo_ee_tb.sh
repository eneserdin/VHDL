ghdl -a ../async_fifo_ee.vhd
ghdl -a async_fifo_ee_tb.vhd
ghdl -e async_fifo_ee_tb
ghdl -r async_fifo_ee_tb --stop-time=15000ns --wave=async_fifo_ee_tb.ghw --vcd=async_fifo_ee_tb.vcd
