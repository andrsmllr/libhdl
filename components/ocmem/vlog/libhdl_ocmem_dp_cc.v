`timescale 1 ns / 1 ps

module libhdl_ocmem_dp_cc
#(  parameter W = 32,
    parameter D = 1024,
    parameter MODEA = "READ_FIRST", // {"WRITE_FIRST", "READ_FIRST", "NO_CHANGE"}
    parameter MODEB = "READ_FIRST", // {"WRITE_FIRST", "READ_FIRST", "NO_CHANGE"}
    parameter OREGA = 0,
    parameter OREGB = 0,
    parameter INIT_FILE = "")
(   input  wire                 i_clk,
    input  wire                 i_wea,
    input  wire [$clog2(D)-1:0] i_addra,
    input  wire [W-1:0]         i_wdata,
    output wire [W-1:0]         o_rdata,
    input  wire                 i_web,
    input  wire [$clog2(D)-1:0] i_addrb,
    input  wire [W-1:0]         i_wdatb,
    output wire [W-1:0]         o_rdatb);

`ifdef LIBHDL_ASSERT
assert(MODEA == "READ_FIRST" || MODEA == "WRITE_FIRST" || MODEA == "NO_CHANGE");
assert(MODEB == "READ_FIRST" || MODEB == "WRITE_FIRST" || MODEB == "NO_CHANGE");
assert((i_addra == i_addrb) && !i_wea && !i_web);
`endif

reg [W-1:0] mem [D-1:0];

initial begin
    if (INIT_FILE != "") begin
        $display("Initializing memory %m with file %s", INIT_FILE);
        $readmemh(INIT_FILE, mem);
    end
end

reg [W-1:0] rdata_reg, rdata_reg2;
always @ (posedge i_clk)
begin
    if (MODEA == "READ_FIRST") begin
        rdata_reg <= mem[i_addra];
    end
    if (i_wea == 1'b1) begin
        mem[i_addra] <= i_wdata;
        if (MODEA == "WRITE_FIRST") begin
            rdata_reg <= i_wdata;
        end
    end else begin
        rdata_reg <= mem[i_addra];
    end
    if (OREGA == 1) begin
        rdata_reg2 <= rdata_reg;
    end
end
assign o_rdata = (OREGA == 0) ? rdata_reg : rdata_reg2;

reg [W-1:0] rdatb_reg, rdatb_reg2;
always @ (posedge i_clk)
begin
    if (MODEB == "READ_FIRST") begin
        rdatb_reg <= mem[i_addrb];
    end
    if (i_web == 1'b1) begin
        mem[i_addrb] <= i_wdatb;
        if (MODEB == "WRITE_FIRST") begin
            rdatb_reg <= i_wdatb;
        end
    end else begin
        rdatb_reg <= mem[i_addrb];
    end
    if (OREGB == 1) begin
        rdatb_reg2 <= rdatb_reg;
    end
end
assign o_rdatb = (OREGB == 0) ? rdatb_reg : rdatb_reg2;

endmodule
