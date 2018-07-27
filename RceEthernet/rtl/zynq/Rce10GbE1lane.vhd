-------------------------------------------------------------------------------
-- File       : Rce10GbE1lane.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-06-27
-- Last update: 2018-07-27
-------------------------------------------------------------------------------
-- Description: 10 GigE (1 lane)
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

entity Rce10GbE1lane is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Misc. Signals
      extRst    : in  sl;
      coreClk   : in  sl;
      coreRst   : in  sl;
      phyClk    : out sl;
      phyRst    : out sl;
      phyReady  : out sl;
      phyStatus : out slv(7 downto 0);
      phyDebug  : out slv(5 downto 0);
      phyConfig : in  slv(6 downto 0);
      -- PHY Interface
      xgmiiRxd  : out slv(63 downto 0);
      xgmiiRxc  : out slv(7 downto 0);
      xgmiiTxd  : in  slv(63 downto 0);
      xgmiiTxc  : in  slv(7 downto 0);
      -- MGT Ports
      gtRefClk  : in  sl;
      gtTxP     : out sl;
      gtTxN     : out sl;
      gtRxP     : in  sl;
      gtRxN     : in  sl);
end Rce10GbE1lane;

architecture mapping of Rce10GbE1lane is

   component TenGigEthGtx7Core
      port (
         rxrecclk_out         : out std_logic;
         coreclk              : in  std_logic;
         dclk                 : in  std_logic;
         txusrclk             : in  std_logic;
         txusrclk2            : in  std_logic;
         areset               : in  std_logic;
         txoutclk             : out std_logic;
         areset_coreclk       : in  std_logic;
         gttxreset            : in  std_logic;
         gtrxreset            : in  std_logic;
         txuserrdy            : in  std_logic;
         qplllock             : in  std_logic;
         qplloutclk           : in  std_logic;
         qplloutrefclk        : in  std_logic;
         reset_counter_done   : in  std_logic;
         txp                  : out std_logic;
         txn                  : out std_logic;
         rxp                  : in  std_logic;
         rxn                  : in  std_logic;
         sim_speedup_control  : in  std_logic;
         xgmii_txd            : in  std_logic_vector(63 downto 0);
         xgmii_txc            : in  std_logic_vector(7 downto 0);
         xgmii_rxd            : out std_logic_vector(63 downto 0);
         xgmii_rxc            : out std_logic_vector(7 downto 0);
         configuration_vector : in  std_logic_vector(535 downto 0);
         status_vector        : out std_logic_vector(447 downto 0);
         core_status          : out std_logic_vector(7 downto 0);
         tx_resetdone         : out std_logic;
         rx_resetdone         : out std_logic;
         signal_detect        : in  std_logic;
         tx_fault             : in  std_logic;
         drp_req              : out std_logic;
         drp_gnt              : in  std_logic;
         drp_den_o            : out std_logic;
         drp_dwe_o            : out std_logic;
         drp_daddr_o          : out std_logic_vector(15 downto 0);
         drp_di_o             : out std_logic_vector(15 downto 0);
         drp_drdy_o           : out std_logic;
         drp_drpdo_o          : out std_logic_vector(15 downto 0);
         drp_den_i            : in  std_logic;
         drp_dwe_i            : in  std_logic;
         drp_daddr_i          : in  std_logic_vector(15 downto 0);
         drp_di_i             : in  std_logic_vector(15 downto 0);
         drp_drdy_i           : in  std_logic;
         drp_drpdo_i          : in  std_logic_vector(15 downto 0);
         tx_disable           : out std_logic;
         pma_pmd_type         : in  std_logic_vector(2 downto 0));
   end component;

   signal qplllock      : sl;
   signal qplloutclk    : sl;
   signal qplloutrefclk : sl;

   signal qpllRst   : sl;
   signal qpllReset : sl;

   signal drpReqGnt : sl;
   signal drpEn     : sl;
   signal drpWe     : sl;
   signal drpAddr   : slv(15 downto 0);
   signal drpDi     : slv(15 downto 0);
   signal drpRdy    : sl;
   signal drpDo     : slv(15 downto 0);

   signal configurationVector : slv(535 downto 0) := (others => '0');

   signal phyClock   : sl;
   signal phyReset   : sl;
   signal txClk322   : sl;
   signal txUsrClk   : sl;
   signal txUsrClk2  : sl;
   signal txUsrRdy   : sl;
   signal gtTxRst    : sl;
   signal gtRxRst    : sl;
   signal rstCntDone : sl;

   signal status : slv(7 downto 0);

