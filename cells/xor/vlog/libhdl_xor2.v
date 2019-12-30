`include "libhdl_timescale.vh"

module libhdl_xor2
(   output wire O,
    input  wire I1,
    input  wire I2);

assign O = I1 ^ I2;

endmodule
