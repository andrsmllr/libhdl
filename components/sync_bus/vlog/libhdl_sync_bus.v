`timescale 1 ns / 1 ps

module libhdl_sync_bus
#(  parameter W = 32,
    parameter NFF = 2,
    parameter INIT_VAL = {W{1'b0}})
(   input  wire         i_clk,
    input  wire [W-1:0] i_bus,
    output wire [W-1:0] o_bus);

(* ASYNC_REG = "TRUE" *)
reg [W-1:0] sync_ff [NFF-1:0];

integer i;
initial begin
    for (i = 0; i < NFF; i = i + 1) sync_ff[i] = INIT_VAL;
end

always @ (posedge i_clk)
begin
    sync_ff[0] <= i_bus;
    for (i = 1; i < NFF; i = i + 1) begin
        sync_ff[i] <= sync_ff[i-1];
    end
end

assign o_bus = sync_ff[NFF-1];

endmodule
