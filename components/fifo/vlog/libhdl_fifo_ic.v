`timescale 1 ns / 1 ps

module libhdl_fifo_ic
#(  parameter DATA_LEN = 32,
    parameter DEPTH = 1024,
    parameter FILL_CNT_ENA = 1,
    parameter ALMOST_EMPTY_ENA = 1,
    parameter ALMOST_FULL_ENA = 1,
    parameter ALMOST_EMPTY_CNT = (DEPTH/4),
    parameter ALMOST_FULL_CNT = (DEPTH - DEPTH/4))
(   input  wire                i_wclk,
    output wire                o_wrdy,
    input  wire                i_wvld,
    input  wire [DATA_LEN-1:0] i_wdat,
    output wire                o_wfull,
    output wire                o_walmost_full,
    output wire                o_wcount,
    input  wire                i_rclk,
    input  wire                i_rrdy,
    output wire                o_rvld,
    output wire [DATA_LEN-1:0] o_rdat,
    output wire                o_rempty,
    output wire                o_ralmost_empty,
    output wire                o_rcount);

`ifdef LIBHDL_ASSERT
assert(ALMOST_FULL_CNT <= DEPTH && ALMOST_EMPTY_CNT >= 0);
assert((FILL_CNT_ENA ~^ ALMOST_EMPTY_ENA) && (FILL_CNT_ENA ~^ ALMOST_FULL_ENA))
`endif

localparam PTRLEN = $clog2(DEPTH);

reg [DATA_LEN-1:0] mem [DEPTH-1:0];

reg [PTRLEN-1:0] wptr = 'd0;
wire [PTRLEN-1:0] wptr_nxt;
wire whandshk;
reg wfull = 1'b0;

reg [DATA_LEN-1:0] rdat_reg;
reg [PTRLEN-1:0] rptr = 'd0;
wire [PTRLEN-1:0] rptr_nxt;
wire rhandshk;
reg rempty = 1'b1;

localparam CDC_NFF = 2;

reg [DATA_LEN-1:0] wptr_gray = 'd0;
(* ASYNC_REG = "TRUE" *)
reg [DATA_LEN-1:0] wcdc_rptr_gray [CDC_NFF-1:0];
reg [DATA_LEN-1:0] wcdc_rptr = 'd0;

reg [DATA_LEN-1:0] rptr_gray = 'd0;
(* ASYNC_REG = "TRUE" *)
reg [DATA_LEN-1:0] rcdc_wptr_gray [CDC_NFF-1:0];
reg [DATA_LEN-1:0] rcdc_wptr = 'd0;

function [DATA_LEN-1:0] bin2gray;
    input [DATA_LEN-1:0] bin;
begin
    bin2gray = bin ^ {1'b0, bin[DATA_LEN-1:1]};
end
endfunction

function [DATA_LEN-1:0] gray2bin;
    input [DATA_LEN-1:0] gray;
    reg [DATA_LEN-1:0] tmp;
    integer i;
begin
    tmp = 'd0;
    tmp[DATA_LEN-1] = gray[DATA_LEN-1];
    for (i = DATA_LEN - 2; i >= 0; i = i - 1) begin
        tmp[i] = tmp[i+1] ^ gray[i];
    end
    gray2bin = tmp;
end
endfunction

/* Write clock domain (i_wclk). ***********************************************/

// Write data path.
always @ (posedge i_wclk)
begin
    if (whandshk == 1'b1) begin
        mem[wptr] <= i_wdat;
    end
end

// Write control.
assign o_wrdy = (wfull == 1'b1) ? 1'b0 : 1'b1;
assign whandshk = (o_wrdy && i_wvld);
assign wptr_nxt = (wptr == DEPTH-1) ? 'd0 : (wptr + 1);

always @ (posedge i_wclk)
begin
    if (wptr != wcdc_rptr) begin
        wfull <= 1'b0;
    end
    if (whandshk == 1'b1) begin
        wptr <= wptr_nxt;
        if (wptr_nxt == wcdc_rptr) begin
            wfull <= 1'b1;
        end
    end
end

assign o_wfull = wfull;

/* CDC write clock domain (i_rclk) to read clock domain (i_rclkd) and vice versa. */

integer i;

always @ (posedge i_wclk)
begin
    wptr_gray <= bin2gray(wptr);
    wcdc_rptr_gray[0] <= rptr_gray;
    for (i = 1; i < CDC_NFF; i = i + 1) begin
        wcdc_rptr_gray[i] <= wcdc_rptr_gray[i-1];
    end
    wcdc_rptr <= gray2bin(wcdc_rptr_gray[CDC_NFF-1]);
end

always @ (posedge i_rclk)
begin
    rptr_gray <= bin2gray(rptr);
    rcdc_wptr_gray[0] <= wptr_gray;
    for (i = 1; i < CDC_NFF; i = i + 1) begin
        rcdc_wptr_gray[i] <= rcdc_wptr_gray[i-1];
    end
    rcdc_wptr <= gray2bin(rcdc_wptr_gray[CDC_NFF-1]);
end

/* Read clock domain (i_rclk). ************************************************/

// Read data path.
always @ (posedge i_rclk)
begin
    if (rhandshk == 1'b1) begin
        rdat_reg <= mem[rptr_nxt];
    end else begin
        rdat_reg <= mem[rptr];
    end
end

// Read control.
assign o_rvld = (rempty == 1'b1) ? 1'b0 : 1'b1;
assign rhandshk = (i_rrdy && o_rvld);
assign rptr_nxt = (rptr == DEPTH-1) ? 'd0 : (rptr + 1);

always @ (posedge i_rclk)
begin
    if (rptr != rcdc_wptr) begin
        rempty <= 1'b0;
    end
    if (rhandshk == 1'b1) begin
        rptr <= rptr_nxt;
        if (rptr_nxt == rcdc_wptr) begin
            rempty <= 1'b1;
        end
    end
end

assign o_rempty = rempty;
assign o_rdat = rdat_reg;

endmodule
