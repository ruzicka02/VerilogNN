`timescale 1ns / 1ns
`include "Softplus.v"
`include "DisplayFloat.v"


module SoftplusTB;
  reg  [31:0] Vector;
  wire [31:0] result;

  Softplus S1 (
      Vector,
      result
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
    $dumpfile("vcd/SoftplusTB.vcd");
    $dumpvars(0, SoftplusTB);

    #20;
    Vector = 32'b11000000000000000000000000000000;  //-2
    #20;
    Vector = 32'b10111111100000000000000000000000;  //-1
    #20;
    Vector = 32'b00000000000000000000000000000000;  // 0
    #20;
    Vector = 32'b00111111100000000000000000000000;  // 1
    #20;
    Vector = 32'b01000000000000000000000000000000;  // 2
    #20;
    Vector = 32'b01000000100000000000000000000000;  // 4
    #20;
    Vector = 32'b01000001010100000000000000000000;  // 13
    #20;
    Vector = 32'b01000001110010000000000000000000;  // 25
    #20;

    $display("%b", result);
  end
endmodule
