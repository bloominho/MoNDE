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

`timescale 1ns/1ps
module krnl_vadd_rtl_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 6,
    C_S_AXI_DATA_WIDTH = 32
)(
    // axi4 lite slave signals
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire                          interrupt, 
    // user signals
    output reg                           ap_start,
    input  wire                          ap_done,
    input  wire                          ap_ready,
    input  wire                          ap_idle,
    

    output [63:0]                        address_read_a_0,
    output [63:0]                        address_read_a_1,
    output [63:0]                        address_read_b_0,
    output [63:0]                        address_read_b_1,
    output [63:0]                        address_read_b_2,
    output [63:0]                        address_read_b_3,
    output [63:0]                        address_read_b_4,
    output [63:0]                        address_read_b_5,
    output [63:0]                        address_read_b_6,
    output [63:0]                        address_read_b_7,
    output [63:0]                        address_read_b_8,
    output [63:0]                        address_read_b_9,
    output [63:0]                        address_read_b_10,
    output [63:0]                        address_read_b_11,
    output [63:0]                        address_read_b_12,
    output [63:0]                        address_read_b_13,
    output [63:0]                        address_read_b_14,
    output [63:0]                        address_read_b_15,
    output [63:0]                        address_read_b_16,
    output [63:0]                        address_read_b_17,
    output [63:0]                        address_read_b_18,
    output [63:0]                        address_read_b_19,
    output [63:0]                        address_read_b_20,
    output [63:0]                        address_read_b_21,
    output [63:0]                        address_read_b_22,
    output [63:0]                        address_read_b_23,
    output [63:0]                        address_read_b_24,
    output [63:0]                        address_read_b_25,
    output [63:0]                        address_read_b_26,
    output [63:0]                        address_read_b_27,
    output [63:0]                        address_read_b_28,
    output [63:0]                        address_read_b_29,
    output [63:0]                        address_read_b_30,
    output [63:0]                        address_read_b_31,

    output [63:0]                        address_write_a_0,
    output [63:0]                        address_write_a_1,
    output [63:0]                        address_write_offset,

    output                               relu,
    output     [31:0]                    length
);
//------------------------Address Info-------------------
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x10 : Data signal of control
//        bit 31~0 - control[31:0] (Read/Write)
// 0x14 : Data signal of control
//        bit 31~0 - control[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of control_address
//        bit 31~0 - a[31:0] (Read/Write)
// 0x20 : Data signal of control_address
//        bit 31~0 - a[63:32] (Read/Write)
// 0x24 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_AP_CTRL            = 10'd0,
    ADDR_GIE                = 10'd4,
    ADDR_IER                = 10'd8,
    ADDR_ISR                = 10'd12,
    ADDR_READ_A_0_DATA_0     = 10'd16,
    ADDR_READ_A_0_DATA_1     = 10'd20,
    ADDR_READ_A_0_CTRL       = 10'd24,
    ADDR_READ_A_1_DATA_0     = 10'd28,
    ADDR_READ_A_1_DATA_1     = 10'd32,
    ADDR_READ_A_1_CTRL       = 10'd36,
    ADDR_READ_B_0_DATA_0     = 10'd40,
    ADDR_READ_B_0_DATA_1     = 10'd44,
    ADDR_READ_B_0_CTRL       = 10'd48,
    ADDR_READ_B_1_DATA_0     = 10'd52,
    ADDR_READ_B_1_DATA_1     = 10'd56,
    ADDR_READ_B_1_CTRL       = 10'd60,
    ADDR_READ_B_2_DATA_0     = 10'd64,
    ADDR_READ_B_2_DATA_1     = 10'd68,
    ADDR_READ_B_2_CTRL       = 10'd72,
    ADDR_READ_B_3_DATA_0     = 10'd76,
    ADDR_READ_B_3_DATA_1     = 10'd80,
    ADDR_READ_B_3_CTRL       = 10'd84,
    ADDR_READ_B_4_DATA_0     = 10'd88,
    ADDR_READ_B_4_DATA_1     = 10'd92,
    ADDR_READ_B_4_CTRL       = 10'd96,
    ADDR_READ_B_5_DATA_0     = 10'd100,
    ADDR_READ_B_5_DATA_1     = 10'd104,
    ADDR_READ_B_5_CTRL       = 10'd108,
    ADDR_READ_B_6_DATA_0     = 10'd112,
    ADDR_READ_B_6_DATA_1     = 10'd116,
    ADDR_READ_B_6_CTRL       = 10'd120,
    ADDR_READ_B_7_DATA_0     = 10'd124,
    ADDR_READ_B_7_DATA_1     = 10'd128,
    ADDR_READ_B_7_CTRL       = 10'd132,
    ADDR_READ_B_8_DATA_0     = 10'd136,
    ADDR_READ_B_8_DATA_1     = 10'd140,
    ADDR_READ_B_8_CTRL       = 10'd144,
    ADDR_READ_B_9_DATA_0     = 10'd148,
    ADDR_READ_B_9_DATA_1     = 10'd152,
    ADDR_READ_B_9_CTRL       = 10'd156,
    ADDR_READ_B_10_DATA_0     = 10'd160,
    ADDR_READ_B_10_DATA_1     = 10'd164,
    ADDR_READ_B_10_CTRL       = 10'd168,
    ADDR_READ_B_11_DATA_0     = 10'd172,
    ADDR_READ_B_11_DATA_1     = 10'd176,
    ADDR_READ_B_11_CTRL       = 10'd180,
    ADDR_READ_B_12_DATA_0     = 10'd184,
    ADDR_READ_B_12_DATA_1     = 10'd188,
    ADDR_READ_B_12_CTRL       = 10'd192,
    ADDR_READ_B_13_DATA_0     = 10'd196,
    ADDR_READ_B_13_DATA_1     = 10'd200,
    ADDR_READ_B_13_CTRL       = 10'd204,
    ADDR_READ_B_14_DATA_0     = 10'd208,
    ADDR_READ_B_14_DATA_1     = 10'd212,
    ADDR_READ_B_14_CTRL       = 10'd216,
    ADDR_READ_B_15_DATA_0     = 10'd220,
    ADDR_READ_B_15_DATA_1     = 10'd224,
    ADDR_READ_B_15_CTRL       = 10'd228,
    ADDR_READ_B_16_DATA_0     = 10'd232,
    ADDR_READ_B_16_DATA_1     = 10'd236,
    ADDR_READ_B_16_CTRL       = 10'd240,
    ADDR_READ_B_17_DATA_0     = 10'd244,
    ADDR_READ_B_17_DATA_1     = 10'd248,
    ADDR_READ_B_17_CTRL       = 10'd252,
    ADDR_READ_B_18_DATA_0     = 10'd256,
    ADDR_READ_B_18_DATA_1     = 10'd260,
    ADDR_READ_B_18_CTRL       = 10'd264,
    ADDR_READ_B_19_DATA_0     = 10'd268,
    ADDR_READ_B_19_DATA_1     = 10'd272,
    ADDR_READ_B_19_CTRL       = 10'd276,
    ADDR_READ_B_20_DATA_0     = 10'd280,
    ADDR_READ_B_20_DATA_1     = 10'd284,
    ADDR_READ_B_20_CTRL       = 10'd288,
    ADDR_READ_B_21_DATA_0     = 10'd292,
    ADDR_READ_B_21_DATA_1     = 10'd296,
    ADDR_READ_B_21_CTRL       = 10'd300,
    ADDR_READ_B_22_DATA_0     = 10'd304,
    ADDR_READ_B_22_DATA_1     = 10'd308,
    ADDR_READ_B_22_CTRL       = 10'd312,
    ADDR_READ_B_23_DATA_0     = 10'd316,
    ADDR_READ_B_23_DATA_1     = 10'd320,
    ADDR_READ_B_23_CTRL       = 10'd324,
    ADDR_READ_B_24_DATA_0     = 10'd328,
    ADDR_READ_B_24_DATA_1     = 10'd332,
    ADDR_READ_B_24_CTRL       = 10'd336,
    ADDR_READ_B_25_DATA_0     = 10'd340,
    ADDR_READ_B_25_DATA_1     = 10'd344,
    ADDR_READ_B_25_CTRL       = 10'd348,
    ADDR_READ_B_26_DATA_0     = 10'd352,
    ADDR_READ_B_26_DATA_1     = 10'd356,
    ADDR_READ_B_26_CTRL       = 10'd360,
    ADDR_READ_B_27_DATA_0     = 10'd364,
    ADDR_READ_B_27_DATA_1     = 10'd368,
    ADDR_READ_B_27_CTRL       = 10'd372,
    ADDR_READ_B_28_DATA_0     = 10'd376,
    ADDR_READ_B_28_DATA_1     = 10'd380,
    ADDR_READ_B_28_CTRL       = 10'd384,
    ADDR_READ_B_29_DATA_0     = 10'd388,
    ADDR_READ_B_29_DATA_1     = 10'd392,
    ADDR_READ_B_29_CTRL       = 10'd396,
    ADDR_READ_B_30_DATA_0     = 10'd400,
    ADDR_READ_B_30_DATA_1     = 10'd404,
    ADDR_READ_B_30_CTRL       = 10'd408,
    ADDR_READ_B_31_DATA_0     = 10'd412,
    ADDR_READ_B_31_DATA_1     = 10'd416,
    ADDR_READ_B_31_CTRL       = 10'd420,
    ADDR_WRITE_A_0_DATA_0     = 10'd424,
    ADDR_WRITE_A_0_DATA_1     = 10'd428,
    ADDR_WRITE_A_0_CTRL       = 10'd432,
    ADDR_WRITE_A_1_DATA_0     = 10'd436,
    ADDR_WRITE_A_1_DATA_1     = 10'd440,
    ADDR_WRITE_A_1_CTRL       = 10'd444,
    ADDR_WRITE_OFFSET_DATA_0  = 10'd448,
    ADDR_WRITE_OFFSET_DATA_1  = 10'd452,
    ADDR_WRITE_OFFSET_CTRL    = 10'd456,
    ADDR_CONTROL_DATA_0       = 10'd460,
    ADDR_CONTROL_CTRL         = 10'd464,
    
    WRIDLE                  = 2'd0,
    WRDATA                  = 2'd1,
    WRRESP                  = 2'd2,
    RDIDLE                  = 2'd0,
    RDDATA                  = 2'd1,
    ADDR_BITS               = 10;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRIDLE;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [31:0]                   wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDIDLE;
    reg  [1:0]                    rnext;
    reg  [31:0]                   rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    wire                          int_ap_idle;
    wire                          int_ap_ready;
    reg                           int_ap_done = 1'b0;
    reg                           int_ap_start = 1'b0;
    reg                           int_auto_restart = 1'b0;
    reg                           int_gie = 2'b0;
    reg  [1:0]                    int_ier = 2'b0;
    reg  [1:0]                    int_isr = 2'b0;
    // read address
    reg  [63:0]                   int_address_read_a_0  = 64'b0;
    reg  [63:0]                   int_address_read_a_1  = 64'b0;
    reg  [63:0]                   int_address_read_b_0  = 64'b0;
    reg  [63:0]                   int_address_read_b_1  = 64'b0;
    reg  [63:0]                   int_address_read_b_2  = 64'b0;
    reg  [63:0]                   int_address_read_b_3  = 64'b0;
    reg  [63:0]                   int_address_read_b_4  = 64'b0;
    reg  [63:0]                   int_address_read_b_5  = 64'b0;
    reg  [63:0]                   int_address_read_b_6  = 64'b0;
    reg  [63:0]                   int_address_read_b_7  = 64'b0;
    reg  [63:0]                   int_address_read_b_8  = 64'b0;
    reg  [63:0]                   int_address_read_b_9  = 64'b0;
    reg  [63:0]                   int_address_read_b_10 = 64'b0;
    reg  [63:0]                   int_address_read_b_11 = 64'b0;
    reg  [63:0]                   int_address_read_b_12 = 64'b0;
    reg  [63:0]                   int_address_read_b_13 = 64'b0;
    reg  [63:0]                   int_address_read_b_14 = 64'b0;
    reg  [63:0]                   int_address_read_b_15 = 64'b0;
    reg  [63:0]                   int_address_read_b_16 = 64'b0;
    reg  [63:0]                   int_address_read_b_17 = 64'b0;
    reg  [63:0]                   int_address_read_b_18 = 64'b0;
    reg  [63:0]                   int_address_read_b_19 = 64'b0;
    reg  [63:0]                   int_address_read_b_20 = 64'b0;
    reg  [63:0]                   int_address_read_b_21 = 64'b0;
    reg  [63:0]                   int_address_read_b_22 = 64'b0;
    reg  [63:0]                   int_address_read_b_23 = 64'b0;
    reg  [63:0]                   int_address_read_b_24 = 64'b0;
    reg  [63:0]                   int_address_read_b_25 = 64'b0;
    reg  [63:0]                   int_address_read_b_26 = 64'b0;
    reg  [63:0]                   int_address_read_b_27 = 64'b0;
    reg  [63:0]                   int_address_read_b_28 = 64'b0;
    reg  [63:0]                   int_address_read_b_29 = 64'b0;
    reg  [63:0]                   int_address_read_b_30 = 64'b0;
    reg  [63:0]                   int_address_read_b_31 = 64'b0;

    reg  [63:0]                   int_address_write_a_0 = 64'b0;
    reg  [63:0]                   int_address_write_a_1 = 64'b0;
    reg  [63:0]                   int_address_write_offset = 64'b0;
    
    reg  [31:0]                   int_control           = 32'b10;
    reg  [31:0]                   int_control_rec       = 32'b10;

//------------------------Instantiation------------------

//------------------------AXI write fsm------------------
assign AWREADY = (~ARESET) & (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRIDLE;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= AWADDR[ADDR_BITS-1:0];
    end
end

assign address_read_a_0  = int_address_read_a_0;
assign address_read_a_1  = int_address_read_a_1;

assign address_read_b_0  = int_address_read_b_0;
assign address_read_b_1  = int_address_read_b_1;
assign address_read_b_2  = int_address_read_b_2;
assign address_read_b_3  = int_address_read_b_3;
assign address_read_b_4  = int_address_read_b_4;
assign address_read_b_5  = int_address_read_b_5;
assign address_read_b_6  = int_address_read_b_6;
assign address_read_b_7  = int_address_read_b_7;
assign address_read_b_8  = int_address_read_b_8;
assign address_read_b_9  = int_address_read_b_9;
assign address_read_b_10 = int_address_read_b_10;
assign address_read_b_11 = int_address_read_b_11;
assign address_read_b_12 = int_address_read_b_12;
assign address_read_b_13 = int_address_read_b_13;
assign address_read_b_14 = int_address_read_b_14;
assign address_read_b_15 = int_address_read_b_15;
assign address_read_b_16 = int_address_read_b_16;
assign address_read_b_17 = int_address_read_b_17;
assign address_read_b_18 = int_address_read_b_18;
assign address_read_b_19 = int_address_read_b_19;
assign address_read_b_20 = int_address_read_b_20;
assign address_read_b_21 = int_address_read_b_21;
assign address_read_b_22 = int_address_read_b_22;
assign address_read_b_23 = int_address_read_b_23;
assign address_read_b_24 = int_address_read_b_24;
assign address_read_b_25 = int_address_read_b_25;
assign address_read_b_26 = int_address_read_b_26;
assign address_read_b_27 = int_address_read_b_27;
assign address_read_b_28 = int_address_read_b_28;
assign address_read_b_29 = int_address_read_b_29;
assign address_read_b_30 = int_address_read_b_30;
assign address_read_b_31 = int_address_read_b_31;

assign address_write_a_0 = int_address_write_a_0;
assign address_write_a_1 = int_address_write_a_1;
assign address_write_offset = int_address_write_offset;

assign relu         = int_control_rec[0];
wire   wait_bit     = int_control_rec[1];
assign length       = {2'b0, int_control_rec[31:2]};

//------------------------AXI read fsm-------------------
assign ARREADY = (~ARESET) && (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDIDLE;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 1'b0;
            case (raddr)
                ADDR_AP_CTRL: begin
                    rdata[0] <= int_ap_start;
                    rdata[1] <= int_ap_done;
                    rdata[2] <= int_ap_idle;
                    rdata[3] <= int_ap_ready;
                    rdata[7] <= int_auto_restart;
                end
                ADDR_GIE: begin
                    rdata <= int_gie;
                end
                ADDR_IER: begin
                    rdata <= int_ier;
                end
                ADDR_ISR: begin
                    rdata <= int_isr;
                end
                ADDR_READ_A_0_DATA_0: begin
                    rdata <= int_address_read_a_0[31:0];
                end
                ADDR_READ_A_0_DATA_1: begin
                    rdata <= int_address_read_a_0[63:32];
                end
                ADDR_READ_A_1_DATA_0: begin
                    rdata <= int_address_read_a_1[31:0];
                end
                ADDR_READ_A_1_DATA_1: begin
                    rdata <= int_address_read_a_1[63:32];
                end
                ADDR_READ_B_0_DATA_0: begin
                    rdata <= int_address_read_b_0[31:0];
                end
                ADDR_READ_B_0_DATA_1: begin
                    rdata <= int_address_read_b_0[63:32];
                end
                ADDR_READ_B_1_DATA_0: begin
                    rdata <= int_address_read_b_1[31:0];
                end
                ADDR_READ_B_1_DATA_1: begin
                    rdata <= int_address_read_b_1[63:32];
                end
                ADDR_READ_B_2_DATA_0: begin
                    rdata <= int_address_read_b_2[31:0];
                end
                ADDR_READ_B_2_DATA_1: begin
                    rdata <= int_address_read_b_2[63:32];
                end
                ADDR_READ_B_3_DATA_0: begin
                    rdata <= int_address_read_b_3[31:0];
                end
                ADDR_READ_B_3_DATA_1: begin
                    rdata <= int_address_read_b_3[63:32];
                end
                ADDR_READ_B_4_DATA_0: begin
                    rdata <= int_address_read_b_4[31:0];
                end
                ADDR_READ_B_4_DATA_1: begin
                    rdata <= int_address_read_b_4[63:32];
                end
                ADDR_READ_B_5_DATA_0: begin
                    rdata <= int_address_read_b_5[31:0];
                end
                ADDR_READ_B_5_DATA_1: begin
                    rdata <= int_address_read_b_5[63:32];
                end
                ADDR_READ_B_6_DATA_0: begin
                    rdata <= int_address_read_b_6[31:0];
                end
                ADDR_READ_B_6_DATA_1: begin
                    rdata <= int_address_read_b_6[63:32];
                end
                ADDR_READ_B_7_DATA_0: begin
                    rdata <= int_address_read_b_7[31:0];
                end
                ADDR_READ_B_7_DATA_1: begin
                    rdata <= int_address_read_b_7[63:32];
                end
                ADDR_READ_B_8_DATA_0: begin
                    rdata <= int_address_read_b_8[31:0];
                end
                ADDR_READ_B_8_DATA_1: begin
                    rdata <= int_address_read_b_8[63:32];
                end
                ADDR_READ_B_9_DATA_0: begin
                    rdata <= int_address_read_b_9[31:0];
                end
                ADDR_READ_B_9_DATA_1: begin
                    rdata <= int_address_read_b_9[63:32];
                end
                ADDR_READ_B_10_DATA_0: begin
                    rdata <= int_address_read_b_10[31:0];
                end
                ADDR_READ_B_10_DATA_1: begin
                    rdata <= int_address_read_b_10[63:32];
                end
                ADDR_READ_B_11_DATA_0: begin
                    rdata <= int_address_read_b_11[31:0];
                end
                ADDR_READ_B_11_DATA_1: begin
                    rdata <= int_address_read_b_11[63:32];
                end
                ADDR_READ_B_12_DATA_0: begin
                    rdata <= int_address_read_b_12[31:0];
                end
                ADDR_READ_B_12_DATA_1: begin
                    rdata <= int_address_read_b_12[63:32];
                end
                ADDR_READ_B_13_DATA_0: begin
                    rdata <= int_address_read_b_13[31:0];
                end
                ADDR_READ_B_13_DATA_1: begin
                    rdata <= int_address_read_b_13[63:32];
                end
                ADDR_READ_B_14_DATA_0: begin
                    rdata <= int_address_read_b_14[31:0];
                end
                ADDR_READ_B_14_DATA_1: begin
                    rdata <= int_address_read_b_14[63:32];
                end
                ADDR_READ_B_15_DATA_0: begin
                    rdata <= int_address_read_b_15[31:0];
                end
                ADDR_READ_B_15_DATA_1: begin
                    rdata <= int_address_read_b_15[63:32];
                end
                ADDR_READ_B_16_DATA_0: begin
                    rdata <= int_address_read_b_16[31:0];
                end
                ADDR_READ_B_16_DATA_1: begin
                    rdata <= int_address_read_b_16[63:32];
                end
                ADDR_READ_B_17_DATA_0: begin
                    rdata <= int_address_read_b_17[31:0];
                end
                ADDR_READ_B_17_DATA_1: begin
                    rdata <= int_address_read_b_17[63:32];
                end
                ADDR_READ_B_18_DATA_0: begin
                    rdata <= int_address_read_b_18[31:0];
                end
                ADDR_READ_B_18_DATA_1: begin
                    rdata <= int_address_read_b_18[63:32];
                end
                ADDR_READ_B_19_DATA_0: begin
                    rdata <= int_address_read_b_19[31:0];
                end
                ADDR_READ_B_19_DATA_1: begin
                    rdata <= int_address_read_b_19[63:32];
                end
                ADDR_READ_B_20_DATA_0: begin
                    rdata <= int_address_read_b_20[31:0];
                end
                ADDR_READ_B_20_DATA_1: begin
                    rdata <= int_address_read_b_20[63:32];
                end
                ADDR_READ_B_21_DATA_0: begin
                    rdata <= int_address_read_b_21[31:0];
                end
                ADDR_READ_B_21_DATA_1: begin
                    rdata <= int_address_read_b_21[63:32];
                end
                ADDR_READ_B_22_DATA_0: begin
                    rdata <= int_address_read_b_22[31:0];
                end
                ADDR_READ_B_22_DATA_1: begin
                    rdata <= int_address_read_b_22[63:32];
                end
                ADDR_READ_B_23_DATA_0: begin
                    rdata <= int_address_read_b_23[31:0];
                end
                ADDR_READ_B_23_DATA_1: begin
                    rdata <= int_address_read_b_23[63:32];
                end
                ADDR_READ_B_24_DATA_0: begin
                    rdata <= int_address_read_b_24[31:0];
                end
                ADDR_READ_B_24_DATA_1: begin
                    rdata <= int_address_read_b_24[63:32];
                end
                ADDR_READ_B_25_DATA_0: begin
                    rdata <= int_address_read_b_25[31:0];
                end
                ADDR_READ_B_25_DATA_1: begin
                    rdata <= int_address_read_b_25[63:32];
                end
                ADDR_READ_B_26_DATA_0: begin
                    rdata <= int_address_read_b_26[31:0];
                end
                ADDR_READ_B_26_DATA_1: begin
                    rdata <= int_address_read_b_26[63:32];
                end
                ADDR_READ_B_27_DATA_0: begin
                    rdata <= int_address_read_b_27[31:0];
                end
                ADDR_READ_B_27_DATA_1: begin
                    rdata <= int_address_read_b_27[63:32];
                end
                ADDR_READ_B_28_DATA_0: begin
                    rdata <= int_address_read_b_28[31:0];
                end
                ADDR_READ_B_28_DATA_1: begin
                    rdata <= int_address_read_b_28[63:32];
                end
                ADDR_READ_B_29_DATA_0: begin
                    rdata <= int_address_read_b_29[31:0];
                end
                ADDR_READ_B_29_DATA_1: begin
                    rdata <= int_address_read_b_29[63:32];
                end
                ADDR_READ_B_30_DATA_0: begin
                    rdata <= int_address_read_b_30[31:0];
                end
                ADDR_READ_B_30_DATA_1: begin
                    rdata <= int_address_read_b_30[63:32];
                end
                ADDR_READ_B_31_DATA_0: begin
                    rdata <= int_address_read_b_31[31:0];
                end
                ADDR_READ_B_31_DATA_1: begin
                    rdata <= int_address_read_b_31[63:32];
                end
                ADDR_WRITE_A_0_DATA_0: begin
                    rdata <= int_address_write_a_0[31:0];
                end
                ADDR_WRITE_A_0_DATA_1: begin
                    rdata <= int_address_write_a_0[63:32];
                end
                ADDR_WRITE_A_1_DATA_0: begin
                    rdata <= int_address_write_a_1[31:0];
                end
                ADDR_WRITE_A_1_DATA_1: begin
                    rdata <= int_address_write_a_1[63:32];
                end
                ADDR_WRITE_OFFSET_DATA_0: begin
                    rdata <= int_address_write_offset[31:0];
                end
                ADDR_WRITE_OFFSET_DATA_1: begin
                    rdata <= int_address_write_offset[63:32];
                end
                ADDR_CONTROL_DATA_0: begin
                    rdata <= int_control[31:0];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
reg    ap_start_r;
reg    int_ap_arg_ready;

assign interrupt    = int_gie & (|int_isr);
assign int_ap_idle  = ap_idle;
assign int_ap_ready = ap_ready;

// int_ap_arg_ready
always @(posedge ACLK) begin
    if(ARESET) begin
        int_ap_arg_ready <= 1'b0;
    end else if(int_ap_start) begin
        int_ap_arg_ready <= 1'b1;
    end else if(ap_start) begin
        int_ap_arg_ready <= 1'b0;
    end
end

// ap_start
always @(posedge ACLK) begin
    if(ARESET) begin
        ap_start <= 1'b0;
        int_control_rec <= 32'b10;
    end else if(ap_done) begin
        ap_start <= 1'b0;
    end else if(~ap_start & int_ap_arg_ready) begin
        ap_start <= 1'b1;
        int_control_rec <= int_control;
    end
    ap_start_r <= ap_start;
end

// int_ap_start
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_start <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
            int_ap_start <= 1'b1;
        else begin
            if(ap_start & ~ap_start_r) begin
                int_ap_start <= 1'b0;
            end
        end
    end
end

// int_ap_done
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_done <= 1'b0;
    else if (ACLK_EN) begin
        if(wait_bit) begin
            if(ap_done) begin
                int_ap_done <= 1'b1;
            end else if (ar_hs && raddr == ADDR_AP_CTRL) begin
                int_ap_done <= 1'b0; // clear on read
            end
        end else begin
            if(ap_start & ~ap_start_r) begin
                int_ap_done <= 1'b1;
            end else if (ar_hs && raddr == ADDR_AP_CTRL) begin
                int_ap_done <= 1'b0; // clear on read
            end
        end
    end
end

// int_auto_restart
always @(posedge ACLK) begin
    if (ARESET)
        int_auto_restart <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
            int_auto_restart <=  WDATA[7];
    end
end

// int_gie
always @(posedge ACLK) begin
    if (ARESET)
        int_gie <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_GIE && WSTRB[0])
            int_gie <= WDATA[0];
    end
end

// int_ier
always @(posedge ACLK) begin
    if (ARESET)
        int_ier <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IER && WSTRB[0])
            int_ier <= WDATA[1:0];
    end
end

// int_isr[0]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[0] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[0] & ap_done)
            int_isr[0] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[0] <= int_isr[0] ^ WDATA[0]; // toggle on write
    end
end

// int_isr[1]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[1] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[1] & ap_ready)
            int_isr[1] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[1] <= int_isr[1] ^ WDATA[1]; // toggle on write
    end
end

// int_address_read_a_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_a_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_A_0_DATA_0)
            int_address_read_a_0[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_a_0[31:0] & ~wmask);
    end
end

// int_address_read_a_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_a_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_A_0_DATA_1)
            int_address_read_a_0[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_a_0[63:32] & ~wmask);
    end
end

// int_address_read_a_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_a_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_A_1_DATA_0)
            int_address_read_a_1[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_a_1[31:0] & ~wmask);
    end
end

// int_address_read_a_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_a_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_A_1_DATA_1)
            int_address_read_a_1[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_a_1[63:32] & ~wmask);
    end
end

// int_address_read_b_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_0_DATA_0)
            int_address_read_b_0[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_0[31:0] & ~wmask);
    end
end

// int_address_read_b_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_0_DATA_1)
            int_address_read_b_0[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_0[63:32] & ~wmask);
    end
end

// int_address_read_b_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_1_DATA_0)
            int_address_read_b_1[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_1[31:0] & ~wmask);
    end
end

// int_address_read_b_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_1_DATA_1)
            int_address_read_b_1[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_1[63:32] & ~wmask);
    end
end

// int_address_read_b_2[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_2[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_2_DATA_0)
            int_address_read_b_2[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_2[31:0] & ~wmask);
    end
end

// int_address_read_b_2[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_2[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_2_DATA_1)
            int_address_read_b_2[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_2[63:32] & ~wmask);
    end
end

// int_address_read_b_3[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_3[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_3_DATA_0)
            int_address_read_b_3[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_3[31:0] & ~wmask);
    end
end

// int_address_read_b_3[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_3[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_3_DATA_1)
            int_address_read_b_3[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_3[63:32] & ~wmask);
    end
end

// int_address_read_b_4[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_4[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_4_DATA_0)
            int_address_read_b_4[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_4[31:0] & ~wmask);
    end
end

// int_address_read_b_4[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_4[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_4_DATA_1)
            int_address_read_b_4[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_4[63:32] & ~wmask);
    end
end

// int_address_read_b_5[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_5[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_5_DATA_0)
            int_address_read_b_5[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_5[31:0] & ~wmask);
    end
end

// int_address_read_b_5[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_5[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_5_DATA_1)
            int_address_read_b_5[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_5[63:32] & ~wmask);
    end
end

// int_address_read_b_6[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_6[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_6_DATA_0)
            int_address_read_b_6[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_6[31:0] & ~wmask);
    end
end

// int_address_read_b_6[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_6[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_6_DATA_1)
            int_address_read_b_6[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_6[63:32] & ~wmask);
    end
end

// int_address_read_b_7[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_7[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_7_DATA_0)
            int_address_read_b_7[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_7[31:0] & ~wmask);
    end
end

// int_address_read_b_7[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_7[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_7_DATA_1)
            int_address_read_b_7[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_7[63:32] & ~wmask);
    end
end

// int_address_read_b_8[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_8[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_8_DATA_0)
            int_address_read_b_8[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_8[31:0] & ~wmask);
    end
end

// int_address_read_b_8[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_8[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_8_DATA_1)
            int_address_read_b_8[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_8[63:32] & ~wmask);
    end
end

// int_address_read_b_9[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_9[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_9_DATA_0)
            int_address_read_b_9[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_9[31:0] & ~wmask);
    end
end

// int_address_read_b_9[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_9[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_9_DATA_1)
            int_address_read_b_9[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_9[63:32] & ~wmask);
    end
end

// int_address_read_b_10[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_10[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_10_DATA_0)
            int_address_read_b_10[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_10[31:0] & ~wmask);
    end
end

// int_address_read_b_10[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_10[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_10_DATA_1)
            int_address_read_b_10[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_10[63:32] & ~wmask);
    end
end

// int_address_read_b_11[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_11[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_11_DATA_0)
            int_address_read_b_11[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_11[31:0] & ~wmask);
    end
end

// int_address_read_b_11[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_11[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_11_DATA_1)
            int_address_read_b_11[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_11[63:32] & ~wmask);
    end
end

// int_address_read_b_12[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_12[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_12_DATA_0)
            int_address_read_b_12[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_12[31:0] & ~wmask);
    end
end

// int_address_read_b_12[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_12[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_12_DATA_1)
            int_address_read_b_12[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_12[63:32] & ~wmask);
    end
end

// int_address_read_b_13[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_13[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_13_DATA_0)
            int_address_read_b_13[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_13[31:0] & ~wmask);
    end
end

// int_address_read_b_13[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_13[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_13_DATA_1)
            int_address_read_b_13[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_13[63:32] & ~wmask);
    end
end

// int_address_read_b_14[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_14[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_14_DATA_0)
            int_address_read_b_14[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_14[31:0] & ~wmask);
    end
end

// int_address_read_b_14[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_14[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_14_DATA_1)
            int_address_read_b_14[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_14[63:32] & ~wmask);
    end
end

// int_address_read_b_15[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_15[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_15_DATA_0)
            int_address_read_b_15[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_15[31:0] & ~wmask);
    end
end

// int_address_read_b_15[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_15[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_15_DATA_1)
            int_address_read_b_15[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_15[63:32] & ~wmask);
    end
end

// int_address_read_b_16[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_16[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_16_DATA_0)
            int_address_read_b_16[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_16[31:0] & ~wmask);
    end
end

// int_address_read_b_16[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_16[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_16_DATA_1)
            int_address_read_b_16[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_16[63:32] & ~wmask);
    end
end

// int_address_read_b_17[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_17[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_17_DATA_0)
            int_address_read_b_17[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_17[31:0] & ~wmask);
    end
end

// int_address_read_b_17[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_17[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_17_DATA_1)
            int_address_read_b_17[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_17[63:32] & ~wmask);
    end
end

// int_address_read_b_18[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_18[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_18_DATA_0)
            int_address_read_b_18[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_18[31:0] & ~wmask);
    end
end

// int_address_read_b_18[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_18[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_18_DATA_1)
            int_address_read_b_18[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_18[63:32] & ~wmask);
    end
end

// int_address_read_b_19[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_19[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_19_DATA_0)
            int_address_read_b_19[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_19[31:0] & ~wmask);
    end
end

// int_address_read_b_19[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_19[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_19_DATA_1)
            int_address_read_b_19[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_19[63:32] & ~wmask);
    end
end

// int_address_read_b_20[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_20[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_20_DATA_0)
            int_address_read_b_20[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_20[31:0] & ~wmask);
    end
end

// int_address_read_b_20[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_20[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_20_DATA_1)
            int_address_read_b_20[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_20[63:32] & ~wmask);
    end
end

// int_address_read_b_21[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_21[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_21_DATA_0)
            int_address_read_b_21[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_21[31:0] & ~wmask);
    end
end

// int_address_read_b_21[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_21[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_21_DATA_1)
            int_address_read_b_21[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_21[63:32] & ~wmask);
    end
end

// int_address_read_b_22[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_22[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_22_DATA_0)
            int_address_read_b_22[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_22[31:0] & ~wmask);
    end
end

// int_address_read_b_22[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_22[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_22_DATA_1)
            int_address_read_b_22[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_22[63:32] & ~wmask);
    end
end

// int_address_read_b_23[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_23[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_23_DATA_0)
            int_address_read_b_23[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_23[31:0] & ~wmask);
    end
end

// int_address_read_b_23[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_23[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_23_DATA_1)
            int_address_read_b_23[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_23[63:32] & ~wmask);
    end
end

// int_address_read_b_24[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_24[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_24_DATA_0)
            int_address_read_b_24[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_24[31:0] & ~wmask);
    end
end

// int_address_read_b_24[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_24[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_24_DATA_1)
            int_address_read_b_24[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_24[63:32] & ~wmask);
    end
end

// int_address_read_b_25[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_25[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_25_DATA_0)
            int_address_read_b_25[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_25[31:0] & ~wmask);
    end
end

// int_address_read_b_25[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_25[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_25_DATA_1)
            int_address_read_b_25[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_25[63:32] & ~wmask);
    end
end

// int_address_read_b_26[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_26[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_26_DATA_0)
            int_address_read_b_26[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_26[31:0] & ~wmask);
    end
end

// int_address_read_b_26[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_26[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_26_DATA_1)
            int_address_read_b_26[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_26[63:32] & ~wmask);
    end
end

// int_address_read_b_27[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_27[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_27_DATA_0)
            int_address_read_b_27[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_27[31:0] & ~wmask);
    end
end

// int_address_read_b_27[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_27[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_27_DATA_1)
            int_address_read_b_27[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_27[63:32] & ~wmask);
    end
end

// int_address_read_b_28[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_28[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_28_DATA_0)
            int_address_read_b_28[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_28[31:0] & ~wmask);
    end
end

// int_address_read_b_28[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_28[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_28_DATA_1)
            int_address_read_b_28[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_28[63:32] & ~wmask);
    end
end

// int_address_read_b_29[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_29[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_29_DATA_0)
            int_address_read_b_29[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_29[31:0] & ~wmask);
    end
end

// int_address_read_b_29[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_29[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_29_DATA_1)
            int_address_read_b_29[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_29[63:32] & ~wmask);
    end
end

// int_address_read_b_30[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_30[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_30_DATA_0)
            int_address_read_b_30[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_30[31:0] & ~wmask);
    end
end

// int_address_read_b_30[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_30[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_30_DATA_1)
            int_address_read_b_30[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_30[63:32] & ~wmask);
    end
end

// int_address_read_b_31[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_31[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_31_DATA_0)
            int_address_read_b_31[31:0] <= (WDATA[31:0] & wmask) | (int_address_read_b_31[31:0] & ~wmask);
    end
end

// int_address_read_b_31[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_read_b_31[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_READ_B_31_DATA_1)
            int_address_read_b_31[63:32] <= (WDATA[31:0] & wmask) | (int_address_read_b_31[63:32] & ~wmask);
    end
end

// int_address_write_a_0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_write_a_0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WRITE_A_0_DATA_0)
            int_address_write_a_0[31:0] <= (WDATA[31:0] & wmask) | (int_address_write_a_0[31:0] & ~wmask);
    end
end

// int_address_write_a_0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_write_a_0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WRITE_A_0_DATA_1)
            int_address_write_a_0[63:32] <= (WDATA[31:0] & wmask) | (int_address_write_a_0[63:32] & ~wmask);
    end
end

// int_address_write_a_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_write_a_1[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WRITE_A_1_DATA_0)
            int_address_write_a_1[31:0] <= (WDATA[31:0] & wmask) | (int_address_write_a_1[31:0] & ~wmask);
    end
end

// int_address_write_a_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_write_a_1[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WRITE_A_1_DATA_1)
            int_address_write_a_1[63:32] <= (WDATA[31:0] & wmask) | (int_address_write_a_1[63:32] & ~wmask);
    end
end

// int_address_write_a_1[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_write_offset[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WRITE_OFFSET_DATA_0)
            int_address_write_offset[31:0] <= (WDATA[31:0] & wmask) | (int_address_write_offset[31:0] & ~wmask);
    end
end

// int_address_write_a_1[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_address_write_offset[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_WRITE_OFFSET_DATA_1)
            int_address_write_offset[63:32] <= (WDATA[31:0] & wmask) | (int_address_write_offset[63:32] & ~wmask);
    end
end

// int_control[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_control[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_CONTROL_DATA_0)
            int_control[31:0] <= (WDATA[31:0] & wmask) | (int_control[31:0] & ~wmask);
    end
end

//------------------------Memory logic-------------------

endmodule
