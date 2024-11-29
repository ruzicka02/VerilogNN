// https://github.com/akilm/FPU-IEEE-754

`timescale 1ns / 1ps
`include "FloatingAddition.v"
`include "DisplayFloat.v"

module FloatAdditionTB;
  reg [31:0] A, B;
  wire [31:0] result;
  real value;

  FloatingAddition F_Add (
      .A(A),
      .B(B),
      .result(result)
  );
  DisplayFloat display_A (
      .num(A),
      .id("A  "),
      .format(1'b1)
  );
  DisplayFloat display_B (
      .num(B),
      .id("B  "),
      .format(1'b1)
  );
  DisplayFloat display_result1 (
      .num(result),
      .id("Res"),
      .format(1'b0)
  );

  initial begin
    A = 32'b0_10000000_10011001100110011001100;  // 3.2
    B = 32'b0_10000001_00001100110011001100110;  // 4.2
    #20 A = 32'b0_01111110_01010001111010111000010;  // 0.66
    B = 32'b0_01111110_00000101000111101011100;  // 0.51
    #20 A = 32'b1_01111110_00000000000000000000000;  // -0.5
    B = 32'b1_10000001_10011001100110011001100;  // -6.4
    #20 A = 32'b1_01111110_00000000000000000000000;  // -0.5
    B = 32'b0_10000001_10011001100110011001100;  //  6.4
    #20 A = 32'h4034b4b5;
    B = 32'hbf70f0f1;
    #20 A = 32'b1_10000000_00000000000000000000000;  // -2.0
    B = 32'b0_10000000_10000000000000000000000;  //  3.0
  end

  initial begin
    $dumpfile("vcd/FloatAdditionTB.vcd");
    $dumpvars;

    // $monitor("A =     %b 1.%b * 2 ^ (%0d - 127)\nB =     %b 1.%b * 2 ^ (%0d - 127)\nA  +  B = %b 1.%b * 2 ^ (%0d - 127)",
    // A[31], A[22:0], A[30:23],
    // B[31], B[22:0], B[30:23],
    // result[31], result[22:0], result[30:23]);

    #15 $display("Expected Value : %f", 3.2 + 4.2);
    #20 $display("Expected Value : %f", 0.66 + 0.51);
    #20 $display("Expected Value : %f", -0.5 - 6.4);
    #20 $display("Expected Value : %f", -0.5 + 6.4);
    #20 $display("Expected Value : %f", 2.82 - 0.94);
    #20 $display("Expected Value : %f", -2.0 + 3.0);
    $finish;
  end
endmodule
