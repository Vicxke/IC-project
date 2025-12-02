`timescale 1ns / 1ps 


module mem_stage(
    input clk,
    input reset_n,
    input [31:0] alu_data_in,
    input [31:0] memory_data_in,
    input control_type control_in,
    input logic compflg,
    output control_type control_out,
    output logic [31:0] memory_data_out,
    output logic [31:0] alu_data_out,
    output logic exception_flag
);
    logic [31:0] mod_data_in;
    logic [31:0] data_out;
    
    word_truncate_store inst_word_truncate_in(
    .in_word(memory_data_in),
    .in_len(control_in.funct3),
    .read_word(data_out), // take funct3 from instruction
    . out_word(mod_data_in),
    .offset(alu_data_in[1:0]),
    .truncate_enable(control_in.mem_write)
);
    word_truncate inst_word_truncate_out(
    .in_word(data_out),
    .in_len(control_in.funct3),
    .offset(alu_data_in[1:0]), // take funct3 from instruction
    . out_word(memory_data_out),
    .truncate_enable(control_in.mem_read)
);
    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_in[9:0]),
        .write_enable(control_in.mem_write),
        .write_data(mod_data_in),
        .read_data(data_out)
    );
    always_comb begin
        if((alu_data_out>=32'd0)&&(alu_data_out<=32'd255))
        begin
            exception_flag=1'b0;
        end
        else
        begin
            exception_flag=1'b1;
        end
    end

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
endmodule
