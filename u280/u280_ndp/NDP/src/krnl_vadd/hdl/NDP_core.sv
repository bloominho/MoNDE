
`default_nettype none

module NDP_core #(
  parameter integer C_DATA_WIDTH   = 32, // Data width of both input and output data
  parameter integer C_NUM_CHANNELS = 1,
  
	//---Number of PEs in each systolic array---
	parameter ARR_WIDTH = 4,
	parameter ARR_HEIGHT = 4,

	//---Number of Systolic Arrays---
	parameter SYS_WIDTH = 16,
	parameter SYS_HEIGHT = 1
) (
	//--- Clock & Reset ---
	input wire			axi_aclk,
	input wire			axi_aresetn,
  	// Double Clock
  	input  wire  		clock_pl,

	input wire			is_relu_in,

	input wire 	[31:0] 	length_in,

	output reg 			NDP_done,

	//--- Data In (AXI4-Stream)---
	input wire 	[C_NUM_CHANNELS-1:0][34*C_DATA_WIDTH-1:0] 	s_axis_tdata,
	input wire 												s_axis_tlast,
	input wire	[C_NUM_CHANNELS-1:0]						s_axis_tvalid,
	output reg	[C_NUM_CHANNELS-1:0]						s_axis_tready,

	//--- Data Out (AXI4-Stream) ---
	output wire [2*32 - 1:0]		m_axis_tdata,
	output reg 						m_axis_tlast,
	output reg						m_axis_tvalid,
	input  wire						m_axis_tready
);


//--- PARAMETERS -----------------
	//--- Clock Ratio ----
	parameter CLOCK_RATIO = 65;

	//---DATA WIDTH---
	parameter WIDTH=16;

	parameter EXP_BITS = 5;
	parameter FRAC_BITS = 10;



//--- Nets and Registers -----------
	// wire					clock_pl;

	// Settings
	reg						is_relu;

	reg [31:0] 				length;	
	reg [31:0] 				count;			

	reg	[9:0]				m_axis_taddr;

	// NDP_unit
	reg 					NDP_unit_reset;
	reg 					NDP_lock;
	reg 					NDP_in_done;

	// NDP_unit control > Scratch Pad control
	wire 					NDP_calc_done;
	reg		 				data_out_addr;

	// Scratch Pad control -> NDP_unit control
	reg						NDP_reset;


	// NDP in
	wire [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 	NDP_in_a = s_axis_tdata[0][SYS_HEIGHT*ARR_HEIGHT*WIDTH-1:0];
	wire [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 		NDP_in_b = s_axis_tdata[0][SYS_HEIGHT*ARR_HEIGHT*WIDTH + SYS_WIDTH*ARR_WIDTH*WIDTH - 1 :SYS_HEIGHT*ARR_HEIGHT*WIDTH];
	
	// calculation result from NDP
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] 	NDP_out;
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] 	result_relu;


//--- NDP Unit ---------------------------------------------
	NDP_unit #(
		//---DATA WIDTH---
		.WIDTH		(WIDTH),
		
		.EXP_BITS	(EXP_BITS),
		.FRAC_BITS	(FRAC_BITS),

		//---Number of PEs in each systolic array---
		.SYS_WIDTH	(SYS_WIDTH),
		.SYS_HEIGHT	(SYS_HEIGHT),

		//---Number of Systolic Arrays---
		.ARR_WIDTH	(ARR_WIDTH),
		.ARR_HEIGHT	(ARR_HEIGHT)
	) ndp_unit_0 (
		//--- Clock & Reset ---
		.clk			(clock_pl),
		.reset			(NDP_reset),

		//--- Data In ---------
		.in_a			(NDP_in_a & {SYS_HEIGHT*ARR_HEIGHT*WIDTH{{s_axis_tready[0] & s_axis_tvalid[0]}}}),
		.in_b			(NDP_in_b & {SYS_WIDTH*ARR_WIDTH*WIDTH{{s_axis_tready[0] & s_axis_tvalid[0]}}}),
		.in_done_flag	(NDP_in_done),

		//-- Data Out ---------
		.calc_done_flag	(NDP_calc_done),
		.out_c			(NDP_out)
	);

//--- Control ----------------------------------------------
	//--- NDP_control ----------
	reg [2:0] 	NDP_step;
	always @(posedge axi_aclk) begin
		if(~axi_aresetn) begin
			NDP_step 	<= 3'b0;

			s_axis_tready[0] 	<= 1'b0;
			NDP_done			<= 1'b0;
		end else begin
			case (NDP_step)
				3'd0: begin 	// Initilization Step
					// READ Configurations
					is_relu 		<= is_relu_in;
					length			<= length_in;
					count 			<= 32'b1;			

					// NDP Configurations
					NDP_reset 		<= 1'b1;
					NDP_in_done		<= 1'b0;
					NDP_done 		<= 1'b0;

					// WRITE Configurations
					m_axis_taddr	<= 10'b0;
					m_axis_tvalid	<= 1'b0;
					m_axis_tlast	<= 1'b0;
					
					NDP_step 			<= 3'd1;
				end
				3'd1: begin 	// Read
					NDP_reset 			<= 1'b0;
					s_axis_tready[0] 	<= 1'b1;

					if(s_axis_tready[0] & s_axis_tvalid[0]) begin
						//---Activate reading (RAM -> NDP Unit)
						count 			<= count + 1'b1;
						if(length == count) begin
							NDP_step 			<= 3'd2;
							s_axis_tready[0] 	<= 1'b0;
						end
					end
				end
				3'd2: begin
					NDP_in_done 	<= 1'b1;
					if(NDP_calc_done) begin
						// Calculation finished
						NDP_step 	<= 3'd3;
					end
				end
				3'd3: begin		// Send data through AXI Stream (as master)
					if(m_axis_tready) begin
						if(~m_axis_tvalid) begin
							m_axis_tvalid <= 1'b1;
						end else begin
							//---Send Results through AXI Stream
							if(m_axis_taddr == SYS_WIDTH*ARR_WIDTH - 1) begin
								m_axis_tvalid 		<= 1'b0;
								NDP_step 			<= 3'd0;
								NDP_done 			<= 1'b1;
							end else if(m_axis_taddr == SYS_WIDTH*ARR_WIDTH - 2) begin
								m_axis_taddr 		<= m_axis_taddr + 1'b1;
								m_axis_tlast 		<= 1'b1;
							end else begin
								m_axis_taddr 		<= m_axis_taddr + 1'b1;
							end
						end
					end
				end
			endcase
		end
	end
	
//--- Output Generation: ReLU ---------------------------------------
	ReLU_layer #(
		//---DATA WIDTH---
		.WIDTH(WIDTH),
		//---Number of floats---
		.COUNT(ARR_HEIGHT*ARR_WIDTH*SYS_WIDTH*SYS_HEIGHT)
	) relu_layer0 (
		.apply_relu	(is_relu),
		.in			(NDP_out),
		.out		(result_relu)
	);

	assign m_axis_tdata[15:0]  = result_relu >> m_axis_taddr*WIDTH + 0*ARR_WIDTH*SYS_WIDTH*WIDTH;
	assign m_axis_tdata[31:16] = result_relu >> m_axis_taddr*WIDTH + 1*ARR_WIDTH*SYS_WIDTH*WIDTH;
	assign m_axis_tdata[47:32] = result_relu >> m_axis_taddr*WIDTH + 2*ARR_WIDTH*SYS_WIDTH*WIDTH;
	assign m_axis_tdata[63:48] = result_relu >> m_axis_taddr*WIDTH + 3*ARR_WIDTH*SYS_WIDTH*WIDTH;

endmodule : NDP_core

`default_nettype wire