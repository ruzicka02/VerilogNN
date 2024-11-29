`timescale 1ns / 1ps
`include "HyperbolicTangent.v"
`include "DisplayFloat.v"


module HyperbolicTangentTB;
  reg  [31:0] Vector;
  wire [31:0] result;

  HyperbolicTangent H1 (
      .num(Vector),
      .result(result)
  );

  DisplayFloat display_in (
      .num(Vector),
      .id("In "),
      .format(1'b1)
  );
  DisplayFloat display_res (
      .num(result),
      .id("Res"),
      .format(1'b1)
  );

  initial begin
    $dumpfile("vcd/HyperbolicTangentTB.vcd");
    $dumpvars(0, HyperbolicTangentTB);

    #20;
    Vector = 32'b11000000000000000000000000000000;  //-2
    #20;
    Vector = 32'b01000000000000000000000000000000;  // 2
    #20;
    Vector = 32'b01000000100000000000000000000000;  // 4
    #20;
    Vector = 32'b0_10000010_10100000000000000000000;  // 13
    #20;
    Vector = 32'b01000001110010000000000000000000;  // 25
    #20;
    $display("%b", result);
  end
endmodule