begin

   phyClk <= phyClock;
   phyRst <= phyReset;

   phyClock <= coreClk;
   phyReset <= coreRst;

   phyStatus <= status;
   phyReady  <= status(0);
   phyDebug  <= (others => '0');

   ----------------------
   -- Common Clock Module 
   ----------------------
   U_QPLL : entity work.Gtx7QuadPll
      generic map (
         TPD_G               => TPD_G,
         SIM_RESET_SPEEDUP_G => "TRUE",        --Does not affect hardware
         SIM_VERSION_G       => "4.0",
         QPLL_CFG_G          => x"0680181",
         QPLL_REFCLK_SEL_G   => "001",
         QPLL_FBDIV_G        => "0101000000",  -- 64B/66B Encoding
         QPLL_FBDIV_RATIO_G  => '0',    -- 64B/66B Encoding
         QPLL_REFCLK_DIV_G   => 1)
      port map (
         qPllRefClk     => gtRefClk,    -- 156.25 MHz
         qPllOutClk     => qPllOutClk,
         qPllOutRefClk  => qPllOutRefClk,
         qPllLock       => qPllLock,
         qPllLockDetClk => '0',  -- IP Core ties this to GND (see note below) 
         qPllRefClkLost => open,
         qPllPowerDown  => '0',
         qPllReset      => qpllReset);
   ---------------------------------------------------------------------------------------------
   -- Note: GTXE2_COMMON pin gtxe2_common_0_i.QPLLLOCKDETCLK cannot be driven by a clock derived 
   --       from the same clock used as the reference clock for the QPLL, including TXOUTCLK*, 
   --       RXOUTCLK*, the output from the IBUFDS_GTE2 providing the reference clock, and any 
   --       buffered or multiplied/divided versions of these clock outputs. Please see UG476 for 
   --       more information. Source, through a clock buffer, is the same as the GT cell 
   --       reference clock.
   ---------------------------------------------------------------------------------------------   

   qpllReset <= qpllRst and not(qPllLock);

   -----------------
   -- 10GBASE-R core
   -----------------
   U_IpCore : TenGigEthGtx7Core
      port map (
         -- Clocks and Resets
         rxrecclk_out         => open,
         coreclk              => phyClock,
         txoutclk             => txClk322,
         areset_coreclk       => phyReset,
         dclk                 => phyClock,
         txusrclk             => txUsrClk,
         txusrclk2            => txUsrClk2,
         areset               => extRst,
         gttxreset            => gtTxRst,
         gtrxreset            => gtRxRst,
         txuserrdy            => txUsrRdy,
         reset_counter_done   => rstCntDone,
         -- Quad PLL Interface
         qplllock             => qplllock,
         qplloutclk           => qplloutclk,
         qplloutrefclk        => qplloutrefclk,
         -- MGT Ports
         txp                  => gtTxP,
         txn                  => gtTxN,
         rxp                  => gtRxP,
         rxn                  => gtRxN,
         -- PHY Interface
         xgmii_txd            => xgmiiTxd,
         xgmii_txc            => xgmiiTxc,
         xgmii_rxd            => xgmiiRxd,
         xgmii_rxc            => xgmiiRxc,
         -- Configuration and Status
         sim_speedup_control  => '0',
         configuration_vector => configurationVector,
         status_vector        => open,
         core_status          => status,
         tx_resetdone         => open,
         rx_resetdone         => open,
         signal_detect        => '1',
         tx_fault             => '0',
         tx_disable           => open,
         pma_pmd_type         => "111",
         -- DRP interface
         -- Note: If no arbitration is required on the GT DRP ports 
         -- then connect REQ to GNT and connect other signals i <= o;         
         drp_req              => drpReqGnt,
         drp_gnt              => drpReqGnt,
         drp_den_o            => drpEn,
         drp_dwe_o            => drpWe,
         drp_daddr_o          => drpAddr,
         drp_di_o             => drpDi,
         drp_drdy_o           => drpRdy,
         drp_drpdo_o          => drpDo,
         drp_den_i            => drpEn,
         drp_dwe_i            => drpWe,
         drp_daddr_i          => drpAddr,
         drp_di_i             => drpDi,
         drp_drdy_i           => drpRdy,
         drp_drpdo_i          => drpDo);

   -------------------------------------
   -- 10GBASE-R's Reset Module
   -------------------------------------        
   U_TenGigEthRst : entity work.TenGigEthRst
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clocks and Resets
         extRst     => extRst,
         phyClk     => phyClock,
         phyRst     => phyReset,
         txClk322   => txClk322,
         txUsrClk   => txUsrClk,
         txUsrClk2  => txUsrClk2,
         gtTxRst    => gtTxRst,
         gtRxRst    => gtRxRst,
         txUsrRdy   => txUsrRdy,
         rstCntDone => rstCntDone,
         -- Quad PLL Ports
         qplllock   => qplllock,
         qpllRst    => qpllRst);

   -------------------------------         
   -- Configuration Vector Mapping
   -------------------------------         
   configurationVector(399 downto 384) <= x"4C4B";  -- timer_ctrl = 0x4C4B (default)   

end mapping;
