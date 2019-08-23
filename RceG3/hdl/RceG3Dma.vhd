-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, DMA Controllers
-- File          : RceG3Dma.vhd
-------------------------------------------------------------------------------
-- Description:
-- Top level Wrapper for DMA controllers
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
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity RceG3Dma is
   generic (
      TPD_G          : time                        := 1 ns;
      SYNTH_MODE_G   : string                      := "xpm";
      MEMORY_TYPE_G  : string                      := "block";
      USE_DMA_ETH_G  : boolean                     := true;
      RCE_DMA_MODE_G : RceDmaModeType              := RCE_DMA_PPI_C;
      SIMULATION_G   : boolean                     := false;
      SIM_PORT_NUM_G : natural range 1024 to 49151 := 1024;
      SIM_CHANNELS_G : natural range 0 to 4        := 3;
      SIM_TDESTS_G   : natural range 0 to 256      := 256);
   port (

      -- AXI BUS Clock
      axiDmaClk : in sl;
      axiDmaRst : in sl;

      -- AXI ACP Slave
      acpWriteSlave  : in  AxiWriteSlaveType;
      acpWriteMaster : out AxiWriteMasterType;
      acpReadSlave   : in  AxiReadSlaveType;
      acpReadMaster  : out AxiReadMasterType;

      -- AXI HP Slave
      hpWriteSlave  : in  AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster : out AxiWriteMasterArray(3 downto 0);
      hpReadSlave   : in  AxiReadSlaveArray(3 downto 0);
      hpReadMaster  : out AxiReadMasterArray(3 downto 0);

      -- User memory access
      auxWriteSlave  : out AxiWriteSlaveType;
      auxWriteMaster : in  AxiWriteMasterType;
      auxReadSlave   : out AxiReadSlaveType;
      auxReadMaster  : in  AxiReadMasterType;

      -- Local AXI Lite Bus, 0x600n0000
      dmaAxilReadMaster  : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilReadSlave   : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteMaster : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteSlave  : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

      -- Interrupts
      dmaInterrupt : out slv(DMA_INT_COUNT_C-1 downto 0);

      -- External DMA Interfaces
      dmaClk      : in  slv(3 downto 0);
      dmaClkRst   : in  slv(3 downto 0);
      dmaState    : out RceDmaStateArray(3 downto 0);
      dmaObMaster : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave  : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave  : out AxiStreamSlaveArray(3 downto 0)
      );
end RceG3Dma;

architecture structure of RceG3Dma is

   signal simIbMasters : AxiStreamMasterArray((256*2)+255 downto 0);
   signal simIbSlaves  : AxiStreamSlaveArray((256*2)+255 downto 0);
   signal simObMasters : AxiStreamMasterArray((256*2)+255 downto 0);
   signal simObSlaves  : AxiStreamSlaveArray((256*2)+255 downto 0);

