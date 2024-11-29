`timescale 1ns / 1ns

module LargestElementofArray #(
    parameter ELEMENT_SIZE = 32,
    ELEMENT_COUNT = 10
) (
    input  [(ELEMENT_SIZE* ELEMENT_COUNT) -1 : 0] in,
    input                                         clk,
    output [                    ELEMENT_SIZE-1:0] result
);

  reg [ELEMENT_SIZE-1:0] largest_element;
  integer i;

  always @(posedge clk) begin
    largest_element = in[ELEMENT_SIZE-1 : 0];

    for (i = 0; i < ELEMENT_COUNT; i = i + 1) begin
      if (in[i*ELEMENT_SIZE+:ELEMENT_SIZE] > largest_element) begin
        largest_element = in[i*ELEMENT_SIZE+:ELEMENT_SIZE];
      end
    end
  end

  assign result = largest_element;
endmodule
;
