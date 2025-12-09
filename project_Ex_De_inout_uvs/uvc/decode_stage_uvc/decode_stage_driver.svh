//------------------------------------------------------------------------------
// decode_stage uVC sequence driver
//
// The driver generates serial data according to the configuration of the
// The driver can generate parity bits if parity_enable is set.
// 
//  The configuration of the serial interface is provided via the
//  decode_stage_config object.
//
//------------------------------------------------------------------------------
import common::*;

class decode_stage_driver extends uvm_driver#(decode_stage_seq_item);
    `uvm_component_param_utils(decode_stage_driver)

    // decode_stage uVC configuration object.
    decode_stage_config  m_config;
    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name = "decode_stage_driver", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(decode_stage_config)::get(this, "", "decode_stage_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find the decode_stage_config in config DB")
        end
    endfunction: new

    //------------------------------------------------------------------------------
    // FUNCTION: build
    // The build phase for the component.
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // FUNCTION: run_phase
    // The run phase for the component.
    // - Main loop
    // -  Wait for sequence item.
    // -  Perform the requested action
    // -  Send a response back.
    //------------------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        decode_stage_seq_item req;

        `uvm_info(get_name(), "decode_stage_driver started", UVM_LOW)

        forever begin
            // Get next request from sequencer
            seq_item_port.get(req);

            if (m_config.m_vif == null) begin
                `uvm_fatal(get_name(), "Virtual interface not set in decode_stage_config (m_vif)")
            end

            @(posedge m_config.m_vif.clk);


            // Drive inputs
            m_config.m_vif.instruction = req.instruction;
            m_config.m_vif.pc       = req.pc;


            // Let DUT sample on next rising edge
            @(posedge m_config.m_vif.clk);

            // Optionally wait a cycle to let outputs propagate
            @(posedge m_config.m_vif.clk);

            // Return the item (no response payload currently)
            seq_item_port.put(req);
        end
    endtask: run_phase

endclass: decode_stage_driver
