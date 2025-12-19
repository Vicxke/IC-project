//------------------------------------------------------------------------------
// decode_stage uVC sequence driver
//
// The driver generates serial data according to the configuration of the
// The driver can generate parity bits if parity_enable is set.
// 
//  The configuration of the serial interface is provided via the
//  decode_stage_input_config object.
//
//------------------------------------------------------------------------------
import common::*;

class decode_stage_input_driver extends uvm_driver#(decode_stage_input_seq_item);
    `uvm_component_param_utils(decode_stage_input_driver)

    // decode_stage uVC configuration object.
    decode_stage_input_config  m_config;
    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name = "decode_stage_input_driver", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(decode_stage_input_config)::get(this, "", "decode_stage_input_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find the decode_stage_input_config in config DB")
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
        decode_stage_input_seq_item req;

        `uvm_info(get_name(), "decode_stage_input_driver started", UVM_LOW)

        forever begin
            // Get next request from sequencer
            seq_item_port.get(req);

            if (m_config.m_vif == null) begin
                `uvm_fatal(get_name(), "Virtual interface not set in decode_stage_input_config (m_vif)")
            end

            @(posedge m_config.m_vif.clk);


            // Drive inputs
            m_config.m_vif.instruction = req.instruction;
            m_config.m_vif.pc       = req.pc;
            m_config.m_vif.compflg  = req.compflg;
            m_config.m_vif.write_en = req.write_en;
            m_config.m_vif.write_id = req.write_id;
            m_config.m_vif.write_data = req.write_data;
            m_config.m_vif.mux_data1  = req.mux_data1;
            m_config.m_vif.mux_data2  = req.mux_data2;
            m_config.m_vif.instr_valid = req.instr_valid;
            m_config.m_vif.instr_valid_ex_in = req.instr_valid_ex_in;
            m_config.m_vif.decode_output_valid = req.decode_output_valid;

            // `uvm_info(get_name(), $sformatf("Send seq item to decode stage: Write data=0x%0h", req.write_data), UVM_LOW);
            // Return the item (no response payload currently)
            seq_item_port.put(req);
        end
    endtask: run_phase

endclass: decode_stage_input_driver
