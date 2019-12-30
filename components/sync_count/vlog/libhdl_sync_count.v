`timescale 1 ns / 1 ps

module libhdl_sync_count
#(  parameter W = 32,
    parameter NFF = 2,
    parameter INIT_VAL = {W{1'b0}})
(   input  wire         i_iclk,
    input  wire [W-1:0] i_icount,
    input  wire         i_oclk,
    output reg  [W-1:0] o_ocount);

function [W-1:0] bin2gray;
    input [W-1:0] bin;
begin
    bin2gray = bin ^ {1'b0, bin[W-1:1]};
end
endfunction

function [W-1:0] gray2bin;
    input [W-1:0] gray;
    reg [W-1:0] tmp;
    integer i;
begin
    tmp = 'd0;
    tmp[W-1] = gray[W-1];
    for (i = W - 2; i >= 0; i = i - 1) begin
        tmp[i] = tmp[i+1] ^ gray[i];
    end
    gray2bin = tmp;
end
endfunction

reg [W-1:0] icount_gray;
(* ASYNC_REG = "TRUE" *)
reg [W-1:0] ocdc_count [NFF-1:0];
integer i;

always @ (posedge i_iclk)
begin
    icount_gray <= bin2gray(i_icount);
end

always @ (posedge i_oclk)
begin
    ocdc_count[0] <= icount_gray;
    for (i = 1; i < NFF; i = i + 1) begin
        ocdc_count[i] <= ocdc_count[i-1];
    end
end

always @ (posedge i_oclk)
begin
    o_ocount <= gray2bin(ocdc_count[NFF-1]);
end

endmodule
