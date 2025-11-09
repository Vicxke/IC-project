class execution_stage_monitor extends uvm_monitor;
    `uvm_component_param_utils(execution_stage_monitor)

    // Execution stage uVC configuration object.
    execution_stage_config               m_config;
    // Monitor analysis port.
    uvm_analysis_port #(execution_stage_seq_item)  m_analysis_port;

    // Constructor - read config from config DB and create analysis port.
    function new(string name = "execution_stage_monitor", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(execution_stage_config)::get(this, "", "execution_stage_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find execution_stage_config in config DB")
        end
        m_analysis_port = new("m_execution_stage_analysis_port", this);
    endfunction : new

    // Build phase (kept minimal)
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

        `uvm_info(get_name(), $sformatf("Starting execution_stage monitoring"), UVM_HIGH)

        // Wait until interface is available
        if (m_config.m_vif == null) begin
            `uvm_fatal(get_name(), "m_vif not set in execution_stage_config")
        end

        // Wait for reset deassertion before sampling
        @(posedge m_config.m_vif.rst_n);
        @(negedge m_config.m_vif.clk);

        forever begin
            // Sample on clock edge
            @(posedge m_config.m_vif.clk);

            // Read current values
            logic [31:0] cur_data1   = m_config.m_vif.data1;
            logic [31:0] cur_data2   = m_config.m_vif.data2;
            logic [31:0] cur_imm     = m_config.m_vif.immediate_data;
            control_type cur_ctrl    = m_config.m_vif.control_in;
            logic cur_cmp            = m_config.m_vif.compflg_in;
            logic [31:0] cur_pc      = m_config.m_vif.program_counter;

            // On first sample, publish unconditionally
            if (first_sample ||
                (cur_data1   !== prev_data1) ||
                (cur_data2   !== prev_data2) ||
                (cur_imm     !== prev_immediate_data) ||
                (cur_ctrl    != prev_control_in) ||
                (cur_cmp     !== prev_compflg_in) ||
                (cur_pc      !== prev_program_counter)) begin

                execution_stage_seq_item seq_item;
                seq_item = execution_stage_seq_item::type_id::create("monitor_item");

                // Fill sequence item fields (assumes these fields exist on execution_stage_seq_item)
                seq_item.data1            = cur_data1;
                seq_item.data2            = cur_data2;
                seq_item.immediate_data   = cur_imm;
                seq_item.control_in       = cur_ctrl;
                seq_item.compflg_in       = cur_cmp;
                seq_item.program_counter  = cur_pc;
                seq_item.monitor_data_valid = 1;

                // Write to analysis port
                m_analysis_port.write(seq_item);

                // Update previous values
                prev_data1            = cur_data1;
                prev_data2            = cur_data2;
                prev_immediate_data   = cur_imm;
                prev_control_in       = cur_ctrl;
                prev_compflg_in       = cur_cmp;
                prev_program_counter  = cur_pc;
                first_sample = 0;
            end
        end
    endtask : run_phase

endclass : execution_stage_monitor