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

//--- WIRES ---------------------------
  	//--- CLOCK & RESET -----------
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

	//--- AHB Signals ---
	wire [31:0]	M_AHB_haddr;
	wire [2:0]	M_AHB_hburst;
	wire		M_AHB_hmastlock;
	wire [3:0]	M_AHB_hprot;
	wire [31:0]	M_AHB_hrdata;
	wire		M_AHB_hready;
	wire		M_AHB_hresp;
	wire [2:0]	M_AHB_hsize;
	wire [1:0]	M_AHB_htrans;
	wire [31:0]	M_AHB_hwdata;
	wire		M_AHB_hwrite;

	wire 		is_relu;
	wire 		is_last;
	wire		read_trigger;

	NDP_core NDP_core0 (
		//--- Clock & Reset ---
		.axi_aclk		(FCLK_CLK0),
		.axi_aresetn	(peripheral_aresetn),

		.is_relu_in		(is_relu),
		.is_last_in		(is_last),
		.read_trigger_in	(read_trigger),

		//--- Data In (AXI4-Stream)---
		.s_axis_tdata	(M_AXIS_tdata),
		.s_axis_tlast	(M_AXIS_tlast),
		.s_axis_tvalid	(M_AXIS_tvalid),
		.s_axis_tready	(M_AXIS_tready),

		//--- Data Out (AXI4-Stream) ---
		.m_axis_tdata	(S_AXIS_tdata),
		.m_axis_tlast	(S_AXIS_tlast),
		.m_axis_tvalid	(S_AXIS_tvalid),
		.m_axis_tready	(S_AXIS_tready)
	);

	//--- Signals (ReLU) ----
	signals signals0 (
		.HCLK			(FCLK_CLK0),
		.HRESETn		(peripheral_aresetn),
		.HSEL			(1'b1),
		.HADDR			(M_AHB_haddr),
		.HWRITE			(M_AHB_hwrite),
		.HTRANS			(M_AHB_htrans),
		.HSIZE			(M_AHB_hsize),
		.HWDATA			(M_AHB_hwdata),
		.HREADY			(M_AHB_hready),
		.HREADYin		(M_AHB_hready),
		.HRESP			(M_AHB_hresp),
		.HRDATA			(M_AHB_hrdata),
		.read_trigger	(read_trigger),
		.is_relu		(is_relu),
		.is_last		(is_last)
	);

	system_wrapper system_wrapper0 (
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

		.M_AHB_haddr			(M_AHB_haddr),
		.M_AHB_hburst			(M_AHB_hburst),
		.M_AHB_hprot			(M_AHB_hprot),
		.M_AHB_hrdata			(M_AHB_hrdata),
		.M_AHB_hready			(M_AHB_hready),
		.M_AHB_hresp			(M_AHB_hresp),
		.M_AHB_hsize			(M_AHB_hsize),
		.M_AHB_htrans			(M_AHB_htrans),
		.M_AHB_hwdata			(M_AHB_hwdata),
		.M_AHB_hwrite			(M_AHB_hwrite),

		.FCLK_CLK0				(FCLK_CLK0),
		.peripheral_aresetn		(peripheral_aresetn)
	);
	
	
endmodule
