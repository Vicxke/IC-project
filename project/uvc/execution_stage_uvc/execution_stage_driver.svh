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
class execute_stage_driver extends uvm_driver #(execute_stage_seq_item);
    `uvm_component_param_utils(execute_stage_driver)

    // execute_stage uVC configuration object.
    execute_stage_config  m_config;

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db #(execute_stage_config)::get(this,"","execute_stage_config", m_config)) begin
            `uvm_fatal(get_name(),"Cannot find the VC configuration!")
        end
    endfunction

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
        execute_stage_seq_item seq_item;

        forever begin
            // Wait for sequence item
            seq_item_port.get(seq_item);

            

            seq_item_port.put(seq_item); // send response back.
        end
    endtask : run_phase
endclass : execute_stage_driver
