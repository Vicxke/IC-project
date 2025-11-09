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
class basic_test extends base_test;
    `uvm_component_utils(basic_test)

    //------------------------------------------------------------------------------
    // FUNCTION: new
    // Creates and constructs the sequence.
    //------------------------------------------------------------------------------
    function new (string name = "test",uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // FUNCTION: build_phase
    // Function to build the class within UVM build phase.
    //------------------------------------------------------------------------------
    virtual function void build_phase(uvm_phase phase);
        // Create and build TB environment as defined in base test
        super.build_phase(phase);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // FUNCTION: run_phase
    // Start UVM test in running phase.
    //------------------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        // Simple directed ALU ADD smoke test
        import common::*;
        top_config m_top_cfg;

        // retrieve top configuration (set in tb_top)
        if (!uvm_config_db#(top_config)::get(null, "tb_top", "top_config", m_top_cfg)) begin
            `uvm_fatal(get_name(), "Cannot get top_config from config DB")
        end

        // wait until virtual interface is assigned
        if (m_top_cfg.m_execution_stage_config.m_vif == null) begin
            `uvm_fatal(get_name(), "execution_stage interface not set in top_config.m_execution_stage_config.m_vif")
        end

        `uvm_info(get_name(), "Starting simple ALU add smoke test", UVM_LOW)

        // wait for reset deassertion then a couple clocks
        @(posedge m_top_cfg.m_execution_stage_config.m_vif.rst_n);
        @(posedge m_top_cfg.m_execution_stage_config.m_vif.clk);
        @(posedge m_top_cfg.m_execution_stage_config.m_vif.clk);

        // Prepare operands and control
        logic [31:0] a = 32'd7;
        logic [31:0] b = 32'd5;
        control_type ctrl;
        ctrl.alu_op = ALU_ADD;
        ctrl.encoding = R_TYPE;
        ctrl.alu_src = 2'b00;
        ctrl.mem_read = 0;
        ctrl.mem_write = 0;
        ctrl.reg_write = 0;
        ctrl.mem_to_reg = 0;
        ctrl.is_branch = 0;
        ctrl.funct3 = 3'd0;

        // Drive inputs (non-UVM direct drive for quick smoke test)
        m_top_cfg.m_execution_stage_config.m_vif.data1 = a;
        m_top_cfg.m_execution_stage_config.m_vif.data2 = b;
        m_top_cfg.m_execution_stage_config.m_vif.immediate_data = 0;
        m_top_cfg.m_execution_stage_config.m_vif.control_in = ctrl;
        m_top_cfg.m_execution_stage_config.m_vif.compflg_in = 0;
        m_top_cfg.m_execution_stage_config.m_vif.program_counter = 0;

        // Let DUT sample and produce output
        @(posedge m_top_cfg.m_execution_stage_config.m_vif.clk);
        @(posedge m_top_cfg.m_execution_stage_config.m_vif.clk);

        // Read output
        logic [31:0] alu_out = m_top_cfg.m_execution_stage_config.m_vif.alu_data;
        logic ovf = m_top_cfg.m_execution_stage_config.m_vif.overflow_flag;

        // Check result
        if (alu_out === (a + b)) begin
            `uvm_info(get_name(), $sformatf("ALU ADD OK: %0d + %0d = %0d", a, b, alu_out), UVM_LOW)
        end else begin
            `uvm_error(get_name(), $sformatf("ALU ADD MISMATCH: %0d + %0d -> got %0d", a, b, alu_out))
        end

        // Continue with base behavior
        no_of_data_loop = 40;
        super.run_phase(phase);
        
    endtask : run_phase

endclass : basic_test
