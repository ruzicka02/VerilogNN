`timescale 1ns / 1ps

`include "FloatingDivision.v"
`include "Sigmoid.v"
// implementing so-called fast sigmoid, approximating with x / (1 + abs(x))
// result is transformed to range <0, 1> for consistency with typical NN usage

// f(x)
// f`(x) = f(x) * (1 - f(x))
module Sigmoid_derivative (
    input  [31:0] num,
    output [31:0] result
);

  wire [31:0] result_sigmoid;
  wire [31:0] one_minus_sigmoid;
  wire [31:0] product;
  wire [31:0] one = 32'b0_01111111_00000000000000000000000;

  Sigmoid sigmoid (
      .num(num),
      .result(result_sigmoid)
  );
  FloatingAddition add1 (
      .A(one),
      .B({~result_sigmoid[31], result_sigmoid[30:0]}),
      .result(one_minus_sigmoid)
  );  // FloatingAddition add1(.A(one), .B({ 1'b1,result_sigmoid[30:0]}) ,.result(one_minus_sigmoid));
  FloatingMultiplication mul1 (
      .A(result_sigmoid),
      .B(one_minus_sigmoid),
      .result(product)
  );

  assign result = product;
endmodule
