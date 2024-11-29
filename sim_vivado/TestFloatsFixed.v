`timescale 1ns / 1ps

// Outputs a vector of floating point numbers in designated format. This vector does not change in time,
// therefore no clock is required. Outputs a sequence of floats [1.0, 2.0, ..., VLEN.0]. Computations are
// done using FloatingAddition, could be done in compile time instead as a potential optimization.
module TestFloatsFixed #(
    parameter VLEN = 1
) (
    output [(32 * VLEN) - 1:0] vec
);

  wire [31:0] one = 32'b0_01111111_00000000000000000000000;

  assign vec[31:0] = one;

  for (genvar i = 1; i < VLEN; i = i + 1) begin
    FloatingAddition add (
        .A(vec[32*(i-1)+:32]),
        .B(one),
        .result(vec[32*i+:32])
    );
  end

endmodule
