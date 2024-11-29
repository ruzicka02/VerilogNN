`timescale 1ns / 1ps

`include "NeuralNetwork.v"

module NeuralNetworkTB;
  parameter NR_LAYERS = 2, INPUTSIZE = 4, OUTPUTSIZE = 10, MAX_IN = 4, MAX_OUT = 10;
  reg [INPUTSIZE * 32 - 1:0] imagedata;
  reg [32 * NR_LAYERS - 1:0] neuron_count = {32'd10, 32'd3};
  wire [32 * OUTPUTSIZE - 1:0] result;

  reg clk = 0;
  always begin
    clk = ~clk;
    #1;
  end

  NeuralNetwork #(
      .NR_LAYERS(2),
      .IN_SIZE(4),
      .OUT_SIZE(10),
      .MAX_IN(4),
      .MAX_OUT(10)
  ) NN1 (
      .inputdata(imagedata),
      .neuron_count(neuron_count),
      .clk(clk),
      .result(result)
  );

  initial begin
    $dumpfile("vcd/NeuralNetworkTB.vcd");
    $dumpvars(0, NeuralNetworkTB);

    //          1.25 * 2 ** 3 = 10
    imagedata = {32'h41200000, 32'h41200000, 32'h41200000, 32'h41200000};

    #1000;
    $finish;
  end

endmodule
