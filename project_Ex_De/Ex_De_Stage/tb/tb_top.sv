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

    // Interfaces
    decode_stage_if    i_decode_if(.clk(tb_clock), .rst_n(tb_reset_n));
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

    // Instantiation of decode_stage RTL DUT
    decode_stage dut_decode_stage (
        .clk(tb_clock),
        .reset_n(tb_reset_n),
        //inputs
        .instruction(i_decode_if.instruction),
        .pc(i_decode_if.pc),
        .compflg(i_decode_if.compflg),
        .write_en(i_decode_if.write_en),
        .write_id(i_decode_if.write_id),
        .write_data(i_decode_if.write_data),
        .mux_data1(i_decode_if.mux_data1),
        .mux_data2(i_decode_if.mux_data2),
        //outputs
        .reg_rd_id(i_decode_if.reg_rd_id),
        .read_data1(i_decode_if.read_data1),
        .read_data2(i_decode_if.read_data2),
        .rs1_id(i_decode_if.rs1_id),
        .rs2_id(i_decode_if.rs2_id),
        .immediate_data(i_decode_if.immediate_data),
        .control_signals(i_decode_if.control_signals),
        .select_target_pc(i_decode_if.select_target_pc),
        .resolve(i_decode_if.resolve),
        .calculated_target_pc(i_decode_if.calculated_target_pc),
        .squash_after_J(i_decode_if.squash_after_J),
        .squash_after_JALR(i_decode_if.squash_after_JALR),
        .compflg_out(i_decode_if.compflg_out)
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
        // Save decode_stage interface instance into top config
        m_top_config.m_decode_stage_config.m_vif = i_decode_if;
    end

    // Start UVM test_base environment
    initial begin // only one run valid
        run_test("ExDeStage_00");
    end

endmodule
