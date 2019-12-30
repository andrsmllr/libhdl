`include "libhdl_timescale.vh"

module libhdl_jkffN
#(  parameter N = 1)
(   input  wire         CK,
    input  wire [N-1:0] J,
    input  wire [N-1:0] K,
    output reg  [N-1:0] Q);

always @ (posedge CK)
    case ({J, K})
        2'b00:   Q <= Q;
        2'b01:   Q <= {N{1'b0}};
        2'b10:   Q <= {N{1'b1}};
        2'b11:   Q <= ~Q;
        default: Q <= {N{1'bX}};
    endcase

endmodule
