`timescale 1ns / 1ps
`include "ReLU.v"
`include "Sigmoid.v"
`include "DisplayFloat.v"

module ActivationTB;
  reg [31:0] num;
  wire [31:0] result_relu, result_sigmoid;

  ReLU relu (
      .num(num),
      .result(result_relu)
  );
  Sigmoid sigmoid (
      .num(num),
      .result(result_sigmoid)
  );

  DisplayFloat display_num (
      .num(num),
      .id("num"),
      .format(1'b0)
  );
  DisplayFloat display_relu (
      .num(result_relu),
      .id("rlu"),
      .format(1'b0)
  );
  DisplayFloat display_sigmoid (
      .num(result_sigmoid),
      .id("sgm"),
      .format(1'b0)
  );

  initial begin
    num = 32'b0_10000000_10011001100110011001100;  //  3.2
    #20 num = 32'b0_01111110_01010001111010111000010;  //  0.66
    #20 num = 32'b1_01111110_00000000000000000000000;  // -0.5
    #20 num = 32'b0_00000000_00000000000000000000000;  //  0.0
    #20 num = 32'b0_11111111_00000000000000000000000;  //  2 ^ 128
    #20 num = 32'b1_11111111_00000000000000000000000;  // -2 ^ 128
  end

  initial begin
    $dumpfile("vcd/ActivationTB.vcd");
    $dumpvars;

    #20 $display("\nt = %0t", $time);

    #20 $display("\nt = %0t", $time);

    #20 $display("\nt = %0t", $time);

    #20 $display("\nt = %0t", $time);

    #20 $display("\nt = %0t", $time);

    #20 $finish;
  end
endmodule
