/*
Changelog:
- (Sky) 2025-04-18: Add definition for decode J-type instruction   
- (Sky) 2025-04-21: Add definition for decode JALR instruction   
- (Jed) 2025-04-21: Add other instructions and decode stage exceptions
*/
`timescale 1ns / 1ps

import common::*;


module control(
    input clk,
    input reset_n,
    input instruction_type instruction, 
    output control_type control,
    output compressed_encoding_type comp,
    output logic illegal_opcode,
    output logic [4:0] rs1_id,
    output logic [4:0] rs2_id,
    output logic [4:0] rd_id
);

    // localparam logic [16:0] ADD_INSTRUCTION = {7'b0000000, 3'b000, 7'b0110011};
    // localparam logic [16:0] SUB_INSTRUCTION = {7'b0100000, 3'b000, 7'b0110011};
    // localparam logic [9:0] ADDI_INSTRUCTION = {3'b000, 7'b0010011};
    // localparam logic [9:0] LW_INSTRUCTION = {3'b010, 7'b0000011};
    // localparam logic [9:0] SW_INSTRUCTION = {3'b010, 7'b0100011};
    // localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};
    logic [15:0] inst_half;
    assign inst_half=instruction[15:0];
    always_comb begin
        control = '0;
        comp=CL_TYPE;
        illegal_opcode = 1'b0;
        rs1_id=instruction.rs1;
        rs2_id=instruction.rs2;
        rd_id=instruction.rd;
        if(inst_half[1:0]!=2'b11)
        begin
            case (inst_half[1:0])
            2'b00: begin
                if(inst_half[15:13]==3'b010)
                begin
                    comp=CL_TYPE;
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;                
                    control.mem_read = 1'b1;                
                    control.mem_to_reg = 1'b1;
                    control.funct3 = 3'b010;
                    rs1_id={2'b01,inst_half[9:7]};
                    rs2_id={5'b0};
                    rd_id={2'b01,inst_half[4:2]};
                    
                end
                else if(inst_half[15:13]==3'b110)
                begin
                    comp=CS_TYPE;
                    control.encoding = S_TYPE;
                    control.alu_src = 2'b01;
                    control.mem_write = 1'b1;
                    control.funct3 = 3'b010;
                    rs1_id={2'b01,inst_half[9:7]};
                    rs2_id={2'b01,inst_half[4:2]};
                    rd_id={5'b0};
                    
                end
          /**      else if(inst_half[15:13]==3'b000)
                begin
                    comp=CIW_TYPE;
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_ADD;
                    rs1_id={5'd2};
                    rs2_id={5'b0};
                    rd_id={2'b0,inst_half[4:2]};
                    
                end  */
            end
            2'b01: begin
                if(inst_half[15:10]==6'b100011)
                begin
                    comp=CA_TYPE;
                    case (inst_half[6:5])
                    2'b00: begin
                    control.encoding = R_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_op = ALU_SUB;
                    end
                    2'b01: begin
                    control.encoding = R_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_op = ALU_XOR;
                    end
                    2'b10: begin
                    control.encoding = R_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_op = ALU_OR;
                    end
                    2'b11: begin
                    control.encoding = R_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_op = ALU_AND;
                    end
                    endcase
                    rs1_id={2'b01,inst_half[9:7]};
                    rs2_id={2'b01, inst_half[4:2]};
                    rd_id={2'b01,inst_half[9:7]};
                end
                else if(inst_half[15:13]==3'b100)
                begin
                    comp=CB_TYPE;
                    case (inst_half[11:10])
                    2'b01: begin
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_SRA;
                    control.funct3=3'b100;
                        
                    end
                    2'b00: begin
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_SRL;
                    control.funct3=3'b100;
                        
                    end
                    2'b10: begin
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_AND;
                    control.funct3=3'b100;
                        
                    end
                    
                    endcase
                    rs1_id={2'b01,inst_half[9:7]};
                    rs2_id={5'b0};
                    rd_id={2'b01,inst_half[9:7]};
                end
                else if(inst_half[15:13]==3'b101)
                begin
                    comp=CJ_TYPE;
                    control.encoding = J_TYPE;
                    control.alu_src = 2'b10; // JAL, rd = pc + 4
                    control.reg_write = 1'b1;
                    control.funct3 = 3'b101;
                    rs1_id={5'b0};
                    rs2_id={5'b0};
                    rd_id={5'd0};
                end
                else if(inst_half[15:13]==3'b001)
                begin
                    comp=CJ_TYPE;
                    control.encoding = J_TYPE;
                    control.alu_src = 2'b10; // JAL, rd = pc + 4
                    control.reg_write = 1'b1;
                    control.funct3 = 3'b001;
                    rs1_id={5'b0};
                    rs2_id={5'b0};
                    rd_id={5'd1};
                end
                else if((inst_half[15:13]==3'b110)||(inst_half[15:13]==3'b111))
                begin
                    comp=CB_TYPE;
                    control.encoding = B_TYPE;
                    control.is_branch = 1'b1;
                    control.funct3={2'b00,inst_half[13]};
                    rs1_id={2'b01,inst_half[9:7]};
                    rs2_id={5'd0};
                    rd_id={5'd0};
                end
                else if(inst_half[15:13]==3'b010)
                begin
                    comp=CI_TYPE;
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_ADD;
                    rd_id={inst_half[11:7]};
                    rs2_id={5'd0};
                    rs1_id={5'd0};
                    
                end
                else if(inst_half[15:13]==3'b011)
                begin
                    comp=CI_TYPE;
                    control.encoding = U_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b11; 
                    control.alu_op = ALU_SLL;
                    rd_id={inst_half[11:7]};
                    rs2_id={5'd0};
                    rs1_id={5'd0};
                    
                end
                else if(inst_half[15:13]==3'b000)
                begin
                    comp=CI_TYPE;
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_ADD;
                    rd_id={inst_half[11:7]};
                    rs2_id={5'd0};
                    rs1_id={inst_half[11:7]};
                    
                end
                
            end
            2'b10: begin
                
                if(inst_half[15:12]==4'b1000)
                begin
                    comp=CR_TYPE;
                    if(inst_half[6:2]==5'd0)
                    begin
                        control.encoding = I_TYPE;
                        control.alu_src = 2'b10; // JALR, rd = pc + 2
                        control.reg_write = 1'b1;
                        rs1_id={inst_half[11:7]};
                        rs2_id={5'd0};
                        rd_id={5'd0};
                    end
                    else
                    begin
                        control.reg_write = 1'b1;
                        control.alu_op = ALU_ADD;
                        rd_id={inst_half[11:7]};
                        rs2_id=inst_half[6:2];
                        rs1_id={5'd0};
                    end    
                end
                else if(inst_half[15:12]==4'b1001)
                begin
                    comp=CR_TYPE;
                    if(inst_half[6:2]==5'd0)
                    begin
                        control.encoding = I_TYPE;
                        control.alu_src = 2'b10; // JALR, rd = pc + 2
                        control.reg_write = 1'b1;
                        rs1_id={inst_half[11:7]};
                        rs2_id={5'd0};
                        rd_id={5'd1};
                    end
                    else
                    begin
                        control.reg_write = 1'b1;
                        control.alu_op = ALU_ADD;
                        rd_id={inst_half[11:7]};
                        rs2_id=inst_half[6:2];
                        rs1_id=inst_half[11:7];
                    end    
                        
                end
                
                else if(inst_half[15:13]==3'b000)
                begin
                    comp=CI_TYPE;
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;
                    control.alu_op = ALU_SLL;
                    rd_id={inst_half[11:7]};
                    rs2_id={5'd0};
                    rs1_id={inst_half[11:7]};                                           
                end
            end
            endcase
        end
        else
        begin
            rs1_id=instruction.rs1;
            rs2_id=instruction.rs2;
            rd_id=instruction.rd;
            case (instruction.opcode)           //Arithmetic R-type
                7'b0110011: begin
                    control.reg_write = 1'b1;
                    case (instruction.funct3)
                        3'b000: begin // ADD/SUB
                            if (instruction.funct7 == 7'b0100000) begin
                                control.alu_op = ALU_SUB;
                            end else begin
                                control.alu_op = ALU_ADD;
                            end
                        end
                        3'b100: control.alu_op = ALU_XOR;
                        3'b110: control.alu_op = ALU_OR;
                        3'b111: control.alu_op = ALU_AND;
                        3'b001: control.alu_op = ALU_SLL;
                        3'b101: begin // SRL/SRA
                            if (instruction.funct7 == 7'b0100000) begin
                                control.alu_op = ALU_SRA;
                            end else begin
                                control.alu_op = ALU_SRL;
                            end
                        end
                        3'b010: control.alu_op = ALU_SLT;
                        3'b011: control.alu_op = ALU_SLTU;
                    endcase
                end
    
                7'b0010011: begin // I-TYPE (Immediate Arithmetic)
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01; 
                    case (instruction.funct3)
                        3'b000: control.alu_op = ALU_ADD;
                        3'b100: control.alu_op = ALU_XOR;
                        3'b110: control.alu_op = ALU_OR;
                        3'b111: control.alu_op = ALU_AND;
                        3'b001: control.alu_op = ALU_SLL;
                        3'b101: begin // SRL/SRA
                            if (instruction.funct7 == 7'b0100000) begin
                                control.alu_op = ALU_SRA;
                            end else begin
                                control.alu_op = ALU_SRL;
                            end
                        end
                        3'b010: control.alu_op = ALU_SLT;
                        3'b011: control.alu_op = ALU_SLTU;
                    endcase
                end
                
                7'b0000011: begin               // Load 
                    control.encoding = I_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b01;                
                    control.mem_read = 1'b1;                
                    control.mem_to_reg = 1'b1;
                    control.funct3 = instruction.funct3;                
                end
    
                
                7'b0100011: begin
                    control.encoding = S_TYPE;
                    control.alu_src = 2'b01;
                    control.mem_write = 1'b1;
                    control.funct3 = instruction.funct3;                  
                end
                
                7'b1100011: begin
                    control.encoding = B_TYPE;
                    control.is_branch = 1'b1;
                    control.funct3=instruction.funct3;            
                end 
                7'b1101111: begin
                    control.encoding = J_TYPE;
                    control.alu_src = 2'b10; // JAL, rd = pc + 4
                    control.reg_write = 1'b1;
                end
                7'b1100111: begin
                    control.encoding = I_TYPE;
                    control.alu_src = 2'b10; // JALR, rd = pc + 4
                    control.reg_write = 1'b1;
                end
                7'b0110111: begin           // U-type// LUI
                    control.encoding = U_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b11; 
                    control.alu_op = ALU_SLL; 
                end
                7'b0010111: begin           // U-type// AUIPC
                    control.encoding = U_TYPE;
                    control.reg_write = 1'b1;
                    control.alu_src = 2'b10; 
                    control.alu_op = ALU_ADD; 
                end
                7'b0000000: begin
                    control = '0;
                    illegal_opcode = 1'b0;
                end
                default:
                    illegal_opcode = 1'b1;
            endcase
        end    
        
    end
    
endmodule
