`timescale 1ns / 1ps

// Writes n-th element of the block memory (length VLEN) to the output vector, starting with the lowest addresses.
// Assumes 32bit memory element size and 32bit addresses.
// Performs VLEN read operations on clock cycles. This process is repeated using a slower clock divider.
// Works only for any VLEN that fits into the memory (VLEN < 11'h7ff for default 8 KiB memory).
module BRAM2Vector #(
    VLEN = 1
) (
    input clk,
    output [(32 * VLEN) - 1:0] vec,

    // port A... write
    input [12:0] bram_porta_0_addr,  // we have this many bytes of memory (last two addr bits ignored)
    input [31:0] bram_porta_0_din,
    output [31:0] bram_porta_0_dout,
    input bram_porta_0_en,
    input rst,
    input bram_porta_0_we
);

  // protect writing over the limit
  reg [(32 * VLEN + 1) - 1:0] vec_wider;
  assign vec = vec_wider[(32*VLEN)-1:0];

  // port B... read
  reg [15:0] bram_portb_0_addr = 0;        // address writing to (indexed from 0x0), plus extra hi bits to delay the overflow
  wire [31:0] bram_portb_0_dout;  // data read from memory
  reg bram_portb_0_en = 1'b1;  // module turned on

  // periodic reset is replaced by cycling through bram_portb_0_addr
  // reg [15:0] periodic_reset = 'b0;         // refresh memory every 2 ** 16 clock cycles (instead of sensitivity list on vec)
  // reg data_changed = 1'b1;

  // BRAM memory 2048 x 32-bit (total 8 KiB == 2 ** 13 B)
  // => 11-bit addresses, 11'h000 - 11'h7ff
  blk_mem_gen_0 blk_mem_gen_0_inst (
      // Zynq PS access through SW
      .clka  (clk),
      .ena   (bram_porta_0_en),  // clock enable
      .wea   (bram_porta_0_we),  // write enable (toggle read/write)
      .addra (bram_porta_0_addr[12:2]),  // throw away bottom 2 addr bits for 32-bit addressing
      .dina  (bram_porta_0_din),
      .douta (bram_porta_0_dout),
      // PL fabric access
      .clkb  (clk),
      .enb   (bram_portb_0_en),
      .web   (1'b0),  // writing disabled
      .addrb (bram_portb_0_addr[10:0]),  // bottom 11 bits used for addressing
      .dinb  (32'b0),  // dummy input (ignored)
      .doutb (bram_portb_0_dout)
  );

  // Read data from BRAM
  always @(posedge clk) begin
    if (rst) begin  // reset address and turn off the memory access (en)
      bram_portb_0_addr <= 0;
      // vec <= 0;
      bram_portb_0_en   <= 1'b0;
    end else if (&bram_portb_0_addr == 1'b1) begin  // unary reduction - all ones in address (periodic reset)
      bram_portb_0_addr <= 0;
      bram_portb_0_en   <= 1'b1;
    end else begin
      if (bram_portb_0_addr < VLEN + 1) begin  // 2 more than Vector2BRAM; vector write is one tick behind instead of forward

        // dout... "one clock cycle behind"
        // however, non-blocking only fixes RHS (out), not the dynamic vector index (addr)
        // this behaves differently than in Vector2BRAM, where the vec (therefore also dynamic index) is on RHS
        // therefore, address increases before the index is evaluated -> subtract 1 from address
        //     lo... addr = 1 (after increment), write to vec[0 +: 32]
        //     hi... addr = VLEN + 1, write to vec[32 * VLEN +: 32]... seems illegal, but the last value is skipped otherwise
        vec_wider[32*(bram_portb_0_addr-1)+:32] <= bram_portb_0_dout;
        bram_portb_0_en <= 1'b1;
      end else begin
        bram_portb_0_en <= 1'b0;
      end
      bram_portb_0_addr <= bram_portb_0_addr + 1;  // also serves as a periodic reset
    end
  end

endmodule
