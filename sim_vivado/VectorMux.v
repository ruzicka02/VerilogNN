`timescale 1ns / 1ps

// Outputs n-th element of a vector of (VLEN) floating point numbers in designated format.
// Output is changed on every clock cycle.
module VectorMux #(
    VLEN = 1
) (
    input clk,
    input [(32 * VLEN) - 1:0] vec,
    output reg [31:0] num
);
  integer idx = 0;

  always @(posedge clk) begin
    num = vec[32*idx+:32];
    idx = (idx < VLEN - 1) ? idx + 1 : 0;
  end

endmodule
