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

	input data_in_flag,
	input [31:0] data_in,

	output calc_done_flag, //When calculation is finished, signals 1
	output [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	out_c 			//Calculation result
);

parameter BUFFER_SIZE = 5;

wire [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] into_ndp_a;
wire [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] into_ndp_b;

reg ndp_unit_in_done_flag;

reg [2:0] step;
reg [31:0] data_received;

reg act_bram_num;
reg act_bram_addr;
reg [2:0] act_bram_layer;

reg [5:0] weight_bram_num;
reg weight_bram_addr;
reg [2:0] weight_bram_layer;

reg [2:0] data_address_into_ndp_unit;

reg NDP_unit_reset;
//---Scratch Pad---
//---Activation Matrix---

// initial
// 	$monitor("%h %h", weight_bram_layer, weight_bram_num);

genvar i;
generate
	for(i=0; i<SYS_HEIGHT; i=i+1) begin
		bram_dual  #(.COUNT(BUFFER_SIZE*2)) bram_activation_X (
			.clka(clk),
			.ena(1'b1),
			.wea((step == 3'd1) && (act_bram_num == i)),
			.addra(act_bram_addr + 4'd2*act_bram_layer),
			.dina(data_received),
			.douta(),

			.clkb(clk),
			.enb(1'b1),
			.web(),
			.addrb(data_address_into_ndp_unit),
			.dinb(),
			.doutb(into_ndp_a[64*i +: 64])
		);
	end
endgenerate

//---Weight Matrix---
genvar j;
generate
	for(j=0; j<SYS_WIDTH; j=j+1) begin
		bram_dual #(.COUNT(BUFFER_SIZE*2)) bram_weight_X (
			.clka(clk),
			.ena(1'b1),
			.wea((step == 3'd2) && (weight_bram_num == j)),
			.addra(weight_bram_addr + 4'd2*weight_bram_layer),
			.dina(data_received),
			.douta(),

			.clkb(clk),
			.enb(1'b1),
			.web(),
			.addrb(data_address_into_ndp_unit),
			.dinb(),
			.doutb(into_ndp_b[64*j +: 64])
		);
	end
endgenerate

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

		act_bram_addr <=1'd0;
		act_bram_num <= 1'd0;
		act_bram_layer <= 3'd0;

		weight_bram_addr <=1'd0;
		weight_bram_num <= 6'd0;
		weight_bram_layer <= 3'd0;

		data_address_into_ndp_unit <= 3'd0;

		NDP_unit_reset <= 1'd1;

		ndp_unit_in_done_flag <= 1'd0;
	end else begin
		case (step)
			3'd0: begin
				if(data_in_flag) begin
					step <= 3'd1;
					act_bram_addr <=1'd0;
					act_bram_num <= 1'd0;
					act_bram_layer <= 3'd0;
				end
			end
			3'd1: begin
				if((act_bram_layer == 3'd4) && (act_bram_num == SYS_HEIGHT-1) && (act_bram_addr == 1'd1)) begin
					step <= 3'd2;
					weight_bram_addr <=1'd0;
					weight_bram_num <= 6'd0;
					weight_bram_layer <= 3'd0;
				end else if((act_bram_num == SYS_HEIGHT-1) && (act_bram_addr == 1'd1)) begin
					act_bram_layer <= act_bram_layer + 1'd1;
					act_bram_num <= 1'd0;
					act_bram_addr <= 1'd0;
				end else if(act_bram_addr == 1'd1) begin
					act_bram_num <= 1'd1;
					act_bram_addr <= 1'd0;
				end else begin
					act_bram_addr <= 1'd1;
				end
			end
			3'd2: begin
				if((weight_bram_layer == 3'd4) && (weight_bram_num == SYS_WIDTH-1) && (weight_bram_addr == 1'd1)) begin
					step <= 3'd3;
				end else if((weight_bram_num == SYS_WIDTH-1) && (weight_bram_addr == 1'd1)) begin
					weight_bram_layer <= weight_bram_layer + 3'd1;
					weight_bram_num <= 6'd0;
					weight_bram_addr <= 1'd0;
				end else if(weight_bram_addr == 1'd1) begin
					weight_bram_num <= weight_bram_num + 1'b1;
					weight_bram_addr <= 1'd0;
				end else begin
					weight_bram_addr <= 1'd1;
				end
			end
			3'd3: begin
				NDP_unit_reset <= 1'b0;
				if(data_address_into_ndp_unit == BUFFER_SIZE) begin
					step <= 3'd4;
					ndp_unit_in_done_flag <= 1'b1;
				end else begin
					data_address_into_ndp_unit <= data_address_into_ndp_unit + 1'b1;
				end
			end
		endcase
	end

	data_received <= data_in;
end

endmodule