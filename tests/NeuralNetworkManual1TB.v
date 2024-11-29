`timescale 1ns / 1ps

`include "NeuralLayerSeq.v"
`include "NeuralLayerPar.v"
`include "DisplayFloat.v"

// https://stackoverflow.com/questions/31010070/verilog-vector-packing-unpacking-macro
`define PACK_ARRAY(PK_WIDTH, PK_LEN, PK_SRC, PK_DEST, PK_IDX) \
for (genvar PK_IDX=0; PK_IDX<(PK_LEN); PK_IDX=PK_IDX+1) begin \
    assign PK_DEST[(PK_WIDTH)*PK_IDX +: PK_WIDTH] = PK_SRC[PK_IDX][((PK_WIDTH)-1):0]; \
end

//                             28 * 28 = 784
module NeuralNetwork1TB #(
    parameter L0 = 100,
    L1 = 15,
    L2 = 10
);  // input size (L0) + numbers of neurons in 2 layers
  reg clk = 0;
  always begin
    clk = ~clk;
    #1;
  end

  wire [(32 * L0) - 1:0] in;
  wire [(32 * L1) - 1:0] potential1, bias1;
  wire [(32 * L2) - 1:0] result, bias2;
  wire [(32 * L0 * L1) - 1:0] weights1;
  wire [(32 * L1 * L2) - 1:0] weights2;
  wire done;

  reg [31:0] in_arr[0:L0 - 1];
  reg [31:0] bias1_arr[0:L1 - 1];
  reg [31:0] bias2_arr[0:L2 - 1];
  reg [31:0] weights1_arr[0:(L0 * L1) - 1];
  reg [31:0] weights2_arr[0:(L1 * L2) - 1];

  // layer 1... 784 -> 15 neurons, sigmoid, sequentially computed
  NeuralLayerSeq #(
      .IN_SIZE(L0),
      .OUT_SIZE(L1),
      .ACTIVATION(1),
      .MOD_COUNT(100)
  ) layer1 (
      .in(in),
      .weights(weights1),
      .bias(bias1),
      .clk(clk),
      .done(done),
      .result(potential1)
  );
  // layer 2 (output)... 15 -> 10 neurons, softmax, computed in parallel
  NeuralLayerPar #(
      .IN_SIZE(L1),
      .OUT_SIZE(L2),
      .ACTIVATION(2)
  ) layer2 (
      .in(potential1),
      .weights(weights2),
      .bias(bias2),
      .result(result)
  );

  // Terminal displaying
  for (genvar i = 0; i < L2; i = i + 1) begin
    wire [3 * 8:1] id_;
    assign id_[8:1]  = (i % 10) + 8'h30;  // 0x30 is "0" in ASCII
    assign id_[16:9] = (i / 10) + 8'h30;
    DisplayFloat display_result (
        .num(result[32*i+:32]),
        .id(id_),
        .format(1'b0)
    );
  end

  // unpack memory arrays to long vectors
  `PACK_ARRAY(32, L0, in_arr, in, pack1);
  `PACK_ARRAY(32, L1, bias1_arr, bias1, pack2);
  `PACK_ARRAY(32, L2, bias2_arr, bias2, pack3);
  `PACK_ARRAY(32, L0 * L1, weights1_arr, weights1, pack5);
  `PACK_ARRAY(32, L1 * L2, weights2_arr, weights2, pack6);

  // load values from memory
  initial begin
    #1
    $readmemb(
        "data/nn1/input01.mem", in_arr
    );  // this will cause a warning since input file has 1 more line (true label)
    $readmemb("data/nn1/bias1.mem", bias1_arr);
    $readmemb("data/nn1/bias2.mem", bias2_arr);
    $readmemb("data/nn1/weights1.mem", weights1_arr);
    $readmemb("data/nn1/weights2.mem", weights2_arr);
  end

  // displaying
  initial begin
    // dump to vcd file for GTKWave
    $dumpfile("vcd/NeuralNetwork1TB.vcd");
    $dumpvars(1, NeuralNetwork1TB);
    $dumpvars(1, layer1);
  end

  always @(posedge done) begin
    #10 $display("Expected Values: TODO");

    $finish;
  end

endmodule
