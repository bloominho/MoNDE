`timescale 1ns/10ps

`define N_TESTS 100

module tb_sys_array;
	parameter WIDTH = 16;
	parameter STEP = 5;

	parameter ARR_WIDTH = 2;
	parameter ARR_HEIGHT = 2;
	parameter SYS_WIDTH = 1;
	parameter SYS_HEIGHT = 1;

	reg [1ARR_WIDTH*ARR_HEIGHT*SYS_WIDTH*SYS_HEIGHT*WIDTH-1:0] expected_result;
	reg [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] in_a; // column
	reg [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] in_b; // row

	reg [ARR_WIDTH*ARR_HEIGHT*SYS_WIDTH*SYS_HEIGHT*WIDTH-1:0] real_result;

	reg [95:0] testVector [`N_TESTS-1:0];

	reg test_stop_enable;

	integer mcd;
	integer test_n = 0;
	integer pass   = 0;
	integer error  = 0;






	reg clk, reset;

	reg [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] in_a;
	reg [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] in_b;

	wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] out_a;
	wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] out_b;
	wire [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] out_c;
	wire calc_done_flag;

	reg in_done_flag;

	initial
	begin
		clk = 1'b0;
		forever #(STEP/2) clk = ~clk;
	end

	NDPUnit #(.WIDTH(WIDTH), .ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT), .SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)) NDPUnit (
		.clk(clk), .reset(reset),
		.in_a(in_a), .in_b(in_b),
		.out_a(out_a), .out_b(out_b), .out_c(out_c),
		.in_done_flag(in_done_flag),
		.calc_done_flag(calc_done_flag),
		.SIMD_Control(2'b00)
	);

	initial
	begin
		$readmemh("TestVectorAddition", testVector);
	end 

	initial
		$monitor($time, "done_flaf=%b, out_c = %b", calc_done_flag, out_c);
	
	initial begin 
		reset=0;
		in_done_flag = 0;
		repeat(2)@(negedge clk); reset = 1;
		repeat(1)@(negedge clk); reset = 0;
			in_a = {16'd4, 16'd0, 16'd2, 16'd1};
			in_b = {{64{16'd4, 16'd3, 16'd2, 16'd1}}};
		repeat(1)@(negedge clk);
			in_a = {16'd8, 16'd3, 16'd4, 16'd2};
			in_b = {{64{16'd1, 16'd2, 16'd3, 16'd4}}};
		repeat(1)@(negedge clk);
		in_done_flag = 1;
		in_a = 0;
		in_b = 0;
		
		
		repeat(3000)@(negedge clk);
		$stop;
	end

endmodule
