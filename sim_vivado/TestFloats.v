`timescale 1ns / 1ps

// Outputs various floating point numbers in designated format. Output changes on each
// clock cycle. In order to create multiple modules giving different values, use the
// START parameter from [0, 499].
module TestFloats #(
    parameter START = 0
) (
    input clk,
    output reg [31:0] num
);
  integer idx = START;

  localparam NUM_COUNT = 500;
  reg [31:0] num_arr[0:NUM_COUNT - 1];

  initial begin
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/placeholder500.mem", num_arr, 0,
              NUM_COUNT - 1);
  end

  always @(posedge clk) begin
    num <= num_arr[idx];
    idx <= (idx < NUM_COUNT - 1) ? idx + 1 : 0;
  end

endmodule
