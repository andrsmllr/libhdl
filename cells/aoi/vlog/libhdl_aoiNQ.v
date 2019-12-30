`include "libhdl_timescale.vh"

module libhdl_aoNQ
#(  parameter N = 2,
    parameter Q = 2)
(   output wire           O,
    input  wire [N*Q-1:0] I);

wire [Q-1:0] Iand;
genvar k;
generate
    for (k = 0; k < Q; k = k + 1) begin
        assign Iand[k] = &I[k*N +: N];
    end
endgenerate

assign O = ~(|Iand);

endmodule
