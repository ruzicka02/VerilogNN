`ifndef _hyperbolic_tangent
`define _hyperbolic_tangent

`include "E_Function.v"
`include "FloatingDivision.v"
`include "FloatingAddition.v"

// Hyperbolic tangent calculated using exponential function as following:
// f(x) = (e^num - e^(-num)) / (e^num + e^(-num))
module HyperbolicTangent (
    input  [31:0] num,
    output [31:0] result
);

  wire [31:0] one = 32'b0_01111111_00000000000000000000000;
  wire [31:0] E_storage;  // e^num
  wire [31:0] E_inverse;  // e^(-num) == (e^num) ^ -1
  wire zero_division;

  wire [31:0] numerator;  // e^num - e^(-num)
  wire [31:0] denominator;  // e^num + e^(-num)
  wire [31:0] fraction;

  e_function E1 (
      .x_value(num),
      .result (E_storage)
  );

  FloatingDivision F1 (
      .A(one),
      .B(E_storage),
      .result(E_inverse)
  );

  // e_function E2 (.x_value({~num[31],num[30:0]}),
  //                .result(E_inverse));

  wire [31:0] E_inverse_flipped;
  assign E_inverse_flipped = {~E_inverse[31], E_inverse[30:0]};

  FloatingAddition A1 (
      .A(E_storage),
      .B(E_inverse_flipped),
      .result(numerator)
  );

  FloatingAddition A2 (
      .A(E_storage),
      .B(E_inverse),
      .result(denominator)
  );

  FloatingDivision F2 (
      .A(numerator),
      .B(denominator),
      .zero_division(zero_division),
      .result(fraction)
  );

  assign result = fraction;
endmodule

`endif  // _hyperbolic_tangent
