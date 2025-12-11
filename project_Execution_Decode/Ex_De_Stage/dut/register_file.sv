`timescale 1ns / 1ps


module register_file(
    input clk,
    input reset_n,
    input write_en,
    input [4:0] read1_id,
    input [4:0] read2_id,
    input [4:0] write_id,
    input [31:0] write_data,
    output logic [31:0] read1_data,
    output logic [31:0] read2_data
);

    parameter REGISTER_FILE_SIZE = 32;
    
    logic [31:0] registers [0:REGISTER_FILE_SIZE-1] = '{default:0};
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            registers = '{default:0};
        end 
        else if (write_en) begin
            registers[write_id] <= write_data;     
        end
    end
/*
// ILA not part of RISC-V implementation, only for debug purposes
	
ila_rf inst_ila_rf (
	.clk(clk), // input wire clk
	.probe0(registers[0]), // input wire [31:0]  probe0  
	.probe1(registers[1]), // input wire [31:0]  probe1 
	.probe2(registers[2]), // input wire [31:0]  probe2 
	.probe3(registers[3]), // input wire [31:0]  probe3 
	.probe4(registers[4]), // input wire [31:0]  probe4 
	.probe5(registers[5]), // input wire [31:0]  probe5 
	.probe6(registers[6]), // input wire [31:0]  probe6 
	.probe7(registers[7]), // input wire [31:0]  probe7 
	.probe8(registers[8]), // input wire [31:0]  probe8 
	.probe9(registers[9]), // input wire [31:0]  probe9 
	.probe10(registers[10]), // input wire [31:0]  probe10 
	.probe11(registers[11]), // input wire [31:0]  probe11 
	.probe12(registers[12]), // input wire [31:0]  probe12 
	.probe13(registers[13]), // input wire [31:0]  probe13 
	.probe14(registers[14]), // input wire [31:0]  probe14 
	.probe15(registers[15]), // input wire [31:0]  probe15 
	.probe16(registers[16]), // input wire [31:0]  probe16 
	.probe17(registers[17]), // input wire [31:0]  probe17 
	.probe18(registers[18]), // input wire [31:0]  probe18 
	.probe19(registers[19]), // input wire [31:0]  probe19 
	.probe20(registers[20]), // input wire [31:0]  probe20 
	.probe21(registers[21]), // input wire [31:0]  probe21 
	.probe22(registers[22]), // input wire [31:0]  probe22 
	.probe23(registers[23]), // input wire [31:0]  probe23 
	.probe24(registers[24]), // input wire [31:0]  probe24 
	.probe25(registers[25]), // input wire [31:0]  probe25 
	.probe26(registers[26]), // input wire [31:0]  probe26 
	.probe27(registers[27]), // input wire [31:0]  probe27 
	.probe28(registers[28]), // input wire [31:0]  probe28 
	.probe29(registers[29]), // input wire [31:0]  probe29 
	.probe30(registers[30]), // input wire [31:0]  probe30 
	.probe31(registers[31]) // input wire [31:0]  probe31
);
*/

    assign read1_data = read1_id == 0 ? 0 : registers[read1_id]; // this is to check x0 always zero otherwise just give the value
    assign read2_data = read2_id == 0 ? 0 : registers[read2_id]; // this is to check x0 always zero otherwise just give the value

endmodule
