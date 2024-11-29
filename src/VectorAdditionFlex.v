`timescale 1ns / 1ps

`ifndef _vector_addition_flex
`define _vector_addition_flex

module VectorAdditionFlex #(
    parameter LBUF = 128
) (
    input      [(32*LBUF)-1:0] A,
    input      [(32*LBUF)-1:0] B,
    input                      clk,
    input      [         31:0] l,
    output reg [(32*LBUF)-1:0] result,
    output reg                 done
);

  // copies to detect change of input
  reg [(32*LBUF)-1:0] A_copy;
  reg [(32*LBUF)-1:0] B_copy;
  reg [31:0] l_copy;

  reg [32 * LBUF - 1:0] A_storage, B_storage;
  reg input_changed = 1'b0;
  wire [32 * LBUF - 1:0] res_sum;

  integer count = 0;

  initial begin
    done = 1'b0;
    A_storage <= A[0+:32];
    B_storage <= B[0+:32];
  end

  FloatingAddition F1 (
      .A(A_storage),
      .B(B_storage),
      .result(res_sum)
  );

  always @(posedge clk) begin
    result[32*count+:32] = res_sum;

    // detect change of input
    if (A_copy !== A || B_copy !== B || l_copy !== l) begin
      A_copy <= A;
      B_copy <= B;
      l_copy <= l;

      count <= 0;
      done <= 1'b0;

      A_storage <= A[0+:32];
      B_storage <= B[0+:32];
    end else if (count >= l - 1) begin
      done <= 1'b1;
    end else begin
      count <= count + 1;

      A_storage <= A[32*(count+1)+:32];
      B_storage <= B[32*(count+1)+:32];
    end
  end

endmodule
`endif  // _vector_addition_flex
