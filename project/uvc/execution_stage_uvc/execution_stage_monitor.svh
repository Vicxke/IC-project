import common::*;

class execution_stage_monitor extends uvm_monitor;
    `uvm_component_param_utils(execution_stage_monitor)

    // Execution stage uVC configuration object.
    execution_stage_config m_config;
    // Monitor analysis port.
    uvm_analysis_port #(execution_stage_seq_item)  m_analysis_port;

    //------------------------------------------------------------------------------
    // Constructor - read config from config DB and create analysis port.
    //------------------------------------------------------------------------------
    function new(string name = "execution_stage_monitor", uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db#(execution_stage_config)::get(this, "", "execution_stage_config", m_config)) begin
            `uvm_fatal(get_name(), "Cannot find execution_stage_config in config DB")
        end
        m_analysis_port = new("m_execution_stage_analysis_port", this);
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
        logic [31:0] cur_data1, cur_data2, cur_imm, cur_pc, cur_result;
        control_type cur_ctrl;
        logic cur_cmp;
        logic cur_ovf;        // current overflow flag
        execution_stage_seq_item seq_item;

        // --- Calculate expected result ---
        logic [31:0] expected_result;
        bit expected_overflow = 0;

        logic [4:0] shamt;
        shamt = cur_data2[4:0];

        `uvm_info(get_name(), $sformatf("Starting execution_stage monitoring"), UVM_HIGH)

        // Wait until interface is available
        if (m_config.m_vif == null) begin
            `uvm_fatal(get_name(), "m_vif not set in execution_stage_config")
        end

        // Wait for reset deassertion before sampling
        @(posedge m_config.m_vif.rst_n);
        @(negedge m_config.m_vif.clk);

        // this will just update the view and nothing else very simple
        forever begin
            // Sample on clock edge
            @(posedge m_config.m_vif.clk);

            // Read current values (assign to temporaries declared above)
            cur_data1   = m_config.m_vif.data1;
            cur_data2   = m_config.m_vif.data2;
            cur_imm     = m_config.m_vif.immediate_data;
            cur_ctrl    = m_config.m_vif.control_in;
            cur_cmp     = m_config.m_vif.compflg_in;
            cur_pc      = m_config.m_vif.program_counter;

            // --- Also read DUT outputs for checking ---
            cur_result  = m_config.m_vif.alu_data;
            cur_ovf     = m_config.m_vif.overflow_flag;

            // On first sample, publish unconditionally so whenever the values change we just update them


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

            // --- Compute expected result/flags for all ALU ops ---
            

            expected_overflow = 1'b0;  // default for non-add/sub ops
            unique case (cur_ctrl.alu_op)
            ALU_ADD: begin
                expected_result   = cur_data1 + cur_data2;
                expected_overflow =
                    (~cur_data1[31] & ~cur_data2[31] &  expected_result[31]) |
                    ( cur_data1[31] &  cur_data2[31] & ~expected_result[31]);
            end

            ALU_SUB: begin
                expected_result   = cur_data1 - cur_data2;
                // Two's complement overflow for A - B: sign(A) != sign(B) AND sign(result) != sign(A)
                expected_overflow =
                    (~cur_data1[31] &  cur_data2[31] &  expected_result[31]) |
                    ( cur_data1[31] & ~cur_data2[31] & ~expected_result[31]);
            end

            ALU_XOR:  expected_result = cur_data1 ^  cur_data2;
            ALU_OR:   expected_result = cur_data1 |  cur_data2;
            ALU_AND:  expected_result = cur_data1 &  cur_data2;

            ALU_SLL:  expected_result = cur_data1 <<  shamt;                    // logical left
            ALU_SRL:  expected_result = cur_data1 >>  shamt;                    // logical right
            ALU_SRA:  expected_result = $signed(cur_data1) >>> shamt;           // arithmetic right

            ALU_SLT:  expected_result = ($signed(cur_data1) <  $signed(cur_data2)) ? 32'd1 : 32'd0;
            ALU_SLTU: expected_result = (cur_data1            <  cur_data2)      ? 32'd1 : 32'd0;

            default: begin
                // DUT default falls back to ADD
                expected_result   = cur_data1 + cur_data2;
                expected_overflow =
                    (~cur_data1[31] & ~cur_data2[31] &  expected_result[31]) |
                    ( cur_data1[31] &  cur_data2[31] & ~expected_result[31]);
            end
            endcase

            // --- Compare DUT result with expected result (all ops) ---
            if (cur_result !== expected_result) begin
            `uvm_error("ALU_CHECK",
                $sformatf("ALU mismatch on %s: data1=0x%08h, data2=0x%08h, DUT=0x%08h, EXP=0x%08h, PC=0x%08h",
                        (cur_ctrl.alu_op.name()),  // if enum has .name(); otherwise map manually
                        cur_data1, cur_data2, cur_result, expected_result, cur_pc))
            end

            // --- Compare overflow only for ADD/SUB (others are 0) ---
            if (cur_ctrl.alu_op inside {ALU_ADD, ALU_SUB}) begin
            if (cur_ovf !== expected_overflow) begin
                `uvm_warning("ALU_OVF_MISMATCH",
                $sformatf("Overflow flag mismatch on %s: data1=0x%08h, data2=0x%08h, DUT_OVF=%0b, EXP_OVF=%0b",
                            (cur_ctrl.alu_op == ALU_ADD) ? "ADD" : "SUB",
                            cur_data1, cur_data2, cur_ovf, expected_overflow))
            end
            end else begin
            if (cur_ovf !== 1'b0) begin
                `uvm_warning("ALU_OVF_MISMATCH",
                $sformatf("Overflow flag should be 0 for non-ADD/SUB op %0d: DUT_OVF=%0b", cur_ctrl.alu_op, cur_ovf))
            end
            end

            // --- Optionally publish to analysis port for scoreboard ---
            m_analysis_port.write(seq_item);

            
        end
    endtask : run_phase

endclass : execution_stage_monitor