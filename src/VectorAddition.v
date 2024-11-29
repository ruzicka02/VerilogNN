`timescale 1ns / 1ps

// `ifndef _vector_addition
// `define _vector_addition

// `include "FloatingAddition.v"

// add two vectors of same length VLEN element-wise
module VectorAddition #(
    parameter VLEN = 3
) (
    input  [(32 * VLEN) - 1:0] A,
    input  [(32 * VLEN) - 1:0] B,
    output [(32 * VLEN) - 1:0] result
);

  for (genvar i = 0; i < VLEN; i = i + 1) begin
    wire [31:0] A_item = A[32*i+:32];
    wire [31:0] B_item = B[32*i+:32];

    FloatingAddition add1 (
        .A(A_item),
        .B(B_item),
        .result(result[32*i+:32])
    );  // element-wise addition
  end
endmodule
// `endif  // _vector_addition
