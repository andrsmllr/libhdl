`timescale 1 ns / 1 ps

module libhdl_ocmem_sp
#(  parameter W = 32,
    parameter D = 1024,
    parameter MODE = "READ_FIRST", // {"WRITE_FIRST", "READ_FIRST", "NO_CHANGE"}
    parameter INIT_FILE = "")
(   input  wire                 i_clk,
    input  wire                 i_we,
    input  wire [$clog2(D)-1:0] i_addr,
    input  wire [W-1:0]         i_wdat,
    output wire [W-1:0]         o_rdat);

`ifdef LIBHDL_ASSERT
assert(MODE == "READ_FIRST" || MODE == "WRITE_FIRST" || MODE == "NO_CHANGE");
`endif

reg [W-1:0] mem [D-1:0];

initial begin
    if (INIT_FILE != "") begin
        $display("Initializing memory %m with file %s", INIT_FILE);
        $readmemh(INIT_FILE, mem);
    end
end

reg [W-1:0] rdat_reg;
always @ (posedge i_clk)
begin
    if (MODE == "READ_FIRST") begin
        rdat_reg <= mem[i_addr];
    end
    if (i_we == 1'b1) begin
        mem[i_addr] <= i_wdat;
        if (MODE == "WRITE_FIRST") begin
            rdat_reg <= i_wdat;
        end
    end else begin
        rdat_reg <= mem[i_addr];
    end
end
assign o_rdat = rdat_reg;

endmodule
