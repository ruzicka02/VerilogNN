`timescale 1ns / 1ns

`include "Sigmoid.v"
`include "Softmax.v"
// `include "HyperbolicTangent.v"
// `include "Softplus.v"
`include "MatrixMultiplicationFlex.v"
`include "VectorAdditionFlex.v"

// https://stackoverflow.com/questions/31010070/verilog-vector-packing-unpacking-macro
`define PACK_ARRAY(PK_WIDTH, PK_LEN, PK_SRC, PK_DEST, PK_IDX) \
for (genvar PK_IDX=0; PK_IDX<(PK_LEN); PK_IDX=PK_IDX+1) begin \
    assign PK_DEST[(PK_WIDTH)*PK_IDX +: PK_WIDTH] = PK_SRC[PK_IDX][((PK_WIDTH)-1):0]; \
end

// Constructs a flexible neural network, that uses the same computation modules for all layers of a network,
// significantly reducing HW usage compared to modules like NeuralLayerSeq.
// The parameters MAX_IN and MAX_OUT indicate the maximum size of a single layer of the NN.
// This is then sufficient to carry out all the necessary calculations.
// NN input and output sizes are determined in compile-time in order to construct the vectors properly,
// sizes of hidden layers can change in run-time as long as they are less than min(MAX_IN, MAX_OUT).
// Structure of the activation functions is fixed for optimization, with sigmoids in all hidden layers
// and softmax on the output layer (modeling probabilities).
module NeuralNetwork #(
    parameter NR_LAYERS = 2,
    IN_SIZE = 4,
    OUT_SIZE = 10,
    MAX_IN = 4,
    MAX_OUT = 10
) (
    input [(32 * IN_SIZE) - 1:0] inputdata,
    input [(32 * NR_LAYERS) - 1: 0]    neuron_count,  // number of neurons located on each level of the NN (32-bit ints)
    input clk,
    output reg [(32 * OUT_SIZE) - 1:0] result
);

  wire [32 * MAX_OUT - 1:0] result_sigmoid;  // current layer after activation
  wire [32 * OUT_SIZE - 1:0] result_softmax;  // only relevant for the final layer
  wire [32 * MAX_OUT - 1:0] mul_store;  // result after the matrix multiplication process
  wire [32 * MAX_OUT - 1:0] add_store;  // result after the addition of the biases
  reg [32 * MAX_OUT - 1:0] data_store;  // data before each layer computation cycle

  // files loading into 2-dimensional arrays, packing needed
  wire [32 * MAX_IN * MAX_OUT - 1:0] weightstorage;
  wire [32 * MAX_OUT - 1:0] biasstorage;
  reg [31:0] weightstorage_2dim[MAX_IN * MAX_OUT - 1:0];
  reg [31:0] biasstorage_2dim[MAX_OUT - 1:0];
  `PACK_ARRAY(32, MAX_IN * MAX_OUT, weightstorage_2dim, weightstorage, PACK1)
  `PACK_ARRAY(32, MAX_OUT, biasstorage_2dim, biasstorage, PACK2)

  integer layerindex = 0;
  reg [31:0] input_cnt;  // number of inputs into current neural layer
  reg [31:0] output_cnt;  // number of outputs from current neural layer
  wire donemul, doneadd;

  // determine input change
  reg [(32 * IN_SIZE) - 1:0] inputdata_copy;

  MatrixMultiplicationFlex #(
      .LBUF(MAX_OUT),
      .MBUF(MAX_IN),
      .NBUF(1),
      .MOD_COUNT(1)
  ) M1 (
      .A(weightstorage),
      .B_T(data_store),
      .clk(clk),
      .l(output_cnt),
      .m(input_cnt),
      .n(1),
      .result(mul_store),
      .done(donemul)
  );

  VectorAdditionFlex #(
      .LBUF(MAX_OUT)
  ) VA1 (
      .A(mul_store),
      .B(biasstorage),
      .clk(clk),
      .l(output_cnt),
      // .prevmuldone(donemul),
      .result(add_store),
      .done(doneadd)
  );

  // applies the activation function to the result of every neuron.
  for (genvar i = 0; i < MAX_OUT; i = i + 1)
  Sigmoid sigmoid (
      .num(add_store[32*i+:32]),
      .result(result_sigmoid[32*i+:32])
  );

  // compute from sigmoids instead of raw values... protects overflow in case the values are too large
  Softmax #(
      .VLEN(OUT_SIZE)
  ) softmax (
      .in(result_sigmoid[0+:OUT_SIZE*32]),
      .result(result_softmax)
  );

  initial begin
    // $readmemb("/home/simon/School/Praktikum/VerilogNN/data/test/weights0.mem", weightstorage_2dim, 0, IN_SIZE * neuron_count[0 +: 32]);
    // $readmemb("/home/simon/School/Praktikum/VerilogNN/data/test/bias0.mem", biasstorage_2dim, 0, neuron_count[0 +: 32]);
    // $readmemb("/home/simon/School/Praktikum/VerilogNN/data/test/weights0.mem", weightstorage_2dim, 0, 12);
    // $readmemb("/home/simon/School/Praktikum/VerilogNN/data/test/bias0.mem", biasstorage_2dim, 0, 3);
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/nn1/weights0.mem", weightstorage_2dim);
    $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/nn1/bias0.mem", biasstorage_2dim);

    inputdata_copy <= inputdata;

    result <= 0;
    data_store <= inputdata;
    input_cnt <= IN_SIZE;
    output_cnt <= neuron_count[0+:32];

    layerindex <= 1;
  end

  // Hopefully the lack of initial block won't cause trouble here, as the data (1st layer weights, input)
  // are loaded after the first doneadd, meaning that we are summing uninitialized values (possibly Hi-Z).
  always @(posedge clk) begin
    if (doneadd) begin
      if (layerindex >= NR_LAYERS) begin  // determines when to stop the computation
        result <= result_softmax;  // final result is then loaded onto the output signal.
      end else begin
        // The process of reading data is always carried out at the beginning on every level of the NN
        // The data needs to be in the correct format in the pre defined location.
        // approach with sformatf is nice, but Vivado does not accept it. Use the fact we only have 2 layers in our net
        // $readmemb("/home/simon/School/Praktikum/VerilogNN/data/test/weights1.mem", weightstorage_2dim);
        // $readmemb("/home/simon/School/Praktikum/VerilogNN/data/test/bias1.mem", biasstorage_2dim);

        // Version for Vivado
        $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/nn1/weights1.mem", weightstorage_2dim);
        $readmemb("/usr/prakt/w0029/NN.FPGA/Codebase/data/nn1/bias1.mem", biasstorage_2dim);


        if (layerindex == 0) begin // based on the layerindex different mechanisms are applied to get the structure of the next layer

        end else begin
          data_store <= result_sigmoid;
          input_cnt  <= output_cnt;
          output_cnt <= neuron_count[layerindex*32+:32];
        end

        layerindex <= layerindex + 1;
      end
    end else if (inputdata !== inputdata_copy) begin  // input change -> reset
      inputdata_copy <= inputdata;

      result <= 0;
      data_store <= inputdata;
      input_cnt <= IN_SIZE;
      output_cnt <= neuron_count[0+:32];

      layerindex <= 1;
    end
  end

endmodule
