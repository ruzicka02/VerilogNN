`timescale 1ns / 1ns
`include "E_Function.v"
`include "DisplayFloat.v"

module E_FunctionTB;

  reg  [31:0] X_val;
  wire [31:0] result;


  e_function E1 (
      .x_value(X_val),
      .result (result)
  );

  DisplayFloat display_in (
      .num(X_val),
      .id("In "),
      .format(1'b1)
  );
  DisplayFloat display_res (
      .num(result),
      .id("Res"),
      .format(1'b1)
  );

  initial begin

    $dumpfile("vcd/E_FunctionTB.vcd");
    $dumpvars(0, E_FunctionTB);

    #20;
    X_val = 32'b0_00000000_00000000000000000000000;  //0
    #20;
    X_val = 32'b0_01111111_00000000000000000000000;  //1
    #20;
    X_val = 32'b0_10000000_00000000000000000000000;  //2
    #20;
    X_val = 32'b11000000000000000000000000000000;  // -2
    #20;
    X_val = 32'b01000000100000000000000000000000;  // 4
    #20;
    X_val = 32'b11000000100000000000000000000000;  // -4
    #20;
    X_val = 32'b0_10000010_10100000000000000000000;  // 13
    #20;
    X_val = 32'b1_10000010_10100000000000000000000;  // -13
    #20;
    X_val = 32'b01000001110010000000000000000000;  // 25
    #20;
    X_val = 32'b11000001110010000000000000000000;  // -25
    #20;
  end

endmodule
