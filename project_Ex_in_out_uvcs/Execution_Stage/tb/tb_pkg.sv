//------------------------------------------------------------------------------
// Testbench package.
//
// The tb_pkg package provides a collection of files and
// uVCs that are used for testbench development
//
// It includes:
// - Clock uVC
// - Reset uVC
// - Serial Data uVC
// - Parallel Data uVC
// - Test Environment
// - Scoreboard
// - Tests
//
// The package also imports the UVM package and includes
// the necessary UVM macros to support UVM-based testbenches
//
//------------------------------------------------------------------------------
`timescale 1ns/1ns 
package tb_pkg;
    // Import from UVM package
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // Include files from the clock uVC
    `include "clock_config.svh"
    `include "clock_driver.svh"
    `include "clock_agent.svh"
    // Include files from the reset uVC
    `include "reset_seq_item.svh"
    `include "reset_seq.svh"
    `include "reset_config.svh"
    `include "reset_driver.svh"
    `include "reset_monitor.svh"
    `include "reset_agent.svh"
    // Include files from the execution_stage_input uVC
    `include "execution_stage_input_seq_item.svh"
    `include "execution_stage_input_seq.svh"
    `include "execution_stage_input_config.svh"
    `include "execution_stage_input_driver.svh"
    `include "execution_stage_input_monitor.svh"
    `include "execution_stage_input_agent.svh"
    // Include files from the execution_stage_output uVC
    `include "execution_stage_input_output_seq_item.svh"
    `include "execution_stage_input_output_config.svh"
    `include "execution_stage_input_output_monitor.svh"
    `include "execution_stage_input_output_agent.svh"
    // Include files from the TB
    `include "scoreboard.svh"
    `include "top_config.svh"
    `include "tb_env.svh"
    `include "ExStage_00.svh"
    `include "ExStage_01.svh"
    `include "ExStage_02.svh"
    `include "ExStage_03.svh"
    `include "ExStage_04.svh"
    `include "ExStage_05.svh"
    `include "ExStage_06.svh"
    // `include "ExStage_07.svh"
    `include "basic_test.svh"
endpackage: tb_pkg
