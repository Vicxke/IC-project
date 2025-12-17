//------------------------------------------------------------------------------
// class basic_test
//
// This class is an extension of the base_test class.
// It provides a basic structure for writing testbenches in the UVM framework.
//
// The class provides an implementation of the build_phase and run_phase methods.
// It creates and builds the TB environment as defined in base_test.
// It runs the test as defined in base_test.
//
// See more detailed information in base_test
//------------------------------------------------------------------------------
import common::*;
class ExDeStage_05 extends uvm_test;
    `uvm_component_utils(ExDeStage_05)

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

    int n = 1; // x for 100% coverage


    virtual task run_phase(uvm_phase phase);

        // Run the test as defined in base test
        reset_seq reset;
        decode_stage_input_seq decode_stage_input;
        instruction_type instruction;
        logic [4:0] write_id_store, write_id_store1, write_id_store2;
        logic [31:0] write_data;
        super.run_phase(phase);

         // Raise objection if no UVM test is running
        phase.raise_objection(this);       

        // Start the data generation loop
        //do a simple reset first
        reset = reset_seq::type_id::create("reset");
        reset.delay = 0;
        reset.length = 1;
        reset.start(m_tb_env.m_reset_agent.m_sequencer);

        repeat (100*n) begin

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

            if (!(decode_stage_input.randomize() with {
                write_en == 0;
                instruction.opcode == 7'b0010111; // U-Type
                // REST OF INSTRUCTION RANDOMIZED
                // PC ALSO RANDOMIZED
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
            decode_stage_input.instr_valid = 1; // input decode stage
            decode_stage_input.instr_valid_ex_in = 1; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            // @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock); // wait until comparison is done
        end

        
        // for special cases
        // repeat (1*n) begin

        //     @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        //     decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        //     if (!(decode_stage_input.randomize() with {
        //         write_en == 0;
        //         instruction.opcode == 7'b0010111; // U-Type
        //         instruction.rd == 
        //         instruvtion.funct3
        //         instruction.rs1 ==
        //         instruction.rs2 ==
        //         instruction.funct7 == 
        //     }))
        //         `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
        //     decode_stage_input.instr_valid = 1; // input decode stage
        //     decode_stage_input.instr_valid_ex_in = 1; // input execution stage
        //     decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        //     @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        //     // @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock); // wait until comparison is done
        // end
        
        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExDeStage_05
