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
      extRst         : in  sl;
      dclk           : in  sl;
      phyClk         : out sl;
      phyRst         : out sl;
      phyReady       : out sl;
      phyStatus      : out slv(7 downto 0);
      phyDebug       : out slv(5 downto 0);
      phyConfig      : in  slv(6 downto 0);
      stableClk      : in  sl;          -- free-running clock reference
      stableRst      : in  sl;
      -- Transceiver Debug Interface
      gtTxPreCursor  : in  slv(19 downto 0) := (others => '0');
      gtTxPostCursor : in  slv(19 downto 0) := (others => '0');
      gtTxDiffCtrl   : in  slv(19 downto 0) := (others => '1');
      gtRxPolarity   : in  slv(3 downto 0)  := x"0";
      gtTxPolarity   : in  slv(3 downto 0)  := x"0";
      -- PHY Interface
      xgmiiRxd       : out slv(63 downto 0);
      xgmiiRxc       : out slv(7 downto 0);
      xgmiiTxd       : in  slv(63 downto 0);
      xgmiiTxc       : in  slv(7 downto 0);
      -- MGT Ports
      gtRefClk       : in  sl;
      gtTxP          : out slv(3 downto 0);
      gtTxN          : out slv(3 downto 0);
      gtRxP          : in  slv(3 downto 0);
      gtRxN          : in  slv(3 downto 0));
end Rce10GbE4lane;

