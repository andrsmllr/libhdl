`timescale 1 ns / 1 ps

module libhdl_fifo_cc
#(  parameter DATA_LEN = 32,
    parameter DEPTH = 1024,
    parameter FILL_CNT_ENA = 1,
    parameter ALMOST_EMPTY_ENA = 1,
    parameter ALMOST_FULL_ENA = 1,
    parameter ALMOST_EMPTY_CNT = (DEPTH/4),
    parameter ALMOST_FULL_CNT = (DEPTH - DEPTH/4))
(   input  wire                i_clk,
    output wire                o_wrdy,
    input  wire                i_wvld,
    input  wire [DATA_LEN-1:0] i_wdat,
    input  wire                i_rrdy,
    output wire                o_rvld,
    output wire [DATA_LEN-1:0] o_rdat,
    output wire                o_count,
    output wire                o_empty,
    output wire                o_full,
    output wire                o_almost_empty,
    output wire                o_almost_full);

`ifdef LIBHDL_ASSERT
assert(ALMOST_FULL_CNT <= DEPTH && ALMOST_EMPTY_CNT >= 0);
assert((FILL_CNT_ENA ~^ ALMOST_EMPTY_ENA) && (FILL_CNT_ENA ~^ ALMOST_FULL_ENA))
`endif

reg [DATA_LEN-1:0] mem [DEPTH-1:0];
reg [DATA_LEN-1:0] rdat_reg;

wire whandshk, rhandshk;
reg empty = 1'b1;
reg empty_nxt = 1'b1;
reg full = 1'b0;
localparam PTRLEN = $clog2(DEPTH);
reg [PTRLEN-1:0] rptr = 'd0;
reg [PTRLEN-1:0] wptr = 'd0;
wire [PTRLEN-1:0] wptr_nxt, rptr_nxt;

// Data path.
always @ (posedge i_clk)
begin
    if (whandshk == 1'b1) begin
        mem[wptr] <= i_wdat;
    end
    if (rhandshk == 1'b1) begin
        rdat_reg <= mem[rptr_nxt];
    end else begin
        rdat_reg <= mem[rptr];
    end
end

assign o_rdat = rdat_reg;

// Control logic.
assign o_wrdy = (full == 1'b1) ? 1'b0 : 1'b1;
assign o_rvld = (empty == 1'b1) ? 1'b0 : 1'b1;

assign whandshk = (o_wrdy && i_wvld);
assign rhandshk = (i_rrdy && o_rvld);

assign wptr_nxt = (wptr == DEPTH-1) ? 'd0 : (wptr + 1);
assign rptr_nxt = (rptr == DEPTH-1) ? 'd0 : (rptr + 1);

always @ (posedge i_clk)
begin
    empty <= empty_nxt;
    if (whandshk == 1'b1) begin
        wptr <= wptr_nxt;
        empty_nxt <= 1'b0;
        if (wptr_nxt == rptr) begin
            full <= 1'b1;
        end
    end
    if (rhandshk == 1'b1) begin
        rptr <= rptr_nxt;
        full <= 1'b0;
        if (rptr_nxt == wptr) begin
            empty <= 1'b1;
            empty_nxt <= 1'b1;
        end
    end
end

assign o_empty = empty;
assign o_full = full;

// Fill count (optional).
// Use economic up/down counter to keep track of fill count instead of
// calucating the fill level from pointers (wptr, rptr).
reg [PTRLEN:0] cnt = 'd0;
if (FILL_CNT_ENA != 0) begin : gen_fill_cnt
    always @ (posedge i_clk)
    begin
        case ({rhandshk, whandshk})
            2'b01:   cnt <= cnt + 1;
            2'b10:   cnt <= cnt - 1;
            default: cnt <= cnt;
        endcase
    end
end

// Almost empty flag (optional).
if (ALMOST_EMPTY_ENA != 0) begin : gen_almost_empty
    assign o_almost_empty = (cnt <= ALMOST_EMPTY_CNT) ? 1'b1 : 1'b0;
end else begin
    assign o_almost_empty = 1'bX;
end

// Almost full flag (optional).
if (ALMOST_FULL_ENA != 0) begin : gen_almost_full
    assign o_almost_full = (cnt >= ALMOST_FULL_CNT) ? 1'b1 : 1'b0;
end else begin
    assign o_almost_full = 1'bX;
end

endmodule
