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
        execution_stage_output_seq_item seq_item;


        if (m_config.m_vif == null) begin
            `uvm_fatal(get_name(), "m_vif not set in execution_stage_output_config")
        end

        // Optional: auf Reset warten
        @(negedge m_config.m_vif.rst_n);
        @(posedge m_config.m_vif.clk);


        forever begin
            @(posedge m_config.m_vif.clk);
            `uvm_info(get_name(), $sformatf("Clock edge + valid bit=%0b", m_config.m_vif.instr_valid_ex_in), UVM_LOW);
            if (m_config.m_vif.instr_valid_ex_in) begin
                seq_item = execution_stage_output_seq_item::type_id::create("monitor_item");

                // Outputs direkt auf dieser Flanke lesen
                seq_item.alu_data      = m_config.m_vif.alu_data;
                seq_item.memory_data   = m_config.m_vif.memory_data;
                seq_item.overflow_flag = m_config.m_vif.overflow_flag;
                // zero_flag gibt's im IF nicht – also weglassen oder auf 0 setzen
                // seq_item.zero_flag     = m_config.m_vif.zero_flag;
                seq_item.control_out   = m_config.m_vif.control_out;
                seq_item.compflg_out   = m_config.m_vif.compflg_out;
                seq_item.instr_valid_ex_in = m_config.m_vif.instr_valid_ex_in;

                @(posedge m_config.m_vif.clk); // wait for calulaton of expected results in scoreboard

                // Send immediately - execution is combinatorial, no pipeline delay
                `uvm_info(get_name(), $sformatf("EX-output scoreboard=0x%0h",seq_item.alu_data), UVM_LOW);

                m_analysis_port.write(seq_item);
                m_config.m_vif.instr_valid_ex_in = 0;
            end
        end
    endtask : run_phase

endclass : execution_stage_output_monitor