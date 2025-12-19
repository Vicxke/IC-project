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
class ExDeStage_06 extends uvm_test;
    `uvm_component_utils(ExDeStage_06)

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

    int n = 20; // x for 100% coverage


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
                write_en == 1;
                instruction.opcode == 7'b1100111; // U-Type
                compflg== 0;
                instr_valid == 1;
                instr_valid_ex_in == 0;
                decode_output_valid == 0;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store1 = decode_stage_input.write_id;
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            
            `uvm_info(get_name(), "Starting new decode_stage input sequence", UVM_LOW);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

            if (!(decode_stage_input.randomize() with {
                write_en == 0;
                instruction.opcode == 7'b1100111; // U-Type
                instruction.funct3 == 3'b000;
                instruction.rs1==    write_id_store1;
                compflg== 0;
                // REST OF INSTRUCTION RANDOMIZED
                // PC ALSO RANDOMIZED
                instr_valid == 1;
                instr_valid_ex_in == 1;
                decode_output_valid == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
            `uvm_info(get_name(), $sformatf("Randomization done with instr_valid_ex_in=%0b", decode_stage_input.instr_valid_ex_in), UVM_LOW);
            // decode_stage_input.instr_valid = 1; // input decode stage
            // decode_stage_input.instr_valid_ex_in = 1; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        end

        repeat (10*n) begin

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
                instruction.opcode == 7'b1100111; // U-Type
                compflg== 0;
                instr_valid == 1;
                instr_valid_ex_in == 0;
                decode_output_valid == 0;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store1 = decode_stage_input.write_id;
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);
            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            
            `uvm_info(get_name(), "Starting new decode_stage input sequence", UVM_LOW);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

            if (!(decode_stage_input.randomize() with {
                write_en == 0;
                instruction.opcode == 7'b1100111; // U-Type
                pc inside {32'h0000_0000,32'hFFFF_FFFF};
                instruction.funct7 inside {7'b0000000,7'b1111111};
                instruction.rs2 inside {5'd0,5'd31};
                instruction.funct3 == 3'b000;
                instruction.rs1 ==    write_id_store1;
                compflg == 0;
                instr_valid == 1;
                instr_valid_ex_in == 1;
                decode_output_valid == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
            `uvm_info(get_name(), $sformatf("Randomization done with instr_valid_ex_in=%0b", decode_stage_input.instr_valid_ex_in), UVM_LOW);
            // decode_stage_input.instr_valid = 1; // input decode stage
            // decode_stage_input.instr_valid_ex_in = 1; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        end

        // ---------------------------- case result all_ones ----------------------------
        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
        if (!(decode_stage_input.randomize() with {
            write_en == 1;
            instruction.opcode == 7'b1100111; // U-Type
            compflg== 0;
            instr_valid == 1;
            instr_valid_ex_in == 0;
            decode_output_valid == 0;
        }))
            `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

        write_id_store1 = decode_stage_input.write_id;

        decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        
        `uvm_info(get_name(), "Starting new decode_stage input sequence", UVM_LOW);
        decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        if (!(decode_stage_input.randomize() with {
            write_en == 0;
            instruction.opcode == 7'b1100111; // U-Type
            pc == 32'hFFFF_FFFB;
            instruction.funct7 == 7'b0000000;
            instruction.rs2 ==5'd0;
            instruction.funct3 ==3'b000;
            instruction.rs1 ==    write_id_store1;
            compflg == 0;
            instr_valid == 1;
            instr_valid_ex_in == 1;
            decode_output_valid == 1;
        }))
            `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
        `uvm_info(get_name(), $sformatf("Randomization done with instr_valid_ex_in=%0b", decode_stage_input.instr_valid_ex_in), UVM_LOW);
        // decode_stage_input.instr_valid = 1; // input decode stage
        // decode_stage_input.instr_valid_ex_in = 1; // input execution stage
        decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        // -----------------------------------------------------------------------------

        // ---------------------------- case result all_ones ----------------------------
        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
                instruction.opcode == 7'b1100111; // U-Type
                compflg== 0;
                instr_valid == 1;
                instr_valid_ex_in == 0;
                decode_output_valid == 0;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store1 = decode_stage_input.write_id;
            decode_stage_input.instr_valid = 1; // input decode stage
            decode_stage_input.instr_valid_ex_in = 0; // input execution stage
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        
        `uvm_info(get_name(), "Starting new decode_stage input sequence", UVM_LOW);
        decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        if (!(decode_stage_input.randomize() with {
            write_en == 0;
            instruction.opcode == 7'b1100111; // U-Type
            pc == 32'hFFFF_FFFC;
            instruction.funct7 == 7'b0000000;
            instruction.rs2 ==5'd0;
            instruction.funct3 ==3'b000;
            instruction.rs1 ==    write_id_store1;        
            compflg == 0;
            instr_valid == 1;
            instr_valid_ex_in == 1;
            decode_output_valid == 1;
        }))
            `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
        `uvm_info(get_name(), $sformatf("Randomization done with instr_valid_ex_in=%0b", decode_stage_input.instr_valid_ex_in), UVM_LOW);
        // decode_stage_input.instr_valid = 1; // input decode stage
        // decode_stage_input.instr_valid_ex_in = 1; // input execution stage
        decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        // -----------------------------------------------------------------------------
        
        @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock); // always needed in the end

        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExDeStage_06
