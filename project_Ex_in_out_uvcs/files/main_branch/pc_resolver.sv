/*
Changelog:
- (Sky) 2025-04-21: Initial. This will handle Branch instructions as well as Jumps    
- (Sky) 2025-05-03: Add branch_decider instance     
- (Sky) 2025-05-05: Add resolve output for branch prediction buffer update     
*/
`timescale 1ns / 1ps

import common::*;
 

module pc_resolver(
    input control_type control,
    input logic [31:0] pc,
    input instruction_type instruction,
    input logic compflg,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input compressed_encoding_type comp,
    input logic [31:0] immediate_data,
    output logic change_pc_decision, //1 for changing PC
    output logic resolve,         //create a pulse 
    output logic [31:0] target_pc
);
    localparam logic [6:0] JALR = 7'b1100111;
    logic branch_result;

    assign change_pc_decision = (control.encoding == J_TYPE)?  1'b1 :
                                (((instruction.opcode == JALR)&&(compflg==1'b0))||((compflg==1'b1)&&(control.encoding == I_TYPE)&&(comp==CR_TYPE)))?  1'b1 :
                                (control.is_branch)?           branch_result : 1'b0;  
                             
    assign resolve            = (control.is_branch)?           1'b1 : 1'b0;  

    always_comb begin
        target_pc = 32'd0;
        case (control.encoding)
            B_TYPE: begin
                target_pc = pc + immediate_data;
            end
            J_TYPE : begin  //JAL
                target_pc = pc + immediate_data;
            end
            I_TYPE : begin //JALR
                target_pc =  rs1_data + immediate_data;
            end
        endcase
    end

branch_decider inst_branch_decider(
    //input
    .control(control),
    .instruction(instruction),
    .rs1_data(rs1_data[31:0]),
    .rs2_data(rs2_data[31:0]),
    //output
    .branch_result(branch_result) //1 for taken, 0 for not taken
);



endmodule