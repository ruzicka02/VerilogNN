`timescale 1ns / 1ps

// Writes n-th element of a vector (length VLEN) to a block memory, starting with the lowest addresses.
// Assumes 32bit memory element size and 32bit addresses.
// Performs VLEN write operations on clock cycles. This process is repeated using a slower clock divider.
// Works only for any VLEN that fits into the memory (VLEN < 11'h7ff for default 8 KiB memory).
module Vector2BRAM #(
    VLEN = 1
) (
    input clk,
    input [(32 * VLEN) - 1:0] vec,

    // port A... read
    input [12:0] bram_porta_0_addr,  // we have this many bytes of memory (last two addr bits ignored)
    input [31:0] bram_porta_0_din,
    output [31:0] bram_porta_0_dout,
    input bram_porta_0_en,
    input rst,
    input bram_porta_0_we
);

  // port B... write
  reg [10:0] bram_portb_0_addr = 0;  // address writing to (indexed from 0x0)
  reg [31:0] bram_portb_0_din = 0;  // data to write to
  reg bram_portb_0_we = 1'b0;  // writing in process

  reg [15:0] periodic_reset = 'b0;         // refresh memory every 2 ** 16 clock cycles (instead of sensitivity list on vec)
  // reg data_changed = 1'b1;

  // BRAM memory 2048 x 32-bit (total 8 KiB == 2 ** 13 B)
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
    end else if (&periodic_reset == 1'b1) begin  // unary reduction - all ones in periodic_reset
      bram_portb_0_addr <= 0;
      bram_portb_0_din  <= vec[31:0];
      bram_portb_0_we   <= 1'b1;
      // data_changed <= 1'b0;
    end else begin
      if (bram_portb_0_addr < 11'h7ff) begin
        bram_portb_0_addr <= bram_portb_0_addr + 1;
        // address change is one clock cycle behind (therefore, add 1)                   vvv
        bram_portb_0_din <= (bram_portb_0_addr < VLEN - 1) ? vec[32 * (bram_portb_0_addr + 1) +: 32] : 32'hdead_feed;
        bram_portb_0_we <= 1'b1;
      end else begin
        bram_portb_0_we <= 1'b0;
      end
    end

    periodic_reset <= periodic_reset + 1;
  end

  // reset when input data changes
  // always @ (vec) begin
  //     data_changed <= 1'b1;
  // end

endmodule
