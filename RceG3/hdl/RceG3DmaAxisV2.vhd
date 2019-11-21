-------------------------------------------------------------------------------
-- Title      : RCE Generation 3 DMA, AXI Streaming, Multi-Channel
-- File       : RceG3DmaAxisV2.vhd
-------------------------------------------------------------------------------
-- Description:
-- AXI Stream DMA based channel for RCE core DMA. AXI streaming.
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


library surf;
use surf.StdRtlPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiPkg.all;
use surf.AxiDmaPkg.all;

entity RceG3DmaAxisV2 is
   generic (
      TPD_G         : time    := 1 ns;
      SYNTH_MODE_G  : string  := "xpm";
      MEMORY_TYPE_G : string  := "block";
      USE_DMA_ETH_G : boolean := true);
   port (
      -- Clock/Reset
      axiDmaClk       : in  sl;
      axiDmaRst       : in  sl;
      -- AXI ACP Slave
      acpWriteSlave   : in  AxiWriteSlaveType;
      acpWriteMaster  : out AxiWriteMasterType;
      acpReadSlave    : in  AxiReadSlaveType;
      acpReadMaster   : out AxiReadMasterType;
      -- AXI HP Slave
      hpWriteSlave    : in  AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster   : out AxiWriteMasterArray(3 downto 0);
      hpReadSlave     : in  AxiReadSlaveArray(3 downto 0);
      hpReadMaster    : out AxiReadMasterArray(3 downto 0);
      -- User memory access
      auxWriteSlave   : out AxiWriteSlaveType;
      auxWriteMaster  : in  AxiWriteMasterType;
      auxReadSlave    : out AxiReadSlaveType;
      auxReadMaster   : in  AxiReadMasterType;
      -- Local AXI Lite Bus, 0x600n0000
      axilReadMaster  : in  AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilReadSlave   : out AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);
      axilWriteMaster : in  AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      axilWriteSlave  : out AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
      -- Interrupts
      interrupt       : out slv(DMA_INT_COUNT_C-1 downto 0);
      -- External DMA Interfaces
      dmaClk          : in  slv(3 downto 0);
      dmaClkRst       : in  slv(3 downto 0);
      dmaState        : out RceDmaStateArray(3 downto 0);
      dmaObMaster     : out AxiStreamMasterArray(3 downto 0);
      dmaObSlave      : in  AxiStreamSlaveArray(3 downto 0);
      dmaIbMaster     : in  AxiStreamMasterArray(3 downto 0);
      dmaIbSlave      : out AxiStreamSlaveArray(3 downto 0));
end RceG3DmaAxisV2;

architecture mapping of RceG3DmaAxisV2 is

   constant DMA_CH_COUNT_C : positive := ite(USE_DMA_ETH_G, 2, 3);

   signal intWriteSlave  : AxiWriteSlaveArray(3 downto 0);
   signal intWriteMaster : AxiWriteMasterArray(3 downto 0);
   signal intReadSlave   : AxiReadSlaveArray(3 downto 0);
   signal intReadMaster  : AxiReadMasterArray(3 downto 0);

   constant AXIL_GP0_CONFIG_C : AxiLiteCrossbarMasterConfigArray(DMA_AXIL_COUNT_C downto 0) := genGp0Config(RCE_DMA_AXISV2_C);

