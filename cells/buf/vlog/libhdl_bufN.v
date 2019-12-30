`include "libhdl_timescale.vh"

module libhdl_bufN
#(  parameter N = 1)
(   output wire         O,
    input  wire [N-1:0] I);

assign O = I;

endmodule
