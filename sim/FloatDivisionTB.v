`timescale 1ns / 1ps
`include "src/FloatingDivision.v"
`include "src/DisplayFloat.v"

module FloatDivisionTB;
    reg [31:0] A, B;
    reg clk;
    reg overflow,  underflow,  exception;
    wire [31:0] result;
    real  value;
    FloatingDivision F_Div (.clk(clk), .A(A), .B(B), .result(result));

    DisplayFloat display_result1 (.num(result), .id("Res"), .format(1'b0));

    initial
    begin
    A = 32'b0_10000001_00001100110011001100110;  // 4.2
    B = 32'b0_10000000_10011001100110011001100;  // 3.2
    #20
    A = 32'b0_01111110_01010001111010111000010;  // 0.66
    B = 32'b0_01111110_00000101000111101011100;  // 0.51
    #20
    A = 32'b1_10000001_10011001100110011001100;  // -6.4
    B = 32'b1_01111110_00000000000000000000000;  // -0.5
    #20
    A = 32'b0_10000001_10011001100110011001100;  // 6.4
    B = 32'b1_01111110_00000000000000000000000;  // -0.5
    #20
    A = 32'h3ff0f0f1; // 1.88
    B = 32'h4034b4b5; // 2.82
    end

    initial
    begin
    #15

    $display("Expected Value : %f", 4.2/3.2);
    #20

    $display("Expected Value : %f", 0.66/0.51);
    #20

    $display("Expected Value : %f", (-6.4)/(-0.5));
    #20

    $display("Expected Value : %f", 6.4/(-0.5));
    #20

    $display("Expected Value : %f", 1.88/2.82);
    $finish;
    end
endmodule
