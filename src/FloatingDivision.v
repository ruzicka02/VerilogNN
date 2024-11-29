// https://github.com/akilm/FPU-IEEE-754
//
// Division Algorithm : A/B
//     Intial Seed : x0 = 48/17 - (32/17)*D
//     where D - Divisor B adjusted to fit <0.5, 1) range by replacing the exponent field with 8'd126
//
//     Newton Raphson Iterations :
//                   x1 = x0*(2-D*x0)
//                   x2 = x1*(2-D*x1)
//                   x3 = x2*(2-D*x2)
//     x3 - Reciprocal of Adusted value D.
//     Adjust the exponents to produce the final reciprocal of B
//     1/B : {B[31], x3[30:23] + 8'd126 - B[30:23], x3[22:0]}
//     Final Value A * (1/B)


`timescale 1ns / 1ps

// `ifndef _floating_division
// `define _floating_division

// `include "FloatingMultiplication.v"
//`include "FloatingAddition.v"

// Uses Newton Raphson Iterations to find the reciprocal of the Divisor and then Multiplies the Reciprocal with the Dividend.
module FloatingDivision (
    input [31:0] A,
    input [31:0] B,
    output zero_division,
    output [31:0] result
);

  wire [7:0] Exponent;
  wire [31:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, result_unprotected;
  wire [31:0] reciprocal;
  wire [31:0] x0, x1, x2, x3;

  // zero division flag
  assign zero_division = (B[30:23] == 0) ? 1'b1 : 1'b0;

  // ----Initial value----       B_Mantissa * (2 ^ -1)            32 / 17
  FloatingMultiplication M1 (
      .A({{1'b0, 8'd126, B[22:0]}}),
      .B(32'h3ff0_f0f1),
      .result(temp1)
  );
  //                         48 / 17        -abs(temp1)
  FloatingAddition A1 (
      .A(32'h4034_b4b5),
      .B({1'b1, temp1[30:0]}),
      .result(x0)
  );

  /*----First Iteration----*/
  FloatingMultiplication M2 (
      .A({{1'b0, 8'd126, B[22:0]}}),
      .B(x0),
      .result(temp2)
  );
  FloatingAddition A2 (
      .A(32'h4000_0000),
      .B({!temp2[31], temp2[30:0]}),
      .result(temp3)
  );
  FloatingMultiplication M3 (
      .A(x0),
      .B(temp3),
      .result(x1)
  );

  /*----Second Iteration----*/
  FloatingMultiplication M4 (
      .A({1'b0, 8'd126, B[22:0]}),
      .B(x1),
      .result(temp4)
  );
  FloatingAddition A3 (
      .A(32'h4000_0000),
      .B({!temp4[31], temp4[30:0]}),
      .result(temp5)
  );
  FloatingMultiplication M5 (
      .A(x1),
      .B(temp5),
      .result(x2)
  );

  /*----Third Iteration----*/
  FloatingMultiplication M6 (
      .A({1'b0, 8'd126, B[22:0]}),
      .B(x2),
      .result(temp6)
  );
  FloatingAddition A4 (
      .A(32'h4000_0000),
      .B({!temp6[31], temp6[30:0]}),
      .result(temp7)
  );
  FloatingMultiplication M7 (
      .A(x2),
      .B(temp7),
      .result(x3)
  );

  /*----Reciprocal : 1/B----*/
  assign Exponent   = x3[30:23] + 8'd126 - B[30:23];
  assign reciprocal = {B[31], Exponent, x3[22:0]};

  /*----Multiplication A*1/B----*/
  FloatingMultiplication M8 (
      .A(A),
      .B(reciprocal),
      .result(result_unprotected)
  );

  assign result = ((A[30:23] == 0) || zero_division) ? 32'h0000_0000 : result_unprotected;
endmodule
// `endif  // _floating_division
