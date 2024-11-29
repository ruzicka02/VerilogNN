// https://github.com/akilm/FPU-IEEE-754

`timescale 1ns / 1ps

// `ifndef _floating_addition
// `define _floating_addition

// `include "FloatingCompare.v"

module FloatingAddition (
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] result
);

  reg [31:0] A_swap, B_swap;  // comparison-based swap
  wire [23:0] A_Mantissa = {
    1'b1, A_swap[22:0]
  }, B_Mantissa = {
    1'b1, B_swap[22:0]
  };  // stored mantissa is 23b, this is {1'b1, mantissa} = 24b long
  wire [7:0] A_Exponent = A_swap[30:23], B_Exponent = B_swap[30:23];
  wire A_sign = A_swap[31], B_sign = B_swap[31];

  reg [23:0] B_shifted_mantissa, result_Mantissa;
  reg [7:0] result_Exponent;
  reg carry;

  wire comp;

  integer i;  // loop variable

  // compare absolute values of A, B
  FloatingCompare comp_abs (
      .A({1'b0, A[30:0]}),
      .B({1'b0, B[30:0]}),
      .result(comp)
  );

  always @(*) begin
    // let A >= B (switch numbers if needed)
    A_swap = comp ? A : B;
    B_swap = comp ? B : A;

    // shift B to same exponent (A >= B, exponent diff >= 0)
    result_Exponent = A_Exponent;
    B_shifted_mantissa = (B_Mantissa >> (result_Exponent - B_Exponent));

    // sum the mantissas (and store potential carry)
    //  1b              24b    1 if signs are the same     24b                  24b
    {carry, result_Mantissa} = (A_sign ~^ B_sign) ? A_Mantissa + B_shifted_mantissa : A_Mantissa - B_shifted_mantissa;

    // adjust mantissa to format 1.xxxx (bit 23 is 1)
    if (carry) begin
      result_Mantissa = result_Mantissa >> 1;
      result_Exponent = (result_Exponent < 8'hff) ? result_Exponent + 1 : 8'hff;  // protect exponent overflow
    end
        else if(|result_Mantissa != 1'b1) begin  // mantissa contains no 1 or unknown value (result should be 0)
      result_Exponent = 0;  // 2 ** (0-127) is almost 0
    end else begin
      // 1st bit is not 1, but there is some 1 in the mantissa (protecting exponent underflow)
      // fixed limit of iterations because Vivado saw this as an infinite loop
      for (i = 0; result_Mantissa[23] !== 1'b1 && result_Exponent > 0 && i < 24; i = i + 1) begin
        result_Mantissa = result_Mantissa << 1;
        result_Exponent = result_Exponent - 1;
      end
    end

    //        A >= B... sign is kept
    result = {A_sign, result_Exponent, result_Mantissa[22:0]};
  end
endmodule
// `endif  // _floating_addition
