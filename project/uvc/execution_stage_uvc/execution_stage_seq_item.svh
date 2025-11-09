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

class execution_stage_seq_item extends uvm_sequence_item;
    `uvm_object_utils(execution_stage_seq_item)

    // DUT inputs
    rand logic [31:0] data1;
    rand logic [31:0] data2;
    rand logic [31:0] immediate_data;
    // store compact control encoding (user can expand mapping in driver)
    rand int control_encoding;
    rand bit compflg_in;
    rand logic [31:0] program_counter;

    // Optional expected outputs (for scoreboard checks)
    logic [31:0] exp_alu_data;
    bit exp_overflow_flag;

    // Fields for printing/packing
    `uvm_object_utils_begin(execution_stage_seq_item)
    `uvm_field_int(data1, UVM_ALL_ON)
    `uvm_field_int(data2, UVM_ALL_ON)
    `uvm_field_int(immediate_data, UVM_ALL_ON)
    `uvm_field_int(control_encoding, UVM_ALL_ON)
    `uvm_field_int(compflg_in, UVM_ALL_ON)
    `uvm_field_int(program_counter, UVM_ALL_ON)
    `uvm_field_int(exp_alu_data, UVM_ALL_ON)
    `uvm_field_int(exp_overflow_flag, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "execution_stage_seq_item");
        super.new(name);
    endfunction: new

endclass: execution_stage_seq_item
