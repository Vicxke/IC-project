//------------------------------------------------------------------------------
// decode_stage interface
//------------------------------------------------------------------------------
interface decode_stage_if (input logic clk, input logic rst_n);

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

    // outputs from dut (made available to monitors/scoreboard)
    logic [5:0] reg_rd_id;
    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic [4:0] rs1_id;
    logic [4:0] rs2_id;
    logic [31:0] immediate_data;
    control_type control_signals;
    logic        select_target_pc;
    logic        resolve;
    logic [31:0] calculated_target_pc;
    logic        squash_after_J;
    logic        squash_after_JALR;
    logic        compflg_out;

endinterface : decode_stage_if
