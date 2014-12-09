-------------------------------------------------------------------------------
-- Title         : Zynq 1Gige Ethernet Core
-- File          : ZynqEthernet.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq ethernet core.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 by Ryan Herbst. All rights reserved.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;

entity ZynqEthernet is
   port (

      -- Clocks
      sysClk125               : in  sl;
      sysClk200               : in  sl;
      sysClk200Rst            : in  sl;

      -- ARM Interface
      armEthTx                : in  ArmEthTxType;
      armEthRx                : out ArmEthRxType;

      -- Ethernet Lines
      ethRxP                  : in  sl;
      ethRxM                  : in  sl;
      ethTxP                  : out sl;
      ethTxM                  : out sl
   );
end ZynqEthernet;

architecture structure of ZynqEthernet is

   -- Local signals
   signal txoutclk              : sl;                    -- txoutclk from GT transceiver
   signal txoutclk_bufg         : sl;                    -- txoutclk from GT transceiver routed onto global routing.
   signal resetdone             : sl;                    -- To indicate that the GT transceiver has completed its reset cycle
   signal mmcm_locked           : sl;                    -- MMCM locked signal.
   signal mmcm_reset            : sl;                    -- MMCM reset signal.
   signal clkfbout              : sl;                    -- MMCM feedback clock
   signal clkout0               : sl;                    -- MMCM clock0 output (62.5MHz).
   signal clkout1               : sl;                    -- MMCM clock1 output (125MHz).
   signal userclk               : sl;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
   signal userclk2              : sl;                    -- 125MHz clock for core reference clock.
   signal pma_reset_pipe        : slv(3 downto 0); -- flip-flop pipeline for reset duration stretch
   signal pma_reset             : sl;                    -- Synchronous transcevier PMA reset
   signal confValid             : sl;

