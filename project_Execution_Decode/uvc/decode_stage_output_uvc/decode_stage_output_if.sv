//------------------------------------------------------------------------------
// decode_stage interface
//------------------------------------------------------------------------------
interface decode_stage_output_if (input logic clk, input logic rst_n);

    // Import DUT common typedefs (control_type, encodings, etc.)
    import common::*;

    // outputs to dut. onl the signals that are not checked in the execution stage
    logic [5:0]  reg_rd_id;
    logic [4:0]  rs1_id;
    logic [4:0]  rs2_id;
    logic        resolve;
    logic [31:0] select_target_pc;
    logic        squash_after_J;
    logic        squash_after_JALR;

endinterface : decode_stage_output_if
