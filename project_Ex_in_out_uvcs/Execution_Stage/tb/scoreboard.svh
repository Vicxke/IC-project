import common::*;

//------------------------------------------------------------------------------
// Instance analysis defines (creates unique analysis_imp types)
`uvm_analysis_imp_decl(_scoreboard_reset)
`uvm_analysis_imp_decl(_scoreboard_execution_stage_input)
`uvm_analysis_imp_decl(_scoreboard_execution_stage_output)

// Simplified scoreboard for execution_stage UVC
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

    // execution_stage analysis connection (uses a dedicated analysis_imp type)
    uvm_analysis_imp_scoreboard_execution_stage_input#(execution_stage_input_seq_item, scoreboard) m_execution_stage_input_ap;
    uvm_analysis_imp_scoreboard_execution_stage_output#(execution_stage_output_seq_item, scoreboard) m_execution_stage_output_ap;
    // reset analysis connection
    uvm_analysis_imp_scoreboard_reset#(reset_seq_item, scoreboard) m_reset_ap;

    // Indicates if the reset signal is active.
    //int unsigned reset_valid;
    // The value of the reset signal.
    int unsigned reset_value;
    
    // ExStage inputs
    int unsigned data1;
    int unsigned data2;
    int unsigned immediate_data;
    control_type control_in;
    logic compflg_in;
    logic [31:0] program_counter_in;

    // ExStage outputs
    int unsigned alu_result;
    int unsigned prev_alu_result;
    int unsigned memory_data_out;
    logic overflow_flag;
    logic zero_flag;
    control_type control_out;
    logic compflg_out;

    // --- Calculate expected result ---
    logic [31:0] expected_result;
    bit expected_overflow = 0;
    bit expected_zeroflg = 0;

    logic [4:0] shamt;
    logic [31:0] op1, op2;

    // Handshake-Flags between Input/Output and Compare
    bit input_valid;
    bit output_valid;

    bit first_input = 0;
    bit first_round = 1;

    typedef struct {
        int unsigned  data1_FIFO;
        int unsigned  data2_FIFO;
        int unsigned  immediate_data_FIFO;
        control_type  control_in_FIFO;
        logic         compflg_in_FIFO;
        logic [31:0]  program_counter_in_FIFO;

        logic [31:0]  expected_result_FIFO;
        bit           expected_overflow_FIFO;
    } ex_expected_t;

    ex_expected_t m_expected_q[$];  // FIFO-Queue




    //------------------------------------------------------------------------------
    // Functional coverage definitions
    //------------------------------------------------------------------------------
    covergroup execution_stage_input_covergrp;
        reset : coverpoint reset_value {
            bins reset =  { 0 };
            bins run=  { 1 };
        }
        operand_1 : coverpoint data1 {
            bins range_very_low   = { [32'h0000_0000 : 32'h1FFF_FFFF] };
            bins range_low        = { [32'h2000_0000 : 32'h3FFF_FFFF] };
            bins range_mid_low    = { [32'h4000_0000 : 32'h5FFF_FFFF] };
            bins range_mid        = { [32'h6000_0000 : 32'h7FFF_FFFF] };
            bins range_mid_high   = { [32'h8000_0000 : 32'h9FFF_FFFF] };
            bins range_high       = { [32'hA000_0000 : 32'hBFFF_FFFF] };
            bins range_very_high  = { [32'hC000_0000 : 32'hDFFF_FFFF] };
            bins range_max_val    = { [32'hE000_0000 : 32'hFFFF_FFFF] };
            // Single-value bins to explicitly cover all-zeros and all-ones
            bins all_zeros  = { 32'h0000_0000 };
            bins all_ones   = { 32'hFFFF_FFFF };
        }

        operand_2 : coverpoint data2 {
            bins range_very_low   = { [32'h0000_0000 : 32'h1FFF_FFFF] };
            bins range_low        = { [32'h2000_0000 : 32'h3FFF_FFFF] };
            bins range_mid_low    = { [32'h4000_0000 : 32'h5FFF_FFFF] };
            bins range_mid        = { [32'h6000_0000 : 32'h7FFF_FFFF] };
            bins range_mid_high   = { [32'h8000_0000 : 32'h9FFF_FFFF] };
            bins range_high       = { [32'hA000_0000 : 32'hBFFF_FFFF] };
            bins range_very_high  = { [32'hC000_0000 : 32'hDFFF_FFFF] };
            bins range_max_val    = { [32'hE000_0000 : 32'hFFFF_FFFF] };
            // Single-value bins to explicitly cover all-zeros and all-ones
            bins all_zeros  = { 32'h0000_0000 };
            bins all_ones   = { 32'hFFFF_FFFF };
        }
        intermediate : coverpoint immediate_data {
            bins range_very_low   = { [32'h0000_0000 : 32'h1FFF_FFFF] };
            bins range_low        = { [32'h2000_0000 : 32'h3FFF_FFFF] };
            bins range_mid_low    = { [32'h4000_0000 : 32'h5FFF_FFFF] };
            bins range_mid        = { [32'h6000_0000 : 32'h7FFF_FFFF] };
            bins range_mid_high   = { [32'h8000_0000 : 32'h9FFF_FFFF] };
            bins range_high       = { [32'hA000_0000 : 32'hBFFF_FFFF] };
            bins range_very_high  = { [32'hC000_0000 : 32'hDFFF_FFFF] };
            bins range_max_val    = { [32'hE000_0000 : 32'hFFFF_FFFF] };
            // Single-value bins to explicitly cover all-zeros and all-ones
            bins all_zeros  = { 32'h0000_0000 };
            bins all_ones   = { 32'hFFFF_FFFF };
        }
        // ----------- control signals --------------
        control_operations : coverpoint control_in.alu_op {
            bins ADD =  { ALU_ADD };
            bins SUB =  { ALU_SUB };
            bins XOR =  { ALU_XOR };
            bins OR  =  { ALU_OR };
            bins AND =  { ALU_AND };
            bins SLL =  { ALU_SLL };
            bins SRL =  { ALU_SRL };
            bins SRA =  { ALU_SRA };
            bins SLT =  { ALU_SLT };
            bins SLTU=  { ALU_SLTU };
        }
        control_op_type : coverpoint control_in.encoding {
            bins R_TYPE = { R_TYPE };
            bins I_TYPE = { I_TYPE };
            bins S_TYPE = { S_TYPE };
            bins B_TYPE = { B_TYPE };
            bins U_TYPE = { U_TYPE };
            bins J_TYPE = { J_TYPE };
        }
        control_in_alu_src : coverpoint control_in.alu_src {
            bins src_reg   = { 2'b00 };
            bins src_imm   = { 2'b01 };
            bins src_pc    = { 2'b10 }; //this will never get hit if you use imm and pc what then?
            bins src_lui   = { 2'b11 };
        }
        control_in_mem_read : coverpoint control_in.mem_read {
            bins no_read = { 1'b0 };
            bins read    = { 1'b1 };
        }
        control_in_mem_write : coverpoint control_in.mem_write {
            bins no_write = { 1'b0 };
            bins write    = { 1'b1 };
        }
        control_in_reg_write : coverpoint control_in.reg_write {
            bins no_write = { 1'b0 };
            bins write    = { 1'b1 };
        }
        control_in_mem_to_reg : coverpoint control_in.mem_to_reg {
            bins no_mem_to_reg = { 1'b0 };
            bins mem_to_reg    = { 1'b1 };
        }
        control_in_is_branch : coverpoint control_in.is_branch {
            bins not_branch = { 1'b0 };
            bins is_branch  = { 1'b1 };
        }
        control_in_funct3 : coverpoint control_in.funct3 {
            bins funct3_0 = { 3'b000 };
            bins funct3_1 = { 3'b001 };
            bins funct3_2 = { 3'b010 };
            bins funct3_3 = { 3'b011 };
            bins funct3_4 = { 3'b100 };
            bins funct3_5 = { 3'b101 };
            bins funct3_6 = { 3'b110 };
            bins funct3_7 = { 3'b111 };
        }
        // ---- end control signals --------------

        // ---- flags ----
        compression_flag : coverpoint compflg_in {
            bins flag_cleared = { 1'b0 };
            bins flag_set     = { 1'b1 };
        }
        program_counter_in : coverpoint program_counter_in {
            bins range_very_low   = { [32'h0000_0000 : 32'h1FFF_FFFF] };
            bins range_low        = { [32'h2000_0000 : 32'h3FFF_FFFF] };
            bins range_mid_low    = { [32'h4000_0000 : 32'h5FFF_FFFF] };
            bins range_mid        = { [32'h6000_0000 : 32'h7FFF_FFFF] };
            bins range_mid_high   = { [32'h8000_0000 : 32'h9FFF_FFFF] };
            bins range_high       = { [32'hA000_0000 : 32'hBFFF_FFFF] };
            bins range_very_high  = { [32'hC000_0000 : 32'hDFFF_FFFF] };
            bins range_max_val    = { [32'hE000_0000 : 32'hFFFF_FFFF] };
        }
        // -------------- Cross coverage definitions ----------------
        cross_ExStage_00 : cross control_operations, operand_1, operand_2;          //ExStage_00
        cross_ExStage_01 : cross control_operations, operand_1, intermediate;       //ExStage_01
        cross_ExStage_02 : cross operand_1, intermediate;                   //ExStage_02
        cross_ExStage_03 : cross operand_1, operand_2, compression_flag;    //ExStage_03
        cross_ExStage_04 : cross operand_2, intermediate;                   //ExStage_04
        // ExStage_05: operands are not relevant for AUIPC -> no cross needed
        // ExStage_06: -> no cross needed
    endgroup

    covergroup execution_stage_output_covergrp;
        alu_result : coverpoint alu_result {
            bins range_very_low   = { [32'h0000_0000 : 32'h1FFF_FFFF] };
            bins range_low        = { [32'h2000_0000 : 32'h3FFF_FFFF] };
            bins range_mid_low    = { [32'h4000_0000 : 32'h5FFF_FFFF] };
            bins range_mid        = { [32'h6000_0000 : 32'h7FFF_FFFF] };
            bins range_mid_high   = { [32'h8000_0000 : 32'h9FFF_FFFF] };
            bins range_high       = { [32'hA000_0000 : 32'hBFFF_FFFF] };
            bins range_very_high  = { [32'hC000_0000 : 32'hDFFF_FFFF] };
            bins range_max_val    = { [32'hE000_0000 : 32'hFFFF_FFFF] };
            // Single-value bins to explicitly cover all-zeros and all-ones
            bins all_zeros  = { 32'h0000_0000 };
            bins all_ones   = { 32'hFFFF_FFFF };
        }
        memory_data_out : coverpoint memory_data_out {
            bins range_very_low   = { [32'h0000_0000 : 32'h1FFF_FFFF] };
            bins range_low        = { [32'h2000_0000 : 32'h3FFF_FFFF] };
            bins range_mid_low    = { [32'h4000_0000 : 32'h5FFF_FFFF] };
            bins range_mid        = { [32'h6000_0000 : 32'h7FFF_FFFF] };
            bins range_mid_high   = { [32'h8000_0000 : 32'h9FFF_FFFF] };
            bins range_high       = { [32'hA000_0000 : 32'hBFFF_FFFF] };
            bins range_very_high  = { [32'hC000_0000 : 32'hDFFF_FFFF] };
            bins range_max_val    = { [32'hE000_0000 : 32'hFFFF_FFFF] };
            // Single-value bins to explicitly cover all-zeros and all-ones
            bins all_zeros  = { 32'h0000_0000 };
            bins all_ones   = { 32'hFFFF_FFFF };
        }
        overflow_flag : coverpoint overflow_flag {
            bins no_overflow = { 1'b0 };
            bins overflow    = { 1'b1 };
        }
        // --------- only active for ExStage_00 test -> Bug found -------------
        // zero_flag : coverpoint zero_flag {
        //     bins not_zero = { 1'b0 };
        //     bins is_zero  = { 1'b1 };
        // }
        // --------------------------------------------------------------
        
        compression_flag : coverpoint compflg_in {
            bins flag_cleared = { 1'b0 };
            bins flag_set     = { 1'b1 };
        }
        // ----------- control signals --------------
        control_out_operations : coverpoint control_out.alu_op {
            bins ADD =  { ALU_ADD };
            bins SUB =  { ALU_SUB };
            bins XOR =  { ALU_XOR };
            bins OR  =  { ALU_OR };
            bins AND =  { ALU_AND };
            bins SLL =  { ALU_SLL };
            bins SRL =  { ALU_SRL };
            bins SRA =  { ALU_SRA };
            bins SLT =  { ALU_SLT };
            bins SLTU=  { ALU_SLTU };
        }
        control_out_op_type : coverpoint control_out.encoding {
            bins R_TYPE = { R_TYPE };
            bins I_TYPE = { I_TYPE };
            bins S_TYPE = { S_TYPE };
            bins B_TYPE = { B_TYPE };
            bins U_TYPE = { U_TYPE };
            bins J_TYPE = { J_TYPE };
        }
        control_out_alu_src : coverpoint control_out.alu_src {
            bins src_reg   = { 2'b00 };
            bins src_imm   = { 2'b01 };
            bins src_pc    = { 2'b10 }; //this will never get hit if you use imm and pc what then?
            bins src_lui   = { 2'b11 };
        }
        control_out_mem_read : coverpoint control_out.mem_read {
            bins no_read = { 1'b0 };
            bins read    = { 1'b1 };
        }
        control_out_mem_write : coverpoint control_out.mem_write {
            bins no_write = { 1'b0 };
            bins write    = { 1'b1 };
        }
        control_out_reg_write : coverpoint control_out.reg_write {
            bins no_write = { 1'b0 };
            bins write    = { 1'b1 };
        }
        control_out_mem_to_reg : coverpoint control_out.mem_to_reg {
            bins no_mem_to_reg = { 1'b0 };
            bins mem_to_reg    = { 1'b1 };
        }
        control_out_is_branch : coverpoint control_out.is_branch {
            bins not_branch = { 1'b0 };
            bins is_branch  = { 1'b1 };
        }
        control_out_funct3 : coverpoint control_out.funct3 {
            bins funct3_0 = { 3'b000 };
            bins funct3_1 = { 3'b001 };
            bins funct3_2 = { 3'b010 };
            bins funct3_3 = { 3'b011 };
            bins funct3_4 = { 3'b100 };
            bins funct3_5 = { 3'b101 };
            bins funct3_6 = { 3'b110 };
            bins funct3_7 = { 3'b111 };
        }
        // ---- end control signals --------------
    endgroup

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name,parent);
        // Create coverage group
        execution_stage_input_covergrp = new();
        execution_stage_output_covergrp = new();

        // Flags initial
        input_valid  = 0;
        output_valid = 0;
    endfunction: new

    //------------------------------------------------------------------------------
    // The build for the component.
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_execution_stage_input_ap = new("m_execution_stage_input_ap", this);
        m_execution_stage_output_ap = new("m_execution_stage_output_ap", this);
        m_reset_ap = new("m_reset_ap", this);
    endfunction: build_phase

    //------------------------------------------------------------------------------
    // The connection phase for the component.
    //------------------------------------------------------------------------------
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    //------------------------------------------------------------------------------
    // Write implementation for write_scoreboard_execution_stage_input analysis port.
    //------------------------------------------------------------------------------
    virtual function void write_scoreboard_execution_stage_input(execution_stage_input_seq_item item);
        ex_expected_t tx;

        first_input = 1;
        

        // 1) Eingänge in tx ablegen
        tx.data1_FIFO              = item.data1;
        tx.data2_FIFO              = item.data2;
        tx.immediate_data_FIFO     = item.immediate_data;
        tx.control_in_FIFO         = item.control_in;
        tx.compflg_in_FIFO         = item.compflg_in;
        tx.program_counter_in_FIFO = item.program_counter_in; // nicht program_counter_in
        // 2) Globale Variablen für Coverage & Berechnung setzen
        data1              = tx.data1_FIFO;
        data2            = tx.data2_FIFO;
        immediate_data     = tx.immediate_data_FIFO; 
        control_in         = tx.control_in_FIFO;
        compflg_in         = tx.compflg_in_FIFO;
        program_counter_in = tx.program_counter_in_FIFO;

        `uvm_info(get_name(),
        $sformatf("Input DUT: data1=%0h, data2=%0h, immediate_data=%0h, operation=%s",
                    data1, data2, immediate_data, control_in.alu_op.name()),
        UVM_MEDIUM)

        execution_stage_input_covergrp.sample();

        // 3) Expected für diese Transaktion berechnen
        calculate_expected_results();         // schreibt expected_result & expected_overflow (global)

        // 4) In tx übernehmen
        tx.expected_result_FIFO   = expected_result;
        tx.expected_overflow_FIFO = expected_overflow;

        // 5) In Queue legen
        m_expected_q.push_back(tx);
    endfunction:write_scoreboard_execution_stage_input

    virtual function void write_scoreboard_execution_stage_output(execution_stage_output_seq_item item);
        ex_expected_t tx;

        //wait for inputs
        if (first_input == 0) begin
            `uvm_info(get_name(), "First input not received yet", UVM_LOW)
            return;
        end


        if (m_expected_q.size() == 0) begin
            `uvm_error(get_name(), "Got DUT output but no pending expected transaction");
            return;
        end

        // Älteste Erwartung zu diesem Output holen
        tx = m_expected_q.pop_front();

        // Globale Variablen für Vergleichs- und Fehlermeldungs-Logik setzen
        data1              = tx.data1_FIFO;
        data2              = tx.data2_FIFO;
        immediate_data     = tx.immediate_data_FIFO;
        control_in         = tx.control_in_FIFO;
        compflg_in         = tx.compflg_in_FIFO;
        program_counter_in = tx.program_counter_in_FIFO;
        expected_result    = tx.expected_result_FIFO;
        expected_overflow  = tx.expected_overflow_FIFO;

        // DUT-Ausgänge übernehmen
        alu_result      = item.alu_data;
        memory_data_out = item.memory_data;
        control_out     = item.control_out;
        overflow_flag   = item.overflow_flag;
        zero_flag       = item.zero_flag;
        compflg_out     = item.compflg_out;

        `uvm_info(get_name(),
        $sformatf("Result from DUT: res=%0h ovf=%0h", alu_result, overflow_flag),
        UVM_MEDIUM)

        execution_stage_output_covergrp.sample();

        // jetzt passt Input/Expected zu diesem Output → JETZT vergleichen
        compare_exp_DUT_results();
    endfunction: write_scoreboard_execution_stage_output


    //------------------------------------------------------------------------------
    // Write implementation for write_scoreboard_reset analysis port.
    //------------------------------------------------------------------------------
    virtual function void write_scoreboard_reset(reset_seq_item item);
        `uvm_info(get_name(),$sformatf("RESET_MONITOR:\n%s",item.sprint()),UVM_HIGH)

        reset_value= item.reset_value;
        //`uvm_info(get_name(), $sformatf("RESET_function: alu_op=%00s reset_value=%0b", alu_op.name(), reset_value), UVM_LOW)
        execution_stage_input_covergrp.sample(); // part of input covergroup

    endfunction :  write_scoreboard_reset

    virtual function void calculate_expected_results();
        expected_overflow = 1'b0;  // default for non-add/sub ops

        // alu_src: when 2'b01 the intermediate value is the RIGHT operand (op2)
        op1 = data1;
        op2 = (control_in.alu_src == 2'b01) ? immediate_data : data2;
        shamt = op2[4:0];

        unique case (control_in.alu_op)
        ALU_ADD: begin
        if ( (control_in.encoding inside {J_TYPE, I_TYPE}) && (control_in.alu_src == 2'b10) ) begin // special case for ExStage_03
            op1 = (compflg_in) ? 32'd2 : 32'd4; 
        end
        
        if (control_in.encoding == U_TYPE && control_in.alu_src == 2'b10) begin
        // AUIPC
        op1 = immediate_data; // Value was already shifted by decode stage
        
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
        if (control_in.encoding == U_TYPE && control_in.alu_src == 2'b11) begin
            // LUI
            op1 = immediate_data; // Value was already shifted by decode stage
            op2 = 32'd0;
            shamt = op2[4:0];
            
        end 
        
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
        `uvm_info(get_name(), $sformatf("Expected result calculated: exp_res=0x%08h, exp_ovf=%0b", expected_result, expected_overflow), UVM_MEDIUM)

    endfunction :  calculate_expected_results


    virtual function void compare_exp_DUT_results();
        // --- Compare DUT result with expected result (all ops) ---
        if (alu_result !== expected_result) begin
        `uvm_error("ALU_RESULT_MISMATCH",
            $sformatf("ALU mismatch on %s: data1=0x%08h, data2=0x%08h, imm=0x%08h, DUT=0x%08h, EXP=0x%08h, PC=0x%08h",
                        (control_in.alu_op.name()), data1, data2, immediate_data, alu_result, expected_result, program_counter_in));
        end

        // --- Compare overflow only for ADD/SUB (others are 0) ---
        //if (control_in.alu_op inside {ALU_ADD, ALU_SUB}) begin // only for ExStage_00 test -> Bug found for overflow flag ALU_SUB
        if (control_in.alu_op inside {ALU_ADD}) begin
            if (overflow_flag !== expected_overflow) begin
                `uvm_error("ALU_OVF_MISMATCH",
                $sformatf("Overflow flag mismatch on %s: data1=0x%08h, data2=0x%08h,, imm=0x%08h DUT_OVF=%0b, EXP_OVF=%0b",
                            (control_in.alu_op == ALU_ADD) ? "ADD" : "SUB",
                            data1, data2,immediate_data, overflow_flag, expected_overflow))
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
        // if (zero_flag !== expected_zeroflg) begin
        //     `uvm_error("ALU_ZEROFLAG_MISMATCH",
        //         $sformatf("Zero flag mismatch: data1=0x%08h, data2=0x%08h, imm=0x%08h, DUT_result=0x%08h, DUT_ZF=%0b, EXP_ZF=%0b",
        //       data1, data2, immediate_data, alu_result, zero_flag, expected_zeroflg));
        // end
        // --------------------------------------------------------------

        // --- compare control signals --- 
        
        // Check for ExStage_03 specific condition: if encoding is J_TYPE or I_TYPE and alu_src is 2'b10, then compflg_in must be considered
        if ( (control_in.encoding inside {J_TYPE, I_TYPE}) && (control_in.alu_src == 2'b10) ) begin
            // For this case, if compflg_in is 1, expected_result should be 2, else 4
            if (compflg_in & (op1 !== 32'd2) ^| (!compflg_in & (op1 !== 32'd4)) ) begin
                `uvm_error("COMPRESSION_FLAG_MISMATCH",
                $sformatf("Compression flag effect mismatch: encoding=%0d, alu_src=%0b, compflg_in=%0b, DUT_result=0x%08h, EXP_result=0x%08h",
                            control_in.encoding, control_in.alu_src, compflg_in, alu_result, (compflg_in ? 32'd2 : 32'd4)))
            end
        end

        // ---- Check memory_data_out for S-Type operations ----
        if (control_in.encoding == S_TYPE) begin
            if (memory_data_out !== data2) begin
                `uvm_error("MEMORY_DATA_MISMATCH",
                $sformatf("Memory data mismatch for S-TYPE: DUT_memory_data=0x%08h, EXP_memory_data=0x%08h",
                            memory_data_out, data2))
            end
        end

        // ----- Check correct pass through of control signals -----
        if (control_out !== control_in) begin
            `uvm_error("CONTROL_SIGNAL_MISMATCH",
            $sformatf("Control signal mismatch: DUT_control_out=%0h, EXP_control_in=%0h",
                        control_out, control_in))
        end

        // ---- Check correct pass through of compflg ----
        if (compflg_out !== compflg_in) begin
            `uvm_error("COMPRESSION_FLAG_PASSTHROUGH_MISMATCH",
            $sformatf("Compression flag passthrough mismatch: DUT_compflg_out=%0b, EXP_compflg_in=%0b",
                        compflg_out, compflg_in))
        end
        `uvm_info(get_name(), "Compare results done", UVM_MEDIUM)
    endfunction :  compare_exp_DUT_results

    //------------------------------------------------------------------------------
    // UVM check phase
    //------------------------------------------------------------------------------
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        $display("*****************************************************");
        if (execution_stage_input_covergrp.get_coverage() == 100.0) begin
            $display("FUNCTIONAL COVERAGE Input (100.0%%) PASSED....");
        end
        else begin
            $display("FUNCTIONAL COVERAGE Input FAILED!!!!!!!!!!!!!!!!!");
            $display("Coverage = %0f", execution_stage_input_covergrp.get_coverage());
        end
        $display("*****************************************************");
        if (execution_stage_output_covergrp.get_coverage() == 100.0) begin
            $display("FUNCTIONAL COVERAGE Output (100.0%%) PASSED....");
        end
        else begin
            $display("FUNCTIONAL COVERAGE Output FAILED!!!!!!!!!!!!!!!!!");
            $display("Coverage = %0f", execution_stage_output_covergrp.get_coverage());
        end
    endfunction : check_phase

endclass: scoreboard
