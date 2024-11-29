`timescale 1ns / 1ps

// Outputs various floating point numbers considered as "edge-cases". Output changes on each
// clock cycle. In order to create multiple modules giving different values, use the
// START parameter from [0, 5].
module TestFloatsEdgecases #(
    parameter START = 0
) (
    input clk,
    output reg [31:0] num
);
  integer idx = START;

  localparam NUM_COUNT = 6;

  always @(posedge clk) begin
    case (idx)
      0: num = 32'b0_11111100_10011001100110011001100;  //  very big number
      1: num = 32'b0_00000011_00001100110011001100110;  //  very small number
      2: num = 32'b1_01111011_10011001100110011001100;  // -0.1
      3: num = 32'b1_01111100_10011001100110011001100;  // -0.2
      4: num = 32'b0_00000000_00000000000000000000000;  //  0.0
      5: num = 32'b0_11111111_00000000000000000000000;  //  inf
      default: num = 32'h0000_0000;  // also 0.0, shouldn't occur as long as START param is valid
    endcase

    idx <= (idx < NUM_COUNT - 1) ? idx + 1 : 0;
  end

endmodule
