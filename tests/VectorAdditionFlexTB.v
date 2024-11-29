`timescale 1ns / 1ps
`include "VectorAdditionFlex.v"
`include "FloatingAddition.v"
`include "DisplayFloat.v"





module VectorAdditionFlexTB #(
    parameter LBUF = 6
);
  reg clk = 0;
  always begin
    clk = ~clk;
    #1;
  end

  reg  [(32 * LBUF) - 1:0] A;
  reg  [(32 * LBUF) - 1:0] B;
  wire [(32 * LBUF) - 1:0] result;
  wire                     done;
  reg  [             31:0] length;

  VectorAdditionFlex #(
      .LBUF(LBUF)
  ) VA1 (
      .A(A),
      .B(B),
      .clk(clk),
      .l(length),
      .result(result),
      .done(done)
  );

  DisplayFloat display_result1 (
      .num(result[0+:32]),
      .id("000"),
      .format(1'b1)
  );
  DisplayFloat display_result2 (
      .num(result[32+:32]),
      .id("001"),
      .format(1'b1)
  );
  DisplayFloat display_result3 (
      .num(result[64+:32]),
      .id("002"),
      .format(1'b1)
  );
  DisplayFloat display_result4 (
      .num(result[96+:32]),
      .id("003"),
      .format(1'b1)
  );
  DisplayFloat display_result5 (
      .num(result[128+:32]),
      .id("004"),
      .format(1'b1)
  );
  DisplayFloat display_result6 (
      .num(result[156+:32]),
      .id("005"),
      .format(1'b1)
  );

  initial begin
    length[0+:32] = 32'd3;
    #1 A[0+:32] = 32'b0_10000000_10011001100110011001100;  // 3.2
    B[0+:32]   = 32'b0_10000001_00001100110011001100110;  // 4.2

    A[32+:32]  = 32'b0_01111110_01010001111010111000010;  // 0.66
    B[32+:32]  = 32'b0_01111110_00000101000111101011100;  // 0.51

    A[64+:32]  = 32'b1_01111110_00000000000000000000000;  // -0.5
    B[64+:32]  = 32'b1_10000001_10011001100110011001100;  // -6.4

    A[96+:32]  = 32'b1_01111110_00000000000000000000000;  // -0.5
    B[96+:32]  = 32'b0_10000001_10011001100110011001100;  //  6.4

    A[128+:32] = 32'b1_01111110_00000000000000000000000;  // -0.5
    B[128+:32] = 32'b1_10000001_10011001100110011001100;  // -6.4

    A[160+:32] = 32'b1_01111110_00000000000000000000000;  // -0.5
    B[160+:32] = 32'b0_10000001_10011001100110011001100;  //  6.4 

    #100;
  end



  initial begin

    $dumpfile("VectorAdditionFlexTB.vcd");
    $dumpvars;
    #100 $finish;
  end

endmodule


// iverilog -o VectorAdditionFlexTB.vvp VectorAdditionFlexTB.v
// vvp VectorAdditionFlexTB.vvp 
