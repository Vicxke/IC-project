//------------------------------------------------------------------------------
//
// This module is a top-level module for the TB with serial data to parallel  DUT
//
// It instantiates all of the uVC interface instances and connects them to the RTL top.
// It also initializes the UVM test environment and runs the test and
// it creates the default top-level test configuration.
//
// The testbench uses the following uVC interfaces:
// - CLOCK IF: Generates a system clock.
// - RESET IF: Generates the reset signal.
// - SERIAL_DATA IF: Generate parallel data to the DUT input interface
// - PARALLEL_DATA IF: Passes the DUT output infterface to parallel data uVC
//
//------------------------------------------------------------------------------
module tb_top;

    // Include basic packages
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Include optional packages
    import tb_pkg::*;

    // uVC TB signal variables
    logic tb_clock;
    logic tb_reset_n;

    // Instantiation of CLOCK uVC interface signal

    clock_if  i_clock_if();
    assign tb_clock = i_clock_if.clock;

    // Instantiation of RESET uVC interface signal
    reset_if  i_reset_if(.clk(tb_clock));
    assign tb_reset_n = i_reset_if.reset_n;

    // Instantiate execution_stage interface and connect to the DUT
    execution_stage_if i_execute_if(.clk(tb_clock), .rst_n(tb_reset_n));

    // Instantiation of the execute_stage RTL DUT
    execute_stage dut_execute_stage (
        .clk(tb_clock),
        .reset_n(tb_reset_n),
        .data1(i_execute_if.data1),
        .data2(i_execute_if.data2),
        .immediate_data(i_execute_if.immediate_data),
        .control_in(i_execute_if.control_in),
        .compflg_in(i_execute_if.compflg_in),
        .program_counter(i_execute_if.program_counter),
        .control_out(i_execute_if.control_out),
        .alu_data(i_execute_if.alu_data),
        .memory_data(i_execute_if.memory_data),
        .overflow_flag(i_execute_if.overflow_flag),
        .compflg_out(i_execute_if.compflg_out)
    );

    // Initialize TB configuration
    initial begin
        top_config  m_top_config;
        // Create TB top configuration and store it into UVM config DB.
        m_top_config = new("m_top_config");
        uvm_config_db #(top_config)::set(null,"tb_top","top_config", m_top_config);
        // Save all virtual interface instances into configuration
        m_top_config.m_clock_config.m_vif = i_clock_if;
        m_top_config.m_reset_config.m_vif = i_reset_if;
        // Save execution_stage interface instance into top config
        m_top_config.m_execution_stage_config.m_vif = i_execute_if;
    end

    // Start UVM test_base environment
    initial begin // only one run valid
        //run_test("ExStage_00"); 
        // run_test("ExStage_01");
        // run_test("ExStage_02");
        run_test("ExStage_03");
        // run_test("ExStage_04");
        // run_test("ExStage_05");

    end

endmodule
