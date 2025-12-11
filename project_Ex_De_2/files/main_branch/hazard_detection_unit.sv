
`timescale 1ns / 1ps
import common::*;
module hazard_detection_unit(
    input clk,
    input reset_n,
    input [4:0] read1_id,
    input [4:0] read2_id,
    input [4:0] rd_mem,
    input [4:0] rd_ex,
    input [4:0] rd_wb,
    input control_type control_id,
    input control_type control_ex,
    input control_type control_mem,
    output control_type control_out,
    output logic [2:0] forward_data,
    output logic [2:0] forward_data2
    );
    logic stall_control,stall_control2;
    always_comb begin
        
        forward_data=3'b000;
        forward_data2=3'b000;
        stall_control=1'b0;
        stall_control2=1'b0;
//        if((control_id.encoding_type==S_TYPE)||(control_id.encoding_type==R_TYPE)||((control_id.encoding_type==I_TYPE)&&(control_id.mem_to_reg = 1'b0)))
//        begin
        if((read1_id!=rd_ex)&&(read2_id!=rd_ex)&&(read1_id!=rd_mem)&&(read2_id!=rd_mem)&&(read1_id!=rd_wb)&&(read2_id!=rd_wb))
        begin
            forward_data=3'b000;
            forward_data2=3'b000;
            stall_control=1'b0;
            stall_control2=1'b0;
        end
        else
        begin            
            if(((read1_id!=rd_ex)&&(read1_id!=rd_mem)&&(read1_id!=rd_wb))||(read1_id==5'b0))
            begin
                forward_data=3'b000;
                stall_control=1'b0;
            end
            else if(read1_id==rd_ex)
            begin
                if((control_ex.encoding==R_TYPE)||((control_ex.encoding==I_TYPE)&&(control_ex.mem_to_reg == 1'b0))||((control_ex.encoding==U_TYPE))||((control_ex.encoding==J_TYPE)))
                begin
                    
                    forward_data=3'b001;
                    stall_control=1'b0;                    
                end
                else if(((control_ex.encoding==I_TYPE)&&(control_ex.mem_to_reg == 1'b1)))
                begin
                    forward_data=3'b111;
                   // forward_data2=3'b111;
                    stall_control=1'b1;
                end
            end               
            else if(read1_id==rd_mem)
            begin
                if((control_mem.encoding==R_TYPE)||((control_mem.encoding==I_TYPE)&&(control_mem.mem_to_reg == 1'b0))||((control_mem.encoding==U_TYPE))||((control_mem.encoding==J_TYPE)))
                begin
                    
                    forward_data=3'b011;
                    stall_control=1'b0;
                end
                else if(((control_mem.encoding==I_TYPE)&&(control_mem.mem_to_reg == 1'b1)))
                begin
                        forward_data=3'b101;
                        stall_control=1'b0;
                end
            end
            else if(read1_id==rd_wb)
            begin
                forward_data=3'b110;
                stall_control=1'b0;
                
                
            end
            if(((read2_id!=rd_ex)&&(read2_id!=rd_mem)&&(read2_id!=rd_wb))||(read2_id==5'b0)||(control_id.encoding==I_TYPE))
            begin
                forward_data2=3'b000;                
                stall_control2=1'b0;
            end
            else if(read2_id==rd_ex)
            begin
                if((control_ex.encoding==R_TYPE)||((control_ex.encoding==I_TYPE)&&(control_ex.mem_to_reg == 1'b0))||((control_ex.encoding==U_TYPE))||((control_ex.encoding==J_TYPE)))
                begin
                    
                    forward_data2=3'b001;
                    stall_control2=1'b0;                    
                end
                else if(((control_ex.encoding==I_TYPE)&&(control_ex.mem_to_reg == 1'b1)))
                begin
                    forward_data2=3'b111;
                   // forward_data2=3'b111;
                    stall_control2=1'b1;
                    
                end
            end               
            else if(read2_id==rd_mem)
            begin
                if((control_mem.encoding==R_TYPE)||((control_mem.encoding==I_TYPE)&&(control_mem.mem_to_reg == 1'b0))||((control_mem.encoding==U_TYPE))||((control_mem.encoding==J_TYPE)))
                begin
                    
                    forward_data2=3'b011;
                    stall_control2=1'b0;
                end
                else if(((control_mem.encoding==I_TYPE)&&(control_mem.mem_to_reg == 1'b1)))
                begin
                        forward_data2=3'b101;
                        stall_control2=1'b0;
                end
            end
            else if(read2_id==rd_wb)
            begin
                forward_data2=3'b110;
                stall_control2=1'b0;
                
                
            end
                                                
        end
    end
    always_comb begin
        if((stall_control2||stall_control)==1'b1)
        begin
            control_out.alu_op=ALU_ADD;
            control_out.encoding=I_TYPE;
            control_out.alu_src=1'b1;
            control_out.mem_read=1'b0;
            control_out.mem_write=1'b0;
            control_out.reg_write=1'b1;
            control_out.mem_to_reg=1'b0;
            control_out.is_branch=1'b0;
            control_out.funct3=3'b000;
        end
        else
            control_out=control_id;
    end
//    end
endmodule