begin

   -- HP for channel 0 & 1
   intWriteSlave(1 downto 0) <= hpWriteSlave(1 downto 0);
   hpWriteMaster(1 downto 0) <= intWriteMaster(1 downto 0);
   intReadSlave(1 downto 0)  <= hpReadSlave(1 downto 0);
   hpReadMaster(1 downto 0)  <= intReadMaster(1 downto 0);

   -- ACP for channel 2
   intWriteSlave(2) <= acpWriteSlave;
   acpWriteMaster   <= intWriteMaster(2);
   intReadSlave(2)  <= acpReadSlave;
   acpReadMaster    <= intReadMaster(2);

   -- HP 2 goes to aux space
   auxWriteSlave    <= hpWriteSlave(2);
   hpWriteMaster(2) <= auxWriteMaster;
   auxReadSlave     <= hpReadSlave(2);
   hpReadMaster(2)  <= auxReadMaster;

   -- HP for channel 3
   intWriteSlave(3) <= hpWriteSlave(3);
   hpWriteMaster(3) <= intWriteMaster(3);
   intReadSlave(3)  <= hpReadSlave(3);
   hpReadMaster(3)  <= intReadMaster(3);

   -- Unused Interrupts
   interrupt(DMA_INT_COUNT_C-1 downto 4) <= (others => '0');

   -------------------------------------------
   -- Version 2 DMA Core 
   -------------------------------------------
   U_Gen2Dma : for i in 0 to DMA_CH_COUNT_C generate
      U_RceG3DmaAxisChan : entity rce_gen3_fw_lib.RceG3DmaAxisV2Chan
         generic map (
            TPD_G             => TPD_G,
            SYNTH_MODE_G      => SYNTH_MODE_G,
            MEMORY_TYPE_G     => MEMORY_TYPE_G,
            AXIL_BASE_ADDR_G  => AXIL_GP0_CONFIG_C(i*2+1).baseAddr,
            AXIS_DMA_CONFIG_G => ite((i = 2), RCEG3_AXIS_DMA_ACP_CONFIG_C, RCEG3_AXIS_DMA_CONFIG_C),
            AXI_CONFIG_G      => ite((i = 2), AXI_ACP_INIT_C, AXI_HP_INIT_C))
         port map (
            axiDmaClk       => axiDmaClk,
            axiDmaRst       => axiDmaRst,
            axiWriteSlave   => intWriteSlave(i),
            axiWriteMaster  => intWriteMaster(i),
            axiReadSlave    => intReadSlave(i),
            axiReadMaster   => intReadMaster(i),
            axilReadMaster  => axilReadMaster(i*2),
            axilReadSlave   => axilReadSlave(i*2),
            axilWriteMaster => axilWriteMaster(i*2),
            axilWriteSlave  => axilWriteSlave(i*2),
            interrupt       => interrupt(i),
            dmaClk          => dmaClk(i),
            dmaClkRst       => dmaClkRst(i),
            dmaState        => dmaState(i),
            dmaObMaster     => dmaObMaster(i),
            dmaObSlave      => dmaObSlave(i),
            dmaIbMaster     => dmaIbMaster(i),
            dmaIbSlave      => dmaIbSlave(i));
   end generate;

   -------------------------------------------
   -- Version 1 DMA Core For Ethernet
   -------------------------------------------
   USE_DMA_ETH : if (USE_DMA_ETH_G = true) generate
      U_RxG3DmaAxiChan : entity rce_gen3_fw_lib.RceG3DmaAxisChan
         generic map (
            TPD_G         => TPD_G,
            --SYNTH_MODE_G  => SYNTH_MODE_G,
            --MEMORY_TYPE_G => MEMORY_TYPE_G,
            AXI_CACHE_G   => "0000",
            BYP_SHIFT_G   => false,
            AXI_CONFIG_G  => AXI_HP_INIT_C)
         port map (
            axiDmaClk       => axiDmaClk,
            axiDmaRst       => axiDmaRst,
            axiReadMaster   => intReadMaster(3),
            axiReadSlave    => intReadSlave(3),
            axiWriteMaster  => intWriteMaster(3),
            axiWriteSlave   => intWriteSlave(3),
            axilReadMaster  => axilReadMaster(7 downto 6),
            axilReadSlave   => axilReadSlave(7 downto 6),
            axilWriteMaster => axilWriteMaster(7 downto 6),
            axilWriteSlave  => axilWriteSlave(7 downto 6),
            interrupt       => interrupt(3),
            dmaClk          => dmaClk(3),
            dmaClkRst       => dmaClkRst(3),
            dmaState        => dmaState(3),
            dmaObMaster     => dmaObMaster(3),
            dmaObSlave      => dmaObSlave(3),
            dmaIbMaster     => dmaIbMaster(3),
            dmaIbSlave      => dmaIbSlave(3));
   end generate;
end mapping;

