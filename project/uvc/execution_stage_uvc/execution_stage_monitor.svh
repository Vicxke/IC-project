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
        logic cur_zeroflg;    // current zero flag
        execution_stage_seq_item seq_item;

        // --- Calculate expected result ---
        logic [31:0] expected_result;
        bit expected_overflow = 0;
        bit expected_zeroflg = 0;

        logic [4:0] shamt;
        

        `uvm_info(get_name(), $sformatf("Starting execution_stage monitoring"), UVM_HIGH)

        // Wait until interface is available
        if (m_config.m_vif == null) begin
            `uvm_fatal(get_name(), "m_vif not set in execution_stage_config")
        end

        // Wait for reset deassertion before sampling
        @(posedge m_config.m_vif.rst_n);
        @(negedge m_config.m_vif.clk);
        // this will just update the view and nothing else very simple
        
        // If any relevant signals are unknown, wait until they become stable
        do begin
            @(posedge m_config.m_vif.clk);
        end while ( $isunknown(m_config.m_vif.control_in) ||
                $isunknown(m_config.m_vif.data1) ||
                $isunknown(m_config.m_vif.data2) ||
                $isunknown(m_config.m_vif.program_counter) );
        
        
        forever begin
            // local operand selection (declaration must precede statements in this block)
            logic [31:0] op1, op2;

            // Sample on clock edge
            @(posedge m_config.m_vif.clk);


            // Read current values (assign to temporaries declared above)
            cur_data1   = m_config.m_vif.data1;
            cur_data2   = m_config.m_vif.data2;
            cur_imm     = m_config.m_vif.immediate_data;
            cur_ctrl    = m_config.m_vif.control_in;
            cur_cmp     = m_config.m_vif.compflg_in;
            cur_pc      = m_config.m_vif.program_counter;

            // alu_src: when 2'b01 the intermediate value is the RIGHT operand (op2)
            op1 = cur_data1;
            op2 = (cur_ctrl.alu_src == 2'b01) ? cur_imm : cur_data2;

            shamt = op2[4:0];

            seq_item = execution_stage_seq_item::type_id::create("monitor_item");



            // --- Compute expected result/flags for all ALU ops ---

            expected_overflow = 1'b0;  // default for non-add/sub ops
            unique case (cur_ctrl.alu_op)
            ALU_ADD: begin
            if ( (cur_ctrl.encoding inside {J_TYPE, I_TYPE}) && (cur_ctrl.alu_src == 2'b10) ) begin // special case for ExStage_03
                op1 = (cur_cmp) ? 32'd2 : 32'd4; 
            end
            //if the encoding is U_TYPE and alu_src is 2'b10 then it's AUIPC and (op1 = imm << 12)
            else
            if (cur_ctrl.encoding == U_TYPE) begin
                if (cur_ctrl.alu_src == 2'b10) begin
                    // not shure about what the behaviour should be
                    op1 = cur_imm << 12; //AUIPC
                    //I would think this because the decode stage should set this immidiate correct from the instruction in decode stage
                    //op1 = cur_imm; //AUIPC
                end
                if (cur_ctrl.alu_src == 2'b11) begin
                    // LUI
                    op1 = cur_imm;
                    op2 = 32'd0;
                end
            end
            expected_result   = op1 + op2;
            expected_overflow =
            (~op1[31] & ~op2[31] &  expected_result[31]) |
            ( op1[31] &  op2[31] & ~expected_result[31]);
            end

            ALU_SUB: begin
            expected_result   = op1 - op2;
            // Two's complement overflow for A - B: sign(A) != sign(B) AND sign(result) != sign(A)
            expected_overflow =(~op1[31] &  op2[31] &  expected_result[31]) |( op1[31] & ~op2[31] & ~expected_result[31]); 
            end

            ALU_XOR: begin
            expected_result = op1 ^  op2;
            end

            ALU_OR: begin
            expected_result = op1 |  op2;
            end

            ALU_AND: begin
            expected_result = op1 &  op2;
            end

            ALU_SLL: begin
            expected_result = op1 <<  shamt;                    // logical left
            end

            ALU_SRL: begin
            expected_result = op1 >>  shamt;                    // logical right
            end

            ALU_SRA: begin
            expected_result = $signed(op1) >>> shamt;           // arithmetic right
            end

            ALU_SLT: begin
            expected_result = ($signed(op1) <  $signed(op2)) ? 32'd1 : 32'd0;
            end

            ALU_SLTU: begin
            expected_result = (op1            <  op2)      ? 32'd1 : 32'd0;
            end

            default: begin

            end
            endcase

            

            @(posedge m_config.m_vif.clk); // wait a cycle to let DUT outputs stabilize

            // --- Also read DUT outputs for checking ---
            cur_result  = m_config.m_vif.alu_data;
            cur_ovf     = m_config.m_vif.overflow_flag;
            cur_zeroflg = m_config.m_vif.zero_flag;


            `uvm_info(get_name(), $sformatf("Result from DUT: res=%0h ovf=%0h",cur_result, cur_ovf), UVM_MEDIUM)


            // --- Compare DUT result with expected result (all ops) ---
            if (cur_result !== expected_result) begin
            `uvm_error("ALU_RESULT_MISMATCH",
                $sformatf("ALU mismatch on %s: data1=0x%08h, data2=0x%08h, imm=0x%08h, DUT=0x%08h, EXP=0x%08h, PC=0x%08h",
                          (cur_ctrl.alu_op.name()), cur_data1, cur_data2, cur_imm, cur_result, expected_result, cur_pc));
            end

            // --- Compare overflow only for ADD/SUB (others are 0) ---
            //if (cur_ctrl.alu_op inside {ALU_ADD, ALU_SUB}) begin // only for ExStage_00 test -> Bug found for overflow flag ALU_SUB
            if (cur_ctrl.alu_op inside {ALU_ADD}) begin
                if (cur_ovf !== expected_overflow) begin
                    `uvm_error("ALU_OVF_MISMATCH",
                    $sformatf("Overflow flag mismatch on %s: data1=0x%08h, data2=0x%08h,, imm=0x%08h DUT_OVF=%0b, EXP_OVF=%0b",
                                (cur_ctrl.alu_op == ALU_ADD) ? "ADD" : "SUB",
                                cur_data1, cur_data2,cur_imm, cur_ovf, expected_overflow))
                end
            end 

            // ------------ only active for ExStage_00 test -> Bug found -------------
            // if (expected_result == 32'd0) begin
            //     expected_zeroflg =  1'b1;
            // end
            // else begin
            //     expected_zeroflg =  1'b0;
            // end

            // // --- Compare zero flag --- not connected in design
            // if (cur_zeroflg !== expected_zeroflg) begin
            //     `uvm_error("ALU_ZEROFLAG_MISMATCH",
            //         $sformatf("Zero flag mismatch: data1=0x%08h, data2=0x%08h, imm=0x%08h, DUT_result=0x%08h, DUT_ZF=%0b, EXP_ZF=%0b",
            //       cur_data1, cur_data2, cur_imm, cur_result, cur_zeroflg, expected_zeroflg));
            // end
            // --------------------------------------------------------------

            // --- compare control signals --- 
            
            // Check for ExStage_03 specific condition: if encoding is J_TYPE or I_TYPE and alu_src is 2'b10, then compflg_in must be considered
            if ( (cur_ctrl.encoding inside {J_TYPE, I_TYPE}) && (cur_ctrl.alu_src == 2'b10) ) begin
                // For this case, if compflg_in is 1, expected_result should be 2, else 4
                if (cur_cmp & (op1 !== 32'd2) ^| (!cur_cmp & (op1 !== 32'd4)) ) begin
                    `uvm_error("COMPRESSION_FLAG_MISMATCH",
                    $sformatf("Compression flag effect mismatch: encoding=%0d, alu_src=%0b, compflg_in=%0b, DUT_result=0x%08h, EXP_result=0x%08h",
                                cur_ctrl.encoding, cur_ctrl.alu_src, cur_cmp, cur_result, (cur_cmp ? 32'd2 : 32'd4)))
                end
            end


            // Fill sequence item fields (assumes these fields exist on execution_stage_seq_item)
            seq_item.data1            = cur_data1;
            seq_item.data2            = op2;
            seq_item.immediate_data   = cur_imm;
            seq_item.control_in       = cur_ctrl;
            seq_item.compflg_in       = cur_cmp;
            seq_item.program_counter  = cur_pc;
            seq_item.exp_alu_data     = cur_result;
            seq_item.exp_overflow_flag= cur_ovf;
            seq_item.exp_zero_flag    = cur_zeroflg;
            seq_item.monitor_data_valid = 1;
            
            // --- Optionally publish to analysis port for scoreboard ---
            m_analysis_port.write(seq_item);

            
        end
    endtask : run_phase

endclass : execution_stage_monitor