-------------------------------------------------------------------------------
-- File       : HsioCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Common top level module for HSIO
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE DPM Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE DPM Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity HsioCore is
   generic (
      TPD_G              : time                     := 1 ns;
      BUILD_INFO_G       : BuildInfoType;
      SIMULATION_G       : boolean                  := false;
      SIM_MEM_PORT_NUM_G : natural range 0 to 65535 := 9000;
      SIM_DMA_PORT_NUM_G : natural range 0 to 65535 := 9002;
      SIM_DMA_CHANNELS_G : natural range 0 to 4     := 3;
      SIM_DMA_TDESTS_G   : natural range 0 to 256   := 256;
      RCE_DMA_MODE_G     : RceDmaModeType           := RCE_DMA_PPI_C);
   port (
      -- I2C
      i2cSda             : inout sl;
      i2cScl             : inout sl;
      -- Clock Select
      clkSelA            : out   sl;
      clkSelB            : out   sl;
      -- Base Ethernet
      ethRxCtrl          : in    slv(1 downto 0);
      ethRxClk           : in    slv(1 downto 0);
      ethRxDataA         : in    Slv(1 downto 0);
      ethRxDataB         : in    Slv(1 downto 0);
      ethRxDataC         : in    Slv(1 downto 0);
      ethRxDataD         : in    Slv(1 downto 0);
      ethTxCtrl          : out   slv(1 downto 0);
      ethTxClk           : out   slv(1 downto 0);
      ethTxDataA         : out   Slv(1 downto 0);
      ethTxDataB         : out   Slv(1 downto 0);
      ethTxDataC         : out   Slv(1 downto 0);
      ethTxDataD         : out   Slv(1 downto 0);
      ethMdc             : out   Slv(1 downto 0);
      ethMio             : inout Slv(1 downto 0);
      ethResetL          : out   Slv(1 downto 0);
      -- IPMI
      dtmToIpmiP         : out   slv(1 downto 0);
      dtmToIpmiM         : out   slv(1 downto 0);
      -- Clocks
      sysClk125          : out   sl;
      sysClk125Rst       : out   sl;
      sysClk200          : out   sl;
      sysClk200Rst       : out   sl;
      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF
      axiClk             : out   sl;
      axiClkRst          : out   sl;
      extAxilReadMaster  : out   AxiLiteReadMasterType;
      extAxilReadSlave   : in    AxiLiteReadSlaveType;
      extAxilWriteMaster : out   AxiLiteWriteMasterType;
      extAxilWriteSlave  : in    AxiLiteWriteSlaveType;
      -- DMA Interfaces
      dmaClk             : in    slv(3 downto 0);
      dmaClkRst          : in    slv(3 downto 0);
      dmaState           : out   RceDmaStateArray(3 downto 0);
      dmaObMaster        : out   AxiStreamMasterArray(3 downto 0);
      dmaObSlave         : in    AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster        : in    AxiStreamMasterArray(3 downto 0);
      dmaIbSlave         : out   AxiStreamSlaveArray(3 downto 0);
      -- User Interrupts
      userInterrupt      : in    slv(USER_INT_COUNT_C-1 downto 0) := (others => '0'));
end HsioCore;

architecture mapping of HsioCore is

   signal iAxilClk : sl;
   signal iAxilRst : sl;

   signal axiDmaClock : sl;
   signal axiDmaReset : sl;

   signal idmaClk      : slv(3 downto 0);
   signal idmaRst      : slv(3 downto 0);
   signal idmaState    : RceDmaStateArray(3 downto 0);
   signal idmaObMaster : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave  : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave  : AxiStreamSlaveArray(3 downto 0);

   signal armEthTx   : ArmEthTxArray(1 downto 0);
   signal armEthRx   : ArmEthRxArray(1 downto 0);
   signal armEthMode : slv(31 downto 0);

