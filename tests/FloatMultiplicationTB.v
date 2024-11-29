// https://github.com/akilm/FPU-IEEE-754
// slightly modified for use with GTKWave

`timescale 1ns / 1ps
`include "FloatingMultiplication.v"

module FloatMultiplicationTB;
  reg [31:0] A, B;
  wire [31:0] result;
  real value;  // real (64bit FP) not synthesizable, only for sim comparison

  FloatingMultiplication F_Mult (
      .A(A),
      .B(B),
      .result(result)
  );

  // numbers assignments
  initial begin
    A = 32'b0_10000000_10011001100110011001100;  // 3.2
    B = 32'b0_10000001_00001100110011001100110;  // 4.2
    #20 A = 32'b0_01111110_01010001111010111000010;  // 0.66
    B = 32'b0_01111110_00000101000111101011100;  // 0.51
    #20 A = 32'b1_01111110_00000000000000000000000;  // -0.5
    B = 32'b1_10000001_10011001100110011001100;  // -6.4
    #20 A = 32'b1_01111110_00000000000000000000000;  // -0.5
    B = 32'b0_10000001_10011001100110011001100;  //  6.4
    #20
    // testing exponent underflow
    A = 32'h0000_0000;
    B = 32'h0000_0000;
  end

  // displaying
  initial begin
    // FP number in hex
    // $monitor("A = %0h, B = %0h, A * B = %0h", A, B, result);

    // different parts of the FP number
    $monitor(
        "A =     %b 1.%b * 2 ^ (%0d - 127)\nB =     %b 1.%b * 2 ^ (%0d - 127)\nA * B = %b 1.%b * 2 ^ (%0d - 127)",
        A[31], A[22:0], A[30:23], B[31], B[22:0], B[30:23], result[31], result[22:0],
        result[30:23]);

    // dump to vcd file for GTKWave
    $dumpfile("vcd/FloatMultiplicationTB.vcd");
    $dumpvars;

    #15
    value = (2 ** (result[30:23] - 127)) * ($itor(
        {1'b1, result[22:0]}
    ) / 2 ** 23) * ((-1) ** (result[31]));
    $display("Expected Value : %f Result : %f", 3.2 * 4.2, value);
    #20
    value = (2 ** (result[30:23] - 127)) * ($itor(
        {1'b1, result[22:0]}
    ) / 2 ** 23) * ((-1) ** (result[31]));
    $display("Expected Value : %f Result : %f", 0.66 * 0.51, value);
    #20
    value = (2 ** (result[30:23] - 127)) * ($itor(
        {1'b1, result[22:0]}
    ) / 2 ** 23) * ((-1) ** (result[31]));
    $display("Expected Value : %f Result : %f", (-0.5) * (-6.4), value);
    #20
    value = (2 ** (result[30:23] - 127)) * ($itor(
        {1'b1, result[22:0]}
    ) / 2 ** 23) * ((-1) ** (result[31]));
    $display("Expected Value : %f Result : %f", (-0.5) * (6.4), value);
    #20
    value = (2 ** (result[30:23] - 127)) * ($itor(
        {1'b1, result[22:0]}
    ) / 2 ** 23) * ((-1) ** (result[31]));
    $display("Expected Value : %f Result : %f", 0.0 * 0.0, value);
    $finish;
  end

endmodule
