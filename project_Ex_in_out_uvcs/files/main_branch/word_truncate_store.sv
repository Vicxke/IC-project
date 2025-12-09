module word_truncate_store(
    input  logic [31:0]  in_word,
    input logic [31:0] read_word,
    input  logic [2:0]   in_len, // take funct3 from instruction
    input  logic [1:0]   offset,
    output logic [31:0]  out_word,
    input logic truncate_enable
);

    logic [31:0]  out_word_temp;
    // Truncate the input word to the output width
    always_comb begin
        out_word_temp = in_word;
        case (in_len)
            3'b000: begin
                case (offset)
                    2'b00: out_word_temp = {read_word[31:8],in_word[7:0]}; // byte lower
                    2'b01: out_word_temp = {read_word[31:16],in_word[7:0],read_word[7:0]}; // byte middle
                    2'b10: out_word_temp = {read_word[31:24],in_word[7:0],read_word[15:0]}; // byte upper
                    2'b11: out_word_temp = {in_word[31:24],read_word[23:0]};         // byte upper
                endcase
            end
            //out_word_temp = {24'b0, in_word[7:0]}; // byte
            3'b001: begin
                case (offset)
                    2'b00: out_word_temp = {read_word[31:16], in_word[15:0]}; // half word lower
                    2'b10: out_word_temp = { in_word[15:0],read_word[15:0]}; // half word upper                                               
                endcase
            end // half-word
            //2'b010: out_word =                 // word

            default: out_word_temp = in_word;                // default case (should not happen)
        endcase
    end

    assign out_word = (truncate_enable == 1'b1) ? out_word_temp : in_word; //

endmodule
