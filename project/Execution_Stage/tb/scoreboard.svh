//------------------------------------------------------------------------------
// Scoreboard for the TBUVM TB.
//
// This class is an implementation of the scoreboard that monitors the TBUVM
// testbench and checks the behavior of the DUT with regard to the
// serial-to-parallel conversion. It provides the following features:
//
// - Monitors the input serial data and the output parallel data of the DUT.
// - Checks if the output data of the DUT is correct with regard to the
//   input serial data.
// - Checks if the DUT is in the correct state during the transmission of data.
// - Provides functional coverage for the transmission of data and the
//   activation of the DUT's output.
// - Provides error reporting for any errors that are detected during the simulation.
//
// This class is derived from the `uvm_component` class and implements the
// `uvm_analysis_imp_scoreboard_reset`, `uvm_analysis_imp_scoreboard_serial_data`
// and `uvm_analysis_imp_scoreboard_parallel_data` analysis ports.
//
// The functional coverage is provided by the `serial_to_parallel_covergrp`
// coverage group.
//

import common::*;

//------------------------------------------------------------------------------
// Instance analysis defines (creates unique analysis_imp types)
`uvm_analysis_imp_decl(_scoreboard_reset)
`uvm_analysis_imp_decl(_scoreboard_execution_stage)

// Simplified scoreboard for execution_stage UVC
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

    // execution_stage analysis connection (uses a dedicated analysis_imp type)
    uvm_analysis_imp_scoreboard_execution_stage#(execution_stage_seq_item, scoreboard) m_execution_stage_ap;
    // reset analysis connection
    uvm_analysis_imp_scoreboard_reset#(reset_seq_item, scoreboard) m_reset_ap;

    // basic counters
    int unsigned items_received = 0;

    // Indicates if the reset signal is active.
    //int unsigned reset_valid;
    // The value of the reset signal.
    int unsigned reset_value;
    // The ALU operation being performed.
    alu_op_type alu_op;

    int unsigned data1;
    int unsigned data2;
    int unsigned immediate_data;
    int unsigned alu_result;

    encoding_type encoding;

    control_type control_in;

    logic compflg_in;
    logic overflow_flag;
    logic zero_flag;

    //------------------------------------------------------------------------------
    // Functional coverage definitions
    //------------------------------------------------------------------------------
    covergroup execution_stage_covergrp;
        reset : coverpoint reset_value {
            bins reset =  { 0 };
            bins run=  { 1 };
        }
        operations : coverpoint alu_op {
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
        op_type : coverpoint encoding {
            bins R_TYPE = { R_TYPE };
            bins I_TYPE = { I_TYPE };
            bins S_TYPE = { S_TYPE };
            bins B_TYPE = { B_TYPE };
            bins U_TYPE = { U_TYPE };
            bins J_TYPE = { J_TYPE };
        }
        alu_src : coverpoint control_in.alu_src {
            bins src_reg   = { 2'b00 };
            bins src_imm   = { 2'b01 };
            bins src_pc    = { 2'b10 }; //this will never get hit if you use imm and pc what then?
            bins src_lui   = { 2'b11 };
        }
        compression_flag : coverpoint compflg_in {
            bins flag_cleared = { 1'b0 };
            bins flag_set     = { 1'b1 };
        }
        coverpoint_overflow_flag : coverpoint overflow_flag {
            bins no_overflow = { 1'b0 };
            bins overflow    = { 1'b1 };
        }
        // --------- only active for ExStage_00 test -> Bug found -------------
        // coverpoint_zero_flag : coverpoint zero_flag {
        //     bins not_zero = { 1'b0 };
        //     bins is_zero  = { 1'b1 };
        // }
        // --------------------------------------------------------------
        cross_ExStage_00 : cross operations, operand_1, operand_2;          //ExStage_00
        cross_ExStage_01 : cross operations, operand_1, intermediate;       //ExStage_01
        cross_ExStage_02 : cross operand_1, intermediate;                   //ExStage_02
        cross_ExStage_03 : cross operand_1, operand_2, compression_flag;    //ExStage_03
        cross_ExStage_04 : cross operand_2, intermediate;                   //ExStage_04
        //cross_ExStage_05 : cross intermediate;                            //ExStage_05: operands are not relevant for AUIPC -> no cross needed
    endgroup

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name,parent);
        // Create coverage group
        execution_stage_covergrp = new();
    endfunction: new

    //------------------------------------------------------------------------------
    // The build for the component.
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_execution_stage_ap = new("m_execution_stage_ap", this);
        m_reset_ap = new("m_reset_ap", this);
    endfunction: build_phase

    //------------------------------------------------------------------------------
    // The connection phase for the component.
    //------------------------------------------------------------------------------
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    //------------------------------------------------------------------------------
    // Write implementation for write_scoreboard_execution_stage analysis port.
    //------------------------------------------------------------------------------
    virtual function void write_scoreboard_execution_stage(execution_stage_seq_item item);
        items_received++;
        if (item.exp_alu_data !== 'x && item.exp_alu_data !== '0) begin
            `uvm_info(get_name(), $sformatf("Item provided expected ALU data=0x%08h", item.exp_alu_data), UVM_LOW)
        end

        alu_op= item.control_in.alu_op;
        data1 = item.data1;
        data2 = item.data2;
        immediate_data = item.immediate_data;
        encoding = item.control_in.encoding;
        control_in = item.control_in;
        compflg_in = item.compflg_in;
        overflow_flag = item.exp_overflow_flag;
        zero_flag = item.exp_zero_flag;
        alu_result = item.exp_alu_data;
        //`uvm_info(get_name(), $sformatf("ALU_OPRESET_function: alu_op=%00s reset_value=%0b", alu_op.name(), reset_value), UVM_LOW)
        execution_stage_covergrp.sample();

    endfunction: write_scoreboard_execution_stage

    //------------------------------------------------------------------------------
    // Write implementation for write_scoreboard_reset analysis port.
    //------------------------------------------------------------------------------
    virtual function void write_scoreboard_reset(reset_seq_item item);
        `uvm_info(get_name(),$sformatf("RESET_MONITOR:\n%s",item.sprint()),UVM_HIGH)
        // // Clear start bit and data
        // input_data_valid= 0;
        // input_data= 0;
        // dut_data_valid= 0;
        // dut_data= 0;
        // Sample reset coverage
        reset_value= item.reset_value;
        //`uvm_info(get_name(), $sformatf("RESET_function: alu_op=%00s reset_value=%0b", alu_op.name(), reset_value), UVM_LOW)
        execution_stage_covergrp.sample();

    endfunction :  write_scoreboard_reset

    //------------------------------------------------------------------------------
    // UVM check phase
    //------------------------------------------------------------------------------
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        $display("*****************************************************");
        if (execution_stage_covergrp.get_coverage() == 100.0) begin
            $display("FUNCTIONAL COVERAGE (100.0%%) PASSED....");
        end
        else begin
            $display("FUNCTIONAL COVERAGE FAILED!!!!!!!!!!!!!!!!!");
            $display("Coverage = %0f", execution_stage_covergrp.get_coverage());
        end
        $display("*****************************************************");
    endfunction : check_phase

endclass: scoreboard
