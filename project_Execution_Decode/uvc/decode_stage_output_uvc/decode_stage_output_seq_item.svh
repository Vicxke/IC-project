import common::*;

class decode_stage_output_seq_item extends uvm_sequence_item;

    // DUT outputs
    logic [5:0]  reg_rd_id;
    logic [4:0]  rs1_id;
    logic [4:0]  rs2_id;
    logic        resolve;
    logic        select_target_pc;
    logic        squash_after_J;
    logic        squash_after_JALR;
    logic       instr_valid;

    // monitor helper flag
    bit monitor_data_valid;

    // Fields for printing/packing
    `uvm_object_utils_begin(decode_stage_output_seq_item)
    `uvm_field_int(reg_rd_id, UVM_ALL_ON)
    `uvm_field_int(rs1_id, UVM_ALL_ON)
    `uvm_field_int(rs2_id, UVM_ALL_ON)
    `uvm_field_int(resolve, UVM_ALL_ON)
    `uvm_field_int(select_target_pc, UVM_ALL_ON)
    `uvm_field_int(squash_after_J, UVM_ALL_ON)
    `uvm_field_int(squash_after_JALR, UVM_ALL_ON)

    
    // monitor_data_valid intentionally not registered
    `uvm_object_utils_end

    // Constructor
    function new(string name = "decode_stage_output_seq_item");
        super.new(name);
    endfunction: new

endclass: decode_stage_output_seq_item