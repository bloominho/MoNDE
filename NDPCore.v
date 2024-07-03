module NDPCore #(
	parameter WIDTH=16
)(
	input clk,
	input reset
);

wire [4*WIDTH-1:0] Unit_in_a;
wire [4*64*WIDTH-1:0] Unit_in_b;
wire in_done_flag;

wire calc_done_flag;
wire [4*WIDTH-1:0] Unit_out_a;
wire [4*64*WIDTH-1:0] Unit_out_b;
wire [4*4*64*WIDTH-1:0] Unit_out_c;

wire [1:0] SIMD_Control_Signal;



NDPUnit #(.WIDTH(WIDTH)) NDPUnit1(
	.clk(clk), .reset(reset),
	.in_a(Unit_in_a), .in_b(Unit_in_b),
	.in_done_flag(in_done_flag),
	.SIMD_Control(SIMD_Control_Signal),

	.calc_done_flag(calc_done_flag),
	.out_a(Unit_out_a), .out_b(Unit_out_b),
	.out_c(Unit_out_c)
);

endmodule