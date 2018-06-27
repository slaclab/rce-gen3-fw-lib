-------------------------------------------------------------------------------
-- File       : MigCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-08-03
-- Last update: 2018-06-14
-------------------------------------------------------------------------------
-- Description: Wrapper for the MIG core
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.MigCorePkg.all;

entity MigCore is
   generic (
      TPD_G : time := 1 ns);
   port (
      extRst         : in    sl;
      -- PL DDR MEM Interface
      ddrClk         : out   sl;
      ddrRst         : out   sl;
      ddrWriteMaster : in    AxiWriteMasterType;
      ddrWriteSlave  : out   AxiWriteSlaveType;
      ddrReadMaster  : in    AxiReadMasterType;
      ddrReadSlave   : out   AxiReadSlaveType;
      -- PL DDR MEM Ports
      ddrClkP        : in    sl;
      ddrClkN        : in    sl;
      ddrOut         : out   DdrOutType;
      ddrInOut       : inout DdrInOutType);
end MigCore;

architecture mapping of MigCore is

   component MigIpCore
      port (
         c0_init_calib_complete  : out   std_logic;
         dbg_clk                 : out   std_logic;
         c0_sys_clk_p            : in    std_logic;
         c0_sys_clk_n            : in    std_logic;
         dbg_bus                 : out   std_logic_vector(511 downto 0);
         c0_ddr4_adr             : out   std_logic_vector(16 downto 0);
         c0_ddr4_ba              : out   std_logic_vector(1 downto 0);
         c0_ddr4_cke             : out   std_logic_vector(0 downto 0);
         c0_ddr4_cs_n            : out   std_logic_vector(0 downto 0);
         c0_ddr4_dm_dbi_n        : inout std_logic_vector(7 downto 0);
         c0_ddr4_dq              : inout std_logic_vector(63 downto 0);
         c0_ddr4_dqs_c           : inout std_logic_vector(7 downto 0);
         c0_ddr4_dqs_t           : inout std_logic_vector(7 downto 0);
         c0_ddr4_odt             : out   std_logic_vector(0 downto 0);
         c0_ddr4_bg              : out   std_logic_vector(1 downto 0);
         c0_ddr4_reset_n         : out   std_logic;
         c0_ddr4_act_n           : out   std_logic;
         c0_ddr4_ck_c            : out   std_logic_vector(0 downto 0);
         c0_ddr4_ck_t            : out   std_logic_vector(0 downto 0);
         c0_ddr4_ui_clk          : out   std_logic;
         c0_ddr4_ui_clk_sync_rst : out   std_logic;
         c0_ddr4_aresetn         : in    std_logic;
         c0_ddr4_s_axi_awid      : in    std_logic_vector(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0);
         c0_ddr4_s_axi_awaddr    : in    std_logic_vector(DDR_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         c0_ddr4_s_axi_awlen     : in    std_logic_vector(DDR_AXI_CONFIG_C.LEN_BITS_C-1 downto 0);
         c0_ddr4_s_axi_awsize    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_awburst   : in    std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_awlock    : in    std_logic_vector(0 downto 0);
         c0_ddr4_s_axi_awcache   : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awprot    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_awqos     : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_awvalid   : in    std_logic;
         c0_ddr4_s_axi_awready   : out   std_logic;
         c0_ddr4_s_axi_wdata     : in    std_logic_vector(8*DDR_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0);
         c0_ddr4_s_axi_wstrb     : in    std_logic_vector(DDR_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0);
         c0_ddr4_s_axi_wlast     : in    std_logic;
         c0_ddr4_s_axi_wvalid    : in    std_logic;
         c0_ddr4_s_axi_wready    : out   std_logic;
         c0_ddr4_s_axi_bready    : in    std_logic;
         c0_ddr4_s_axi_bid       : out   std_logic_vector(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0);
         c0_ddr4_s_axi_bresp     : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_bvalid    : out   std_logic;
         c0_ddr4_s_axi_arid      : in    std_logic_vector(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0);
         c0_ddr4_s_axi_araddr    : in    std_logic_vector(DDR_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0);
         c0_ddr4_s_axi_arlen     : in    std_logic_vector(DDR_AXI_CONFIG_C.LEN_BITS_C-1 downto 0);
         c0_ddr4_s_axi_arsize    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_arburst   : in    std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_arlock    : in    std_logic_vector(0 downto 0);
         c0_ddr4_s_axi_arcache   : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_arprot    : in    std_logic_vector(2 downto 0);
         c0_ddr4_s_axi_arqos     : in    std_logic_vector(3 downto 0);
         c0_ddr4_s_axi_arvalid   : in    std_logic;
         c0_ddr4_s_axi_arready   : out   std_logic;
         c0_ddr4_s_axi_rready    : in    std_logic;
         c0_ddr4_s_axi_rlast     : out   std_logic;
         c0_ddr4_s_axi_rvalid    : out   std_logic;
         c0_ddr4_s_axi_rresp     : out   std_logic_vector(1 downto 0);
         c0_ddr4_s_axi_rid       : out   std_logic_vector(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0);
         c0_ddr4_s_axi_rdata     : out   std_logic_vector(8*DDR_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0);
         sys_rst                 : in    std_logic);
   end component;

   signal ddrClock   : sl;
   signal ddrReset   : sl;
   signal ddrCalDone : sl;
   signal coreReset  : sl;
   signal coreRst    : sl;
   signal extRstL    : sl;

begin

   ddrClk <= ddrClock;
   ddrRst <= ddrReset;

   extRstL <= not(extRst);

   U_MIG : MigIpCore
      port map (
         c0_init_calib_complete  => ddrCalDone,
         dbg_clk                 => open,
         c0_sys_clk_p            => ddrClkP,
         c0_sys_clk_n            => ddrClkN,
         dbg_bus                 => open,
         c0_ddr4_adr             => ddrOut.addr,
         c0_ddr4_ba              => ddrOut.ba,
         c0_ddr4_cke             => ddrOut.cke,
         c0_ddr4_cs_n            => ddrOut.csL,
         c0_ddr4_dm_dbi_n        => ddrInOut.dm,
         c0_ddr4_dq              => ddrInOut.dq,
         c0_ddr4_dqs_c           => ddrInOut.dqsC,
         c0_ddr4_dqs_t           => ddrInOut.dqsT,
         c0_ddr4_odt             => ddrOut.odt,
         c0_ddr4_bg              => ddrOut.bg,
         c0_ddr4_reset_n         => ddrOut.rstL,
         c0_ddr4_act_n           => ddrOut.actL,
         c0_ddr4_ck_c            => ddrOut.ckC,
         c0_ddr4_ck_t            => ddrOut.ckT,
         c0_ddr4_ui_clk          => ddrClk,
         c0_ddr4_ui_clk_sync_rst => coreReset,
         c0_ddr4_aresetn         => extRstL,
         c0_ddr4_s_axi_awid      => ddrWriteMaster.awid(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         c0_ddr4_s_axi_awaddr    => ddrWriteMaster.awaddr(DDR_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         c0_ddr4_s_axi_awlen     => ddrWriteMaster.awlen(DDR_AXI_CONFIG_C.LEN_BITS_C-1 downto 0),
         c0_ddr4_s_axi_awsize    => ddrWriteMaster.awsize(2 downto 0),
         c0_ddr4_s_axi_awburst   => ddrWriteMaster.awburst(1 downto 0),
         c0_ddr4_s_axi_awlock    => ddrWriteMaster.awlock(0 downto 0),
         c0_ddr4_s_axi_awcache   => ddrWriteMaster.awcache(3 downto 0),
         c0_ddr4_s_axi_awprot    => ddrWriteMaster.awprot(2 downto 0),
         c0_ddr4_s_axi_awqos     => ddrWriteMaster.awqos(3 downto 0),
         c0_ddr4_s_axi_awvalid   => ddrWriteMaster.awvalid,
         c0_ddr4_s_axi_awready   => ddrWriteSlave.awready,
         c0_ddr4_s_axi_wdata     => ddrWriteMaster.wdata(8*DDR_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0),
         c0_ddr4_s_axi_wstrb     => ddrWriteMaster.wstrb(DDR_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0),
         c0_ddr4_s_axi_wlast     => ddrWriteMaster.wlast,
         c0_ddr4_s_axi_wvalid    => ddrWriteMaster.wvalid,
         c0_ddr4_s_axi_wready    => ddrWriteSlave.wready,
         c0_ddr4_s_axi_bready    => ddrWriteMaster.bready,
         c0_ddr4_s_axi_bid       => ddrWriteSlave.bid(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         c0_ddr4_s_axi_bresp     => ddrWriteSlave.bresp(1 downto 0),
         c0_ddr4_s_axi_bvalid    => ddrWriteSlave.bvalid,
         c0_ddr4_s_axi_arid      => ddrReadMaster.arid(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         c0_ddr4_s_axi_araddr    => ddrReadMaster.araddr(DDR_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0),
         c0_ddr4_s_axi_arlen     => ddrReadMaster.arlen(DDR_AXI_CONFIG_C.LEN_BITS_C-1 downto 0),
         c0_ddr4_s_axi_arsize    => ddrReadMaster.arsize(2 downto 0),
         c0_ddr4_s_axi_arburst   => ddrReadMaster.arburst(1 downto 0),
         c0_ddr4_s_axi_arlock    => ddrReadMaster.arlock(0 downto 0),
         c0_ddr4_s_axi_arcache   => ddrReadMaster.arcache(3 downto 0),
         c0_ddr4_s_axi_arprot    => ddrReadMaster.arprot(2 downto 0),
         c0_ddr4_s_axi_arqos     => ddrReadMaster.arqos(3 downto 0),
         c0_ddr4_s_axi_arvalid   => ddrReadMaster.arvalid,
         c0_ddr4_s_axi_arready   => ddrReadSlave.arready,
         c0_ddr4_s_axi_rready    => ddrReadMaster.rready,
         c0_ddr4_s_axi_rlast     => ddrReadSlave.rlast,
         c0_ddr4_s_axi_rvalid    => ddrReadSlave.rvalid,
         c0_ddr4_s_axi_rresp     => ddrReadSlave.rresp(1 downto 0),
         c0_ddr4_s_axi_rid       => ddrReadSlave.rid(DDR_AXI_CONFIG_C.ID_BITS_C-1 downto 0),
         c0_ddr4_s_axi_rdata     => ddrReadSlave.rdata(8*DDR_AXI_CONFIG_C.DATA_BYTES_C-1 downto 0),
         sys_rst                 => extRst);

   coreRst <= coreReset and not(ddrCalDone);

   U_Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ddrClock,
         rstIn  => coreRst,
         rstOut => ddrReset);

end mapping;
