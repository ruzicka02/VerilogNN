`timescale 1ns / 1ns

`ifndef _vector_sum
`define _vector_sum

`include "FloatingAddition.v"

// outputs the sum of all values in the input vector
module VectorSum #(
    parameter VLEN = 4
)  // ALWAYS ADJUST THE PARAMETER !!!!!!
(
    input [(32 * VLEN) - 1:0] Vector,
    output [31:0] result
);

  wire [(32 * VLEN) - 1:0] sumvector;

  genvar i;
  generate
    for (i = 0; i < VLEN; i = i + 1) begin
      if (i == 0) begin
        // FloatingAddition FL(.A(32'b0_00000000_00000000000000000000000), .B(Vector[32* i +: 32]), .result(sumvector[31:0]));
        assign sumvector[31:0] = Vector[31:0];
      end else begin
        FloatingAddition FL (
            .A(sumvector[32*(i-1)+:32]),
            .B(Vector[32*i+:32]),
            .result(sumvector[32*i+:32])
        );
      end
    end
  endgenerate
  assign result = sumvector[32*(VLEN-1)+:32];
endmodule

`endif  // _vector_sum
