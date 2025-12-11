`timescale 1ns / 1ps
import common::*;

module forward_mux(
    input clk,
    input reset_n,
    input [2:0] forward_data,
    input [2:0] forward_data2,
    input [31:0] decode_data1,
    input [31:0] decode_data2,
    input compflg_id,
    input [31:0] decode_immediate,
    input [31:0] exe_out,
    input [31:0] mem_alu_out,
    input [31:0] mem_mem_out,
    input [31:0] wb_out,
    input [5:0] reg_rd_id,
    output logic [5:0] reg_rd_exe,
    output logic [31:0] mux_data1,
    output logic [31:0] mux_data2,
    output logic [31:0] exe_immediate,
    output logic compflg_out
    );
    always_comb begin
        mux_data2=decode_data2;
        mux_data1=decode_data1;
        compflg_out=compflg_id;
        case(forward_data2)
        3'b000:
        begin
            mux_data2=decode_data2;
           
        end
        3'b001:
        begin
            mux_data2=exe_out;
           
        end
  
        3'b011:
        begin
            mux_data2=mem_alu_out;
            
        end
        3'b101:
        begin
            mux_data2=mem_mem_out;
           
        end
        3'b110:
        begin
            mux_data2=wb_out;
           
        end
    
       
        3'b111:
        begin
        //    mux_data2=32'd0;
            mux_data1=32'd0;
        end
        default:
        begin
            mux_data2=decode_data2;
        
        end
        endcase
        
        case(forward_data)
        3'b000:
        begin
            mux_data1=decode_data1;
            //mux_data2=decode_data2;
           // exe_immediate=decode_immediate;
            //reg_rd_exe=reg_rd_id;
        end
        3'b001:
        begin
            mux_data1=exe_out;
            //mux_data2=decode_data2;
           // exe_immediate=decode_immediate;
           // reg_rd_exe=reg_rd_id;
        end
  /**      3'b010:
        begin
            mux_data2=exe_out;
            mux_data1=decode_data1;
            exe_immediate=decode_immediate;
            reg_rd_exe=reg_rd_id;
        end
        */
        3'b011:
        begin
            mux_data1=mem_alu_out;
            //mux_data2=decode_data2;
           // exe_immediate=decode_immediate;
           // reg_rd_exe=reg_rd_id;
        end
   /**     3'b100:
        begin
            mux_data2=mem_alu_out;
            mux_data1=decode_data1;
            exe_immediate=decode_immediate;
            reg_rd_exe=reg_rd_id;
        end
        */
        3'b101:
        begin
            mux_data1=mem_mem_out;
           // mux_data2=decode_data2;
          //  exe_immediate=decode_immediate;
          //  reg_rd_exe=reg_rd_id;
        end
     /**   3'b110:
        begin
            mux_data2=mem_mem_out;
            mux_data1=decode_data1;
            exe_immediate=decode_immediate;
            reg_rd_exe=reg_rd_id;
        end
        */
        3'b110:
        begin
            mux_data1=wb_out;
           
        end
        3'b111:
        begin
        //    mux_data2=32'd0;
            mux_data1=32'd0;
          //  exe_immediate=32'd0;
         //   reg_rd_exe=6'd0;
        end
        default:
        begin
            mux_data1=decode_data1;
        //    mux_data2=decode_data2;
         //   exe_immediate=decode_immediate;
         //   reg_rd_exe=reg_rd_id;
        end
        endcase
        if((forward_data==3'b111)||(forward_data2==3'b111))
        begin
            exe_immediate=32'd0;
            reg_rd_exe=6'd0;
            compflg_out=0; 
        end
        else
        begin
            exe_immediate=decode_immediate;
            reg_rd_exe=reg_rd_id;
            compflg_out=compflg_id;    
        end
            
    end
endmodule
