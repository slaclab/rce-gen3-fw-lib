-------------------------------------------------------------------------------
-- File       : Rce10GbE1lane.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-06-27
-- Last update: 2018-06-27
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

   component TenGigEthGthUltraScale156p25MHzCore
      port (
         gt_rxp_in_0                         : in  std_logic;
         gt_rxn_in_0                         : in  std_logic;
         gt_txp_out_0                        : out std_logic;
         gt_txn_out_0                        : out std_logic;
         rx_core_clk_0                       : in  std_logic;
         rx_serdes_reset_0                   : in  std_logic;
         txoutclksel_in_0                    : in  std_logic_vector(2 downto 0);
         rxoutclksel_in_0                    : in  std_logic_vector(2 downto 0);
         gt_dmonitorout_0                    : out std_logic_vector(16 downto 0);
         gt_eyescandataerror_0               : out std_logic;
         gt_eyescanreset_0                   : in  std_logic;
         gt_eyescantrigger_0                 : in  std_logic;
         gt_pcsrsvdin_0                      : in  std_logic_vector(15 downto 0);
         gt_rxbufreset_0                     : in  std_logic;
         gt_rxbufstatus_0                    : out std_logic_vector(2 downto 0);
         gt_rxcdrhold_0                      : in  std_logic;
         gt_rxcommadeten_0                   : in  std_logic;
         gt_rxdfeagchold_0                   : in  std_logic;
         gt_rxdfelpmreset_0                  : in  std_logic;
         gt_rxlatclk_0                       : in  std_logic;
         gt_rxlpmen_0                        : in  std_logic;
         gt_rxpcsreset_0                     : in  std_logic;
         gt_rxpmareset_0                     : in  std_logic;
         gt_rxpolarity_0                     : in  std_logic;
         gt_rxprbscntreset_0                 : in  std_logic;
         gt_rxprbserr_0                      : out std_logic;
         gt_rxprbssel_0                      : in  std_logic_vector(3 downto 0);
         gt_rxrate_0                         : in  std_logic_vector(2 downto 0);
         gt_rxslide_in_0                     : in  std_logic;
         gt_rxstartofseq_0                   : out std_logic_vector(1 downto 0);
         gt_txbufstatus_0                    : out std_logic_vector(1 downto 0);
         gt_txdiffctrl_0                     : in  std_logic_vector(4 downto 0);
         gt_txinhibit_0                      : in  std_logic;
         gt_txlatclk_0                       : in  std_logic;
         gt_txmaincursor_0                   : in  std_logic_vector(6 downto 0);
         gt_txpcsreset_0                     : in  std_logic;
         gt_txpmareset_0                     : in  std_logic;
         gt_txpolarity_0                     : in  std_logic;
         gt_txpostcursor_0                   : in  std_logic_vector(4 downto 0);
         gt_txprbsforceerr_0                 : in  std_logic;
         gt_txprbssel_0                      : in  std_logic_vector(3 downto 0);
         gt_txprecursor_0                    : in  std_logic_vector(4 downto 0);
         rxrecclkout_0                       : out std_logic;
         gt_drpclk_0                         : in  std_logic;
         gt_drpdo_0                          : out std_logic_vector(15 downto 0);
         gt_drprdy_0                         : out std_logic;
         gt_drpen_0                          : in  std_logic;
         gt_drpwe_0                          : in  std_logic;
         gt_drpaddr_0                        : in  std_logic_vector(9 downto 0);
         gt_drpdi_0                          : in  std_logic_vector(15 downto 0);
         sys_reset                           : in  std_logic;
         dclk                                : in  std_logic;
         tx_mii_clk_0                        : out std_logic;
         rx_clk_out_0                        : out std_logic;
         gtpowergood_out_0                   : out std_logic;
         qpll0clk_in                         : in  std_logic_vector(0 downto 0);
         qpll0refclk_in                      : in  std_logic_vector(0 downto 0);
         qpll1clk_in                         : in  std_logic_vector(0 downto 0);
         qpll1refclk_in                      : in  std_logic_vector(0 downto 0);
         gtwiz_reset_qpll0lock_in            : in  std_logic;
         gtwiz_reset_qpll0reset_out          : out std_logic;
         gtwiz_reset_qpll1lock_in            : in  std_logic;
         gtwiz_reset_qpll1reset_out          : out std_logic;
         gt_reset_tx_done_out_0              : out std_logic;
         gt_reset_rx_done_out_0              : out std_logic;
         gt_reset_all_in_0                   : in  std_logic;
         gt_tx_reset_in_0                    : in  std_logic;
         gt_rx_reset_in_0                    : in  std_logic;
         rx_reset_0                          : in  std_logic;
         rx_mii_d_0                          : out std_logic_vector(63 downto 0);
         rx_mii_c_0                          : out std_logic_vector(7 downto 0);
         ctl_rx_test_pattern_0               : in  std_logic;
         ctl_rx_data_pattern_select_0        : in  std_logic;
         ctl_rx_test_pattern_enable_0        : in  std_logic;
         ctl_rx_prbs31_test_pattern_enable_0 : in  std_logic;
         stat_rx_framing_err_0               : out std_logic;
         stat_rx_framing_err_valid_0         : out std_logic;
         stat_rx_local_fault_0               : out std_logic;
         stat_rx_block_lock_0                : out std_logic;
         stat_rx_valid_ctrl_code_0           : out std_logic;
         stat_rx_status_0                    : out std_logic;
         stat_rx_hi_ber_0                    : out std_logic;
         stat_rx_bad_code_0                  : out std_logic;
         stat_rx_bad_code_valid_0            : out std_logic;
         stat_rx_error_0                     : out std_logic_vector(7 downto 0);
         stat_rx_error_valid_0               : out std_logic;
         stat_rx_fifo_error_0                : out std_logic;
         tx_reset_0                          : in  std_logic;
         tx_mii_d_0                          : in  std_logic_vector(63 downto 0);
         tx_mii_c_0                          : in  std_logic_vector(7 downto 0);
         stat_tx_local_fault_0               : out std_logic;
         ctl_tx_test_pattern_0               : in  std_logic;
         ctl_tx_test_pattern_enable_0        : in  std_logic;
         ctl_tx_test_pattern_select_0        : in  std_logic;
         ctl_tx_data_pattern_select_0        : in  std_logic;
         ctl_tx_test_pattern_seed_a_0        : in  std_logic_vector(57 downto 0);
         ctl_tx_test_pattern_seed_b_0        : in  std_logic_vector(57 downto 0);
         ctl_tx_prbs31_test_pattern_enable_0 : in  std_logic;
         gt_loopback_in_0                    : in  std_logic_vector(2 downto 0)
         );
   end component;


   signal qplllock      : slv(1 downto 0);
   signal qplloutclk    : slv(1 downto 0);
   signal qplloutrefclk : slv(1 downto 0);

   signal qpllRst   : slv(1 downto 0);
   signal qpllReset : slv(1 downto 0);

   signal phyClock  : sl;
   signal phyReset  : sl;
   signal txRstdone : sl;
   signal rxRstdone : sl;
   signal txGtClk   : sl;

   signal status : slv(7 downto 0);

