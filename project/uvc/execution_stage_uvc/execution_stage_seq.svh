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

class execution_stage_seq extends uvm_sequence#(execution_stage_seq_item);
    `uvm_object_utils(execution_stage_seq)

    function new(string name = "execution_stage_seq");
        super.new(name);
    endfunction: new

    task body();

        // Create a new item
        req = execution_stage_seq_item::type_id::create("req");

        // Randomize basic fields; tests can override by setting fields before start
        if (!req.randomize()) begin
            `uvm_warning(get_name(), "Randomization failed for execution_stage_seq_item - using defaults")
        end

        // Start/finish item pattern
        start_item(req);
        finish_item(req);

        // Optionally wait for a response (some drivers may provide responses)
        get_response(rsp, req.get_transaction_id());
    endtask: body

endclass: execution_stage_seq
