//------------------------------------------------------------------------------
// serial_data_seq_item class
//
// This class is used to represent the serial data sequence item
//
// This class is used to represent the serial data sequence item for
// the test bench. It is used to create a serial data sequence with 
// the following fields:
//    start_bit_delay - The delay in clock cycles before start bit is activated
//    start_bit_length - The length in clock cycles of the start bit
//    serial_data - The data to transmit
//    parity_error - Whether to introduce a parity error
//    monitor_start_bit_value - The actual value of the start bit
//    monitor_start_bit_valid - Whether the start bit is valid
//    monitor_data_valid - Whether the serial data is valid
//
//------------------------------------------------------------------------------
// execution_stage_output_seq_item.svh
// Sequence item for the execution_stage_output uVC

import common::*;

class execution_stage_output_seq_item extends uvm_sequence_item;


    // expected outputs (for scoreboard checks)
    logic [31:0] alu_data;
    logic [31:0] memory_data;
    bit overflow_flag;
    bit zero_flag;
    control_type control_out;
    logic compflg_out;
    logic [31:0] program_counter_out;




    // Fields for printing/packing
    `uvm_object_utils_begin(execution_stage_output_seq_item)
    `uvm_field_int(alu_data, UVM_ALL_ON)
    `uvm_field_int(memory_data, UVM_ALL_ON)
    `uvm_field_int(overflow_flag, UVM_ALL_ON)
    `uvm_field_int(zero_flag, UVM_ALL_ON)
    //`uvm_field_object(control_out, UVM_ALL_ON) not possible because control_type is a typedef struct
    `uvm_field_int(compflg_out, UVM_ALL_ON)
    `uvm_field_int(program_counter_out, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "execution_stage_output_seq_item");
        super.new(name);
    endfunction: new

endclass: execution_stage_output_seq_item