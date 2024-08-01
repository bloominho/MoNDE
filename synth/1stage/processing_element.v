module processing_element #(
	parameter WIDTH = 16,

	parameter EXP_BITS = 5,
	parameter FRAC_BITS = 10,

	parameter PIPE_STAGE = 2
) (
	input wire reset,
	input wire clk,

	//--Input Data--
	input wire [WIDTH-1:0] in_a, 	//West
	input wire [WIDTH-1:0] in_b,	//North

	//--Output Data--
	output reg [WIDTH-1:0] out_a, 	//East
	output reg [WIDTH-1:0] out_b,	//South
	output reg [WIDTH-1:0] out_c	//Accumulated Data
);

wire [WIDTH - 1 : 0]	 mult_result;

reg [WIDTH - 1 : 0] 	add_in;
wire [WIDTH - 1 : 0] 	add_result;

always @(posedge clk) begin
	if(reset) begin
		out_a 	<= 0;
		out_b 	<= 0;
		out_c 	<= 0;
		add_in 	<= 0;
	end else begin
		out_c 	<= add_result;
		add_in 	<= mult_result;

		out_a 	<= in_a;
		out_b 	<= in_b;
	end
end

floating_point_mult multiplier (
	.s_axis_a_tdata(in_a),
	.s_axis_a_tvalid(1'b1),
	.s_axis_b_tdata(in_b),
	.s_axis_b_tvalid(1'b1),
	.m_axis_result_tvalid(),
	.m_axis_result_tdata(mult_result)
);


floating_point_add adder (
	.s_axis_a_tdata(out_c),
	.s_axis_a_tvalid(1'b1),
	.s_axis_b_tdata(add_in),
	.s_axis_b_tvalid(1'b1),
	.m_axis_result_tvalid(),
	.m_axis_result_tdata(add_result)
);

endmodule