# ------------------------------------------------------------
# Compile (vlog)
# ------------------------------------------------------------

vlog -sv -timescale 1ns/1ns \
    +incdir+uvc/clock_uvc \
    +incdir+uvc/reset_uvc \
    +incdir+uvc/execution_stage_uvc_input \
    +incdir+uvc/execution_stage_uvc_output \
    \
    Ex_De_Stage/dut/alu.sv \
    Ex_De_Stage/dut/common.sv \
    Ex_De_Stage/dut/execute_stage.sv \
    \
    uvc/clock_uvc/clock_if.sv \
    uvc/reset_uvc/reset_if.sv \
    uvc/execution_stage_uvc_input/execution_stage_input_if.sv \
    uvc/execution_stage_uvc_output/execution_stage_output_if.sv \
    \
    +incdir+Ex_De_Stage/tb \
    Ex_De_Stage/tb/tb_pkg.sv \
    Ex_De_Stage/tb/tb_top.sv

# ------------------------------------------------------------
# Simulation (vsim)
# ------------------------------------------------------------

vsim -i work.tb_top \
    -sv_seed 7979700 \
    -coverage \
    +UVM_NO_RELNOTES \
    -do "run -all"


# vsim  -i work.tb_top -sv_seed 7979700 -coverage +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=basic_test