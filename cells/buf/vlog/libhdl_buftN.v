`include "libhdl_timescale.vh"

module libhdl_buftN
#(  parameter N = 1)
(   output wire         O,
    input  wire         OE,
    input  wire [N-1:0] I);

assign O = (OE == 1'b1) ? I : {N{1'bZ}};

endmodule
