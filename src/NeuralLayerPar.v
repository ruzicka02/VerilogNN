`timescale 1ns / 1ps

`ifndef _neural_layer_par
`define _neural_layer_par

`include "MatrixMultiplicationPar.v"
`include "VectorAddition.v"
`include "ReLU.v"
`include "Sigmoid.v"
`include "Softmax.v"
`include "HyperbolicTangent.v"
`include "Softplus.v"

// Neural layer performing all computations in parallel. After matrix multiplication, one of the many activation
// functions is applied - this is determined in compile time.
//
// List of available activation functions (and their respective ACTIVATION values):
//   0 - ReLU
//   1 - sigmoid
//   2 - softmax (per-vector, not per-element)
//   3 - tanh (HyperbolicTangent)
//   4 - softplus
module NeuralLayerPar #(
    parameter IN_SIZE = 1,
    OUT_SIZE = 1,
    ACTIVATION = 0
) (
    input  [           (32 * IN_SIZE) - 1:0] in,
    input  [(32 * OUT_SIZE * IN_SIZE) - 1:0] weights,
    input  [          (32 * OUT_SIZE) - 1:0] bias,
    output [          (32 * OUT_SIZE) - 1:0] result
);

  wire [(32 * OUT_SIZE) - 1:0] res_matmul, res_bias;

  MatrixMultiplicationPar #(
      .L(OUT_SIZE),
      .M(IN_SIZE),
      .N(1)
  ) matmul (
      .A(weights),
      .B(in),
      .result(res_matmul)
  );
  VectorAddition #(
      .VLEN(OUT_SIZE)
  ) add_bias (
      .A(res_matmul),
      .B(bias),
      .result(res_bias)
  );

  // create modules for activation functions
  genvar i;
  generate
    case (ACTIVATION)
      0: begin
        for (i = 0; i < OUT_SIZE; i = i + 1) begin
          ReLU relu (
              .num(res_bias[32*i+:32]),
              .result(result[32*i+:32])
          );
        end
      end
      1: begin
        for (i = 0; i < OUT_SIZE; i = i + 1) begin
          Sigmoid sigmoid (
              .num(res_bias[32*i+:32]),
              .result(result[32*i+:32])
          );
        end
      end
      2: begin
        Softmax #(
            .VLEN(OUT_SIZE)
        ) softmax (
            .in(res_bias),
            .result(result)
        );
      end
      3: begin
        for (i = 0; i < OUT_SIZE; i = i + 1) begin
          HyperbolicTangent htangent (
              .num(res_bias[32*i+:32]),
              .result(result[32*i+:32])
          );
        end
      end
      4: begin
        for (i = 0; i < OUT_SIZE; i = i + 1) begin
          Softplus softplus (
              .x_value(res_bias[32*i+:32]),
              .result (result[32*i+:32])
          );
        end
      end
      default:
      begin
        assign result = res_bias;  // no activation
      end
    endcase
  endgenerate

endmodule
`endif  // _neural_layer_par
