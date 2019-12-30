`include "libhdl_timescale.vh"

module libhdl_srffN
#(  parameter N = 1)
(   input  wire         CK,
    input  wire [N-1:0] S,
    input  wire [N-1:0] R,
    output reg  [N-1:0] Q);

always @ (posedge CK)
    case ({S, R})
        2'b00:   Q <= Q;
        2'b01:   Q <= {N{1'b0}};
        2'b10:   Q <= {N{1'b1}};
        default: Q <= {N{1'bX}};
    endcase

endmodule
