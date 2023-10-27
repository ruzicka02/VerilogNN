`timescale 1ns / 1ps
`include "src/FloatingMultiplication.v"
`include "src/FloatingAddition.v"

module VectorMultiplication #(parameter VLEN = 1)
                             (input [(32 * VLEN) - 1:0] A,
                              input [(32 * VLEN) - 1:0] B,
                              input clk,
                              output [31:0] result);
    wire [31:0] partial_sums [0:VLEN-1];

    genvar i;
    generate
        for(i = 0; i < VLEN; i = i + 1) begin
            wire [31:0] A_item = A[32 * i +: 31];
            wire [31:0] B_item = B[32 * i +: 31];
            wire [31:0] temp;
            FloatingMultiplication mult1(.A(A_item), .B(B_item), .clk(clk), .result(temp));  // element-wise multiplication

            if (i == 0)
                assign partial_sums[i] = temp;
            else
                FloatingAddition add1(.A(temp), .B(partial_sums[i-1]), .clk(clk), .result(partial_sums[i]));
        end
    endgenerate

    assign result = partial_sums[VLEN-1];
endmodule;