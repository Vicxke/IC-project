import common::*;

class decode_stage_input_seq_item extends uvm_sequence_item;

    // DUT inputs
    randc instruction_type instruction;
    randc logic [31:0] pc;
    randc bit compflg;
    randc bit write_en;
    randc logic [4:0] write_id;
    randc logic [31:0] write_data;
    randc logic [31:0] mux_data1;
    randc logic [31:0] mux_data2;

    rand bit instr_valid;
    rand bit instr_valid_ex_in; // for execution stage instruction

    // monitor helper flag
    bit monitor_data_valid;

    // Fields for printing/packing
    `uvm_object_utils_begin(decode_stage_input_seq_item)
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
    function new(string name = "decode_stage_input_seq_item");
        super.new(name);
    endfunction: new

endclass: decode_stage_input_seq_item