module processing_element #(
	parameter WIDTH = 16,

	parameter IS_FLOAT = 1,
	parameter EXP_BITS = 5,
	parameter FRAC_BITS = 10
) (
	input wire reset,
	input wire clk,
	input wire [1:0] SIMD_control,

	//--Input Data--
	input wire [WIDTH-1:0] in_a, 	//West
	input wire [WIDTH-1:0] in_b,	//North

	//--Output Data--
	output reg [WIDTH-1:0] out_a, 	//East
	output reg [WIDTH-1:0] out_b,	//South
	output reg [WIDTH-1:0] out_c	//Accumulated Data
);

wire [WIDTH - 1 : 0] mult_result;
wire [WIDTH - 1 : 0] add_in;
wire [WIDTH - 1 : 0] add_result;

always @(posedge clk) begin
	if(reset) begin
		out_a = 0;
		out_b = 0;
		out_c = 0;		
	end else begin
		out_a = in_a;
		out_b = in_b;

		if(IS_FLOAT == 1) begin
			// --- Handling Floats ---
			out_c = add_result;	
		end else begin
			// --- Handling Integers ---
			out_c = out_c + in_a * in_b;
		end
	end
end

assign add_in = mult_result;

wire [2:0] round_mode = 3'b000;

DW_fp_mult #(FRAC_BITS, EXP_BITS, 1) MULT (
	.a(in_a),
	.b(in_b),
	.rnd(round_mode),
	.z(mult_result),
	.status()
);

DW_fp_add #(FRAC_BITS, EXP_BITS, 1) ADD (
	.a(out_c), 
	.b(add_in),
	.rnd(round_mode),
	.z(add_result),
	.status()
);

endmodule