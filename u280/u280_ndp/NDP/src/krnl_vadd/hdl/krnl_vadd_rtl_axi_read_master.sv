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
// Description: This is a multi-threaded AXI4 read master.  Each channel will
// issue commands on a different IDs.  As a result data may arrive out of 
// order.  The amount of data requested is equal to the ctrl_length variable.
// Prog full is set and sampled such that the FIFO will never overflow.  Thus 
// rready can be always asserted for better timing.
///////////////////////////////////////////////////////////////////////////////

`default_nettype none

module krnl_vadd_rtl_axi_read_master #( 
  parameter integer C_ID_WIDTH         = 1,   // Must be >= $clog2(C_NUM_CHANNELS)
  parameter integer C_ADDR_WIDTH       = 64,
  parameter integer C_DATA_WIDTH       = 32,
  parameter integer C_NUM_CHANNELS     = 2,   // Only 2 tested.
  parameter integer C_LENGTH_WIDTH     = 32,  
  parameter integer C_BURST_LEN        = 256, // Max AXI burst length for read commands
  parameter integer C_LOG_BURST_LEN    = 8,
  parameter integer C_MAX_OUTSTANDING  = 3 
)
(
  // System signals
  input  wire                                          aclk,
  input  wire                                          areset,

  //--- Read Control
    input  wire                                          ctrl_start, 
    output wire                                          ctrl_done, 
    input  wire                     [C_LENGTH_WIDTH-1:0] ctrl_length,
    input  wire [C_NUM_CHANNELS-1:0]                     ctrl_prog_full,
  //--- Read Addresses
    //---- PLRAM ------
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_0,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_1,
    //---- HBM --------
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_2,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_3,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_4,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_5,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_6,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_7,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_8,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_9,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_10,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_11,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_12,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_13,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_14,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_15,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_16,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_17,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_18,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_19,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_20,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_21,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_22,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_23,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_24,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_25,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_26,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_27,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_28,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_29,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_30,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_31,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_32,
    input  wire [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset_33,

  //--- Read Channel ----------------------                          
    output wire                                          arvalid,
    input  wire                                          arready,
    output wire [C_ID_WIDTH-1:0]                         arid,
    output wire [7:0]                                    arlen,
    output wire [2:0]                                    arsize,
    input  wire                                          rvalid,
    output wire                                          rready,
    input  wire                                          rlast,
    input  wire [C_ID_WIDTH - 1:0]                       rid,
    input  wire [1:0]                                    rresp,
  //--- Read Address & Data -----------------
    //---- PLRAM ----------------
    output wire [C_ADDR_WIDTH-1:0]                       araddr_0,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_0,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_1,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_1,
    //---- HBM ------------------
    output wire [C_ADDR_WIDTH-1:0]                       araddr_2,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_2,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_3,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_3,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_4,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_4,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_5,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_5,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_6,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_6,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_7,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_7,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_8,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_8,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_9,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_9,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_10,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_10,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_11,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_11,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_12,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_12,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_13,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_13,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_14,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_14,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_15,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_15,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_16,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_16,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_17,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_17,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_18,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_18,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_19,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_19,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_20,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_20,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_21,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_21,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_22,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_22,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_23,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_23,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_24,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_24,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_25,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_25,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_26,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_26,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_27,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_27,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_28,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_28,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_29,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_29,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_30,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_30,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_31,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_31,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_32,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_32,
    output wire [C_ADDR_WIDTH-1:0]                       araddr_33,
    input  wire [C_DATA_WIDTH - 1:0]                     rdata_33,

  //--- Data Pass ----------------------------------------
    output wire [C_NUM_CHANNELS-1:0]                     m_tvalid,
    input  wire [C_NUM_CHANNELS-1:0]                     m_tready,
    //---- PLRAM
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_0,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_1,
    //---- HBM
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_2,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_3,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_4,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_5,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_6,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_7,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_8,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_9,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_10,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_11,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_12,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_13,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_14,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_15,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_16,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_17,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_18,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_19,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_20,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_21,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_22,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_23,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_24,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_25,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_26,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_27,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_28,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_29,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_30,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_31,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_32,
    output wire [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata_33
);

timeunit 1ps; 
timeprecision 1ps; 

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_MAX_OUTSTANDING_CNTR_WIDTH = $clog2(C_MAX_OUTSTANDING+1); 
localparam integer LP_TRANSACTION_CNTR_WIDTH = C_LENGTH_WIDTH-C_LOG_BURST_LEN;

///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
// Control logic
logic [C_NUM_CHANNELS-1:0]            done = '0;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_full_bursts;
logic                                 num_partial_bursts;
logic                                 start    = 1'b0;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_transactions;
logic                                 has_partial_burst;
logic [C_LOG_BURST_LEN-1:0]           final_burst_len;
logic                                 single_transaction;
logic                                 ar_idle = 1'b1;
logic                                 ar_done;
// AXI Read Address Channel
logic                                                         fifo_stall;
logic                                                         arxfer;
logic                                                         arvalid_r = 1'b0; 

logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_0;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_1;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_2;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_3;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_4;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_5;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_6;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_7;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_8;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_9;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_10;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_11;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_12;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_13;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_14;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_15;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_16;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_17;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_18;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_19;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_20;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_21;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_22;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_23;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_24;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_25;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_26;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_27;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_28;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_29;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_30;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_31;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_32;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]                  addr_33;


logic [C_ID_WIDTH-1:0]                                        id = {C_ID_WIDTH{1'b0}};
logic [LP_TRANSACTION_CNTR_WIDTH-1:0]                         ar_transactions_to_go;
logic                                                         ar_final_transaction;
logic [C_NUM_CHANNELS-1:0]                                    incr_ar_to_r_cnt;
logic [C_NUM_CHANNELS-1:0]                                    decr_ar_to_r_cnt;
logic [C_NUM_CHANNELS-1:0]                                    stall_ar;
logic [C_NUM_CHANNELS-1:0][LP_MAX_OUTSTANDING_CNTR_WIDTH-1:0] outstanding_vacancy_count;
// AXI Data Channel
logic [C_NUM_CHANNELS-1:0]                                tvalid;

logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_0;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_1;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_2;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_3;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_4;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_5;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_6;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_7;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_8;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_9;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_10;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_11;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_12;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_13;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_14;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_15;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_16;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_17;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_18;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_19;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_20;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_21;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_22;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_23;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_24;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_25;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_26;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_27;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_28;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_29;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_30;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_31;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_32;
logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]              tdata_33;


logic                                                     rxfer;
logic [C_NUM_CHANNELS-1:0]                                decr_r_transaction_cntr;
logic [C_NUM_CHANNELS-1:0][LP_TRANSACTION_CNTR_WIDTH-1:0] r_transactions_to_go;
logic [C_NUM_CHANNELS-1:0]                                r_final_transaction;
///////////////////////////////////////////////////////////////////////////////
// Control Logic 
///////////////////////////////////////////////////////////////////////////////

always @(posedge aclk) begin
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin 
    done[i] <= rxfer & rlast & (rid == i) & r_final_transaction[i] ? 1'b1 : 
          ctrl_done ? 1'b0 : done[i]; 
  end
end
assign ctrl_done = &done;

// Determine how many full burst to issue and if there are any partial bursts.
assign num_full_bursts = ctrl_length[C_LOG_BURST_LEN+:C_LENGTH_WIDTH-C_LOG_BURST_LEN];
assign num_partial_bursts = ctrl_length[0+:C_LOG_BURST_LEN] ? 1'b1 : 1'b0; 

always @(posedge aclk) begin 
  start <= ctrl_start;
  num_transactions <= (num_partial_bursts == 1'b0) ? num_full_bursts - 1'b1 : num_full_bursts;
  has_partial_burst <= num_partial_bursts;
  final_burst_len <=  ctrl_length[0+:C_LOG_BURST_LEN] - 1'b1;
end

// Special case if there is only 1 AXI transaction. 
assign single_transaction = (num_transactions == {LP_TRANSACTION_CNTR_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////////////////////////////
// AXI Read Address Channel
///////////////////////////////////////////////////////////////////////////////
assign arvalid = arvalid_r;

assign araddr_0 = addr_0[id];
assign araddr_1 = addr_1[id];
assign araddr_2 = addr_2[id];
assign araddr_3 = addr_3[id];
assign araddr_4 = addr_4[id];
assign araddr_5 = addr_5[id];
assign araddr_6 = addr_6[id];
assign araddr_7 = addr_7[id];
assign araddr_8 = addr_8[id];
assign araddr_9 = addr_9[id];
assign araddr_10 = addr_10[id];
assign araddr_11 = addr_11[id];
assign araddr_12 = addr_12[id];
assign araddr_13 = addr_13[id];
assign araddr_14 = addr_14[id];
assign araddr_15 = addr_15[id];
assign araddr_16 = addr_16[id];
assign araddr_17 = addr_17[id];
assign araddr_18 = addr_18[id];
assign araddr_19 = addr_19[id];
assign araddr_20 = addr_20[id];
assign araddr_21 = addr_21[id];
assign araddr_22 = addr_22[id];
assign araddr_23 = addr_23[id];
assign araddr_24 = addr_24[id];
assign araddr_25 = addr_25[id];
assign araddr_26 = addr_26[id];
assign araddr_27 = addr_27[id];
assign araddr_28 = addr_28[id];
assign araddr_29 = addr_29[id];
assign araddr_30 = addr_30[id];
assign araddr_31 = addr_31[id];
assign araddr_32 = addr_32[id];
assign araddr_33 = addr_33[id];



assign arlen  = ar_final_transaction || (start & single_transaction) ? final_burst_len : C_BURST_LEN - 1;
assign arsize = $clog2((C_DATA_WIDTH/8));
assign arid   = id;

assign arxfer = arvalid & arready;
assign fifo_stall = ctrl_prog_full[id];

always @(posedge aclk) begin 
  if (areset) begin 
    arvalid_r <= 1'b0;
  end
  else begin
    arvalid_r <= ~ar_idle & ~stall_ar[id] & ~arvalid_r & ~fifo_stall ? 1'b1 : 
                 arready ? 1'b0 : arvalid_r;
  end
end

// When ar_idle, there are no transactions to issue.
always @(posedge aclk) begin 
  if (areset) begin 
    ar_idle <= 1'b1; 
  end
  else begin 
    ar_idle <= start   ? 1'b0 :
               ar_done ? 1'b1 : 
                         ar_idle;
  end
end

// Increment to next address after each transaction is issued.
always @(posedge aclk) begin 
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
addr_0[i] <= ctrl_start          ? ctrl_offset_0[i] :
               arxfer && (id == i) ? addr_0[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_0[i];
    addr_1[i] <= ctrl_start          ? ctrl_offset_1[i] :
               arxfer && (id == i) ? addr_1[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_1[i];
    addr_2[i] <= ctrl_start          ? ctrl_offset_2[i] :
               arxfer && (id == i) ? addr_2[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_2[i];
    addr_3[i] <= ctrl_start          ? ctrl_offset_3[i] :
               arxfer && (id == i) ? addr_3[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_3[i];
    addr_4[i] <= ctrl_start          ? ctrl_offset_4[i] :
               arxfer && (id == i) ? addr_4[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_4[i];
    addr_5[i] <= ctrl_start          ? ctrl_offset_5[i] :
               arxfer && (id == i) ? addr_5[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_5[i];
    addr_6[i] <= ctrl_start          ? ctrl_offset_6[i] :
               arxfer && (id == i) ? addr_6[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_6[i];
    addr_7[i] <= ctrl_start          ? ctrl_offset_7[i] :
               arxfer && (id == i) ? addr_7[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_7[i];
    addr_8[i] <= ctrl_start          ? ctrl_offset_8[i] :
               arxfer && (id == i) ? addr_8[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_8[i];
    addr_9[i] <= ctrl_start          ? ctrl_offset_9[i] :
               arxfer && (id == i) ? addr_9[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_9[i];
    addr_10[i] <= ctrl_start          ? ctrl_offset_10[i] :
               arxfer && (id == i) ? addr_10[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_10[i];
    addr_11[i] <= ctrl_start          ? ctrl_offset_11[i] :
               arxfer && (id == i) ? addr_11[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_11[i];
    addr_12[i] <= ctrl_start          ? ctrl_offset_12[i] :
               arxfer && (id == i) ? addr_12[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_12[i];
    addr_13[i] <= ctrl_start          ? ctrl_offset_13[i] :
               arxfer && (id == i) ? addr_13[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_13[i];
    addr_14[i] <= ctrl_start          ? ctrl_offset_14[i] :
               arxfer && (id == i) ? addr_14[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_14[i];
    addr_15[i] <= ctrl_start          ? ctrl_offset_15[i] :
               arxfer && (id == i) ? addr_15[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_15[i];
    addr_16[i] <= ctrl_start          ? ctrl_offset_16[i] :
               arxfer && (id == i) ? addr_16[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_16[i];
    addr_17[i] <= ctrl_start          ? ctrl_offset_17[i] :
               arxfer && (id == i) ? addr_17[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_17[i];
    addr_18[i] <= ctrl_start          ? ctrl_offset_18[i] :
               arxfer && (id == i) ? addr_18[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_18[i];
    addr_19[i] <= ctrl_start          ? ctrl_offset_19[i] :
               arxfer && (id == i) ? addr_19[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_19[i];
    addr_20[i] <= ctrl_start          ? ctrl_offset_20[i] :
               arxfer && (id == i) ? addr_20[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_20[i];
    addr_21[i] <= ctrl_start          ? ctrl_offset_21[i] :
               arxfer && (id == i) ? addr_21[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_21[i];
    addr_22[i] <= ctrl_start          ? ctrl_offset_22[i] :
               arxfer && (id == i) ? addr_22[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_22[i];
    addr_23[i] <= ctrl_start          ? ctrl_offset_23[i] :
               arxfer && (id == i) ? addr_23[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_23[i];
    addr_24[i] <= ctrl_start          ? ctrl_offset_24[i] :
               arxfer && (id == i) ? addr_24[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_24[i];
    addr_25[i] <= ctrl_start          ? ctrl_offset_25[i] :
               arxfer && (id == i) ? addr_25[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_25[i];
    addr_26[i] <= ctrl_start          ? ctrl_offset_26[i] :
               arxfer && (id == i) ? addr_26[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_26[i];
    addr_27[i] <= ctrl_start          ? ctrl_offset_27[i] :
               arxfer && (id == i) ? addr_27[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_27[i];
    addr_28[i] <= ctrl_start          ? ctrl_offset_28[i] :
               arxfer && (id == i) ? addr_28[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_28[i];
    addr_29[i] <= ctrl_start          ? ctrl_offset_29[i] :
               arxfer && (id == i) ? addr_29[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_29[i];
    addr_30[i] <= ctrl_start          ? ctrl_offset_30[i] :
               arxfer && (id == i) ? addr_30[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_30[i];
    addr_31[i] <= ctrl_start          ? ctrl_offset_31[i] :
               arxfer && (id == i) ? addr_31[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_31[i];
    addr_32[i] <= ctrl_start          ? ctrl_offset_32[i] :
               arxfer && (id == i) ? addr_32[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_32[i];
    addr_33[i] <= ctrl_start          ? ctrl_offset_33[i] :
               arxfer && (id == i) ? addr_33[i] + C_BURST_LEN*C_DATA_WIDTH/8 : 
                                     addr_33[i];
  end
end

// Counts down the number of transactions to send.
krnl_vadd_rtl_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} ) 
)
inst_ar_transaction_cntr ( 
  .clk        ( aclk                   ) ,
  .clken      ( 1'b1                   ) ,
  .rst        ( areset                 ) ,
  .load       ( start                  ) ,
  .incr       ( 1'b0                   ) ,
  .decr       ( arxfer && id == '0     ) ,
  .load_value ( num_transactions       ) ,
  .count      ( ar_transactions_to_go  ) ,
  .is_zero    ( ar_final_transaction   ) 
);

assign ar_done = ar_final_transaction && arxfer && id == 1'b0;

always_comb begin 
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin 
    incr_ar_to_r_cnt[i] = rxfer & rlast & (rid == i);
    decr_ar_to_r_cnt[i] = arxfer & (arid == i);
  end
end

// Keeps track of the number of outstanding transactions. Stalls 
// when the value is reached so that the FIFO won't overflow.
krnl_vadd_rtl_counter #(
  .C_WIDTH ( LP_MAX_OUTSTANDING_CNTR_WIDTH                       ) ,
  .C_INIT  ( C_MAX_OUTSTANDING[0+:LP_MAX_OUTSTANDING_CNTR_WIDTH] ) 
)
inst_ar_to_r_transaction_cntr[C_NUM_CHANNELS-1:0] ( 
  .clk        ( aclk                           ) ,
  .clken      ( 1'b1                           ) ,
  .rst        ( areset                         ) ,
  .load       ( 1'b0                           ) ,
  .incr       ( incr_ar_to_r_cnt               ) ,
  .decr       ( decr_ar_to_r_cnt               ) ,
  .load_value ( {LP_MAX_OUTSTANDING_CNTR_WIDTH{1'b0}} ) ,
  .count      ( outstanding_vacancy_count      ) ,
  .is_zero    ( stall_ar                       ) 
);

///////////////////////////////////////////////////////////////////////////////
// AXI Read Channel
///////////////////////////////////////////////////////////////////////////////
assign m_tvalid = tvalid;

assign m_tdata_0 = tdata_0;
assign m_tdata_1 = tdata_1;
assign m_tdata_2 = tdata_2;
assign m_tdata_3 = tdata_3;
assign m_tdata_4 = tdata_4;
assign m_tdata_5 = tdata_5;
assign m_tdata_6 = tdata_6;
assign m_tdata_7 = tdata_7;
assign m_tdata_8 = tdata_8;
assign m_tdata_9 = tdata_9;
assign m_tdata_10 = tdata_10;
assign m_tdata_11 = tdata_11;
assign m_tdata_12 = tdata_12;
assign m_tdata_13 = tdata_13;
assign m_tdata_14 = tdata_14;
assign m_tdata_15 = tdata_15;
assign m_tdata_16 = tdata_16;
assign m_tdata_17 = tdata_17;
assign m_tdata_18 = tdata_18;
assign m_tdata_19 = tdata_19;
assign m_tdata_20 = tdata_20;
assign m_tdata_21 = tdata_21;
assign m_tdata_22 = tdata_22;
assign m_tdata_23 = tdata_23;
assign m_tdata_24 = tdata_24;
assign m_tdata_25 = tdata_25;
assign m_tdata_26 = tdata_26;
assign m_tdata_27 = tdata_27;
assign m_tdata_28 = tdata_28;
assign m_tdata_29 = tdata_29;
assign m_tdata_30 = tdata_30;
assign m_tdata_31 = tdata_31;
assign m_tdata_32 = tdata_32;
assign m_tdata_33 = tdata_33;

always_comb begin 
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    tvalid[i] = rvalid && (rid == i); 
    tdata_0[i] = rdata_0;
    tdata_1[i] = rdata_1;
    tdata_2[i] = rdata_2;
    tdata_3[i] = rdata_3;
    tdata_4[i] = rdata_4;
    tdata_5[i] = rdata_5;
    tdata_6[i] = rdata_6;
    tdata_7[i] = rdata_7;
    tdata_8[i] = rdata_8;
    tdata_9[i] = rdata_9;
    tdata_10[i] = rdata_10;
    tdata_11[i] = rdata_11;
    tdata_12[i] = rdata_12;
    tdata_13[i] = rdata_13;
    tdata_14[i] = rdata_14;
    tdata_15[i] = rdata_15;
    tdata_16[i] = rdata_16;
    tdata_17[i] = rdata_17;
    tdata_18[i] = rdata_18;
    tdata_19[i] = rdata_19;
    tdata_20[i] = rdata_20;
    tdata_21[i] = rdata_21;
    tdata_22[i] = rdata_22;
    tdata_23[i] = rdata_23;
    tdata_24[i] = rdata_24;
    tdata_25[i] = rdata_25;
    tdata_26[i] = rdata_26;
    tdata_27[i] = rdata_27;
    tdata_28[i] = rdata_28;
    tdata_29[i] = rdata_29;
    tdata_30[i] = rdata_30;
    tdata_31[i] = rdata_31;
    tdata_32[i] = rdata_32;
    tdata_33[i] = rdata_33;
  end
end

// rready can remain high for optimal timing because ar transactions are not issued
// unless there is enough space in the FIFO.
assign rready = 1'b1;
assign rxfer = rready & rvalid;

always_comb begin 
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin 
    decr_r_transaction_cntr[i] = rxfer & rlast & (rid == i);
  end
end
krnl_vadd_rtl_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} ) 
)
inst_r_transaction_cntr[C_NUM_CHANNELS-1:0] ( 
  .clk        ( aclk                          ) ,
  .clken      ( 1'b1                          ) ,
  .rst        ( areset                        ) ,
  .load       ( start                         ) ,
  .incr       ( 1'b0                          ) ,
  .decr       ( decr_r_transaction_cntr       ) ,
  .load_value ( num_transactions              ) ,
  .count      ( r_transactions_to_go          ) ,
  .is_zero    ( r_final_transaction           ) 
);


endmodule : krnl_vadd_rtl_axi_read_master

`default_nettype wire
