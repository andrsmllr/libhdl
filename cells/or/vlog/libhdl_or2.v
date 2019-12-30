`include "libhdl_timescale.vh"

module libhdl_or2
(   output wire O,
    input  wire I1,
    input  wire I2);

assign O = I1 | I2;

endmodule