begin

   -- Outputs
   armEthRx.enetGmiiRxClk <= userclk2;
   armEthRx.enetGmiiTxClk <= userclk2;

   -- Unused inputs
   --armEthTx.enetMdioT           : sl;
   --armEthTx.enetPtpDelayReqRx   : sl;
   --armEthTx.enetPtpDelayReqTx   : sl;
   --armEthTx.enetPtpPDelayReqRx  : sl;
   --armEthTx.enetPtpPDelayReqTx  : sl;
   --armEthTx.enetPtpPDelayRespRx : sl;
   --armEthTx.enetPtpPDelayRespTx : sl;
   --armEthTx.enetPtpSyncFrameRx  : sl;
   --armEthTx.enetPtpSyncFrameTx  : sl;
   --armEthTx.enetSofRx           : sl;
   --armEthTx.enetSofTx           : sl;

   -- Unused outputs
   armEthRx.enetGmiiCol  <= '0';
   armEthRx.enetGmiiCrs  <= '0';
   armEthRx.enetExtInitN <= '0';

   -----------------------------------------------------------------------------
   -- The following code is based on the zynq_gige_example_design.vhd
   -- file in the coregen/zynq_gige/example_design directory.
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Transceiver Clock Management
   -----------------------------------------------------------------------------

   -- Route txoutclk input through a BUFG
   bufg_txoutclk : BUFG
      port map (
         I         => txoutclk,
         O         => txoutclk_bufg
      );

   -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
   -- routed to an MMCM module where it is used to create phase and frequency
   -- related 62.5MHz and 125MHz clock sources
   mmcm_adv_inst : MMCME2_ADV
      generic map (
         BANDWIDTH            => "OPTIMIZED",
         CLKOUT4_CASCADE      => FALSE,
         COMPENSATION         => "ZHOLD",
         STARTUP_WAIT         => FALSE,
         DIVCLK_DIVIDE        => 1,
         CLKFBOUT_MULT_F      => 16.000,
         CLKFBOUT_PHASE       => 0.000,
         CLKFBOUT_USE_FINE_PS => FALSE,
         CLKOUT0_DIVIDE_F     => 8.000,
         CLKOUT0_PHASE        => 0.000,
         CLKOUT0_DUTY_CYCLE   => 0.5,
         CLKOUT0_USE_FINE_PS  => FALSE,
         CLKOUT1_DIVIDE       => 16,
         CLKOUT1_PHASE        => 0.000,
         CLKOUT1_DUTY_CYCLE   => 0.5,
         CLKOUT1_USE_FINE_PS  => FALSE,
         CLKIN1_PERIOD        => 16.0,
         REF_JITTER1          => 0.010
      )
      port map (
         CLKFBOUT             => clkfbout,
         CLKFBOUTB            => open,
         CLKOUT0              => clkout0,
         CLKOUT0B             => open,
         CLKOUT1              => clkout1,
         CLKOUT1B             => open,
         CLKOUT2              => open,
         CLKOUT2B             => open,
         CLKOUT3              => open,
         CLKOUT3B             => open,
         CLKOUT4              => open,
         CLKOUT5              => open,
         CLKOUT6              => open,
         -- Input clock control
         CLKFBIN              => clkfbout,
         CLKIN1               => txoutclk_bufg,
         CLKIN2               => '0',
         -- Tied to always select the primary input clock
         CLKINSEL             => '1',
         -- Ports for dynamic reconfiguration
         DADDR                => (others => '0'),
         DCLK                 => '0',
         DEN                  => '0',
         DI                   => (others => '0'),
         DO                   => open,
         DRDY                 => open,
         DWE                  => '0',
         -- Ports for dynamic phase shift
         PSCLK                => '0',
         PSEN                 => '0',
         PSINCDEC             => '0',
         PSDONE               => open,
         -- Other control and status signals
         LOCKED               => mmcm_locked,
         CLKINSTOPPED         => open,
         CLKFBSTOPPED         => open,
         PWRDWN               => '0',
         RST                  => mmcm_reset
      );

   --mmcm_reset <= sysClk200Rst or (not resetdone);
   mmcm_reset <= sysClk200Rst;

   -- This 62.5MHz clock is placed onto global clock routing and is then used
   -- for tranceiver TXUSRCLK/RXUSRCLK.
   bufg_userclk: BUFG
   port map (
      I     => clkout1,
      O     => userclk
   );    

   -- This 125MHz clock is placed onto global clock routing and is then used
   -- to clock all Ethernet core logic.
   bufg_userclk2: BUFG
   port map (
      I     => clkout0,
      O     => userclk2
   );    

   -----------------------------------------------------------------------------
   -- Transceiver PMA reset circuitry
   -----------------------------------------------------------------------------

   -- Create a reset pulse of a decent length
   process(sysClk200Rst, sysClk200)
   begin
     if (sysClk200Rst = '1') then
       pma_reset_pipe <= "1111";
     elsif sysClk200'event and sysClk200 = '1' then
       pma_reset_pipe <= pma_reset_pipe(2 downto 0) & sysClk200Rst;
     end if;
   end process;

   pma_reset <= pma_reset_pipe(3);

   ------------------------------------------------------------------------------
   -- Instantiate the Core Block (core wrapper).
   ------------------------------------------------------------------------------
   core_wrapper : entity work.zynq_gige_block
      port map (
         gtrefclk               => sysClk125,
         txn                    => ethTxM,
         txp                    => ethTxP,
         rxn                    => ethRxM,         
         rxp                    => ethRxP,
         independent_clock_bufg => sysClk200,
         txoutclk               => txoutclk,
         rxoutclk               => open,
         resetdone              => resetdone,
         cplllock               => open,
         userclk                => userclk,
         userclk2               => userclk2,
         pma_reset              => pma_reset,
         mmcm_locked            => mmcm_locked,
         rxuserclk              => userclk,
         rxuserclk2             => userclk,
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
         configuration_vector   => "00000",
         configuration_valid    => confValid,
         status_vector          => open,
         reset                  => sysClk200Rst,
         signal_detect          => '1',
         gt0_qplloutclk_in      => '0',-- QPLL not used
         gt0_qplloutrefclk_in   => '0');-- QPLL not used

   -- Force configuration set
   process(userclk2, sysClk200Rst)
   begin
     if (sysClk200Rst = '1') then
       confValid <= '0';
     elsif userclk2'event and userclk2 = '1' then
       confValid <= not confValid;
     end if;
   end process;

end architecture structure;

