-------------------------------------------------------------------------------
-- File       : Rce1GbE1lane.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-06-27
-- Last update: 2018-08-11
-------------------------------------------------------------------------------
-- Description: 1 GigE (1 lane)
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
use work.GigEthPkg.all;

entity Rce1GbE1lane is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Misc. Signals
      extRst    : in  sl;
      sysClk62  : in  sl;
      sysClk125 : in  sl;
      sysRst125 : in  sl;
      phyReady  : out sl;
      phyStatus : out slv(7 downto 0);
      phyDebug  : out slv(5 downto 0);
      phyConfig : in  slv(6 downto 0);
      -- PHY Interface
      gmiiRxDv  : out sl;
      gmiiRxEr  : out sl;
      gmiiRxd   : out slv(7 downto 0);
      gmiiTxEn  : in  sl;
      gmiiTxEr  : in  sl;
      gmiiTxd   : in  slv(7 downto 0);
      -- MGT Ports
      gtTxP     : out sl;
      gtTxN     : out sl;
      gtRxP     : in  sl;
      gtRxN     : in  sl);
end Rce1GbE1lane;

architecture mapping of Rce1GbE1lane is

   signal coreRst : sl;
   signal status  : slv(15 downto 0);

begin

   phyReady  <= status(1);
   phyStatus <= x"FC"    when(status(1) = '1') else x"00";
   phyDebug  <= "111111" when(status(1) = '1') else "000000";

   U_PwrUpRst : entity work.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => 1000)
      port map (
         clk    => sysClk125,
         arst   => extRst,
         rstOut => coreRst);

   ------------------
   -- 1000BASE-X core
   ------------------
   U_IpCore : entity work.GigEthGthUltraScaleCore
      port map (
         -- Clocks and Resets
         gtrefclk               => sysClk125,  -- Used as CPLL clock reference
         independent_clock_bufg => sysClk62,  -- Used for the GT free running and DRP clock
         txoutclk               => open,
         rxoutclk               => open,
         userclk                => sysClk62,
         userclk2               => sysClk125,
         rxuserclk              => sysClk62,
         rxuserclk2             => sysClk62,
         reset                  => coreRst,
         pma_reset              => coreRst,
         resetdone              => open,
         mmcm_locked            => '1',
         mmcm_reset             => open,
         cplllock               => open,
         -- PHY Interface
         gmii_txd               => gmiiTxd,
         gmii_tx_en             => gmiiTxEn,
         gmii_tx_er             => gmiiTxEr,
         gmii_rxd               => gmiiRxd,
         gmii_rx_dv             => gmiiRxDv,
         gmii_rx_er             => gmiiRxEr,
         gmii_isolate           => open,
         -- MGT Ports
         txp                    => gtTxP,
         txn                    => gtTxN,
         rxp                    => gtRxP,
         rxn                    => gtRxN,
         -- Configuration and Status
         an_restart_config      => '0',
         an_adv_config_vector   => GIG_ETH_AN_ADV_CONFIG_INIT_C,
         an_interrupt           => open,
         configuration_vector   => "00000",
         status_vector          => status,
         signal_detect          => '1');

end mapping;