architecture mapping of Rce10GbE4lane is

   signal phyClock : sl;
   signal phyReset : sl;
   signal phyLock  : sl;
   signal status   : slv(7 downto 0);

   component XauiGthUltraScale156p25MHz10GigECore is
      port (
         dclk                 : in  std_logic;
         reset                : in  std_logic;
         clk156_out           : out std_logic;
         clk156_lock          : out std_logic;
         refclk               : in  std_logic;
         xgmii_txd            : in  std_logic_vector (63 downto 0);
         xgmii_txc            : in  std_logic_vector (7 downto 0);
         xgmii_rxd            : out std_logic_vector (63 downto 0);
         xgmii_rxc            : out std_logic_vector (7 downto 0);
         xaui_tx_l0_p         : out std_logic;
         xaui_tx_l0_n         : out std_logic;
         xaui_tx_l1_p         : out std_logic;
         xaui_tx_l1_n         : out std_logic;
         xaui_tx_l2_p         : out std_logic;
         xaui_tx_l2_n         : out std_logic;
         xaui_tx_l3_p         : out std_logic;
         xaui_tx_l3_n         : out std_logic;
         xaui_rx_l0_p         : in  std_logic;
         xaui_rx_l0_n         : in  std_logic;
         xaui_rx_l1_p         : in  std_logic;
         xaui_rx_l1_n         : in  std_logic;
         xaui_rx_l2_p         : in  std_logic;
         xaui_rx_l2_n         : in  std_logic;
         xaui_rx_l3_p         : in  std_logic;
         xaui_rx_l3_n         : in  std_logic;
         signal_detect        : in  std_logic_vector (3 downto 0);
         debug                : out std_logic_vector (5 downto 0);
         gt0_drpaddr          : in  std_logic_vector (8 downto 0);
         gt0_drpen            : in  std_logic;
         gt0_drpdi            : in  std_logic_vector (15 downto 0);
         gt0_drpdo            : out std_logic_vector (15 downto 0);
         gt0_drprdy           : out std_logic;
         gt0_drpwe            : in  std_logic;
         gt1_drpaddr          : in  std_logic_vector (8 downto 0);
         gt1_drpen            : in  std_logic;
         gt1_drpdi            : in  std_logic_vector (15 downto 0);
         gt1_drpdo            : out std_logic_vector (15 downto 0);
         gt1_drprdy           : out std_logic;
         gt1_drpwe            : in  std_logic;
         gt2_drpaddr          : in  std_logic_vector (8 downto 0);
         gt2_drpen            : in  std_logic;
         gt2_drpdi            : in  std_logic_vector (15 downto 0);
         gt2_drpdo            : out std_logic_vector (15 downto 0);
         gt2_drprdy           : out std_logic;
         gt2_drpwe            : in  std_logic;
         gt3_drpaddr          : in  std_logic_vector (8 downto 0);
         gt3_drpen            : in  std_logic;
         gt3_drpdi            : in  std_logic_vector (15 downto 0);
         gt3_drpdo            : out std_logic_vector (15 downto 0);
         gt3_drprdy           : out std_logic;
         gt3_drpwe            : in  std_logic;
         gt_txpmareset        : in  std_logic_vector (3 downto 0);
         gt_txpcsreset        : in  std_logic_vector (3 downto 0);
         gt_txresetdone       : out std_logic_vector (3 downto 0);
         gt_rxpmareset        : in  std_logic_vector (3 downto 0);
         gt_rxpcsreset        : in  std_logic_vector (3 downto 0);
         gt_rxpmaresetdone    : out std_logic_vector (3 downto 0);
         gt_rxresetdone       : out std_logic_vector (3 downto 0);
         gt_rxbufstatus       : out std_logic_vector (11 downto 0);
         gt_txphaligndone     : out std_logic_vector (3 downto 0);
         gt_txphinitdone      : out std_logic_vector (3 downto 0);
         gt_txdlysresetdone   : out std_logic_vector (3 downto 0);
         gt_qplllock          : out std_logic;
         gt_eyescantrigger    : in  std_logic_vector (3 downto 0);
         gt_eyescanreset      : in  std_logic_vector (3 downto 0);
         gt_eyescandataerror  : out std_logic_vector (3 downto 0);
         gt_rxrate            : in  std_logic_vector (11 downto 0);
         gt_loopback          : in  std_logic_vector (11 downto 0);
         gt_rxpolarity        : in  std_logic_vector (3 downto 0);
         gt_txpolarity        : in  std_logic_vector (3 downto 0);
         gt_rxlpmen           : in  std_logic_vector (3 downto 0);
         gt_rxdfelpmreset     : in  std_logic_vector (3 downto 0);
         gt_txpostcursor      : in  std_logic_vector (19 downto 0);
         gt_txprecursor       : in  std_logic_vector (19 downto 0);
         gt_txdiffctrl        : in  std_logic_vector (15 downto 0);
         gt_txinhibit         : in  std_logic_vector (3 downto 0);
         gt_rxprbscntreset    : in  std_logic_vector (3 downto 0);
         gt_rxprbserr         : out std_logic_vector (3 downto 0);
         gt_rxprbssel         : in  std_logic_vector (15 downto 0);
         gt_txprbssel         : in  std_logic_vector (15 downto 0);
         gt_txprbsforceerr    : in  std_logic_vector (3 downto 0);
         gt_rxcdrhold         : in  std_logic_vector (3 downto 0);
         gt_dmonitorout       : out std_logic_vector (67 downto 0);
         gt_pcsrsvdin         : in  std_logic_vector (63 downto 0);
         gt_rxdisperr         : out std_logic_vector (7 downto 0);
         gt_rxnotintable      : out std_logic_vector (7 downto 0);
         gt_rxcommadet        : out std_logic_vector (3 downto 0);
         configuration_vector : in  std_logic_vector (6 downto 0);
         status_vector        : out std_logic_vector (7 downto 0));
   end component XauiGthUltraScale156p25MHz10GigECore;

