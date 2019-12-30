`include "libhdl_timescale.vh"

module libhdl_dffeN
#(  parameter N = 1)
(   input  wire         CK,
    input  wire         CE,
    input  wire [N-1:0] D,
    output reg  [N-1:0] Q);

always @ (posedge CK)
    if (CE == 1'b1)
        Q <= D;

endmodule
