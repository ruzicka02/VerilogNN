// https://github.com/akilm/FPU-IEEE-754

`timescale 1ns / 1ps

module FloatingMultiplication (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] result
);

  wire [23:0] A_Mantissa = {1'b1, A[22:0]}, B_Mantissa = {1'b1, B[22:0]};
  wire [7:0] A_Exponent = A[30:23], B_Exponent = B[30:23];
  wire A_sign = A[31], B_sign = B[31];

  reg [47:0] Temp_Mantissa;
  wire [22:0] Mantissa = Temp_Mantissa[45:23];
  reg [8:0] Exponent;
  reg Sign;
  reg [31:0] Result;

  assign result = Result;

  always @(*) begin
    // Handle special cases first
    if ((A_Exponent == 0) || (B_Exponent == 0)) begin
      // Zero case
      Result = {(A_sign ^ B_sign), 31'b0};
    end else if ((A_Exponent == 8'hFF) || (B_Exponent == 8'hFF)) begin
      // Infinity or NaN
      Result = {(A_sign ^ B_sign), 8'hFF, 23'b0};
    end else begin
      Sign = A_sign ^ B_sign;

      // Normal multiplication
      Exponent = A_Exponent + B_Exponent - 'd127;
      Temp_Mantissa = A_Mantissa * B_Mantissa;

      if (Temp_Mantissa[47]) begin
        Temp_Mantissa = Temp_Mantissa >> 1;
        Exponent = Exponent + 1;
      end

      // Handle overflow/underflow
      if (Exponent[8] || Exponent >= 255) Result = {Sign, 8'hFF, 23'b0};  // Infinity
      else if (Exponent <= 0) Result = {Sign, 31'b0};  // Zero
      else Result = {Sign, Exponent[7:0], Mantissa};
    end
  end
endmodule
