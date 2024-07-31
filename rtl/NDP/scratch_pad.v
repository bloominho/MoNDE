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
	//--- Clocks ----------------
	input write_clk,
	input read_clk,

	//--- Data In ---------------
	input 			wen,
	input [10:0] 	data_in_addr,
	input [31:0] 	data_in,

	//--- Data Out ---------------
	input [2:0] 	data_out_addr,
	output [ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] 	data_out_a,
	output [ARR_WIDTH*SYS_WIDTH*WIDTH-1:0] 		data_out_b
);

//--- Scratch Pad -------------------------------------

wire [(SYS_HEIGHT+SYS_WIDTH) * 64 - 1 : 0] data_out;

genvar i;
generate
	for(i=0; i<SYS_HEIGHT+SYS_WIDTH; i=i+1) begin
		bram bram_x (
			.clka(write_clk),
			.ena(1'b1),
			.wea(data_in_addr[7:1] == i && wen),
			.addra({data_in_addr[10:8], data_in_addr[0]}),
			.dina(data_in),
			.douta(),

			.clkb(read_clk),
			.enb(1'b1),
			.web(1'b0),
			.addrb(data_out_addr),
			.dinb(64'b0),
			.doutb(data_out[i*64 + 63 : i*64])
		);
	end
endgenerate

assign data_out_a = data_out[63:0];
assign data_out_b = data_out[(SYS_HEIGHT+SYS_WIDTH) * 64 - 1:64];


endmodule
