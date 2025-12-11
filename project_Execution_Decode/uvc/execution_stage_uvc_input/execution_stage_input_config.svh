//------------------------------------------------------------------------------
// execution_stage_input_config class
//
// The configuration of clock.
// This class contains the configuration of serial data, and the virtual interface.
//
// The configuration of serial data includes:
//  is_active     - indicate whether the sequencer and driver are activated.
//  has_monitor   - indicate whether the monitor is activated.
//
// The virtual interface includes:
//  m_vif - the execution_stage uVC virtual EXECUTION_STAGE_IF interface.
//
//------------------------------------------------------------------------------
class execution_stage_input_config extends uvm_object;

    // The Sequencer and driver are activated
    bit is_active = 1;
    // The monitor is active. 
    bit has_monitor = 1;
    // execution_stage uVC virtual EXECUTION_STAGE_IF interface.
    virtual execution_stage_input_if m_vif;

    `uvm_object_utils_begin(execution_stage_input_config)
    `uvm_field_int(is_active,UVM_ALL_ON|UVM_DEC)
    `uvm_field_int(has_monitor,UVM_ALL_ON|UVM_DEC)
    `uvm_object_utils_end

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new (string name = "execution_stage_input_config");
        super.new(name);
    endfunction : new

endclass : execution_stage_input_config