import common::*;

class execution_stage_input_seq_item extends uvm_sequence_item;

    // DUT inputs
    randc logic [31:0] data1;
    randc logic [31:0] data2;
    randc logic [31:0] immediate_data;
    // control_type is a DUT typedef; include a field for it so monitor can pass it
    randc control_type control_in;
    rand bit compflg_in;
    rand logic [31:0] program_counter_in;
    rand bit instr_valid_ex_in;


    // Fields for printing/packing
    `uvm_object_utils_begin(execution_stage_input_seq_item)
    `uvm_field_int(data1, UVM_ALL_ON)
    `uvm_field_int(data2, UVM_ALL_ON)
    `uvm_field_int(immediate_data, UVM_ALL_ON)
    // control_in is a typedef (enum/struct) from common, skip automatic uvm_field macros
    `uvm_field_int(control_in, UVM_ALL_ON)
    `uvm_field_int(compflg_in, UVM_ALL_ON)
    `uvm_field_int(program_counter_in, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "execution_stage_input_seq_item");
        super.new(name);
    endfunction: new

endclass: execution_stage_input_seq_item