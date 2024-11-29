`timescale 1ns / 1ps

`ifndef _sigmoid
`define _sigmoid

`include "FloatingDivision.v"

// implementing so-called fast sigmoid, approximating with x / (1 + abs(x))
// result is transformed to range <0, 1> for consistency with typical NN usage
module Sigmoid (
    input  [31:0] num,
    output [31:0] result
);
  wire [31:0] denominator, result_wide, result_unprotected;
  wire [31:0] one = 32'b0_01111111_00000000000000000000000;  // 1.00... * 2 ^ 0
  wire [31:0] one_half = 32'b0_01111110_00000000000000000000000;  // 1.00... * 2 ^ -1 = 0.5
  wire [31:0] abs_num = {1'b0, num[30:0]};  // effectively setting the sign bit to 0 (positive)

  FloatingAddition add1 (
      .A(one),
      .B(abs_num),
      .result(denominator)
  );
  FloatingDivision div1 (
      .A(num),
      .B(denominator),
      .result(result_wide)
  );  // range <-1, 1>; need to transform

  // first, divide by 2 (decrease exponent by 1, as long as it is not 0)
  wire [7:0] new_exponent = (result_wide[30:23] == 0) ? result_wide[30:23] : result_wide[30:23] - 1;
  // add 1 / 2
  FloatingAddition add2 (
      .A(one_half),
      .B({result_wide[31], new_exponent, result_wide[22:0]}),
      .result(result_unprotected)
  );

  // protecting zero division
  assign result = (denominator[30:23] == 0) ? one_half : result_unprotected;
endmodule
`endif  // _sigmoid
