`timescale 1ns / 1ps
`include "VectorMultiplicationSeq.v"
`include "VectorMultiplicationPar.v"
`include "VectorMultiplicationFlex.v"
`include "DisplayFloat.v"

module VectorMultiplicationTB #(
    parameter VLEN = 5
);  // 5-element float vectors
  reg clk = 0;
  always begin
    clk = ~clk;
    #1;
  end

  // this syntax would not pass to the module, easier to do it as one big vector
  // reg [31:0] A, B [0:VLEN-1];

  reg [(32 * VLEN) - 1:0] A, B;
  reg [31:0] vlen;
  wire [31:0] result_par, result_seq, result_flex;
  wire seq_done, flex_done;
  real value;  // real (64bit FP) not synthesizable, only for sim comparison

  // pack the A, B arrays (not necessary in current implementation)
  // genvar i;
  // for(i = 0; i < VLEN; i = i + 1) begin
  //     assign A_packed[32 * i +: 31] = A[i];
  //     assign B_packed[32 * i +: 31] = B[i];
  // end

  VectorMultiplicationPar #(
      .VLEN(VLEN)
  ) mult_par (
      .A(A),
      .B(B),
      .result(result_par)
  );
  VectorMultiplicationSeq #(
      .VLEN(VLEN),
      .MOD_COUNT(2)
  ) mult_seq (
      .A(A),
      .B(B),
      .clk(clk),
      .result(result_seq),
      .done(seq_done)
  );
  VectorMultiplicationFlex #(
      .MOD_COUNT(10)
  ) mult_flex (
      .A(A),
      .B(B),
      .clk(clk),
      .vlen(vlen),
      .result(result_flex),
      .done(flex_done)
  );

  DisplayFloat display_result_par (
      .num(result_par),
      .id("Par"),
      .format(1'b1)
  );
  DisplayFloat display_result_seq (
      .num(result_seq),
      .id("Seq"),
      .format(1'b1)
  );
  DisplayFloat display_result_flex (
      .num(result_flex),
      .id("Flx"),
      .format(1'b1)
  );

  // numbers assignments
  initial begin
    // dump to vcd file for GTKWave
    $dumpfile("vcd/VectorMultiplicationTB.vcd");
    $dumpvars;

    #1 A[0+:32] = 32'b0_10000000_10011001100110011001100;  // 3.2
    B[0+:32]   = 32'b0_10000001_00001100110011001100110;  // 4.2

    A[32+:32]  = 32'b0_01111110_01010001111010111000010;  // 0.66
    B[32+:32]  = 32'b0_01111110_00000101000111101011100;  // 0.51

    A[64+:32]  = 32'b1_01111110_00000000000000000000000;  // -0.5
    B[64+:32]  = 32'b1_10000001_10011001100110011001100;  // -6.4

    A[96+:32]  = 32'b1_01111110_00000000000000000000000;  // -0.5
    B[96+:32]  = 32'b0_10000001_10011001100110011001100;  //  6.4

    A[128+:32] = 32'h4034b4b5;  //  2.82
    B[128+:32] = 32'hbf70f0f1;  // -0.94
  end

  // seq vs. par result comparison
  always @(posedge seq_done) begin
    if (result_par !== result_seq)
      $display(
          "Results of vector multiplications differ! Par vs. Seq:\n%h\n%h", result_par, result_seq
      );
    else $display("Par, Seq vector multiplications are the same");

    $display("Expected Value: %f",
             (3.2 * 4.2) + (0.66 * 0.51) + ((-0.5) * (-6.4)) + ((-0.5) * (6.4)) + (2.82 * (-0.94)));

    #100 $finish;
  end

  // flex (changing vlen and seeing results)
  initial begin
    vlen = 32'd5;
    $display("Flex vlen set to %1d", vlen);

    #20 vlen = 32'd3;
    $display("Flex vlen set to %1d", vlen);

    #20 vlen = 32'd1;
    $display("Flex vlen set to %1d", vlen);
  end

endmodule
