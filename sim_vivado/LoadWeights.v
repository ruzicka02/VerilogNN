`timescale 1ns / 1ps

// Outputs a vector of floating point numbers in designated format. One element of output changes on each
// clock cycle (takes some time to initialize). In order to create multiple modules giving different values, use the
// START parameter from [0, 498].
module LoadWeights #(
    parameter WEIGHT_COUNT = 1,
    BIAS_COUNT = 1
) (
    output [(32 * WEIGHT_COUNT) - 1:0] weights,
    output [  (32 * BIAS_COUNT) - 1:0] biases
);

  reg [31:0] weight_arr[0:WEIGHT_COUNT - 1];
  reg [31:0] bias_arr  [  0:BIAS_COUNT - 1];

  for (genvar i = 0; i < WEIGHT_COUNT; i = i + 1) begin
    assign weights[32*i+:32] = weight_arr[i][31:0];
  end

  for (genvar j = 0; j < BIAS_COUNT; j = j + 1) begin
    assign biases[32*j+:32] = bias_arr[j][31:0];
  end

  initial begin
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/nn1/weights2.mem", weight_arr, 0,
              WEIGHT_COUNT - 1);
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/nn1/bias2.mem", bias_arr, 0, BIAS_COUNT - 1);
  end

endmodule
