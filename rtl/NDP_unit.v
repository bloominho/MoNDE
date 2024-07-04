module NDP_unit #(
	//---DATA WIDTH---
	parameter WIDTH=8,

	//---Number of PEs in each systolic array---
	parameter ARR_WIDTH = 4,
	parameter ARR_HEIGHT = 4,

	//---Number of Systolic Arrays---
	parameter SYS_WIDTH = 64,
	parameter SYS_HEIGHT = 1
) (
	input clk,
	input reset,

	//---Rows and Columns from matrix A and B (Data Feeding)---
	input [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	in_a,
	input [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] 		in_b,
	
	//---Control Signals---	
	input in_done_flag, 		//When feeding is finished, signals 1
	input [1:0] SIMD_control,	//Signals about SIMD

	//---Outpus---
	output 															calc_done_flag, //When calculation is finished, signals 1
	output [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 						out_a,
	output [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] 							out_b,
	output [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	out_c 			//Calculation result
);

//---Vectors to be fed to Systoric Array---
wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] into_sys_array_a;
wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] into_sys_array_b;


//---Buffers---
//---Buffer for Matrix A---
genvar i;
generate
	for(i=0; i<SYS_HEIGHT*ARR_HEIGHT; i=i+1) begin : act_buff_chunk
		fifo_buffer #(.SIZE(i+1), .WIDTH(WIDTH)) ACT_BUFF (
			.clk(clk), .reset(reset),
			.in({WIDTH{{!in_done_flag}}} & in_a[(i+1)*WIDTH-1:i*WIDTH]), .out(into_sys_array_a[(i+1)*WIDTH-1:i*WIDTH])
		);
	end
endgenerate

//---Buffer for Matrix B---
genvar j;
generate
	for(j=0; j<SYS_WIDTH*ARR_WIDTH; j=j+1) begin : exp_buff_chunk
		fifo_buffer #(.SIZE(j+1), .WIDTH(WIDTH)) EXP_BUFF (
			.clk(clk), .reset(reset),
			.in({WIDTH{{!in_done_flag}}} & in_b[(j+1)*WIDTH-1:j*WIDTH]), 
			.out(into_sys_array_b[(j+1)*WIDTH-1:j*WIDTH])
		);
	end
endgenerate

//---Done Counter: When matix multiplication is done, prints 1---
fifo_buffer #(.SIZE(SYS_WIDTH*ARR_WIDTH + SYS_HEIGHT*ARR_HEIGHT), .WIDTH(1)) DONE_COUNTER (
	.clk(clk), .reset(reset),
	.in(in_done_flag), .out(calc_done_flag)
);

//---Systolic Arrays (Aligned)---
systolic_array_align #(.WIDTH(WIDTH), .ARR_HEIGHT(ARR_HEIGHT), .ARR_WIDTH(ARR_WIDTH), .SYS_HEIGHT(SYS_HEIGHT), .SYS_WIDTH(SYS_WIDTH)) SYS (
	.clk(clk), .reset(reset),
	.in_a(into_sys_array_a), .in_b(into_sys_array_b),
	.SIMD_control(SIMD_control),
	.out_a(out_a), .out_b(out_b), .out_c(out_c)
);

endmodule