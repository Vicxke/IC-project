//------------------------------------------------------------------------------
// top_config class
//
// Top level configuration object for top level component.
// This class is intended to be used by the UVM configuration database.
//
// It contains the configuration objects for each agent in the system and
// configures them appropriately for the test.
//
//------------------------------------------------------------------------------
class top_config extends uvm_object;
    `uvm_object_param_utils(top_config)

    // clock configuration instance for clock agent uVC.
    clock_config m_clock_config;
    // reset configuration instance for reset agent uVC.
    reset_config m_reset_config;
    // execution_stage configuration instance for execution_stage agent uVC.
    execution_stage_config m_execution_stage_config;
    // decode_stage configuration instance for decode_stage agent uVC.
    decode_stage_config m_decode_stage_config;

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new (string name="top_config");
        super.new(name);
        // Create and configure clock uVC with 10ns clock generation
        m_clock_config = new("m_clock_config");
        m_clock_config.is_active = 1;
        m_clock_config.clock_period = 10;

        // Create and configure reset uVC configuration with driver and monitor
        m_reset_config = new("m_reset_config");
        m_reset_config.is_active = 1;
        m_reset_config.has_monitor = 1;

        // Create and configure execution_stage uVC configuration with driver and monitor
        m_execution_stage_config = new("m_execution_stage_config");
        m_execution_stage_config.is_active = 1;
        m_execution_stage_config.has_monitor = 1;

        // Create and configure decode_stage uVC configuration with driver and monitor
        m_decode_stage_config = new("m_decode_stage_config");
        m_decode_stage_config.is_active = 1;
        m_decode_stage_config.has_monitor = 1;
        
    endfunction : new

endclass : top_config
