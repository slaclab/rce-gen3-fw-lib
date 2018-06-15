-------------------------------------------------------------------------------
-- File       : DuneDpmCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-11-14
-- Last update: 2018-06-15
-------------------------------------------------------------------------------
-- Description: Common top level module for DUNE DPM
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

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.RceG3Pkg.all;
use work.MigCorePkg.all;

entity DuneDpmCore is
   generic (
      TPD_G              : time                  := 1 ns;
      BUILD_INFO_G       : BuildInfoType;
      ETH_10G_EN_G       : boolean               := false;
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_AXISV2_C;
      AXI_ST_COUNT_G     : natural range 3 to 4  := 3;
      UDP_SERVER_EN_G    : boolean               := false;
      UDP_SERVER_SIZE_G  : positive              := 1;
      UDP_SERVER_PORTS_G : PositiveArray         := (0 => 8192);
      BYP_EN_G           : boolean               := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)      := x"AAAA";
      VLAN_EN_G          : boolean               := false;
      VLAN_SIZE_G        : positive range 1 to 8 := 1;
      VLAN_VID_G         : Slv12Array            := (0 => x"001"));
   port (
      -- PL DDR MEM Ports
      ddrClkP              : in    sl;
      ddrClkN              : in    sl;
      ddrOut               : out   DdrOutType;
      ddrInOut             : inout DdrInOutType;
      -- IPMI I2C Ports
      i2cSda               : inout sl;
      i2cScl               : inout sl;
      -- Ethernet Ports
      ethRxP               : in    slv(1 downto 0);
      ethRxN               : in    slv(1 downto 0);
      ethTxP               : out   slv(1 downto 0);
      ethTxN               : out   slv(1 downto 0);
      ethRefClkP           : in    sl;
      ethRefClkN           : in    sl;
      sgmiiTxP             : out   slv(3 downto 0);
      sgmiiTxN             : out   slv(3 downto 0);
      sgmiiRxP             : in    slv(3 downto 0);
      sgmiiRxN             : in    slv(3 downto 0);
      -- Clocks and Resets
      sysClk125            : out   sl;
      sysRst125            : out   sl;
      sysClk200            : out   sl;
      sysRst200            : out   sl;
      -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
      axilClk              : out   sl;
      axilRst              : out   sl;
      axilReadMaster       : out   AxiLiteReadMasterType;
      axilReadSlave        : in    AxiLiteReadSlaveType;
      axilWriteMaster      : out   AxiLiteWriteMasterType;
      axilWriteSlave       : in    AxiLiteWriteSlaveType;
      -- PL DDR MEM Interface
      ddrClk               : out   sl;
      ddrRst               : out   sl;
      ddrWriteMaster       : in    AxiWriteMasterType;
      ddrWriteSlave        : out   AxiWriteSlaveType;
      ddrReadMaster        : in    AxiReadMasterType;
      ddrReadSlave         : out   AxiReadSlaveType;
      -- AXI Stream DMA Interfaces
      dmaClk               : in    slv(AXI_ST_COUNT_G-1 downto 0);
      dmaRst               : in    slv(AXI_ST_COUNT_G-1 downto 0);
      dmaState             : out   RceDmaStateArray(AXI_ST_COUNT_G-1 downto 0);
      dmaObMasters         : out   AxiStreamMasterArray(AXI_ST_COUNT_G-1 downto 0);
      dmaObSlaves          : in    AxiStreamSlaveArray(AXI_ST_COUNT_G-1 downto 0);
      dmaIbMasters         : in    AxiStreamMasterArray(AXI_ST_COUNT_G-1 downto 0);
      dmaIbSlaves          : out   AxiStreamSlaveArray(AXI_ST_COUNT_G-1 downto 0);
      -- Advance User's memory access to PS's memory (sysclk200 domain)
      userWriteSlave       : out   AxiWriteSlaveType;
      userWriteMaster      : in    AxiWriteMasterType                           := AXI_WRITE_MASTER_INIT_C;
      userReadSlave        : out   AxiReadSlaveType;
      userReadMaster       : in    AxiReadMasterType                            := AXI_READ_MASTER_INIT_C;
      -- User ETH interface (userEthClk domain)
      userEthClk           : out   sl;
      userEthRst           : out   sl;
      userEthIpAddr        : out   slv(31 downto 0);
      userEthMacAddr       : out   slv(47 downto 0);
      userEthUdpIbMaster   : in    AxiStreamMasterType                          := AXI_STREAM_MASTER_INIT_C;
      userEthUdpIbSlave    : out   AxiStreamSlaveType;
      userEthUdpObMaster   : out   AxiStreamMasterType;
      userEthUdpObSlave    : in    AxiStreamSlaveType                           := AXI_STREAM_SLAVE_FORCE_C;
      userEthBypIbMaster   : in    AxiStreamMasterType                          := AXI_STREAM_MASTER_INIT_C;
      userEthBypIbSlave    : out   AxiStreamSlaveType;
      userEthBypObMaster   : out   AxiStreamMasterType;
      userEthBypObSlave    : in    AxiStreamSlaveType                           := AXI_STREAM_SLAVE_FORCE_C;
      userEthVlanIbMasters : in    AxiStreamMasterArray(VLAN_SIZE_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
      userEthVlanIbSlaves  : out   AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanObMasters : out   AxiStreamMasterArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanObSlaves  : in    AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
      -- User Interrupts
      userInterrupt        : in    slv(USER_INT_COUNT_C-1 downto 0)             := (others => '0'));
end DuneDpmCore;

architecture mapping of DuneDpmCore is

   signal iaxiClk             : sl;
   signal iaxiClkRst          : sl;
   signal isysClk125          : sl;
   signal isysClk125Rst       : sl;
   signal isysClk200          : sl;
   signal isysClk200Rst       : sl;
   signal idmaClk             : slv(3 downto 0);
   signal idmaClkRst          : slv(3 downto 0);
   signal idmaState           : RceDmaStateArray(3 downto 0);
   signal idmaObMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave         : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave         : AxiStreamSlaveArray(3 downto 0);
   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
   signal armEthTx            : ArmEthTxArray(1 downto 0);
   signal armEthRx            : ArmEthRxArray(1 downto 0);
   signal armEthMode          : slv(31 downto 0);

   signal sgmiiRx : slv(3 downto 0);
   signal sgmiiTx : slv(3 downto 0);

begin

   --------------------------------------------------
   -- Assertions to validate the configuration
   --------------------------------------------------

   assert (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C and AXI_ST_COUNT_G = 4) or RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C
      report "Only AXI_ST_COUNT_G = 4 is supported when RCE_DMA_MODE_G = RCE_DMA_Q4X2_C"
      severity failure;
   assert (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C and ETH_10G_EN_G = false) or RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C
      report "RCE_DMA_MODE_G = RCE_DMA_Q4X2_C is not supported when ETH_10G_EN_G = true"
      severity failure;

   -- more assertion checks should be added e.g. ETH_10G_EN_G = true only with RCE_DMA_MODE_G = RCE_DMA_PPI_C ???
   -- my 3rd assertion can be removed when the above check is added

   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   axilClk   <= iaxiClk;
   axilRst   <= iaxiClkRst;
   sysClk125 <= isysClk125;
   sysRst125 <= isysClk125Rst;
   sysClk200 <= isysClk200;
   sysRst200 <= isysClk200Rst;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk(2 downto 0);
   idmaClkRst(2 downto 0)   <= dmaRst(2 downto 0);
   dmaState(2 downto 0)     <= idmaState(2 downto 0);
   dmaObMasters(2 downto 0) <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlaves(2 downto 0);
   idmaIbMaster(2 downto 0) <= dmaIbMasters(2 downto 0);
   dmaIbSlaves(2 downto 0)  <= idmaIbSlave(2 downto 0);

   -------------
   -- PL DDR MEM
   -------------
   U_Mig : entity work.MigCore
      generic map (
         TPD_G => TPD_G)
      port map (
         extRst         => isysClk125Rst,
         -- PL DDR MEM Interface
         ddrClk         => ddrClk,
         ddrRst         => ddrRst,
         ddrWriteMaster => ddrWriteMaster,
         ddrWriteSlave  => ddrWriteSlave,
         ddrReadMaster  => ddrReadMaster,
         ddrReadSlave   => ddrReadSlave,
         -- PL DDR MEM Ports
         ddrClkP        => ddrClkP,
         ddrClkN        => ddrClkN,
         ddrOut         => ddrOut,
         ddrInOut       => ddrInOut);

   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top : entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         BUILD_INFO_G   => BUILD_INFO_G,
         XIL_DEVICE_G   => "ULTRASCALE",
         RCE_DMA_MODE_G => RCE_DMA_MODE_G)
      port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => isysClk125,
         sysClk125Rst        => isysClk125Rst,
         sysClk200           => isysClk200,
         sysClk200Rst        => isysClk200Rst,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         extAxilReadMaster   => axilReadMaster,
         extAxilReadSlave    => axilReadSlave,
         extAxilWriteMaster  => axilWriteMaster,
         extAxilWriteSlave   => axilWriteSlave,
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         dmaClk              => idmaClk,
         dmaClkRst           => idmaClkRst,
         dmaState            => idmaState,
         dmaObMaster         => idmaObMaster,
         dmaObSlave          => idmaObSlave,
         dmaIbMaster         => idmaIbMaster,
         dmaIbSlave          => idmaIbSlave,
         userInterrupt       => userInterrupt,
         userWriteSlave      => userWriteSlave,
         userWriteMaster     => userWriteMaster,
         userReadSlave       => userReadSlave,
         userReadMaster      => userReadMaster,
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode,
         clkSelA             => open,
         clkSelB             => open);

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_Eth1gGen : if ETH_10G_EN_G = false generate
      U_ZynqEthernet : entity work.ZynqEthernet
         port map (
            sysClk125    => isysClk125,
            sysClk200    => isysClk200,
            sysClk200Rst => isysClk200Rst,
            armEthTx     => armEthTx(0),
            armEthRx     => armEthRx(0),
            ethRxP       => ethRxP(0),
            ethRxM       => ethRxN(0),
            ethTxP       => ethTxP(0),
            ethTxM       => ethTxN(0));

      userEthClk           <= isysClk125;
      userEthRst           <= isysClk125Rst;
      userEthIpAddr        <= (others => '0');
      userEthMacAddr       <= (others => '0');
      userEthUdpIbSlave    <= AXI_STREAM_SLAVE_FORCE_C;
      userEthUdpObMaster   <= AXI_STREAM_MASTER_INIT_C;
      userEthBypIbSlave    <= AXI_STREAM_SLAVE_FORCE_C;
      userEthBypObMaster   <= AXI_STREAM_MASTER_INIT_C;
      userEthVlanIbSlaves  <= (others => AXI_STREAM_SLAVE_FORCE_C);
      userEthVlanObMasters <= (others => AXI_STREAM_MASTER_INIT_C);

      U_Q4X2DmaGen : if (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C) generate
         idmaClk(3)                     <= dmaClk(AXI_ST_COUNT_G-1);
         idmaClkRst(3)                  <= dmaRst(AXI_ST_COUNT_G-1);
         idmaObSlave(3)                 <= dmaObSlaves(AXI_ST_COUNT_G-1);
         idmaIbMaster(3)                <= dmaIbMasters(AXI_ST_COUNT_G-1);
         dmaState(AXI_ST_COUNT_G-1)     <= idmaState(3);
         dmaObMasters(AXI_ST_COUNT_G-1) <= idmaObMaster(3);
         dmaIbSlaves(AXI_ST_COUNT_G-1)  <= idmaIbSlave(3);
      end generate;
      U_NoQ4X2DmaGen : if (RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C) generate
         idmaClk(3)      <= isysClk125;
         idmaClkRst(3)   <= isysClk125Rst;
         idmaObSlave(3)  <= AXI_STREAM_SLAVE_INIT_C;
         idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;
      end generate;

      armEthRx(1) <= ARM_ETH_RX_INIT_C;
      armEthMode  <= x"00000001";       -- 1 Gig on lane 0

   end generate;

   -- U_Eth10gGen : if ETH_10G_EN_G = true generate
   -- U_ZynqEthernet10G : entity work.ZynqEthernet10G
   -- generic map (
   -- TPD_G              => TPD_G,
   -- RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
   -- UDP_SERVER_EN_G    => UDP_SERVER_EN_G,
   -- UDP_SERVER_SIZE_G  => UDP_SERVER_SIZE_G,
   -- UDP_SERVER_PORTS_G => UDP_SERVER_PORTS_G,
   -- BYP_EN_G           => BYP_EN_G,
   -- BYP_ETH_TYPE_G     => BYP_ETH_TYPE_G,
   -- VLAN_EN_G          => VLAN_EN_G,
   -- VLAN_SIZE_G        => VLAN_SIZE_G,
   -- VLAN_VID_G         => VLAN_VID_G)
   -- port map (
   -- -- Clocks
   -- sysClk200            => isysClk200,
   -- sysClk200Rst         => isysClk200Rst,
   -- -- PPI Interface
   -- dmaClk               => idmaClk(3),
   -- dmaClkRst            => idmaClkRst(3),
   -- dmaState             => idmaState(3),
   -- dmaIbMaster          => idmaIbMaster(3),
   -- dmaIbSlave           => idmaIbSlave(3),
   -- dmaObMaster          => idmaObMaster(3),
   -- dmaObSlave           => idmaObSlave(3),
   -- -- User ETH interface (userEthClk domain)
   -- userEthClk           => userEthClk,
   -- userEthClkRst        => userEthRst,
   -- userEthIpAddr        => userEthIpAddr,
   -- userEthMacAddr       => userEthMacAddr,
   -- userEthUdpObMaster   => userEthUdpObMaster,
   -- userEthUdpObSlave    => userEthUdpObSlave,
   -- userEthUdpIbMaster   => userEthUdpIbMaster,
   -- userEthUdpIbSlave    => userEthUdpIbSlave,
   -- userEthBypObMaster   => userEthBypObMaster,
   -- userEthBypObSlave    => userEthBypObSlave,
   -- userEthBypIbMaster   => userEthBypIbMaster,
   -- userEthBypIbSlave    => userEthBypIbSlave,
   -- userEthVlanObMasters => userEthVlanObMasters,
   -- userEthVlanObSlaves  => userEthVlanObSlaves,
   -- userEthVlanIbMasters => userEthVlanIbMasters,
   -- userEthVlanIbSlaves  => userEthVlanIbSlaves,
   -- -- AXI-Lite Buses
   -- axilClk              => iaxiClk,
   -- axilClkRst           => iaxiClkRst,
   -- axilWriteMaster      => coreAxilWriteMaster,
   -- axilWriteSlave       => coreAxilWriteSlave,
   -- axilReadMaster       => coreAxilReadMaster,
   -- axilReadSlave        => coreAxilReadSlave,
   -- -- Ref Clock
   -- ethRefClkP           => ethRefClkP,
   -- ethRefClkM           => ethRefClkN,
   -- -- Ethernet Lines
   -- ethRxP               => ethRxP(0),
   -- ethRxM               => ethRxN(0),
   -- ethTxP               => ethTxP(0),
   -- ethTxM               => ethTxN(0));

   -- armEthRx   <= (others => ARM_ETH_RX_INIT_C);
   -- armEthMode <= x"0000000A";        -- 10 Gig on lane 0

   -- end generate;

   U_UnusedGth : entity work.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 1)
      port map (
         refClk   => isysClk125,
         gtRxP(0) => ethRxP(1),
         gtRxN(0) => ethRxN(1),
         gtTxP(0) => ethTxP(1),
         gtTxN(0) => ethTxN(1));

   GEN_VEC : for i in 3 to 0 generate
      U_sgmiiRx : IBUFDS
         generic map (
            DIFF_TERM => true)
         port map(
            I  => sgmiiRxP(i),
            IB => sgmiiRxN(i),
            O  => sgmiiRx(i));
      U_sgmiiTx : OBUFDS
         port map(
            I  => sgmiiTx(i),
            O  => sgmiiTxP(i),
            OB => sgmiiTxN(i));
      -- Prevent optimizing out the IBUFDS/OBUFDS
      sgmiiTx(i) <= sgmiiRx(i) and iaxiClkRst;
   end generate;

end mapping;
