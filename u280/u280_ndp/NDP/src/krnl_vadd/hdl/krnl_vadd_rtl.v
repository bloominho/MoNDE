/**
* Copyright (C) 2019-2021 Xilinx, Inc
*
* Licensed under the Apache License, Version 2.0 (the "License"). You may
* not use this file except in compliance with the License. A copy of the
* License is located at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations
* under the License.
*/

///////////////////////////////////////////////////////////////////////////////
// Description: This is a wrapper of module "krnl_vadd_rtl_int"
///////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps 

module krnl_vadd_rtl #(
  parameter integer LP_NUM_READ_CHANNELS  = 1,
  parameter integer LP_LENGTH_WIDTH       = 32,
  parameter integer LP_DW_BYTES           = C_M_AXI_GMEM_DATA_WIDTH/8,
  parameter integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256,
  parameter integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN),
  parameter integer LP_RD_MAX_OUTSTANDING = 3,
  parameter integer LP_RD_FIFO_DEPTH      = LP_AXI_BURST_LEN*(LP_RD_MAX_OUTSTANDING + 1),
  parameter integer LP_WR_FIFO_DEPTH      = LP_AXI_BURST_LEN,

  parameter integer  C_M_AXI_GMEM_ID_WIDTH = 1,
  parameter integer  C_M_AXI_GMEM_ADDR_WIDTH = 64,
  parameter integer  C_M_AXI_GMEM_DATA_WIDTH = 32,

  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH = 10
) (
  // System signals
    input  wire  ap_clk,
    input  wire  ap_rst_n,

  // AXI4 master interface - DATA 0 ~ 31
    // PORT 0 ~ 1  : PLRAM
    // PORT 2 ~ 33 : HBM

    // PORT 0
    output wire                                 m_axi_gmem_0_AWVALID,
    input  wire                                 m_axi_gmem_0_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_0_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_0_AWID,
    output wire [7:0]                           m_axi_gmem_0_AWLEN,
    output wire [2:0]                           m_axi_gmem_0_AWSIZE,
    output wire [1:0]                           m_axi_gmem_0_AWBURST,
    output wire [1:0]                           m_axi_gmem_0_AWLOCK,
    output wire [3:0]                           m_axi_gmem_0_AWCACHE,
    output wire [2:0]                           m_axi_gmem_0_AWPROT,
    output wire [3:0]                           m_axi_gmem_0_AWQOS,
    output wire [3:0]                           m_axi_gmem_0_AWREGION,
    output wire                                 m_axi_gmem_0_WVALID,
    input  wire                                 m_axi_gmem_0_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_0_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_0_WSTRB,
    output wire                                 m_axi_gmem_0_WLAST,
    output wire                                 m_axi_gmem_0_ARVALID,
    input  wire                                 m_axi_gmem_0_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_0_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_0_ARID,
    output wire [7:0]                           m_axi_gmem_0_ARLEN,
    output wire [2:0]                           m_axi_gmem_0_ARSIZE,
    output wire [1:0]                           m_axi_gmem_0_ARBURST,
    output wire [1:0]                           m_axi_gmem_0_ARLOCK,
    output wire [3:0]                           m_axi_gmem_0_ARCACHE,
    output wire [2:0]                           m_axi_gmem_0_ARPROT,
    output wire [3:0]                           m_axi_gmem_0_ARQOS,
    output wire [3:0]                           m_axi_gmem_0_ARREGION,
    input  wire                                 m_axi_gmem_0_RVALID,
    output wire                                 m_axi_gmem_0_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_0_RDATA,
    input  wire                                 m_axi_gmem_0_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_0_RID,
    input  wire [1:0]                           m_axi_gmem_0_RRESP,
    input  wire                                 m_axi_gmem_0_BVALID,
    output wire                                 m_axi_gmem_0_BREADY,
    input  wire [1:0]                           m_axi_gmem_0_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_0_BID,
    
    output wire                                 m_axi_gmem_1_AWVALID,
    input  wire                                 m_axi_gmem_1_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_1_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_1_AWID,
    output wire [7:0]                           m_axi_gmem_1_AWLEN,
    output wire [2:0]                           m_axi_gmem_1_AWSIZE,
    output wire [1:0]                           m_axi_gmem_1_AWBURST,
    output wire [1:0]                           m_axi_gmem_1_AWLOCK,
    output wire [3:0]                           m_axi_gmem_1_AWCACHE,
    output wire [2:0]                           m_axi_gmem_1_AWPROT,
    output wire [3:0]                           m_axi_gmem_1_AWQOS,
    output wire [3:0]                           m_axi_gmem_1_AWREGION,
    output wire                                 m_axi_gmem_1_WVALID,
    input  wire                                 m_axi_gmem_1_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_1_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_1_WSTRB,
    output wire                                 m_axi_gmem_1_WLAST,
    output wire                                 m_axi_gmem_1_ARVALID,
    input  wire                                 m_axi_gmem_1_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_1_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_1_ARID,
    output wire [7:0]                           m_axi_gmem_1_ARLEN,
    output wire [2:0]                           m_axi_gmem_1_ARSIZE,
    output wire [1:0]                           m_axi_gmem_1_ARBURST,
    output wire [1:0]                           m_axi_gmem_1_ARLOCK,
    output wire [3:0]                           m_axi_gmem_1_ARCACHE,
    output wire [2:0]                           m_axi_gmem_1_ARPROT,
    output wire [3:0]                           m_axi_gmem_1_ARQOS,
    output wire [3:0]                           m_axi_gmem_1_ARREGION,
    input  wire                                 m_axi_gmem_1_RVALID,
    output wire                                 m_axi_gmem_1_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_1_RDATA,
    input  wire                                 m_axi_gmem_1_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_1_RID,
    input  wire [1:0]                           m_axi_gmem_1_RRESP,
    input  wire                                 m_axi_gmem_1_BVALID,
    output wire                                 m_axi_gmem_1_BREADY,
    input  wire [1:0]                           m_axi_gmem_1_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_1_BID,
    
    output wire                                 m_axi_gmem_2_AWVALID,
    input  wire                                 m_axi_gmem_2_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_2_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_2_AWID,
    output wire [7:0]                           m_axi_gmem_2_AWLEN,
    output wire [2:0]                           m_axi_gmem_2_AWSIZE,
    output wire [1:0]                           m_axi_gmem_2_AWBURST,
    output wire [1:0]                           m_axi_gmem_2_AWLOCK,
    output wire [3:0]                           m_axi_gmem_2_AWCACHE,
    output wire [2:0]                           m_axi_gmem_2_AWPROT,
    output wire [3:0]                           m_axi_gmem_2_AWQOS,
    output wire [3:0]                           m_axi_gmem_2_AWREGION,
    output wire                                 m_axi_gmem_2_WVALID,
    input  wire                                 m_axi_gmem_2_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_2_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_2_WSTRB,
    output wire                                 m_axi_gmem_2_WLAST,
    output wire                                 m_axi_gmem_2_ARVALID,
    input  wire                                 m_axi_gmem_2_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_2_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_2_ARID,
    output wire [7:0]                           m_axi_gmem_2_ARLEN,
    output wire [2:0]                           m_axi_gmem_2_ARSIZE,
    output wire [1:0]                           m_axi_gmem_2_ARBURST,
    output wire [1:0]                           m_axi_gmem_2_ARLOCK,
    output wire [3:0]                           m_axi_gmem_2_ARCACHE,
    output wire [2:0]                           m_axi_gmem_2_ARPROT,
    output wire [3:0]                           m_axi_gmem_2_ARQOS,
    output wire [3:0]                           m_axi_gmem_2_ARREGION,
    input  wire                                 m_axi_gmem_2_RVALID,
    output wire                                 m_axi_gmem_2_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_2_RDATA,
    input  wire                                 m_axi_gmem_2_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_2_RID,
    input  wire [1:0]                           m_axi_gmem_2_RRESP,
    input  wire                                 m_axi_gmem_2_BVALID,
    output wire                                 m_axi_gmem_2_BREADY,
    input  wire [1:0]                           m_axi_gmem_2_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_2_BID,
    
    output wire                                 m_axi_gmem_3_AWVALID,
    input  wire                                 m_axi_gmem_3_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_3_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_3_AWID,
    output wire [7:0]                           m_axi_gmem_3_AWLEN,
    output wire [2:0]                           m_axi_gmem_3_AWSIZE,
    output wire [1:0]                           m_axi_gmem_3_AWBURST,
    output wire [1:0]                           m_axi_gmem_3_AWLOCK,
    output wire [3:0]                           m_axi_gmem_3_AWCACHE,
    output wire [2:0]                           m_axi_gmem_3_AWPROT,
    output wire [3:0]                           m_axi_gmem_3_AWQOS,
    output wire [3:0]                           m_axi_gmem_3_AWREGION,
    output wire                                 m_axi_gmem_3_WVALID,
    input  wire                                 m_axi_gmem_3_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_3_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_3_WSTRB,
    output wire                                 m_axi_gmem_3_WLAST,
    output wire                                 m_axi_gmem_3_ARVALID,
    input  wire                                 m_axi_gmem_3_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_3_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_3_ARID,
    output wire [7:0]                           m_axi_gmem_3_ARLEN,
    output wire [2:0]                           m_axi_gmem_3_ARSIZE,
    output wire [1:0]                           m_axi_gmem_3_ARBURST,
    output wire [1:0]                           m_axi_gmem_3_ARLOCK,
    output wire [3:0]                           m_axi_gmem_3_ARCACHE,
    output wire [2:0]                           m_axi_gmem_3_ARPROT,
    output wire [3:0]                           m_axi_gmem_3_ARQOS,
    output wire [3:0]                           m_axi_gmem_3_ARREGION,
    input  wire                                 m_axi_gmem_3_RVALID,
    output wire                                 m_axi_gmem_3_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_3_RDATA,
    input  wire                                 m_axi_gmem_3_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_3_RID,
    input  wire [1:0]                           m_axi_gmem_3_RRESP,
    input  wire                                 m_axi_gmem_3_BVALID,
    output wire                                 m_axi_gmem_3_BREADY,
    input  wire [1:0]                           m_axi_gmem_3_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_3_BID,
    
    output wire                                 m_axi_gmem_4_AWVALID,
    input  wire                                 m_axi_gmem_4_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_4_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_4_AWID,
    output wire [7:0]                           m_axi_gmem_4_AWLEN,
    output wire [2:0]                           m_axi_gmem_4_AWSIZE,
    output wire [1:0]                           m_axi_gmem_4_AWBURST,
    output wire [1:0]                           m_axi_gmem_4_AWLOCK,
    output wire [3:0]                           m_axi_gmem_4_AWCACHE,
    output wire [2:0]                           m_axi_gmem_4_AWPROT,
    output wire [3:0]                           m_axi_gmem_4_AWQOS,
    output wire [3:0]                           m_axi_gmem_4_AWREGION,
    output wire                                 m_axi_gmem_4_WVALID,
    input  wire                                 m_axi_gmem_4_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_4_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_4_WSTRB,
    output wire                                 m_axi_gmem_4_WLAST,
    output wire                                 m_axi_gmem_4_ARVALID,
    input  wire                                 m_axi_gmem_4_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_4_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_4_ARID,
    output wire [7:0]                           m_axi_gmem_4_ARLEN,
    output wire [2:0]                           m_axi_gmem_4_ARSIZE,
    output wire [1:0]                           m_axi_gmem_4_ARBURST,
    output wire [1:0]                           m_axi_gmem_4_ARLOCK,
    output wire [3:0]                           m_axi_gmem_4_ARCACHE,
    output wire [2:0]                           m_axi_gmem_4_ARPROT,
    output wire [3:0]                           m_axi_gmem_4_ARQOS,
    output wire [3:0]                           m_axi_gmem_4_ARREGION,
    input  wire                                 m_axi_gmem_4_RVALID,
    output wire                                 m_axi_gmem_4_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_4_RDATA,
    input  wire                                 m_axi_gmem_4_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_4_RID,
    input  wire [1:0]                           m_axi_gmem_4_RRESP,
    input  wire                                 m_axi_gmem_4_BVALID,
    output wire                                 m_axi_gmem_4_BREADY,
    input  wire [1:0]                           m_axi_gmem_4_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_4_BID,
    
    output wire                                 m_axi_gmem_5_AWVALID,
    input  wire                                 m_axi_gmem_5_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_5_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_5_AWID,
    output wire [7:0]                           m_axi_gmem_5_AWLEN,
    output wire [2:0]                           m_axi_gmem_5_AWSIZE,
    output wire [1:0]                           m_axi_gmem_5_AWBURST,
    output wire [1:0]                           m_axi_gmem_5_AWLOCK,
    output wire [3:0]                           m_axi_gmem_5_AWCACHE,
    output wire [2:0]                           m_axi_gmem_5_AWPROT,
    output wire [3:0]                           m_axi_gmem_5_AWQOS,
    output wire [3:0]                           m_axi_gmem_5_AWREGION,
    output wire                                 m_axi_gmem_5_WVALID,
    input  wire                                 m_axi_gmem_5_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_5_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_5_WSTRB,
    output wire                                 m_axi_gmem_5_WLAST,
    output wire                                 m_axi_gmem_5_ARVALID,
    input  wire                                 m_axi_gmem_5_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_5_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_5_ARID,
    output wire [7:0]                           m_axi_gmem_5_ARLEN,
    output wire [2:0]                           m_axi_gmem_5_ARSIZE,
    output wire [1:0]                           m_axi_gmem_5_ARBURST,
    output wire [1:0]                           m_axi_gmem_5_ARLOCK,
    output wire [3:0]                           m_axi_gmem_5_ARCACHE,
    output wire [2:0]                           m_axi_gmem_5_ARPROT,
    output wire [3:0]                           m_axi_gmem_5_ARQOS,
    output wire [3:0]                           m_axi_gmem_5_ARREGION,
    input  wire                                 m_axi_gmem_5_RVALID,
    output wire                                 m_axi_gmem_5_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_5_RDATA,
    input  wire                                 m_axi_gmem_5_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_5_RID,
    input  wire [1:0]                           m_axi_gmem_5_RRESP,
    input  wire                                 m_axi_gmem_5_BVALID,
    output wire                                 m_axi_gmem_5_BREADY,
    input  wire [1:0]                           m_axi_gmem_5_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_5_BID,
    
    output wire                                 m_axi_gmem_6_AWVALID,
    input  wire                                 m_axi_gmem_6_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_6_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_6_AWID,
    output wire [7:0]                           m_axi_gmem_6_AWLEN,
    output wire [2:0]                           m_axi_gmem_6_AWSIZE,
    output wire [1:0]                           m_axi_gmem_6_AWBURST,
    output wire [1:0]                           m_axi_gmem_6_AWLOCK,
    output wire [3:0]                           m_axi_gmem_6_AWCACHE,
    output wire [2:0]                           m_axi_gmem_6_AWPROT,
    output wire [3:0]                           m_axi_gmem_6_AWQOS,
    output wire [3:0]                           m_axi_gmem_6_AWREGION,
    output wire                                 m_axi_gmem_6_WVALID,
    input  wire                                 m_axi_gmem_6_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_6_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_6_WSTRB,
    output wire                                 m_axi_gmem_6_WLAST,
    output wire                                 m_axi_gmem_6_ARVALID,
    input  wire                                 m_axi_gmem_6_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_6_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_6_ARID,
    output wire [7:0]                           m_axi_gmem_6_ARLEN,
    output wire [2:0]                           m_axi_gmem_6_ARSIZE,
    output wire [1:0]                           m_axi_gmem_6_ARBURST,
    output wire [1:0]                           m_axi_gmem_6_ARLOCK,
    output wire [3:0]                           m_axi_gmem_6_ARCACHE,
    output wire [2:0]                           m_axi_gmem_6_ARPROT,
    output wire [3:0]                           m_axi_gmem_6_ARQOS,
    output wire [3:0]                           m_axi_gmem_6_ARREGION,
    input  wire                                 m_axi_gmem_6_RVALID,
    output wire                                 m_axi_gmem_6_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_6_RDATA,
    input  wire                                 m_axi_gmem_6_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_6_RID,
    input  wire [1:0]                           m_axi_gmem_6_RRESP,
    input  wire                                 m_axi_gmem_6_BVALID,
    output wire                                 m_axi_gmem_6_BREADY,
    input  wire [1:0]                           m_axi_gmem_6_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_6_BID,
    
    output wire                                 m_axi_gmem_7_AWVALID,
    input  wire                                 m_axi_gmem_7_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_7_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_7_AWID,
    output wire [7:0]                           m_axi_gmem_7_AWLEN,
    output wire [2:0]                           m_axi_gmem_7_AWSIZE,
    output wire [1:0]                           m_axi_gmem_7_AWBURST,
    output wire [1:0]                           m_axi_gmem_7_AWLOCK,
    output wire [3:0]                           m_axi_gmem_7_AWCACHE,
    output wire [2:0]                           m_axi_gmem_7_AWPROT,
    output wire [3:0]                           m_axi_gmem_7_AWQOS,
    output wire [3:0]                           m_axi_gmem_7_AWREGION,
    output wire                                 m_axi_gmem_7_WVALID,
    input  wire                                 m_axi_gmem_7_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_7_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_7_WSTRB,
    output wire                                 m_axi_gmem_7_WLAST,
    output wire                                 m_axi_gmem_7_ARVALID,
    input  wire                                 m_axi_gmem_7_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_7_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_7_ARID,
    output wire [7:0]                           m_axi_gmem_7_ARLEN,
    output wire [2:0]                           m_axi_gmem_7_ARSIZE,
    output wire [1:0]                           m_axi_gmem_7_ARBURST,
    output wire [1:0]                           m_axi_gmem_7_ARLOCK,
    output wire [3:0]                           m_axi_gmem_7_ARCACHE,
    output wire [2:0]                           m_axi_gmem_7_ARPROT,
    output wire [3:0]                           m_axi_gmem_7_ARQOS,
    output wire [3:0]                           m_axi_gmem_7_ARREGION,
    input  wire                                 m_axi_gmem_7_RVALID,
    output wire                                 m_axi_gmem_7_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_7_RDATA,
    input  wire                                 m_axi_gmem_7_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_7_RID,
    input  wire [1:0]                           m_axi_gmem_7_RRESP,
    input  wire                                 m_axi_gmem_7_BVALID,
    output wire                                 m_axi_gmem_7_BREADY,
    input  wire [1:0]                           m_axi_gmem_7_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_7_BID,
    
    output wire                                 m_axi_gmem_8_AWVALID,
    input  wire                                 m_axi_gmem_8_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_8_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_8_AWID,
    output wire [7:0]                           m_axi_gmem_8_AWLEN,
    output wire [2:0]                           m_axi_gmem_8_AWSIZE,
    output wire [1:0]                           m_axi_gmem_8_AWBURST,
    output wire [1:0]                           m_axi_gmem_8_AWLOCK,
    output wire [3:0]                           m_axi_gmem_8_AWCACHE,
    output wire [2:0]                           m_axi_gmem_8_AWPROT,
    output wire [3:0]                           m_axi_gmem_8_AWQOS,
    output wire [3:0]                           m_axi_gmem_8_AWREGION,
    output wire                                 m_axi_gmem_8_WVALID,
    input  wire                                 m_axi_gmem_8_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_8_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_8_WSTRB,
    output wire                                 m_axi_gmem_8_WLAST,
    output wire                                 m_axi_gmem_8_ARVALID,
    input  wire                                 m_axi_gmem_8_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_8_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_8_ARID,
    output wire [7:0]                           m_axi_gmem_8_ARLEN,
    output wire [2:0]                           m_axi_gmem_8_ARSIZE,
    output wire [1:0]                           m_axi_gmem_8_ARBURST,
    output wire [1:0]                           m_axi_gmem_8_ARLOCK,
    output wire [3:0]                           m_axi_gmem_8_ARCACHE,
    output wire [2:0]                           m_axi_gmem_8_ARPROT,
    output wire [3:0]                           m_axi_gmem_8_ARQOS,
    output wire [3:0]                           m_axi_gmem_8_ARREGION,
    input  wire                                 m_axi_gmem_8_RVALID,
    output wire                                 m_axi_gmem_8_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_8_RDATA,
    input  wire                                 m_axi_gmem_8_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_8_RID,
    input  wire [1:0]                           m_axi_gmem_8_RRESP,
    input  wire                                 m_axi_gmem_8_BVALID,
    output wire                                 m_axi_gmem_8_BREADY,
    input  wire [1:0]                           m_axi_gmem_8_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_8_BID,
    
    output wire                                 m_axi_gmem_9_AWVALID,
    input  wire                                 m_axi_gmem_9_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_9_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_9_AWID,
    output wire [7:0]                           m_axi_gmem_9_AWLEN,
    output wire [2:0]                           m_axi_gmem_9_AWSIZE,
    output wire [1:0]                           m_axi_gmem_9_AWBURST,
    output wire [1:0]                           m_axi_gmem_9_AWLOCK,
    output wire [3:0]                           m_axi_gmem_9_AWCACHE,
    output wire [2:0]                           m_axi_gmem_9_AWPROT,
    output wire [3:0]                           m_axi_gmem_9_AWQOS,
    output wire [3:0]                           m_axi_gmem_9_AWREGION,
    output wire                                 m_axi_gmem_9_WVALID,
    input  wire                                 m_axi_gmem_9_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_9_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_9_WSTRB,
    output wire                                 m_axi_gmem_9_WLAST,
    output wire                                 m_axi_gmem_9_ARVALID,
    input  wire                                 m_axi_gmem_9_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_9_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_9_ARID,
    output wire [7:0]                           m_axi_gmem_9_ARLEN,
    output wire [2:0]                           m_axi_gmem_9_ARSIZE,
    output wire [1:0]                           m_axi_gmem_9_ARBURST,
    output wire [1:0]                           m_axi_gmem_9_ARLOCK,
    output wire [3:0]                           m_axi_gmem_9_ARCACHE,
    output wire [2:0]                           m_axi_gmem_9_ARPROT,
    output wire [3:0]                           m_axi_gmem_9_ARQOS,
    output wire [3:0]                           m_axi_gmem_9_ARREGION,
    input  wire                                 m_axi_gmem_9_RVALID,
    output wire                                 m_axi_gmem_9_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_9_RDATA,
    input  wire                                 m_axi_gmem_9_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_9_RID,
    input  wire [1:0]                           m_axi_gmem_9_RRESP,
    input  wire                                 m_axi_gmem_9_BVALID,
    output wire                                 m_axi_gmem_9_BREADY,
    input  wire [1:0]                           m_axi_gmem_9_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_9_BID,
    
    output wire                                 m_axi_gmem_10_AWVALID,
    input  wire                                 m_axi_gmem_10_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_10_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_10_AWID,
    output wire [7:0]                           m_axi_gmem_10_AWLEN,
    output wire [2:0]                           m_axi_gmem_10_AWSIZE,
    output wire [1:0]                           m_axi_gmem_10_AWBURST,
    output wire [1:0]                           m_axi_gmem_10_AWLOCK,
    output wire [3:0]                           m_axi_gmem_10_AWCACHE,
    output wire [2:0]                           m_axi_gmem_10_AWPROT,
    output wire [3:0]                           m_axi_gmem_10_AWQOS,
    output wire [3:0]                           m_axi_gmem_10_AWREGION,
    output wire                                 m_axi_gmem_10_WVALID,
    input  wire                                 m_axi_gmem_10_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_10_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_10_WSTRB,
    output wire                                 m_axi_gmem_10_WLAST,
    output wire                                 m_axi_gmem_10_ARVALID,
    input  wire                                 m_axi_gmem_10_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_10_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_10_ARID,
    output wire [7:0]                           m_axi_gmem_10_ARLEN,
    output wire [2:0]                           m_axi_gmem_10_ARSIZE,
    output wire [1:0]                           m_axi_gmem_10_ARBURST,
    output wire [1:0]                           m_axi_gmem_10_ARLOCK,
    output wire [3:0]                           m_axi_gmem_10_ARCACHE,
    output wire [2:0]                           m_axi_gmem_10_ARPROT,
    output wire [3:0]                           m_axi_gmem_10_ARQOS,
    output wire [3:0]                           m_axi_gmem_10_ARREGION,
    input  wire                                 m_axi_gmem_10_RVALID,
    output wire                                 m_axi_gmem_10_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_10_RDATA,
    input  wire                                 m_axi_gmem_10_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_10_RID,
    input  wire [1:0]                           m_axi_gmem_10_RRESP,
    input  wire                                 m_axi_gmem_10_BVALID,
    output wire                                 m_axi_gmem_10_BREADY,
    input  wire [1:0]                           m_axi_gmem_10_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_10_BID,
    
    output wire                                 m_axi_gmem_11_AWVALID,
    input  wire                                 m_axi_gmem_11_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_11_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_11_AWID,
    output wire [7:0]                           m_axi_gmem_11_AWLEN,
    output wire [2:0]                           m_axi_gmem_11_AWSIZE,
    output wire [1:0]                           m_axi_gmem_11_AWBURST,
    output wire [1:0]                           m_axi_gmem_11_AWLOCK,
    output wire [3:0]                           m_axi_gmem_11_AWCACHE,
    output wire [2:0]                           m_axi_gmem_11_AWPROT,
    output wire [3:0]                           m_axi_gmem_11_AWQOS,
    output wire [3:0]                           m_axi_gmem_11_AWREGION,
    output wire                                 m_axi_gmem_11_WVALID,
    input  wire                                 m_axi_gmem_11_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_11_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_11_WSTRB,
    output wire                                 m_axi_gmem_11_WLAST,
    output wire                                 m_axi_gmem_11_ARVALID,
    input  wire                                 m_axi_gmem_11_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_11_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_11_ARID,
    output wire [7:0]                           m_axi_gmem_11_ARLEN,
    output wire [2:0]                           m_axi_gmem_11_ARSIZE,
    output wire [1:0]                           m_axi_gmem_11_ARBURST,
    output wire [1:0]                           m_axi_gmem_11_ARLOCK,
    output wire [3:0]                           m_axi_gmem_11_ARCACHE,
    output wire [2:0]                           m_axi_gmem_11_ARPROT,
    output wire [3:0]                           m_axi_gmem_11_ARQOS,
    output wire [3:0]                           m_axi_gmem_11_ARREGION,
    input  wire                                 m_axi_gmem_11_RVALID,
    output wire                                 m_axi_gmem_11_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_11_RDATA,
    input  wire                                 m_axi_gmem_11_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_11_RID,
    input  wire [1:0]                           m_axi_gmem_11_RRESP,
    input  wire                                 m_axi_gmem_11_BVALID,
    output wire                                 m_axi_gmem_11_BREADY,
    input  wire [1:0]                           m_axi_gmem_11_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_11_BID,
    
    output wire                                 m_axi_gmem_12_AWVALID,
    input  wire                                 m_axi_gmem_12_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_12_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_12_AWID,
    output wire [7:0]                           m_axi_gmem_12_AWLEN,
    output wire [2:0]                           m_axi_gmem_12_AWSIZE,
    output wire [1:0]                           m_axi_gmem_12_AWBURST,
    output wire [1:0]                           m_axi_gmem_12_AWLOCK,
    output wire [3:0]                           m_axi_gmem_12_AWCACHE,
    output wire [2:0]                           m_axi_gmem_12_AWPROT,
    output wire [3:0]                           m_axi_gmem_12_AWQOS,
    output wire [3:0]                           m_axi_gmem_12_AWREGION,
    output wire                                 m_axi_gmem_12_WVALID,
    input  wire                                 m_axi_gmem_12_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_12_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_12_WSTRB,
    output wire                                 m_axi_gmem_12_WLAST,
    output wire                                 m_axi_gmem_12_ARVALID,
    input  wire                                 m_axi_gmem_12_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_12_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_12_ARID,
    output wire [7:0]                           m_axi_gmem_12_ARLEN,
    output wire [2:0]                           m_axi_gmem_12_ARSIZE,
    output wire [1:0]                           m_axi_gmem_12_ARBURST,
    output wire [1:0]                           m_axi_gmem_12_ARLOCK,
    output wire [3:0]                           m_axi_gmem_12_ARCACHE,
    output wire [2:0]                           m_axi_gmem_12_ARPROT,
    output wire [3:0]                           m_axi_gmem_12_ARQOS,
    output wire [3:0]                           m_axi_gmem_12_ARREGION,
    input  wire                                 m_axi_gmem_12_RVALID,
    output wire                                 m_axi_gmem_12_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_12_RDATA,
    input  wire                                 m_axi_gmem_12_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_12_RID,
    input  wire [1:0]                           m_axi_gmem_12_RRESP,
    input  wire                                 m_axi_gmem_12_BVALID,
    output wire                                 m_axi_gmem_12_BREADY,
    input  wire [1:0]                           m_axi_gmem_12_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_12_BID,
    
    output wire                                 m_axi_gmem_13_AWVALID,
    input  wire                                 m_axi_gmem_13_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_13_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_13_AWID,
    output wire [7:0]                           m_axi_gmem_13_AWLEN,
    output wire [2:0]                           m_axi_gmem_13_AWSIZE,
    output wire [1:0]                           m_axi_gmem_13_AWBURST,
    output wire [1:0]                           m_axi_gmem_13_AWLOCK,
    output wire [3:0]                           m_axi_gmem_13_AWCACHE,
    output wire [2:0]                           m_axi_gmem_13_AWPROT,
    output wire [3:0]                           m_axi_gmem_13_AWQOS,
    output wire [3:0]                           m_axi_gmem_13_AWREGION,
    output wire                                 m_axi_gmem_13_WVALID,
    input  wire                                 m_axi_gmem_13_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_13_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_13_WSTRB,
    output wire                                 m_axi_gmem_13_WLAST,
    output wire                                 m_axi_gmem_13_ARVALID,
    input  wire                                 m_axi_gmem_13_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_13_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_13_ARID,
    output wire [7:0]                           m_axi_gmem_13_ARLEN,
    output wire [2:0]                           m_axi_gmem_13_ARSIZE,
    output wire [1:0]                           m_axi_gmem_13_ARBURST,
    output wire [1:0]                           m_axi_gmem_13_ARLOCK,
    output wire [3:0]                           m_axi_gmem_13_ARCACHE,
    output wire [2:0]                           m_axi_gmem_13_ARPROT,
    output wire [3:0]                           m_axi_gmem_13_ARQOS,
    output wire [3:0]                           m_axi_gmem_13_ARREGION,
    input  wire                                 m_axi_gmem_13_RVALID,
    output wire                                 m_axi_gmem_13_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_13_RDATA,
    input  wire                                 m_axi_gmem_13_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_13_RID,
    input  wire [1:0]                           m_axi_gmem_13_RRESP,
    input  wire                                 m_axi_gmem_13_BVALID,
    output wire                                 m_axi_gmem_13_BREADY,
    input  wire [1:0]                           m_axi_gmem_13_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_13_BID,
    
    output wire                                 m_axi_gmem_14_AWVALID,
    input  wire                                 m_axi_gmem_14_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_14_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_14_AWID,
    output wire [7:0]                           m_axi_gmem_14_AWLEN,
    output wire [2:0]                           m_axi_gmem_14_AWSIZE,
    output wire [1:0]                           m_axi_gmem_14_AWBURST,
    output wire [1:0]                           m_axi_gmem_14_AWLOCK,
    output wire [3:0]                           m_axi_gmem_14_AWCACHE,
    output wire [2:0]                           m_axi_gmem_14_AWPROT,
    output wire [3:0]                           m_axi_gmem_14_AWQOS,
    output wire [3:0]                           m_axi_gmem_14_AWREGION,
    output wire                                 m_axi_gmem_14_WVALID,
    input  wire                                 m_axi_gmem_14_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_14_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_14_WSTRB,
    output wire                                 m_axi_gmem_14_WLAST,
    output wire                                 m_axi_gmem_14_ARVALID,
    input  wire                                 m_axi_gmem_14_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_14_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_14_ARID,
    output wire [7:0]                           m_axi_gmem_14_ARLEN,
    output wire [2:0]                           m_axi_gmem_14_ARSIZE,
    output wire [1:0]                           m_axi_gmem_14_ARBURST,
    output wire [1:0]                           m_axi_gmem_14_ARLOCK,
    output wire [3:0]                           m_axi_gmem_14_ARCACHE,
    output wire [2:0]                           m_axi_gmem_14_ARPROT,
    output wire [3:0]                           m_axi_gmem_14_ARQOS,
    output wire [3:0]                           m_axi_gmem_14_ARREGION,
    input  wire                                 m_axi_gmem_14_RVALID,
    output wire                                 m_axi_gmem_14_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_14_RDATA,
    input  wire                                 m_axi_gmem_14_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_14_RID,
    input  wire [1:0]                           m_axi_gmem_14_RRESP,
    input  wire                                 m_axi_gmem_14_BVALID,
    output wire                                 m_axi_gmem_14_BREADY,
    input  wire [1:0]                           m_axi_gmem_14_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_14_BID,
    
    output wire                                 m_axi_gmem_15_AWVALID,
    input  wire                                 m_axi_gmem_15_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_15_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_15_AWID,
    output wire [7:0]                           m_axi_gmem_15_AWLEN,
    output wire [2:0]                           m_axi_gmem_15_AWSIZE,
    output wire [1:0]                           m_axi_gmem_15_AWBURST,
    output wire [1:0]                           m_axi_gmem_15_AWLOCK,
    output wire [3:0]                           m_axi_gmem_15_AWCACHE,
    output wire [2:0]                           m_axi_gmem_15_AWPROT,
    output wire [3:0]                           m_axi_gmem_15_AWQOS,
    output wire [3:0]                           m_axi_gmem_15_AWREGION,
    output wire                                 m_axi_gmem_15_WVALID,
    input  wire                                 m_axi_gmem_15_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_15_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_15_WSTRB,
    output wire                                 m_axi_gmem_15_WLAST,
    output wire                                 m_axi_gmem_15_ARVALID,
    input  wire                                 m_axi_gmem_15_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_15_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_15_ARID,
    output wire [7:0]                           m_axi_gmem_15_ARLEN,
    output wire [2:0]                           m_axi_gmem_15_ARSIZE,
    output wire [1:0]                           m_axi_gmem_15_ARBURST,
    output wire [1:0]                           m_axi_gmem_15_ARLOCK,
    output wire [3:0]                           m_axi_gmem_15_ARCACHE,
    output wire [2:0]                           m_axi_gmem_15_ARPROT,
    output wire [3:0]                           m_axi_gmem_15_ARQOS,
    output wire [3:0]                           m_axi_gmem_15_ARREGION,
    input  wire                                 m_axi_gmem_15_RVALID,
    output wire                                 m_axi_gmem_15_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_15_RDATA,
    input  wire                                 m_axi_gmem_15_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_15_RID,
    input  wire [1:0]                           m_axi_gmem_15_RRESP,
    input  wire                                 m_axi_gmem_15_BVALID,
    output wire                                 m_axi_gmem_15_BREADY,
    input  wire [1:0]                           m_axi_gmem_15_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_15_BID,
    
    output wire                                 m_axi_gmem_16_AWVALID,
    input  wire                                 m_axi_gmem_16_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_16_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_16_AWID,
    output wire [7:0]                           m_axi_gmem_16_AWLEN,
    output wire [2:0]                           m_axi_gmem_16_AWSIZE,
    output wire [1:0]                           m_axi_gmem_16_AWBURST,
    output wire [1:0]                           m_axi_gmem_16_AWLOCK,
    output wire [3:0]                           m_axi_gmem_16_AWCACHE,
    output wire [2:0]                           m_axi_gmem_16_AWPROT,
    output wire [3:0]                           m_axi_gmem_16_AWQOS,
    output wire [3:0]                           m_axi_gmem_16_AWREGION,
    output wire                                 m_axi_gmem_16_WVALID,
    input  wire                                 m_axi_gmem_16_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_16_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_16_WSTRB,
    output wire                                 m_axi_gmem_16_WLAST,
    output wire                                 m_axi_gmem_16_ARVALID,
    input  wire                                 m_axi_gmem_16_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_16_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_16_ARID,
    output wire [7:0]                           m_axi_gmem_16_ARLEN,
    output wire [2:0]                           m_axi_gmem_16_ARSIZE,
    output wire [1:0]                           m_axi_gmem_16_ARBURST,
    output wire [1:0]                           m_axi_gmem_16_ARLOCK,
    output wire [3:0]                           m_axi_gmem_16_ARCACHE,
    output wire [2:0]                           m_axi_gmem_16_ARPROT,
    output wire [3:0]                           m_axi_gmem_16_ARQOS,
    output wire [3:0]                           m_axi_gmem_16_ARREGION,
    input  wire                                 m_axi_gmem_16_RVALID,
    output wire                                 m_axi_gmem_16_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_16_RDATA,
    input  wire                                 m_axi_gmem_16_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_16_RID,
    input  wire [1:0]                           m_axi_gmem_16_RRESP,
    input  wire                                 m_axi_gmem_16_BVALID,
    output wire                                 m_axi_gmem_16_BREADY,
    input  wire [1:0]                           m_axi_gmem_16_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_16_BID,
    
    output wire                                 m_axi_gmem_17_AWVALID,
    input  wire                                 m_axi_gmem_17_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_17_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_17_AWID,
    output wire [7:0]                           m_axi_gmem_17_AWLEN,
    output wire [2:0]                           m_axi_gmem_17_AWSIZE,
    output wire [1:0]                           m_axi_gmem_17_AWBURST,
    output wire [1:0]                           m_axi_gmem_17_AWLOCK,
    output wire [3:0]                           m_axi_gmem_17_AWCACHE,
    output wire [2:0]                           m_axi_gmem_17_AWPROT,
    output wire [3:0]                           m_axi_gmem_17_AWQOS,
    output wire [3:0]                           m_axi_gmem_17_AWREGION,
    output wire                                 m_axi_gmem_17_WVALID,
    input  wire                                 m_axi_gmem_17_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_17_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_17_WSTRB,
    output wire                                 m_axi_gmem_17_WLAST,
    output wire                                 m_axi_gmem_17_ARVALID,
    input  wire                                 m_axi_gmem_17_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_17_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_17_ARID,
    output wire [7:0]                           m_axi_gmem_17_ARLEN,
    output wire [2:0]                           m_axi_gmem_17_ARSIZE,
    output wire [1:0]                           m_axi_gmem_17_ARBURST,
    output wire [1:0]                           m_axi_gmem_17_ARLOCK,
    output wire [3:0]                           m_axi_gmem_17_ARCACHE,
    output wire [2:0]                           m_axi_gmem_17_ARPROT,
    output wire [3:0]                           m_axi_gmem_17_ARQOS,
    output wire [3:0]                           m_axi_gmem_17_ARREGION,
    input  wire                                 m_axi_gmem_17_RVALID,
    output wire                                 m_axi_gmem_17_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_17_RDATA,
    input  wire                                 m_axi_gmem_17_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_17_RID,
    input  wire [1:0]                           m_axi_gmem_17_RRESP,
    input  wire                                 m_axi_gmem_17_BVALID,
    output wire                                 m_axi_gmem_17_BREADY,
    input  wire [1:0]                           m_axi_gmem_17_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_17_BID,
    
    output wire                                 m_axi_gmem_18_AWVALID,
    input  wire                                 m_axi_gmem_18_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_18_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_18_AWID,
    output wire [7:0]                           m_axi_gmem_18_AWLEN,
    output wire [2:0]                           m_axi_gmem_18_AWSIZE,
    output wire [1:0]                           m_axi_gmem_18_AWBURST,
    output wire [1:0]                           m_axi_gmem_18_AWLOCK,
    output wire [3:0]                           m_axi_gmem_18_AWCACHE,
    output wire [2:0]                           m_axi_gmem_18_AWPROT,
    output wire [3:0]                           m_axi_gmem_18_AWQOS,
    output wire [3:0]                           m_axi_gmem_18_AWREGION,
    output wire                                 m_axi_gmem_18_WVALID,
    input  wire                                 m_axi_gmem_18_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_18_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_18_WSTRB,
    output wire                                 m_axi_gmem_18_WLAST,
    output wire                                 m_axi_gmem_18_ARVALID,
    input  wire                                 m_axi_gmem_18_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_18_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_18_ARID,
    output wire [7:0]                           m_axi_gmem_18_ARLEN,
    output wire [2:0]                           m_axi_gmem_18_ARSIZE,
    output wire [1:0]                           m_axi_gmem_18_ARBURST,
    output wire [1:0]                           m_axi_gmem_18_ARLOCK,
    output wire [3:0]                           m_axi_gmem_18_ARCACHE,
    output wire [2:0]                           m_axi_gmem_18_ARPROT,
    output wire [3:0]                           m_axi_gmem_18_ARQOS,
    output wire [3:0]                           m_axi_gmem_18_ARREGION,
    input  wire                                 m_axi_gmem_18_RVALID,
    output wire                                 m_axi_gmem_18_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_18_RDATA,
    input  wire                                 m_axi_gmem_18_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_18_RID,
    input  wire [1:0]                           m_axi_gmem_18_RRESP,
    input  wire                                 m_axi_gmem_18_BVALID,
    output wire                                 m_axi_gmem_18_BREADY,
    input  wire [1:0]                           m_axi_gmem_18_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_18_BID,
    
    output wire                                 m_axi_gmem_19_AWVALID,
    input  wire                                 m_axi_gmem_19_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_19_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_19_AWID,
    output wire [7:0]                           m_axi_gmem_19_AWLEN,
    output wire [2:0]                           m_axi_gmem_19_AWSIZE,
    output wire [1:0]                           m_axi_gmem_19_AWBURST,
    output wire [1:0]                           m_axi_gmem_19_AWLOCK,
    output wire [3:0]                           m_axi_gmem_19_AWCACHE,
    output wire [2:0]                           m_axi_gmem_19_AWPROT,
    output wire [3:0]                           m_axi_gmem_19_AWQOS,
    output wire [3:0]                           m_axi_gmem_19_AWREGION,
    output wire                                 m_axi_gmem_19_WVALID,
    input  wire                                 m_axi_gmem_19_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_19_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_19_WSTRB,
    output wire                                 m_axi_gmem_19_WLAST,
    output wire                                 m_axi_gmem_19_ARVALID,
    input  wire                                 m_axi_gmem_19_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_19_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_19_ARID,
    output wire [7:0]                           m_axi_gmem_19_ARLEN,
    output wire [2:0]                           m_axi_gmem_19_ARSIZE,
    output wire [1:0]                           m_axi_gmem_19_ARBURST,
    output wire [1:0]                           m_axi_gmem_19_ARLOCK,
    output wire [3:0]                           m_axi_gmem_19_ARCACHE,
    output wire [2:0]                           m_axi_gmem_19_ARPROT,
    output wire [3:0]                           m_axi_gmem_19_ARQOS,
    output wire [3:0]                           m_axi_gmem_19_ARREGION,
    input  wire                                 m_axi_gmem_19_RVALID,
    output wire                                 m_axi_gmem_19_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_19_RDATA,
    input  wire                                 m_axi_gmem_19_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_19_RID,
    input  wire [1:0]                           m_axi_gmem_19_RRESP,
    input  wire                                 m_axi_gmem_19_BVALID,
    output wire                                 m_axi_gmem_19_BREADY,
    input  wire [1:0]                           m_axi_gmem_19_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_19_BID,
    
    output wire                                 m_axi_gmem_20_AWVALID,
    input  wire                                 m_axi_gmem_20_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_20_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_20_AWID,
    output wire [7:0]                           m_axi_gmem_20_AWLEN,
    output wire [2:0]                           m_axi_gmem_20_AWSIZE,
    output wire [1:0]                           m_axi_gmem_20_AWBURST,
    output wire [1:0]                           m_axi_gmem_20_AWLOCK,
    output wire [3:0]                           m_axi_gmem_20_AWCACHE,
    output wire [2:0]                           m_axi_gmem_20_AWPROT,
    output wire [3:0]                           m_axi_gmem_20_AWQOS,
    output wire [3:0]                           m_axi_gmem_20_AWREGION,
    output wire                                 m_axi_gmem_20_WVALID,
    input  wire                                 m_axi_gmem_20_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_20_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_20_WSTRB,
    output wire                                 m_axi_gmem_20_WLAST,
    output wire                                 m_axi_gmem_20_ARVALID,
    input  wire                                 m_axi_gmem_20_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_20_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_20_ARID,
    output wire [7:0]                           m_axi_gmem_20_ARLEN,
    output wire [2:0]                           m_axi_gmem_20_ARSIZE,
    output wire [1:0]                           m_axi_gmem_20_ARBURST,
    output wire [1:0]                           m_axi_gmem_20_ARLOCK,
    output wire [3:0]                           m_axi_gmem_20_ARCACHE,
    output wire [2:0]                           m_axi_gmem_20_ARPROT,
    output wire [3:0]                           m_axi_gmem_20_ARQOS,
    output wire [3:0]                           m_axi_gmem_20_ARREGION,
    input  wire                                 m_axi_gmem_20_RVALID,
    output wire                                 m_axi_gmem_20_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_20_RDATA,
    input  wire                                 m_axi_gmem_20_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_20_RID,
    input  wire [1:0]                           m_axi_gmem_20_RRESP,
    input  wire                                 m_axi_gmem_20_BVALID,
    output wire                                 m_axi_gmem_20_BREADY,
    input  wire [1:0]                           m_axi_gmem_20_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_20_BID,
    
    output wire                                 m_axi_gmem_21_AWVALID,
    input  wire                                 m_axi_gmem_21_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_21_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_21_AWID,
    output wire [7:0]                           m_axi_gmem_21_AWLEN,
    output wire [2:0]                           m_axi_gmem_21_AWSIZE,
    output wire [1:0]                           m_axi_gmem_21_AWBURST,
    output wire [1:0]                           m_axi_gmem_21_AWLOCK,
    output wire [3:0]                           m_axi_gmem_21_AWCACHE,
    output wire [2:0]                           m_axi_gmem_21_AWPROT,
    output wire [3:0]                           m_axi_gmem_21_AWQOS,
    output wire [3:0]                           m_axi_gmem_21_AWREGION,
    output wire                                 m_axi_gmem_21_WVALID,
    input  wire                                 m_axi_gmem_21_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_21_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_21_WSTRB,
    output wire                                 m_axi_gmem_21_WLAST,
    output wire                                 m_axi_gmem_21_ARVALID,
    input  wire                                 m_axi_gmem_21_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_21_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_21_ARID,
    output wire [7:0]                           m_axi_gmem_21_ARLEN,
    output wire [2:0]                           m_axi_gmem_21_ARSIZE,
    output wire [1:0]                           m_axi_gmem_21_ARBURST,
    output wire [1:0]                           m_axi_gmem_21_ARLOCK,
    output wire [3:0]                           m_axi_gmem_21_ARCACHE,
    output wire [2:0]                           m_axi_gmem_21_ARPROT,
    output wire [3:0]                           m_axi_gmem_21_ARQOS,
    output wire [3:0]                           m_axi_gmem_21_ARREGION,
    input  wire                                 m_axi_gmem_21_RVALID,
    output wire                                 m_axi_gmem_21_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_21_RDATA,
    input  wire                                 m_axi_gmem_21_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_21_RID,
    input  wire [1:0]                           m_axi_gmem_21_RRESP,
    input  wire                                 m_axi_gmem_21_BVALID,
    output wire                                 m_axi_gmem_21_BREADY,
    input  wire [1:0]                           m_axi_gmem_21_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_21_BID,
    
    output wire                                 m_axi_gmem_22_AWVALID,
    input  wire                                 m_axi_gmem_22_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_22_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_22_AWID,
    output wire [7:0]                           m_axi_gmem_22_AWLEN,
    output wire [2:0]                           m_axi_gmem_22_AWSIZE,
    output wire [1:0]                           m_axi_gmem_22_AWBURST,
    output wire [1:0]                           m_axi_gmem_22_AWLOCK,
    output wire [3:0]                           m_axi_gmem_22_AWCACHE,
    output wire [2:0]                           m_axi_gmem_22_AWPROT,
    output wire [3:0]                           m_axi_gmem_22_AWQOS,
    output wire [3:0]                           m_axi_gmem_22_AWREGION,
    output wire                                 m_axi_gmem_22_WVALID,
    input  wire                                 m_axi_gmem_22_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_22_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_22_WSTRB,
    output wire                                 m_axi_gmem_22_WLAST,
    output wire                                 m_axi_gmem_22_ARVALID,
    input  wire                                 m_axi_gmem_22_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_22_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_22_ARID,
    output wire [7:0]                           m_axi_gmem_22_ARLEN,
    output wire [2:0]                           m_axi_gmem_22_ARSIZE,
    output wire [1:0]                           m_axi_gmem_22_ARBURST,
    output wire [1:0]                           m_axi_gmem_22_ARLOCK,
    output wire [3:0]                           m_axi_gmem_22_ARCACHE,
    output wire [2:0]                           m_axi_gmem_22_ARPROT,
    output wire [3:0]                           m_axi_gmem_22_ARQOS,
    output wire [3:0]                           m_axi_gmem_22_ARREGION,
    input  wire                                 m_axi_gmem_22_RVALID,
    output wire                                 m_axi_gmem_22_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_22_RDATA,
    input  wire                                 m_axi_gmem_22_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_22_RID,
    input  wire [1:0]                           m_axi_gmem_22_RRESP,
    input  wire                                 m_axi_gmem_22_BVALID,
    output wire                                 m_axi_gmem_22_BREADY,
    input  wire [1:0]                           m_axi_gmem_22_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_22_BID,
    
    output wire                                 m_axi_gmem_23_AWVALID,
    input  wire                                 m_axi_gmem_23_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_23_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_23_AWID,
    output wire [7:0]                           m_axi_gmem_23_AWLEN,
    output wire [2:0]                           m_axi_gmem_23_AWSIZE,
    output wire [1:0]                           m_axi_gmem_23_AWBURST,
    output wire [1:0]                           m_axi_gmem_23_AWLOCK,
    output wire [3:0]                           m_axi_gmem_23_AWCACHE,
    output wire [2:0]                           m_axi_gmem_23_AWPROT,
    output wire [3:0]                           m_axi_gmem_23_AWQOS,
    output wire [3:0]                           m_axi_gmem_23_AWREGION,
    output wire                                 m_axi_gmem_23_WVALID,
    input  wire                                 m_axi_gmem_23_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_23_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_23_WSTRB,
    output wire                                 m_axi_gmem_23_WLAST,
    output wire                                 m_axi_gmem_23_ARVALID,
    input  wire                                 m_axi_gmem_23_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_23_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_23_ARID,
    output wire [7:0]                           m_axi_gmem_23_ARLEN,
    output wire [2:0]                           m_axi_gmem_23_ARSIZE,
    output wire [1:0]                           m_axi_gmem_23_ARBURST,
    output wire [1:0]                           m_axi_gmem_23_ARLOCK,
    output wire [3:0]                           m_axi_gmem_23_ARCACHE,
    output wire [2:0]                           m_axi_gmem_23_ARPROT,
    output wire [3:0]                           m_axi_gmem_23_ARQOS,
    output wire [3:0]                           m_axi_gmem_23_ARREGION,
    input  wire                                 m_axi_gmem_23_RVALID,
    output wire                                 m_axi_gmem_23_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_23_RDATA,
    input  wire                                 m_axi_gmem_23_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_23_RID,
    input  wire [1:0]                           m_axi_gmem_23_RRESP,
    input  wire                                 m_axi_gmem_23_BVALID,
    output wire                                 m_axi_gmem_23_BREADY,
    input  wire [1:0]                           m_axi_gmem_23_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_23_BID,
    
    output wire                                 m_axi_gmem_24_AWVALID,
    input  wire                                 m_axi_gmem_24_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_24_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_24_AWID,
    output wire [7:0]                           m_axi_gmem_24_AWLEN,
    output wire [2:0]                           m_axi_gmem_24_AWSIZE,
    output wire [1:0]                           m_axi_gmem_24_AWBURST,
    output wire [1:0]                           m_axi_gmem_24_AWLOCK,
    output wire [3:0]                           m_axi_gmem_24_AWCACHE,
    output wire [2:0]                           m_axi_gmem_24_AWPROT,
    output wire [3:0]                           m_axi_gmem_24_AWQOS,
    output wire [3:0]                           m_axi_gmem_24_AWREGION,
    output wire                                 m_axi_gmem_24_WVALID,
    input  wire                                 m_axi_gmem_24_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_24_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_24_WSTRB,
    output wire                                 m_axi_gmem_24_WLAST,
    output wire                                 m_axi_gmem_24_ARVALID,
    input  wire                                 m_axi_gmem_24_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_24_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_24_ARID,
    output wire [7:0]                           m_axi_gmem_24_ARLEN,
    output wire [2:0]                           m_axi_gmem_24_ARSIZE,
    output wire [1:0]                           m_axi_gmem_24_ARBURST,
    output wire [1:0]                           m_axi_gmem_24_ARLOCK,
    output wire [3:0]                           m_axi_gmem_24_ARCACHE,
    output wire [2:0]                           m_axi_gmem_24_ARPROT,
    output wire [3:0]                           m_axi_gmem_24_ARQOS,
    output wire [3:0]                           m_axi_gmem_24_ARREGION,
    input  wire                                 m_axi_gmem_24_RVALID,
    output wire                                 m_axi_gmem_24_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_24_RDATA,
    input  wire                                 m_axi_gmem_24_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_24_RID,
    input  wire [1:0]                           m_axi_gmem_24_RRESP,
    input  wire                                 m_axi_gmem_24_BVALID,
    output wire                                 m_axi_gmem_24_BREADY,
    input  wire [1:0]                           m_axi_gmem_24_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_24_BID,
    
    output wire                                 m_axi_gmem_25_AWVALID,
    input  wire                                 m_axi_gmem_25_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_25_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_25_AWID,
    output wire [7:0]                           m_axi_gmem_25_AWLEN,
    output wire [2:0]                           m_axi_gmem_25_AWSIZE,
    output wire [1:0]                           m_axi_gmem_25_AWBURST,
    output wire [1:0]                           m_axi_gmem_25_AWLOCK,
    output wire [3:0]                           m_axi_gmem_25_AWCACHE,
    output wire [2:0]                           m_axi_gmem_25_AWPROT,
    output wire [3:0]                           m_axi_gmem_25_AWQOS,
    output wire [3:0]                           m_axi_gmem_25_AWREGION,
    output wire                                 m_axi_gmem_25_WVALID,
    input  wire                                 m_axi_gmem_25_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_25_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_25_WSTRB,
    output wire                                 m_axi_gmem_25_WLAST,
    output wire                                 m_axi_gmem_25_ARVALID,
    input  wire                                 m_axi_gmem_25_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_25_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_25_ARID,
    output wire [7:0]                           m_axi_gmem_25_ARLEN,
    output wire [2:0]                           m_axi_gmem_25_ARSIZE,
    output wire [1:0]                           m_axi_gmem_25_ARBURST,
    output wire [1:0]                           m_axi_gmem_25_ARLOCK,
    output wire [3:0]                           m_axi_gmem_25_ARCACHE,
    output wire [2:0]                           m_axi_gmem_25_ARPROT,
    output wire [3:0]                           m_axi_gmem_25_ARQOS,
    output wire [3:0]                           m_axi_gmem_25_ARREGION,
    input  wire                                 m_axi_gmem_25_RVALID,
    output wire                                 m_axi_gmem_25_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_25_RDATA,
    input  wire                                 m_axi_gmem_25_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_25_RID,
    input  wire [1:0]                           m_axi_gmem_25_RRESP,
    input  wire                                 m_axi_gmem_25_BVALID,
    output wire                                 m_axi_gmem_25_BREADY,
    input  wire [1:0]                           m_axi_gmem_25_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_25_BID,
    
    output wire                                 m_axi_gmem_26_AWVALID,
    input  wire                                 m_axi_gmem_26_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_26_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_26_AWID,
    output wire [7:0]                           m_axi_gmem_26_AWLEN,
    output wire [2:0]                           m_axi_gmem_26_AWSIZE,
    output wire [1:0]                           m_axi_gmem_26_AWBURST,
    output wire [1:0]                           m_axi_gmem_26_AWLOCK,
    output wire [3:0]                           m_axi_gmem_26_AWCACHE,
    output wire [2:0]                           m_axi_gmem_26_AWPROT,
    output wire [3:0]                           m_axi_gmem_26_AWQOS,
    output wire [3:0]                           m_axi_gmem_26_AWREGION,
    output wire                                 m_axi_gmem_26_WVALID,
    input  wire                                 m_axi_gmem_26_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_26_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_26_WSTRB,
    output wire                                 m_axi_gmem_26_WLAST,
    output wire                                 m_axi_gmem_26_ARVALID,
    input  wire                                 m_axi_gmem_26_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_26_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_26_ARID,
    output wire [7:0]                           m_axi_gmem_26_ARLEN,
    output wire [2:0]                           m_axi_gmem_26_ARSIZE,
    output wire [1:0]                           m_axi_gmem_26_ARBURST,
    output wire [1:0]                           m_axi_gmem_26_ARLOCK,
    output wire [3:0]                           m_axi_gmem_26_ARCACHE,
    output wire [2:0]                           m_axi_gmem_26_ARPROT,
    output wire [3:0]                           m_axi_gmem_26_ARQOS,
    output wire [3:0]                           m_axi_gmem_26_ARREGION,
    input  wire                                 m_axi_gmem_26_RVALID,
    output wire                                 m_axi_gmem_26_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_26_RDATA,
    input  wire                                 m_axi_gmem_26_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_26_RID,
    input  wire [1:0]                           m_axi_gmem_26_RRESP,
    input  wire                                 m_axi_gmem_26_BVALID,
    output wire                                 m_axi_gmem_26_BREADY,
    input  wire [1:0]                           m_axi_gmem_26_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_26_BID,
    
    output wire                                 m_axi_gmem_27_AWVALID,
    input  wire                                 m_axi_gmem_27_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_27_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_27_AWID,
    output wire [7:0]                           m_axi_gmem_27_AWLEN,
    output wire [2:0]                           m_axi_gmem_27_AWSIZE,
    output wire [1:0]                           m_axi_gmem_27_AWBURST,
    output wire [1:0]                           m_axi_gmem_27_AWLOCK,
    output wire [3:0]                           m_axi_gmem_27_AWCACHE,
    output wire [2:0]                           m_axi_gmem_27_AWPROT,
    output wire [3:0]                           m_axi_gmem_27_AWQOS,
    output wire [3:0]                           m_axi_gmem_27_AWREGION,
    output wire                                 m_axi_gmem_27_WVALID,
    input  wire                                 m_axi_gmem_27_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_27_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_27_WSTRB,
    output wire                                 m_axi_gmem_27_WLAST,
    output wire                                 m_axi_gmem_27_ARVALID,
    input  wire                                 m_axi_gmem_27_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_27_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_27_ARID,
    output wire [7:0]                           m_axi_gmem_27_ARLEN,
    output wire [2:0]                           m_axi_gmem_27_ARSIZE,
    output wire [1:0]                           m_axi_gmem_27_ARBURST,
    output wire [1:0]                           m_axi_gmem_27_ARLOCK,
    output wire [3:0]                           m_axi_gmem_27_ARCACHE,
    output wire [2:0]                           m_axi_gmem_27_ARPROT,
    output wire [3:0]                           m_axi_gmem_27_ARQOS,
    output wire [3:0]                           m_axi_gmem_27_ARREGION,
    input  wire                                 m_axi_gmem_27_RVALID,
    output wire                                 m_axi_gmem_27_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_27_RDATA,
    input  wire                                 m_axi_gmem_27_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_27_RID,
    input  wire [1:0]                           m_axi_gmem_27_RRESP,
    input  wire                                 m_axi_gmem_27_BVALID,
    output wire                                 m_axi_gmem_27_BREADY,
    input  wire [1:0]                           m_axi_gmem_27_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_27_BID,
    
    output wire                                 m_axi_gmem_28_AWVALID,
    input  wire                                 m_axi_gmem_28_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_28_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_28_AWID,
    output wire [7:0]                           m_axi_gmem_28_AWLEN,
    output wire [2:0]                           m_axi_gmem_28_AWSIZE,
    output wire [1:0]                           m_axi_gmem_28_AWBURST,
    output wire [1:0]                           m_axi_gmem_28_AWLOCK,
    output wire [3:0]                           m_axi_gmem_28_AWCACHE,
    output wire [2:0]                           m_axi_gmem_28_AWPROT,
    output wire [3:0]                           m_axi_gmem_28_AWQOS,
    output wire [3:0]                           m_axi_gmem_28_AWREGION,
    output wire                                 m_axi_gmem_28_WVALID,
    input  wire                                 m_axi_gmem_28_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_28_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_28_WSTRB,
    output wire                                 m_axi_gmem_28_WLAST,
    output wire                                 m_axi_gmem_28_ARVALID,
    input  wire                                 m_axi_gmem_28_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_28_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_28_ARID,
    output wire [7:0]                           m_axi_gmem_28_ARLEN,
    output wire [2:0]                           m_axi_gmem_28_ARSIZE,
    output wire [1:0]                           m_axi_gmem_28_ARBURST,
    output wire [1:0]                           m_axi_gmem_28_ARLOCK,
    output wire [3:0]                           m_axi_gmem_28_ARCACHE,
    output wire [2:0]                           m_axi_gmem_28_ARPROT,
    output wire [3:0]                           m_axi_gmem_28_ARQOS,
    output wire [3:0]                           m_axi_gmem_28_ARREGION,
    input  wire                                 m_axi_gmem_28_RVALID,
    output wire                                 m_axi_gmem_28_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_28_RDATA,
    input  wire                                 m_axi_gmem_28_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_28_RID,
    input  wire [1:0]                           m_axi_gmem_28_RRESP,
    input  wire                                 m_axi_gmem_28_BVALID,
    output wire                                 m_axi_gmem_28_BREADY,
    input  wire [1:0]                           m_axi_gmem_28_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_28_BID,
    
    output wire                                 m_axi_gmem_29_AWVALID,
    input  wire                                 m_axi_gmem_29_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_29_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_29_AWID,
    output wire [7:0]                           m_axi_gmem_29_AWLEN,
    output wire [2:0]                           m_axi_gmem_29_AWSIZE,
    output wire [1:0]                           m_axi_gmem_29_AWBURST,
    output wire [1:0]                           m_axi_gmem_29_AWLOCK,
    output wire [3:0]                           m_axi_gmem_29_AWCACHE,
    output wire [2:0]                           m_axi_gmem_29_AWPROT,
    output wire [3:0]                           m_axi_gmem_29_AWQOS,
    output wire [3:0]                           m_axi_gmem_29_AWREGION,
    output wire                                 m_axi_gmem_29_WVALID,
    input  wire                                 m_axi_gmem_29_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_29_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_29_WSTRB,
    output wire                                 m_axi_gmem_29_WLAST,
    output wire                                 m_axi_gmem_29_ARVALID,
    input  wire                                 m_axi_gmem_29_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_29_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_29_ARID,
    output wire [7:0]                           m_axi_gmem_29_ARLEN,
    output wire [2:0]                           m_axi_gmem_29_ARSIZE,
    output wire [1:0]                           m_axi_gmem_29_ARBURST,
    output wire [1:0]                           m_axi_gmem_29_ARLOCK,
    output wire [3:0]                           m_axi_gmem_29_ARCACHE,
    output wire [2:0]                           m_axi_gmem_29_ARPROT,
    output wire [3:0]                           m_axi_gmem_29_ARQOS,
    output wire [3:0]                           m_axi_gmem_29_ARREGION,
    input  wire                                 m_axi_gmem_29_RVALID,
    output wire                                 m_axi_gmem_29_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_29_RDATA,
    input  wire                                 m_axi_gmem_29_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_29_RID,
    input  wire [1:0]                           m_axi_gmem_29_RRESP,
    input  wire                                 m_axi_gmem_29_BVALID,
    output wire                                 m_axi_gmem_29_BREADY,
    input  wire [1:0]                           m_axi_gmem_29_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_29_BID,
    
    output wire                                 m_axi_gmem_30_AWVALID,
    input  wire                                 m_axi_gmem_30_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_30_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_30_AWID,
    output wire [7:0]                           m_axi_gmem_30_AWLEN,
    output wire [2:0]                           m_axi_gmem_30_AWSIZE,
    output wire [1:0]                           m_axi_gmem_30_AWBURST,
    output wire [1:0]                           m_axi_gmem_30_AWLOCK,
    output wire [3:0]                           m_axi_gmem_30_AWCACHE,
    output wire [2:0]                           m_axi_gmem_30_AWPROT,
    output wire [3:0]                           m_axi_gmem_30_AWQOS,
    output wire [3:0]                           m_axi_gmem_30_AWREGION,
    output wire                                 m_axi_gmem_30_WVALID,
    input  wire                                 m_axi_gmem_30_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_30_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_30_WSTRB,
    output wire                                 m_axi_gmem_30_WLAST,
    output wire                                 m_axi_gmem_30_ARVALID,
    input  wire                                 m_axi_gmem_30_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_30_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_30_ARID,
    output wire [7:0]                           m_axi_gmem_30_ARLEN,
    output wire [2:0]                           m_axi_gmem_30_ARSIZE,
    output wire [1:0]                           m_axi_gmem_30_ARBURST,
    output wire [1:0]                           m_axi_gmem_30_ARLOCK,
    output wire [3:0]                           m_axi_gmem_30_ARCACHE,
    output wire [2:0]                           m_axi_gmem_30_ARPROT,
    output wire [3:0]                           m_axi_gmem_30_ARQOS,
    output wire [3:0]                           m_axi_gmem_30_ARREGION,
    input  wire                                 m_axi_gmem_30_RVALID,
    output wire                                 m_axi_gmem_30_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_30_RDATA,
    input  wire                                 m_axi_gmem_30_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_30_RID,
    input  wire [1:0]                           m_axi_gmem_30_RRESP,
    input  wire                                 m_axi_gmem_30_BVALID,
    output wire                                 m_axi_gmem_30_BREADY,
    input  wire [1:0]                           m_axi_gmem_30_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_30_BID,
    
    output wire                                 m_axi_gmem_31_AWVALID,
    input  wire                                 m_axi_gmem_31_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_31_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_31_AWID,
    output wire [7:0]                           m_axi_gmem_31_AWLEN,
    output wire [2:0]                           m_axi_gmem_31_AWSIZE,
    output wire [1:0]                           m_axi_gmem_31_AWBURST,
    output wire [1:0]                           m_axi_gmem_31_AWLOCK,
    output wire [3:0]                           m_axi_gmem_31_AWCACHE,
    output wire [2:0]                           m_axi_gmem_31_AWPROT,
    output wire [3:0]                           m_axi_gmem_31_AWQOS,
    output wire [3:0]                           m_axi_gmem_31_AWREGION,
    output wire                                 m_axi_gmem_31_WVALID,
    input  wire                                 m_axi_gmem_31_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_31_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_31_WSTRB,
    output wire                                 m_axi_gmem_31_WLAST,
    output wire                                 m_axi_gmem_31_ARVALID,
    input  wire                                 m_axi_gmem_31_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_31_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_31_ARID,
    output wire [7:0]                           m_axi_gmem_31_ARLEN,
    output wire [2:0]                           m_axi_gmem_31_ARSIZE,
    output wire [1:0]                           m_axi_gmem_31_ARBURST,
    output wire [1:0]                           m_axi_gmem_31_ARLOCK,
    output wire [3:0]                           m_axi_gmem_31_ARCACHE,
    output wire [2:0]                           m_axi_gmem_31_ARPROT,
    output wire [3:0]                           m_axi_gmem_31_ARQOS,
    output wire [3:0]                           m_axi_gmem_31_ARREGION,
    input  wire                                 m_axi_gmem_31_RVALID,
    output wire                                 m_axi_gmem_31_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_31_RDATA,
    input  wire                                 m_axi_gmem_31_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_31_RID,
    input  wire [1:0]                           m_axi_gmem_31_RRESP,
    input  wire                                 m_axi_gmem_31_BVALID,
    output wire                                 m_axi_gmem_31_BREADY,
    input  wire [1:0]                           m_axi_gmem_31_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_31_BID,

    output wire                                 m_axi_gmem_32_AWVALID,
    input  wire                                 m_axi_gmem_32_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_32_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_32_AWID,
    output wire [7:0]                           m_axi_gmem_32_AWLEN,
    output wire [2:0]                           m_axi_gmem_32_AWSIZE,
    output wire [1:0]                           m_axi_gmem_32_AWBURST,
    output wire [1:0]                           m_axi_gmem_32_AWLOCK,
    output wire [3:0]                           m_axi_gmem_32_AWCACHE,
    output wire [2:0]                           m_axi_gmem_32_AWPROT,
    output wire [3:0]                           m_axi_gmem_32_AWQOS,
    output wire [3:0]                           m_axi_gmem_32_AWREGION,
    output wire                                 m_axi_gmem_32_WVALID,
    input  wire                                 m_axi_gmem_32_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_32_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_32_WSTRB,
    output wire                                 m_axi_gmem_32_WLAST,
    output wire                                 m_axi_gmem_32_ARVALID,
    input  wire                                 m_axi_gmem_32_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_32_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_32_ARID,
    output wire [7:0]                           m_axi_gmem_32_ARLEN,
    output wire [2:0]                           m_axi_gmem_32_ARSIZE,
    output wire [1:0]                           m_axi_gmem_32_ARBURST,
    output wire [1:0]                           m_axi_gmem_32_ARLOCK,
    output wire [3:0]                           m_axi_gmem_32_ARCACHE,
    output wire [2:0]                           m_axi_gmem_32_ARPROT,
    output wire [3:0]                           m_axi_gmem_32_ARQOS,
    output wire [3:0]                           m_axi_gmem_32_ARREGION,
    input  wire                                 m_axi_gmem_32_RVALID,
    output wire                                 m_axi_gmem_32_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_32_RDATA,
    input  wire                                 m_axi_gmem_32_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_32_RID,
    input  wire [1:0]                           m_axi_gmem_32_RRESP,
    input  wire                                 m_axi_gmem_32_BVALID,
    output wire                                 m_axi_gmem_32_BREADY,
    input  wire [1:0]                           m_axi_gmem_32_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_32_BID,

    output wire                                 m_axi_gmem_33_AWVALID,
    input  wire                                 m_axi_gmem_33_AWREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_33_AWADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_33_AWID,
    output wire [7:0]                           m_axi_gmem_33_AWLEN,
    output wire [2:0]                           m_axi_gmem_33_AWSIZE,
    output wire [1:0]                           m_axi_gmem_33_AWBURST,
    output wire [1:0]                           m_axi_gmem_33_AWLOCK,
    output wire [3:0]                           m_axi_gmem_33_AWCACHE,
    output wire [2:0]                           m_axi_gmem_33_AWPROT,
    output wire [3:0]                           m_axi_gmem_33_AWQOS,
    output wire [3:0]                           m_axi_gmem_33_AWREGION,
    output wire                                 m_axi_gmem_33_WVALID,
    input  wire                                 m_axi_gmem_33_WREADY,
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_33_WDATA,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_33_WSTRB,
    output wire                                 m_axi_gmem_33_WLAST,
    output wire                                 m_axi_gmem_33_ARVALID,
    input  wire                                 m_axi_gmem_33_ARREADY,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_33_ARADDR,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_33_ARID,
    output wire [7:0]                           m_axi_gmem_33_ARLEN,
    output wire [2:0]                           m_axi_gmem_33_ARSIZE,
    output wire [1:0]                           m_axi_gmem_33_ARBURST,
    output wire [1:0]                           m_axi_gmem_33_ARLOCK,
    output wire [3:0]                           m_axi_gmem_33_ARCACHE,
    output wire [2:0]                           m_axi_gmem_33_ARPROT,
    output wire [3:0]                           m_axi_gmem_33_ARQOS,
    output wire [3:0]                           m_axi_gmem_33_ARREGION,
    input  wire                                 m_axi_gmem_33_RVALID,
    output wire                                 m_axi_gmem_33_RREADY,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_33_RDATA,
    input  wire                                 m_axi_gmem_33_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_33_RID,
    input  wire [1:0]                           m_axi_gmem_33_RRESP,
    input  wire                                 m_axi_gmem_33_BVALID,
    output wire                                 m_axi_gmem_33_BREADY,
    input  wire [1:0]                           m_axi_gmem_33_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_33_BID,

  // AXI4-Lite slave interface
    input  wire                                    s_axi_control_AWVALID,
    output wire                                    s_axi_control_AWREADY,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_AWADDR,
    input  wire                                    s_axi_control_WVALID,
    output wire                                    s_axi_control_WREADY,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_WDATA,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_WSTRB,
    input  wire                                    s_axi_control_ARVALID,
    output wire                                    s_axi_control_ARREADY,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_ARADDR,
    output wire                                    s_axi_control_RVALID,
    input  wire                                    s_axi_control_RREADY,
    output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_RDATA,
    output wire [1:0]                              s_axi_control_RRESP,
    output wire                                    s_axi_control_BVALID,
    input  wire                                    s_axi_control_BREADY,
    output wire [1:0]                              s_axi_control_BRESP,
    output wire                                    interrupt 
);

