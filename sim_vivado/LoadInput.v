`timescale 1ns / 1ps

// Outputs a vector of floating point numbers in designated format.
module LoadInput (
    output [(32 * 784) - 1:0] img
);
  reg [31:0] arr[0:783];

  for (genvar i = 0; i < 784; i = i + 1) begin
    assign img[32*i+:32] = arr[i][31:0];
  end

  initial begin
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/img/input00.mem", arr, 0, 783);
  end

endmodule
