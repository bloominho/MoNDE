module systolic_array_align #(
	//---Number of PEs in each systolic array
	parameter ARR_WIDTH = 4,
	parameter ARR_HEIGHT = 4,

	//---Number of systolic arrays
	parameter SYS_WIDTH = 64,
	parameter SYS_HEIGHT = 1,

	//---Data width---
	parameter WIDTH = 16
) (
	input clk,
	input reset,

	//---Data in---
	input [SYS_HEIGHT * ARR_HEIGHT * WIDTH-1:0] 	in_a,
	input [SYS_WIDTH * ARR_WIDTH * WIDTH-1:0] 		in_b,
	input [1:0] SIMD_control,

	//---Data out---
	output [SYS_HEIGHT * ARR_HEIGHT * WIDTH-1:0] 	out_a,
	output [SYS_WIDTH * ARR_WIDTH * WIDTH-1:0] 		out_b,
	output [SYS_WIDTH * ARR_WIDTH * SYS_HEIGHT * ARR_HEIGHT * WIDTH - 1 : 0] out_c
);

//---Connections between systolic arrays
wire [(ARR_HEIGHT * SYS_HEIGHT) * (SYS_WIDTH + 1) * WIDTH - 1 : 0] v_passes;
wire [(ARR_HEIGHT + 1) * (ARR_WIDTH * SYS_WIDTH) * WIDTH - 1 : 0] h_passes;


//---Data fed to module is assigned to first rows/columns
assign v_passes[(SYS_HEIGHT * ARR_HEIGHT) * WIDTH - 1 : 0] = in_a;
assign h_passes[(SYS_WIDTH * ARR_WIDTH) * WIDTH - 1 : 0] = in_b;


//---Generate systolic arrays---
//---Systolic array number---
genvar i;
genvar j;
//---PE number (inside each systolic array)---
genvar k;
genvar l;

generate
	for(i = 0; i < SYS_HEIGHT; i = i+1) begin : SYSROW
		for(j = 0; j < SYS_WIDTH; j = j+1) begin : SYSCOL
			wire [ARR_WIDTH * ARR_HEIGHT * WIDTH - 1 : 0] out_temp;		// Connection wire (array's output -> module output)

			//---Systolic Array---
			systolic_array #(.WIDTH(WIDTH), .ARR_HEIGHT(ARR_HEIGHT), .ARR_WIDTH(ARR_WIDTH)) SYS_ARRAY (
				.clk(clk), .reset(reset), 
				.in_a(v_passes[(j * SYS_HEIGHT + i) * ARR_HEIGHT * WIDTH +: ARR_HEIGHT*WIDTH]),
				.in_b(h_passes[(i * SYS_WIDTH + j) * ARR_WIDTH * WIDTH +: ARR_WIDTH*WIDTH]),
				.SIMD_control(SIMD_control),

				.out_a(v_passes[((j+1)*SYS_HEIGHT + i)*ARR_HEIGHT*WIDTH +: ARR_HEIGHT*WIDTH]),
				.out_b(h_passes[((i+1)*SYS_WIDTH + j)*ARR_WIDTH*WIDTH +: ARR_WIDTH*WIDTH]),
				.out_c(out_temp)
			);

			//---Connection : systolic array's output -> module output---
			for(k=0; k<ARR_HEIGHT; k=k+1) begin: ARRROW
				for(l=0; l<ARR_WIDTH; l=l+1) begin: ARRCOL
					assign out_c[(i*(SYS_WIDTH*ARR_WIDTH*ARR_HEIGHT) + k*(SYS_WIDTH*ARR_WIDTH) + j*ARR_WIDTH + l) * WIDTH +: WIDTH]
									= out_temp[(k*ARR_WIDTH + l) * WIDTH +: WIDTH];
				end
			end

		end
	end
endgenerate

assign out_a = v_passes[(ARR_HEIGHT * SYS_HEIGHT) * (SYS_WIDTH + 1) * WIDTH - 1 : (ARR_HEIGHT * SYS_HEIGHT) * (SYS_WIDTH) * WIDTH];
assign out_b = h_passes[(ARR_HEIGHT + 1) * (ARR_WIDTH * SYS_WIDTH) * WIDTH - 1 :(ARR_HEIGHT) * (ARR_WIDTH * SYS_WIDTH) * WIDTH];

endmodule