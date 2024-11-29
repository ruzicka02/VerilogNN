`timescale 1ns / 1ps

`ifndef _vector_multiplication_seq
`define _vector_multiplication_seq

`include "FloatingMultiplication.v"
`include "FloatingAddition.v"

// also known as dot product. Sequentialized into MOD_COUNT multipliers and adders.
// it is expected that MOD_COUNT <= VLEN (and ideally VLEN % MOD_COUNT == 0).
// in case MOD_COUNT == VLEN this should behave similarly to VecMultPar (while being unnecessarily complex)
module VectorMultiplicationSeq #(
    parameter VLEN = 1,
    MOD_COUNT = 1
) (
    input      [(32 * VLEN) - 1:0] A,
    input      [(32 * VLEN) - 1:0] B,
    input                          clk,
    output reg [             31:0] result,
    output reg                     done
);  // indicates that computing is complete
  reg [(32 * MOD_COUNT) - 1:0] A_items = 0, B_items = 0;  // automatic padding with 0s
  wire [(32 * MOD_COUNT) - 1:0] partial_sums;
  reg
      input_changed = 1'b0,  // input changed while in a computing cycle
      almost_done = 1'b0;  // data loading is finished, wait 1 cycle for final computations

  // computing modules
  for (genvar i = 0; i < MOD_COUNT; i = i + 1) begin
    wire [31:0] product;  // this can be purely "local variable", not accessed from the outside

    FloatingMultiplication mult1 (
        .A(A_items[32*i+:32]),
        .B(B_items[32*i+:32]),
        .result(product)
    );  // element multiplication

    // sum the product with the previous "partial sum"
    if (i == 0)
      FloatingAddition add1 (
          .A(product),
          .B(result),
          .result(partial_sums[32*i+:32])
      );
    else
      FloatingAddition add1 (
          .A(product),
          .B(partial_sums[32*(i-1)+:32]),
          .result(partial_sums[32*i+:32])
      );
  end

  initial begin
    result = 32'h0000_0000;  // eliminate unknown X's
    done   = 1'b0;
  end

  // flip down switches
  always @(A, B) begin
    almost_done = 1'b0;
    done = 1'b0;
    input_changed = 1'b1;
  end

  // computing cycle (essentially a for cycle simulated by clock)
  // stop computing once done is set to 1 (otherwise, sum would grow infinitely)
  integer i = 0, j;
  always @(posedge (clk & ~done)) begin
    // add what was calculated in the previous cycle (last of the partial sums)
    // as long as A_items, B_items and result are the same, partial_sums wire doesnt change
    result = partial_sums[32*(MOD_COUNT-1)+:32];

    // start computing from the beginning
    if (input_changed) begin
      i = 0;
      result = 32'h0000_0000;
      input_changed = 1'b0;
    end

    // end computing
    if (almost_done) done = 1'b1;

    // load data into input registers
    for (j = 0; j < MOD_COUNT; j = j + 1) begin
      // instead of A B overflow, fill the rest with zeros so that the result is unaffected
      A_items[32*j+:32] = almost_done ? 32'h0000_0000 : A[32*i+:32];
      B_items[32*j+:32] = almost_done ? 32'h0000_0000 : B[32*i+:32];

      // increase counter
      i = i + 1;

      // loading data finished
      if (i >= VLEN) almost_done = 1'b1;
    end

    // computation is performed until the next clock tick (and added to result afterwards)
  end
endmodule
`endif  // _vector_multiplication_seq
