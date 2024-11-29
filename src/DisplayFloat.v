`timescale 1ns / 1ps

`ifndef _display_float
`define _display_float

// not synthesizable, only for testbench purposes
// converts custom float into `real` type and displays it whenever the number changes
module DisplayFloat (
    input [31:0] num,
    input [3*8:1] id,
    input format
);

  real value;

  always @(num, format) begin
    // bitwise XOR of all values in num... result will be x if num contains any x
    if (^num !== 1'bx) begin
      //      mantissa converted to real (and shifted)        number sign   2 ^ exponent (convert to real for bigger number range)
      value = ($itor({1'b1, num[22:0]}) / 2 ** 23) * ((-1) ** (num[31])) *
          ($itor(2) ** $itor(num[30:23] - 127));

      if (format)  // == 1'b1
        $display("[DisplayFloat] %s: %f", id, value);
      else
        $display(
            "[DisplayFloat] %s: %b 1.%b * 2 ^ (%3d - 127) = %f",
            id,
            num[31],
            num[22:0],
            num[30:23],
            value
        );
    end
  end
endmodule
`endif
