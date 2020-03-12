vlib work
vlog  SimpleDualPortRAM_generic.v
vlog  ShiftRegisterRAM_generic.v
vlog  compression_hdl_lowpower.v

vlog  ../my_testbench_fpga.v
vsim -novopt work.my_testbench

add wave -noupdate -expand -group clock&reset -color Gold :my_testbench:clk
add wave -noupdate -expand -group clock&reset -color Gold :my_testbench:resetx
add wave -noupdate -expand -group clock&reset -color Gold :my_testbench:enb
add wave -noupdate -radix decimal -expand -group pointer -color {Medium Aquamarine} :my_testbench:h_count_delay
add wave -noupdate -radix decimal -expand -group pointer -color {Medium Aquamarine} :my_testbench:v_count_delay
add wave -noupdate -radix decimal -expand -group pointer -color {Medium Aquamarine} :my_testbench:pixel_count_delay
add wave -noupdate -expand -group control_signals -color Coral :my_testbench:hStart_delay
add wave -noupdate -expand -group control_signals -color Coral :my_testbench:hEnd_delay
add wave -noupdate -expand -group control_signals -color Coral :my_testbench:vStart_delay
add wave -noupdate -expand -group control_signals -color Coral :my_testbench:vEnd_delay
add wave -noupdate -expand -group control_signals -color Coral :my_testbench:valid_delay
add wave -noupdate -radix unsigned -expand -group control_signals -color Coral :my_testbench:mode

add wave -noupdate -radix unsigned -expand -group fileIO -color {Pale Green} :my_testbench:pixelin
add wave -noupdate -radix unsigned -expand -group fileIO -color {Pale Green} :my_testbench:pixelin_ram
add wave -noupdate -expand -group fileIO -color {Pale Green} :my_testbench:fp_pixelin
add wave -noupdate -expand -group fileIO -color {Pale Green} :my_testbench:status_pixelin
add wave -noupdate -radix decimal -expand -group fileIO -color {Pale Green} :my_testbench:pixelin_addr


add wave -noupdate -expand -group bitstream_output -color {Cornflower Blue} :my_testbench:bitstreamready
add wave -noupdate -expand -group bitstream_output -color {Cornflower Blue} -radix decimal :my_testbench:bitstreamlengt
add wave -noupdate -expand -group bitstream_output -color {Cornflower Blue} :my_testbench:subimageindexo
add wave -noupdate -expand -group bitstream_output -color {Cornflower Blue} :my_testbench:bitstreamoutpu

add wave -noupdate -expand -group control_output -color Gray90 :my_testbench:hstartoutput
add wave -noupdate -expand -group control_output -color Gray90 :my_testbench:hendoutput
add wave -noupdate -expand -group control_output -color Gray90 :my_testbench:vstartoutput
add wave -noupdate -expand -group control_output -color Gray90 :my_testbench:vendoutput
add wave -noupdate -expand -group control_output -color Gray90 :my_testbench:validoutput

add wave -noupdate -expand -group debug_signals -color {Slate Blue} :my_testbench:ceout
add wave -noupdate -expand -group debug_signals -color {Slate Blue} -radix decimal :my_testbench:psdout

add wave -noupdate -radix decimal -expand -group pointer_decompress -color Sienna :my_testbench:pixel_count_dec
add wave -noupdate -radix decimal -expand -group pointer_decompress -color Sienna :my_testbench:h_count_dec
add wave -noupdate -radix decimal -expand -group pointer_decompress -color Sienna :my_testbench:v_count_dec


configure wave -namecolwidth 330
configure wave -valuecolwidth 208
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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

run 6700000ns
quit
