//------------------------------------------------------------------------------
// pass through of:
// - control signals
// - comparison flag
//------------------------------------------------------------------------------
import common::*;
class ExStage_06 extends uvm_test;
    `uvm_component_utils(ExStage_06)

    // Testbench top configuration object with all setup for the TB
    top_config  m_top_config;

    // Testbench environment
    tb_env  m_tb_env;

    //------------------------------------------------------------------------------
    // FUNCTION: new
    // Creates and constructs the sequence.
    //------------------------------------------------------------------------------
    function new (string name = "test",uvm_component parent = null);
        super.new(name,parent);
        // Get TB TOP configuration from UVM DB
        if ((uvm_config_db #(top_config)::get(null, "tb_top", "top_config", m_top_config))==0) begin
            `uvm_fatal(get_name(),"Cannot find <top_config> TB configuration!")
        end
    endfunction : new

    //------------------------------------------------------------------------------
    // FUNCTION: build_phase
    // Function to build the class within UVM build phase.
    //------------------------------------------------------------------------------
    virtual function void build_phase(uvm_phase phase);
        // Create and build TB environment as defined in base test
        super.build_phase(phase);
        // Create TB verification environment
        m_tb_env = tb_env::type_id::create("m_tb_env",this);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // FUNCTION: run_phase
    // Start UVM test in running phase.
    //------------------------------------------------------------------------------
    
    int n = 1; // 1 for 100% coverage

    virtual task run_phase(uvm_phase phase);

        //reset_seq reset;
        execution_stage_seq execute_stage;
        control_type ctrl;
        super.run_phase(phase);

        `uvm_info("ExStage_06 Info", "Starting ExStage_06 run_phase", UVM_LOW);

         // Raise objection if no UVM test is running
        phase.raise_objection(this);       

        // // Start the data generation loop
        //do a simple reset first
        reset = reset_seq::type_id::create("reset");
        reset.delay = 0;
        reset.length = 2;
        reset.start(m_tb_env.m_reset_agent.m_sequencer);
        
        // -----------------------------Control signals and compression flag -----------------

        
        repeat (100*n) begin
            execute_stage = execution_stage_seq::type_id::create("execute_stage_rand");

            //this will set the 
            if (!(execute_stage.randomize() with {

                // PC is the base address for AUIPC
                program_counter == 32'h0000_0040;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            execute_stage.start(m_tb_env.m_execution_stage_agent.m_sequencer);
        end

        `uvm_info("ExStage_06 Info", "Completed ExStage_06 run_phase", UVM_LOW);

        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExStage_06