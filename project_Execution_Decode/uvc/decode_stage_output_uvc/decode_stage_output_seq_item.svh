import common::*;

class decode_stage_output_seq_item extends uvm_sequence_item;

    // DUT outputs
    logic [5:0]  reg_rd_id;
    logic [4:0]  rs1_id;
    logic [4:0]  rs2_id;
    logic        resolve;
    logic [31:0] select_target_pc;
    logic        squash_after_J;
    logic        squash_after_JALR;

    // monitor helper flag
    bit monitor_data_valid;

    // Fields for printing/packing
    `uvm_object_utils_begin(decode_stage_output_seq_item)
    `uvm_field_int(instruction, UVM_ALL_ON)
    `uvm_field_int(pc, UVM_ALL_ON)
    `uvm_field_int(compflg, UVM_ALL_ON)
    `uvm_field_int(write_en, UVM_ALL_ON)
    `uvm_field_int(write_id, UVM_ALL_ON)
    `uvm_field_int(write_data, UVM_ALL_ON)
    `uvm_field_int(mux_data1, UVM_ALL_ON)
    `uvm_field_int(mux_data2, UVM_ALL_ON)

    
    // monitor_data_valid intentionally not registered
    `uvm_object_utils_end

    // Constructor
    function new(string name = "decode_stage_output_seq_item");
        super.new(name);
    endfunction: new

endclass: decode_stage_output_seq_item