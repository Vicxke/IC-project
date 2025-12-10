import common::*;

class execution_stage_output_monitor extends uvm_monitor;
    `uvm_component_param_utils(execution_stage_output_monitor)

    // Execution stage uVC configuration object.
    execution_stage_output_config m_config;
    // Monitor analysis port.
    uvm_analysis_port #(execution_stage_output_seq_item)  m_analysis_port;

    //------------------------------------------------------------------------------
    // Constructor - read config from config DB and create analysis port.
    //------------------------------------------------------------------------------
    function new(string name = "execution_stage_output_monitor", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(execution_stage_output_config)::get(this, "", "execution_stage_output_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find execution_stage_output_config in config DB")
        end
        m_analysis_port = new("m_execution_stage_output_analysis_port", this);
    endfunction : new
    //------------------------------------------------------------------------------
    // Build phase (kept minimal)
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    // Run phase - sample interface signals on clock and publish seq_items when values change.
    task run_phase(uvm_phase phase);
        // Local previous-state variables for change detection.
        logic [31:0] prev_data1, prev_data2, prev_immediate_data, prev_program_counter;
        control_type prev_control_in;
        logic prev_compflg_in;
        bit first_sample = 1;

        // Declare per-sample temporaries and seq_item up-front so declarations precede any statements.
        logic [31:0] cur_data1, cur_data2, cur_imm, cur_pc, cur_result, cur_memory_data;
        
        control_type cur_control_in; // control input
        control_type cur_control_out; // control output

        logic cur_cmp;         // compression flag input
        logic cur_compflg_out; // compression flag output

        logic cur_ovf;        // current overflow flag
        logic cur_zeroflg;    // current zero flag
        execution_stage_output_seq_item seq_item;

        // --- Calculate expected result ---
        logic [31:0] expected_result;
        bit expected_overflow = 0;
        bit expected_zeroflg = 0;

        logic [4:0] shamt;

        encoding_type cur_opType;
        

        `uvm_info(get_name(), $sformatf("Starting execution_stage_output monitoring"), UVM_HIGH)

        // Wait until interface is available
        if (m_config.m_vif == null) begin
            `uvm_fatal(get_name(), "m_vif not set in execution_stage_output_config")
        end

        
        
        forever begin
            // Sample on clock edge
            @(posedge m_config.m_vif.clk);

            seq_item = execution_stage_output_seq_item::type_id::create("monitor_item");


            @(posedge m_config.m_vif.clk); // wait a cycle to let DUT outputs stabilize

            // --- Also read DUT outputs for checking ---
            cur_result  = m_config.m_vif.alu_data;
            cur_memory_data = m_config.m_vif.memory_data;
            cur_ovf     = m_config.m_vif.overflow_flag;
            cur_zeroflg = m_config.m_vif.zero_flag;
            cur_control_out = m_config.m_vif.control_out;
            cur_compflg_out = m_config.m_vif.compflg_out;
            cur_pc        = m_config.m_vif.program_counter;

            // Fill sequence item fields (assumes these fields exist on execution_stage_output_seq_item)
            seq_item.alu_data     = cur_result;
            seq_item.memory_data  = cur_memory_data;
            seq_item.overflow_flag= cur_ovf;
            seq_item.zero_flag    = cur_zeroflg;
            seq_item.control_out  = cur_control_out;
            seq_item.compflg_in       = cur_cmp;
            seq_item.program_counter  = cur_pc;


            `uvm_info(get_name(), $sformatf("UVC_output monitor: res=%0h ovf=%0h",cur_result, cur_ovf), UVM_MEDIUM)
            
            // --- Optionally publish to analysis port for scoreboard ---
            m_analysis_port.write(seq_item);

            
        end
    endtask : run_phase

endclass : execution_stage_output_monitor