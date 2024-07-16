// BRAM MODULE (for test and simulations)

module bram_dual #(
	parameter A_WIDTH = 32,
	parameter COUNT = 10,
	parameter A_ADDRESS_WIDTH = 4,

	parameter B_WIDTH = 64,
	B_ADDRESS_WIDTH = 3
) (
	input clka,
	input ena,
	input wea,
	input [A_ADDRESS_WIDTH - 1 : 0] addra,
	input [A_WIDTH - 1 : 0] dina,
	output reg [A_WIDTH - 1 : 0] douta,

	input clkb,
	input enb,
	input web,
	input [B_ADDRESS_WIDTH - 1 : 0] addrb,
	input [B_WIDTH - 1 : 0] dinb,
	output reg [B_WIDTH - 1 : 0] doutb
);

reg [A_WIDTH*COUNT - 1 : 0] data;

always @(posedge clka) begin
	if(wea) begin
		case (addra)
			4'd0:
				data[0 * A_WIDTH + A_WIDTH - 1 : 0 * A_WIDTH] <= dina;
			4'd1:
				data[1 * A_WIDTH + A_WIDTH - 1 : 1 * A_WIDTH] <= dina;
			4'd2:
				data[2 * A_WIDTH + A_WIDTH - 1 : 2 * A_WIDTH] <= dina;
			4'd3:
				data[3 * A_WIDTH + A_WIDTH - 1 : 3 * A_WIDTH] <= dina;
			4'd4:
				data[4 * A_WIDTH + A_WIDTH - 1 : 4 * A_WIDTH] <= dina;
			4'd5:
				data[5 * A_WIDTH + A_WIDTH - 1 : 5 * A_WIDTH] <= dina;
			4'd6:
				data[6 * A_WIDTH + A_WIDTH - 1 : 6 * A_WIDTH] <= dina;
			4'd7:
				data[7 * A_WIDTH + A_WIDTH - 1 : 7 * A_WIDTH] <= dina;
			4'd8:
				data[8 * A_WIDTH + A_WIDTH - 1 : 8 * A_WIDTH] <= dina;
			4'd9:
				data[9 * A_WIDTH + A_WIDTH - 1 : 9 * A_WIDTH] <= dina;
		endcase
	end else begin
		data <= data;
	end

	doutb <= data[B_WIDTH * addrb +: B_WIDTH];
end

endmodule