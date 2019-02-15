-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Top Level
-- File          : RceG3Top.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Top level file for ARM based rce generation 3 processor core.
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.RceG3Pkg.all;

entity RceG3Top is
   generic (
      TPD_G          : time                   := 1 ns;
      BUILD_INFO_G   : BuildInfoType;
      SYNTH_MODE_G   : string                 := "xpm";
      MEMORY_TYPE_G  : string                 := "block";      
      RCE_DMA_MODE_G : RceDmaModeType         := RCE_DMA_PPI_C;
      PCIE_EN_G      : boolean                := false;
      SEL_REFCLK_G   : boolean                := true;  -- false = ZYNQ ref, true = ETH ref
      SIM_USER_ID_G  : natural range 0 to 100 := 1;
      BYP_BSI_G      : boolean                := false; -- true for non-COB applications (like DEV boards)
      SIMULATION_G   : boolean                := false);
   port (
      -- I2C Ports
      i2cSda              : inout sl;
      i2cScl              : inout sl;
      -- Reference Clock
      ethRefClkP          : in    sl;
      ethRefClkN          : in    sl;
      ethRefClk           : out   sl;
      stableClk           : out   sl;
      stableRst           : out   sl;
      -- Top-level clocks and resets
      clk312              : out   sl;
      rst312              : out   sl;
      clk200              : out   sl;
      rst200              : out   sl;
      clk156              : out   sl;
      rst156              : out   sl;
      clk125              : out   sl;
      rst125              : out   sl;
      clk62               : out   sl;
      rst62               : out   sl;
      locked              : out   sl;
      -- DMA clock and reset
      axiDmaClk           : out   sl;
      axiDmaRst           : out   sl;
      -- AXI-Lite clock and reset
      axilClk             : out   sl;
      axilRst             : out   sl;
      -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF  (axilClk domain)
      extAxilReadMaster   : out   AxiLiteReadMasterType;
      extAxilReadSlave    : in    AxiLiteReadSlaveType;
      extAxilWriteMaster  : out   AxiLiteWriteMasterType;
      extAxilWriteSlave   : in    AxiLiteWriteSlaveType;
      -- Core Axi Bus, 0xB0000000 - 0xBFFFFFFF  (axilClk domain)
      coreAxilReadMaster  : out   AxiLiteReadMasterType;
      coreAxilReadSlave   : in    AxiLiteReadSlaveType;
      coreAxilWriteMaster : out   AxiLiteWriteMasterType;
      coreAxilWriteSlave  : in    AxiLiteWriteSlaveType;
      -- PCIE Ports
      pciRefClkP          : in    sl                 := '0';
      pciRefClkN          : in    sl                 := '0';
      pciResetL           : out   sl;
      pcieRxP             : in    sl                 := '0';
      pcieRxN             : in    sl                 := '0';
      pcieTxP             : out   sl;
      pcieTxN             : out   sl;
      -- DMA Interfaces (dmaClk domain)
      dmaClk              : in    slv(3 downto 0);
      dmaClkRst           : in    slv(3 downto 0);
      dmaState            : out   RceDmaStateArray(3 downto 0);
      dmaObMaster         : out   AxiStreamMasterArray(3 downto 0);
      dmaObSlave          : in    AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster         : in    AxiStreamMasterArray(3 downto 0);
      dmaIbSlave          : out   AxiStreamSlaveArray(3 downto 0);
      -- User Interrupts (axilClk domain)
      userInterrupt       : in    slv(USER_INT_COUNT_C-1 downto 0);
      -- User memory access (axiDmaClk domain)
      userWriteSlave      : out   AxiWriteSlaveType;
      userWriteMaster     : in    AxiWriteMasterType := AXI_WRITE_MASTER_INIT_C;
      userReadSlave       : out   AxiReadSlaveType;
      userReadMaster      : in    AxiReadMasterType  := AXI_READ_MASTER_INIT_C;
      -- ZYNQ GEM Interface
      armEthTx            : out   ArmEthTxArray(1 downto 0);
      armEthRx            : in    ArmEthRxArray(1 downto 0);
      armEthMode          : in    slv(31 downto 0);
      -- Programmable Clock Select
      clkSelA             : out   slv(1 downto 0);
      clkSelB             : out   slv(1 downto 0));
end RceG3Top;

