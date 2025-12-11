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
class ExStage_02 extends uvm_test;
    `uvm_component_utils(ExStage_02)

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
        execution_stage_input_seq execute_stage;
        control_type ctrl;
        super.run_phase(phase);

        `uvm_info("ExStage_02 Info", "Starting ExStage_02 run_phase", UVM_LOW);

         // Raise objection if no UVM test is running
        phase.raise_objection(this);       

        // Start the data generation loop
        //do a simple reset first
        reset = reset_seq::type_id::create("reset");
        reset.delay = 0;
        reset.length = 2;
        reset.start(m_tb_env.m_reset_agent.m_sequencer);

        // -----------------------------ALU Operations -------------------------------------------------

        
        repeat (100*n) begin
            execute_stage = execution_stage_input_seq::type_id::create("execute_stage_rand");

            if (!(execute_stage.randomize() with {
                // ALU und Encoding randomisieren (alle anderen Felder fix)
                control_in.alu_op == ALU_ADD; 
                control_in.encoding == S_TYPE;

                control_in.alu_src    == 2'b01; //This is tested here
                control_in.mem_read   == 0;
                control_in.mem_write  == 0;
                control_in.reg_write  == 1;
                control_in.mem_to_reg == 0;
                control_in.is_branch  == 0;
                control_in.funct3     == 3'b000;

                // data1/data2 frei (volle 32-Bit-Spanne)
                compflg_in == 0;

                // PC in wachsendem Bereich, optional
                program_counter_in == 32'h0000_0040;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            execute_stage.start(m_tb_env.m_execution_stage_input_agent.m_sequencer);
        end

        repeat (20*n) begin
            execute_stage = execution_stage_input_seq::type_id::create("execute_stage_rand");

            if (!(execute_stage.randomize() with {
                // ALU und Encoding randomisieren (alle anderen Felder fix)
                control_in.alu_op == ALU_ADD; 
                control_in.encoding == S_TYPE;
                execute_stage.data1 inside {32'h0000_0000,32'hFFFF_FFFF};

                control_in.alu_src    == 2'b01;
                control_in.mem_read   == 0;
                control_in.mem_write  == 0;
                control_in.reg_write  == 1;
                control_in.mem_to_reg == 0;
                control_in.is_branch  == 0;
                control_in.funct3     == 3'b000;

                // data1/data2 frei (volle 32-Bit-Spanne)
                compflg_in == 0;

                // PC in wachsendem Bereich, optional
                program_counter_in == 32'h0000_0040;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            execute_stage.start(m_tb_env.m_execution_stage_input_agent.m_sequencer);
        end

        repeat (20*n) begin
            execute_stage = execution_stage_input_seq::type_id::create("execute_stage_rand");

            if (!(execute_stage.randomize() with {
                // ALU und Encoding randomisieren (alle anderen Felder fix)
                control_in.alu_op == ALU_ADD; 
                control_in.encoding == S_TYPE;
                // execute_stage.data2 inside {32'h0000_0000,32'hFFFF_FFFF}; //not used in this test case
                execute_stage.immediate_data inside {32'h0000_0000,32'hFFFF_FFFF};

                control_in.alu_src    == 2'b01;
                control_in.mem_read   == 0;
                control_in.mem_write  == 0;
                control_in.reg_write  == 1;
                control_in.mem_to_reg == 0;
                control_in.is_branch  == 0;
                control_in.funct3     == 3'b000;

                // data1/data2 frei (volle 32-Bit-Spanne)
                compflg_in == 0;

                // PC in wachsendem Bereich, optional
                program_counter_in == 32'h0000_0040;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            execute_stage.start(m_tb_env.m_execution_stage_input_agent.m_sequencer);
        end

        repeat (5*n) begin
            execute_stage = execution_stage_input_seq::type_id::create("execute_stage_rand");

            if (!(execute_stage.randomize() with {
                // ALU und Encoding randomisieren (alle anderen Felder fix)
                control_in.alu_op == ALU_ADD; 
                control_in.encoding == S_TYPE;
                execute_stage.data1 inside {32'h0000_0000,32'hFFFF_FFFF};
                //execute_stage.data2 inside {32'h0000_0000,32'hFFFF_FFFF}; //not used in this test case
                execute_stage.immediate_data inside {32'h0000_0000,32'hFFFF_FFFF};


                control_in.alu_src    == 2'b01;
                control_in.mem_read   == 0;
                control_in.mem_write  == 0;
                control_in.reg_write  == 1;
                control_in.mem_to_reg == 0;
                control_in.is_branch  == 0;
                control_in.funct3     == 3'b000;

                // data1/data2 frei (volle 32-Bit-Spanne)
                compflg_in == 0;

                // PC in wachsendem Bereich, optional
                program_counter_in == 32'h0000_0040;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            execute_stage.start(m_tb_env.m_execution_stage_input_agent.m_sequencer);
        end


        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExStage_02
