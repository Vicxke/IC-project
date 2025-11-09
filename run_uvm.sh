vlog -sv -timescale 1ns/1ns \
        +incdir+project/uvc/clock_uvc+project/uvc/reset_uvc+project/uvc/execution_stage_uvc+project/files/main_branch \
        project/uvc/clock_uvc/clock_if.sv project/uvc/reset_uvc/reset_if.sv project/uvc/execution_stage_uvc/execution_stage_if.sv \
        project/Execution_Stage/dut/execute_stage.sv project/Execution_Stage/dut/alu.sv project/Execution_Stage/tb/tb_pkg.sv project/Execution_Stage/tb/tb_top.sv
vsim  -i work.tb_top -sv_seed 7979700 -coverage +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=basic_test