module clk_gen #(
	parameter RATIO = 5
) (	
	input 	reset_in,
	input   original_clock,

	output reg  clock_1x,
	output reg  clock_slower
);

reg [5:0] clk_count;

always @(posedge original_clock) begin
	if(~reset_in) begin
		clock_1x		<= 1'b1;
		clock_slower	<= 1'b0;

		clk_count		<= 6'b0;
	end else begin
		clock_1x		<= ~clock_1x;

		if(clk_count != RATIO - 1) begin
			clk_count		<= clk_count + 1'b1;
		end else begin
			clk_count		<= 6'b0;
			clock_slower	<= ~clock_slower;
		end
	end
end

endmodule