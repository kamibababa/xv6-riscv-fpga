/*
top - Top level module implements:
- reset
- PLL
- SOC
*/
`default_nettype none
module top(
   input wire clk,
   input wire uart_rx,
   output wire uart_tx,
   output [1:0] led,
   input sd_miso,
   output sd_mosi,
   output sd_sck,
   output sd_ss,
  	output SDRAM_CLK,        // Clock for SDRAM chip
 	output SDRAM_CKE,        // Clock enabled
  	inout [15:0] SDRAM_DQ,          // Bidirectional data lines to/from SDRAM
  	output [12:0] SDRAM_A,       // Address bus, multiplexed, 13 bits
  	output [1:0] SDRAM_BA,         // Bank select wires for 4 banks
  	output [1:0] SDRAM_DQM,        // Byte mask
  	output SDRAM_CSX,         // Chip select
  	output SDRAM_WEX,         // Write enable
  	output SDRAM_RASX,        // Row address select
  	output SDRAM_CASX        // Columns address select
);

//reset
reg [24:0]	rst_cnt = 0;
wire		rst = ! (& rst_cnt);
always @(posedge o_clk) rst_cnt <= rst_cnt + {23'd0,rst};

//PLL   
wire  o_clk;
pll PLL(.clkin(clk),.clkout0(o_clk));
//SOC
soc SOC(
	.i_clk(o_clk),
	.i_rst(rst),
	.o_uart_tx(uart_tx),
	.i_uart_rx(uart_rx),
	.o_led(led),
	.i_spi_miso(sd_miso),
	.o_spi_mosi(sd_mosi),
	.o_spi_sck(sd_sck),
	.o_spi_ss(sd_ss),
  	.SDRAM_CLK(SDRAM_CLK),        // Clock for SDRAM chip
 	.SDRAM_CKE(SDRAM_CKE),        // Clock enabled
  	.SDRAM_D(SDRAM_DQ),          // Bidirectional data lines to/from SDRAM
  	.SDRAM_ADDR(SDRAM_A),       // Address bus, multiplexed, 13 bits
  	.SDRAM_BA(SDRAM_BA),         // Bank select wires for 4 banks
  	.SDRAM_DQM(SDRAM_DQM),        // Byte mask
  	.SDRAM_CS(SDRAM_CSX),         // Chip select
  	.SDRAM_WE(SDRAM_WEX),         // Write enable
  	.SDRAM_RAS(SDRAM_RASX),        // Row address select
  	.SDRAM_CAS(SDRAM_CASX)        // Columns address select
);
   
endmodule
