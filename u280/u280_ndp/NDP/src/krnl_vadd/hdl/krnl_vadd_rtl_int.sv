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
// Description: This is a example of how to create an RTL Kernel.  The function
// of this module is to add two 32-bit values and produce a result.  The values
// are read from one AXI4 memory mapped master, processed and then written out.
//
// Data flow: axi_read_master->fifo[2]->adder->fifo->axi_write_master
///////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps 

module krnl_vadd_rtl_int (
  // System signals
    input  wire  ap_clk,
    input  wire  ap_rst_n,

  // DATA PORT
    // 0 ~ 1  : PLRAM
    // 3 ~ 33 : HBM
    
    // SHARED PORTS
    // --- OUTPUT PORTS
    output wire                                 m_axi_gmem_AWVALID,
    output wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_AWID,
    output wire [7:0]                           m_axi_gmem_AWLEN,
    output wire [2:0]                           m_axi_gmem_AWSIZE,
    output wire [1:0]                           m_axi_gmem_AWBURST,
    output wire [1:0]                           m_axi_gmem_AWLOCK,
    output wire [3:0]                           m_axi_gmem_AWCACHE,
    output wire [2:0]                           m_axi_gmem_AWPROT,
    output wire [3:0]                           m_axi_gmem_AWQOS,
    output wire [3:0]                           m_axi_gmem_AWREGION,
    output wire                                 m_axi_gmem_WVALID,
    output wire [C_M_AXI_GMEM_DATA_WIDTH/8-1:0] m_axi_gmem_WSTRB,
    output wire                                 m_axi_gmem_WLAST,
    output wire                                 m_axi_gmem_ARVALID,
    output wire [C_M_AXI_GMEM_ID_WIDTH-1:0]     m_axi_gmem_ARID,
    output wire [7:0]                           m_axi_gmem_ARLEN,
    output wire [2:0]                           m_axi_gmem_ARSIZE,
    output wire [1:0]                           m_axi_gmem_ARBURST,
    output wire [1:0]                           m_axi_gmem_ARLOCK,
    output wire [3:0]                           m_axi_gmem_ARCACHE,
    output wire [2:0]                           m_axi_gmem_ARPROT,
    output wire [3:0]                           m_axi_gmem_ARQOS,
    output wire [3:0]                           m_axi_gmem_ARREGION,
    output wire                                 m_axi_gmem_RREADY,
    output wire                                 m_axi_gmem_BREADY,
  
    // --- INPUT PORTS
    input  wire                                 m_axi_gmem_RLAST,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_RID,
    input  wire [1:0]                           m_axi_gmem_RRESP,
    input  wire                                 m_axi_gmem_BVALID,
    input  wire [1:0]                           m_axi_gmem_BRESP,
    input  wire [C_M_AXI_GMEM_ID_WIDTH - 1:0]   m_axi_gmem_BID,
    input  wire                                 m_axi_gmem_AWREADY,
    input  wire                                 m_axi_gmem_WREADY,
    input  wire                                 m_axi_gmem_ARREADY,
    input  wire                                 m_axi_gmem_RVALID,

    // --- Individual Ports
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_0_WDATA,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_0_ARADDR,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_0_AWADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_0_RDATA,
    
    output wire [C_M_AXI_GMEM_DATA_WIDTH-1:0]   m_axi_gmem_1_WDATA,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_1_ARADDR,
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_1_AWADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_1_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_2_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_2_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_3_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_3_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_4_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_4_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_5_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_5_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_6_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_6_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_7_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_7_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_8_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_8_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_9_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_9_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_10_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_10_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_11_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_11_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_12_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_12_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_13_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_13_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_14_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_14_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_15_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_15_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_16_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_16_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_17_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_17_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_18_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_18_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_19_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_19_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_20_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_20_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_21_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_21_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_22_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_22_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_23_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_23_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_24_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_24_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_25_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_25_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_26_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_26_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_27_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_27_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_28_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_28_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_29_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_29_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_30_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_30_RDATA,
    
    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_31_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_31_RDATA,

    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_32_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_32_RDATA,

    output wire [C_M_AXI_GMEM_ADDR_WIDTH-1:0]   m_axi_gmem_33_ARADDR,
    input  wire [C_M_AXI_GMEM_DATA_WIDTH - 1:0] m_axi_gmem_33_RDATA,

  // AXI4-Lite Slave
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



///////////////////////////////////////////////////////////////////////////////
// Local Parameters (constants)
///////////////////////////////////////////////////////////////////////////////
  localparam integer LP_NUM_READ_CHANNELS  = 1;
  localparam integer LP_LENGTH_WIDTH       = 32;
  localparam integer LP_DW_BYTES           = C_M_AXI_GMEM_DATA_WIDTH/8;
  localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
  localparam integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN);
  localparam integer LP_RD_MAX_OUTSTANDING = 3;
  localparam integer LP_RD_FIFO_DEPTH      = LP_AXI_BURST_LEN*(LP_RD_MAX_OUTSTANDING + 1);
  localparam integer LP_WR_FIFO_DEPTH      = LP_AXI_BURST_LEN;

  localparam integer  C_M_AXI_GMEM_ID_WIDTH = 1;
  localparam integer  C_M_AXI_GMEM_ADDR_WIDTH = 64;
  localparam integer  C_M_AXI_GMEM_DATA_WIDTH = 32;

  localparam integer  C_S_AXI_CONTROL_DATA_WIDTH = 32;
  localparam integer  C_S_AXI_CONTROL_ADDR_WIDTH = 10;

  //---Number of PEs in each systolic array---
  localparam ARR_WIDTH = 4;
  localparam ARR_HEIGHT = 4;

  //---Number of Systolic Arrays---
  parameter SYS_WIDTH = 16;
  localparam SYS_HEIGHT = 1;


