-------------------------------------------------------------------------------
-- File       : Rce10GbE4lane.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: 10 GigE XAUI
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


library surf;
use surf.StdRtlPkg.all;

entity Rce10GbE4lane is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Misc. Signals
      extRst    : in  sl;
      dclk      : in  sl;
      phyClk    : out sl;
      phyRst    : out sl;
      phyReady  : out sl;
      phyStatus : out slv(7 downto 0);
      phyDebug  : out slv(5 downto 0);
      phyConfig : in  slv(6 downto 0);
      stableClk : in  sl;               -- free-running clock reference
      stableRst : in  sl;
      -- PHY Interface
      xgmiiRxd  : out slv(63 downto 0);
      xgmiiRxc  : out slv(7 downto 0);
      xgmiiTxd  : in  slv(63 downto 0);
      xgmiiTxc  : in  slv(7 downto 0);
      -- MGT Ports
      gtRefClk  : in  sl;
      gtTxP     : out slv(3 downto 0);
      gtTxN     : out slv(3 downto 0);
      gtRxP     : in  slv(3 downto 0);
      gtRxN     : in  slv(3 downto 0));
end Rce10GbE4lane;

architecture mapping of Rce10GbE4lane is

   signal phyClock : sl;
   signal phyReset : sl;
   signal phyLock  : sl;
   signal status   : slv(7 downto 0);

begin

   phyClk    <= phyClock;
   phyRst    <= phyReset;
   phyStatus <= status;
   phyReady  <= status(7);

   --------------------
   -- 10 GigE XAUI Core
   --------------------
   U_IpCore : entity surf.XauiGtx7Core
      port map (
         -- Clocks and Resets
         dclk                 => dclk,
         reset                => extRst,
         clk156_out           => phyClock,
         clk156_lock          => phyLock,
         refclk               => gtRefClk,
         -- PHY Interface
         xgmii_txd            => xgmiiTxd,
         xgmii_txc            => xgmiiTxc,
         xgmii_rxd            => xgmiiRxd,
         xgmii_rxc            => xgmiiRxc,
         -- MGT Ports
         xaui_tx_l0_p         => gtTxP(0),
         xaui_tx_l0_n         => gtTxN(0),
         xaui_tx_l1_p         => gtTxP(1),
         xaui_tx_l1_n         => gtTxN(1),
         xaui_tx_l2_p         => gtTxP(2),
         xaui_tx_l2_n         => gtTxN(2),
         xaui_tx_l3_p         => gtTxP(3),
         xaui_tx_l3_n         => gtTxN(3),
         xaui_rx_l0_p         => gtRxP(0),
         xaui_rx_l0_n         => gtRxN(0),
         xaui_rx_l1_p         => gtRxP(1),
         xaui_rx_l1_n         => gtRxN(1),
         xaui_rx_l2_p         => gtRxP(2),
         xaui_rx_l2_n         => gtRxN(2),
         xaui_rx_l3_p         => gtRxP(3),
         xaui_rx_l3_n         => gtRxN(3),
         -- Configuration and Status
         signal_detect        => (others => '1'),
         debug                => phyDebug,
         configuration_vector => phyConfig,
         status_vector        => status);

   U_EthClkRst : entity surf.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '0',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 3)
      port map (
         clk      => phyClock,
         asyncRst => phyLock,
         syncRst  => phyReset);

end mapping;
