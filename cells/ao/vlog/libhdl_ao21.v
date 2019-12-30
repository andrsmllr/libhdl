`include "libhdl_timescale.vh"

module libhdl_ao21
(   output wire O,
    input  wire IA1,
    input  wire IA2,
    input  wire IB1);

assign O = (IA1 & IA2) | IB1;

endmodule
