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
// decode_stage_seq.svh
// Simple sequence to generate decode_stage_seq_item transactions
import common::*;
class decode_stage_seq extends uvm_sequence#(decode_stage_seq_item);
    `uvm_object_utils(decode_stage_seq)



    rand instruction_type instruction;
    rand int unsigned pc;
    rand bit compflg;
    rand bit write_en;
    rand int unsigned write_id;
    rand int unsigned write_data;
    rand int unsigned mux_data1;
    rand int unsigned mux_data2;

    // decode_stage_seq_item decode_req;
    // decode_stage_seq_item rsp;

    function new(string name = "decode_stage_seq");
        super.new(name);
    endfunction: new

    task body();

        // Create a new item
        req = decode_stage_seq_item::type_id::create("req");

        // Copy explicit values (deterministic behaviour for basic tests)
        req.instruction = instruction;
        req.pc       = pc;
        req.compflg    = compflg;
        req.write_en    = write_en;
        req.write_id    = write_id;
        req.write_data    = write_data;
        req.mux_data1    = mux_data1;
        req.mux_data2    = mux_data2;

        // Start/finish item pattern
        start_item(req);

        finish_item(req);

        // Optionally wait for a response (some drivers may provide responses)
        get_response(rsp, req.get_transaction_id());
    endtask: body

endclass: decode_stage_seq
