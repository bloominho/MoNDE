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
	input clk,
	input [2:0] step,

	input act_bram_num,
	input act_bram_addr,
	input [2:0] act_bram_layer,

	input [31:0] data_received,
	input [2:0] data_address_into_ndp_unit,

	output [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] data_out_a,

	input [5:0] weight_bram_num,
	input weight_bram_addr,
	input [2:0] weight_bram_layer,

	output [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] data_out_b
);

	//---Scratch Pad---
	//---Activation Matrix---

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
				.doutb(data_out_a[64*i +: 64])
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
				.doutb(data_out_b[64*j +: 64])
			);
		end
	endgenerate

endmodule
