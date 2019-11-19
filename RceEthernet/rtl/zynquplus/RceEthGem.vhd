-------------------------------------------------------------------------------
-- File       : RceEthGem.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper file for Zynq GEM 
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

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

entity RceEthGem is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clocks and Resets
      sysClk125 : in  sl;
      sysRst125 : in  sl;
      sysClk62  : in  sl;
      sysRst62  : in  sl;
      locked    : in  sl;
      stableClk : in  sl;               -- free-running clock reference
      stableRst : in  sl;
      -- ARM Interface
      armEthTx  : in  ArmEthTxType;
      armEthRx  : out ArmEthRxType;
      -- Ethernet Lines
      gtTxP     : out sl;
      gtTxN     : out sl;
      gtRxP     : in  sl;
      gtRxN     : in  sl);
end RceEthGem;

architecture mapping of RceEthGem is

   component zynq_gige_block
      port (
         gtrefclk               : in  std_logic;
         txp                    : out std_logic;
         txn                    : out std_logic;
         rxp                    : in  std_logic;
         rxn                    : in  std_logic;
         txoutclk               : out std_logic;
         rxoutclk               : out std_logic;
         resetdone              : out std_logic;
         cplllock               : out std_logic;
         mmcm_reset             : out std_logic;
         mmcm_locked            : in  std_logic;
         userclk                : in  std_logic;
         userclk2               : in  std_logic;
         rxuserclk              : in  std_logic;
         rxuserclk2             : in  std_logic;
         independent_clock_bufg : in  std_logic;
         pma_reset              : in  std_logic;
         gmii_txclk             : out std_logic;
         gmii_rxclk             : out std_logic;
         gmii_txd               : in  std_logic_vector (7 downto 0);
         gmii_tx_en             : in  std_logic;
         gmii_tx_er             : in  std_logic;
         gmii_rxd               : out std_logic_vector (7 downto 0);
         gmii_rx_dv             : out std_logic;
         gmii_rx_er             : out std_logic;
         gmii_isolate           : out std_logic;
         mdc                    : in  std_logic;
         mdio_i                 : in  std_logic;
         mdio_o                 : out std_logic;
         mdio_t                 : out std_logic;
         phyaddr                : in  std_logic_vector (4 downto 0);
         configuration_vector   : in  std_logic_vector (4 downto 0);
         configuration_valid    : in  std_logic;
         status_vector          : out std_logic_vector (15 downto 0);
         reset                  : in  std_logic;
         gtpowergood            : out std_logic;
         signal_detect          : in  std_logic);
   end component;

   type RegType is record
      load : sl;
   end record;

   constant REG_INIT_C : RegType := (
      load => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal coreRst : sl;

begin

   -- Outputs
   armEthRx.enetGmiiRxClk <= sysClk125;
   armEthRx.enetGmiiTxClk <= sysClk125;

   -- Unused outputs
   armEthRx.enetGmiiCol  <= '0';
   armEthRx.enetGmiiCrs  <= '1';
   armEthRx.enetExtInitN <= '0';

   -----------------
   -- Power Up Reset
   -----------------
   U_PwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => 1000)
      port map (
         clk    => sysClk125,
         arst   => sysRst125,
         rstOut => coreRst);

   --------------------------------------------
   -- Instantiate the Core Block (core wrapper)
   --------------------------------------------
   U_IpCore : zynq_gige_block
      port map (
         gtrefclk               => sysClk125,
         txn                    => gtTxN,
         txp                    => gtTxP,
         rxn                    => gtRxN,
         rxp                    => gtRxP,
         independent_clock_bufg => sysClk62,
         txoutclk               => open,
         rxoutclk               => open,
         resetdone              => open,
         cplllock               => open,
         userclk                => sysClk62,
         userclk2               => sysClk125,
         pma_reset              => coreRst,
         mmcm_locked            => locked,
         rxuserclk              => sysClk62,
         rxuserclk2             => sysClk62,
         gmii_txclk             => open,
         gmii_rxclk             => open,
         gmii_txd               => armEthTx.enetGmiiTxD,
         gmii_tx_en             => armEthTx.enetGmiiTxEn,
         gmii_tx_er             => armEthTx.enetGmiiTxEr,
         gmii_rxd               => armEthRx.enetGmiiRxd,
         gmii_rx_dv             => armEthRx.enetGmiiRxDv,
         gmii_rx_er             => armEthRx.enetGmiiRxEr,
         gmii_isolate           => open,
         mdc                    => armEthTx.enetMdioMdc,
         mdio_i                 => armEthTx.enetMdioO,
         mdio_o                 => armEthRx.enetMdioI,
         mdio_t                 => open,
         phyaddr                => "00000",
         configuration_vector   => "00000",
         configuration_valid    => r.load,
         status_vector          => open,
         reset                  => coreRst,
         signal_detect          => '1');

   comb : process (r, sysRst125) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Toggle
      v.load := not(r.load);

      -- Reset
      if (sysRst125 = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (sysClk125) is
   begin
      if rising_edge(sysClk125) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
