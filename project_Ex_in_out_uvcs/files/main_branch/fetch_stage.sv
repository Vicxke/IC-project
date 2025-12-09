
/*
Changelog:
- (Sky) 2025-04-19: Add PC MUX    
- (Sky) 2025-05-13: Merge with Main. Add ports for predict/actual taken     
- (Sky) 2025-05-14: Add control instance for decoding     
- (Sky) 2025-05-18: Add input uart_done
- (Sky) 2025-06-05: Add end of program condition to halt execution
*/

`timescale 1ns / 1ps

module fetch_stage(
    input clk,
    input reset_n,
    input uart_done,
    input [2:0] forward_data,
    input [2:0] forward_data2, // change by soumya biswas added input signal for stalling
    input select_target_pc,
    input [31:0]  calculated_target_pc,
    input predict_taken,     //branch prediction
    input [31:0] data,   
    output logic [31:0] address,
    output logic        squash_for_wrong_pdctn, //insert NOP
    output logic compflg
);

    logic [31:0] pc_next, pc_reg;
    logic [31:0] pc_decided_by_branch;
    logic is_branch_dly1,is_branch;     //controls PC two times every branch encounter
    control_type controls;
    logic compflg_prev;
    always @(posedge clk)
    begin
        if (!reset_n) 
        compflg_prev=1'b0;
  else
        compflg_prev=1'b1;
        
    end
    always_comb begin
        if(data[6:0]==7'b1100011)
        begin
            is_branch=1'b1;
        end
        else if((data[1:0]==2'b01)&&((data[15:13]==3'b110)||(data[15:13]==3'b111)))
        begin
            is_branch=1'b1;
        end
        else
        begin
            is_branch=1'b0;
        end
    end
    


    control_hazard_mealy inst_control_hazard_mealy(
        //inputs
        .clk(clk),
        .reset_n(reset_n),
        .is_branch(is_branch),
        .predict_taken(predict_taken),
        .actual_taken(select_target_pc),
        .pc(pc_reg),
        .compflg(compflg),
        .calculated_target_pc(calculated_target_pc), 
        //outputs
        .pc_next(pc_decided_by_branch),
        .squash_for_wrong_pdctn(squash_for_wrong_pdctn) 
    );


    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else if(!uart_done) begin
            pc_reg <= 0;
        end    
        else begin
            pc_reg <= pc_next;
        end 
    end
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            is_branch_dly1     <= 0;
        end
        else if(!uart_done) begin
            is_branch_dly1     <= 0;
        end
        else begin
            is_branch_dly1     <= is_branch;
        end 
    end    
        
    always_comb begin
        if((forward_data==3'b111)||(forward_data2==3'b111))  //change by Soumya Biswas to stop pc for stalling
            pc_next=pc_reg;
        else if(is_branch == 1 || is_branch_dly1 == 1) //Current PC is B-type, use prediction for PC
            pc_next = pc_decided_by_branch; 
        else if(select_target_pc == 1)  //JAL and JALR, not including B-type
            pc_next = calculated_target_pc;      
        else if(data[1:0]!=2'b11)
            pc_next = pc_reg + 2;
        else if(pc_reg[9:2] == 8'hFE) //end of program
            pc_next=pc_reg;
        else
            pc_next = pc_reg + 4;       
    end
    
    
    assign address = pc_reg;
    assign compflg=(pc_reg==32'd200)?compflg_prev:(data[1:0]==2'b11)?1'b0:1'b1;
endmodule
