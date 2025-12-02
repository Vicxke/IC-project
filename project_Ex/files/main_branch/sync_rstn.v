//===============================================================================
//
// COMPANY:              T-smartlink
//
// PROJECT:              Cupertino 
// Filename:              sync_rstn.v 
//
// REVISION & HISTORY:
//          rstn must be a controllable reset for scan
//          the gated reset will be sync 2 Flip-flop for reset sync
//===============================================================================

module sync_rstn ( rstn, clk, gated, rstn_sync, scan_sel, rstn_ok );

input   rstn, clk, gated, scan_sel;
output  rstn_sync;
output  rstn_ok;

reg rstn_in_d1, rstn_in_d2;
reg rstn_in_d3;

wire    rstn_gate = (scan_sel) ? rstn : rstn & gated;
wire    rstn_sync = (scan_sel) ? rstn : rstn_in_d2;

always @(posedge clk or negedge rstn_gate) begin
    if(~rstn_gate)  rstn_in_d1 <= #1 1'b0; 
    else        rstn_in_d1 <= #1 1'b1;
end

always @(posedge clk or negedge rstn_gate) begin
    if(~rstn_gate)  rstn_in_d2 <= #1 1'b0; 
    else        rstn_in_d2 <= #1 rstn_in_d1;
end

//---- for interrupt
always @(posedge clk or negedge rstn_gate) begin
    if(~rstn_gate)  rstn_in_d3 <= #1 1'b0; 
    else        rstn_in_d3 <= #1 rstn_in_d2;
end


assign rstn_ok = rstn_in_d2 & ~rstn_in_d3;



endmodule
