//------------------------------------------------------------------------------
// execute_stage interface
//------------------------------------------------------------------------------
interface execution_stage_output_if (input logic clk, input logic rst_n);

    // Import DUT common typedefs (control_type, encodings, etc.)
    import common::*;


    // outputs from dut (made available to monitors/scoreboard)
    //not shure if it should be here
    control_type control_out;
    logic [31:0] alu_data;
    logic [31:0] memory_data;
    logic overflow_flag;
    logic zero_flag;
    logic compflg_out;
    logic [31:0] program_counter;

endinterface : execution_stage_output_if
