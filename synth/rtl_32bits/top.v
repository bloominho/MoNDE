`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2024 10:44:53 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
	input [0:0] 	SYSCLK_P,
	input [0:0]		SYSCLK_N,

	inout [14:0]	DDR_addr,
	inout [2:0]		DDR_ba,
	inout 			DDR_cas_n,
	inout 			DDR_ck_n,
	inout 			DDR_ck_p,
	inout 			DDR_cke,
	inout 			DDR_cs_n,
	inout [3:0]		DDR_dm,
	inout [31:0]	DDR_dq,
	inout [3:0]		DDR_dqs_n,
	inout [3:0]		DDR_dqs_p,
	inout 			DDR_odt,
	inout 			DDR_ras_n,
	inout 			DDR_reset_n,
	inout 			DDR_we_n,
	
	inout 			FIXED_IO_ddr_vrn,
	inout 			FIXED_IO_ddr_vrp,
	inout [53:0]	FIXED_IO_mio,
	inout 			FIXED_IO_ps_clk,
	inout 			FIXED_IO_ps_porb,
	inout 			FIXED_IO_ps_srstb
);

//--- PARAMETERS -----------------
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

	parameter BUFFER_SIZE = 5;


//--- WIRES ---------------------------
  	//--- CLOCK & RESET -----------
	wire [0:0]	IBUF_OUT;
	wire 		FCLK_CLK0;
	wire [0:0]	peripheral_aresetn;

	//--- AXI MASTER (RAM -> NDP)
	wire [31:0]	M_AXIS_tdata;
	wire [7:0]	M_AXIS_tkeep;
	wire 		M_AXIS_tlast;
	wire 		M_AXIS_tready;
	wire		M_AXIS_tvalid;

	//--- AXI SLAVE (NDP -> RAM)
	wire [31:0]	S_AXIS_tdata;
	wire [7:0]	S_AXIS_tkeep;
	wire		S_AXIS_tlast;
	wire 		S_AXIS_tready;
	wire 		S_AXIS_tvalid;
	
	//--- DEBUG SIGNALS -----------
	wire [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 		NDP_in_a_debug;
	wire [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 			NDP_in_b_debug;

	wire [SYS_HEIGHT*ARR_HEIGHT*WIDTH - 1:0] 		into_sys_a_debug;
	wire [SYS_WIDTH*ARR_WIDTH*WIDTH - 1:0] 			into_sys_b_debug;

	wire [1:0] 										NDP_step_debug;
	wire 											NDP_lock_debug;
	wire [5:0]										buffer_filled_in_debug;
	wire [3:0] 										data_out_addr_debug;
	wire [15:0]										NDP_out_debug;
	wire [15:0]										add_in_debug;


	NDP_core NDP_core0 (
		//--- Clock & Reset ---
		.axi_aclk(FCLK_CLK0),
		.axi_aresetn(peripheral_aresetn),
		.ps_clk(FCLK_CLK0),

		//--- Data In (AXI4-Stream)---
		.s_axis_tdata(M_AXIS_tdata),
		.s_axis_tlast(M_AXIS_tlast),
		.s_axis_tvalid(M_AXIS_tvalid),
		.s_axis_tready(M_AXIS_tready),

		//--- Data Out (AXI4-Stream) ---
		.m_axis_tdata(S_AXIS_tdata),
		.m_axis_tlast(S_AXIS_tlast),
		.m_axis_tvalid(S_AXIS_tvalid),
		.m_axis_tready(S_AXIS_tready),

		//--- DEBUG ---
		.NDP_in_a_debug(NDP_in_a_debug),
		.NDP_in_b_debug(NDP_in_b_debug),
		.into_sys_a_debug(into_sys_a_debug),
		.into_sys_b_debug(into_sys_b_debug),

		.NDP_step_debug(NDP_step_debug),
		.NDP_lock_debug(NDP_lock_debug),
		.buffer_filled_in_debug(buffer_filled_in_debug),
		.data_out_addr_debug(data_out_addr_debug),
		.NDP_out_debug(NDP_out_debug),
		.add_in_debug(add_in_debug)
	);

	system_wrapper system_wrapper0 (
		.SYSCLK_P				(SYSCLK_P),
		.SYSCLK_N				(SYSCLK_N),
		.DDR_addr				(DDR_addr),
		.DDR_ba					(DDR_ba),
		.DDR_cas_n				(DDR_cas_n),
		.DDR_ck_n				(DDR_ck_n),
		.DDR_ck_p				(DDR_ck_p),
		.DDR_cke				(DDR_cke),
		.DDR_cs_n				(DDR_cs_n),
		.DDR_dm					(DDR_dm),
		.DDR_dq					(DDR_dq),
		.DDR_dqs_n				(DDR_dqs_n),
		.DDR_dqs_p				(DDR_dqs_p),
		.DDR_odt				(DDR_odt),
		.DDR_ras_n				(DDR_ras_n),
		.DDR_reset_n			(DDR_reset_n),
		.DDR_we_n				(DDR_we_n),
		.FIXED_IO_ddr_vrn		(FIXED_IO_ddr_vrn),
		.FIXED_IO_ddr_vrp		(FIXED_IO_ddr_vrp),
		.FIXED_IO_mio			(FIXED_IO_mio),
		.FIXED_IO_ps_clk		(FIXED_IO_ps_clk),
		.FIXED_IO_ps_porb		(FIXED_IO_ps_porb),
		.FIXED_IO_ps_srstb		(FIXED_IO_ps_srstb),

		.M_AXIS_tdata			(M_AXIS_tdata),
		.M_AXIS_tlast			(M_AXIS_tlast),
		.M_AXIS_tready			(M_AXIS_tready),
		.M_AXIS_tvalid			(M_AXIS_tvalid),

		.S_AXIS_tdata			(S_AXIS_tdata),
		.S_AXIS_tlast			(S_AXIS_tlast),
		.S_AXIS_tready			(S_AXIS_tready),
		.S_AXIS_tvalid			(S_AXIS_tvalid),

		.FCLK_CLK0				(FCLK_CLK0),
  		.IBUF_OUT				(IBUF_OUT),
		.peripheral_aresetn		(peripheral_aresetn),

		//--- DEBUG ---
		
		.NDP_in_a_debug(NDP_in_a_debug),
		.NDP_in_b_debug(NDP_in_b_debug),
		.into_sys_a_debug(into_sys_a_debug),
		.into_sys_b_debug(into_sys_b_debug),
		
		.NDP_step_debug(NDP_step_debug),
		.NDP_lock_debug(NDP_lock_debug),
		.buffer_filled_in_debug(buffer_filled_in_debug),
		.data_out_addr_debug(data_out_addr_debug),
		.NDP_out_debug(NDP_out_debug),
		.add_in_debug(add_in_debug)
	);
	
	
endmodule
