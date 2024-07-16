module fifo_buffer #(
	parameter SIZE = 4,
	parameter WIDTH = 8
) (
	input clk,
	input reset,
	input [WIDTH-1:0] in, 		//data in
	output [WIDTH-1:0] out		//data out
);

//---BUFFER---
reg [WIDTH-1:0] buffer [SIZE-1:0];

integer i;
always @(posedge clk or posedge reset) begin
	if(reset) begin

		//---Reset: Initialize to Zero---
		for(i=0; i<SIZE; i=i+1) begin
			buffer[i] <= 0;
		end

	end else begin

		//---Feed buffer---
		buffer[0] <= in;

		//---Pass values to next register---
		for(i=0; i<SIZE-1; i=i+1) begin
			buffer[i+1] <= buffer[i];
		end

	end
end

//---Dequeue from buffer---
assign out = buffer[SIZE-1];

endmodule