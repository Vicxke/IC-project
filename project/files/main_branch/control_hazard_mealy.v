module control_hazard_mealy (
  input clk,
  input reset_n,
  input is_branch,
  input predict_taken,
  input actual_taken,
  input compflg,
  input [31:0] pc,
  input [31:0] calculated_target_pc, 
  output reg [31:0] pc_next,
  output reg squash_for_wrong_pdctn 
);

reg [2:0] current_state, next_state;  //states declaration
reg [31:0] pc_latch_once_for_returnFromState4;
reg [31:0] pc_incr;
always@ (compflg) begin
if(compflg==1)
pc_incr=32'd2;
else
pc_incr=32'd4;
end
always@(posedge clk or negedge reset_n) begin  
  if (!reset_n) 
    pc_latch_once_for_returnFromState4 <= 32'd0;
  else
    pc_latch_once_for_returnFromState4 <= pc;
end

localparam PC_DONT_CARE = 32'hFFFF00FF; //Special code for pc SHOULD NOT be decided by branch 

localparam IDLE                        = 3'd0;
localparam PREDICT_NT_BEFORE_ACTUAL    = 3'd1;
localparam PREDICT_TAKEN_BEFORE_ACTUAL = 3'd4;

always@(posedge clk or negedge reset_n) begin  //states transation controlled by clk
  if (!reset_n) 
    current_state <= IDLE;
  else 
    current_state <= next_state;
end 

always@(*)  begin 
    case(current_state)
      IDLE : begin 
          if(is_branch) begin
              if(predict_taken)
                next_state = PREDICT_TAKEN_BEFORE_ACTUAL;
              else
                next_state = PREDICT_NT_BEFORE_ACTUAL;
          end
          else  begin
              next_state = IDLE;     
          end
      end
      PREDICT_NT_BEFORE_ACTUAL: begin 
              next_state = IDLE;     
      end
      PREDICT_TAKEN_BEFORE_ACTUAL: begin
              next_state = IDLE;     
      end 
      default: next_state = IDLE;
    endcase
end

always@(*) begin 
 case(current_state)
      IDLE : begin 
        if(is_branch) begin
          if(predict_taken) begin
            pc_next    = 32'd200; //stall for 1 cycle, until resolved at ID stage. Value don't matter since NOP will be inserted at ID
            squash_for_wrong_pdctn = 0;
          end
          else  begin
            pc_next    = pc+pc_incr; 
            squash_for_wrong_pdctn = 0;
          end
        end
        else  begin
          pc_next     = PC_DONT_CARE; 
          squash_for_wrong_pdctn  = 0;
        end
      end
      PREDICT_NT_BEFORE_ACTUAL: begin 
          if(actual_taken) begin
            pc_next     = calculated_target_pc; 
            squash_for_wrong_pdctn  = 1;
          end
          else begin  
            pc_next     = pc+pc_incr; 
            squash_for_wrong_pdctn  = 0;
          end
      end
      PREDICT_TAKEN_BEFORE_ACTUAL: begin 
          if(actual_taken)  begin
            pc_next     = calculated_target_pc; 
            squash_for_wrong_pdctn  = 1; //squash the following, because predicted taken
          end
          else begin  
            pc_next     = pc_latch_once_for_returnFromState4 + pc_incr; 
            squash_for_wrong_pdctn  = 1; //squash the following, because predicted taken
          end
      end
      default: begin
          pc_next     = PC_DONT_CARE; 
          squash_for_wrong_pdctn  = 0;
      end
    endcase
end 


endmodule