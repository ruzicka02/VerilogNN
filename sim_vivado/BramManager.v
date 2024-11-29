// Instantiates a block memory, writing some minimal data to it as a proof of concept.
// The read ports are passed forward to the Zynq board.
module BramManager (
    // port A... read
    input [12:0] bram_porta_0_addr,
    input clk,
    input [31:0] bram_porta_0_din,
    output [31:0] bram_porta_0_dout,
    input bram_porta_0_en,
    input rst,
    input bram_porta_0_we
);

  // port B... write
  reg [10:0] bram_portb_0_addr = 0;  // address writing to (indexed from 0x0)
  reg [31:0] bram_portb_0_din = 0;  // data to write to (prototype... counter)
  reg        bram_portb_0_we = 1'b0;  // writing in process

  // alternative to a counter -- fixed value to all cells (comment out increments)
  // reg [31:0] bram_portb_0_din = 32'hdead_feed;

  // BRAM memory 2048 x 32-bit (total 8 KiB)
  // => 11-bit addresses, 11'h000 - 11'h7ff
  blk_mem_gen_0 blk_mem_gen_0_inst (
      // Zynq PS access through SW
      .clka (clk),
      .ena  (bram_porta_0_en),
      .wea  (bram_porta_0_we),
      .addra(bram_porta_0_addr[12:2]),  // throw away bottom 2 addr bits for 32-bit addressing
      .dina (bram_porta_0_din),
      .douta(bram_porta_0_dout),
      // PL fabric access
      .clkb (clk),
      .enb  (1'b1),
      .web  (bram_portb_0_we),
      .addrb(bram_portb_0_addr),
      .dinb (bram_portb_0_din),
      .doutb()
  );

  // Write data into BRAM
  always @(posedge clk) begin
    if (rst) begin
      bram_portb_0_addr <= 0;
      bram_portb_0_din  <= 0;
      bram_portb_0_we   <= 1'b0;
    end else begin
      if (bram_portb_0_addr != 11'h7ff) begin
        bram_portb_0_addr <= bram_portb_0_addr + 1;
        bram_portb_0_din  <= bram_portb_0_din + 1;
        bram_portb_0_we   <= 1'b1;
      end else begin
        bram_portb_0_we <= 1'b0;
      end
    end
  end

endmodule
