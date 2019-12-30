`include "libhdl_timescale.vh"

module libhdl_ddr2sdrN
#(  parameter N = 1)
(   input  wire           CK,
    input  wire [N-1:0]   D,
    output reg  [N*2-1:0] Q);

genvar k;
generate
for (k = 0; k < N; k = k + 1) begin
    always @ (posedge CK)
        Q[k*2+0] <= D[k];
    always @ (negedge CK)
        Q[k*2+1] <= D[k];
end
endgenerate

endmodule
