module NDP_core (
	//--- Clock & Reset ---
	input			axi_aclk,
	input			axi_aresetn,

	input			is_relu_in,
	input			is_last_in,
	input			read_trigger_in,

	//--- Data In (AXI4-Stream)---
	input 		[31:0] 	s_axis_tdata,
	input 				s_axis_tlast,
	input				s_axis_tvalid,
	output reg			s_axis_tready,

	//--- Data Out (AXI4-Stream) ---
	output  	[31:0]	m_axis_tdata,
	output reg 			m_axis_tlast,
	output reg			m_axis_tvalid,
	input				m_axis_tready,

	output [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 		NDP_in_a_debug,
	output [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 			NDP_in_b_debug,
	output [15:0]			probe2_0,
	output [15:0]			probe3_0,
	output [15:0]			probe4_0,
	output 					probe5_0,
	output 					probe6_0,
	output 					probe7_0,
	output 					probe8_0,
	output [15:0]			probe9_0,
	output 					probe10_0,
	output 					probe11_0,
	output 					probe12_0,
	output 					probe13_0
);


//--- PARAMETERS -----------------
	//--- Clock Ratio ----
	parameter CLOCK_RATIO = 25;

	//---DATA WIDTH---
	parameter WIDTH=16;

	parameter EXP_BITS = 5;
	parameter FRAC_BITS = 10;

	//---Number of PEs in each systolic array---
	parameter ARR_WIDTH = 4;
	parameter ARR_HEIGHT = 4;

	//---Number of Systolic Arrays---
	parameter SYS_WIDTH = 16;
	parameter SYS_HEIGHT = 1;


//--- Nets and Registers -----------
	wire					clock_pl;

	// Settings
	reg						read_trigger;
	reg						is_relu;
	reg						is_last;
	reg						read_from_reg;
	reg	[16:0]				reg_data_key;				

	// Scratch Pad
	reg [8:0] 				data_in_addr;
	reg	[9:0]				m_axis_taddr;

	// NDP_unit
	reg 					NDP_unit_reset;
	reg 					NDP_lock;
	reg 					NDP_in_done;

	// NDP_unit control > Scratch Pad control
	wire 					NDP_calc_done;
	reg		 				data_out_addr;

	// Scratch Pad control -> NDP_unit control
	reg						tlast_in;
	reg						NDP_reset;
	
	// activation & weight data from scratch pad (RAM)
	wire [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 		scratch_pad_out_a;
	wire [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 			scratch_pad_out_b;

	// activation data from previous calculations
	reg [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] 	calc_result_old;
	wire [WIDTH - 1 : 0] NDP_in_a_0 = calc_result_old >> (0*WIDTH*ARR_WIDTH*SYS_WIDTH + WIDTH*(reg_data_key-1'b1));
	wire [WIDTH - 1 : 0] NDP_in_a_1 = calc_result_old >> (1*WIDTH*ARR_WIDTH*SYS_WIDTH + WIDTH*(reg_data_key-1'b1));
	wire [WIDTH - 1 : 0] NDP_in_a_2 = calc_result_old >> (2*WIDTH*ARR_WIDTH*SYS_WIDTH + WIDTH*(reg_data_key-1'b1));
	wire [WIDTH - 1 : 0] NDP_in_a_3 = calc_result_old >> (3*WIDTH*ARR_WIDTH*SYS_WIDTH + WIDTH*(reg_data_key-1'b1));

	// NDP in
	wire [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 	NDP_in_a = ~read_from_reg 
														?  scratch_pad_out_a
														: {NDP_in_a_3, NDP_in_a_2, NDP_in_a_1, NDP_in_a_0};
	wire [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 		NDP_in_b = scratch_pad_out_b;
	
	// calculation result from NDP
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] 	NDP_out;
	wire [SYS_HEIGHT*ARR_HEIGHT*SYS_WIDTH*ARR_WIDTH*WIDTH - 1 : 0] 	result_relu;

//--- Clock Generation ------------------------------------
	clk_gen #(
		.RATIO				(CLOCK_RATIO)
	) clk_gen0 (
		.reset_in			(axi_aresetn),
		.original_clock		(axi_aclk),
		
		.clock_2x			(),
		.clock_slower		(clock_pl)
	);

//--- Scratch Pad ------------------------------------------
	scratch_pad #(
		//---DATA WIDTH---
		.WIDTH			(WIDTH),

		//---Number of PEs in each systolic array---
		.SYS_WIDTH		(SYS_WIDTH),
		.SYS_HEIGHT		(SYS_HEIGHT),

		//---Number of Systolic Arrays---
		.ARR_WIDTH		(ARR_WIDTH),
		.ARR_HEIGHT		(ARR_HEIGHT)
	)scratch_pad0 (
		//--- Clocks ------------------------------
		.write_clk		(axi_aclk),
		.read_clk		(clock_pl),

		//--- Data In -----------------------------
		.wen			(s_axis_tready & s_axis_tvalid),
		.data_in_addr	(data_in_addr),
		.data_in		(s_axis_tdata),

		//--- Data Out ----------------------------
		.data_out_addr	(data_out_addr),
		.data_out_a		(scratch_pad_out_a),
		.data_out_b		(scratch_pad_out_b)
	);


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
		.reset			(NDP_unit_reset),

		//--- Data In ---------
		.in_a			(NDP_in_a & {SYS_HEIGHT*ARR_HEIGHT*WIDTH{{~NDP_lock}}}),
		.in_b			(NDP_in_b & {SYS_WIDTH*ARR_WIDTH*WIDTH{{~NDP_lock}}}),
		.in_done_flag	(NDP_in_done),

		//-- Data Out ---------
		.calc_done_flag	(NDP_calc_done),
		.out_c			(NDP_out)
	);



//--- Control ----------------------------------------------
	//--- Scratch Pad ADDRESS CONTROL ----------
	reg [2:0] scratch_pad_step;
	always @(posedge axi_aclk or negedge axi_aresetn) begin
		if(~axi_aresetn) begin
			scratch_pad_step 	<= 3'b0;
			read_from_reg		<= 1'b0;
			read_trigger		<= 1'b1;
		end else begin
			case (scratch_pad_step)
				3'd0: begin 	// Initilization Step
					// READ Configurations
					is_relu 		<= is_relu_in;
					is_last 		<= is_last_in;
					data_in_addr 	<= {7'b0, read_from_reg, 1'b0};
					tlast_in		<= 1'b0;

					// NDP Configurations
					NDP_reset		<= 1'b1;

					// WRITE Configurations
					m_axis_taddr	<= 10'b0;
					m_axis_tvalid	<= 1'b0;
					m_axis_tlast	<= 1'b0;
					
					// Wait for configurations to finish
					if(read_trigger == read_trigger_in) begin
						// Start Reading
						s_axis_tready 		<= 1'b1;
						read_trigger 		<= ~read_trigger;
						scratch_pad_step 	<= 3'd1;
					end
				end
				3'd1: begin 	// Read
					if(s_axis_tready & s_axis_tvalid) begin
						//---Activate reading (RAM -> Scratch Pad)
						if(data_in_addr[7:1] == SYS_WIDTH && data_in_addr[0]) begin
							//--- Buffer Full ---
							tlast_in 			<= s_axis_tlast;
							data_in_addr[8] 	<= ~data_in_addr[8];
							data_in_addr[7:0] 	<= {6'b00_0000, read_from_reg, 1'b0};
							scratch_pad_step 	<= 3'd2;
							s_axis_tready 		<= 1'b0;
							
							NDP_reset <= 1'b0;
						end else begin
							//---Next Address
							data_in_addr[7:0] 	<= data_in_addr[7:0] + 1'b1;
						end
					end
				end
				3'd2: begin
					if(~tlast_in) begin
						//---Data left in memory : Resume reading---
						if(data_in_addr[8] == data_out_addr) begin
							s_axis_tready 		<= 1'b1;
							scratch_pad_step 	<= 3'd1;
						end
					end else begin
						//--- Data transfer from memory finished ----
						//		: Wait for Final Calculation
						if(NDP_calc_done) begin
							// Calculation finished
							if(~is_last) begin
								// Continuous calculation (store calculated data as activation data)
								//--- Resume Reading (only Weight Data)
								read_from_reg 		<= 1'b1;
								calc_result_old 	<= result_relu;
								scratch_pad_step 	<= 3'd0;
							end else begin
								//--- Start transfering result data back to memory
								scratch_pad_step 	<= 3'd3;
							end
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
								m_axis_tvalid 		<= 1'b0;
								scratch_pad_step 	<= 3'd0;
								read_from_reg 		<= 1'b0;
							end else if(m_axis_taddr == SYS_WIDTH*SYS_HEIGHT*ARR_WIDTH*ARR_HEIGHT*WIDTH/32 - 2) begin
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

	//--- NDP Unit Control -------------------

	reg NDP_step;
	reg trigger;
	reg trigger_target;

	always @(posedge clock_pl or posedge NDP_reset) begin
		if(NDP_reset) begin
			NDP_unit_reset 	<= 1'b1;
			
			// Data address
			data_out_addr 	<= 1'b0; 	// data from scratch pad
			reg_data_key 	<= 17'b0;	// data from register

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
						reg_data_key <= reg_data_key + 1'b1;
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
	
//--- Output Generation: ReLU ---------------------------------------
	ReLU_layer #(
		//---DATA WIDTH---
		.WIDTH(WIDTH),
		//---Number of PEs in each systolic array---
		.ARR_WIDTH(ARR_WIDTH),
		.ARR_HEIGHT(ARR_HEIGHT),
		//---Number of Systolic Arrays---
		.SYS_WIDTH(SYS_WIDTH),
		.SYS_HEIGHT(SYS_HEIGHT)
	) relu_layer0 (
		.apply_relu	(is_relu),
		.in			(NDP_out),
		.out		(result_relu)
	);

	assign m_axis_tdata = result_relu >> 32*m_axis_taddr;

	
//--- DEBUG---
assign NDP_in_a_debug = NDP_in_a;
assign NDP_in_b_debug = NDP_in_b;
assign probe2_0 =  reg_data_key;
assign probe3_0 = NDP_step;
assign probe4_0 = scratch_pad_step;
assign probe5_0 = is_last_in;
assign probe6_0 = is_last;
assign probe7_0 = data_out_addr;
assign probe8_0 = NDP_lock;
assign probe9_0 = NDP_out[4095:4080];
assign probe10_0 = read_trigger;
assign probe11_0 = read_trigger_in;
assign probe12_0 = s_axis_tvalid;
assign probe13_0 = s_axis_tready;

endmodule