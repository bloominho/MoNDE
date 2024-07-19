module scratch_pad #(
	//---DATA WIDTH---
	parameter WIDTH=16,

	parameter BUFFER_SIZE = 5,

	//---Number of PEs in each systolic array---
	parameter SYS_WIDTH = 64,
	parameter SYS_HEIGHT = 1,

	//---Number of Systolic Arrays---
	parameter ARR_WIDTH = 4,
	parameter ARR_HEIGHT = 4
) (
	input write_clk,
	input read_clk,

	input			en;
	input 			wen,
	input 			bram_type,
	input [2:0] 	bram_layer,
	input [5:0] 	bram_num,
	input 			bram_addr,
	input [31:0] 	data_in,
	output reg [31:0] 	HRDATA,

	input [2:0] 	data_address_into_ndp_unit,
	output [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	data_out_a,
	output [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] 		data_out_b
);

	//---Scratch Pad---
	//---Activation Matrix---

	wire [32*SYS_HEIGHT - 1 : 0] act_douta;
	genvar i;
	generate
		for(i=0; i<SYS_HEIGHT; i=i+1) begin
			bram_dual_act bram_activation_X (
				.clka(write_clk),
				.ena(en & (~bram_type) & (bram_num == i)),
				.wea(wen & (~bram_type) & (bram_num == i)),
				.addra(bram_addr + 4'd2*bram_layer),
				.dina(data_in),
				.douta(act_douta[i*32 +: 32]),

				.clkb(read_clk),
				.enb(1'b1),
				.web(),
				.addrb(data_address_into_ndp_unit),
				.dinb(),
				.doutb(data_out_a[64*i +: 64])
			);
		end
	endgenerate

	//---Weight Matrix---
	wire [32*SYS_WIDTH - 1 : 0] weight_douta;
	genvar j;
	generate
		for(j=0; j<SYS_WIDTH; j=j+1) begin
			bram_dual_act bram_weight_X (
				.clka(write_clk),
				.ena(en & bram_type & (bram_num == j)),
				.wea(wen & bram_type & (bram_num == j)),
				.addra(bram_addr + 4'd2*bram_layer),
				.dina(data_in),
				.douta(weight_douta[j*32 +: 32]),

				.clkb(read_clk),
				.enb(1'b1),
				.web(),
				.addrb(data_address_into_ndp_unit),
				.dinb(),
				.doutb(data_out_b[64*j +: 64])
			);
		end
	endgenerate

	always @(*) begin
		if(~bram_type) begin
			HRDATA <= act_douta[bram_num*32 +: 32];
		end else begin
			HRDATA <= weight_douta[bram_num*32 +: 32];
		end
	end

endmodule
