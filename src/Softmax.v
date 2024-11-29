`ifndef _softmax
`define _softmax

`include "E_Function.v"
`include "VectorSum.v"
`include "FloatingDivision.v"

module Softmax #(
    parameter VLEN = 4
)  // IN SIZE should be equal to out size since each value gets a probability
(
    input  [(32 * VLEN) - 1 : 0] in,
    output [(32 * VLEN) - 1 : 0] result
);

  wire [(32 * VLEN) - 1:0] E_storage;
  wire [31:0] sum;
  wire zerodivision;

  genvar i;
  generate
    for (i = 0; i < VLEN; i = i + 1) begin
      e_function E1 (
          .x_value(in[32*i+:32]),
          .result (E_storage[32*i+:32])
      );
    end
  endgenerate

  VectorSum #(
      .VLEN(VLEN)
  ) V1 (
      .Vector(E_storage),
      .result(sum)
  );

  genvar j;
  generate
    for (j = 0; j < VLEN; j = j + 1) begin
      FloatingDivision F1 (
          .A(E_storage[32*j+:32]),
          .B(sum),
          .zero_division(zerodivision),
          .result(result[32*j+:32])
      );
    end
  endgenerate

  // probably some safety measures regarding Zero Div still needed !
endmodule
`endif  // _softmax
