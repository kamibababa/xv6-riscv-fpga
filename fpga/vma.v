/*
VMA - Virtual Memory Access

Implements RISC-V virtual memory mapping Sv32
Test trunvate3 no TLB: 2:29 min
Test truncate3  3 TLB: 1:29 min
*/
`default_nettype none
module vma(
	input			i_clk,
	input			i_rst,
	input	[31:0]	i_v_addr,
	input			i_v_stb,
	input	[3:0]	i_v_we,
	output			o_v_ack,
	output	[31:0]	o_p_addr,
	output			o_p_stb,
	output	[3:0]	o_p_we,
	input			i_p_ack,
	input	[31:0]	i_p_dat_r,
	input	[31:0]	i_satp,
	input			i_smode,
	input			i_sfence_vma,
	output			o_exception
);

//satp supervisor address translation and protection register
wire [21:0] satp_ppn  = i_satp[21:0];
wire satp_mode = i_satp[31] & i_smode;
wire rst = i_rst|i_sfence_vma|exception;
assign o_exception = 0;

//translation process
assign o_p_addr[11:0]  = ~satp_mode? i_v_addr[11:0]: walk1? {i_v_addr[31:22],2'd0} : walk2? {i_v_addr[21:12],2'd0} : i_v_addr[11:0];
assign o_p_addr[31:12] = ~satp_mode? i_v_addr[31:12] : walk1? satp_ppn[19:0] : walk2? pte[29:10]: pte1[29:10];
wire exception = (walk1|walk2) & i_p_ack & ~i_p_dat_r[0];
assign o_p_stb = ~satp_mode? i_v_stb: (walk3_stb|walk1_stb|walk2_stb);
assign o_v_ack = ~satp_mode? i_p_ack: (walk3 & i_p_ack);
assign o_p_we  = (~satp_mode | walk3)? i_v_we: 4'd0;

wire start_walk = satp_mode & i_v_stb & ~hit;

reg walk1;
always @(posedge i_clk)
	if (rst) walk1 <= 0;
	else if (start_walk) walk1 <= 1;
	else if (walk1 & i_p_ack) walk1 <= 0;
reg walk2;
always @(posedge i_clk)
	if (rst) walk2 <= 0;
	else if (walk1 & i_p_ack) walk2 <= 1;
	else if (walk2 & i_p_ack) walk2 <= 0;
reg walk3;
always @(posedge i_clk)
	if (rst) walk3 <= 0;
	else if ((walk2 & i_p_ack)|hit) walk3 <= 1;
	else if (walk3 & i_p_ack) walk3 <= 0;
reg walk1_stb;
always @(posedge i_clk)
	if (rst | walk1_stb) walk1_stb <= 0;
	else if (start_walk) walk1_stb <= 1;
reg walk2_stb;
always @(posedge i_clk)
	if (rst | walk2_stb) walk2_stb <= 0;
	else if (walk1 & i_p_ack) walk2_stb <= 1;
reg walk3_stb;
always @(posedge i_clk)
	if (rst | walk3_stb) walk3_stb <= 0;
	else if ((walk2 & i_p_ack)|hit) walk3_stb <= 1;

reg [31:0] pte;
always @(posedge i_clk)
	if (rst) pte <= 0;
	else if (walk1 & i_p_ack) pte <= i_p_dat_r;

reg [31:0] pte1;
always @(posedge i_clk)
	if (rst) pte1 <= 0;
	else if (walk2 & i_p_ack) pte1 <= i_p_dat_r;
	else if (hit2) pte1 <= pte2;
	else if (hit3) pte1 <= pte3;
	else if (hit4) pte1 <= pte4;

reg [31:0] pte2;
always @(posedge i_clk)
	if (rst) pte2 <= 0;
	else if (walk2 & i_p_ack) pte2 <= pte1;
	else if (hit2|hit3|hit4) pte2 <= pte1;

reg [31:0] pte3;
always @(posedge i_clk)
	if (rst) pte3 <= 0;
	else if (walk2 & i_p_ack) pte3 <= pte2;
	else if (hit3|hit4) pte3 <= pte2;

reg [31:0] pte4;
always @(posedge i_clk)
	if (rst) pte4 <= 0;
	else if (walk2 & i_p_ack) pte4 <= pte3;
	else if (hit4) pte4 <= pte3;

reg [20:0] tlb1;
always @(posedge i_clk)
	if (rst) tlb1 <= 0;
	else if (walk2 & i_p_ack) tlb1 <= {1'b1,i_v_addr[31:12]};
	else if (hit2) tlb1<=tlb2;
	else if (hit3) tlb1<=tlb3;
	else if (hit4) tlb1<=tlb4;
wire hit1;
assign hit1 = satp_mode & (i_v_addr[31:12]==tlb1[19:0]) & i_v_stb & tlb1[20];

reg [20:0] tlb2;
always @(posedge i_clk)
	if (rst) tlb2 <= 0;
	else if ((walk2 & i_p_ack)|hit2|hit3|hit4) tlb2 <= tlb1;

wire hit2;
assign hit2 = satp_mode & (i_v_addr[31:12]==tlb2[19:0]) & i_v_stb & tlb2[20];
reg [20:0] tlb3;
always @(posedge i_clk)
	if (rst) tlb3 <= 0;
	else if ((walk2 & i_p_ack)|hit3|hit4) tlb3 <= tlb2;

wire hit3;
assign hit3 = satp_mode & (i_v_addr[31:12]==tlb3[19:0]) & i_v_stb & tlb3[20];
reg [20:0] tlb4;
always @(posedge i_clk)
	if (rst) tlb4 <= 0;
	else if ((walk2 & i_p_ack)|hit4) tlb4 <= tlb3;

wire hit4;
assign hit4 = satp_mode & (i_v_addr[31:12]==tlb4[19:0]) & i_v_stb & tlb4[20];
wire hit=hit1|hit2|hit3|hit4;
endmodule
