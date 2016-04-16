ghdl -a ../../fifo_ee/fifo_ee.vhd
ghdl -a ../fwft_fifo_ee.vhd
ghdl -a fwft_fifo_ee_tb.vhd
ghdl -e fwft_fifo_ee_tb
ghdl -r fwft_fifo_ee_tb --stop-time=400000ns --wave=fwft_fifo_ee_tb.ghw
