`include "libhdl_timescale.vh"

module libhdl_tffN
#(  parameter N = 1)
(   input  wire         CK,
    input  wire         RST,
    input  wire [N-1:0] T,
    output reg  [N-1:0] Q);

always @ (posedge CK, posedge RST)
    if (RST == 1'b1)
        Q <= 1'b0;
    else if (T == 1'b1)
        Q <= ~Q;

endmodule
