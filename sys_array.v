// Systolic Array //

module sys_array #(
	parameter WIDTH=16,
	parameter ARR_HEIGHT = 4,
	parameter ARR_WIDTH = 4
) (
	input clk,
	input reset,
	input [ARR_HEIGHT * WIDTH-1:0] in_a,
	input [ARR_WIDTH * WIDTH-1:0] in_b,
	input [1:0] SIMD_Control,

	output [ARR_HEIGHT * WIDTH-1:0] out_a,
	output [ARR_WIDTH * WIDTH-1:0] out_b,
	output [ARR_HEIGHT * ARR_WIDTH * WIDTH-1:0] out_c
);

// Connections between PEs
wire [(ARR_HEIGHT) * (ARR_WIDTH+1) * WIDTH-1:0] v_passes; // Horizontal Direction (Aligned Vertical Order)
wire [(ARR_HEIGHT+1) * (ARR_WIDTH) * WIDTH-1:0] h_passes; // Vertical Direction (Alligned Horizontal Order)

// Inputs are Assigned to first rows/columns
assign v_passes[ARR_HEIGHT * WIDTH - 1: 0] = in_a;
assign h_passes[ARR_WIDTH * WIDTH - 1: 0] = in_b;

// Generate PEs (in horizontal first order)
genvar i;
genvar j;
generate
	for(i = 0; i < ARR_HEIGHT; i=i+1) begin : PEROW
		// Make a ROW of Processing Elements
		for(j = 0; j < ARR_WIDTH; j=j+1) begin : PECOL
			// Fill in the Row with Processing Elements
			processingelement #(.WIDTH(WIDTH)) PE (
				.reset(reset), .clk(clk), .SIMD_Control(SIMD_Control),
				.in_a(v_passes[(j*ARR_HEIGHT+i+1)*WIDTH-1:(j*ARR_HEIGHT+i)*WIDTH]),
				.in_b(h_passes[(i*ARR_WIDTH+j+1)*WIDTH-1:(i*ARR_WIDTH+j)*WIDTH]),
				.out_a(v_passes[((j+1)*ARR_HEIGHT+i+1)*WIDTH-1:((j+1)*ARR_HEIGHT+i)*WIDTH]),
				.out_b(h_passes[((i+1)*ARR_WIDTH+j+1)*WIDTH-1:((i+1)*ARR_WIDTH+j)*WIDTH]),
				.out_c(out_c[(i*ARR_WIDTH + j + 1)*WIDTH-1: (i*ARR_WIDTH + j)*WIDTH])
			);
		end
	end
endgenerate

// Assign outputs from last PEs to out_a and out_b
assign out_a = v_passes[(ARR_HEIGHT) * (ARR_WIDTH+1) * WIDTH-1 : (ARR_HEIGHT) * (ARR_WIDTH) * WIDTH];
assign out_b = h_passes[(ARR_HEIGHT+1) * (ARR_WIDTH) * WIDTH-1 : (ARR_HEIGHT) * (ARR_WIDTH) * WIDTH];
endmodule