`timescale 1 ns / 1 ps

module libhdl_count
#(  parameter COUNT_LEN = 8)
(   input  wire                 i_clk,
    input  wire                 i_ce,
    input  wire                 i_lden,
    input  wire [COUNT_LEN-1:0] i_ldval,
    input  wire                 i_up_ndown,
    output reg  [COUNT_LEN-1:0] o_count);

always @ (posedge i_clk)
begin
    if (i_ce == 1'b1) begin
        if (i_lden == 1'b1) begin
            o_count <= i_ldval;
        end else begin
            o_count <= (i_up_ndown == 1'b1) ? o_count + 1 : o_count - 1;
        end
    end
end

endmodule
