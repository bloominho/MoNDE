// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.1 (lin64) Build 3865809 Sun May  7 15:04:56 MDT 2023
// Date        : Thu Aug  1 10:55:52 2024
// Host        : owl running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bram_sim_netlist.v
// Design      : bram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bram,blk_mem_gen_v8_4_6,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_6,Vivado 2023.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    enb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [1:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [0:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [63:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [1:0]addra;
  wire [0:0]addrb;
  wire clka;
  wire clkb;
  wire [31:0]dina;
  wire [63:0]dinb;
  wire [31:0]douta;
  wire [63:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire [0:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [0:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "2" *) 
  (* C_ADDRB_WIDTH = "1" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     11.253301 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "bram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "4" *) 
  (* C_READ_DEPTH_B = "2" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "64" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "4" *) 
  (* C_WRITE_DEPTH_B = "2" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "64" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_6 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
aMT3usC6uizzcwnzOCX4OsS16Ob+YxFcsGovFpFklbnaIaD1S0lVdxenTwHPp6ByIEi+ehwr6Rgg
z/3AlTheI5NFTM8ihiMA18/wmUxI7EbaftJACA1LykUKCuj5myy0T+DACuv3sGYIZS38TZTZnnBC
FGAlvTZmRWs+JzneH3o=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lR9ZerhYSAb39nzEkeYvhnwEs5t9y/+yTDf8KuoUtR1BGeHZq8pA/YxtjzQLtaOW1R1IQUb0FtSI
e3CYAb7WHYbIjcpw3vKHvW1SqcGn9CMGa556CYKmD2oF12Kow8xRaFvMSBUVxX7HsHxNWnRd+PU1
+C0YayU2KFIY/7Yl6cZ5luAzhw/6SW3PFYUIyyqWy5MCIXweHOwQR2IpQEdlDur5nluN7i7BeB+i
fxwwHh8TU/g7T4mhZFkiTuBKdLAtQOjxWxzqTMxgcuAjlTylY16FgMFOASdvvSbqBZJjbxMdVloU
rYjS8O/8rWktv8GXcaIdBJ2BRj01q7jsChsbwA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Qvl63GHz9mq2xOB7elt/vAQ7URLGdD1Lkcz7f3Wtw31dwjjjbP62Ny/Jr6OmBIheWlgejx38qxAT
TrHiiEyjKmGcnPn1Tn2n+cH4RAxCbOFnCI9n6+YsYMTe9JkplGhGGr39SkFgJz0I2IKpPsuqTjCj
rhf49TAryNMQeRpREJA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MA+9Ro+dh339m0iZrkKbqTKN8gQ5xkxN/SPCfhkOn+5jjgCTS5IOKLHil+HsZDjX333ebxnornwG
MOBxyEdFfLM8SA+bs2r41J/j0af2VVMmCM3hOh8JmZxB4X9Jg/glegNCbvwzqxMbOQNEy+zt7j5t
TFVD82RtPFmYVVYZZyll/WvAA+0aVpyjzLCIM1GznFky0RWLv65Wp4MJJnNRRrtG3muMznVO/u2s
tACsJ9jzv9M0IlMYjYH9BixhG6cZX02I4LEXXaPkhdOINlMMhsbArXtc9NphzmS4bY1/1yF1D6YD
EKLyS2Sr3HDl0O/lefN+jvfG8iKuVl55PNNrVQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
wpMTg7STjFkUDhOqdNPa0FHXTnHQgKmhvqDv+rRVBvMiQ8O7u8oj7ibITq3o+jugJsMJ60B410gQ
JFTcqCJKYmYJvqi8rPLLOYDmFG6ZLP/Ixr3n62IyIaCeDltBahi3yV009QN0X+iuzuFCL+Y7g9ff
IvAgyBly+Z3Itv2H9EJMZPMl17Sa7IkgjmWqzVXIKNMKn0iDVYsQw6ZgzQDYQ8N8IvTIEggU3/lh
6Nf0hV0ev3qOv/2P+4w0U766Ux3yLuzPJSI7bKm3/ip9NjhOytxOiKKqVXhKG8dzbbuS5u3EE/eq
q6YxkL7gpvNltVqqBnJB6vHSyWrD6+MqsCtR9A==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q7Q4SSp70lxFryaopuic9VVP/Ire0pSsPEIMYdURBAczC7ShkuYeV02U7L3BlAiyBE4vBKcwYSQd
cWiaj8sVP7q4kxoRHKxLV1R5PIO6l4DsLWE2E+1MLyUPME0w5KTular/oX8EPCJ5n/8VCtW7x4Vf
dpeyki1/IAPJkAyi3zVZKHzgKhEwnZaZZtZYuMWoPZMt4V38sAcE42Raf+7yfFWG5HO74JY6iEnW
gJeRk58K+avB/XLF2/j2RQZfjTYizrprT2tUMBK6e7DRWZZtk8AOcsMhUikev44IFGNbNXjP8BXC
0J3y3P7pCFT6l+saU83nRwi/H25fSA34diJtNw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
a/8ooC+s+6nfvfa1+oBhsvYWLJjFgp83DI1kNyOi5Am+ugPbGRmgGZudfyo6yw6Yd5gGbLm5aToQ
5G4cGF5HaXD5TU6A0ZZFMTIbzFLE76JMjjIxX8JcaJIZpSmrXqlru8l5gDINUEAmwUY3mRQnjcGJ
0Z+kMRH8iAEF+gEviPiFZSBbJeOPqivIS217kimQJX3BeNbNPQTP+GUidcRywpGMh5avxtA0kDRO
F9SoCSyTm9hr2v9hsK1IUAYQLb7n2/R+z5YNKNzt1oN4qgJH1wZfdI8if2K8+ohyOdnxrrgJOWdj
cOqr7cGqEOYfBMTIQeHVZzb7NGWVN+9B8XSUaQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
FLPvOUNRWNW2GU+FEGmt2XWthOT5bY/31DRbol2cUmEGNF6b2XzpCosNKGx/o2n6sQvGP39KRFCs
nJu0ihe2dUGee9nEZZUcpwPjnEfXVI3yJaRVYy8iL+rm59lXq0jX4sjAPieDvv8shgAnoXLTZGlq
K+2c1JhaHt+nFi27TDrYar/+P8nP1MhocOS7BjzCvSs0foEXj92/qD+71Sm/LqGr8cjlH2qTJJ8B
ynxoH6iT+bksVA2VbtPT9o6h1kJ/zwP4wcsL9l+qSlJhd4GI11JPux26DlNyIi41WmufQcfiT0PB
r6O9+0E9lV9ODwKdjaxfZRK29rjKeq2yr0jWhMV38XKKqHAJli7MIypGRXcCo+u89H87KgYt+ebw
s3foIqCe0JKR57WzI8VD6XdNtOL8eBxK539oemx4vkE0cGYECZKYru6A2hPeZOYDD5eyWSUlQl1R
EciK49WM8HnssyRVcmE6di6bISMbVi0TZG/v98bz+9UZa8DtqMVYH0tz

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
fphquQOeFuqByo36Gh2C1zEC1J6u9swSMbMzsKldIvLm+SZ6/hr/N8KJ/G2vBABzX6UtbVuP1ZXx
AxdftP4Aqis1B3Bs6989aQG9eo0SOHA7r6aFLtFb3qoD5Pvqw4aVNU4z4EtTpFpn/jCWD21lKROf
q5X32HRfFq1jwqod+9vIbUNRRzz5y9VHvXfacZlxDazSPmcCF4hxB1KqWqT44KmYVkDedgkgnYgb
ZGidHnTb3W7C8tSqC9ac4kNJCL429QndtddweESJNlpX+65pt9Irok9pkOodwoj0QScswOIFjhBZ
/GrzZLQcFWiD3gXRU4DazzxQnGdRH4qEIRWziw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
1lUYYHPCt1BUJOvcBbgMU2GSQiqfxItz4ntieMaenjrtsE9SLwaU6xB0tBl8Atw5yP/RRNww1kX/
9uZbTz5He3r9mPVt+mGxB4N3f9BbCrQRb4USVPgKO/+vWUfMQERGklScy0+fz75WuxH74CjRUoDI
8iyssb2cUNnfDe13jIoI8gM1w4w/Pkxkmb6Mef53QMxacHAWEZeytcH3fuL/adO263D8P90U3XJv
vBXJmbjkRVi9qzjBzfMxuOy2KbZaZgR3BLzaffIfFnMwg/Rb8sGls5pQsZv5jL2wk3+Bj3OXBYdd
pDyjGoalJBzObKzd/t15kNHwY4FXYFcZLQPncw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YRmSEzaa2WFVvMH1BwWc1TIUpVbzSEIP0VbI6n0sEgct/X4PiTfMQmK1jBVCaISIzwBxscKQwZOt
mb/nmINGg6I7ih39LSbBMtx6cdCUiyaLkPeRbqfyPpKhvnUIFmdKVvTd1dYzxeOeuDnhSVaBaAcN
3lngSg7lIbmhLIGjC29yQrBTiLArbVZi6IRGronMK51e3UrYa6GspsznhiuRcXjEb4bHKrJ2CM5Z
BUwA+E9949sQgyOagFZbLVle2ESbwBaoxcAPn2gxfRHlT0leqyLgUGDZLsfArzGzw9BTGzyEG2TR
XOrKFNYRfMXMrnGsBM7acIelY4LdAMgsKgDH/A==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 48976)
`pragma protect data_block
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
lK3lh+ExtNUG9+CeYg==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
