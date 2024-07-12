module systolic_array_with_buffer #(
	//---DATA WIDTH---
	parameter WIDTH			= 16,

	parameter IS_FLOAT = 1,
	parameter EXP_BITS = 5,
	parameter FRAC_BITS = 10,

	//---ARRAY SIZE---
	parameter ARR_HEIGHT 	= 4,
	parameter ARR_WIDTH 	= 4
) (
	input clk,
	input reset,
	input in_done_flag,

	//---DATA IN---
	input [ARR_HEIGHT * WIDTH-1:0] in_a,	//West
	input [ARR_WIDTH * WIDTH-1:0] in_b,		//North
	input [1:0] SIMD_control,

	//---DATA OUT---
	output calc_done_flag, //When calculation is finished, signals 1
	output [ARR_HEIGHT * ARR_WIDTH * WIDTH-1:0] out_c
);

//---Vectors to be fed to Systoric Array---
wire [ARR_HEIGHT*WIDTH-1 : 0] into_sys_a;
wire [ARR_WIDTH*WIDTH-1 : 0] into_sys_b;


//--- FIFO Buffer ---
//---Buffer for Matrix A---
genvar i;
generate
	for(i=0; i<ARR_HEIGHT; i= i+1) begin : ACT_BUFFER_CHUNK
		fifo_buffer #(.SIZE(i+1), .WIDTH(WIDTH)) ACT_BUFF (
			.clk(clk), .reset(reset),
			.in({WIDTH{{!in_done_flag}}} & in_a[i*WIDTH +: WIDTH]), 
			.out(into_sys_a[i*WIDTH +: WIDTH])
		);
	end
endgenerate

//---Buffer for Matrix B---
genvar j;
generate
	for(j=0; j<ARR_WIDTH; j = j+1) begin : WEIGHT_BUFFER_CHUNK
		fifo_buffer #(.SIZE(j+1), .WIDTH(WIDTH)) WEIGHT_BUFF (
			.clk(clk), .reset(reset),
			.in({WIDTH{{!in_done_flag}}} & in_b[j*WIDTH +: WIDTH]), 
			.out(into_sys_b[j*WIDTH +: WIDTH])
		);
	end
endgenerate

wire into_SYS_done;

//---Done Counter: When matix multiplication is done, prints 1---
fifo_buffer #(.SIZE(ARR_WIDTH + ARR_HEIGHT), .WIDTH(1)) DONE_COUNTER (
	.clk(clk), .reset(reset),
	.in(in_done_flag), .out(into_SYS_done)
);

//---	After all data is fed into systolic array, 
//	 	wait 4 more cycles for final addition (2 sums are added in PEs)
fifo_buffer #(.SIZE(4), .WIDTH(1)) DONE_COUNTER_2 (
	.clk(clk), .reset(reset),
	.in(into_SYS_done), .out(calc_done_flag)
);

//---Systolic Array---
systolic_array #(
		.WIDTH(WIDTH), 
		.IS_FLOAT(IS_FLOAT), .EXP_BITS(EXP_BITS), .FRAC_BITS(FRAC_BITS), 
		.ARR_HEIGHT(ARR_HEIGHT), .ARR_WIDTH(ARR_WIDTH)
	) SYS_ARRAY (
		.clk(clk), .reset(reset), .in_done_flag(into_SYS_done),
		.in_a(into_sys_a),
		.in_b(into_sys_b),
		.SIMD_control(SIMD_control),
		.out_c(out_c)
);

endmodule