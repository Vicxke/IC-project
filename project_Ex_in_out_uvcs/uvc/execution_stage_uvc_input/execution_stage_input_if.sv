//------------------------------------------------------------------------------
// execute_stage interface
//------------------------------------------------------------------------------
interface execution_stage_input_if (input logic clk, input logic rst_n);

    // Import DUT common typedefs (control_type, encodings, etc.)
    import common::*;

    // inputs to dut.
    logic [31:0] data1;
    logic [31:0] data2;
    logic [31:0] immediate_data;
    control_type control_in;
    logic compflg_in;
    logic [31:0] program_counter_in;


endinterface : execution_stage_input_if
