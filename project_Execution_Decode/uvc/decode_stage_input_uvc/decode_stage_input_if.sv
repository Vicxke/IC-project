//------------------------------------------------------------------------------
// decode_stage interface
//------------------------------------------------------------------------------
interface decode_stage_input_if (input logic clk, input logic rst_n);

    // Import DUT common typedefs (control_type, encodings, etc.)
    import common::*;

    // inputs to dut.
    instruction_type instruction;
    logic [31:0] pc;
    logic compflg;
    logic write_en;
    logic [4:0] write_id;
    logic [31:0] write_data;
    logic [31:0] mux_data1;
    logic [31:0] mux_data2;

    logic instr_valid;


endinterface : decode_stage_input_if
