`timescale 1 ns / 1 ps

module libhdl_sync_bit
#(  parameter NFF = 2,
    parameter INIT_VAL = 1'b0)
(   input  wire i_clk,
    input  wire i_bit,
    output wire o_bit);

(* ASYNC_REG = "TRUE" *)
reg [NFF-1:0] sync_ff = {NFF{INIT_VAL}};

always @ (posedge i_clk)
begin
    sync_ff <= {sync_ff[NFF-2:0], i_bit};
end

assign o_bit = sync_ff[NFF-1];

endmodule