begin

   phyClk    <= phyClock;
   phyRst    <= phyReset;
   phyStatus <= status;
   phyReady  <= status(7);

   --------------------
   -- 10 GigE XAUI Core
   --------------------
   U_IpCore : XauiGthUltraScale156p25MHz10GigECore
      port map (
         -- Clocks and Resets
         dclk                         => dclk,
         reset                        => extRst,
         clk156_out                   => phyClock,
         clk156_lock                  => phyLock,
         refclk                       => gtRefClk,
         -- PHY Interface
         xgmii_txd                    => xgmiiTxd,
         xgmii_txc                    => xgmiiTxc,
         xgmii_rxd                    => xgmiiRxd,
         xgmii_rxc                    => xgmiiRxc,
         -- MGT Ports
         xaui_tx_l0_p                 => gtTxP(0),
         xaui_tx_l0_n                 => gtTxN(0),
         xaui_tx_l1_p                 => gtTxP(1),
         xaui_tx_l1_n                 => gtTxN(1),
         xaui_tx_l2_p                 => gtTxP(2),
         xaui_tx_l2_n                 => gtTxN(2),
         xaui_tx_l3_p                 => gtTxP(3),
         xaui_tx_l3_n                 => gtTxN(3),
         xaui_rx_l0_p                 => gtRxP(0),
         xaui_rx_l0_n                 => gtRxN(0),
         xaui_rx_l1_p                 => gtRxP(1),
         xaui_rx_l1_n                 => gtRxN(1),
         xaui_rx_l2_p                 => gtRxP(2),
         xaui_rx_l2_n                 => gtRxN(2),
         xaui_rx_l3_p                 => gtRxP(3),
         xaui_rx_l3_n                 => gtRxN(3),
         -- DRP
         gt0_drpaddr                  => (others => '0'),
         gt0_drpen                    => '0',
         gt0_drpdi                    => X"0000",
         gt0_drpdo                    => open,
         gt0_drprdy                   => open,
         gt0_drpwe                    => '0',
         gt1_drpaddr                  => (others => '0'),
         gt1_drpen                    => '0',
         gt1_drpdi                    => X"0000",
         gt1_drpdo                    => open,
         gt1_drprdy                   => open,
         gt1_drpwe                    => '0',
         gt2_drpaddr                  => (others => '0'),
         gt2_drpen                    => '0',
         gt2_drpdi                    => X"0000",
         gt2_drpdo                    => open,
         gt2_drprdy                   => open,
         gt2_drpwe                    => '0',
         gt3_drpaddr                  => (others => '0'),
         gt3_drpen                    => '0',
         gt3_drpdi                    => X"0000",
         gt3_drpdo                    => open,
         gt3_drprdy                   => open,
         gt3_drpwe                    => '0',
         -- TX Reset and Initialization
         gt_reset_tx_datapath         => '0',
         gt_reset_tx_pll_and_datapath => '0',
         gt_txpmareset                => B"0000",
         gt_txpcsreset                => B"0000",
         gt_txresetdone               => open,
         -- RX Reset and Initialization
         gt_reset_rx_datapath         => '0',
         gt_reset_rx_pll_and_datapath => '0',
         gt_rxpmareset                => B"0000",
         gt_rxpcsreset                => B"0000",
         gt_rxpmaresetdone            => open,
         gt_rxresetdone               => open,
         -- Clocking
         gt_rxbufstatus               => open,
         gt_txphaligndone             => open,
         gt_txphinitdone              => open,
         gt_txdlysresetdone           => open,
         gt_qplllock                  => open,
         -- Signal Integrity and Functionality
         -- Eye Scan
         gt_eyescantrigger            => B"0000",
         gt_eyescanreset              => B"0000",
         gt_eyescandataerror          => open,
         gt_rxrate                    => X"000",
         -- Loopback
         gt_loopback                  => X"000",
         -- Polarity
         gt_rxpolarity                => x"0",
         gt_txpolarity                => x"0",
         -- RX Decision Feedback Equalizer (DFE)
         gt_rxlpmen                   => B"1111",
         gt_rxdfelpmreset             => B"0000",
         -- TX Driver
         gt_txpostcursor              => (others => '0'),
         gt_txprecursor               => (others => '0'),
         gt_txdiffctrl                => (others => '1'),
         gt_txinhibit                 => "0000",
         -- PRBS
         gt_rxprbscntreset            => B"0000",
         gt_rxprbserr                 => open,
         gt_rxprbssel                 => X"0000",
         gt_txprbssel                 => X"0000",
         gt_txprbsforceerr            => B"0000",
         gt_rxcdrhold                 => B"0000",
         gt_dmonitorout               => open,
         gt_pcsrsvdin                 => (others => '0'),
         -- Configuration and Status
         gt_rxdisperr                 => open,
         gt_rxnotintable              => open,
         gt_rxcommadet                => open,
         signal_detect                => (others => '1'),
         debug                        => phyDebug,
         configuration_vector         => phyConfig,
         status_vector                => status);

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
