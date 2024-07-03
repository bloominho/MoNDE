`timescale 1ns/10ps

module tb_FIFO;
    parameter WIDTH = 8;
	parameter STEP = 5;

	reg clk;
	reg reset;
	reg [WIDTH-1:0] in;
	wire [WIDTH-1:0] out;

	FIFO_buffer #(.SIZE(4), .WIDTH(WIDTH)) FIFO (
		.clk(clk), .reset(reset),
		.in(in), .out(out)
	);
	
	initial
		$monitor($time, "in=%b, out=%b", in, out);
	
	initial
	begin
		clk = 1'b0;
		forever #(STEP/2) clk = ~clk;
	end
	
	initial begin 
		reset=0;
		in = 0;
		repeat(2)@(negedge clk); reset = 1;
		repeat(2)@(negedge clk); 
		reset = 0;
		in = 1;
		repeat(200)@(negedge clk);
		$stop;
	end

endmodule
