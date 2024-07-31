module NDP_core (
	//--- Clock & Reset ---
	input			axi_aclk,
	input			axi_aresetn,

	output 			clock_pl,
    output			clock_axi,

	//--- Data In (AXI4-Stream)---
	input 		[31:0] 	s_axis_tdata,
	input 				s_axis_tlast,
	input				s_axis_tvalid,
	output reg			s_axis_tready,

	//--- Data Out (AXI4-Stream) ---
	output  	[31:0]	m_axis_tdata,
	output reg 			m_axis_tlast,
	output reg			m_axis_tvalid,
	input				m_axis_tready
);

//--- PARAMETERS -----------------
	//--- Clock Ratio ----
	parameter CLOCK_RATIO = 63;

	//---DATA WIDTH---
	parameter WIDTH=16;

	parameter IS_FLOAT = 1;
	parameter EXP_BITS = 5;
	parameter FRAC_BITS = 10;

	//---Number of PEs in each systolic array---
	parameter ARR_WIDTH = 4;
	parameter ARR_HEIGHT = 4;

	//---Number of Systolic Arrays---
	parameter SYS_WIDTH = 16;
	parameter SYS_HEIGHT = 1;


//--- Nets and Registers -----------

	// Scratch Pad
	reg [8:0] 				data_in_addr;
	reg	[9:0]				m_axis_taddr;

	// NDP_unit
	reg 					NDP_unit_reset;
	reg 					NDP_lock;
	reg 					NDP_in_done;

	// NDP_unit control > Scratch Pad control
	wire 					NDP_calc_done;
	reg 	 				data_out_addr;

	// Scratch Pad control -> NDP_unit control
	reg						tlast_in;
	reg						NDP_reset;

	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] 	NDP_out;

	wire [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 			NDP_in_a;
	wire [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 				NDP_in_b;

	
	assign m_axis_tdata = NDP_out >> 32*m_axis_taddr;

//--- Clock Generation ------------------------------------
	clk_gen #(
		.RATIO				(CLOCK_RATIO)
	) clk_gen0 (
		.reset_in			(axi_aresetn),
		.original_clock		(axi_aclk),
		
		.clock_1x			(clock_axi),
		.clock_slower		(clock_pl)
	);

//--- Scratch Pad ------------------------------------------
	scratch_pad #(
		//---DATA WIDTH---
		.WIDTH(WIDTH),

		//---Number of PEs in each systolic array---
		.SYS_WIDTH(SYS_WIDTH),
		.SYS_HEIGHT(SYS_HEIGHT),

		//---Number of Systolic Arrays---
		.ARR_WIDTH(ARR_WIDTH),
		.ARR_HEIGHT(ARR_HEIGHT)
	)scratch_pad0 (
		//--- Clocks ------------------------------
		.write_clk	(clock_axi),
		.read_clk	(clock_pl),

		//--- Data In -----------------------------
		.wen			(s_axis_tready & s_axis_tvalid),
		.data_in_addr	(data_in_addr),
		.data_in		(s_axis_tdata),

		//--- Data Out ----------------------------
		.data_out_addr	(data_out_addr),
		.data_out_a		(NDP_in_a),
		.data_out_b		(NDP_in_b)
	);


//--- NDP Unit ---------------------------------------------
	NDP_unit #(
		//---DATA WIDTH---
		.WIDTH(WIDTH),
		
		.IS_FLOAT(IS_FLOAT),
		.EXP_BITS(EXP_BITS),
		.FRAC_BITS(FRAC_BITS),

		//---Number of PEs in each systolic array---
		.SYS_WIDTH(SYS_WIDTH),
		.SYS_HEIGHT(SYS_HEIGHT),

		//---Number of Systolic Arrays---
		.ARR_WIDTH(ARR_WIDTH),
		.ARR_HEIGHT(ARR_HEIGHT)
	) ndp_unit_0 (
		//--- Clock & Reset ---
		.clk			(clock_pl),
		.reset			(NDP_unit_reset),

		//--- Data In ---------
		.in_a			(NDP_in_a & {SYS_HEIGHT*ARR_HEIGHT*WIDTH{{~NDP_lock}}}),
		.in_b			(NDP_in_b & {SYS_WIDTH*ARR_HEIGHT*WIDTH{{~NDP_lock}}}),
		.in_done_flag	(NDP_in_done),

		//-- Data Out ---------
		.calc_done_flag	(NDP_calc_done),
		.out_c			(NDP_out)
	);



