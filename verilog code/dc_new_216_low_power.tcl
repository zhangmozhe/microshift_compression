suppress_message {LINT-32 LINT-33}
#sh mkdir WORK
define_design_lib WORK -path ./WORK

# scripts of step 1, please list all file in an order from the sub-modules to the top module
analyze -library WORK -format verilog {../rtl_new_216_low_power/SimpleDualPortRAM_generic.v}
analyze -library WORK -format verilog {../rtl_new_216_low_power/ShiftRegisterRAM_generic.v}
analyze -library WORK -format verilog {../rtl_new_216_low_power/compression_hdl_lowpower.v}


# scripts of step 2, check the top module name before running
elaborate compression_hdl_lowpower -architecture verilog -library DEFAULT -update
current_design compression_hdl_lowpower

# scripts of step 3: link
link

# scripts of step 4: check design
check_design > ./rpt_new_216_lower_power/check_design.txt

# scripts of step 5: save design to ddc format before synthesis
write -hierarchy -format ddc -output ../ddc/compression_hdl_linked.ddc

# scripts of step 6: set input driving
change_selection [all_inputs]
set_drive 0 [all_inputs]

# scripts of step 7: set output capacitance load & fanout load
change_selection [all_outputs]
set_load 1 [all_outputs]

# scripts of step 8, if there is a clock signal in your design, please append "{clk(or the name of the clock you use)}" at the end
# define clock of 100MHz, 50% duty cycle
create_clock -name "clk" -period 10 -waveform { 0 5 } {clk} 
set_clock_uncertainty -setup 0.01 "clk"
set_clock_latency -max 0.01 "clk"
set_clock_transition -max 0.05 "clk"
set_dont_touch_network "clk"
set_ideal_network "clk"


# scripts of step 9: set input delay
change_selection [all_inputs]
set_input_delay -clock clk -add_delay -max -rise 1.6 [all_inputs]
set_input_delay -clock clk -add_delay -max -fall 1.6 [all_inputs]
set_input_delay -clock clk -add_delay -min -rise 0.2 [all_inputs]
set_input_delay -clock clk -add_delay -min -fall 0.2 [all_inputs]

# scripts of step 10: set output delay
change_selection [all_outputs]
set_output_delay -clock clk -add_delay -max -rise 1.6 [all_outputs]
set_output_delay -clock clk -add_delay -max -fall 1.6 [all_outputs]
set_output_delay -clock clk -add_delay -min -rise 0.2 [all_outputs]
set_output_delay -clock clk -add_delay -min -fall 0.2 [all_outputs]

# operand isolation
#set do_operand_isolation true
#set_operand_isolation_style -logic adaptive -verbose
#set_operand_isolation_slack 0.3 -weight 1

# power related
#saif_map -start
#set_power_prediction
#read_saif -input ../rtl_new/activity.saif -instance_name compression_hdl_lowpower_tb/u_compression_hdl_lowpower -verbose -auto_map_names


# scripts of step 11: specify wire load model
#set_wire_load_model -name csm18_wl30 -library scx_csm_18ic_tt_1p8v_25c
set auto_wire_load_selection "true"

# scripts of step 12: set optimization goal
# set_max_delay 0 -from [all_inputs] -to [all_outputs]
set_max_area 0
set_max_dynamic_power 0

# scripts of step 13
write -hierarchy -format ddc -output ../ddc/compression_hdl_constrained.ddc

# scripts of step 14
set verilogout_no_tri true
set_fix_multiple_port_nets -all -buffer_constants
compile_ultra -exact_map -gate_clock -area_high_effort_script -num_cpus 12
set_fix_hold "clk"
compile -incrementals

# scripts of step 15, you can do step 25 in design vision using the *.ddc file you save in this step
write -hierarchy -format ddc -output ../ddc/compression_hdl_compiled.ddc

# scripts of step 16(report timing, area and power)
report_timing -nworst 3 -max_paths 3 > ./rpt_new_216_lower_power/timing.txt
report_area  -hierarchy > ./rpt_new_216_lower_power/area.txt
report_power  > ./rpt_new_216_lower_power/power.txt
report_resources -hierarchy > ./rpt_new_216_lower_power/resource.txt

# scripts of step 17: export the synthesized design in vhdl 
#change_names -rule vhdl -hierarchy
#write -format vhdl -hierarchy -output ../net/compression_fifo_compiled.vhd

# scripts of step 18: export the synthesized design in verilog
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output ../net_new_216_low_power/compression_hdl_compiled.v

# scripts of step 19: export the sdf file
write_sdf ../net_new_216_low_power/compression_hdl.sdf

# scripts of step 20: export the sdc file
write_sdc ../net_new_216_low_power/compression_hdl.sdc

#quit
