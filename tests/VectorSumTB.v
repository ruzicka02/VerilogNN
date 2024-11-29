`timescale 1ns / 1ns
`include "VectorSum.v"

module VectorSumTB;
  reg  [63:0] Vector;
  wire [31:0] result;

  VectorSum #(
      .VLEN(2)
  ) V1 (
      Vector,
      result
  );

  initial begin
    $dumpfile("vcd/VectorSumTB.vcd");
    $dumpvars(0, VectorSumTB);

    #20;
    Vector = 64'b0_10000000_00000000000000000000000__0_01111111_00000000000000000000000;
    #20;
  end

endmodule