architecture structure of RceG3Top is

   signal fclkClk0 : sl;
   signal fclkRst0 : sl;

   signal axiDmaClock : sl;
   signal axiDmaReset : sl;

   signal axilClock : sl;
   signal axilReset : sl;

   signal mGpWriteMaster : AxiWriteMasterArray(1 downto 0);
   signal mGpWriteSlave  : AxiWriteSlaveArray(1 downto 0);
   signal mGpReadMaster  : AxiReadMasterArray(1 downto 0);
   signal mGpReadSlave   : AxiReadSlaveArray(1 downto 0);

   signal acpWriteSlave  : AxiWriteSlaveType;
   signal acpWriteMaster : AxiWriteMasterType;
   signal acpReadSlave   : AxiReadSlaveType;
   signal acpReadMaster  : AxiReadMasterType;

   signal hpWriteSlave  : AxiWriteSlaveArray(3 downto 0);
   signal hpWriteMaster : AxiWriteMasterArray(3 downto 0);
   signal hpReadSlave   : AxiReadSlaveArray(3 downto 0);
   signal hpReadMaster  : AxiReadMasterArray(3 downto 0);

   signal bsiAxilReadMaster  : AxiLiteReadMasterType;
   signal bsiAxilReadSlave   : AxiLiteReadSlaveType;
   signal bsiAxilWriteMaster : AxiLiteWriteMasterType;
   signal bsiAxilWriteSlave  : AxiLiteWriteSlaveType;

   signal dmaAxilReadMaster  : AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal dmaAxilReadSlave   : AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal dmaAxilWriteMaster : AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
   signal dmaAxilWriteSlave  : AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

   signal icAxilReadMaster  : AxiLiteReadMasterType;
   signal icAxilReadSlave   : AxiLiteReadSlaveType;
   signal icAxilWriteMaster : AxiLiteWriteMasterType;
   signal icAxilWriteSlave  : AxiLiteWriteSlaveType;

   signal armInterrupt : slv(15 downto 0);
   signal dmaInterrupt : slv(DMA_INT_COUNT_C-1 downto 0);
   signal bsiInterrupt : sl;
   signal eFuseValue   : slv(31 downto 0);
   signal deviceDna    : slv(127 downto 0);

   signal auxReadMaster  : AxiReadMasterType;
   signal auxReadSlave   : AxiReadSlaveType;
   signal auxAxiClk      : sl;
   signal auxWriteMaster : AxiWriteMasterType;
   signal auxWriteSlave  : AxiWriteSlaveType;
   signal pcieInterrupt  : sl;

