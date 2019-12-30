`timescale 1 ns / 1 ps

module libhdl_mux
#(  parameter N = 2,
    parameter W = 1)
(   output wire [N-1:0]         o_mux,
    input  wire [N*W-1:0]       i_data,
    input  wire [$clog2(N)-1:0] i_sel);

assign o_mux = i_data[i_sel*W +: W];

endmodule