///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
  //--- AP CONTROL SIGNALS -------------
    logic areset = 1'b0;  
    logic ap_ready;

    logic ap_start;
    logic ap_start_r;
    logic ap_start_pulse;

    logic read_done;
    logic NDP_done;

    logic ap_write_done;
    
    logic ap_done;
    logic ap_done_r;
    logic ap_done_pulse;

    logic ap_idle = 1'b1;

  //--- CONFIGURATION SIGNALS ---------
    wire        relu;
    wire [31:0] length;

  //--- DATA ADDRESSES ----------------
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_a_0;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_a_1;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_0;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_1;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_2;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_3;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_4;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_5;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_6;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_7;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_8;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_9;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_10;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_11;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_12;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_13;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_14;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_15;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_16;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_17;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_18;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_19;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_20;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_21;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_22;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_23;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_24;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_25;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_26;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_27;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_28;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_29;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_30;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_read_b_31;

    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_write_a_0;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_write_a_1;
    logic [C_M_AXI_GMEM_ADDR_WIDTH-1:0] address_write_offset;

  //--- READ MASTER
    logic [LP_NUM_READ_CHANNELS-1:0] rd_tvalid;
    logic [LP_NUM_READ_CHANNELS-1:0] rd_tready_n; 

  //--- READ DATA
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_0;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_1;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_2;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_3;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_4;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_5;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_6;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_7;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_8;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_9;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_10;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_11;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_12;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_13;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_14;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_15;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_16;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_17;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_18;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_19;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_20;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_21;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_22;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_23;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_24;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_25;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_26;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_27;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_28;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_29;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_30;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_31;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_32;
    logic [LP_NUM_READ_CHANNELS-1:0] [C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_tdata_33;

  //-- READ FIFO CONTROL
    logic [LP_NUM_READ_CHANNELS-1:0] ctrl_rd_fifo_prog_full;
    logic [LP_NUM_READ_CHANNELS-1:0] rd_fifo_tvalid_n;
    logic [LP_NUM_READ_CHANNELS-1:0] rd_fifo_tready; 
    logic [LP_NUM_READ_CHANNELS-1:0] [34*C_M_AXI_GMEM_DATA_WIDTH-1:0] rd_fifo_tdata;

  //--- WRITE FIFO
    logic                                 adder_tvalid;
    logic                                 adder_tready_n; 
    logic [2*C_M_AXI_GMEM_DATA_WIDTH-1:0] adder_tdata;
    logic                                 wr_fifo_tvalid_n;
    logic                                 wr_fifo_tready; 

  //--- WRITE DATA
    logic [C_M_AXI_GMEM_DATA_WIDTH-1:0]   wr_fifo_tdata_0;
    logic [C_M_AXI_GMEM_DATA_WIDTH-1:0]   wr_fifo_tdata_1;

///////////////////////////////////////////////////////////////////////////////
// RTL Logic 
///////////////////////////////////////////////////////////////////////////////
  // Tie-off unused AXI protocol features
  assign m_axi_gmem_AWID          = {C_M_AXI_GMEM_ID_WIDTH{1'b0}};
  assign m_axi_gmem_AWBURST       = 2'b01;
  assign m_axi_gmem_AWLOCK        = 2'b00;
  assign m_axi_gmem_AWCACHE       = 4'b0011;
  assign m_axi_gmem_AWPROT        = 3'b000;
  assign m_axi_gmem_AWQOS         = 4'b0000;
  assign m_axi_gmem_AWREGION      = 4'b0000;
  assign m_axi_gmem_ARBURST       = 2'b01;
  assign m_axi_gmem_ARLOCK        = 2'b00;
  assign m_axi_gmem_ARCACHE       = 4'b0011;
  assign m_axi_gmem_ARPROT        = 3'b000;
  assign m_axi_gmem_ARQOS         = 4'b0000;
  assign m_axi_gmem_ARREGION      = 4'b0000;

  // Register and invert reset signal for better timing.
  always @(posedge ap_clk) begin 
    areset <= ~ap_rst_n; 
  end

  //--- PULSE
  //------ AP START
    always @(posedge ap_clk) begin 
      begin 
        ap_start_r <= ap_start;
      end
    end
    assign ap_start_pulse = ap_start & ~ap_start_r;

  //------ AP DONE
    always @(posedge ap_clk) begin 
      begin 
        ap_done_r <= ap_done;
      end
    end
    assign ap_done_pulse = ap_done & ~ap_done_r;

  always @(posedge ap_clk) begin 
    if (areset) begin 
      ap_idle <= 1'b1;
    end
    else begin 
      ap_idle <= ap_done        ? 1'b1 : 
                ap_start_pulse ? 1'b0 : 
                                  ap_idle;
    end
  end

  assign ap_ready = ap_done;
  assign ap_done  = ap_write_done;


//--- MODULES -----------------------------------------------------

// 1. CONTROL INPUT MODULE
krnl_vadd_rtl_control_s_axi #(
  .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH( C_S_AXI_CONTROL_DATA_WIDTH )
) 
inst_krnl_vadd_control_s_axi (
  .AWVALID   ( s_axi_control_AWVALID         ) ,
  .AWREADY   ( s_axi_control_AWREADY         ) ,
  .AWADDR    ( s_axi_control_AWADDR          ) ,
  .WVALID    ( s_axi_control_WVALID          ) ,
  .WREADY    ( s_axi_control_WREADY          ) ,
  .WDATA     ( s_axi_control_WDATA           ) ,
  .WSTRB     ( s_axi_control_WSTRB           ) ,
  .ARVALID   ( s_axi_control_ARVALID         ) ,
  .ARREADY   ( s_axi_control_ARREADY         ) ,
  .ARADDR    ( s_axi_control_ARADDR          ) ,
  .RVALID    ( s_axi_control_RVALID          ) ,
  .RREADY    ( s_axi_control_RREADY          ) ,
  .RDATA     ( s_axi_control_RDATA           ) ,
  .RRESP     ( s_axi_control_RRESP           ) ,
  .BVALID    ( s_axi_control_BVALID          ) ,
  .BREADY    ( s_axi_control_BREADY          ) ,
  .BRESP     ( s_axi_control_BRESP           ) ,
  .ACLK      ( ap_clk                        ) ,
  .ARESET    ( areset                        ) ,
  .ACLK_EN   ( 1'b1                          ) ,
  .ap_start  ( ap_start                      ) ,
  .interrupt ( interrupt                     ) ,
  .ap_ready  ( ap_ready                      ) ,
  .ap_done   ( ap_done                       ) ,
  .ap_idle   ( ap_idle                       ) ,

  // ADDRESSES
  .address_read_a_0    ( address_read_a_0    ) ,
  .address_read_a_1    ( address_read_a_1    ) ,
  .address_read_b_0    ( address_read_b_0    ) ,
  .address_read_b_1    ( address_read_b_1    ) ,
  .address_read_b_2    ( address_read_b_2    ) ,
  .address_read_b_3    ( address_read_b_3    ) ,
  .address_read_b_4    ( address_read_b_4    ) ,
  .address_read_b_5    ( address_read_b_5    ) ,
  .address_read_b_6    ( address_read_b_6    ) ,
  .address_read_b_7    ( address_read_b_7    ) ,
  .address_read_b_8    ( address_read_b_8    ) ,
  .address_read_b_9    ( address_read_b_9    ) ,
  .address_read_b_10   ( address_read_b_10   ) ,
  .address_read_b_11   ( address_read_b_11   ) ,
  .address_read_b_12   ( address_read_b_12   ) ,
  .address_read_b_13   ( address_read_b_13   ) ,
  .address_read_b_14   ( address_read_b_14   ) ,
  .address_read_b_15   ( address_read_b_15   ) ,
  .address_read_b_16   ( address_read_b_16   ) ,
  .address_read_b_17   ( address_read_b_17   ) ,
  .address_read_b_18   ( address_read_b_18   ) ,
  .address_read_b_19   ( address_read_b_19   ) ,
  .address_read_b_20   ( address_read_b_20   ) ,
  .address_read_b_21   ( address_read_b_21   ) ,
  .address_read_b_22   ( address_read_b_22   ) ,
  .address_read_b_23   ( address_read_b_23   ) ,
  .address_read_b_24   ( address_read_b_24   ) ,
  .address_read_b_25   ( address_read_b_25   ) ,
  .address_read_b_26   ( address_read_b_26   ) ,
  .address_read_b_27   ( address_read_b_27   ) ,
  .address_read_b_28   ( address_read_b_28   ) ,
  .address_read_b_29   ( address_read_b_29   ) ,
  .address_read_b_30   ( address_read_b_30   ) ,
  .address_read_b_31   ( address_read_b_31   ) ,

  .address_write_a_0   ( address_write_a_0   ) ,
  .address_write_a_1   ( address_write_a_1   ) ,
  .address_write_offset ( address_write_offset   ) ,

  // Configuartion Signals
  .relu           ( relu                      ) ,
  .length         ( length                    )
);



// AXI4 Read Master
krnl_vadd_rtl_axi_read_master #( 
  .C_ADDR_WIDTH       ( C_M_AXI_GMEM_ADDR_WIDTH ) ,
  .C_DATA_WIDTH       ( C_M_AXI_GMEM_DATA_WIDTH ) ,
  .C_ID_WIDTH         ( C_M_AXI_GMEM_ID_WIDTH   ) ,
  .C_NUM_CHANNELS     ( LP_NUM_READ_CHANNELS    ) ,
  .C_LENGTH_WIDTH     ( LP_LENGTH_WIDTH         ) ,
  .C_BURST_LEN        ( LP_AXI_BURST_LEN        ) ,
  .C_LOG_BURST_LEN    ( LP_LOG_BURST_LEN        ) ,
  .C_MAX_OUTSTANDING  ( LP_RD_MAX_OUTSTANDING   )
)
inst_axi_read_master ( 
  .aclk                ( ap_clk                   ) ,
  .areset              ( areset                   ) ,

  //--- Read Control ------------------------
    .ctrl_start        ( ap_start_pulse           ) ,
    .ctrl_done         ( read_done                ) ,
    .ctrl_length       ( length                   ) ,
    .ctrl_prog_full    ( ctrl_rd_fifo_prog_full   ) ,
    
  //--- READ ADDRESSES -----------------------
    //---- PLRAM
    .ctrl_offset_0     ( address_read_a_0         ) ,
    .ctrl_offset_1     ( address_read_a_1         ) ,
    //---- HBM
    .ctrl_offset_2     ( address_read_b_0         ) ,
    .ctrl_offset_3     ( address_read_b_1         ) ,
    .ctrl_offset_4     ( address_read_b_2         ) ,
    .ctrl_offset_5     ( address_read_b_3         ) ,
    .ctrl_offset_6     ( address_read_b_4         ) ,
    .ctrl_offset_7     ( address_read_b_5         ) ,
    .ctrl_offset_8     ( address_read_b_6         ) ,
    .ctrl_offset_9     ( address_read_b_7         ) ,
    .ctrl_offset_10    ( address_read_b_8         ) ,
    .ctrl_offset_11    ( address_read_b_9         ) ,
    .ctrl_offset_12    ( address_read_b_10        ) ,
    .ctrl_offset_13    ( address_read_b_11        ) ,
    .ctrl_offset_14    ( address_read_b_12        ) ,
    .ctrl_offset_15    ( address_read_b_13        ) ,
    .ctrl_offset_16    ( address_read_b_14        ) ,
    .ctrl_offset_17    ( address_read_b_15        ) ,
    .ctrl_offset_18    ( address_read_b_16        ) ,
    .ctrl_offset_19    ( address_read_b_17        ) ,
    .ctrl_offset_20    ( address_read_b_18        ) ,
    .ctrl_offset_21    ( address_read_b_19        ) ,
    .ctrl_offset_22    ( address_read_b_20        ) ,
    .ctrl_offset_23    ( address_read_b_21        ) ,
    .ctrl_offset_24    ( address_read_b_22        ) ,
    .ctrl_offset_25    ( address_read_b_23        ) ,
    .ctrl_offset_26    ( address_read_b_24        ) ,
    .ctrl_offset_27    ( address_read_b_25        ) ,
    .ctrl_offset_28    ( address_read_b_26        ) ,
    .ctrl_offset_29    ( address_read_b_27        ) ,
    .ctrl_offset_30    ( address_read_b_28        ) ,
    .ctrl_offset_31    ( address_read_b_29        ) ,
    .ctrl_offset_32    ( address_read_b_30        ) ,
    .ctrl_offset_33    ( address_read_b_31        ) ,

  //--- Read Channel (Shared)-----------------------
    .arvalid           ( m_axi_gmem_ARVALID        ) ,
    .arready           ( m_axi_gmem_ARREADY        ) ,
    .arid              ( m_axi_gmem_ARID           ) ,
    .arlen             ( m_axi_gmem_ARLEN          ) ,
    .arsize            ( m_axi_gmem_ARSIZE         ) ,
    .rvalid            ( m_axi_gmem_RVALID         ) ,
    .rready            ( m_axi_gmem_RREADY         ) ,
    .rlast             ( m_axi_gmem_RLAST          ) ,
    .rid               ( m_axi_gmem_RID            ) ,
    .rresp             ( m_axi_gmem_RRESP          ) ,
  //--- Read Address & Data --------------------------
    //---- PLRAM
    .araddr_0          ( m_axi_gmem_0_ARADDR       ) ,
    .rdata_0           ( m_axi_gmem_0_RDATA        ) ,
    .araddr_1          ( m_axi_gmem_1_ARADDR       ) ,
    .rdata_1           ( m_axi_gmem_1_RDATA        ) ,
    //---- HBM
    .araddr_2          ( m_axi_gmem_2_ARADDR       ) ,
    .rdata_2           ( m_axi_gmem_2_RDATA        ) ,
    .araddr_3          ( m_axi_gmem_3_ARADDR       ) ,
    .rdata_3           ( m_axi_gmem_3_RDATA        ) ,
    .araddr_4          ( m_axi_gmem_4_ARADDR       ) ,
    .rdata_4           ( m_axi_gmem_4_RDATA        ) ,
    .araddr_5          ( m_axi_gmem_5_ARADDR       ) ,
    .rdata_5           ( m_axi_gmem_5_RDATA        ) ,
    .araddr_6          ( m_axi_gmem_6_ARADDR       ) ,
    .rdata_6           ( m_axi_gmem_6_RDATA        ) ,
    .araddr_7          ( m_axi_gmem_7_ARADDR       ) ,
    .rdata_7           ( m_axi_gmem_7_RDATA        ) ,
    .araddr_8          ( m_axi_gmem_8_ARADDR       ) ,
    .rdata_8           ( m_axi_gmem_8_RDATA        ) ,
    .araddr_9          ( m_axi_gmem_9_ARADDR       ) ,
    .rdata_9           ( m_axi_gmem_9_RDATA        ) ,
    .araddr_10         ( m_axi_gmem_10_ARADDR      ) ,
    .rdata_10          ( m_axi_gmem_10_RDATA       ) ,
    .araddr_11         ( m_axi_gmem_11_ARADDR      ) ,
    .rdata_11          ( m_axi_gmem_11_RDATA       ) ,
    .araddr_12         ( m_axi_gmem_12_ARADDR      ) ,
    .rdata_12          ( m_axi_gmem_12_RDATA       ) ,
    .araddr_13         ( m_axi_gmem_13_ARADDR      ) ,
    .rdata_13          ( m_axi_gmem_13_RDATA       ) ,
    .araddr_14         ( m_axi_gmem_14_ARADDR      ) ,
    .rdata_14          ( m_axi_gmem_14_RDATA       ) ,
    .araddr_15         ( m_axi_gmem_15_ARADDR      ) ,
    .rdata_15          ( m_axi_gmem_15_RDATA       ) ,
    .araddr_16         ( m_axi_gmem_16_ARADDR      ) ,
    .rdata_16          ( m_axi_gmem_16_RDATA       ) ,
    .araddr_17         ( m_axi_gmem_17_ARADDR      ) ,
    .rdata_17          ( m_axi_gmem_17_RDATA       ) ,
    .araddr_18         ( m_axi_gmem_18_ARADDR      ) ,
    .rdata_18          ( m_axi_gmem_18_RDATA       ) ,
    .araddr_19         ( m_axi_gmem_19_ARADDR      ) ,
    .rdata_19          ( m_axi_gmem_19_RDATA       ) ,
    .araddr_20         ( m_axi_gmem_20_ARADDR      ) ,
    .rdata_20          ( m_axi_gmem_20_RDATA       ) ,
    .araddr_21         ( m_axi_gmem_21_ARADDR      ) ,
    .rdata_21          ( m_axi_gmem_21_RDATA       ) ,
    .araddr_22         ( m_axi_gmem_22_ARADDR      ) ,
    .rdata_22          ( m_axi_gmem_22_RDATA       ) ,
    .araddr_23         ( m_axi_gmem_23_ARADDR      ) ,
    .rdata_23          ( m_axi_gmem_23_RDATA       ) ,
    .araddr_24         ( m_axi_gmem_24_ARADDR      ) ,
    .rdata_24          ( m_axi_gmem_24_RDATA       ) ,
    .araddr_25         ( m_axi_gmem_25_ARADDR      ) ,
    .rdata_25          ( m_axi_gmem_25_RDATA       ) ,
    .araddr_26         ( m_axi_gmem_26_ARADDR      ) ,
    .rdata_26          ( m_axi_gmem_26_RDATA       ) ,
    .araddr_27         ( m_axi_gmem_27_ARADDR      ) ,
    .rdata_27          ( m_axi_gmem_27_RDATA       ) ,
    .araddr_28         ( m_axi_gmem_28_ARADDR      ) ,
    .rdata_28          ( m_axi_gmem_28_RDATA       ) ,
    .araddr_29         ( m_axi_gmem_29_ARADDR      ) ,
    .rdata_29          ( m_axi_gmem_29_RDATA       ) ,
    .araddr_30         ( m_axi_gmem_30_ARADDR      ) ,
    .rdata_30          ( m_axi_gmem_30_RDATA       ) ,
    .araddr_31         ( m_axi_gmem_31_ARADDR      ) ,
    .rdata_31          ( m_axi_gmem_31_RDATA       ) ,
    .araddr_32         ( m_axi_gmem_32_ARADDR      ) ,
    .rdata_32          ( m_axi_gmem_32_RDATA       ) ,
    .araddr_33         ( m_axi_gmem_33_ARADDR      ) ,
    .rdata_33          ( m_axi_gmem_33_RDATA       ) ,

  //--- Data Pass ----------------------------------
    .m_tvalid          ( rd_tvalid                 ) ,
    .m_tready          ( ~rd_tready_n              ) ,

    //---- PLRAM (Activation Data)
    .m_tdata_0         ( rd_tdata_0                ) ,
    .m_tdata_1         ( rd_tdata_1                ) ,
    //---- HBM   (Weight Data)
    .m_tdata_2         ( rd_tdata_2                ) ,
    .m_tdata_3         ( rd_tdata_3                ) ,
    .m_tdata_4         ( rd_tdata_4                ) ,
    .m_tdata_5         ( rd_tdata_5                ) ,
    .m_tdata_6         ( rd_tdata_6                ) ,
    .m_tdata_7         ( rd_tdata_7                ) ,
    .m_tdata_8         ( rd_tdata_8                ) ,
    .m_tdata_9         ( rd_tdata_9                ) ,
    .m_tdata_10        ( rd_tdata_10               ) ,
    .m_tdata_11        ( rd_tdata_11               ) ,
    .m_tdata_12        ( rd_tdata_12               ) ,
    .m_tdata_13        ( rd_tdata_13               ) ,
    .m_tdata_14        ( rd_tdata_14               ) ,
    .m_tdata_15        ( rd_tdata_15               ) ,
    .m_tdata_16        ( rd_tdata_16               ) ,
    .m_tdata_17        ( rd_tdata_17               ) ,
    .m_tdata_18        ( rd_tdata_18               ) ,
    .m_tdata_19        ( rd_tdata_19               ) ,
    .m_tdata_20        ( rd_tdata_20               ) ,
    .m_tdata_21        ( rd_tdata_21               ) ,
    .m_tdata_22        ( rd_tdata_22               ) ,
    .m_tdata_23        ( rd_tdata_23               ) ,
    .m_tdata_24        ( rd_tdata_24               ) ,
    .m_tdata_25        ( rd_tdata_25               ) ,
    .m_tdata_26        ( rd_tdata_26               ) ,
    .m_tdata_27        ( rd_tdata_27               ) ,
    .m_tdata_28        ( rd_tdata_28               ) ,
    .m_tdata_29        ( rd_tdata_29               ) ,
    .m_tdata_30        ( rd_tdata_30               ) ,
    .m_tdata_31        ( rd_tdata_31               ) ,
    .m_tdata_32        ( rd_tdata_32               ) ,
    .m_tdata_33        ( rd_tdata_33               ) 
);

xpm_fifo_sync # (
  .FIFO_MEMORY_TYPE    ( "auto"                     ),    //string; "auto", "block", "distributed", or "ultra";
  .ECC_MODE            ( "no_ecc"                   ),    //string; "no_ecc" or "en_ecc";
  .FIFO_WRITE_DEPTH    ( LP_RD_FIFO_DEPTH           ),    //positive integer
  .WRITE_DATA_WIDTH    ( C_M_AXI_GMEM_DATA_WIDTH*34 ),    //positive integer
  .WR_DATA_COUNT_WIDTH ( $clog2(LP_RD_FIFO_DEPTH)+1 ),    //positive integer, Not used
  .PROG_FULL_THRESH    ( LP_AXI_BURST_LEN-2         ),    //positive integer
  .FULL_RESET_VALUE    ( 1                          ),    //positive integer; 0 or 1
  .READ_MODE           ( "fwft"                     ),    //string; "std" or "fwft";
  .FIFO_READ_LATENCY   ( 1                          ),    //positive integer;
  .READ_DATA_WIDTH     ( C_M_AXI_GMEM_DATA_WIDTH*34 ),    //positive integer
  .RD_DATA_COUNT_WIDTH ( $clog2(LP_RD_FIFO_DEPTH)+1 ),    //positive integer, not used
  .PROG_EMPTY_THRESH   ( 10                         ),    //positive integer, not used 
  .DOUT_RESET_VALUE    ( "0"                        ),    //string, don't care
  .WAKEUP_TIME         ( 0                          )     //positive integer; 0 or 2;
) inst_rd_xpm_fifo_sync[LP_NUM_READ_CHANNELS-1:0] (
  .sleep         ( 1'b0                    ) ,
  .rst           ( areset                  ) ,
  .wr_clk        ( ap_clk                  ) ,
  .wr_en         ( rd_tvalid               ) ,
  .din           ( { rd_tdata_33, rd_tdata_32, rd_tdata_31, rd_tdata_30, 
                     rd_tdata_29, rd_tdata_28, rd_tdata_27, rd_tdata_26, 
                     rd_tdata_25, rd_tdata_24, rd_tdata_23, rd_tdata_22, 
                     rd_tdata_21, rd_tdata_20, rd_tdata_19, rd_tdata_18, 
                     rd_tdata_17, rd_tdata_16, rd_tdata_15, rd_tdata_14, 
                     rd_tdata_13, rd_tdata_12, rd_tdata_11, rd_tdata_10, 
                     rd_tdata_9,  rd_tdata_8,  rd_tdata_7,  rd_tdata_6,  
                     rd_tdata_5,  rd_tdata_4,  rd_tdata_3,  rd_tdata_2,  
                     rd_tdata_1,  rd_tdata_0 }) ,
  .full          ( rd_tready_n             ) ,
  .prog_full     ( ctrl_rd_fifo_prog_full  ) ,
  .wr_data_count (                         ) ,
  .overflow      (                         ) ,
  .wr_rst_busy   (                         ) ,
  .rd_en         ( rd_fifo_tready          ) ,
  .dout          ( rd_fifo_tdata           ) ,
  .empty         ( rd_fifo_tvalid_n        ) ,
  .prog_empty    (                         ) ,
  .rd_data_count (                         ) ,
  .underflow     (                         ) ,
  .rd_rst_busy   (                         ) ,
  .injectsbiterr ( 1'b0                    ) ,
  .injectdbiterr ( 1'b0                    ) ,
  .sbiterr       (                         ) ,
  .dbiterr       (                         ) 
);


//--- NDP CORE -------------------------------
NDP_core #(
  //---Number of PEs in each systolic array---
	.ARR_WIDTH    ( ARR_WIDTH  ),
	.ARR_HEIGHT   ( ARR_HEIGHT ),

	//---Number of Systolic Arrays---
	.SYS_WIDTH    ( SYS_WIDTH  ),
	.SYS_HEIGHT   ( SYS_HEIGHT )
) NDP_core0 (
  //--- Clock & Reset ---
  .axi_aclk		      ( ap_clk                    ) ,
  .axi_aresetn	    ( ~(areset | ap_start_pulse) ) ,
  .clock_pl         ( ap_clk                    ) ,

  .is_relu_in		    ( relu                      ) ,
  .length_in        ( length                    ) ,

  .NDP_done         ( NDP_done                  ) ,

  //--- Data In (AXI4-Stream)---
  .s_axis_tdata	    ( rd_fifo_tdata[0]          ) ,
  .s_axis_tlast	    (                           ) ,
  .s_axis_tvalid	  ( ~rd_fifo_tvalid_n[0]      ) ,
  .s_axis_tready	  ( rd_fifo_tready[0]         ) ,

  //--- Data Out (AXI4-Stream) ---
  .m_axis_tdata	    ( adder_tdata               ) ,
  .m_axis_tlast	    (                           ) ,
  .m_axis_tvalid	  ( adder_tvalid              ) ,
  .m_axis_tready	  ( ~adder_tready_n           )
);

xpm_fifo_sync # (
  .FIFO_MEMORY_TYPE          ( "auto"                     ) ,       //string; "auto", "block", "distributed", or "ultra";
  .ECC_MODE                  ( "no_ecc"                   ) ,       //string; "no_ecc" or "en_ecc";
  .FIFO_WRITE_DEPTH          ( LP_WR_FIFO_DEPTH           ) ,       //positive integer
  .WRITE_DATA_WIDTH          ( C_M_AXI_GMEM_DATA_WIDTH*2  ) ,       //positive integer
  .WR_DATA_COUNT_WIDTH       ( $clog2(LP_WR_FIFO_DEPTH)   ) ,       //positive integer, Not used
  .PROG_FULL_THRESH          ( 10                         ) ,       //positive integer, Not used 
  .FULL_RESET_VALUE          ( 1                          ) ,       //positive integer; 0 or 1
  .READ_MODE                 ( "fwft"                     ) ,       //string; "std" or "fwft";
  .FIFO_READ_LATENCY         ( 1                          ) ,       //positive integer;
  .READ_DATA_WIDTH           ( C_M_AXI_GMEM_DATA_WIDTH*2 ) ,       //positive integer
  .RD_DATA_COUNT_WIDTH       ( $clog2(LP_WR_FIFO_DEPTH)   ) ,       //positive integer, not used
  .PROG_EMPTY_THRESH         ( 10                         ) ,       //positive integer, not used 
  .DOUT_RESET_VALUE          ( "0"                        ) ,       //string, don't care
  .WAKEUP_TIME               ( 0                          )         //positive integer; 0 or 2;
) inst_wr_xpm_fifo_sync (
  .sleep         ( 1'b0                    ) ,
  .rst           ( areset                  ) ,
  .wr_clk        ( ap_clk                  ) ,
  .wr_en         ( adder_tvalid            ) ,
  .din           ( adder_tdata             ) ,
  .full          ( adder_tready_n          ) ,
  .prog_full     (                         ) ,
  .wr_data_count (                         ) ,
  .overflow      (                         ) ,
  .wr_rst_busy   (                         ) ,
  .rd_en         ( wr_fifo_tready          ) ,
  .dout          ( { wr_fifo_tdata_1 ,  
                     wr_fifo_tdata_0     } ) ,
  .empty         ( wr_fifo_tvalid_n        ) ,
  .prog_empty    (                         ) ,
  .rd_data_count (                         ) ,
  .underflow     (                         ) ,
  .rd_rst_busy   (                         ) ,
  .injectsbiterr ( 1'b0                    ) ,
  .injectdbiterr ( 1'b0                    ) ,
  .sbiterr       (                         ) ,
  .dbiterr       (                         ) 

);

// AXI4 Write Master
krnl_vadd_rtl_axi_write_master #( 
  .C_ADDR_WIDTH       ( C_M_AXI_GMEM_ADDR_WIDTH ) ,
  .C_DATA_WIDTH       ( C_M_AXI_GMEM_DATA_WIDTH ) ,
  .C_MAX_LENGTH_WIDTH ( LP_LENGTH_WIDTH         ) ,
  .C_BURST_LEN        ( LP_AXI_BURST_LEN        ) ,
  .C_LOG_BURST_LEN    ( LP_LOG_BURST_LEN        ) 
)
inst_axi_write_master ( 
  .aclk           ( ap_clk                  ) ,
  .areset         ( areset                  ) ,

  .ctrl_start     ( ap_start_pulse          ) ,
  .ctrl_offset_0  ( address_write_a_0 + address_write_offset ) ,
  .ctrl_offset_1  ( address_write_a_1 + address_write_offset ) ,

  .ctrl_length    ( ARR_WIDTH * SYS_WIDTH   ) ,
  .ctrl_done      ( ap_write_done           ) ,

  .awvalid        ( m_axi_gmem_AWVALID      ) ,
  .awready        ( m_axi_gmem_AWREADY      ) ,
  .awaddr_0       ( m_axi_gmem_0_AWADDR     ) ,
  .awaddr_1       ( m_axi_gmem_1_AWADDR     ) ,

  .awlen          ( m_axi_gmem_AWLEN        ) ,
  .awsize         ( m_axi_gmem_AWSIZE       ) ,

  .s_tvalid       ( ~wr_fifo_tvalid_n       ) ,
  .s_tready       ( wr_fifo_tready          ) ,
  .s_tdata_0      ( wr_fifo_tdata_0         ) ,
  .s_tdata_1      ( wr_fifo_tdata_1         ) ,

  .wvalid         ( m_axi_gmem_WVALID       ) ,
  .wready         ( m_axi_gmem_WREADY       ) ,
  .wstrb          ( m_axi_gmem_WSTRB        ) ,
  .wlast          ( m_axi_gmem_WLAST        ) ,
  .wdata_0        ( m_axi_gmem_0_WDATA      ) ,
  .wdata_1        ( m_axi_gmem_1_WDATA      ) ,

  .bvalid         ( m_axi_gmem_BVALID       ) ,
  .bready         ( m_axi_gmem_BREADY       ) ,
  .bresp          ( m_axi_gmem_BRESP        ) 
);


endmodule : krnl_vadd_rtl_int

`default_nettype wire
