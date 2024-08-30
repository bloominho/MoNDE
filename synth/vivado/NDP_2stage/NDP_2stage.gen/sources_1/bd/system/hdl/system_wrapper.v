//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.1 (lin64) Build 3865809 Sun May  7 15:04:56 MDT 2023
//Date        : Mon Aug  5 17:18:41 2024
//Host        : owl running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FCLK_CLK0,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    M_AHB_haddr,
    M_AHB_hburst,
    M_AHB_hmastlock,
    M_AHB_hprot,
    M_AHB_hrdata,
    M_AHB_hready,
    M_AHB_hresp,
    M_AHB_hsize,
    M_AHB_htrans,
    M_AHB_hwdata,
    M_AHB_hwrite,
    M_AXIS_tdata,
    M_AXIS_tkeep,
    M_AXIS_tlast,
    M_AXIS_tready,
    M_AXIS_tvalid,
    NDP_in_a_debug,
    NDP_in_b_debug,
    S_AXIS_tdata,
    S_AXIS_tlast,
    S_AXIS_tready,
    S_AXIS_tvalid,
    peripheral_aresetn,
    probe10_0,
    probe11_0,
    probe12_0,
    probe13_0,
    probe2_0,
    probe3_0,
    probe4_0,
    probe5_0,
    probe6_0,
    probe7_0,
    probe8_0,
    probe9_0);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  output FCLK_CLK0;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [31:0]M_AHB_haddr;
  output [2:0]M_AHB_hburst;
  output M_AHB_hmastlock;
  output [3:0]M_AHB_hprot;
  input [31:0]M_AHB_hrdata;
  input M_AHB_hready;
  input M_AHB_hresp;
  output [2:0]M_AHB_hsize;
  output [1:0]M_AHB_htrans;
  output [31:0]M_AHB_hwdata;
  output M_AHB_hwrite;
  output [31:0]M_AXIS_tdata;
  output [3:0]M_AXIS_tkeep;
  output M_AXIS_tlast;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
  input [63:0]NDP_in_a_debug;
  input [1023:0]NDP_in_b_debug;
  input [31:0]S_AXIS_tdata;
  input S_AXIS_tlast;
  output S_AXIS_tready;
  input S_AXIS_tvalid;
  output [0:0]peripheral_aresetn;
  input [0:0]probe10_0;
  input [0:0]probe11_0;
  input [0:0]probe12_0;
  input [0:0]probe13_0;
  input [15:0]probe2_0;
  input [15:0]probe3_0;
  input [15:0]probe4_0;
  input [15:0]probe5_0;
  input [0:0]probe6_0;
  input [0:0]probe7_0;
  input [0:0]probe8_0;
  input [15:0]probe9_0;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FCLK_CLK0;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [31:0]M_AHB_haddr;
  wire [2:0]M_AHB_hburst;
  wire M_AHB_hmastlock;
  wire [3:0]M_AHB_hprot;
  wire [31:0]M_AHB_hrdata;
  wire M_AHB_hready;
  wire M_AHB_hresp;
  wire [2:0]M_AHB_hsize;
  wire [1:0]M_AHB_htrans;
  wire [31:0]M_AHB_hwdata;
  wire M_AHB_hwrite;
  wire [31:0]M_AXIS_tdata;
  wire [3:0]M_AXIS_tkeep;
  wire M_AXIS_tlast;
  wire M_AXIS_tready;
  wire M_AXIS_tvalid;
  wire [63:0]NDP_in_a_debug;
  wire [1023:0]NDP_in_b_debug;
  wire [31:0]S_AXIS_tdata;
  wire S_AXIS_tlast;
  wire S_AXIS_tready;
  wire S_AXIS_tvalid;
  wire [0:0]peripheral_aresetn;
  wire [0:0]probe10_0;
  wire [0:0]probe11_0;
  wire [0:0]probe12_0;
  wire [0:0]probe13_0;
  wire [15:0]probe2_0;
  wire [15:0]probe3_0;
  wire [15:0]probe4_0;
  wire [15:0]probe5_0;
  wire [0:0]probe6_0;
  wire [0:0]probe7_0;
  wire [0:0]probe8_0;
  wire [15:0]probe9_0;

  system system_i
       (.DDR_addr(DDR_addr),
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
        .FCLK_CLK0(FCLK_CLK0),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M_AHB_haddr(M_AHB_haddr),
        .M_AHB_hburst(M_AHB_hburst),
        .M_AHB_hmastlock(M_AHB_hmastlock),
        .M_AHB_hprot(M_AHB_hprot),
        .M_AHB_hrdata(M_AHB_hrdata),
        .M_AHB_hready(M_AHB_hready),
        .M_AHB_hresp(M_AHB_hresp),
        .M_AHB_hsize(M_AHB_hsize),
        .M_AHB_htrans(M_AHB_htrans),
        .M_AHB_hwdata(M_AHB_hwdata),
        .M_AHB_hwrite(M_AHB_hwrite),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tkeep(M_AXIS_tkeep),
        .M_AXIS_tlast(M_AXIS_tlast),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .NDP_in_a_debug(NDP_in_a_debug),
        .NDP_in_b_debug(NDP_in_b_debug),
        .S_AXIS_tdata(S_AXIS_tdata),
        .S_AXIS_tlast(S_AXIS_tlast),
        .S_AXIS_tready(S_AXIS_tready),
        .S_AXIS_tvalid(S_AXIS_tvalid),
        .peripheral_aresetn(peripheral_aresetn),
        .probe10_0(probe10_0),
        .probe11_0(probe11_0),
        .probe12_0(probe12_0),
        .probe13_0(probe13_0),
        .probe2_0(probe2_0),
        .probe3_0(probe3_0),
        .probe4_0(probe4_0),
        .probe5_0(probe5_0),
        .probe6_0(probe6_0),
        .probe7_0(probe7_0),
        .probe8_0(probe8_0),
        .probe9_0(probe9_0));
endmodule
