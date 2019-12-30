`include "libhdl_timescale.vh"

module libhdl_andN
#(  parameter N = 2)
(   output wire         O,
    input  wire [N-1:0] I);

assign O = &I;

endmodule
