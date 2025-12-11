import common::*;

class decode_stage_input_seq_item extends uvm_sequence_item;

    // DUT inputs
    randc instruction_type instruction;
    randc logic [31:0] pc;
    randc bit compflg;
    randc bit write_en;
    randc logic [4:0] write_id;
    randc logic [31:0] write_data;
    randc logic [31:0] mux_data1;
    randc logic [31:0] mux_data2;

    // Optional expected outputs (for scoreboard checks)
    // logic [31:0] exp_alu_data;
    // bit exp_overflow_flag;
    // bit exp_zero_flag;
    logic [5:0] exp_reg_rd_id;
    logic [31:0] exp_read_data1;
    logic [31:0] exp_read_data2;
    logic [4:0] exp_rs1_id;
    logic [4:0] exp_rs2_id;
    logic [31:0] exp_immediate_data;
    control_type exp_control_in;
    bit exp_select_target_pc;
    bit exp_resolve;
    logic [31:0] exp_calculated_target_pc;
    bit exp_squash_after_J;
    bit exp_squash_after_JALR;
    bit exp_compflg_out;
    // monitor helper flag
    bit monitor_data_valid;

    // Fields for printing/packing
    `uvm_object_utils_begin(decode_stage_input_seq_item)
    `uvm_field_int(instruction, UVM_ALL_ON)
    `uvm_field_int(pc, UVM_ALL_ON)
    `uvm_field_int(compflg, UVM_ALL_ON)
    `uvm_field_int(write_en, UVM_ALL_ON)
    `uvm_field_int(write_id, UVM_ALL_ON)
    `uvm_field_int(write_data, UVM_ALL_ON)
    `uvm_field_int(mux_data1, UVM_ALL_ON)
    `uvm_field_int(mux_data2, UVM_ALL_ON)

    `uvm_field_int(exp_reg_rd_id, UVM_ALL_ON)
    `uvm_field_int(exp_read_data1, UVM_ALL_ON)
    `uvm_field_int(exp_read_data2, UVM_ALL_ON)
    `uvm_field_int(exp_rs1_id, UVM_ALL_ON)
    `uvm_field_int(exp_rs2_id, UVM_ALL_ON)
    `uvm_field_int(exp_immediate_data, UVM_ALL_ON)
    `uvm_field_int(exp_control_in, UVM_ALL_ON)
    `uvm_field_int(exp_select_target_pc, UVM_ALL_ON)
    `uvm_field_int(exp_resolve, UVM_ALL_ON)
    `uvm_field_int(exp_calculated_target_pc, UVM_ALL_ON)
    `uvm_field_int(exp_squash_after_J, UVM_ALL_ON)
    `uvm_field_int(exp_squash_after_JALR, UVM_ALL_ON)
    `uvm_field_int(exp_compflg_out, UVM_ALL_ON)

    
    // monitor_data_valid intentionally not registered
    `uvm_object_utils_end

    // Constructor
    function new(string name = "decode_stage_input_seq_item");
        super.new(name);
    endfunction: new

endclass: decode_stage_input_seq_item