// WIRES FOR SHARED DATA OUTPUTS
  wire                                  m_axi_gmem_AWVALID;
  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]    m_axi_gmem_AWID;
  wire [7:0]                            m_axi_gmem_AWLEN;
  wire [2:0]                            m_axi_gmem_AWSIZE;
  wire [1:0]                            m_axi_gmem_AWBURST;
  wire [1:0]                            m_axi_gmem_AWLOCK;
  wire [3:0]                            m_axi_gmem_AWCACHE;
  wire [2:0]                            m_axi_gmem_AWPROT;
  wire [3:0]                            m_axi_gmem_AWQOS;
  wire [3:0]                            m_axi_gmem_AWREGION;
  wire                                  m_axi_gmem_WVALID;
  wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0]  m_axi_gmem_WSTRB;
  wire                                  m_axi_gmem_WLAST;
  wire                                  m_axi_gmem_ARVALID;
  wire [C_M_AXI_GMEM_ID_WIDTH-1:0]      m_axi_gmem_ARID;
  wire [7:0]                            m_axi_gmem_ARLEN;
  wire [2:0]                            m_axi_gmem_ARSIZE;
  wire [1:0]                            m_axi_gmem_ARBURST;
  wire [1:0]                            m_axi_gmem_ARLOCK;
  wire [3:0]                            m_axi_gmem_ARCACHE;
  wire [2:0]                            m_axi_gmem_ARPROT;
  wire [3:0]                            m_axi_gmem_ARQOS;
  wire [3:0]                            m_axi_gmem_ARREGION;
  wire                                  m_axi_gmem_RREADY;
  wire                                  m_axi_gmem_BREADY;

