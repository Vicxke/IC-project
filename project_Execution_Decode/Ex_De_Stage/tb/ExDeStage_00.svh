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
        logic [4:0] write_id_store, write_id_store1, write_id_store2;
        logic [31:0] write_data;
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

        //-------------------- simple test -----------------------
            `uvm_info("Starts test 1:", "fixed values", UVM_LOW);
            // write A into x1
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            decode_stage_input.write_en = 1;
            decode_stage_input.write_id = 5'd1;
            decode_stage_input.write_data = 32'h0000_000A; // x1 = 10
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

            // write B into x2
            decode_stage_input = decode_stage_input_seq::type_id::create("wr_x2");
            decode_stage_input.write_en   = 1;
            decode_stage_input.write_id   = 5'd2;             // x2
            decode_stage_input.write_data = 32'h0000_000B;    // 11
            decode_stage_input.instruction = 32'h0000_0013;   // NOP (optional aber gut!)
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            // now do ADD x2, x1, x2  => x2 = x1 + x2 = 21
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            decode_stage_input.write_en   = 0;
            decode_stage_input.instruction = '{
            funct7: 7'b0000000,   
            rs2:    5'd1,         // read x1
            rs1:    5'd2,         // read x2
            funct3: 3'b000,       // ADD
            rd:     5'd2,         // x2
            opcode: 7'b0110011 
            };
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);


        //-------------------- randomize write data test -----------------------
            `uvm_info("Starts test 2:", "randomize write data 1", UVM_LOW);
            // write random value into x1
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
                decode_stage_input.write_id   == 5'd1;             // x1
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

            // now do ADD x2, x1, x2  => x2 = x1 + x2 = 21
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            decode_stage_input.write_en   = 0;
            decode_stage_input.instruction = '{
            funct7: 7'b0000000,   
            rs2:    5'd1,         // read x1
            rs1:    5'd2,         // read x2
            funct3: 3'b000,       // ADD
            rd:     5'd2,         // x2
            opcode: 7'b0110011 
            };
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);



        //-------------------- randomize write data + write id test -----------------------
            // write random value into x1
            `uvm_info("Starts test 3:", "randomize write data 1 + write id 1", UVM_LOW);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store = decode_stage_input.write_id;
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

            // write B into x2
            decode_stage_input = decode_stage_input_seq::type_id::create("wr_x2");
            decode_stage_input.write_en   = 1;
            decode_stage_input.write_id   = 5'd2;             // x2
            decode_stage_input.write_data = 32'h0000_000B;    // 11
            decode_stage_input.instruction = 32'h0000_0013;   // NOP (optional aber gut!)
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            // now do ADD x2, x1, x2  => x2 = x1 + x2 = 21
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            decode_stage_input.write_en   = 0;
            decode_stage_input.instruction = '{
            funct7: 7'b0000000,   
            rs2:    write_id_store,         // read x1
            rs1:    5'd2,         // read x2
            funct3: 3'b000,       // ADD
            rd:     5'd2,         // x2
            opcode: 7'b0110011 
            };
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);


        //-------------------- randomize write data + write id test -----------------------
            // write random value into x1
            `uvm_info("Starts test 4:", "randomize write data 1/2 + write id 1/2", UVM_LOW);
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store1 = decode_stage_input.write_id;
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);

            // write B into x2
            decode_stage_input = decode_stage_input_seq::type_id::create("wr_x2");
            if (!(decode_stage_input.randomize() with {
                write_en == 1;
            }))
                `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

            write_id_store2 = decode_stage_input.write_id;
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            // now do ADD x2, x1, x2  => x2 = x1 + x2 = 21
            decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
            decode_stage_input.write_en   = 0;
            decode_stage_input.instruction = '{
            funct7: 7'b0000000,   
            rs2:    write_id_store1,         // read x1
            rs1:    write_id_store2,         // read x2
            funct3: 3'b000,       // ADD
            rd:     5'd2,         // x2
            opcode: 7'b0110011 
            };
            decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

            @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        //  repeat (2*n) begin
        //     decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        //      if (!(decode_stage_input.randomize() with {
        //         write_en == 1;
        //         instruction.opcode == 7'b0000011; //lw
        //      }))
        //          `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
        //     write_id = decode_stage_input.write_id;
        //     write_data = decode_stage_input.write_data;
        //     `uvm_info(get_name(),$sformatf("lw in reg: Write ID: %0d; Write Data: 0x%0h, Write En: %0d", write_id, write_data, decode_stage_input.write_en), UVM_LOW)
        //     decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);

        //     //after putting the data in the register also read it back
        //     // this is done so we can check in the scoreboard if the data is correct in the register.
        //     // Register file write timing:
        //     //   - Cycle N: write_en=1, data latched on posedge
        //     //   - Cycle N+1: data visible for read, can issue SW instruction
        //     // Minimal delay: only 1 cycle needed for register write to complete
        //     @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
            
        //     decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        //      if (!(decode_stage_input.randomize() with {
        //         write_en == 0;
        //         instruction.opcode == 7'b0100011; //sw
        //         instruction.funct3 inside {3'b000, 3'b001, 3'b010, 3'b011}; //differend S-types
        //         instruction.rs1 == write_id;  // RS1 provides base address (data1)
        //         instruction.rs2 == write_id;  // RS2 provides store data (data2)
        //         compflg == 0;
        //      }))
        //          `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")
        //     `uvm_info(get_name(),$sformatf("sw with Write ID: %0d", write_id), UVM_LOW)
        //     decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);
            
        //     // SW is combinatorial through decode+execute, result in same cycle
        //     // Wait 1 cycle to allow next instruction
        //     @(posedge m_tb_env.m_clock_agent.m_config.m_vif.clock);
        //  end

        // // do zith all zeros and ones
        //  repeat (100*n) begin
        //     decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        //      if (!(decode_stage_input.randomize() with {
        //         write_data inside {32'h0000_0000, 32'hFFFF_FFFF};
        //         write_en == 1;
        //         instruction.opcode == 7'b0000011; //lw
        //      }))
        //          `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

        //     write_id = decode_stage_input.write_id;
        //     decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);
        //     //after putting the data in the register also read it back
        //     // this is done so we can check in the scoreboard if the data is correct in the register.
        //     decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");

        //      if (!(decode_stage_input.randomize() with {
        //         write_en == 0;
        //         instruction.opcode == 7'b0100011; //sw
        //         instruction.funct3 inside {3'b000, 3'b001, 3'b010, 3'b011}; //differend S-types
        //         instruction.rs2 == write_id;
        //         compflg == 0;
        //      }))
        //          `uvm_fatal(get_name(), "Failed to randomize execute_stage sequence")

        //     decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);
        //  end

        //-------------------- save data from register to mem -----------------------
        //decode_stage_input = decode_stage_input_seq::type_id::create("decode_stage_input");
        
        //decode_stage_input.instruction = '{
        //    funct7:  7'b0000001, //1 to add to the immidiate
        //    rs2:     5'd1, 
        //    rs1:     5'd2, 
        //    funct3:  3'b010, //sw
        //    rd:      5'd3,
        //    opcode:  7'b0100011 
        //};

        //decode_stage_input.pc = 32'h0000_0040;
        //decode_stage_input.start(m_tb_env.m_decode_stage_input_agent.m_sequencer);


        // Drop objection if no UVM test is running
        phase.drop_objection(this);

    endtask : run_phase

endclass : ExDeStage_00