begin

   ------------------------------------------------------------------------   
   --                         Clock Generation                           --
   ------------------------------------------------------------------------   
   -- This VHDL wrapper is determined by the ZYNQ family type
   -- Zynq-7000:        rce-gen3-fw-lib/RceG3/hdl/zynq/RceG3Clocks.vhd
   -- Zynq Ultrascale+: rce-gen3-fw-lib/RceG3/hdl/zynquplus/RceG3Clocks.vhd
   ------------------------------------------------------------------------   
   U_RceG3Clocks : entity work.RceG3Clocks
      generic map (
         TPD_G        => TPD_G,
         SEL_REFCLK_G => SEL_REFCLK_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         -- ZYNQ Reference
         fclkClk0   => fclkClk0,
         fclkRst0   => fclkRst0,
         -- Reference Clock
         ethRefClkP => ethRefClkP,
         ethRefClkN => ethRefClkN,
         ethRefClk  => ethRefClk,
         stableClk  => stableClk,
         stableRst  => stableRst,
         -- Top-level clocks and resets
         clk312     => clk312,
         rst312     => rst312,
         clk200     => clk200,
         rst200     => rst200,
         clk156     => clk156,
         rst156     => rst156,
         clk125     => clk125,
         rst125     => rst125,
         clk62      => clk62,
         rst62      => rst62,
         locked     => locked,
         -- DMA clock and reset
         axiDmaClk  => axiDmaClock,
         axiDmaRst  => axiDmaReset,
         -- AXI-Lite clock and reset
         axilClk    => axilClock,
         axilRst    => axilReset);

   axiDmaClk <= axiDmaClock;
   axiDmaRst <= axiDmaReset;

   axilClk <= axilClock;
   axilRst <= axilReset;

   GEN_SYNTH : if (SIMULATION_G = false) generate
      ---------------------------------------------------------------------
      --                        Processor Core                           --
      ---------------------------------------------------------------------
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceG3/hdl/zynq/RceG3Cpu.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceG3/hdl/zynquplus/RceG3Cpu.vhd
      ---------------------------------------------------------------------
      U_RceG3Cpu : entity work.RceG3Cpu
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Clocks
            fclkClk0       => fclkClk0,
            fclkRst0       => fclkRst0,
            -- Interrupts
            armInterrupt   => armInterrupt,
            -- AXI GP Master
            mGpAxiClk(0)   => axiDmaClock,
            mGpAxiClk(1)   => axilClock,
            mGpWriteMaster => mGpWriteMaster,
            mGpWriteSlave  => mGpWriteSlave,
            mGpReadMaster  => mGpReadMaster,
            mGpReadSlave   => mGpReadSlave,
            -- AXI GP Slave
            sGpAxiClk(0)   => axiDmaClock,
            sGpAxiClk(1)   => axiDmaClock,
            sGpWriteSlave  => open,
            sGpWriteMaster => (others => AXI_WRITE_MASTER_INIT_C),
            sGpReadSlave   => open,
            sGpReadMaster  => (others => AXI_READ_MASTER_INIT_C),
            -- AXI ACP Slave
            acpAxiClk      => axiDmaClock,
            acpWriteSlave  => acpWriteSlave,
            acpWriteMaster => acpWriteMaster,
            acpReadSlave   => acpReadSlave,
            acpReadMaster  => acpReadMaster,
            -- AXI HP Slave
            hpAxiClk(0)    => axiDmaClock,
            hpAxiClk(1)    => axiDmaClock,
            hpAxiClk(2)    => auxAxiClk,
            hpAxiClk(3)    => axiDmaClock,
            hpWriteSlave   => hpWriteSlave,
            hpWriteMaster  => hpWriteMaster,
            hpReadSlave    => hpReadSlave,
            hpReadMaster   => hpReadMaster,
            -- Ethernet
            armEthTx       => armEthTx,
            armEthRx       => armEthRx);

      --------------------------------------------
      -- AXI Lite Bus
      --------------------------------------------
      U_RceG3AxiCntl : entity work.RceG3AxiCntl
         generic map (
            TPD_G          => TPD_G,
            BUILD_INFO_G   => BUILD_INFO_G,
            PCIE_EN_G      => PCIE_EN_G,
            RCE_DMA_MODE_G => RCE_DMA_MODE_G)
         port map (
            mGpReadMaster       => mGpReadMaster,
            mGpReadSlave        => mGpReadSlave,
            mGpWriteMaster      => mGpWriteMaster,
            mGpWriteSlave       => mGpWriteSlave,
            axiDmaClk           => axiDmaClock,
            axiDmaRst           => axiDmaReset,
            icAxilReadMaster    => icAxilReadMaster,
            icAxilReadSlave     => icAxilReadSlave,
            icAxilWriteMaster   => icAxilWriteMaster,
            icAxilWriteSlave    => icAxilWriteSlave,
            dmaAxilReadMaster   => dmaAxilReadMaster,
            dmaAxilReadSlave    => dmaAxilReadSlave,
            dmaAxilWriteMaster  => dmaAxilWriteMaster,
            dmaAxilWriteSlave   => dmaAxilWriteSlave,
            axiClk              => axilClock,
            axiClkRst           => axilReset,
            bsiAxilReadMaster   => bsiAxilReadMaster,
            bsiAxilReadSlave    => bsiAxilReadSlave,
            bsiAxilWriteMaster  => bsiAxilWriteMaster,
            bsiAxilWriteSlave   => bsiAxilWriteSlave,
            extAxilReadMaster   => extAxilReadMaster,
            extAxilReadSlave    => extAxilReadSlave,
            extAxilWriteMaster  => extAxilWriteMaster,
            extAxilWriteSlave   => extAxilWriteSlave,
            coreAxilReadMaster  => coreAxilReadMaster,
            coreAxilReadSlave   => coreAxilReadSlave,
            coreAxilWriteMaster => coreAxilWriteMaster,
            coreAxilWriteSlave  => coreAxilWriteSlave,
            userReadMaster      => userReadMaster,
            userReadSlave       => userReadSlave,
            userWriteMaster     => userWriteMaster,
            userWriteSlave      => userWriteSlave,
            auxReadMaster       => auxReadMaster,
            auxReadSlave        => auxReadSlave,
            auxWriteMaster      => auxWriteMaster,
            auxWriteSlave       => auxWriteSlave,
            auxAxiClk           => auxAxiClk,
            pciRefClkP          => pciRefClkP,
            pciRefClkN          => pciRefClkN,
            pciResetL           => pciResetL,
            pcieInt             => pcieInterrupt,
            pcieRxP             => pcieRxP,
            pcieRxN             => pcieRxN,
            pcieTxP             => pcieTxP,
            pcieTxN             => pcieTxN,
            clkSelA             => clkSelA,
            clkSelB             => clkSelB,
            armEthMode          => armEthMode,
            eFuseValue          => eFuseValue,
            deviceDna           => deviceDna);

      --------------------------------------------
      -- BSI Controller
      --------------------------------------------
      U_RceG3Bsi : entity work.RceG3Bsi
         generic map (
            TPD_G     => TPD_G,
            BYP_BSI_G => BYP_BSI_G)
         port map (
            axiClk          => axilClock,
            axiClkRst       => axilReset,
            axilReadMaster  => bsiAxilReadMaster,
            axilReadSlave   => bsiAxilReadSlave,
            axilWriteMaster => bsiAxilWriteMaster,
            axilWriteSlave  => bsiAxilWriteSlave,
            armEthMode      => armEthMode,
            eFuseValue      => eFuseValue,
            deviceDna       => deviceDna,
            i2cSda          => i2cSda,
            i2cScl          => i2cScl);

      --------------------------------------------
      -- Interrupt Controller
      --------------------------------------------
      U_RceG3IntCntl : entity work.RceG3IntCntl
         generic map (
            TPD_G          => TPD_G,
            RCE_DMA_MODE_G => RCE_DMA_MODE_G)
         port map (
            axiDmaClk         => axiDmaClock,
            axiDmaRst         => axiDmaReset,
            icAxilReadMaster  => icAxilReadMaster,
            icAxilReadSlave   => icAxilReadSlave,
            icAxilWriteMaster => icAxilWriteMaster,
            icAxilWriteSlave  => icAxilWriteSlave,
            dmaInterrupt      => dmaInterrupt,
            pcieInterrupt     => pcieInterrupt,
            userInterrupt     => userInterrupt,
            armInterrupt      => armInterrupt);

   end generate;

   --------------------------------------------
   -- DMA Controller
   --------------------------------------------
   U_RceG3Dma : entity work.RceG3Dma
      generic map (
         TPD_G          => TPD_G,
         SYNTH_MODE_G   => SYNTH_MODE_G,
         MEMORY_TYPE_G  => MEMORY_TYPE_G,          
         RCE_DMA_MODE_G => RCE_DMA_MODE_G,
         SIM_USER_ID_G  => SIM_USER_ID_G,
         SIMULATION_G   => SIMULATION_G)
      port map (
         axiDmaClk          => axiDmaClock,
         axiDmaRst          => axiDmaReset,
         acpWriteSlave      => acpWriteSlave,
         acpWriteMaster     => acpWriteMaster,
         acpReadSlave       => acpReadSlave,
         acpReadMaster      => acpReadMaster,
         hpWriteSlave       => hpWriteSlave,
         hpWriteMaster      => hpWriteMaster,
         hpReadSlave        => hpReadSlave,
         hpReadMaster       => hpReadMaster,
         auxWriteSlave      => auxWriteSlave,
         auxWriteMaster     => auxWriteMaster,
         auxReadSlave       => auxReadSlave,
         auxReadMaster      => auxReadMaster,
         dmaAxilReadMaster  => dmaAxilReadMaster,
         dmaAxilReadSlave   => dmaAxilReadSlave,
         dmaAxilWriteMaster => dmaAxilWriteMaster,
         dmaAxilWriteSlave  => dmaAxilWriteSlave,
         dmaInterrupt       => dmaInterrupt,
         dmaClk             => dmaClk,
         dmaClkRst          => dmaClkRst,
         dmaState           => dmaState,
         dmaObMaster        => dmaObMaster,
         dmaObSlave         => dmaObSlave,
         dmaIbMaster        => dmaIbMaster,
         dmaIbSlave         => dmaIbSlave);

end structure;
