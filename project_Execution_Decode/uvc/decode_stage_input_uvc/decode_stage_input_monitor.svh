import common::*;

class decode_stage_input_monitor extends uvm_monitor;
    `uvm_component_param_utils(decode_stage_input_monitor)

    // decode_stage uVC configuration object.
    decode_stage_input_config m_config;
    // Monitor analysis port.
    uvm_analysis_port #(decode_stage_input_seq_item)  m_analysis_port;

    //------------------------------------------------------------------------------
    // Constructor - read config from config DB and create analysis port.
    //------------------------------------------------------------------------------
    function new(string name = "decode_stage_input_monitor", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(decode_stage_input_config)::get(this, "", "decode_stage_input_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find decode_stage_input_config in config DB")
        end
        m_analysis_port = new("m_decode_stage_input_analysis_port", this);
    endfunction : new
    //------------------------------------------------------------------------------
    // Build phase (kept minimal)
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    // Run phase - sample interface signals on clock and publish seq_items when values change.
    task run_phase(uvm_phase phase);
        decode_stage_input_seq_item seq_item;

        // DUT inputs
        instruction_type cur_instruction;
        logic [31:0] cur_pc;
        bit cur_compflg;
        bit cur_write_en;
        logic [4:0] cur_write_id;
        logic [31:0] cur_write_data;
        logic [31:0] cur_mux_data1;
        logic [31:0] cur_mux_data2;

        // DUT outputs
        logic [5:0] cur_reg_rd_id;
        logic [31:0] cur_read_data1;
        logic [31:0] cur_read_data2;
        logic [4:0] cur_rs1_id;
        logic [4:0] cur_rs2_id;
        logic [31:0] cur_immediate_data;
        control_type cur_control_signals;
        bit cur_select_target_pc;
        bit cur_resolve;
        logic [31:0] cur_calculated_target_pc;
        bit cur_squash_after_J;
        bit cur_squash_after_JALR;
        bit cur_compflg_out;

        `uvm_info(get_name(), $sformatf("Starting decode_stage monitoring"), UVM_HIGH)

        // Wait until interface is available
        if (m_config.m_vif == null) begin
            `uvm_fatal(get_name(), "m_vif not set in decode_stage_input_config")
        end

        // Wait for reset deassertion before sampling
        @(posedge m_config.m_vif.rst_n);
        @(negedge m_config.m_vif.clk);
        // this will just update the view and nothing else very simple
        
        // // If any relevant signals are unknown, wait until they become stable
        // do begin
        //     @(posedge m_config.m_vif.clk);
        // end while ( $isunknown(m_config.m_vif.control_in) ||
        //         $isunknown(m_config.m_vif.data1) ||
        //         $isunknown(m_config.m_vif.data2) ||
        //         $isunknown(m_config.m_vif.program_counter) );
        
        
        forever begin
            // // local operand selection (declaration must precede statements in this block)
            // logic [31:0] op1, op2;

            // // Sample on clock edge
            // @(posedge m_config.m_vif.clk);


            // Read current values (assign to temporaries declared above)
            cur_instruction = m_config.m_vif.instruction;
            cur_pc       = m_config.m_vif.pc;
            cur_compflg    = m_config.m_vif.compflg;
            cur_write_en    = m_config.m_vif.write_en;
            cur_write_id    = m_config.m_vif.write_id;
            cur_write_data    = m_config.m_vif.write_data;
            cur_mux_data1    = m_config.m_vif.mux_data1;
            cur_mux_data2    = m_config.m_vif.mux_data2;

            // // alu_src: when 2'b01 the intermediate value is the RIGHT operand (op2)
            // op1 = cur_data1;
            // op2 = (cur_control_in.alu_src == 2'b01) ? cur_imm : cur_data2;
            // shamt = op2[4:0];

            seq_item = decode_stage_input_seq_item::type_id::create("monitor_item");

            

            @(posedge m_config.m_vif.clk); // wait a cycle to let DUT outputs stabilize

            // --- Also read DUT outputs for checking ---
            // cur_result  = m_config.m_vif.alu_data;
            // cur_ovf     = m_config.m_vif.overflow_flag;
            // cur_zeroflg = m_config.m_vif.zero_flag;
            // cur_memory_data = m_config.m_vif.memory_data;
            // cur_control_out = m_config.m_vif.control_out;
            // cur_compflg_out = m_config.m_vif.compflg_out;

            cur_reg_rd_id        = m_config.m_vif.reg_rd_id;
            cur_read_data1      = m_config.m_vif.read_data1;
            cur_read_data2      = m_config.m_vif.read_data2;
            cur_rs1_id          = m_config.m_vif.rs1_id;
            cur_rs2_id          = m_config.m_vif.rs2_id;
            cur_immediate_data  = m_config.m_vif.immediate_data;
            cur_control_signals = m_config.m_vif.control_signals;
            cur_select_target_pc = m_config.m_vif.select_target_pc;
            cur_resolve         = m_config.m_vif.resolve;
            cur_calculated_target_pc = m_config.m_vif.calculated_target_pc;
            cur_squash_after_J  = m_config.m_vif.squash_after_J;
            cur_squash_after_JALR = m_config.m_vif.squash_after_JALR;
            cur_compflg_out     = m_config.m_vif.compflg_out;



            // Fill sequence item fields (assumes these fields exist on decode_stage_input_seq_item)
            seq_item.exp_reg_rd_id            = cur_reg_rd_id;
            seq_item.exp_read_data1          = cur_read_data1;
            seq_item.exp_read_data2          = cur_read_data2;
            seq_item.exp_rs1_id              = cur_rs1_id;
            seq_item.exp_rs2_id              = cur_rs2_id;
            seq_item.exp_immediate_data      = cur_immediate_data;
            seq_item.exp_control_in         = cur_control_signals;
            seq_item.exp_select_target_pc    = cur_select_target_pc;
            seq_item.exp_resolve             = cur_resolve;
            seq_item.exp_calculated_target_pc = cur_calculated_target_pc;
            seq_item.exp_squash_after_J     = cur_squash_after_J;
            seq_item.exp_squash_after_JALR  = cur_squash_after_JALR;
            seq_item.exp_compflg_out        = cur_compflg_out;

            seq_item.monitor_data_valid = 1;
            
            // --- Optionally publish to analysis port for scoreboard ---
            m_analysis_port.write(seq_item);

            
        end
    endtask : run_phase

endclass : decode_stage_input_monitor