`timescale 1ns / 1ps

`ifndef _matrix_multiplication_flex
`define _matrix_multiplication_flex

`include "src/VectorMultiplicationFlex.v"

// Multiplies two matrices of dimensions L * M and M * N. As input can be only a vector, it is automatically
// assumed that the matrix is passed in row-major order. Output matrix will have dimensions L * N and will be
// in row-major order as well. Optimized for cases when simulator/FPGA cannot handle the so many modules
// at once and performs some calculations at the clock cycle. For NN usage, M (inputs) > L (outputs) > N = 1 is expected.
// The matrix dimensions can change in the runtime, although they cannot exceed the set buffer parameters. In order to optimize
// your module performance, set the buffer sizes exactly to the maximum admissible input sizes.
//
// Note that matrix B must be transposed on input (can be ignored if it has only 1 row or column).
module MatrixMultiplicationFlex #(parameter LBUF = 128, MBUF = 128, NBUF = 128, MOD_COUNT = 1)
                                (input      [(32 * LBUF * MBUF) - 1:0] A,
                                 input      [(32 * NBUF * MBUF) - 1:0] B_T,  // Transposed !!!
                                 input                           clk,
                                 input [31:0]                    l,
                                 input [31:0]                    m,
                                 input [31:0]                    n,
                                 output reg [(32 * LBUF * NBUF) - 1:0] result,
                                 output reg done);
    reg  [(32 * MBUF) - 1:0] A_vector, B_vector;
    reg  input_changed = 1'b0;  // indicates that the input changed while in a computing cycle
    wire [31:0] res_scalar;
    wire vector_mult_done;

    // matrix B already transposed on input (we want tu multiply rows and columns -> subsequent parts of memory)
    // wire [(32 * NBUF * MBUF) - 1:0] B_T;

    // N * L VectorMultiplication modules from MatMulPar reduced to just 1
    VectorMultiplicationFlex #(.BUFLEN(MBUF), .MOD_COUNT(MOD_COUNT)) vector_mult (
                                .A(A_vector),
                                .B(B_vector),
                                .clk(clk),
                                .vlen(m),
                                .result(res_scalar),
                                .done(vector_mult_done)
                                );

    integer cnt_a = 0, cnt_b = 0;

    // start computing the first output (load m numbers)
    initial begin
        done = 1'b0;

        A_vector <= A[0 +: 32 * MBUF];    // m would be sufficient, but this must be constant expression
        B_vector <= B_T[0 +: 32 * MBUF];  // this might overflow the sensible values in A, B_T (should be zero-padded)
    end

    // flip down switches
    always @ (A, B_T, l, m, n) begin
        done <= 1'b0;
        input_changed <= 1'b1;
    end

    // once output is complete, change the inputs for vector_mult
    always @(posedge vector_mult_done) begin
        // write the result from previous iteration (moved into next clock cycle to allow vector_mult computing time)
        result[(32 * n * cnt_a) + (32 * cnt_b) +: 32] = res_scalar;

        // start computing from the beginning
        if (input_changed) begin
            cnt_a = 0;
            cnt_b = 0;
            input_changed = 1'b0;
        end else begin
            // change counter variables (valid ranges: 0, 1, ..., n/l - 1)
            if (cnt_b >= n - 1) begin  // move to next row
                cnt_b = 0;
                if (cnt_a >= l - 1)
                    done = 1'b1;  // cnt_a == l... calculation is done (we dont have to reset counter, it happens once input changes)
                else
                    cnt_a = cnt_a + 1;
            end else
                cnt_b = cnt_b + 1;
        end

        // change input data for VecMult (and let it compute for 1 clock cycle)
        A_vector = A[(32 * m * cnt_a) +: 32 * MBUF];  // possible overflow of A, B_T (especially if LBUF or NBUF is set low)
        B_vector = B_T[(32 * m * cnt_b) +: 32 * MBUF];
    end

endmodule
`endif // _matrix_multiplication_flex