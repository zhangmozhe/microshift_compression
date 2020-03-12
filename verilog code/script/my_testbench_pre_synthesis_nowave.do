vlib work
vlog  SimpleDualPortRAM_generic.v
vlog  ShiftRegisterRAM_generic.v
vlog  compression_hdl_lowpower.v
vlog  ../my_testbench_fpga.v
vsim -novopt work.my_testbench

run 6700000ns
quit
