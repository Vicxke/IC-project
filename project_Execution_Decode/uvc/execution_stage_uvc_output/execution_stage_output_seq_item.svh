import common::*;

class execution_stage_output_seq_item extends uvm_sequence_item;


    // expected outputs (for scoreboard checks)
    logic [31:0] alu_data;
    logic [31:0] memory_data;
    bit overflow_flag;
    bit zero_flag;
    control_type control_out;
    logic compflg_out;
    logic instr_valid_ex_in;




    // Fields for printing/packing
    `uvm_object_utils_begin(execution_stage_output_seq_item)
    `uvm_field_int(alu_data, UVM_ALL_ON)
    `uvm_field_int(memory_data, UVM_ALL_ON)
    `uvm_field_int(overflow_flag, UVM_ALL_ON)
    `uvm_field_int(zero_flag, UVM_ALL_ON)
    //`uvm_field_object(control_out, UVM_ALL_ON) not possible because control_type is a typedef struct
    `uvm_field_int(compflg_out, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "execution_stage_output_seq_item");
        super.new(name);
    endfunction: new

endclass: execution_stage_output_seq_item