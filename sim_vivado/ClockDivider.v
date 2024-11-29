`timescale 1ns / 1ps

// Divides the input clock frequency by 2 ** RATIO_EXP. Stores a register
// of RATIO_EXP bits, incremented by one on input clock and outputs the
// highest bit.
module ClockDivider #(
    RATIO_EXP = 1
) (
    input  clk_in,
    output clk_out
);
  reg [RATIO_EXP - 1:0] ctr = 0;
  assign clk_out = ctr[RATIO_EXP-1];

  always @(posedge clk_in) begin
    ctr = ctr + 1;
  end

endmodule
