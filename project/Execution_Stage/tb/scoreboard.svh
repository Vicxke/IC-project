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
        cross_op_reset : cross operations, reset;
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
        `uvm_info(get_name(), $sformatf("EXECUTION_STAGE_MONITOR: %s", item.convert2string()), UVM_MEDIUM)
        items_received++;
        if (item.exp_alu_data !== 'x && item.exp_alu_data !== '0) begin
            `uvm_info(get_name(), $sformatf("Item provided expected ALU data=0x%08h", item.exp_alu_data), UVM_LOW)
        end

        alu_op= item.control_in.alu_op;
        `uvm_info(get_name(), $sformatf("ALU_OPRESET_function: alu_op=%00s reset_value=%0b", alu_op.name(), reset_value), UVM_LOW)
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
        `uvm_info(get_name(), $sformatf("RESET_function: alu_op=%00s reset_value=%0b", alu_op.name(), reset_value), UVM_LOW)
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
