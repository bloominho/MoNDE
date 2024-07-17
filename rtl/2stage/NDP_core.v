module NDP_core #(
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

	input data_in_flag,				// Valid Data is comming in
	input [31:0] data_in,			// Data fed into NDP core
	output reg data_read_flag,		// Whether data is accepted by NDP core

	output calc_done_flag, 			//When calculation is finished, signals 1
	output [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	out_c 			//Calculation result
);

parameter BUFFER_SIZE = 5;


reg [2:0] step;
reg [31:0] data_received;
reg calculation_in_process;

//---Scratch Pad Control---
reg [2:0] bram_layer;		
reg [5:0] bram_num;			// BRAM Number
reg bram_addr;			// Address

//---NDP Unit Control---
reg NDP_unit_reset;
reg [2:0] data_address_into_ndp_unit;				// Layer Number
reg ndp_unit_in_done_flag;							// All data is fed into NDP unit
reg [BUFFER_SIZE : 0] ndp_unit_in_done_count;		// Number of Data left that needs to be fed into NDP unit
wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] into_ndp_a;
wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] into_ndp_b;

//---Scratch Pad---
scratch_pad #(
	.WIDTH(WIDTH), .BUFFER_SIZE(BUFFER_SIZE),
	.ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT),
	.SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)
	) scratch_pad0 (
		.clk(clk),
		.step(step),
		.bram_num(bram_num),
		.bram_addr(bram_addr),
		.bram_layer(bram_layer),
		.data_received(data_received),
		.data_address_into_ndp_unit(data_address_into_ndp_unit),
		.data_out_a(into_ndp_a),
		.data_out_b(into_ndp_b)
	);

NDP_unit #(
	.WIDTH(WIDTH), 
	.IS_FLOAT(IS_FLOAT), .EXP_BITS(EXP_BITS), .FRAC_BITS(FRAC_BITS),
	.ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT),
	.SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)
) ndp_unit (
	.clk(clk),
	.reset(NDP_unit_reset),
	.in_a(into_ndp_a),
	.in_b(into_ndp_b),
	.in_done_flag(ndp_unit_in_done_flag),
	.SIMD_control(2'b00),
	.calc_done_flag(calc_done_flag),
	.out_c(out_c)
);


always @(posedge clk) begin
	if(reset) begin
		step <= 3'd0;

		//---Action Matrix Scratch Pad Location---
		bram_addr <=1'd0;
		bram_num <= 6'd0;
		bram_layer <= 3'd0;

		//--- NDP unit control---
		data_address_into_ndp_unit <= 3'd0;
		NDP_unit_reset <= 1'd1;
		ndp_unit_in_done_flag <= 1'd0;
		ndp_unit_in_done_count <= 2'b10;

		data_read_flag <= 1'b0;
		calculation_in_process <= 1'b0;
	end else begin
		case (step)
			3'd0: begin		// Wait for data to be fed
				if(data_in_flag) begin		// Data is fed into NDP_core
					step <= 3'd1;
					bram_addr <=1'd0;
					bram_num <= 6'd0;
					bram_layer <= 3'd0;
					data_read_flag <= 1'b1;
				end
			end
			3'd1: begin		// Activation Data
				if((bram_num == SYS_HEIGHT-1) && (bram_addr == 1'd1)) begin
					step <= 3'd2;
					bram_num <= 6'd0;
					bram_addr <= 1'd0;
				end else if(bram_addr == 1'd1) begin
					bram_num <= 6'd1;
					bram_addr <= 1'd0;
				end else begin
					bram_addr <= 1'd1;
				end
			end
			3'd2: begin		// Weight Data
				if(~data_in_flag || 
						((bram_layer == BUFFER_SIZE - 1) && 
							(bram_num == SYS_WIDTH-1) && 
							(bram_addr == 1'd1))) begin  	// Data Transfer Finished of Full Scratch Pad
					step <= 3'd3;
					data_read_flag <= 1'b0;
				end else if((bram_num == SYS_WIDTH-1) && (bram_addr == 1'd1)) begin
					step <= 3'd1;
					bram_layer <= bram_layer + 3'd1;
					ndp_unit_in_done_count <= ndp_unit_in_done_count << 1;
					bram_addr <=1'd0;
					bram_num <= 1'd0;
				end else if(bram_addr == 1'd1) begin
					bram_num <= bram_num + 6'b1;
					bram_addr <= 1'd0;
				end else begin
					bram_addr <= 1'd1;
				end
			end
			3'd3: begin
				if(~calculation_in_process) begin
					NDP_unit_reset <= 1'b0;
					calculation_in_process <= 1'b1;
				end


				if(ndp_unit_in_done_count[0]) begin
					step <= 3'd4;
					ndp_unit_in_done_flag <= 1'b1;
				end else begin
					ndp_unit_in_done_count <= ndp_unit_in_done_count >> 1;
					data_address_into_ndp_unit <= data_address_into_ndp_unit + 1'b1;
				end
			end
		endcase
	end

	data_received <= data_in;
end

endmodule