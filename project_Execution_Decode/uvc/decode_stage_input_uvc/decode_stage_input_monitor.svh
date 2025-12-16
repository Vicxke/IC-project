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

        bit instr_valid;



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
            @(posedge m_config.m_vif.clk);
            `uvm_info(get_name(), $sformatf("instr_valid=%0b", m_config.m_vif.instr_valid), UVM_LOW);
            if (m_config.m_vif.instr_valid) begin
            
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

                
                seq_item.instruction = cur_instruction;
                seq_item.pc          = cur_pc;
                seq_item.compflg     = cur_compflg;
                seq_item.write_en    = cur_write_en;
                seq_item.write_id    = cur_write_id;
                seq_item.write_data  = cur_write_data;
                seq_item.mux_data1   = cur_mux_data1;
                seq_item.mux_data2   = cur_mux_data2;
                
                seq_item.monitor_data_valid = 1;
                // `uvm_info(get_name(), $sformatf("decode input scoreboard: Write data=0x%0h",seq_item.write_data), UVM_LOW);
                // --- Optionally publish to analysis port for scoreboard ---
                m_analysis_port.write(seq_item);
                @(negedge m_config.m_vif.clk); // wait so decode output monitor can read as well
                m_config.m_vif.instr_valid = 0;
            end

            
        end
    endtask : run_phase

endclass : decode_stage_input_monitor