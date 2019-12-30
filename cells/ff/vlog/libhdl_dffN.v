`include "libhdl_timescale.vh"

module libhdl_dffN
#(  parameter N = 1)
(   input  wire         CK,
    input  wire [N-1:0] D,
    output reg  [N-1:0] Q);

always @ (posedge CK)
    Q <= D;

endmodule
