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
	input scratch_pad_clk,
	input ndp_unit_clk,

	//--- Control Signals ---
	input reset_in,
	input start_in,
	input finished_in,

	//---Scratch Pad---
	input 			to_scratch_pad_en,
	input 			to_scratch_pad_wen,		// Valid Data is comming in
	input [31:0] 	data_addr,
	input [31:0] 	data,					// Data fed into NDP core

	output reg		HREADY,
	output [31:0] 	HRDATA,

	output reg 		calc_done_flag, 		//When calculation is finished, signals 1
	output [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	out_c 			//Calculation result
);

parameter BUFFER_SIZE = 5;

//--- NDP Core Control ---
reg			calculating;
reg [31:0] 	data_received;
reg 		reset_old;
reg 		start_old;
wire 		reset = ~reset_old & reset_in;
wire 		start = ~start_old & start_in;

//---Scratch Pad Control---
reg [2:0] 	bram_layer;		
reg [5:0] 	bram_num;			// BRAM Number
reg 		bram_addr;			// Address

//---NDP Unit Control---
reg 					NDP_unit_lock;					// Whether if PE should accumulate
reg [2:0] 				data_address_into_ndp_unit;		// Layer Number
reg 					ndp_unit_in_done_flag;			// All data is fed into NDP unit
reg [BUFFER_SIZE : 0] 	ndp_unit_in_done_count;			// Number of Data left that needs to be fed into NDP unit
wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	into_ndp_a;
wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] 	into_ndp_b;
wire 					NDP_calc_done_flag;


//---Scratch Pad---
scratch_pad #(
	.WIDTH(WIDTH), .BUFFER_SIZE(BUFFER_SIZE),
	.ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT),
	.SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)
) scratch_pad0 (
	.write_clk	(scratch_pad_clk)
	.read_clk	(clk),

	.en				(to_scratch_pad_en),
	.wen			(to_scratch_pad_wen),
	.bram_type		(data_addr[10]),
	.bram_layer		(data_addr[9:7]),
	.bram_num		(data_addr[6:1]),
	.bram_addr		(data_addr[0]),
	.data_in		(data_in),
	.HRDATA			(HRDATA),

	.data_address_into_ndp_unit	(data_address_into_ndp_unit),
	.data_out_a		(into_ndp_a),
	.data_out_b		(into_ndp_b)
);

NDP_unit #(
	.WIDTH(WIDTH), 
	.IS_FLOAT(IS_FLOAT), .EXP_BITS(EXP_BITS), .FRAC_BITS(FRAC_BITS),
	.ARR_WIDTH(ARR_WIDTH), .ARR_HEIGHT(ARR_HEIGHT),
	.SYS_WIDTH(SYS_WIDTH), .SYS_HEIGHT(SYS_HEIGHT)
) ndp_unit (
	.clk(clk),
	.reset(reset),
	.in_a(into_ndp_a & {ARR_HEIGHT*SYS_HEIGHT*WIDTH{{~NDP_unit_lock}}}),
	.in_b(into_ndp_b & {ARR_WIDTH*SYS_WIDTH*WIDTH{{~NDP_unit_lock}}}),
	.in_done_flag(ndp_unit_in_done_flag),
	.SIMD_control(2'b00),
	.calc_done_flag(NDP_calc_done_flag),
	.out_c(out_c)
);


//--- Signals Generation ---
always @(posedge scratch_pad_clk) begin
	reset_old <= reset_in;
	start_old <= start_in;
end

always @(posedge scratch_pad_clk) begin
	reset_old <= reset_in;
	start_old <= start_in;


	if(reset) begin
		HREADY <= 1'b1;
		
		//--- NDP Unit Control--
		NDP_unit_lock <= 1'b1;
		ndp_unit_in_done_flag <= 1'd0;
		calculating <= 1'b0;

		calc_done_flag <= 1'b0;
	end else if(start) begin
		calculating <= 1'b1;
		HREADY <= 1'b0;
		data_address_into_ndp_unit <= 3'd0;
	end


	case(data_addr[9:7])
		3'd0:begin
			if(~(&ndp_unit_in_done_count[5:2]))
				ndp_unit_in_done_count <= 2'b10;
		end
		3'd1:begin
			if(~(&ndp_unit_in_done_count[5:3]))
				ndp_unit_in_done_count <= 3'b100;
		end
		3'd2:begin
			if(~(&ndp_unit_in_done_count[5:4]))
				ndp_unit_in_done_count <= 4'b1000;
		end
		3'd3:begin
			if(~(&ndp_unit_in_done_count[5:5]))
				ndp_unit_in_done_count <= 5'b10000;
		end
		3'd4:begin
			ndp_unit_in_done_count <= 6'b100000;
		end
	endcase
end


always @(posedge ndp_unit_clk) begin
	if(calculating) begin
		if(~ndp_unit_in_done_count[0]) begin

			NDP_unit_lock <= 1'b0;
			ndp_unit_in_done_count <= ndp_unit_in_done_count >> 1;
			data_address_into_ndp_unit <= data_address_into_ndp_unit + 1'b1;

		end else begin	// All Data in Scratch Pad is Fed into NDP Unit

			NDP_unit_lock <= 1'b1;
			
			if(to_scratch_pad_wen) begin 		// More data is waiting from memory
				calculating <= 1'b0;
				HREADY <= 1'b1;
			end else if (finished) begin
				ndp_unit_in_done_flag <= 1'b1;
			end

			if(NDP_calc_done_flag) begin
				calc_done_flag <= 1'b1;
			end
		end
	end
end

endmodule