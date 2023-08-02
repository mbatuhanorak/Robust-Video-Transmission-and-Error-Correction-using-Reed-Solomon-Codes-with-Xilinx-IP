-- (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- (c) Copyright 2022-2023 Advanced Micro Devices, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:sid:8.0
-- IP Revision: 18

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY sid_v8_0_18;
USE sid_v8_0_18.sid_v8_0_18;

ENTITY sid_de_interleaver IS
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tlast : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tlast : OUT STD_LOGIC;
    m_axis_data_tready : IN STD_LOGIC;
    event_tlast_unexpected : OUT STD_LOGIC;
    event_tlast_missing : OUT STD_LOGIC;
    event_halted : OUT STD_LOGIC
  );
END sid_de_interleaver;

ARCHITECTURE sid_de_interleaver_arch OF sid_de_interleaver IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF sid_de_interleaver_arch: ARCHITECTURE IS "yes";
  COMPONENT sid_v8_0_18 IS
    GENERIC (
      c_xdevicefamily : STRING;
      c_family : STRING;
      c_architecture : INTEGER;
      c_mem_init_prefix : STRING;
      c_elaboration_dir : STRING;
      c_type : INTEGER;
      c_mode : INTEGER;
      c_symbol_width : INTEGER;
      c_row_type : INTEGER;
      c_row_constant : INTEGER;
      c_has_row : INTEGER;
      c_has_row_valid : INTEGER;
      c_min_num_rows : INTEGER;
      c_row_width : INTEGER;
      c_num_selectable_rows : INTEGER;
      c_row_select_file : STRING;
      c_has_row_sel : INTEGER;
      c_has_row_sel_valid : INTEGER;
      c_use_row_permute_file : INTEGER;
      c_row_permute_file : STRING;
      c_col_type : INTEGER;
      c_col_constant : INTEGER;
      c_has_col : INTEGER;
      c_has_col_valid : INTEGER;
      c_min_num_cols : INTEGER;
      c_col_width : INTEGER;
      c_num_selectable_cols : INTEGER;
      c_col_select_file : STRING;
      c_has_col_sel : INTEGER;
      c_has_col_sel_valid : INTEGER;
      c_use_col_permute_file : INTEGER;
      c_col_permute_file : STRING;
      c_block_size_type : INTEGER;
      c_block_size_constant : INTEGER;
      c_has_block_size : INTEGER;
      c_block_size_width : INTEGER;
      c_has_block_size_valid : INTEGER;
      c_num_branches : INTEGER;
      c_branch_length_type : INTEGER;
      c_branch_length_constant : INTEGER;
      c_branch_length_file : STRING;
      c_num_configurations : INTEGER;
      c_external_ram : INTEGER;
      c_ext_mem_latency : INTEGER;
      c_ext_addr_width : INTEGER;
      c_memstyle : INTEGER;
      c_pipe_level : INTEGER;
      c_throughput_mode : INTEGER;
      c_has_aclken : INTEGER;
      c_has_aresetn : INTEGER;
      c_has_rdy : INTEGER;
      c_has_block_start : INTEGER;
      c_has_block_end : INTEGER;
      c_has_fdo : INTEGER;
      c_s_axis_ctrl_tdata_width : INTEGER;
      c_s_axis_data_tdata_width : INTEGER;
      c_m_axis_data_tdata_width : INTEGER;
      c_m_axis_data_tuser_width : INTEGER;
      c_has_dout_tready : INTEGER
    );
    PORT (
      aclk : IN STD_LOGIC;
      aclken : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s_axis_ctrl_tdata : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      s_axis_ctrl_tvalid : IN STD_LOGIC;
      s_axis_ctrl_tready : OUT STD_LOGIC;
      s_axis_data_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s_axis_data_tvalid : IN STD_LOGIC;
      s_axis_data_tlast : IN STD_LOGIC;
      s_axis_data_tready : OUT STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axis_data_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tlast : OUT STD_LOGIC;
      m_axis_data_tready : IN STD_LOGIC;
      rd_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      rd_en : OUT STD_LOGIC;
      wr_en : OUT STD_LOGIC;
      rd_addr : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
      wr_addr : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
      wr_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      event_tlast_unexpected : OUT STD_LOGIC;
      event_tlast_missing : OUT STD_LOGIC;
      event_halted : OUT STD_LOGIC;
      event_row_valid : OUT STD_LOGIC;
      event_col_valid : OUT STD_LOGIC;
      event_row_sel_valid : OUT STD_LOGIC;
      event_col_sel_valid : OUT STD_LOGIC;
      event_block_size_valid : OUT STD_LOGIC
    );
  END COMPONENT sid_v8_0_18;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF sid_de_interleaver_arch: ARCHITECTURE IS "sid_v8_0_18,Vivado 2023.1";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF sid_de_interleaver_arch : ARCHITECTURE IS "sid_de_interleaver,sid_v8_0_18,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF sid_de_interleaver_arch: ARCHITECTURE IS "sid_de_interleaver,sid_v8_0_18,{x_ipProduct=Vivado 2023.1,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=sid,x_ipVersion=8.0,x_ipCoreRevision=18,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,c_xdevicefamily=zynquplus,c_family=zynquplus,c_architecture=0,c_mem_init_prefix=sid_de_interleaver,c_elaboration_dir=./,c_type=0,c_mode=1,c_symbol_width=8,c_row_type=0,c_row_constant=192,c_has_row=0,c_has_row_valid=0,c_min_num_rows=15,c_row_width=4,c_num_selectable_rows=4,c_row_select_file=sid_de_interleaver_RS.mif" & 
",c_has_row_sel=0,c_has_row_sel_valid=0,c_use_row_permute_file=0,c_row_permute_file=sid_de_interleaver_RP.mif,c_col_type=0,c_col_constant=2,c_has_col=0,c_has_col_valid=0,c_min_num_cols=15,c_col_width=4,c_num_selectable_cols=4,c_col_select_file=sid_de_interleaver_CS.mif,c_has_col_sel=0,c_has_col_sel_valid=0,c_use_col_permute_file=0,c_col_permute_file=sid_de_interleaver_CP.mif,c_block_size_type=3,c_block_size_constant=225,c_has_block_size=0,c_block_size_width=8,c_has_block_size_valid=0,c_num_branch" & 
"es=16,c_branch_length_type=0,c_branch_length_constant=16,c_branch_length_file=sid_de_interleaver.mif,c_num_configurations=1,c_external_ram=0,c_ext_mem_latency=0,c_ext_addr_width=9,c_memstyle=2,c_pipe_level=2,c_throughput_mode=0,c_has_aclken=0,c_has_aresetn=1,c_has_rdy=0,c_has_block_start=0,c_has_block_end=0,c_has_fdo=0,c_s_axis_ctrl_tdata_width=1,c_s_axis_data_tdata_width=8,c_m_axis_data_tdata_width=8,c_m_axis_data_tuser_width=1,c_has_dout_tready=1,x_ipLicense=sid@2013.03(hardware_evaluation)}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF aclk: SIGNAL IS "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF S_AXIS_CTRL:M_AXIS_DATA:S_AXIS_DATA, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 aclk_intf CLK";
  ATTRIBUTE X_INTERFACE_PARAMETER OF aresetn: SIGNAL IS "XIL_INTERFACENAME aresetn_intf, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 aresetn_intf RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF event_halted: SIGNAL IS "XIL_INTERFACENAME event_halted_intf, SENSITIVITY EDGE_RISING, PORTWIDTH 1";
  ATTRIBUTE X_INTERFACE_INFO OF event_halted: SIGNAL IS "xilinx.com:signal:interrupt:1.0 event_halted_intf INTERRUPT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF event_tlast_missing: SIGNAL IS "XIL_INTERFACENAME event_tlast_missing_intf, SENSITIVITY EDGE_RISING, PORTWIDTH 1";
  ATTRIBUTE X_INTERFACE_INFO OF event_tlast_missing: SIGNAL IS "xilinx.com:signal:interrupt:1.0 event_tlast_missing_intf INTERRUPT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF event_tlast_unexpected: SIGNAL IS "XIL_INTERFACENAME event_tlast_unexpected_intf, SENSITIVITY EDGE_RISING, PORTWIDTH 1";
  ATTRIBUTE X_INTERFACE_INFO OF event_tlast_unexpected: SIGNAL IS "xilinx.com:signal:interrupt:1.0 event_tlast_unexpected_intf INTERRUPT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF m_axis_data_tdata: SIGNAL IS "XIL_INTERFACENAME M_AXIS_DATA, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_data_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 M_AXIS_DATA TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_data_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 M_AXIS_DATA TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_data_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 M_AXIS_DATA TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_data_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 M_AXIS_DATA TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axis_data_tdata: SIGNAL IS "XIL_INTERFACENAME S_AXIS_DATA, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_data_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 S_AXIS_DATA TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_data_tlast: SIGNAL IS "xilinx.com:interface:axis:1.0 S_AXIS_DATA TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_data_tready: SIGNAL IS "xilinx.com:interface:axis:1.0 S_AXIS_DATA TREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axis_data_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 S_AXIS_DATA TVALID";
BEGIN
  U0 : sid_v8_0_18
    GENERIC MAP (
      c_xdevicefamily => "zynquplus",
      c_family => "zynquplus",
      c_architecture => 0,
      c_mem_init_prefix => "sid_de_interleaver",
      c_elaboration_dir => "./",
      c_type => 0,
      c_mode => 1,
      c_symbol_width => 8,
      c_row_type => 0,
      c_row_constant => 192,
      c_has_row => 0,
      c_has_row_valid => 0,
      c_min_num_rows => 15,
      c_row_width => 4,
      c_num_selectable_rows => 4,
      c_row_select_file => "sid_de_interleaver_RS.mif",
      c_has_row_sel => 0,
      c_has_row_sel_valid => 0,
      c_use_row_permute_file => 0,
      c_row_permute_file => "sid_de_interleaver_RP.mif",
      c_col_type => 0,
      c_col_constant => 2,
      c_has_col => 0,
      c_has_col_valid => 0,
      c_min_num_cols => 15,
      c_col_width => 4,
      c_num_selectable_cols => 4,
      c_col_select_file => "sid_de_interleaver_CS.mif",
      c_has_col_sel => 0,
      c_has_col_sel_valid => 0,
      c_use_col_permute_file => 0,
      c_col_permute_file => "sid_de_interleaver_CP.mif",
      c_block_size_type => 3,
      c_block_size_constant => 225,
      c_has_block_size => 0,
      c_block_size_width => 8,
      c_has_block_size_valid => 0,
      c_num_branches => 16,
      c_branch_length_type => 0,
      c_branch_length_constant => 16,
      c_branch_length_file => "sid_de_interleaver.mif",
      c_num_configurations => 1,
      c_external_ram => 0,
      c_ext_mem_latency => 0,
      c_ext_addr_width => 9,
      c_memstyle => 2,
      c_pipe_level => 2,
      c_throughput_mode => 0,
      c_has_aclken => 0,
      c_has_aresetn => 1,
      c_has_rdy => 0,
      c_has_block_start => 0,
      c_has_block_end => 0,
      c_has_fdo => 0,
      c_s_axis_ctrl_tdata_width => 1,
      c_s_axis_data_tdata_width => 8,
      c_m_axis_data_tdata_width => 8,
      c_m_axis_data_tuser_width => 1,
      c_has_dout_tready => 1
    )
    PORT MAP (
      aclk => aclk,
      aclken => '1',
      aresetn => aresetn,
      s_axis_ctrl_tdata => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      s_axis_ctrl_tvalid => '1',
      s_axis_data_tdata => s_axis_data_tdata,
      s_axis_data_tvalid => s_axis_data_tvalid,
      s_axis_data_tlast => s_axis_data_tlast,
      s_axis_data_tready => s_axis_data_tready,
      m_axis_data_tdata => m_axis_data_tdata,
      m_axis_data_tvalid => m_axis_data_tvalid,
      m_axis_data_tlast => m_axis_data_tlast,
      m_axis_data_tready => m_axis_data_tready,
      rd_data => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)),
      event_tlast_unexpected => event_tlast_unexpected,
      event_tlast_missing => event_tlast_missing,
      event_halted => event_halted
    );
END sid_de_interleaver_arch;
