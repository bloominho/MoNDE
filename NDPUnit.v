// ** NDP UNIT ** //
// VECTOR A (Activation Vector, SIZE 4)
// VECTOR B (Expert Vector, SIZE 256)

// Execution Orcer : Reset -> FEED DATA -> in_done_flag

// DATA PATH : VECTOR A & B -> FIFO BUFFER -> SYS ARRAY -> out_c

module NDPUnit #(
	parameter WIDTH=8,
	// Number of PEs in each systolic Array
	parameter ARR_WIDTH = 4,
	parameter ARR_HEIGHT = 4,
	// Number of Systolic Arrays
	parameter SYS_WIDTH = 64,
	parameter SYS_HEIGHT = 1
) (
	input clk,
	input reset,
	// Pass vectors
	input [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] in_a,
	input [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] in_b,
	// When All vectors are given, set in_done_flag to 1 
	input in_done_flag,
	input [1:0] SIMD_Control,

	output calc_done_flag, // Calculation Done
	output [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] out_a,
	output [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] out_b,
	output [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] out_c // Result
);

wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] into_sys_array_a;
wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] into_sys_array_b;

// ** Buffers ** //
// To calculate Matrix Multiplication,
// data should be fed to Systolic Arrays in different timings
// by using Buffers

// Activation Buffer
genvar i;
generate
	for(i=0; i<SYS_HEIGHT*ARR_HEIGHT; i=i+1) begin : act_buff_chunk
		FIFO_buffer #(.SIZE(i+1), .WIDTH(WIDTH)) ACT_BUFF (
			.clk(clk), .reset(reset),
			.in({WIDTH{{!in_done_flag}}} & in_a[(i+1)*WIDTH-1:i*WIDTH]), .out(into_sys_array_a[(i+1)*WIDTH-1:i*WIDTH])
		);
	end
endgenerate

// Expert Buffer
genvar j;
generate
	for(j=0; j<SYS_WIDTH*ARR_WIDTH; j=j+1) begin : exp_buff_chunk
		FIFO_buffer #(.SIZE(j+1), .WIDTH(WIDTH)) EXP_BUFF (
			.clk(clk), .reset(reset),
			.in({WIDTH{{!in_done_flag}}} & in_b[(j+1)*WIDTH-1:j*WIDTH]), 
			.out(into_sys_array_b[(j+1)*WIDTH-1:j*WIDTH])
		);
	end
endgenerate

// Done Counter
FIFO_buffer #(.SIZE(SYS_WIDTH*ARR_WIDTH + SYS_HEIGHT*ARR_HEIGHT), .WIDTH(1)) DONE_COUNTER (
	.clk(clk), .reset(reset),
	.in(in_done_flag), .out(calc_done_flag)
);

// Systolic Array
sys_array_align #(.WIDTH(WIDTH), .ARR_HEIGHT(ARR_HEIGHT), .ARR_WIDTH(ARR_WIDTH), .SYS_HEIGHT(SYS_HEIGHT), .SYS_WIDTH(SYS_WIDTH)) SYS (
	.clk(clk), .reset(reset),
	.in_a(into_sys_array_a), .in_b(into_sys_array_b),
	.SIMD_Control(SIMD_Control),
	.out_a(out_a), .out_b(out_b), .out_c(out_c)
);


endmodule