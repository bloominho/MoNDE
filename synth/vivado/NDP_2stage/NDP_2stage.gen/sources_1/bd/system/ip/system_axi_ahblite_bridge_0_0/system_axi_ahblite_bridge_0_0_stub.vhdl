-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.1 (lin64) Build 3865809 Sun May  7 15:04:56 MDT 2023
-- Date        : Fri Aug  2 11:55:03 2024
-- Host        : owl running 64-bit CentOS Linux release 7.9.2009 (Core)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/kimth/bloominho/vivado/NDP_2stage/NDP_2stage.gen/sources_1/bd/system/ip/system_axi_ahblite_bridge_0_0/system_axi_ahblite_bridge_0_0_stub.vhdl
-- Design      : system_axi_ahblite_bridge_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z045ffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity system_axi_ahblite_bridge_0_0 is
  Port ( 
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_awlock : in STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rlast : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    m_ahb_haddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_ahb_hwrite : out STD_LOGIC;
    m_ahb_hsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_ahb_hburst : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_ahb_hprot : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_ahb_htrans : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_ahb_hmastlock : out STD_LOGIC;
    m_ahb_hwdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_ahb_hready : in STD_LOGIC;
    m_ahb_hrdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_ahb_hresp : in STD_LOGIC
  );

end system_axi_ahblite_bridge_0_0;

architecture stub of system_axi_ahblite_bridge_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "s_axi_aclk,s_axi_aresetn,s_axi_awid[11:0],s_axi_awlen[7:0],s_axi_awsize[2:0],s_axi_awburst[1:0],s_axi_awcache[3:0],s_axi_awaddr[31:0],s_axi_awprot[2:0],s_axi_awvalid,s_axi_awready,s_axi_awlock,s_axi_wdata[31:0],s_axi_wstrb[3:0],s_axi_wlast,s_axi_wvalid,s_axi_wready,s_axi_bid[11:0],s_axi_bresp[1:0],s_axi_bvalid,s_axi_bready,s_axi_arid[11:0],s_axi_araddr[31:0],s_axi_arprot[2:0],s_axi_arcache[3:0],s_axi_arvalid,s_axi_arlen[7:0],s_axi_arsize[2:0],s_axi_arburst[1:0],s_axi_arlock,s_axi_arready,s_axi_rid[11:0],s_axi_rdata[31:0],s_axi_rresp[1:0],s_axi_rvalid,s_axi_rlast,s_axi_rready,m_ahb_haddr[31:0],m_ahb_hwrite,m_ahb_hsize[2:0],m_ahb_hburst[2:0],m_ahb_hprot[3:0],m_ahb_htrans[1:0],m_ahb_hmastlock,m_ahb_hwdata[31:0],m_ahb_hready,m_ahb_hrdata[31:0],m_ahb_hresp";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "axi_ahblite_bridge,Vivado 2023.1";
begin
end;
