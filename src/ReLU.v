`timescale 1ns / 1ps

`ifndef _relu
`define _relu

module ReLU (
    input      [31:0] num,
    output reg [31:0] result
);

  always @(num) begin
    if (num[31] == 1'b1)  // number is negative
      result = 32'h0000_0000;  // 2 ^ -127, approx. 0
    else result = num;
  end
endmodule
`endif  // _relu
