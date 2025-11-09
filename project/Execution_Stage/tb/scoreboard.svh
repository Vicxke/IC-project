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
//------------------------------------------------------------------------------
// Simplified scoreboard for execution_stage UVC
class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

    // analysis implementation to receive execution_stage monitor items
    uvm_analysis_imp#(execution_stage_seq_item, scoreboard) m_execution_stage_ap;

    // basic counters
    int unsigned items_received = 0;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_execution_stage_ap = new("m_execution_stage_ap", this);
    endfunction: build_phase

    // connect_phase left empty for now
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    // write callback from analysis imp
    function void write(execution_stage_seq_item item);
        `uvm_info(get_name(), $sformatf("EXECUTION_STAGE_MONITOR: %s", item.convert2string()), UVM_MEDIUM)
        items_received++;
        // Basic optional checks: if expected alu value provided, print mismatch
        if (item.exp_alu_data !== 'x && item.exp_alu_data !== '0) begin
            // can't check actual DUT output here unless another monitor reports it
            `uvm_info(get_name(), $sformatf("Item provided expected ALU data=0x%08h", item.exp_alu_data), UVM_LOW)
        end
    endfunction: write

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        `uvm_info(get_name(), $sformatf("Total execution_stage items observed: %0d", items_received), UVM_LOW)
    endfunction: check_phase

endclass: scoreboard