//--- Control ----------------------------------------------
	//--- Scratch Pad ADDRESS CONTROL ----------
	reg [2:0] scratch_pad_step;
	always @(posedge clock_axi or negedge axi_aresetn) begin
		if(~axi_aresetn) begin
			scratch_pad_step <= 3'b0;
		end else begin
			case (scratch_pad_step)
				3'd0: begin 	// Reset Step
					// READ
					s_axis_tready <= 1'b1;
					data_in_addr <= 11'b0;

					NDP_reset <= 1'b1;

					// AXI OUT (as Master)
					m_axis_taddr	<= 10'b0;
					m_axis_tvalid	<= 1'b0;
					m_axis_tlast	<= 1'b0;

					tlast_in		<= 1'b0;

					scratch_pad_step <= 3'd1;
				end
				3'd1: begin 	// Read
					NDP_reset <= 1'b0;
					
					if(s_axis_tready & s_axis_tvalid) begin
						//---Activate reading (RAM -> Scratch Pad)
						if(data_in_addr[7:1] == SYS_WIDTH && data_in_addr[0]) begin
							//--- Buffer Full ---
							tlast_in 			<= s_axis_tlast;
							data_in_addr[8] 	<= ~data_in_addr[8];
							data_in_addr[7:0] 	<= 8'b0;
							scratch_pad_step 	<= 3'd2;
							s_axis_tready 		<= 1'b0;
						end else begin
							//---Next Address
							data_in_addr[7:0] 	<= data_in_addr[7:0] + 1'b1;
						end
					end
				end
				3'd2: begin
						if(~tlast_in) begin
							//---Resume reading---
							if(data_in_addr[8] == data_out_addr) begin
								s_axis_tready <= 1'b1;
								scratch_pad_step <= 3'd1;
							end
						end else begin
							//---Wait for Final Calculation
							if(NDP_calc_done) begin
								scratch_pad_step <= 3'd3;
							end
						end
				end
				3'd3: begin		// Send data through AXI Stream (as master)
					if(m_axis_tready) begin
						if(~m_axis_tvalid) begin
							m_axis_tvalid <= 1'b1;
						end else begin
							//---Send Results through AXI Stream
							if(m_axis_taddr == SYS_WIDTH*SYS_HEIGHT*ARR_WIDTH*ARR_HEIGHT*WIDTH/32 - 1) begin
								m_axis_tvalid <= 1'b0;
								scratch_pad_step <= 3'd0;
							end else if(m_axis_taddr == SYS_WIDTH*SYS_HEIGHT*ARR_WIDTH*ARR_HEIGHT*WIDTH/32 - 2) begin
								m_axis_taddr <= m_axis_taddr + 1'b1;
								m_axis_tlast <= 1'b1;
							end else begin
								m_axis_taddr <= m_axis_taddr + 1'b1;
							end
						end
					end
				end
			endcase
		end
	end

	//--- NDP Unit Control -------------------

	reg NDP_step;
	reg trigger;
	reg trigger_target;

	always @(posedge clock_pl or posedge NDP_reset) begin
		if(NDP_reset) begin
			NDP_unit_reset 	<= 1'b1;
			data_out_addr 	<= 1'b0;
			NDP_lock		<= 1'b1;
			NDP_in_done		<= 1'b0;

			trigger_target 	<= 1'b0;
			trigger 		<= 1'b1;

			NDP_step 		<= 1'd0;
		end else begin
			trigger <= ~trigger;
			case (NDP_step)
				1'b0: begin
					NDP_unit_reset <= 1'b0;

					if(data_in_addr[8] != data_out_addr && trigger_target == trigger) begin
						//-- Buffer is fed with data, data is available
						NDP_lock <= 1'd0;
						data_out_addr <= ~data_out_addr;
						trigger_target <= ~trigger;

						if(tlast_in) begin
							// If All data is fed -> Add two sums
							NDP_step 	<= 1'b1;
						end
					end else begin
						//--- Buffer is not available -> Wait with NDP locked
						NDP_lock <= 1'd1;
					end
				end
				1'b1: begin
					NDP_lock		<= 1'd1;
					NDP_in_done 	<= 1'b1;
				end
			endcase
		end
	end

endmodule