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
// execution_stage_seq_item.svh
// Sequence item for the execution_stage uVC

import common::*;

class execution_stage_seq_item extends uvm_sequence_item;

    // DUT inputs
    randc logic [31:0] data1;
    randc logic [31:0] data2;
    rand logic [31:0] immediate_data;
    // control_type is a DUT typedef; include a field for it so monitor can pass it
    rand control_type control_in;
    rand bit compflg_in;
    rand logic [31:0] program_counter;

    // Optional expected outputs (for scoreboard checks)
    logic [31:0] exp_alu_data;
    bit exp_overflow_flag;
    // monitor helper flag
    bit monitor_data_valid;

    // Fields for printing/packing
    `uvm_object_utils_begin(execution_stage_seq_item)
    `uvm_field_int(data1, UVM_ALL_ON)
    `uvm_field_int(data2, UVM_ALL_ON)
    `uvm_field_int(immediate_data, UVM_ALL_ON)
    // control_in is a typedef (enum/struct) from common, skip automatic uvm_field macros
    // (we still register the main integer/packed fields)
    `uvm_field_int(compflg_in, UVM_ALL_ON)
    `uvm_field_int(program_counter, UVM_ALL_ON)
    `uvm_field_int(exp_alu_data, UVM_ALL_ON)
    `uvm_field_int(exp_overflow_flag, UVM_ALL_ON)
    // monitor_data_valid intentionally not registered
    `uvm_object_utils_end

    // Constructor
    function new(string name = "execution_stage_seq_item");
        super.new(name);
    endfunction: new

endclass: execution_stage_seq_item
