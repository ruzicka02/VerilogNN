`timescale 1ns / 1ps

`include "NeuralLayerSeq.v"
`include "NeuralLayerPar.v"
`include "DisplayFloat.v"

// https://stackoverflow.com/questions/31010070/verilog-vector-packing-unpacking-macro
`define PACK_ARRAY(PK_WIDTH, PK_LEN, PK_SRC, PK_DEST, PK_IDX) \
for (genvar PK_IDX=0; PK_IDX<(PK_LEN); PK_IDX=PK_IDX+1) begin \
    assign PK_DEST[(PK_WIDTH)*PK_IDX +: PK_WIDTH] = PK_SRC[PK_IDX][((PK_WIDTH)-1):0]; \
end

module NeuralNetworkTestTB #(
    parameter L0 = 25,
    L1 = 20,
    L2 = 15,
    L3 = 15
);  // input size (L0) + numbers of neurons in 3 layers
  reg clk = 0;
  always begin
    clk = ~clk;
    #1;
  end

  wire [(32 * L0) - 1:0] in;
  wire [(32 * L1) - 1:0] potential1, bias1;
  wire [(32 * L2) - 1:0] potential2, bias2;
  wire [(32 * L3) - 1:0] result, bias3;  // result == potential of final output layer after activation
  wire [(32 * L0 * L1) - 1:0] weights1;
  wire [(32 * L1 * L2) - 1:0] weights2;
  wire [(32 * L2 * L3) - 1:0] weights3;
  wire done;

  reg [31:0] in_arr[0:L0 - 1];
  reg [31:0] bias1_arr[0:L1 - 1];
  reg [31:0] bias2_arr[0:L2 - 1];
  reg [31:0] bias3_arr[0:L3 - 1];
  reg [31:0] weights1_arr[0:(L0 * L1) - 1];
  reg [31:0] weights2_arr[0:(L1 * L2) - 1];
  reg [31:0] weights3_arr[0:(L2 * L3) - 1];

  NeuralLayerSeq #(
      .IN_SIZE(L0),
      .OUT_SIZE(L1),
      .ACTIVATION(1),
      .MOD_COUNT(10)
  ) layer1 (
      .in(in),
      .weights(weights1),
      .bias(bias1),
      .clk(clk),
      .result(potential1),
      .done(done)
  );
  NeuralLayerPar #(
      .IN_SIZE(L1),
      .OUT_SIZE(L2),
      .ACTIVATION(1)
  ) layer2 (
      .in(potential1),
      .weights(weights2),
      .bias(bias2),
      .result(potential2)
  );
  NeuralLayerPar #(
      .IN_SIZE(L2),
      .OUT_SIZE(L3),
      .ACTIVATION(1)
  ) layer3 (
      .in(potential2),
      .weights(weights3),
      .bias(bias3),
      .result(result)
  );

  // Terminal displaying
  for (genvar i = 0; i < L3; i = i + 1) begin
    wire [3 * 8:1] id_;
    // $sformat(id_, "%d", i);
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
  `PACK_ARRAY(32, L3, bias3_arr, bias3, pack4);
  `PACK_ARRAY(32, L0 * L1, weights1_arr, weights1, pack5);
  `PACK_ARRAY(32, L1 * L2, weights2_arr, weights2, pack6);
  `PACK_ARRAY(32, L2 * L3, weights3_arr, weights3, pack7);

  // load values from memory
  initial begin
    #1 $readmemb("data/placeholder500.mem", in_arr, 0, L0 - 1);
    $readmemb("data/placeholder500.mem", bias1_arr, 0, L1 - 1);
    $readmemb("data/placeholder500.mem", bias2_arr, 0, L2 - 1);
    $readmemb("data/placeholder500.mem", bias3_arr, 0, L3 - 1);
    $readmemb("data/placeholder500.mem", weights1_arr, 0, (L0 * L1) - 1);
    $readmemb("data/placeholder500.mem", weights2_arr, 0, (L1 * L2) - 1);
    $readmemb("data/placeholder500.mem", weights3_arr, 0, (L2 * L3) - 1);
  end

  // dump to vcd file for GTKWave
  initial begin
    $dumpfile("vcd/NeuralNetworkTestTB.vcd");
    $dumpvars;
  end

  // end of computing
  always @(posedge done) begin
    #10 $display("Computing finished!");

    $finish;
  end

endmodule
