`include "libhdl_timescale.vh"

module libhdl_sdr2ddrN
#(  parameter N = 1)
(   input  wire           CK,
    input  wire [N*2-1:0] D,
    output wire [N-1:0]   Q);

reg [N-1:0] Qr = {N{1'b0}};
reg [N-1:0] Qf = {N{1'b0}};

genvar k;
generate
for (k = 0; k < N; k = k + 1) begin
    always @ (posedge CK)
        Qr[k] <= D[k*2+0];
    always @ (negedge CK)
        Qf[k] <= D[k*2+1];
end
endgenerate

assign Q = (CK == 1'b1) ? Qr : Qf;

endmodule
