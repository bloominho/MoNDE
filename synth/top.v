module top (
	input clk,

	inout [14:0] 	DDR_addr,
	inout [2:0] 	DDR_ba,
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
	inout 			FIXED_IO_ps_srstb,

	output 			led
);
	// --- PARAMETERS ---------------------------------------

	//---DATA WIDTH---
	parameter WIDTH=16;

	parameter IS_FLOAT = 1;
	parameter EXP_BITS = 5;
	parameter FRAC_BITS = 10;

	//---Number of PEs in each systolic array---
	parameter ARR_WIDTH = 4;
	parameter ARR_HEIGHT = 4;

	//---Number of Systolic Arrays---
	parameter SYS_WIDTH = 64;
	parameter SYS_HEIGHT = 1;

	// -------------------------------------------------------

	//--- PS -> (DRAM) -> PL Matrix Data ---
	wire [31:0]	M_AHB_haddr;
	wire [2:0]	M_AHB_hburst;
	wire [3:0]	M_AHB_hprot;
	wire [31:0]	M_AHB_hrdata;
	wire 		M_AHB_hready;
	wire 		M_AHB_hresp;
	wire [2:0]	M_AHB_hsize;
	wire [1:0]	M_AHB_htrans;
	wire [31:0]	M_AHB_hwdata;
	wire 		M_AHB_hwrite;

	wire 		NDP_HREADY;

	//--- PS -> (DRAM) -> PL Control Signals ---
	wire [31:0]	M_AHB_1_haddr;
	wire [2:0]	M_AHB_1_hburst;
	wire [3:0]	M_AHB_1_hprot;
	wire [31:0]	M_AHB_1_hrdata;
	wire 		M_AHB_1_hready;
	wire 		M_AHB_1_hresp;
	wire [2:0]	M_AHB_1_hsize;
	wire [1:0]	M_AHB_1_htrans;
	wire [31:0]	M_AHB_1_hwdata;
	wire 		M_AHB_1_hwrite;

	wire 		m_ahb_hclk;
	//wire 		m_ahb_hclk_1;
	wire 		m_ahb_hmastlock;
	wire 		m_ahb_hmastlock_1;
	wire 		m_ahb_hresetn;
	// wire 	m_ahb_hresetn_1;

	wire [1:0] 	register_set_0_hresp;

	wire [1:0] 	register_set_1_hresp;
	wire [31:0]	register_set_1_reg0;
	wire [31:0]	register_set_1_reg1;
	wire [31:0]	register_set_1_reg2;

	system_wrapper usystem_wrapper (
		.DDR_addr(DDR_addr),
		.DDR_ba(DDR_ba),
		.DDR_cas_n(DDR_cas_n),
		.DDR_ck_n(DDR_ck_n),
		.DDR_ck_p(DDR_ck_p),
		.DDR_cke(DDR_cke),
		.DDR_cs_n(DDR_cs_n),
		.DDR_dm(DDR_dm),
		.DDR_dq(DDR_dq),
		.DDR_dqs_n(DDR_dqs_n),
		.DDR_dqs_p(DDR_dqs_p),
		.DDR_odt(DDR_odt),
		.DDR_ras_n(DDR_ras_n),
		.DDR_reset_n(DDR_reset_n),
		.DDR_we_n(DDR_we_n),

		.FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
		.FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
		.FIXED_IO_mio(FIXED_IO_mio),
		.FIXED_IO_ps_clk(FIXED_IO_ps_clk),
		.FIXED_IO_ps_porb(FIXED_IO_ps_porb),
		.FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

		.M_AHB_haddr(M_AHB_haddr),
		.M_AHB_hburst(M_AHB_hburst),
		.M_AHB_hprot(M_AHB_hprot),
		.M_AHB_hrdata(M_AHB_hrdata),
		.M_AHB_hready(M_AHB_hready & NDP_HREADY),
		.M_AHB_hresp(M_AHB_hresp),
		.M_AHB_hsize(M_AHB_hsize),
		.M_AHB_htrans(M_AHB_htrans),
		.M_AHB_hwdata(M_AHB_hwdata),
		.M_AHB_hwrite(M_AHB_hwrite),

		.M_AHB_1_haddr(M_AHB_1_haddr),
		.M_AHB_1_hburst(M_AHB_1_hburst),
		.M_AHB_1_hprot(M_AHB_1_hprot),
		.M_AHB_1_hrdata(M_AHB_1_hrdata),
		.M_AHB_1_hready(M_AHB_1_hready),
		.M_AHB_1_hresp(M_AHB_1_hresp),
		.M_AHB_1_hsize(M_AHB_1_hsize),
		.M_AHB_1_htrans(M_AHB_1_htrans),
		.M_AHB_1_hwdata(M_AHB_1_hwdata),
		.M_AHB_1_hwrite(M_AHB_1_hwrite),


		.m_ahb_hclk(m_ahb_hclk),
		//    .m_ahb_hclk_1(m_ahb_hclk_1),
		.m_ahb_hmastlock(m_ahb_hmastlock),
		.m_ahb_hmastlock_1(m_ahb_hmastlock_1),
		.m_ahb_hresetn(m_ahb_hresetn)
		//    .m_ahb_hresetn_1(m_ahb_hresetn_1)
	);

	//--- CONTROL SIGNALS ---
	assign M_AHB_1_hresp = (register_set_1_hresp == 2'b00) ? 1'b0 : 1'b1;
	signals_input signals_input_1 (
		// AHB SIGNALS
		.HCLK(m_ahb_hclk),
		.HRESETn(m_ahb_hresetn),
		.HSEL(1'b1),
		.HADDR(M_AHB_1_haddr),
		.HWRITE(M_AHB_1_hwrite),
		.HTRANS(M_AHB_1_htrans),
		.HSIZE(M_AHB_1_hsize),
		.HWDATA(M_AHB_1_hwdata),
		.HREADY(M_AHB_1_hready),
		.HREADYin(M_AHB_1_hready),
		.HRESP(register_set_1_hresp),
		.HRDATA(M_AHB_1_hrdata),

		// CONTROL SIGNALS
		.reset(register_set_1_reg0),
		.start(register_set_1_reg1),
		.finished(register_set_1_reg2),
	);

	//--- Matrix Data ---
	wire [31:0]		from_scratch_pad_HRDATA;
	wire			to_scratch_pad_wen;
	wire 			to_scratch_pad_en;
	wire [31:0] 	to_scratch_pad_wdata;
	wire [31:0]		to_scratch_pad_addr;

	wire [31:0]		write_M_AHB_hrdata;

	ahb_decoder ahb_decoder_1 (
		//---AHB -> DECODER ---
		.HRESETn ( m_ahb_hresetn ),
		.BIGEND ( 1'b0 ),
		.PORT1HCLK ( m_ahb_hclk ),
		.PORT1HSEL ( 1'b1 ),
		.PORT1HREADYIN ( M_AHB_hready & NDP_HREADY ),
		.PORT1HTRANS ( M_AHB_htrans ),
		.PORT1HSIZE ( M_AHB_hsize[1:0] ),
		.PORT1HWRITE ( M_AHB_hwrite ),
		.PORT1HWDATA ( M_AHB_hwdata ),
		.PORT1HRDATA ( M_AHB_hrdata ),
		.PORT1HADDR ( M_AHB_haddr ),
		.PORT1HREADYOUT ( M_AHB_hready ),
		.PORT1HRESP (register_set_0_hresp ),

		.from_scratch_pad_HRDATA (from_scratch_pad_HRDATA),
		//--- DECODER -> Scratch Pad ---
		.to_scratch_pad_en 		(to_scratch_pad_en),
		.to_scratch_pad_wen 	(to_scratch_pad_wen),
		.to_scratch_pad_addr	(to_scratch_pad_addr)
		.to_scratch_pad_wdata 	(to_scratch_pad_wdata),
	);

	wire [ARR_WIDTH*SYS_WIDTH*ARR_HEIGHT*SYS_HEIGHT*WIDTH-1:0] out_c;
	reg [31:0]		read_M_AHB_hrdata;

	NDP_core ndp_core (
		.scratch_pad_clk(m_ahb_hclk),
		.ndp_unit_clk(clk), 

		.reset_in		(register_set_1_reg0[0]),
		.start_in		(register_set_1_reg1[0]),
		.finished_in	(register_set_1_reg2[0]),

		.to_scratch_pad_en	(to_scratch_pad_en),
		.to_scratch_pad_wen	(to_scratch_pad_wen),
		.data_addr			(to_scratch_pad_addr),
		.data				(to_scratch_pad_wdata),
		
		.HREADY		(NDP_HREADY),			// Whether data is accepted by NDP core
		.HRDATA		(from_scratch_pad_HRDATA),

		.calc_done_flag	(led),
		.out_c			(out_c)
	);

	always @(posedge m_ahb_hclk) begin
		read_M_AHB_hrdata <= out_c[M_AHB_haddr[]]
	end 



endmodule