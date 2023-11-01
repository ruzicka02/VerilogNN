`timescale 1ns / 1ps

`ifndef _neural_layer
`define _neural_layer

`include "src/MatrixMultiplication.v"
`include "src/ReLU.v"
`include "src/Sigmoid.v"


module NeuralLayer #(parameter IN_SIZE = 1, OUT_SIZE = 1)
                    (input  [(32 * IN_SIZE) - 1:0]            in,
                     input  [(32 * OUT_SIZE * IN_SIZE) - 1:0] weights,
                     input                                    activation,  // 0 for ReLU, 1 for sigmoid
                     output [(32 * OUT_SIZE) - 1:0]           result);

    output [(32 * OUT_SIZE) - 1:0] res_pretransform, res_relu, res_sigmoid;

    MatrixMultiplication #(.L(OUT_SIZE), .M(IN_SIZE), .N(1)) matmul(.A(weights), .B(in), .result(res_pretransform));

    // create modules for activation functions
    genvar i;
    generate
        for(i = 0; i < OUT_SIZE; i = i + 1) begin
            ReLU relu(.num(res_pretransform[32 * i +: 32]), .result(res_relu[32 * i +: 32]));
            Sigmoid sigmoid(.num(res_pretransform[32 * i +: 32]), .result(res_sigmoid[32 * i +: 32]));
        end
    endgenerate

    // determine output
    assign result = (activation == 1'b0) ? res_relu : res_sigmoid;
endmodule;
`endif // _neural_layer