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
    int unsigned reset_valid;
    // The value of the reset signal.
    int unsigned reset_value;
    // The ALU operation being performed.
    alu_op_type alu_op;

    //------------------------------------------------------------------------------
    // Functional coverage definitions
    //------------------------------------------------------------------------------
    covergroup execution_stage_covergrp;
        reset : coverpoint reset_value iff (reset_valid) {
            bins reset =  { 0 };
            bins run=  { 1 };
        }
        operations : coverpoint alu_op {
            bins ADD =  { ALU_ADD };
            bins SUB =  { ALU_SUB };
            bins MUL =  { ALU_MUL };
            bins DIV =  { ALU_DIV };
        }
        cross_op_reset : cross operations, reset;
    endgroup

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_execution_stage_ap = new("m_execution_stage_ap", this);
        m_reset_ap = new("m_reset_ap", this);
    endfunction: build_phase

    // connect_phase left empty for now
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    //------------------------------------------------------------------------------
    // Write implementation called by analysis_imp adapters
    //------------------------------------------------------------------------------
    virtual function void write_scoreboard_execution_stage(execution_stage_seq_item item);
        `uvm_info(get_name(), $sformatf("EXECUTION_STAGE_MONITOR: %s", item.convert2string()), UVM_MEDIUM)
        items_received++;
        if (item.exp_alu_data !== 'x && item.exp_alu_data !== '0) begin
            `uvm_info(get_name(), $sformatf("Item provided expected ALU data=0x%08h", item.exp_alu_data), UVM_LOW)
        end
    endfunction: write_scoreboard_execution_stage

    virtual function void write_scoreboard_reset(reset_seq_item item);
        `uvm_info(get_name(), $sformatf("RESET_MONITOR: delay=%0d length=%0d value=%0b", item.reset_delay, item.reset_length, item.reset_value), UVM_LOW)
    endfunction: write_scoreboard_reset

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        `uvm_info(get_name(), $sformatf("Total execution_stage items observed: %0d", items_received), UVM_LOW)
    endfunction: check_phase

endclass: scoreboard
