module ahb_decoder (
	//--- AHB -> DECODER ---
	input			HRESETn,
	input			BIGEND,
	input			PORT1HCLK,
	input			PORT1HSEL,
	input			PORT1HREADYIN,
	input [1:0]		PORT1HTRANS,
	input [1:0]		PORT1HSIZE,
	input			PORT1HWRITE,
	input [31:0]	PORT1HWDATA,
	input [31:0]	PORT1HADDR,
	output [31:0]	PORT1HRDATA,
	output			PORT1HREADYOUT,
	output [1:0]	PORT1HRESP,

	//--- Scratch Pad -> DECODER ---
	input 			from_scratch_pad_HRDATA;
	//--- DECODER -> Scratch Pad ---
	output 			to_scratch_pad_en,
	output			to_scratch_pad_wen,
	output [31:0] 	to_scratch_pad_addr,
	output [31:0] 	to_scratch_pad_wdata
);
// -----------------------------------------------------------------------------
// Signal declaration
wire        HRESETn;
wire  [2:1] REQ;
reg   [1:0] PORT1HSIZEREG;
reg         PORT1HWRITEREG;
reg         PORT1HWRITEOLD;
reg         PORt1HREADYOLD;
reg  [31:0] PORT1HADDRREG;
reg   [1:0] PORT1HTRANSREG;
reg         PORT1HSELREG;
reg         P1HWRITEMUX;
wire [31:0] P1HADDRMUX; 

// -----------------------------------------------------------------------------

// register hsize,hwrite and haddr to create data phase signals PORT 1
always @ (posedge PORT1HCLK or negedge HRESETn)
begin 
	if (!HRESETn)
		begin 
			PORT1HSIZEREG    <= 2'b10;
			PORT1HWRITEREG   <= 1'b0 ;
			PORT1HADDRREG    <= 32'h00000000;
			PORT1HSELREG     <= 1'b0;
			PORT1HTRANSREG   <= 2'b00;
			PORT1HWRITEOLD   <= 1'b0;
			P1HWRITEMUX      <= 1'b0;
		end else begin
			PORT1HWRITEOLD   <= (PORT1HWRITE & PORT1HSEL & PORT1HTRANS[1]);
			P1HWRITEMUX   <= (PORT1HWRITE & PORT1HSEL & PORT1HTRANS[1] &
													 PORT1HREADYIN);
			if (PORT1HREADYIN)
				begin
					PORT1HSIZEREG    <= PORT1HSIZE;
					PORT1HWRITEREG   <= PORT1HWRITE;
					PORT1HADDRREG    <= PORT1HADDR;
					PORT1HSELREG     <= PORT1HSEL;
					PORT1HTRANSREG   <= PORT1HTRANS;
				end 
		end 
end

//Only write to BRAM in Write data phase
//assign P1HWRITEMUX   = PORT1HWRITEOLD & PORT1HREADYIN;
//Delayed in Write Data Phase, else straight through
assign P1HADDRMUX    = P1HWRITEMUX ? PORT1HADDRREG : PORT1HADDR;
// CS on write data phase or read addr phase
assign REQ[1] = (PORT1HTRANSREG[1] & PORT1HWRITEREG & PORT1HSELREG) |
							 (PORT1HTRANS[1] & ~PORT1HWRITE & PORT1HSEL);

// -----------------------------------------------------------------------------
// multiplexing hsize and hwrite and haddr and hwdata
assign PORT1HRESP     = 2'b00;
// Hready needs to be held off if a write was previously committed to DPRAM and
// now a read to DPRAM is required as the address/control phase will overlap.
assign PORT1HREADYOUT = ~(~PORT1HWRITE & PORT1HWRITEOLD & PORT1HTRANS[1]);
reg   [1:0] HADDR1Masked;  // Uses size and BIGEND
wire  [3:0] BWE1;
		
// Byte lane decoding for ssram    
// ----------------------------
// memory byte lane enables are decoded from transfer size, A1, A0 & endianness.
// Change the address so that :
// - The two bottom bits are inverted in BIGEND mode
always @ (P1HADDRMUX or BIGEND)
begin
	HADDR1Masked[1:0]   = PORT1HADDRREG[1:0] ^ {BIGEND, BIGEND};
end
// Decode byte write enables
// Only relevant for writes hence done in write data phase
assign BWE1[0] = P1HWRITEMUX && ( (PORT1HSIZEREG == 2'b10) || 
	((PORT1HSIZEREG == 2'b01) && !HADDR1Masked[1]) || 
	((PORT1HSIZEREG == 2'b00 ) && (HADDR1Masked[1:0] == 2'b00)));
assign BWE1[1] = P1HWRITEMUX && ( (PORT1HSIZEREG == 2'b10) || 
	((PORT1HSIZEREG == 2'b01) && !HADDR1Masked[1]) || 
	((PORT1HSIZEREG == 2'b00 ) && (HADDR1Masked[1:0] == 2'b01)));
assign BWE1[2] = P1HWRITEMUX && ( (PORT1HSIZEREG == 2'b10) || 
	((PORT1HSIZEREG == 2'b01) && HADDR1Masked[1]) || 
	((PORT1HSIZEREG == 2'b00 ) && (HADDR1Masked[1:0] == 2'b10)));
assign BWE1[3] = P1HWRITEMUX && ( (PORT1HSIZEREG == 2'b10) || 
	((PORT1HSIZEREG == 2'b01) && HADDR1Masked[1]) || 
	((PORT1HSIZEREG == 2'b00 ) && (HADDR1Masked[1:0] == 2'b11)));

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG


//---To Scratch Pad---
assign to_scratch_pad_en = REQ[1];
assign to_scratch_pad_wen = BWE1;
assign to_scratch_pad_addr = P1HADDRMUX[17:2];
assign to_scratch_pad_wdata = PORT1HWDATA;

assign PORT1HRDATA = from_scratch_pad_HRDATA;

// bufferram bufferram_i (
// 	.clka ( PORT2HCLK ), // input clka
// 	.ena ( port2cs ), // input ena
// 	.wea ( port2bwe ), // input [1 : 0] wea
// 	.addra ( port2addr[16:0] ), // input [16 : 0] addra
// 	.dina ( port2di ), // input [15 : 0] dina
// 	.douta( port2do ), // output [15 : 0] douta
	
// 	// PS -> DRAM -> BRAM
// 	.clkb ( PORT1HCLK ), // input clkb
// 	.enb ( REQ[1] ), // input enb
// 	.web ( BWE1  ), // input [3 : 0] web
// 	.addrb(P1HADDRMUX[17:2]), // input [15 : 0] addrb
// 	.dinb(PORT1HWDATA), // input [31 : 0] dinb
// 	.doutb(PORT1HRDATA) // output [31 : 0] doutb
// );

endmodule
