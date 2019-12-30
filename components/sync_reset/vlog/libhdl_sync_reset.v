`timescale 1 ns / 1 ps

module libhdl_sync_reset
#(  parameter NFF = 2,
    parameter RST_ASYNC_ACTIVE = 1'b1,
    parameter RST_SYNC_ACTIVE = 1'b1)
(   input  wire i_rst_async,
    input  wire i_clk,
    output wire o_rst_sync);

(* ASYNC_REG = "TRUE" *)
reg [NFF-1:0] sync_ff = {NFF{!RST_SYNC_ACTIVE}};

if (RST_ASYNC_ACTIVE == 1'b1) begin : gen_acthi_rst
    always @ (posedge i_clk, posedge i_rst_async)
    begin
        if (i_rst_async == RST_ASYNC_ACTIVE)
            sync_ff <= {NFF{RST_SYNC_ACTIVE}};
        else
            sync_ff <= {sync_ff[NFF-2:0], ~RST_SYNC_ACTIVE};
    end
end else begin : gen_actlo_rst
    always @ (posedge i_clk, negedge i_rst_async)
    begin
        if (i_rst_async == RST_ASYNC_ACTIVE)
            sync_ff <= {NFF{RST_SYNC_ACTIVE}};
        else
            sync_ff <= {sync_ff[NFF-2:0], ~RST_SYNC_ACTIVE};
    end
end

assign o_rst_sync = sync_ff[NFF-1];

endmodule
