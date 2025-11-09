//------------------------------------------------------------------------------
// serial_data_seq class
//
// This sequence is used to generate random serial data with start bit delay and length.
//
// The sequence has two constraints on the start bit delay and start bit length.
// The start bit delay must be less than 10 clocks,
// The start bit length must be less than 10 clocks.
//
//------------------------------------------------------------------------------
// execution_stage_seq.svh
// Simple sequence to generate execution_stage_seq_item transactions
import common::*;
class execution_stage_seq extends uvm_sequence#(execution_stage_seq_item);
    `uvm_object_utils(execution_stage_seq)

    rand int unsigned data1;
    rand int unsigned data2;
    rand int unsigned immediate_data;
    rand control_type control_in;
    rand bit compflg_in;
    rand int unsigned program_counter;

    function new(string name = "execution_stage_seq");
        super.new(name);
    endfunction: new

    task body();

        // Create a new item
        req = execution_stage_seq_item::type_id::create("req");

        // Copy explicit values (deterministic behaviour for basic tests)
        req.data1         = data1;
        req.data2         = data2;
        req.immediate_data = immediate_data;
        req.control_in    = control_in;
        req.compflg_in    = compflg_in;
        req.program_counter = program_counter;

        // Start/finish item pattern
        start_item(req);
        //if (!(req.randomize() with {
        //    req.data1 == local::data1;
        //    req.data2 == local::data2;
        //    req.immediate_data == local::immediate_data;
        //    req.control_in == local::control_in;
        //    req.compflg_in == local::compflg_in;
        //    req.program_counter == local::program_counter;
        //}))`uvm_warning(get_name(), "Failed to randomize")
        finish_item(req);

        // Optionally wait for a response (some drivers may provide responses)
        get_response(rsp, req.get_transaction_id());
    endtask: body

endclass: execution_stage_seq
