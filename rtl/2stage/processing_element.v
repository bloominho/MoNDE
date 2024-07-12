module processing_element #(
	parameter WIDTH = 16,

	parameter IS_FLOAT = 1,
	parameter EXP_BITS = 5,
	parameter FRAC_BITS = 10,

	parameter PIPE_STAGE = 2
) (
	input wire reset,
	input wire clk,
	input wire in_done_flag,
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

reg [WIDTH - 1 : 0] add_in;
wire [WIDTH - 1 : 0] add_result;

reg [2:0] step;


always @(posedge clk) begin
	if(reset) begin
		out_a = 0;
		out_b = 0;

		step = 0;
		
	end else begin
		if(IS_FLOAT == 1) begin
			// --- Handling Floats ---

			case (step)
				3'd0: begin
					//--- Odd set start
					add_in = 0;
					step = 2'd1;
				end
				3'd1: begin
					//--- Even set start
					out_c = 0;
					add_in = mult_result;
					step = 2'd2;
				end
				3'd2: begin
					//--- Start accumulating
					out_c = 0;
					add_in = mult_result;
					step = 2'd3;
				end
				3'd3: begin
					if(in_done_flag)begin
						//--- If all data is fed, add two sums
						add_in = add_result;
						step = 3'd4;
					end else begin
						out_c = add_result;
						add_in = mult_result;
					end
				end
				3'd4: begin
					//---Final Answer
					out_c = add_result;
				end
			endcase

			out_a = in_a;
			out_b = in_b;
		end else begin
			// --- Handling Integers ---
			out_c = out_c + in_a * in_b;
		end
	end
end

wire [2:0] round_mode = 3'b000;

DW_lp_piped_fp_mult #(10, 5, 1, 0, 8, 0, PIPE_STAGE, 0, 1, 0) multiplier (
	.clk(clk),
	.rst_n(!reset),
	.a(in_a),
	.b(in_b),
	.rnd(round_mode),
	.z(mult_result),
	.status(),
	.launch(1'b1),
	.launch_id(),
	.pipe_full(),
	.pipe_ovf(),
	.accept_n(1'b0),
	.arrive(),
	.arrive_id(),
	.push_out_n(),
	.pipe_census()
);


DW_lp_piped_fp_add #(10, 5, 1, 0, 8, 0, PIPE_STAGE, 0, 1, 0) adder (
	.clk(clk),
	.rst_n(!reset),
	.a(out_c),
	.b(add_in),
	.rnd(round_mode),
	.z(add_result),
	.status(),
	.launch(1'b1),
	.launch_id(),
	.pipe_full(),
	.pipe_ovf(),
	.accept_n(1'b0),
	.arrive(),
	.arrive_id(),
	.push_out_n(),
	.pipe_census()
);



endmodule