`timescale 1ns / 1ps


module program_memory (
    input clk,
    input [31:0] byte_address,
    input write_enable,         
    input [31:0] write_data,
    output logic pc_addr_exception_flag, 
    output logic [31:0] read_data
);

    logic [31:0] ram [256];
    logic [31:0]read_data1,read_data2;  //change by soumya
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];    
    assign pc_addr_exception_flag = (byte_address >= 32'd256)? 1'b1: 1'b0;
    
    initial begin
        //$readmemb("instruction_mem.mem", ram);
        $readmemb("test7_edit_binary_out.mem", ram);
    end
    
    
    always @(posedge clk) begin
        if (write_enable) begin
            ram[word_address] <= write_data;
        end 
    end
    
    assign read_data1 = ram[word_address];
    assign read_data2 = ram[word_address+1];
    always_comb begin
        if(byte_address[1]==1'b1)
            read_data={read_data2[15:0],read_data1[31:16]};
        else
            read_data=read_data1;
    end

ila_prgmem inst_ila_prgmem (
	.clk(clk), // input wire clk
	.probe0(read_data), // input wire [31:0]  probe0  
	.probe1(word_address) // input wire [7:0]  probe1
);

endmodule
