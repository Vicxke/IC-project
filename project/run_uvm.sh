vlog -sv -timescale 1ns/1ns \
        +incdir+uvc/clock_uvc+uvc/reset_uvc+uvc/execution_stage_uvc+Execution_Stage/tb \
        Execution_Stage/dut/common.sv \
        uvc/clock_uvc/clock_if.sv uvc/reset_uvc/reset_if.sv uvc/execution_stage_uvc/execution_stage_if.sv \
        Execution_Stage/dut/execute_stage.sv Execution_Stage/dut/alu.sv Execution_Stage/tb/tb_pkg.sv Execution_Stage/tb/tb_top.sv
vsim  -i work.tb_top -sv_seed 7979700 -coverage +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_HIGH +UVM_TESTNAME=basic_test