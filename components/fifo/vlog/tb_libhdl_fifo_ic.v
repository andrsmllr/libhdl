`timescale 1 ns / 1 ps

module tb_libhdl_fifo_ic;

parameter DUT_DATA_LEN = 32;
parameter DUT_DEPTH = 16;
parameter DUT_FILL_CNT_ENA = 1;
parameter DUT_ALMOST_EMPTY_ENA = 1;
parameter DUT_ALMOST_FULL_ENA = 1;
parameter DUT_ALMOST_EMPTY_CNT = DUT_DEPTH/4;
parameter DUT_ALMOST_FULL_CNT = DUT_DEPTH - DUT_DEPTH/4;

reg                     i_wclk = 1'b1;
wire                    o_wrdy;
reg                     i_wvld = 1'b0;
reg  [DUT_DATA_LEN-1:0] i_wdat = 'd0;
wire                    o_wfull;
wire                    o_walmost_full;
wire                    o_wcount;

reg                     i_rclk = 1'b1;
reg                     i_rrdy = 1'b0;
wire                    o_rvld;
wire [DUT_DATA_LEN-1:0] o_rdat;
wire                    o_rempty;
wire                    o_ralmost_empty;
wire                    o_rcount;

reg [DUT_DATA_LEN-1:0] word;
reg run;
integer i = 0;
integer j = 0;

task write_word;
    input  [DUT_DATA_LEN-1:0] i_word;
    input                     i_clk;
    output [DUT_DATA_LEN-1:0] o_wdat;
    output                    o_wvld;
    input                     i_wrdy;
    reg run;
begin
    o_wdat = i_word;
    o_wvld = 1'b1;
    run = 1'b1;
$display("Entering write while loop");
    while (run != 1'b0) begin
        @(posedge i_clk);
$display("After edge");
        if (i_wrdy == 1'b1 && o_wvld == 1'b1) run = 1'b0;
    end
    o_wvld = 1'b0;
end
endtask

task read_word;
    output reg [DUT_DATA_LEN-1:0] o_word;
    input                         i_clk;
    input  reg [DUT_DATA_LEN-1:0] i_rdat;
    input  reg                    i_rvld;
    output reg                    o_rrdy;
    reg run;
begin
    o_rrdy <= 1'b1;
    run = 1'b1;
    while (run != 0) begin
        @(posedge i_clk);
        o_word <= i_rdat;
        if (o_rrdy == 1'b1 && i_rvld == 1'b1) run = 1'b0;
    end
    o_rrdy <= 1'b0;
end
endtask

initial begin : tb
    $dumpfile("tb_libhdl_fifo_cc.vcd");
    $dumpvars;
    repeat (10) @(posedge i_wclk);

    $display("Write single word");
    @(posedge i_wclk);
    i_wvld <= 1'b1;
    i_wdat <= $random;
    @(posedge i_wclk);
    i_wvld <= 1'b0;
    repeat (10) @(posedge i_wclk);

    $display("Write until full");
    while (o_wrdy == 1'b1) begin
        i_wvld <= o_wrdy;
        i_wdat <= $random;
        @(posedge i_wclk);
        #1;
    end
    i_wvld <= 1'b0;
    repeat (10) @(posedge i_rclk);

    $display("Read until empty");
    while (o_rvld == 1'b1) begin
        i_rrdy <= o_rvld;
        @(posedge i_rclk);
        #1;
    end
    i_rrdy <= 1'b0;
    repeat (10) @(posedge i_wclk);

    $display("Write single word and read ASAP");
    i_rrdy <= 1'b1;
    i_wvld <= 1'b1;
    i_wdat <= $random;
    @(posedge i_wclk);
    i_wvld <= 1'b0;
    repeat (10) @(posedge i_rclk);

    $display("Write and read continuously");
    fork
        begin : write_fork
            for (i = 0; i < 100; i = i + 1) begin
                i_wdat <= $random;
                i_wvld <= 1'b1;
                run = 1'b1;
                while (run != 1'b0) begin
                    @(posedge i_wclk);
                    if (o_wrdy == 1'b1 && i_wvld == 1'b1) run = 1'b0;
                end
                i_wvld <= 1'b0;
                $display("Write word %d", i_wdat);
            end
        end
        begin : read_fork
            for (j = 0; j < 100; j = j + 1) begin
                i_rrdy <= 1'b1;
                run = 1'b1;
                while (run != 0) begin
                    @(posedge i_rclk);
                    word = o_rdat;
                    if (i_rrdy == 1'b1 && o_rvld == 1'b1) run = 1'b0;
                end
                i_rrdy <= 1'b0;
                $display("Read word %d", word);
                if (j == 50) begin
                    $display("Wait until FIFO full");
                    wait(o_wfull == 1'b1);
                    $display("Wait some more time");
                    repeat (10) @(posedge i_rclk);
                    $display("Continue");
                end
            end
        end
    join
    repeat (10) @(posedge i_wclk);

    $finish;
end

always #7 i_wclk <= ~i_wclk;
always #11 i_rclk <= ~i_rclk;

libhdl_fifo_ic
#(  .DATA_LEN(DUT_DATA_LEN),
    .DEPTH(DUT_DEPTH),
    .FILL_CNT_ENA(DUT_FILL_CNT_ENA),
    .ALMOST_EMPTY_ENA(DUT_ALMOST_EMPTY_ENA),
    .ALMOST_FULL_ENA(DUT_ALMOST_FULL_ENA),
    .ALMOST_EMPTY_CNT(DUT_ALMOST_EMPTY_CNT),
    .ALMOST_FULL_CNT(DUT_ALMOST_FULL_CNT))
dut
(   .i_wclk(i_wclk),
    .o_wrdy(o_wrdy),
    .i_wvld(i_wvld),
    .i_wdat(i_wdat),
    .o_wfull(o_wfull),
    .o_walmost_full(o_walmost_full),
    .o_wcount(o_wcount),

    .i_rclk(i_rclk),
    .i_rrdy(i_rrdy),
    .o_rvld(o_rvld),
    .o_rdat(o_rdat),
    .o_rempty(o_rempty),
    .o_ralmost_empty(o_ralmost_empty),
    .o_rcount(o_rcount));

endmodule
