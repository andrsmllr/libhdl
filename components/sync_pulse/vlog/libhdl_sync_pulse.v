`timescale 1 ns / 1 ps

module libhdl_sync_pulse
#(  parameter OREG = 1)
(   input  wire i_aClk,
    input  wire i_aPulse,
    output wire o_aBusy,
    input  wire i_bClk,
    output wire o_bPulse);

reg aToggle = 1'b0;
wire aFeedback;
wire bToggle;
reg bToggle_prev = 1'b0;
wire bPulse;
reg bPulse_reg;

assign o_aBusy = (aToggle == aFeedback) ? 1'b0 : 1'b1;

// Detect pulse and create toggle signal.
always @ (posedge i_aClk)
begin
    if (i_aPulse == 1'b1) begin
        if (aToggle == aFeedback) begin
            aToggle <= ~aToggle;
`ifdef LIBHDL_ASSERT
        end else begin
            $error("Missed an inbound pulse (%m)");
`endif
        end
    end
end

// Transfer toggle signal from aClk to bClk domain.
(* ASYNC_REG = "TRUE" *)
reg [1:0] ff_a2b;
always @ (posedge i_bClk) ff_a2b <= {ff_a2b[0], aToggle};
assign bToggle = ff_a2b[1];

// Detect toggle signal and create pulse.
always @ (posedge i_bClk)
begin
    bToggle_prev <= bToggle;
    bPulse_reg <= bToggle ^ bToggle_prev;
end

assign bPulse = bToggle ^ bToggle_prev;
assign o_bPulse = (OREG == 1) ? bPulse_reg : bPulse;

// Transfer feedback signal from bClk to aClk domain.
(* ASYNC_REG = "TRUE" *)
reg [1:0] ff_b2a;
always @ (posedge i_aClk) ff_b2a <= {ff_b2a[0], bToggle};
assign aFeedback = ff_b2a[1];

endmodule