// Wire Connections
  // OUTPUT PORTS
  assign m_axi_gmem_0_AWVALID    = m_axi_gmem_AWVALID;
  assign m_axi_gmem_0_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_0_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_0_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_0_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_0_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_0_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_0_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_0_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_0_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_0_WVALID     = m_axi_gmem_WVALID;
  assign m_axi_gmem_0_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_0_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_0_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_0_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_0_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_0_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_0_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_0_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_0_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_0_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_0_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_0_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_0_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;;
  assign m_axi_gmem_0_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_1_AWVALID    = m_axi_gmem_AWVALID;
  assign m_axi_gmem_1_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_1_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_1_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_1_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_1_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_1_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_1_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_1_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_1_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_1_WVALID     = m_axi_gmem_WVALID;
  assign m_axi_gmem_1_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_1_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_1_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_1_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_1_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_1_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_1_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_1_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_1_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_1_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_1_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_1_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_1_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_1_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_2_AWVALID    = 1'b0;
  assign m_axi_gmem_2_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_2_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_2_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_2_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_2_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_2_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_2_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_2_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_2_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_2_WVALID     = 1'b0;
  assign m_axi_gmem_2_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_2_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_2_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_2_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_2_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_2_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_2_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_2_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_2_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_2_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_2_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_2_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_2_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_2_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_3_AWVALID    = 1'b0;
  assign m_axi_gmem_3_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_3_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_3_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_3_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_3_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_3_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_3_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_3_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_3_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_3_WVALID     = 1'b0;
  assign m_axi_gmem_3_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_3_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_3_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_3_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_3_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_3_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_3_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_3_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_3_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_3_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_3_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_3_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_3_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_3_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_4_AWVALID    = 1'b0;
  assign m_axi_gmem_4_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_4_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_4_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_4_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_4_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_4_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_4_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_4_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_4_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_4_WVALID     = 1'b0;
  assign m_axi_gmem_4_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_4_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_4_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_4_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_4_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_4_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_4_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_4_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_4_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_4_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_4_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_4_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_4_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_4_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_5_AWVALID    = 1'b0;
  assign m_axi_gmem_5_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_5_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_5_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_5_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_5_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_5_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_5_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_5_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_5_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_5_WVALID     = 1'b0;
  assign m_axi_gmem_5_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_5_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_5_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_5_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_5_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_5_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_5_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_5_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_5_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_5_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_5_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_5_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_5_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_5_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_6_AWVALID    = 1'b0;
  assign m_axi_gmem_6_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_6_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_6_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_6_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_6_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_6_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_6_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_6_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_6_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_6_WVALID     = 1'b0;
  assign m_axi_gmem_6_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_6_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_6_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_6_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_6_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_6_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_6_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_6_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_6_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_6_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_6_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_6_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_6_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_6_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_7_AWVALID    = 1'b0;
  assign m_axi_gmem_7_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_7_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_7_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_7_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_7_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_7_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_7_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_7_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_7_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_7_WVALID     = 1'b0;
  assign m_axi_gmem_7_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_7_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_7_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_7_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_7_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_7_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_7_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_7_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_7_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_7_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_7_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_7_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_7_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_7_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_8_AWVALID    = 1'b0;
  assign m_axi_gmem_8_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_8_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_8_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_8_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_8_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_8_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_8_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_8_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_8_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_8_WVALID     = 1'b0;
  assign m_axi_gmem_8_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_8_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_8_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_8_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_8_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_8_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_8_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_8_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_8_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_8_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_8_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_8_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_8_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_8_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_9_AWVALID    = 1'b0;
  assign m_axi_gmem_9_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_9_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_9_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_9_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_9_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_9_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_9_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_9_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_9_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_9_WVALID     = 1'b0;
  assign m_axi_gmem_9_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_9_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_9_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_9_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_9_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_9_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_9_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_9_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_9_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_9_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_9_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_9_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_9_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_9_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_10_AWVALID    = 1'b0;
  assign m_axi_gmem_10_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_10_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_10_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_10_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_10_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_10_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_10_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_10_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_10_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_10_WVALID     = 1'b0;
  assign m_axi_gmem_10_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_10_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_10_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_10_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_10_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_10_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_10_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_10_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_10_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_10_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_10_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_10_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_10_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_10_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_11_AWVALID    = 1'b0;
  assign m_axi_gmem_11_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_11_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_11_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_11_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_11_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_11_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_11_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_11_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_11_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_11_WVALID     = 1'b0;
  assign m_axi_gmem_11_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_11_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_11_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_11_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_11_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_11_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_11_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_11_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_11_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_11_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_11_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_11_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_11_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_11_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_12_AWVALID    = 1'b0;
  assign m_axi_gmem_12_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_12_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_12_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_12_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_12_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_12_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_12_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_12_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_12_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_12_WVALID     = 1'b0;
  assign m_axi_gmem_12_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_12_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_12_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_12_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_12_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_12_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_12_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_12_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_12_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_12_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_12_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_12_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_12_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_12_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_13_AWVALID    = 1'b0;
  assign m_axi_gmem_13_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_13_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_13_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_13_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_13_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_13_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_13_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_13_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_13_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_13_WVALID     = 1'b0;
  assign m_axi_gmem_13_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_13_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_13_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_13_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_13_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_13_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_13_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_13_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_13_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_13_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_13_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_13_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_13_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_13_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_14_AWVALID    = 1'b0;
  assign m_axi_gmem_14_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_14_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_14_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_14_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_14_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_14_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_14_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_14_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_14_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_14_WVALID     = 1'b0;
  assign m_axi_gmem_14_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_14_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_14_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_14_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_14_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_14_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_14_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_14_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_14_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_14_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_14_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_14_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_14_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_14_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_15_AWVALID    = 1'b0;
  assign m_axi_gmem_15_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_15_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_15_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_15_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_15_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_15_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_15_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_15_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_15_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_15_WVALID     = 1'b0;
  assign m_axi_gmem_15_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_15_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_15_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_15_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_15_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_15_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_15_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_15_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_15_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_15_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_15_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_15_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_15_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_15_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_16_AWVALID    = 1'b0;
  assign m_axi_gmem_16_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_16_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_16_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_16_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_16_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_16_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_16_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_16_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_16_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_16_WVALID     = 1'b0;
  assign m_axi_gmem_16_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_16_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_16_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_16_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_16_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_16_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_16_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_16_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_16_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_16_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_16_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_16_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_16_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_16_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_17_AWVALID    = 1'b0;
  assign m_axi_gmem_17_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_17_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_17_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_17_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_17_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_17_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_17_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_17_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_17_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_17_WVALID     = 1'b0;
  assign m_axi_gmem_17_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_17_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_17_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_17_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_17_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_17_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_17_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_17_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_17_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_17_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_17_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_17_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_17_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_17_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_18_AWVALID    = 1'b0;
  assign m_axi_gmem_18_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_18_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_18_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_18_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_18_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_18_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_18_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_18_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_18_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_18_WVALID     = 1'b0;
  assign m_axi_gmem_18_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_18_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_18_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_18_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_18_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_18_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_18_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_18_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_18_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_18_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_18_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_18_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_18_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_18_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_19_AWVALID    = 1'b0;
  assign m_axi_gmem_19_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_19_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_19_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_19_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_19_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_19_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_19_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_19_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_19_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_19_WVALID     = 1'b0;
  assign m_axi_gmem_19_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_19_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_19_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_19_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_19_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_19_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_19_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_19_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_19_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_19_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_19_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_19_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_19_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_19_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_20_AWVALID    = 1'b0;
  assign m_axi_gmem_20_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_20_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_20_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_20_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_20_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_20_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_20_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_20_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_20_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_20_WVALID     = 1'b0;
  assign m_axi_gmem_20_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_20_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_20_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_20_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_20_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_20_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_20_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_20_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_20_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_20_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_20_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_20_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_20_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_20_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_21_AWVALID    = 1'b0;
  assign m_axi_gmem_21_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_21_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_21_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_21_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_21_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_21_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_21_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_21_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_21_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_21_WVALID     = 1'b0;
  assign m_axi_gmem_21_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_21_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_21_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_21_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_21_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_21_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_21_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_21_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_21_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_21_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_21_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_21_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_21_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_21_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_22_AWVALID    = 1'b0;
  assign m_axi_gmem_22_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_22_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_22_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_22_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_22_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_22_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_22_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_22_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_22_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_22_WVALID     = 1'b0;
  assign m_axi_gmem_22_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_22_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_22_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_22_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_22_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_22_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_22_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_22_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_22_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_22_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_22_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_22_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_22_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_22_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_23_AWVALID    = 1'b0;
  assign m_axi_gmem_23_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_23_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_23_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_23_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_23_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_23_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_23_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_23_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_23_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_23_WVALID     = 1'b0;
  assign m_axi_gmem_23_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_23_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_23_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_23_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_23_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_23_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_23_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_23_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_23_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_23_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_23_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_23_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_23_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_23_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_24_AWVALID    = 1'b0;
  assign m_axi_gmem_24_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_24_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_24_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_24_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_24_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_24_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_24_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_24_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_24_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_24_WVALID     = 1'b0;
  assign m_axi_gmem_24_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_24_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_24_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_24_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_24_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_24_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_24_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_24_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_24_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_24_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_24_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_24_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_24_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_24_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_25_AWVALID    = 1'b0;
  assign m_axi_gmem_25_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_25_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_25_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_25_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_25_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_25_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_25_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_25_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_25_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_25_WVALID     = 1'b0;
  assign m_axi_gmem_25_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_25_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_25_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_25_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_25_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_25_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_25_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_25_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_25_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_25_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_25_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_25_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_25_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_25_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_26_AWVALID    = 1'b0;
  assign m_axi_gmem_26_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_26_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_26_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_26_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_26_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_26_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_26_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_26_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_26_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_26_WVALID     = 1'b0;
  assign m_axi_gmem_26_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_26_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_26_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_26_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_26_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_26_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_26_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_26_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_26_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_26_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_26_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_26_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_26_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_26_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_27_AWVALID    = 1'b0;
  assign m_axi_gmem_27_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_27_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_27_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_27_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_27_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_27_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_27_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_27_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_27_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_27_WVALID     = 1'b0;
  assign m_axi_gmem_27_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_27_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_27_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_27_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_27_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_27_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_27_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_27_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_27_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_27_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_27_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_27_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_27_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_27_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_28_AWVALID    = 1'b0;
  assign m_axi_gmem_28_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_28_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_28_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_28_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_28_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_28_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_28_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_28_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_28_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_28_WVALID     = 1'b0;
  assign m_axi_gmem_28_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_28_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_28_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_28_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_28_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_28_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_28_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_28_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_28_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_28_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_28_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_28_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_28_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_28_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_29_AWVALID    = 1'b0;
  assign m_axi_gmem_29_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_29_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_29_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_29_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_29_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_29_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_29_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_29_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_29_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_29_WVALID     = 1'b0;
  assign m_axi_gmem_29_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_29_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_29_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_29_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_29_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_29_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_29_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_29_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_29_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_29_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_29_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_29_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_29_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_29_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_30_AWVALID    = 1'b0;
  assign m_axi_gmem_30_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_30_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_30_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_30_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_30_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_30_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_30_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_30_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_30_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_30_WVALID     = 1'b0;
  assign m_axi_gmem_30_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_30_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_30_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_30_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_30_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_30_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_30_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_30_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_30_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_30_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_30_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_30_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_30_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_30_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_31_AWVALID    = 1'b0;
  assign m_axi_gmem_31_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_31_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_31_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_31_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_31_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_31_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_31_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_31_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_31_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_31_WVALID     = 1'b0;
  assign m_axi_gmem_31_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_31_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_31_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_31_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_31_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_31_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_31_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_31_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_31_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_31_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_31_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_31_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_31_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_31_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_32_AWVALID    = 1'b0;
  assign m_axi_gmem_32_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_32_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_32_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_32_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_32_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_32_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_32_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_32_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_32_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_32_WVALID     = 1'b0;
  assign m_axi_gmem_32_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_32_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_32_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_32_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_32_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_32_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_32_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_32_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_32_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_32_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_32_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_32_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_32_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_32_BREADY     = m_axi_gmem_BREADY;

  assign m_axi_gmem_33_AWVALID    = 1'b0;
  assign m_axi_gmem_33_AWID       = m_axi_gmem_AWID;
  assign m_axi_gmem_33_AWLEN      = m_axi_gmem_AWLEN;
  assign m_axi_gmem_33_AWSIZE     = m_axi_gmem_AWSIZE;
  assign m_axi_gmem_33_AWBURST    = m_axi_gmem_AWBURST;
  assign m_axi_gmem_33_AWLOCK     = m_axi_gmem_AWLOCK;
  assign m_axi_gmem_33_AWCACHE    = m_axi_gmem_AWCACHE;
  assign m_axi_gmem_33_AWPROT     = m_axi_gmem_AWPROT;
  assign m_axi_gmem_33_AWQOS      = m_axi_gmem_AWQOS;
  assign m_axi_gmem_33_AWREGION   = m_axi_gmem_AWREGION;
  assign m_axi_gmem_33_WVALID     = 1'b0;
  assign m_axi_gmem_33_WSTRB      = m_axi_gmem_WSTRB;
  assign m_axi_gmem_33_WLAST      = m_axi_gmem_WLAST;
  assign m_axi_gmem_33_ARVALID    = m_axi_gmem_ARVALID & m_axi_gmem_ARREADY;
  assign m_axi_gmem_33_ARID       = m_axi_gmem_ARID;
  assign m_axi_gmem_33_ARLEN      = m_axi_gmem_ARLEN;
  assign m_axi_gmem_33_ARSIZE     = m_axi_gmem_ARSIZE;
  assign m_axi_gmem_33_ARBURST    = m_axi_gmem_ARBURST;
  assign m_axi_gmem_33_ARLOCK     = m_axi_gmem_ARLOCK;
  assign m_axi_gmem_33_ARCACHE    = m_axi_gmem_ARCACHE;
  assign m_axi_gmem_33_ARPROT     = m_axi_gmem_ARPROT;
  assign m_axi_gmem_33_ARQOS      = m_axi_gmem_ARQOS;
  assign m_axi_gmem_33_ARREGION   = m_axi_gmem_ARREGION;
  assign m_axi_gmem_33_RREADY     = m_axi_gmem_RREADY & m_axi_gmem_RVALID;
  assign m_axi_gmem_33_BREADY     = m_axi_gmem_BREADY;

  wire m_axi_gmem_ARREADY = m_axi_gmem_0_ARREADY & m_axi_gmem_1_ARREADY & m_axi_gmem_2_ARREADY & m_axi_gmem_3_ARREADY & m_axi_gmem_4_ARREADY & m_axi_gmem_5_ARREADY & m_axi_gmem_6_ARREADY & m_axi_gmem_7_ARREADY & m_axi_gmem_8_ARREADY & m_axi_gmem_9_ARREADY & m_axi_gmem_10_ARREADY & m_axi_gmem_11_ARREADY & m_axi_gmem_12_ARREADY & m_axi_gmem_13_ARREADY & m_axi_gmem_14_ARREADY & m_axi_gmem_15_ARREADY & m_axi_gmem_16_ARREADY &  m_axi_gmem_17_ARREADY &  m_axi_gmem_18_ARREADY &  m_axi_gmem_19_ARREADY &  m_axi_gmem_20_ARREADY &  m_axi_gmem_21_ARREADY &  m_axi_gmem_22_ARREADY &  m_axi_gmem_23_ARREADY &  m_axi_gmem_24_ARREADY &  m_axi_gmem_25_ARREADY &  m_axi_gmem_26_ARREADY &  m_axi_gmem_27_ARREADY &  m_axi_gmem_28_ARREADY &  m_axi_gmem_29_ARREADY &  m_axi_gmem_30_ARREADY &  m_axi_gmem_31_ARREADY &  m_axi_gmem_32_ARREADY &  m_axi_gmem_33_ARREADY;
  wire m_axi_gmem_RVALID = m_axi_gmem_0_RVALID & m_axi_gmem_1_RVALID & m_axi_gmem_2_RVALID & m_axi_gmem_3_RVALID & m_axi_gmem_4_RVALID & m_axi_gmem_5_RVALID & m_axi_gmem_6_RVALID & m_axi_gmem_7_RVALID & m_axi_gmem_8_RVALID & m_axi_gmem_9_RVALID & m_axi_gmem_10_RVALID & m_axi_gmem_11_RVALID & m_axi_gmem_12_RVALID & m_axi_gmem_13_RVALID & m_axi_gmem_14_RVALID & m_axi_gmem_15_RVALID & m_axi_gmem_16_RVALID &  m_axi_gmem_17_RVALID &  m_axi_gmem_18_RVALID &  m_axi_gmem_19_RVALID &  m_axi_gmem_20_RVALID &  m_axi_gmem_21_RVALID &  m_axi_gmem_22_RVALID &  m_axi_gmem_23_RVALID &  m_axi_gmem_24_RVALID &  m_axi_gmem_25_RVALID &  m_axi_gmem_26_RVALID &  m_axi_gmem_27_RVALID &  m_axi_gmem_28_RVALID &  m_axi_gmem_29_RVALID &  m_axi_gmem_30_RVALID &  m_axi_gmem_31_RVALID &  m_axi_gmem_32_RVALID &  m_axi_gmem_33_RVALID; 

