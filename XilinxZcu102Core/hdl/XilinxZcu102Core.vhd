-------------------------------------------------------------------------------
-- File       : XilinxZcu102Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Common top level module for Xilinx ZCU102
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

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxZcu102Core is
   generic (
      TPD_G              : time                     := 1 ns;
      BUILD_INFO_G       : BuildInfoType;
      SIMULATION_G       : boolean                  := false;
      SIM_MEM_PORT_NUM_G : natural range 0 to 65535 := 9000;
      SIM_DMA_PORT_NUM_G : natural range 0 to 65535 := 9002;
      SIM_DMA_CHANNELS_G : natural range 0 to 4     := 3;
      SIM_DMA_TDESTS_G   : natural range 0 to 256   := 256);
   port (
      -- Clocks and Resets
      sysClk125          : out sl;
      sysClk125Rst       : out sl;
      sysClk200          : out sl;
      sysClk200Rst       : out sl;
      -- External AXI-Lite Interface [0xB4000000:0xB7FFFFFF]
      axiClk             : out sl;
      axiClkRst          : out sl;
      extAxilReadMaster  : out AxiLiteReadMasterType;
      extAxilReadSlave   : in  AxiLiteReadSlaveType;
      extAxilWriteMaster : out AxiLiteWriteMasterType;
      extAxilWriteSlave  : in  AxiLiteWriteSlaveType;
      -- DMA Interfaces
      dmaClk             : in  slv(3 downto 0);
      dmaClkRst          : in  slv(3 downto 0);
      dmaObMaster        : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave         : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster        : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave         : out AxiStreamSlaveArray(3 downto 0);
      -- User memory access (sysclk200 domain)
      userWriteSlave     : out AxiWriteSlaveType;
      userWriteMaster    : in  AxiWriteMasterType               := AXI_WRITE_MASTER_INIT_C;
      userReadSlave      : out AxiReadSlaveType;
      userReadMaster     : in  AxiReadMasterType                := AXI_READ_MASTER_INIT_C;
      -- User Interrupts
      userInterrupt      : in  slv(USER_INT_COUNT_C-1 downto 0) := (others => '0'));
end XilinxZcu102Core;

architecture mapping of XilinxZcu102Core is

   signal coreAxilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal armEthTx : ArmEthTxArray(1 downto 0) := (others => ARM_ETH_TX_INIT_C);
   signal armEthRx : ArmEthRxArray(1 downto 0) := (others => ARM_ETH_RX_INIT_C);

   ---------------------------------------------------
   -- when "ZYNQ-GEM"    => armEthMode <= x"00000001";
   -- when "1000BASE-KX" => armEthMode <= x"00000002";
   -- when "10GBASE-KX4" => armEthMode <= x"03030303";
   -- when "10GBASE-KR"  => armEthMode <= x"0000000A";
   -- when "40GBASE-KR4" => armEthMode <= x"0A0A0A0A";
   -- when others        => armEthMode <= x"00000000";   
   ---------------------------------------------------
   signal armEthMode : slv(31 downto 0) := (others => '0');  -- Using GEM[3] on MIO[75:64]

   signal axilClock : sl;
   signal axilReset : sl;

   signal axiDmaClock : sl;
   signal axiDmaReset : sl;

begin

   axiClk       <= axilClock;
   axiClkRst    <= axilReset;
   sysClk125    <= axilClock;
   sysClk125Rst <= axilReset;
   sysClk200    <= axiDmaClock;
   sysClk200Rst <= axiDmaReset;

   -----------
   -- RCE Core
   -----------
   U_RceG3Top : entity work.RceG3Top
      generic map (
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         SIM_MEM_PORT_NUM_G => SIM_MEM_PORT_NUM_G,
         SIM_DMA_PORT_NUM_G => SIM_DMA_PORT_NUM_G,
         SIM_DMA_CHANNELS_G => SIM_DMA_CHANNELS_G,
         SIM_DMA_TDESTS_G   => SIM_DMA_TDESTS_G,
         MEMORY_TYPE_G      => "ultra",
         SEL_REFCLK_G       => false,   -- false = ZYNQ ref
         USE_DMA_ETH_G      => false,  -- false = using DMA[3] for application space (not ETH)
         BUILD_INFO_G       => BUILD_INFO_G,
         BYP_BSI_G          => true,    -- bypassing BSI I2C interface
         RCE_DMA_MODE_G     => RCE_DMA_AXISV2_C)  -- AXIS DMA Version2
      port map (
         -- I2C Ports
         i2cSda              => open,   -- No BSI interface on ZCU102 board
         i2cScl              => open,
         -- Reference Clock
         ethRefClkP          => '0',
         ethRefClkN          => '1',
         -- DMA clock and reset
         axiDmaClk           => axiDmaClock,
         axiDmaRst           => axiDmaReset,
         -- AXI-Lite clock and reset
         axilClk             => axilClock,
         axilRst             => axilReset,
         -- External Axi Bus, 0xB4000000 - 0xB7FFFFFF  (axilClk domain)
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave,
         -- Core Axi Bus, 0xB8000000 - 0xBFFFFFFF  (axilClk domain)
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         -- DMA Interfaces (dmaClk domain)
         dmaClk              => dmaClk,
         dmaClkRst           => dmaClkRst,
         dmaObMaster         => dmaObMaster,
         dmaObSlave          => dmaObSlave,
         dmaIbMaster         => dmaIbMaster,
         dmaIbSlave          => dmaIbSlave,
         -- User Interrupts (axilClk domain)
         userInterrupt       => userInterrupt,
         -- User memory access (axiDmaClk domain)
         userWriteSlave      => userWriteSlave,
         userWriteMaster     => userWriteMaster,
         userReadSlave       => userReadSlave,
         userReadMaster      => userReadMaster,
         -- ZYNQ GEM Interface
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode);

end mapping;
