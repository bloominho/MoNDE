module processing_element #(
	parameter WIDTH = 16
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

reg [WIDTH-1:0] mult_result; 	// in_a * in_b

always @(posedge clk or posedge reset) begin
	if(reset)begin
		out_a = 0;
		out_b = 0;

		out_c = 0;
		mult_result = 0;
	end else begin
		//---Pass data to next PE---
		out_a = in_a;
		out_b = in_b;

		// TODO : REPLACE WITH f16, bf16 MULTIPLIER
		mult_result = in_a * in_b;
		// TODO : REPLACE WITH f16, bf16 ADDER
		out_c = out_c + mult_result;
	end
end

endmodule