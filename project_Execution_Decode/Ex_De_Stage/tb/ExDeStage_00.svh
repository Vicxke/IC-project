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
class ExDeStage_00 extends uvm_test;
    `uvm_component_utils(ExDeStage_00)

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
        super.run_phase(phase);

        `uvm_info("ExDeStage_00 Info", "Starting ExDeStage_00 run_phase", UVM_LOW);

         // Raise objection if no UVM test is running
        phase.raise_objection(this);       

        // Start the data generation loop
        //do a simple reset first
        reset = reset_seq::type_id::create("reset");
        reset.delay = 0;
        reset.length = 1;
        reset.start(m_tb_env.m_reset_agent.m_sequencer);

        //-------------------- put some data into the memory -----------------------
        decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
        decode_stage_input.write_en = 1;
        decode_stage_input.write_id = 5'd1;
        decode_stage_input.write_data = 32'h0000_000A; // x1 = 10
        decode_stage_input.instruction = 0;  // Not used when write_en=1, but set to avoid X
        decode_stage_input.pc = 0;
        decode_stage_input.compflg = 0;
        decode_stage_input.mux_data1 = 0;
        decode_stage_input.mux_data2 = 0;
        decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);


        //-------------------- save data from register to mem -----------------------
        decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
        
        decode_stage_input.instruction = '{
            funct7:  7'b0000001, //1 to add to the immidiate
            rs2:     5'd1, 
            rs1:     5'd2, 
            funct3:  3'b010, //sw
            rd:      5'd3,
            opcode:  7'b0100011 
        };

        decode_stage_input.pc = 32'h0000_0040;
        decode_stage_input.compflg = 0;
        decode_stage_input.write_en = 0;  // Not writing to register during instruction
        decode_stage_input.write_id = 0;
        decode_stage_input.write_data = 0;
        decode_stage_input.mux_data1 = 0;
        decode_stage_input.mux_data2 = 0;

        decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        


        // // -----------------------------ALU Operations -------------------------------------------------

        // repeat (100*n) begin
        //     execute_stage = execution_stage_seq::type_id::create("execute_stage_rand");

        //     if (!(execute_stage.randomize() with {
        //         // ALU und Encoding randomisieren (alle anderen Felder fix)
        //         // control_in.alu_op inside {
        //         //     ALU_ADD, ALU_SUB, ALU_XOR, ALU_OR, ALU_AND, ALU_SLL, ALU_SRL,ALU_SRA, ALU_SLT, ALU_SLTU
        //         // };
        //         control_in.encoding == R_TYPE;

        //         control_in.alu_src    == 2'b00;
        //         control_in.mem_read   == 0;
        //         control_in.mem_write  == 0;
        //         control_in.reg_write  == 1;
        //         control_in.mem_to_reg == 0;
        //         control_in.is_branch  == 0;
        //         control_in.funct3     == 3'b000;

        //         // data1/data2 frei (volle 32-Bit-Spanne)
        //         compflg_in == 0;

        //         // PC in wachsendem Bereich, optional
        //         program_counter == 32'h0000_0040;
        //     }))
        //         `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

        //     execute_stage.start(m_tb_env.m_execution_stage_agent.m_sequencer);
        // end


        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExDeStage_00