krnl_vadd_rtl_int inst_krnl_vadd_rtl_int (
  .ap_clk                 ( ap_clk ),
  .ap_rst_n               ( ap_rst_n ),

  // DATA OUT PORT - SHARED
  .m_axi_gmem_AWVALID     ( m_axi_gmem_AWVALID ),
  .m_axi_gmem_AWID        ( m_axi_gmem_AWID ),
  .m_axi_gmem_AWLEN       ( m_axi_gmem_AWLEN ),
  .m_axi_gmem_AWSIZE      ( m_axi_gmem_AWSIZE ),
  .m_axi_gmem_AWBURST     ( m_axi_gmem_AWBURST ),
  .m_axi_gmem_AWLOCK      ( m_axi_gmem_AWLOCK ),
  .m_axi_gmem_AWCACHE     ( m_axi_gmem_AWCACHE ),
  .m_axi_gmem_AWPROT      ( m_axi_gmem_AWPROT ),
  .m_axi_gmem_AWQOS       ( m_axi_gmem_AWQOS ),
  .m_axi_gmem_AWREGION    ( m_axi_gmem_AWREGION ),
  .m_axi_gmem_WVALID      ( m_axi_gmem_WVALID ),
  .m_axi_gmem_WSTRB       ( m_axi_gmem_WSTRB ),
  .m_axi_gmem_WLAST       ( m_axi_gmem_WLAST ),
  .m_axi_gmem_ARVALID     ( m_axi_gmem_ARVALID ),
  .m_axi_gmem_ARID        ( m_axi_gmem_ARID ),
  .m_axi_gmem_ARLEN       ( m_axi_gmem_ARLEN ),
  .m_axi_gmem_ARSIZE      ( m_axi_gmem_ARSIZE ),
  .m_axi_gmem_ARBURST     ( m_axi_gmem_ARBURST ),
  .m_axi_gmem_ARLOCK      ( m_axi_gmem_ARLOCK ),
  .m_axi_gmem_ARCACHE     ( m_axi_gmem_ARCACHE ),
  .m_axi_gmem_ARPROT      ( m_axi_gmem_ARPROT ),
  .m_axi_gmem_ARQOS       ( m_axi_gmem_ARQOS ),
  .m_axi_gmem_ARREGION    ( m_axi_gmem_ARREGION ),
  .m_axi_gmem_RREADY      ( m_axi_gmem_RREADY ),
  .m_axi_gmem_BREADY      ( m_axi_gmem_BREADY ),

  // DATA IN PORT - SHARED
  .m_axi_gmem_RLAST       ( m_axi_gmem_3_RLAST ),
  .m_axi_gmem_RID         ( m_axi_gmem_3_RID ),
  .m_axi_gmem_RRESP       ( m_axi_gmem_3_RRESP ),
  .m_axi_gmem_BVALID      ( m_axi_gmem_0_BVALID ),
  .m_axi_gmem_BRESP       ( m_axi_gmem_0_BRESP ),
  .m_axi_gmem_BID         ( m_axi_gmem_0_BID ),
  .m_axi_gmem_AWREADY     ( m_axi_gmem_0_AWREADY & m_axi_gmem_1_AWREADY ),
  .m_axi_gmem_WREADY      ( m_axi_gmem_0_WREADY & m_axi_gmem_1_WREADY ),
  .m_axi_gmem_ARREADY     ( m_axi_gmem_ARREADY ),
  .m_axi_gmem_RVALID      ( m_axi_gmem_RVALID ),

  // DATA PORT - INDIVIDUAL
  .m_axi_gmem_0_WDATA       ( m_axi_gmem_0_WDATA ),
  .m_axi_gmem_0_ARADDR      ( m_axi_gmem_0_ARADDR ),
  .m_axi_gmem_0_AWADDR      ( m_axi_gmem_0_AWADDR ),
  .m_axi_gmem_0_RDATA       ( m_axi_gmem_0_RDATA ),
  
  .m_axi_gmem_1_WDATA       ( m_axi_gmem_1_WDATA ),
  .m_axi_gmem_1_ARADDR      ( m_axi_gmem_1_ARADDR ),
  .m_axi_gmem_1_AWADDR      ( m_axi_gmem_1_AWADDR ),
  .m_axi_gmem_1_RDATA       ( m_axi_gmem_1_RDATA ),
  
  .m_axi_gmem_2_ARADDR      ( m_axi_gmem_2_ARADDR ),
  .m_axi_gmem_2_RDATA       ( m_axi_gmem_2_RDATA ),
  .m_axi_gmem_3_ARADDR      ( m_axi_gmem_3_ARADDR ),
  .m_axi_gmem_3_RDATA       ( m_axi_gmem_3_RDATA ),
  .m_axi_gmem_4_ARADDR      ( m_axi_gmem_4_ARADDR ),
  .m_axi_gmem_4_RDATA       ( m_axi_gmem_4_RDATA ),
  .m_axi_gmem_5_ARADDR      ( m_axi_gmem_5_ARADDR ),
  .m_axi_gmem_5_RDATA       ( m_axi_gmem_5_RDATA ),
  .m_axi_gmem_6_ARADDR      ( m_axi_gmem_6_ARADDR ),
  .m_axi_gmem_6_RDATA       ( m_axi_gmem_6_RDATA ),
  .m_axi_gmem_7_ARADDR      ( m_axi_gmem_7_ARADDR ),
  .m_axi_gmem_7_RDATA       ( m_axi_gmem_7_RDATA ),
  .m_axi_gmem_8_ARADDR      ( m_axi_gmem_8_ARADDR ),
  .m_axi_gmem_8_RDATA       ( m_axi_gmem_8_RDATA ),
  .m_axi_gmem_9_ARADDR      ( m_axi_gmem_9_ARADDR ),
  .m_axi_gmem_9_RDATA       ( m_axi_gmem_9_RDATA ),
  .m_axi_gmem_10_ARADDR     ( m_axi_gmem_10_ARADDR ),
  .m_axi_gmem_10_RDATA      ( m_axi_gmem_10_RDATA ),
  .m_axi_gmem_11_ARADDR     ( m_axi_gmem_11_ARADDR ),
  .m_axi_gmem_11_RDATA      ( m_axi_gmem_11_RDATA ),
  .m_axi_gmem_12_ARADDR     ( m_axi_gmem_12_ARADDR ),
  .m_axi_gmem_12_RDATA      ( m_axi_gmem_12_RDATA ),
  .m_axi_gmem_13_ARADDR     ( m_axi_gmem_13_ARADDR ),
  .m_axi_gmem_13_RDATA      ( m_axi_gmem_13_RDATA ),
  .m_axi_gmem_14_ARADDR     ( m_axi_gmem_14_ARADDR ),
  .m_axi_gmem_14_RDATA      ( m_axi_gmem_14_RDATA ),
  .m_axi_gmem_15_ARADDR     ( m_axi_gmem_15_ARADDR ),
  .m_axi_gmem_15_RDATA      ( m_axi_gmem_15_RDATA ),
  .m_axi_gmem_16_ARADDR     ( m_axi_gmem_16_ARADDR ),
  .m_axi_gmem_16_RDATA      ( m_axi_gmem_16_RDATA ),
  .m_axi_gmem_17_ARADDR     ( m_axi_gmem_17_ARADDR ),
  .m_axi_gmem_17_RDATA      ( m_axi_gmem_17_RDATA ),
  .m_axi_gmem_18_ARADDR     ( m_axi_gmem_18_ARADDR ),
  .m_axi_gmem_18_RDATA      ( m_axi_gmem_18_RDATA ),
  .m_axi_gmem_19_ARADDR     ( m_axi_gmem_19_ARADDR ),
  .m_axi_gmem_19_RDATA      ( m_axi_gmem_19_RDATA ),
  .m_axi_gmem_20_ARADDR     ( m_axi_gmem_20_ARADDR ),
  .m_axi_gmem_20_RDATA      ( m_axi_gmem_20_RDATA ),
  .m_axi_gmem_21_ARADDR     ( m_axi_gmem_21_ARADDR ),
  .m_axi_gmem_21_RDATA      ( m_axi_gmem_21_RDATA ),
  .m_axi_gmem_22_ARADDR     ( m_axi_gmem_22_ARADDR ),
  .m_axi_gmem_22_RDATA      ( m_axi_gmem_22_RDATA ),
  .m_axi_gmem_23_ARADDR     ( m_axi_gmem_23_ARADDR ),
  .m_axi_gmem_23_RDATA      ( m_axi_gmem_23_RDATA ),
  .m_axi_gmem_24_ARADDR     ( m_axi_gmem_24_ARADDR ),
  .m_axi_gmem_24_RDATA      ( m_axi_gmem_24_RDATA ),
  .m_axi_gmem_25_ARADDR     ( m_axi_gmem_25_ARADDR ),
  .m_axi_gmem_25_RDATA      ( m_axi_gmem_25_RDATA ),
  .m_axi_gmem_26_ARADDR     ( m_axi_gmem_26_ARADDR ),
  .m_axi_gmem_26_RDATA      ( m_axi_gmem_26_RDATA ),
  .m_axi_gmem_27_ARADDR     ( m_axi_gmem_27_ARADDR ),
  .m_axi_gmem_27_RDATA      ( m_axi_gmem_27_RDATA ),
  .m_axi_gmem_28_ARADDR     ( m_axi_gmem_28_ARADDR ),
  .m_axi_gmem_28_RDATA      ( m_axi_gmem_28_RDATA ),
  .m_axi_gmem_29_ARADDR     ( m_axi_gmem_29_ARADDR ),
  .m_axi_gmem_29_RDATA      ( m_axi_gmem_29_RDATA ),
  .m_axi_gmem_30_ARADDR     ( m_axi_gmem_30_ARADDR ),
  .m_axi_gmem_30_RDATA      ( m_axi_gmem_30_RDATA ),
  .m_axi_gmem_31_ARADDR     ( m_axi_gmem_31_ARADDR ),
  .m_axi_gmem_31_RDATA      ( m_axi_gmem_31_RDATA ),
  .m_axi_gmem_32_ARADDR     ( m_axi_gmem_32_ARADDR ),
  .m_axi_gmem_32_RDATA      ( m_axi_gmem_32_RDATA ),
  .m_axi_gmem_33_ARADDR     ( m_axi_gmem_33_ARADDR ),
  .m_axi_gmem_33_RDATA      ( m_axi_gmem_33_RDATA ),

  .s_axi_control_AWVALID    ( s_axi_control_AWVALID ),
  .s_axi_control_AWREADY    ( s_axi_control_AWREADY ),
  .s_axi_control_AWADDR     ( s_axi_control_AWADDR ),
  .s_axi_control_WVALID     ( s_axi_control_WVALID ),
  .s_axi_control_WREADY     ( s_axi_control_WREADY ),
  .s_axi_control_WDATA      ( s_axi_control_WDATA ),
  .s_axi_control_WSTRB      ( s_axi_control_WSTRB ),
  .s_axi_control_ARVALID    ( s_axi_control_ARVALID ),
  .s_axi_control_ARREADY    ( s_axi_control_ARREADY ),
  .s_axi_control_ARADDR     ( s_axi_control_ARADDR ),
  .s_axi_control_RVALID     ( s_axi_control_RVALID ),
  .s_axi_control_RREADY     ( s_axi_control_RREADY ),
  .s_axi_control_RDATA      ( s_axi_control_RDATA ),
  .s_axi_control_RRESP      ( s_axi_control_RRESP ),
  .s_axi_control_BVALID     ( s_axi_control_BVALID ),
  .s_axi_control_BREADY     ( s_axi_control_BREADY ),
  .s_axi_control_BRESP      ( s_axi_control_BRESP ),
  .interrupt                ( interrupt )
);
endmodule : krnl_vadd_rtl

`default_nettype wire
