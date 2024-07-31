module NDP_unit #(
	//---DATA WIDTH---
	parameter WIDTH=16,

	parameter IS_FLOAT = 1,
	parameter EXP_BITS = 5,
	parameter FRAC_BITS = 10,

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
	input 		in_done_flag, 		//When feeding is finished, signals 1

	//---Outputs---
	output calc_done_flag, //When calculation is finished, signals 1
	output [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	out_c, 			//Calculation result

	//--- DEBUG ---
	output [SYS_HEIGHT * ARR_HEIGHT * WIDTH - 1 : 0] 	into_sys_a_debug, 	// Buffer -> Systolic Array
	output [SYS_WIDTH * ARR_WIDTH * WIDTH - 1 : 0] 		into_sys_b_debug,	// Buffer -> Systolic Array
	output [WIDTH - 1 : 0] add_in_debug
);


//---Generate systolic arrays and Buffers---
//---Systolic array number---
genvar i;
genvar j;
//---PE number (inside each systolic array)---
genvar k;
genvar l;

wire [SYS_HEIGHT * ARR_HEIGHT * WIDTH - 1 : 0] 	into_sys_a; 	// Buffer -> Systolic Array
wire [SYS_WIDTH * ARR_WIDTH * WIDTH - 1 : 0] 	into_sys_b;	// Buffer -> Systolic Array

wire [SYS_HEIGHT - 1 :0] calc_done_flags_col;
assign calc_done_flag = &calc_done_flags_col;

//---Buffers---
generate
	//---ACTION MATRIX (Saves a row)---
	for(i=0; i<SYS_HEIGHT; i=i+1) begin
		for(k=0; k<ARR_HEIGHT; k=k+1) begin
			fifo_buffer #(
				.SIZE(k+1), 
				.WIDTH(WIDTH)
			) ACT_BUFF (
				.clk	(clk), 
				.reset	(reset),
				.in		({WIDTH{{!in_done_flag}}} & in_a[i*ARR_HEIGHT*WIDTH + k*WIDTH + WIDTH - 1 : i*ARR_HEIGHT*WIDTH + k*WIDTH]),
				.out	(into_sys_a[i*ARR_HEIGHT*WIDTH + k*WIDTH + WIDTH - 1 : i*ARR_HEIGHT*WIDTH + k*WIDTH])
			);
		end
	end
	//---WEIGHT MATRIX (Saves a row)---
	for(j=0; j<SYS_WIDTH; j=j+1) begin
		for(l=0; l<ARR_WIDTH; l=l+1) begin
			fifo_buffer #(
				.SIZE(l+1), 
				.WIDTH(WIDTH)
			) ACT_BUFF (
				.clk	(clk), 
				.reset	(reset),
				.in		({WIDTH{{!in_done_flag}}} & in_b[j*ARR_WIDTH*WIDTH + l*WIDTH + WIDTH - 1 : j*ARR_WIDTH*WIDTH + l*WIDTH]),
				.out	(into_sys_b[j*ARR_WIDTH*WIDTH + l*WIDTH + WIDTH - 1 : j*ARR_WIDTH*WIDTH + l*WIDTH])
			);
		end
	end

	wire [WIDTH*SYS_WIDTH - 1 : 0] add_in_debug_all;

	//---SYSTOLIC ARRAY---
	for(i=0; i<SYS_HEIGHT; i=i+1) begin
		wire [SYS_WIDTH - 1 : 0] calc_done_flags_row;
		assign calc_done_flags_col[i] = &calc_done_flags_row;

		for(j=0; j<SYS_WIDTH; j=j+1) begin
			wire [ARR_WIDTH * ARR_HEIGHT * WIDTH - 1 : 0] out_temp;		// Connection wire (array's output -> module output)

			//---Systolic Array---
			systolic_array_with_buffer #(
					.WIDTH			(WIDTH),
					.IS_FLOAT		(IS_FLOAT), 
					.EXP_BITS		(EXP_BITS), 
					.FRAC_BITS		(FRAC_BITS),
					.ARR_HEIGHT		(ARR_HEIGHT), 
					.ARR_WIDTH		(ARR_WIDTH)
				) SYS_ARRAY (
					.clk			(clk), 
					.reset			(reset), 
					.in_done_flag	(in_done_flag),
					.in_a			(into_sys_a[ARR_HEIGHT*WIDTH*i + ARR_HEIGHT*WIDTH - 1: ARR_HEIGHT*WIDTH*i]),
					.in_b			(into_sys_b[ARR_WIDTH*WIDTH*j + ARR_WIDTH*WIDTH - 1 : ARR_WIDTH*WIDTH*j]),
					.calc_done_flag	(calc_done_flags_row[j]),
					.out_c			(out_temp),
					.add_in_debug	(add_in_debug_all[WIDTH*j + WIDTH - 1 : WIDTH*j])
			);

			//---Connection : systolic array's output -> module output---
			for(k=0; k<ARR_HEIGHT; k=k+1) begin: ARRROW
				for(l=0; l<ARR_WIDTH; l=l+1) begin: ARRCOL
					assign out_c[(i*(SYS_WIDTH*ARR_WIDTH*ARR_HEIGHT) + k*(SYS_WIDTH*ARR_WIDTH) + j*ARR_WIDTH + l) * WIDTH + WIDTH - 1 : (i*(SYS_WIDTH*ARR_WIDTH*ARR_HEIGHT) + k*(SYS_WIDTH*ARR_WIDTH) + j*ARR_WIDTH + l) * WIDTH]
									= out_temp[(k*ARR_WIDTH + l) * WIDTH + WIDTH - 1 : (k*ARR_WIDTH + l) * WIDTH];
				end
			end

		end
	end
endgenerate


// --- DEBUG ---

	assign into_sys_a_debug = into_sys_a; 	// Buffer -> Systolic Array
	assign into_sys_b_debug = into_sys_b;	// Buffer -> Systolic Array
	assign add_in_debug = add_in_debug_all[255:240];

endmodule