
`ifndef _e_function
`define _e_function

`include "FloatingAddition.v"
`include "FloatingMultiplication.v"
`include "FloatingDivision.v"

// approximates exponential function using 5th degree Taylor polynomial. For negative inputs,
// calculates e^(-x) instead (to avoid negative polynomial values) and outputs inverse of it.
module e_function (
    x_value,
    result
);
  input [31:0] x_value;
  output reg [31:0] result;

  wire [31:0] one = 32'b0_01111111_00000000000000000000000;
  wire [31:0] two = 32'b0_10000000_00000000000000000000000;
  wire [31:0] six = 32'b0_10000001_10000000000000000000000;
  wire [31:0] twentyfour = 32'b0_10000011_10000000000000000000000;
  wire [31:0] hundredtwenty = 32'b0_10000101_11100000000000000000000;

  wire [31:0] x_2, x_3, x_4, x_5;
  wire [31:0] xd_2, xd_3, xd_4, xd_5;
  wire [31:0] p1, p2, p3, p4;

  wire [31:0] sum1, sum2, sum3, sum4, sum5;
  wire [31:0] res_inverse;

  wire is_negative = x_value[31];
  wire [31:0] x_positive = {1'b0, x_value[30:0]};


  FloatingMultiplication mult2 (
      .A(x_positive),
      .B(x_positive),
      .result(x_2)
  );  // already returns x squared
  FloatingMultiplication mult3 (
      .A(x_2),
      .B(x_positive),
      .result(x_3)
  );
  FloatingMultiplication mult4 (
      .A(x_3),
      .B(x_positive),
      .result(x_4)
  );
  FloatingMultiplication mult5 (
      .A(x_4),
      .B(x_positive),
      .result(x_5)
  );

  FloatingDivision Div2 (
      .A(x_2),
      .B(two),
      .result(xd_2)
  );
  FloatingDivision Div3 (
      .A(x_3),
      .B(six),
      .result(xd_3)
  );
  FloatingDivision Div4 (
      .A(x_4),
      .B(twentyfour),
      .result(xd_4)
  );
  FloatingDivision Div5 (
      .A(x_5),
      .B(hundredtwenty),
      .result(xd_5)
  );

  FloatingAddition add1 (
      .A(one),
      .B(x_positive),
      .result(sum1)
  );
  FloatingAddition add2 (
      .A(sum1),
      .B(xd_2),
      .result(sum2)
  );
  FloatingAddition add3 (
      .A(sum2),
      .B(xd_3),
      .result(sum3)
  );
  FloatingAddition add4 (
      .A(sum3),
      .B(xd_4),
      .result(sum4)
  );
  FloatingAddition add5 (
      .A(sum4),
      .B(xd_5),
      .result(sum5)
  );

  FloatingDivision negativ (
      .A(one),
      .B(sum5),
      .result(res_inverse)
  );

  always @(*) begin
    if (is_negative) begin
      result = res_inverse;
    end else begin
      result = sum5;
    end
  end

endmodule
`endif  // _e_function
