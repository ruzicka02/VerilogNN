`ifndef _softplus
`define _softplus

`include "LogarithmApprox.v"
`include "FloatingAddition.v"
`include "FloatingMultiplication.v"
`include "FloatingDivision.v"
`include "FloatingCompare.v"



module Softplus (
    x_value,
    result
);
  input [31:0] x_value;
  output reg [31:0] result;

  wire [31:0] zero = 32'b0_00000000_00000000000000000000000;
  wire [31:0] neg_two = 32'b1_10000000_00000000000000000000000;
  wire [31:0] three = 32'b0_10000000_10000000000000000000000;


  wire greater_three;
  wire smaller_neg_two;
  wire [31:0] store;

  FloatingCompare F1 (
      .A(x_value),
      .B(three),
      .result(greater_three)
  );
  FloatingCompare F2 (
      .A(neg_two),
      .B(x_value),
      .result(smaller_neg_two)
  );

  LogarithmApprox L1 (
      .x_value(x_value),
      .result (store)
  );

  always @(*) begin
    if (greater_three) begin
      result = x_value;
    end else if (smaller_neg_two) begin
      result = zero;
    end else begin
      result = store;
    end
  end

endmodule

`endif  // _softplus
