//------------------------------------------------------------------------------
// execution_stage uVC sequence driver
//
// The driver generates serial data according to the configuration of the
// The driver can generate parity bits if parity_enable is set.
// 
//  The configuration of the serial interface is provided via the
//  execution_stage_config object.
//
//------------------------------------------------------------------------------
import common::*;

class execution_stage_driver extends uvm_driver#(execution_stage_seq_item);
    `uvm_component_param_utils(execution_stage_driver)

    // execution_stage uVC configuration object.
    execution_stage_config  m_config;
    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name = "execution_stage_driver", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(execution_stage_config)::get(this, "", "execution_stage_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find the execution_stage_config in config DB")
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
        execution_stage_seq_item req;

        `uvm_info(get_name(), "execution_stage_driver started", UVM_LOW)

        forever begin
            // Get next request from sequencer
            seq_item_port.get(req);

            // Debug: print received request contents so we can track whether
            // the sequence populated the item correctly.
            `uvm_info(get_name(), $sformatf("Received REQ: data1=%0h data2=%0h imm=%0h pc=%0h comp=%0b",
                        req.data1, req.data2, req.immediate_data, req.program_counter, req.compflg_in), UVM_MEDIUM)

            if (m_config.m_vif == null) begin
                `uvm_fatal(get_name(), "Virtual interface not set in execution_stage_config (m_vif)")
            end

            @(posedge m_config.m_vif.clk);


            // Drive inputs
            m_config.m_vif.data1 = req.data1;
            m_config.m_vif.data2 = req.data2;
            m_config.m_vif.immediate_data = req.immediate_data;
            m_config.m_vif.control_in = req.control_in;
            m_config.m_vif.compflg_in = req.compflg_in;
            m_config.m_vif.program_counter = req.program_counter;

            // Debug: print the interface values after driving so we can confirm
            // the driver actually wrote the expected values onto the virtual IF.
            `uvm_info(get_name(), $sformatf("Wrote IF: data1=%0h data2=%0h imm=%0h pc=%0h comp=%0b",
                        m_config.m_vif.data1, m_config.m_vif.data2, m_config.m_vif.immediate_data, m_config.m_vif.program_counter, m_config.m_vif.compflg_in), UVM_MEDIUM)

            // Let DUT sample on next rising edge
            @(posedge m_config.m_vif.clk);

            // Optionally wait a cycle to let outputs propagate
            @(posedge m_config.m_vif.clk);

            // Return the item (no response payload currently)
            seq_item_port.put(req);
        end
    endtask: run_phase

endclass: execution_stage_driver
