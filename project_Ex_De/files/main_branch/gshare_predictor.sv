//------------------------------------------------------------------------------
// gshare_predictor.sv
//
// A small GShare predictor “front-end” that:
//  1) Keeps an 8-bit Global History Register (GHR).
//  2) Computes PHT index = PC[7:0] ^ GHR.
//  3) Exposes the current 2-bit PHT counter at that index as 'predict'.
//  4) On branch resolution, computes the next 2-bit counter value and
//     shifts the actual outcome into GHR.
//------------------------------------------------------------------------------


module gshare_predictor (
    input  logic        clk,           // system clock
    input  logic        reset_n,       // active‐low reset
    // --- fetch‐stage inputs:
    input  logic [31:0] branch_pc,     // PC of the branch being predicted
    output logic        predict_taken, // high if PHT[pht_index] ≥ 2

    // --- resolution‐stage inputs (one cycle later, when branch resolves):
    input  logic        resolve,    // pulses high for exactly one cycle
    input  logic        actual_taken // 1 == branch was actually taken

    // --- interface to your external PHT memory:
    //input  logic [1:0]  pht_current,   // current 2-bit counter read from PHT[pht_index]
    //output logic [1:0]  pht_next,      // updated counter to write back
    //output logic        pht_we         // write‐enable for that PHT entry
);

    //--------------------------------------------------------------------------
    // 1) Global History Register (8 bits)
    //--------------------------------------------------------------------------

    logic [7:0] GHR;
    logic [7:0] pht_index;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            GHR <= 8'b0;
        end
        else if (resolve) begin
            // Shift in the new branch outcome (1 if taken, 0 if not)
            GHR <= { GHR[6:0], actual_taken };
        end
        // else: no change until the next resolved branch
    end

    //--------------------------------------------------------------------------
    // 2) Compute PHT index by XOR’ing PC[7:0] with GHR
    //--------------------------------------------------------------------------

    // You can compute this purely combinationally at fetch time:
    always_comb begin
        pht_index = branch_pc[8:1] ^ GHR;
    end

    //--------------------------------------------------------------------------
    // 3) Form the prediction from the MSB of the 2-bit counter:
    //--------------------------------------------------------------------------
    branch_prediction_buffer inst_branch_prediction_buffer(
    //inputs
    .clk(clk),
    .rst_n(reset_n),         
    .address_index(pht_index), 
    .resolve(resolve),       
    .actual_taken(actual_taken),  // 1 if branch was taken, 0 if not
    //output
    .predict_taken(predict_taken)  //prediction for current PC branching
    );
  
     

endmodule
