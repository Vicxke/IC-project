/*
Changelog:
- (Sky) 2025-04-18: When instruction is JAL or JALR, pass PC to next stage ALU in order to perfrom rd = pc+4   
- (Sky) 2025-04-21: add branch resolver instance   
- (Sky) 2025-05-03: add ports for pc resolver   
- (Sky) 2025-05-05: add 1 more output port, resolve   
- (Sky) 2025-05-15: Add squash signal following JAL 
*/
`timescale 1ns / 1ps

import common::*;


module decode_stage(
    input clk,
    input reset_n,
    input instruction_type instruction,
    input logic [31:0] pc,
    input compflg,
    input logic write_en,
    input logic [4:0] write_id,
    input logic [31:0] write_data,
    input logic [31:0] mux_data1,
    input logic [31:0] mux_data2,
    output logic [5:0] reg_rd_id,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [4:0] rs1_id,
    output logic [4:0] rs2_id,
    output logic [31:0] immediate_data,
    output control_type control_signals,
    output logic        select_target_pc,
    output logic        resolve,
    output logic [31:0] calculated_target_pc,
    output logic        squash_after_J,
    output logic        squash_after_JALR,
    output logic compflg_out
);

    logic [31:0] rf_read_data1;
    logic [31:0] rf_read_data2;
    logic        change_pc_decision;   
    logic [31:0] target_pc;
    localparam opcode_JALR = 7'b1100111;
    logic [4:0] rs2_control;
    logic [4:0] rs1_control;
    logic [4:0] rd_control;
    control_type controls;
    compressed_encoding_type comp;   

    register_file rf_inst(
        .clk(clk),
        .reset_n(reset_n),
        .write_en(write_en),
        .read1_id(rs1_control),
        .read2_id(rs2_control),
        .write_id(write_id),
        .write_data(write_data),
        .read1_data(rf_read_data1),
        .read2_data(rf_read_data2)        
    );
    
    logic illegal_opcode;
    control inst_control(
        .clk(clk), 
        .reset_n(reset_n), 
        .instruction(instruction),
        .control(controls),
        .comp(comp),
        .illegal_opcode(illegal_opcode),
        .rs1_id(rs1_control),
        .rs2_id(rs2_control),
        .rd_id(reg_rd_id)
    );
    
    
    
    pc_resolver inst_pc_resolver(
    //inputs
    .control(controls),
    .pc(pc),
    .instruction(instruction),
    .rs1_data(mux_data1),
    .rs2_data(mux_data2),
    .compflg(compflg),
    .comp(comp),
    .immediate_data(immediate_data),
    //outputs
    .change_pc_decision(change_pc_decision), //1 for changing PC
    .resolve(resolve), 
    .target_pc(target_pc)
    );

   
   // assign reg_rd_id = instruction.rd;
    assign read_data1 = rf_read_data1;
    assign read_data2 = (controls.alu_src == 2'b10)? pc : rf_read_data2;
    //assign read_data2 = rf_read_data2;
    
    assign control_signals = controls;
    assign select_target_pc = change_pc_decision;
    assign calculated_target_pc = target_pc;
    //Insert NOP into ID stage itself after the first JAL!
    assign squash_after_J = (controls.encoding == J_TYPE)? 1'b1 : 1'b0;
    always_comb begin
    if(compflg==0) begin
    immediate_data = immediate_extension(instruction, controls.encoding);
    squash_after_JALR = (instruction.opcode == opcode_JALR)? 1'b1 : 1'b0;
    end
    else
    begin
        //insert immediate extension for compressed instructions here
        immediate_data = compressed_extension(instruction[15:0],comp);
        squash_after_JALR = ((instruction[1:0]==2'b10)&&(instruction[6:2]==5'd0)&&(instruction[15:13]==3'b100))? 1'b1 : 1'b0;
    end
    end
    assign compflg_out=compflg;
    assign rs1_id = rs1_control;
    assign rs2_id = rs2_control;
endmodule
