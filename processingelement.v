// ** Processing Element ** //

module processingelement #(
	parameter WIDTH = 16
) (
	input wire reset,
	input wire clk,
	input wire [1:0] SIMD_Control,
	input wire [WIDTH-1:0] in_a,
	input wire [WIDTH-1:0] in_b,
	output reg [WIDTH-1:0] out_a,
	output reg [WIDTH-1:0] out_b,
	output reg [WIDTH-1:0] out_c
);

reg [WIDTH-1:0] mult_result;

always @(posedge clk or posedge reset) begin
	if(reset)begin
		out_a = 0;
		out_b = 0;

		out_c = 0;
		mult_result = 0;
	end else begin
		out_a = in_a;
		out_b = in_b;

		// TODO : REPLACE WITH f16, bf16 MULTIPLIER
		mult_result = in_a * in_b;
		// TODO : REPLACE WITH f16, bf16 ADDER
		out_c = out_c + mult_result;

	end
end

endmodule