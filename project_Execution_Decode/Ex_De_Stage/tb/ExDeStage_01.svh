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
class ExDeStage_01 extends uvm_test;
    `uvm_component_utils(ExDeStage_01)

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

    int n = 5; // x for 100% coverage


    virtual task run_phase(uvm_phase phase);

        // Run the test as defined in base test
        reset_seq reset;
        decode_stage_input_seq decode_stage_input;
        instruction_type instruction;
        logic [4:0] write_id_store1, write_id_store2;
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

        repeat (50*n) begin
            // write random value into x1
            `uvm_info("Starts test 4:", "randomize write data 1/2 + write id 1/2", UVM_LOW);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store1 = decode_stage_input.write_id;
            decode_stage_input.instr_valid = 1; // input decode stage
            decode_stage_input.instr_valid_ex_in = 0; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

            // write B into x2
            decode_stage_input = decode_stage_input_seq::type_id::create("wr_x2");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store2 = decode_stage_input.write_id;
            // Force different register if collision detected
            if (write_id_store2 == write_id_store1) begin
                //`uvm_warning(get_name(), $sformatf("Collision detected! Both IDs are %0d, forcing different ID...", write_id_store1))
                // Pick a different ID by adding 1 (modulo 32, skip x0)
                decode_stage_input.write_id = (write_id_store1 + 1) % 32;
                write_id_store2 = decode_stage_input.write_id;
            end

            decode_stage_input.instr_valid = 1; // input decode stage
            decode_stage_input.instr_valid_ex_in = 0; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 0;
                instruction.opcode == 7'b0110011; //R-types
                instruction.funct7 == 7'b0000000; //standard operations
                instruction.rs2 == write_id_store2;  // RS2 provides store data (data2)
                instruction.rs1 == write_id_store1;  // RS1 provides base address
                compflg == 0;
                instr_valid == 1;
                instr_valid_ex_in == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        end
        
        //only for sub and sra
        repeat (10*n) begin
            // write random value into x1
            `uvm_info("Starts test 4:", "randomize write data 1/2 + write id 1/2", UVM_LOW);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store1 = decode_stage_input.write_id;
            decode_stage_input.instr_valid = 1; // input decode stage
            decode_stage_input.instr_valid_ex_in = 0; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

            // write B into x2
            decode_stage_input = decode_stage_input_seq::type_id::create("wr_x2");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store2 = decode_stage_input.write_id;
            // Force different register if collision detected
            if (write_id_store2 == write_id_store1) begin
                //`uvm_warning(get_name(), $sformatf("Collision detected! Both IDs are %0d, forcing different ID...", write_id_store1))
                // Pick a different ID by adding 1 (modulo 32, skip x0)
                decode_stage_input.write_id = (write_id_store1 + 1) % 32;
                write_id_store2 = decode_stage_input.write_id;
            end
            
            decode_stage_input.instr_valid = 1; // input decode stage
            decode_stage_input.instr_valid_ex_in = 0; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 0;
                instruction.opcode == 7'b0110011; //R-types
                instruction.funct7 == 7'b0100000; //standard operations
                instruction.funct3 inside {3'b000, 3'b101}; //ADD/SUB and SRL/SRA
                instruction.rs2 == write_id_store2;  // RS2 provides store data (data2)
                instruction.rs1 == write_id_store1;  // RS1 provides base address
                compflg == 0;
                instr_valid == 1;
                instr_valid_ex_in == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        end

        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExDeStage_01
