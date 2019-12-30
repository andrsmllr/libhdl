`timescale 1 ns / 1 ps

module libhdl_add
#(  parameter N = 2,
    parameter W = 8)
(   output wire [W+$clog2(N)-1 : 0] o_sum,
    input  wire [N*W-1 : 0]         i_op);

reg [W+$clog2(N)-1 : 0] sum;
integer k;

always @ (*)
begin
    sum = 0;
    for (k = 0; k < N; k = k + 1) begin
        sum = sum + i_op[k*W +: W];
    end
end

assign o_sum = sum;

endmodule