begin

   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   axiClk       <= iAxilClk;
   axiClkRst    <= iAxilRst;
   sysClk125    <= iAxilClk;
   sysClk125Rst <= iAxilRst;
   sysClk200    <= axiDmaClock;
   sysClk200Rst <= axiDmaReset;

   -- DMA Interfaces
   idmaClk(3 downto 0)      <= dmaClk(3 downto 0);
   idmaRst(3 downto 0)      <= dmaClkRst(3 downto 0);
   dmaState(3 downto 0)     <= idmaState(3 downto 0);
   dmaObMaster(3 downto 0)  <= idmaObMaster(3 downto 0);
   idmaObSlave(3 downto 0)  <= dmaObSlave(3 downto 0);
   idmaIbMaster(3 downto 0) <= dmaIbMaster(3 downto 0);
   dmaIbSlave(3 downto 0)   <= idmaIbSlave(3 downto 0);

   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top : entity rce_gen3_fw_lib.RceG3Top
      generic map (
         TPD_G              => TPD_G,
         BUILD_INFO_G       => BUILD_INFO_G,
         SIMULATION_G       => SIMULATION_G,
         SIM_MEM_PORT_NUM_G => SIM_MEM_PORT_NUM_G,
         SIM_DMA_PORT_NUM_G => SIM_DMA_PORT_NUM_G,
         SIM_DMA_CHANNELS_G => SIM_DMA_CHANNELS_G,
         SIM_DMA_TDESTS_G   => SIM_DMA_TDESTS_G,
         RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
         SEL_REFCLK_G       => false)   -- false = ZYNQ ref
      port map (
         -- I2C Ports
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         -- Reference Clock
         ethRefClkP         => '0',     -- Using ZYNQ ref
         ethRefClkN         => '1',
         -- DMA clock and reset
         axiDmaClk          => axiDmaClock,
         axiDmaRst          => axiDmaReset,
         -- AXI-Lite clock and reset
         axilClk            => iAxilClk,
         axilRst            => iAxilRst,
         -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF  (axilClk domain)
         extAxilReadMaster  => extAxilReadMaster,
         extAxilReadSlave   => extAxilReadSlave,
         extAxilWriteMaster => extAxilWriteMaster,
         extAxilWriteSlave  => extAxilWriteSlave,
         -- Core Axi Bus, 0xB0000000 - 0xBFFFFFFF  (axilClk domain)
         coreAxilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
         coreAxilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C,
         -- DMA Interfaces (dmaClk domain)
         dmaClk             => idmaClk,
         dmaClkRst          => idmaRst,
         dmaState           => idmaState,
         dmaObMaster        => idmaObMaster,
         dmaObSlave         => idmaObSlave,
         dmaIbMaster        => idmaIbMaster,
         dmaIbSlave         => idmaIbSlave,
         -- User Interrupts (axilClk domain)
         userInterrupt      => userInterrupt,
         -- ZYNQ GEM Interface
         armEthTx           => armEthTx,
         armEthRx           => armEthRx,
         armEthMode         => armEthMode);

   -- Hard code to 250Mhz
   clkSelA <= '1';
   clkSelB <= '1';

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_GmiiToRgmii : entity rce_gen3_fw_lib.GmiiToRgmiiDual
      port map (
         sysClk200    => axiDmaClock,
         sysClk200Rst => axiDmaReset,
         armEthTx     => armEthTx,
         armEthRx     => armEthRx,
         ethRxCtrl    => ethRxCtrl,
         ethRxClk     => ethRxClk,
         ethRxDataA   => ethRxDataA,
         ethRxDataB   => ethRxDataB,
         ethRxDataC   => ethRxDataC,
         ethRxDataD   => ethRxDataD,
         ethTxCtrl    => ethTxCtrl,
         ethTxClk     => ethTxClk,
         ethTxDataA   => ethTxDataA,
         ethTxDataB   => ethTxDataB,
         ethTxDataC   => ethTxDataC,
         ethTxDataD   => ethTxDataD,
         ethMdc       => ethMdc,
         ethMio       => ethMio,
         ethResetL    => ethResetL);

   armEthMode <= x"00000001";           -- 1 Gig on lane 0

   --------------------------------------------------
   -- Unused
   --------------------------------------------------
   dtmToIpmiP(0) <= 'Z';
   dtmToIpmiP(1) <= 'Z';
   dtmToIpmiM(0) <= 'Z';
   dtmToIpmiM(1) <= 'Z';

end mapping;
