
module ReLU_layer #(
	//---DATA WIDTH---
	parameter WIDTH=16,
	//---Number of PEs in each systolic array---
	parameter ARR_WIDTH = 4,
	parameter ARR_HEIGHT = 4,

	//---Number of Systolic Arrays---
	parameter SYS_WIDTH = 16,
	parameter SYS_HEIGHT = 1
) (
    input apply_relu,

    input [ARR_HEIGHT*SYS_HEIGHT*ARR_WIDTH*SYS_WIDTH*WIDTH - 1 : 0] in,
    output reg [ARR_HEIGHT*SYS_HEIGHT*ARR_WIDTH*SYS_WIDTH*WIDTH - 1:0] out
);


genvar i;
generate
    for(i = 0; i < ARR_HEIGHT*SYS_HEIGHT*ARR_WIDTH*SYS_WIDTH; i=i+1) begin
        always @(*) begin
            if(~apply_relu) begin
                out[WIDTH*(i+1) - 1 : WIDTH*i] <= in[WIDTH*(i+1) - 1 : WIDTH*i];
            end else begin
                if(~in[WIDTH*(i+1) - 1]) begin
                    // Positive 
                    out[WIDTH*(i+1) - 1 : WIDTH*i] <= in[WIDTH*(i+1) - 1 : WIDTH*i];
                end else begin
                    // Negative 
                    out[WIDTH*(i+1) - 1 : WIDTH*i]<= 16'b0;
                end
            end
        end
    end
endgenerate


endmodule