begin

   GEN_SYNTH : if (SIMULATION_G = false) generate

      ------------------------------------
      -- PPI DMA Controllers
      ------------------------------------
      U_PpiDmaGen : if RCE_DMA_MODE_G = RCE_DMA_PPI_C generate

         U_RceG3DmaPpi : entity work.RceG3DmaPpi
            generic map (
               TPD_G => TPD_G)
            -- SYNTH_MODE_G     => SYNTH_MODE_G,   <--- generic for future XPM FIFO release
            -- MEMORY_TYPE_G    => MEMORY_TYPE_G)  <--- generic for future XPM FIFO release 
            port map (
               axiDmaClk       => axiDmaClk,
               axiDmaRst       => axiDmaRst,
               acpWriteSlave   => acpWriteSlave,
               acpWriteMaster  => acpWriteMaster,
               acpReadSlave    => acpReadSlave,
               acpReadMaster   => acpReadMaster,
               hpWriteSlave    => hpWriteSlave,
               hpWriteMaster   => hpWriteMaster,
               hpReadSlave     => hpReadSlave,
               hpReadMaster    => hpReadMaster,
               axilReadMaster  => dmaAxilReadMaster,
               axilReadSlave   => dmaAxilReadSlave,
               axilWriteMaster => dmaAxilWriteMaster,
               axilWriteSlave  => dmaAxilWriteSlave,
               interrupt       => dmaInterrupt,
               dmaClk          => dmaClk,
               dmaClkRst       => dmaClkRst,
               dmaState        => dmaState,
               dmaObMaster     => dmaObMaster,
               dmaObSlave      => dmaObSlave,
               dmaIbMaster     => dmaIbMaster,
               dmaIbSlave      => dmaIbSlave);

         auxWriteSlave <= AXI_WRITE_SLAVE_INIT_C;
         auxReadSlave  <= AXI_READ_SLAVE_INIT_C;

      end generate;


      ------------------------------------
      -- AXI Streaming DMA Controllers
      ------------------------------------
      U_AxisDmaGen : if RCE_DMA_MODE_G = RCE_DMA_AXIS_C generate

         U_RceG3DmaAxis : entity work.RceG3DmaAxis
            generic map (
               TPD_G => TPD_G)
            -- SYNTH_MODE_G     => SYNTH_MODE_G,   <--- generic for future XPM FIFO release
            -- MEMORY_TYPE_G    => MEMORY_TYPE_G)  <--- generic for future XPM FIFO release 
            port map (
               axiDmaClk       => axiDmaClk,
               axiDmaRst       => axiDmaRst,
               acpWriteSlave   => acpWriteSlave,
               acpWriteMaster  => acpWriteMaster,
               acpReadSlave    => acpReadSlave,
               acpReadMaster   => acpReadMaster,
               hpWriteSlave    => hpWriteSlave,
               hpWriteMaster   => hpWriteMaster,
               hpReadSlave     => hpReadSlave,
               hpReadMaster    => hpReadMaster,
               auxWriteSlave   => auxWriteSlave,
               auxWriteMaster  => auxWriteMaster,
               auxReadSlave    => auxReadSlave,
               auxReadMaster   => auxReadMaster,
               axilReadMaster  => dmaAxilReadMaster,
               axilReadSlave   => dmaAxilReadSlave,
               axilWriteMaster => dmaAxilWriteMaster,
               axilWriteSlave  => dmaAxilWriteSlave,
               interrupt       => dmaInterrupt,
               dmaClk          => dmaClk,
               dmaClkRst       => dmaClkRst,
               dmaState        => dmaState,
               dmaObMaster     => dmaObMaster,
               dmaObSlave      => dmaObSlave,
               dmaIbMaster     => dmaIbMaster,
               dmaIbSlave      => dmaIbSlave);
      end generate;

      U_AxisV2DmaGen : if RCE_DMA_MODE_G = RCE_DMA_AXISV2_C generate

         U_RceG3DmaAxisV2 : entity work.RceG3DmaAxisV2
            generic map (
               TPD_G         => TPD_G,
               -- SYNTH_MODE_G  => SYNTH_MODE_G,   <--- generic for future XPM FIFO release
               -- MEMORY_TYPE_G => MEMORY_TYPE_G   <--- generic for future XPM FIFO release 
               USE_DMA_ETH_G => USE_DMA_ETH_G)
            port map (
               axiDmaClk       => axiDmaClk,
               axiDmaRst       => axiDmaRst,
               acpWriteSlave   => acpWriteSlave,
               acpWriteMaster  => acpWriteMaster,
               acpReadSlave    => acpReadSlave,
               acpReadMaster   => acpReadMaster,
               hpWriteSlave    => hpWriteSlave,
               hpWriteMaster   => hpWriteMaster,
               hpReadSlave     => hpReadSlave,
               hpReadMaster    => hpReadMaster,
               auxWriteSlave   => auxWriteSlave,
               auxWriteMaster  => auxWriteMaster,
               auxReadSlave    => auxReadSlave,
               auxReadMaster   => auxReadMaster,
               axilReadMaster  => dmaAxilReadMaster,
               axilReadSlave   => dmaAxilReadSlave,
               axilWriteMaster => dmaAxilWriteMaster,
               axilWriteSlave  => dmaAxilWriteSlave,
               interrupt       => dmaInterrupt,
               dmaClk          => dmaClk,
               dmaClkRst       => dmaClkRst,
               dmaState        => dmaState,
               dmaObMaster     => dmaObMaster,
               dmaObSlave      => dmaObSlave,
               dmaIbMaster     => dmaIbMaster,
               dmaIbSlave      => dmaIbSlave);
      end generate;

      ------------------------------------
      -- AXI Streaming DMA Simple Controller
      -- 4x2 Queue and fully HW path
      ------------------------------------
      U_Queue4x2DmaGen : if RCE_DMA_MODE_G = RCE_DMA_Q4X2_C generate

         U_RceG3DmaQueue4x2 : entity work.RceG3DmaQueue4x2
            generic map (
               TPD_G                => TPD_G,
               -- SYNTH_MODE_G     => SYNTH_MODE_G,   <--- generic for future XPM FIFO release
               -- MEMORY_TYPE_G    => MEMORY_TYPE_G,  <--- generic for future XPM FIFO release                
               DMA_BUF_START_ADDR_G => x"3C000000",  -- set x"00000000" for simulation and x"3C000000" for implementation
               DMA_BUF_SIZE_BITS_G  => 24,           -- set 24 for implementation
               MAX_CSPAD_PKT_SIZE_G => 1150000)
            port map (
               axiDmaClk       => axiDmaClk,
               axiDmaRst       => axiDmaRst,
               acpWriteSlave   => acpWriteSlave,
               acpWriteMaster  => acpWriteMaster,
               acpReadSlave    => acpReadSlave,
               acpReadMaster   => acpReadMaster,
               hpWriteSlave    => hpWriteSlave,
               hpWriteMaster   => hpWriteMaster,
               hpReadSlave     => hpReadSlave,
               hpReadMaster    => hpReadMaster,
               axilReadMaster  => dmaAxilReadMaster,
               axilReadSlave   => dmaAxilReadSlave,
               axilWriteMaster => dmaAxilWriteMaster,
               axilWriteSlave  => dmaAxilWriteSlave,
               interrupt       => dmaInterrupt,
               dmaClk          => dmaClk,
               dmaClkRst       => dmaClkRst,
               dmaState        => dmaState,
               dmaObMaster     => dmaObMaster,
               dmaObSlave      => dmaObSlave,
               dmaIbMaster     => dmaIbMaster,
               dmaIbSlave      => dmaIbSlave);

         auxWriteSlave <= AXI_WRITE_SLAVE_INIT_C;
         auxReadSlave  <= AXI_READ_SLAVE_INIT_C;

      end generate;

   end generate;

   GEN_SIM : if (SIMULATION_G = true) generate
      GEN_DMA : for i in SIM_CHANNELS_G-1 downto 0 generate
         U_TCP_DMA_LANE : entity work.RogueTcpStreamWrap
            generic map (
               TPD_G         => TPD_G,
               PORT_NUM_G    => (SIM_PORT_NUM_G + i*512),
               SSI_EN_G      => true,
               CHAN_COUNT_G  => SIM_TDESTS_G,
               AXIS_CONFIG_G => ite((i = 2), RCEG3_AXIS_DMA_ACP_CONFIG_C, RCEG3_AXIS_DMA_CONFIG_C))
            port map (
               axisClk     => dmaClk(i),
               axisRst     => dmaClkRst(i),
               sAxisMaster => dmaIbMaster(i),
               sAxisSlave  => dmaIbSlave(i),
               mAxisMaster => dmaObMaster(i),
               mAxisSlave  => dmaObSlave(i));
      end generate GEN_DMA;

      NO_DMA : for i in 3 downto SIM_CHANNELS_G generate
         -- Path data through RogueStreamSim (not Ethernet)
         dmaObMaster(i) <= AXI_STREAM_MASTER_INIT_C;
         dmaIbSlave(i)  <= AXI_STREAM_SLAVE_FORCE_C;
      end generate;

   end generate;

end architecture structure;
