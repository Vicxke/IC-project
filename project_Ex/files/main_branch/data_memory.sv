`timescale 1ns / 1ps


module data_memory (
    input clk,
    input [9:0] byte_address,
    input write_enable,         
    input [31:0] write_data, 
    output logic [31:0] read_data
);

    logic [31:0] ram [256];
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];
    
    
    always @(posedge clk) begin
        if (write_enable) begin
            ram[word_address] <= write_data;
        end 
    end

    
    assign read_data = ram[word_address];

ila_dmem inst_ila_dmem (
	.clk(clk), // input wire clk
	.probe0(ram[0]), // input wire [31:0]  probe0  
	.probe1(ram[1]), // input wire [31:0]  probe1 
	.probe2(ram[2]), // input wire [31:0]  probe2 
	.probe3(ram[3]), // input wire [31:0]  probe3 
	.probe4(ram[4]), // input wire [31:0]  probe4 
	.probe5(ram[5]), // input wire [31:0]  probe5 
	.probe6(ram[6]), // input wire [31:0]  probe6 
	.probe7(ram[7]), // input wire [31:0]  probe7 
	.probe8(ram[8]), // input wire [31:0]  probe8 
	.probe9(ram[9]), // input wire [31:0]  probe9 
	.probe10(ram[10]), // input wire [31:0]  probe10 
	.probe11(ram[11]), // input wire [31:0]  probe11 
	.probe12(ram[12]), // input wire [31:0]  probe12 
	.probe13(ram[13]), // input wire [31:0]  probe13 
	.probe14(ram[14]), // input wire [31:0]  probe14 
	.probe15(ram[15]), // input wire [31:0]  probe15 
	.probe16(ram[16]), // input wire [31:0]  probe16 
	.probe17(ram[17]), // input wire [31:0]  probe17 
	.probe18(ram[18]), // input wire [31:0]  probe18 
	.probe19(ram[19]) // input wire [31:0]  probe19
);
endmodule
