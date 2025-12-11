/*
Changelog:
- (Sky) 2025-04-25: Initial. To solve branch decisions.     
- (Sky) 2025-05-03: Finish up on all the branch instructions deciding logic     
*/
`timescale 1ns / 1ps

import common::*;

module branch_decider(
    input control_type control,
    input instruction_type instruction,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    output logic branch_result //1 for taken, 0 for not taken
);
    //funct3
    localparam logic [2:0] BEQ  = 3'd0;
    localparam logic [2:0] BNE  = 3'd1;
    localparam logic [2:0] BLT  = 3'd4;
    localparam logic [2:0] BGE  = 3'd5;
    localparam logic [2:0] BLTU = 3'd6; //Unsigned
    localparam logic [2:0] BGEU = 3'd7; //Unsigned


    always_comb begin
        branch_result = 0;
        case (control.funct3)
            BEQ: begin
                if(rs1_data == rs2_data)
                    branch_result = 1;
                else
                    branch_result = 0;
            end
            BNE : begin  
                if(rs1_data == rs2_data)
                    branch_result = 0;
                else
                    branch_result = 1;
            end
            BLT : begin  
                if($signed(rs1_data) < $signed(rs2_data))
                    branch_result = 1;
                else
                    branch_result = 0;
            end
            BGE : begin  
                if($signed(rs1_data) >= $signed(rs2_data))
                    branch_result = 1;
                else
                    branch_result = 0;
            end 
            BLTU : begin  
                if(rs1_data < rs2_data)
                    branch_result = 1;
                else
                    branch_result = 0;
            end
            BGEU : begin  
                if(rs1_data >= rs2_data)
                    branch_result = 1;
                else
                    branch_result = 0;
            end 
        endcase
    end
    
endmodule
