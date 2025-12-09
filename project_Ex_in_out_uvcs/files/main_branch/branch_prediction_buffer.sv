/*
Changelog: 
- (Sky) 2025-05-04: Initial.    
- (Sky) 2025-05-05: FSM and History table    
- (Sky) 2025-06-05: Make changes to fit new gshare desingn    
*/
`timescale 1ns / 1ps

module branch_prediction_buffer (
    input clk,
    input rst_n,         // active-low reset
    input [7:0] address_index, //indexed by gshare
    input resolve,       // high when a branch outcome is presented
    input actual_taken,  // 1 if branch was taken, 0 if not
    output logic predict_taken  //prediction for next branch
);
    
    // State encoding
    typedef enum logic [1:0] {
        SN = 2'b00,  // Strongly Not Taken
        WN = 2'b01,  // Weakly Not Taken
        WT = 2'b10,  // Weakly Taken
        ST = 2'b11   // Strongly Taken
    } state_t;

    state_t prediction_buffer [256]; //2-bit wide
    //logic [7:0] address_index;
    logic [7:0] address_index_dly1;   //delay 1 time, because branch is resolved in the next clock cycle
                                     //to record the previous PC of the actual instruction 
    
    assign predict_taken = prediction_buffer[address_index][1]; //bit 1
    
    // Helper function to compute next state
    function state_t next_counter(state_t cur, logic taken);
        case (cur)
            SN: next_counter = taken ? WN : SN;
            WN: next_counter = taken ? ST : SN;
            WT: next_counter = taken ? ST : SN;
            ST: next_counter = taken ? ST : WT;
            default: next_counter = SN;
        endcase
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            address_index_dly1 <= 8'd0;
        end    
        else    begin
            address_index_dly1 <= address_index;
        end
    end
    // On reset, initialize the table; on each resolve, update only the indexed entry
    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all entries to Strongly Not Taken
            for (i = 0; i < 256; i = i + 1)
                prediction_buffer[i] <= SN;
        end else if (resolve) begin
            // Update the single entry pointed to by pc_index
            prediction_buffer[address_index_dly1] <= next_counter(prediction_buffer[address_index_dly1], actual_taken);
        end
        // Otherwise, leave all other entries unchanged
    end

endmodule
    
 