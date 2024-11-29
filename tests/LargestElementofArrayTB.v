`timescale 1ns / 1ns
`include "LargestElementofArray.v"

module LargestElementofArrayTB #(
    parameter ELEMENT_SIZE = 32
);
  reg [319:0] Vector;
  wire [31:0] result;

  reg clk = 0;
  always begin
    clk = ~clk;
    #1;
  end

  LargestElementofArray #(
      .ELEMENT_SIZE (ELEMENT_SIZE),
      .ELEMENT_COUNT(10)
  ) L1 (
      Vector,
      clk,
      result
  );

  initial begin
    $dumpfile("LargestElementofArrayTB.vcd");
    $dumpvars(0, LargestElementofArrayTB);

    #20;
    Vector = {32'd53, 32'd187, 32'd100, 32'd16, 32'd42, 32'd133, 32'd29, 32'd66, 32'd45, 32'd87};
    $display("Expected Value : %d    real value : %d", 187, result);

    #20;
    Vector = {
      32'd3453,
      32'd13487,
      32'd10340,
      32'd146,
      32'd4222,
      32'd1373,
      32'd2669,
      32'd2663,
      32'd4995,
      32'd897
    };
    $display("Expected Value : %d    real value : %d", 13487, result);

    #20;
    Vector = {
      32'd3453,
      32'd13487,
      32'd10340,
      32'd146,
      32'd4222,
      32'd1373,
      32'd2669,
      32'd2663,
      32'd4995,
      32'd897
    };
    $display("Expected Value : %d    real value : %d", 13487, result);

    $finish;
  end

endmodule
