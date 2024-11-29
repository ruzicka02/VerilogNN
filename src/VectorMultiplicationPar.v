`timescale 1ns / 1ps

`ifndef _vector_multiplication_par
`define _vector_multiplication_par

// `include "FloatingMultiplication.v"
// `include "FloatingAddition.v"

// also known as dot product
module VectorMultiplicationPar #(
    parameter VLEN = 3
) (
    input [(32 * VLEN) - 1:0] A,
    input [(32 * VLEN) - 1:0] B,
    output [31:0] result
);
  wire [31:0] partial_sums[0:VLEN-1];

  genvar i;
  generate
    for (i = 0; i < VLEN; i = i + 1) begin
      wire [31:0] A_item = A[32*i+:32];
      wire [31:0] B_item = B[32*i+:32];
      wire [31:0] temp;
      FloatingMultiplication mult1 (
          .A(A_item),
          .B(B_item),
          .result(temp)
      );  // element-wise multiplication

      if (i == 0) assign partial_sums[i] = temp;
      else
        FloatingAddition add1 (
            .A(temp),
            .B(partial_sums[i-1]),
            .result(partial_sums[i])
        );
    end
  endgenerate

  assign result = partial_sums[VLEN-1];
endmodule
`endif  // _vector_multiplication_par
