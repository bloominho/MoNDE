`timescale 1ns/10ps

module tb_BRAM;
    parameter WIDTH = 8;
	parameter STEP = 5;

	parameter A_WIDTH = 32;
	parameter COUNT = 2;
	parameter A_ADDRESS_WIDTH = 1;

	parameter B_WIDTH = 64;
	parameter B_ADDRESS_WIDTH = 0;


	reg clk;
	reg reset;

	reg bram_address;
	reg [31:0] data_in;

	wire [63:0] data_out;

	bram_dual bufferram_weight_X (
		.clka(clk),
		.ena(1'b1),
		.wea(1'b1),
		.addra(bram_address),
		.dina(data_in),
		.douta(),
		
		//---DATA OUT (into NDP unit)---
		.clkb(clk),
		.enb(1'b1),
		.web(1'b0),
		.addrb(1'b0),
		.dinb(64'd0),
		.doutb(data_out)
	);
	
	initial
		$monitor($time, "in=%b, out=%b", data_in, data_out);
	
	initial
	begin
		clk = 1'b0;
		forever #(STEP/2) clk = ~clk;
	end
	
	initial begin 
		bram_address = 1;
		data_in = $random;
		repeat(2)@(negedge clk);
		data_in = $random;
		repeat(2)@(negedge clk); 
		data_in = $random;
		repeat(200)@(negedge clk);
		$finish;
	end

endmodule
