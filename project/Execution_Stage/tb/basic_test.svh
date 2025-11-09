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
class basic_test extends uvm_test;
    `uvm_component_utils(basic_test)

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
    virtual task run_phase(uvm_phase phase);
        // Run the test as defined in base test
        reset_seq reset;
        super.run_phase(phase);
        // Start the data generation loop
        //do a simple reset first
        reset = reset_seq::type_id::create("reset");
        reset.start(m_tb_env.m_reset_agent.m_sequencer);
        #10;
        //test some basic add operand
        execute_stage = execution_stage_seq::type_id::create("execute_stage");
        
        execute_stage.data1 = 32'd15;
        execute_stage.data2 = 32'd27;

        initial begin
            // wait until reset is released
            wait (tb_reset_n == 1);
            @(posedge tb_clock);

            // simple addition test: drive inputs on the execution_stage interface
            i_execute_if.data1       = 32'd15;
            i_execute_if.data2       = 32'd27;
            // If ALU_ADD is defined in package `common`, replace '0 with that (e.g. `ALU_ADD`)
            i_execute_if.control_in  = '0; // assume add encoding = 0
            i_execute_if.immediate_data = 32'd0;
            i_execute_if.compflg_in = 1'b0;
            i_execute_if.program_counter = 32'd0;

            // let DUT compute for a few clocks
            @(posedge tb_clock);
            repeat (5) @(posedge tb_clock);

            $display("SIMPLE ADD: %0d + %0d => alu_data=0x%08h (%0d)",
                    i_execute_if.data1, i_execute_if.data2, i_execute_if.alu_data, i_execute_if.alu_data);
        end
        
    endtask : run_phase

endclass : basic_test
