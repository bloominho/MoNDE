// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.1 (lin64) Build 3865809 Sun May  7 15:04:56 MDT 2023
// Date        : Fri Jul 26 18:55:36 2024
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [3:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [2:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [63:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [63:0]doutb;

  wire [3:0]addra;
  wire [2:0]addrb;
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
  wire [2:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [2:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "4" *) 
  (* C_ADDRB_WIDTH = "3" *) 
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
  (* C_READ_DEPTH_A = "10" *) 
  (* C_READ_DEPTH_B = "5" *) 
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
  (* C_WRITE_DEPTH_A = "10" *) 
  (* C_WRITE_DEPTH_B = "5" *) 
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
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[2:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[2:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 49088)
`pragma protect data_block
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
T88roHlvf89OCmQ=
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
