`timescale 1ns / 1ps

// Outputs a vector of floating point numbers in designated format. One element of output changes on each
// clock cycle (takes some time to initialize). In order to create multiple modules giving different values, use the
// START parameter from [0, 498].
module TestVectorFloats #(
    parameter START = 0,
    VLEN = 1
) (
    input clk,
    output reg [(32 * VLEN) - 1:0] vec
);
  integer idx = START, vec_tracker = 0;

  localparam NUM_COUNT = 499;  // even though file has 500 numbers, choosing a prime NUM_COUNT means the vector combinations will not repeat
  reg [31:0] num_arr[0:NUM_COUNT - 1];

  initial begin
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/placeholder500.mem", num_arr, 0,
              NUM_COUNT - 1);
  end

  always @(posedge clk) begin
    vec[32*vec_tracker+:32] = num_arr[idx];

    idx = (idx < NUM_COUNT - 1) ? idx + 1 : 0;
    vec_tracker = (vec_tracker < VLEN - 1) ? vec_tracker + 1 : 0;
  end

endmodule