begin

   phyClk <= phyClock;
   phyRst <= phyReset;

   phyStatus <= status;
   phyReady  <= status(0);
   phyDebug  <= (others => '0');

   ----------------------
   -- Common Clock Module 
   ----------------------
   U_QPLL : entity work.GthUltraScaleQuadPll
      generic map (
         -- Simulation Parameters
         TPD_G              => TPD_G,
         -- QPLL Configuration Parameters
         QPLL_CFG0_G        => (others => x"391C"),
         QPLL_CFG1_G        => (others => x"0000"),
         QPLL_CFG1_G3_G     => (others => x"0020"),
         QPLL_CFG2_G        => (others => x"0F80"),
         QPLL_CFG2_G3_G     => (others => x"0F80"),
         QPLL_CFG3_G        => (others => x"0120"),
         QPLL_CFG4_G        => (others => x"0002"),
         QPLL_CP_G          => (others => "0000011111"),
         QPLL_CP_G3_G       => (others => "0000011111"),
         QPLL_FBDIV_G       => (others => 66),
         QPLL_FBDIV_G3_G    => (others => 80),
         QPLL_INIT_CFG0_G   => (others => x"0000"),
         QPLL_INIT_CFG1_G   => (others => x"00"),
         QPLL_LOCK_CFG_G    => (others => x"01E8"),
         QPLL_LOCK_CFG_G3_G => (others => x"21E8"),
         QPLL_LPF_G         => (others => "1011111111"),
         QPLL_LPF_G3_G      => (others => "1111111111"),
         QPLL_REFCLK_DIV_G  => (others => 1),
         QPLL_SDM_CFG0_G    => (others => x"0040"),
         QPLL_SDM_CFG1_G    => (others => x"0000"),
         QPLL_SDM_CFG2_G    => (others => x"0000"),
         -- Clock Selects
         QPLL_REFCLK_SEL_G  => (others => "001"))
      port map (
         qPllRefClk(0)  => gtRefClk,
         qPllRefClk(1)  => gtRefClk,
         qPllOutClk     => qPllOutClk,
         qPllOutRefClk  => qPllOutRefClk,
         qPllLock       => qPllLock,
         qPllLockDetClk => "00",        -- IP Core ties this to GND
         qPllReset      => qpllReset);

   qpllReset(0) <= coreRst or (qpllRst(0) and not(qPllLock(0)));
   qpllReset(1) <= coreRst or (qpllRst(1) and not(qPllLock(1)));

   -----------------
   -- 10GBASE-R core
   -----------------
   U_IpCore : TenGigEthGthUltraScale156p25MHzCore
      port map (
         -- Clocks      
         dclk                                => coreClk,
         gt_drpclk_0                         => coreClk,
         rx_core_clk_0                       => phyClock,
         tx_mii_clk_0                        => txGtClk,
         rx_clk_out_0                        => open,
         rxrecclkout_0                       => open,
         -- Resets     
         gt_reset_all_in_0                   => coreRst,
         gt_tx_reset_in_0                    => coreRst,
         gt_rx_reset_in_0                    => coreRst,
         tx_reset_0                          => coreRst,
         rx_reset_0                          => coreRst,
         rx_serdes_reset_0                   => coreRst,
         sys_reset                           => coreRst,
         -- Quad PLL Interface      
         qpll0clk_in(0)                      => qplloutclk(0),
         qpll0refclk_in(0)                   => qplloutrefclk(0),
         qpll1clk_in(0)                      => qplloutclk(1),
         qpll1refclk_in(0)                   => qplloutrefclk(1),
         gtwiz_reset_qpll0lock_in            => qplllock(0),
         gtwiz_reset_qpll0reset_out          => qpllRst(0),
         gtwiz_reset_qpll1lock_in            => qplllock(1),
         gtwiz_reset_qpll1reset_out          => qpllRst(1),
         -- MGT Ports      
         gt_txp_out_0                        => gtTxP,
         gt_txn_out_0                        => gtTxN,
         gt_rxp_in_0                         => gtRxP,
         gt_rxn_in_0                         => gtRxN,
         -- PHY Interface      
         tx_mii_d_0                          => xgmiiTxd,
         tx_mii_c_0                          => xgmiiTxc,
         rx_mii_d_0                          => xgmiiRxd,
         rx_mii_c_0                          => xgmiiRxc,
         -- Configuration and Status      
         txoutclksel_in_0                    => "101",
         rxoutclksel_in_0                    => "101",
         gt_loopback_in_0                    => (others => '0'),
         ctl_rx_test_pattern_0               => '0',
         ctl_rx_data_pattern_select_0        => '0',
         ctl_rx_test_pattern_enable_0        => '0',
         ctl_rx_prbs31_test_pattern_enable_0 => '0',
         ctl_tx_test_pattern_0               => '0',
         ctl_tx_test_pattern_enable_0        => '0',
         ctl_tx_test_pattern_select_0        => '0',
         ctl_tx_data_pattern_select_0        => '0',
         ctl_tx_test_pattern_seed_a_0        => (others => '0'),
         ctl_tx_test_pattern_seed_b_0        => (others => '0'),
         ctl_tx_prbs31_test_pattern_enable_0 => '0',
         gtpowergood_out_0                   => open,
         gt_reset_tx_done_out_0              => txRstdone,
         gt_reset_rx_done_out_0              => rxRstdone,
         stat_tx_local_fault_0               => open,
         stat_rx_framing_err_0               => open,
         stat_rx_framing_err_valid_0         => open,
         stat_rx_local_fault_0               => open,
         stat_rx_block_lock_0                => open,
         stat_rx_valid_ctrl_code_0           => open,
         stat_rx_status_0                    => open,
         stat_rx_hi_ber_0                    => open,
         stat_rx_bad_code_0                  => open,
         stat_rx_bad_code_valid_0            => open,
         stat_rx_error_0                     => open,
         stat_rx_error_valid_0               => open,
         stat_rx_fifo_error_0                => open,
         -- DRP interface
         gt_drpdo_0                          => open,
         gt_drprdy_0                         => open,
         gt_drpen_0                          => '0',
         gt_drpwe_0                          => '0',
         gt_drpaddr_0                        => (others => '0'),
         gt_drpdi_0                          => (others => '0'),
         -- Transceiver Debug Interface         
         gt_dmonitorout_0                    => open,
         gt_eyescandataerror_0               => open,
         gt_eyescanreset_0                   => '0',
         gt_eyescantrigger_0                 => '0',
         gt_pcsrsvdin_0                      => (others => '0'),
         gt_rxbufreset_0                     => '0',
         gt_rxbufstatus_0                    => open,
         gt_rxcdrhold_0                      => '0',
         gt_rxcommadeten_0                   => '0',
         gt_rxdfeagchold_0                   => '0',
         gt_rxdfelpmreset_0                  => '0',
         gt_rxlatclk_0                       => '0',
         gt_rxlpmen_0                        => '0',
         gt_rxpcsreset_0                     => '0',
         gt_rxpmareset_0                     => '0',
         gt_rxpolarity_0                     => '0',
         gt_rxprbscntreset_0                 => '0',
         gt_rxprbserr_0                      => open,
         gt_rxprbssel_0                      => (others => '0'),
         gt_rxrate_0                         => (others => '0'),
         gt_rxslide_in_0                     => '0',
         gt_rxstartofseq_0                   => open,
         gt_txbufstatus_0                    => open,
         gt_txdiffctrl_0                     => "11100",
         gt_txinhibit_0                      => '0',
         gt_txlatclk_0                       => '0',
         gt_txmaincursor_0                   => (others => '0'),
         gt_txpcsreset_0                     => '0',
         gt_txpmareset_0                     => '0',
         gt_txpolarity_0                     => '0',
         gt_txpostcursor_0                   => "00000",
         gt_txprbsforceerr_0                 => '0',
         gt_txprbssel_0                      => (others => '0'),
         gt_txprecursor_0                    => "00000");

   ---------------------------
   -- 10GBASE-R's Reset Module
   ---------------------------
   U_TenGigEthRst : entity work.TenGigEthGthUltraScaleRst
      generic map (
         TPD_G => TPD_G)
      port map (
         coreClk   => coreClk,
         coreRst   => coreRst,
         txGtClk   => txGtClk,
         txRstdone => txRstdone,
         rxRstdone => rxRstdone,
         phyClk    => phyClock,
         phyRst    => phyReset,
         phyReady  => phyReady);

end mapping;
