-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : DpmCore.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-11-14
-- Last update: 2018-03-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Common top level module for DPM
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

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

entity DpmCore is
   generic (
      TPD_G              : time                  := 1 ns;
      BUILD_INFO_G       : BuildInfoType;
      ETH_10G_EN_G       : boolean               := false;
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_PPI_C;
      AXI_ST_COUNT_G     : natural range 3 to 4  := 3;
      USE_AXI_IC_G       : boolean               := false;
      UDP_SERVER_EN_G    : boolean               := false;
      UDP_SERVER_SIZE_G  : positive              := 1;
      UDP_SERVER_PORTS_G : PositiveArray         := (0 => 8192);
      BYP_EN_G           : boolean               := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)      := x"AAAA";
      VLAN_EN_G          : boolean               := false;
      VLAN_SIZE_G        : positive range 1 to 8 := 1;
      VLAN_VID_G         : Slv12Array            := (0 => x"001"));       
   port (
      -- I2C
      i2cSda               : inout sl;
      i2cScl               : inout sl;
      -- Ethernet
      ethRxP               : in    slv(3 downto 0);
      ethRxM               : in    slv(3 downto 0);
      ethTxP               : out   slv(3 downto 0);
      ethTxM               : out   slv(3 downto 0);
      ethRefClkP           : in    sl;
      ethRefClkM           : in    sl;
      -- Clock Select
      clkSelA              : out   slv(1 downto 0);
      clkSelB              : out   slv(1 downto 0);
      -- Clocks and Resets
      sysClk125            : out   sl;
      sysClk125Rst         : out   sl;
      sysClk200            : out   sl;
      sysClk200Rst         : out   sl;
      -- External AXI-Lite Interface [0xA0000000:0xAFFFFFFF]
      axiClk               : out   sl;
      axiClkRst            : out   sl;
      extAxilReadMaster    : out   AxiLiteReadMasterType;
      extAxilReadSlave     : in    AxiLiteReadSlaveType;
      extAxilWriteMaster   : out   AxiLiteWriteMasterType;
      extAxilWriteSlave    : in    AxiLiteWriteSlaveType;
      -- DMA Interfaces
      dmaClk               : in    slv(AXI_ST_COUNT_G-1 downto 0);
      dmaClkRst            : in    slv(AXI_ST_COUNT_G-1 downto 0);
      dmaState             : out   RceDmaStateArray(AXI_ST_COUNT_G-1 downto 0);
      dmaObMaster          : out   AxiStreamMasterArray(AXI_ST_COUNT_G-1 downto 0);
      dmaObSlave           : in    AxiStreamSlaveArray(AXI_ST_COUNT_G-1 downto 0);
      dmaIbMaster          : in    AxiStreamMasterArray(AXI_ST_COUNT_G-1 downto 0);
      dmaIbSlave           : out   AxiStreamSlaveArray(AXI_ST_COUNT_G-1 downto 0);
      -- User memory access (sysclk200 domain)
      userWriteSlave       : out   AxiWriteSlaveType;
      userWriteMaster      : in    AxiWriteMasterType                           := AXI_WRITE_MASTER_INIT_C;
      userReadSlave        : out   AxiReadSlaveType;
      userReadMaster       : in    AxiReadMasterType                            := AXI_READ_MASTER_INIT_C;
      -- PCIE AXI Interface (axiClk domain)
      pcieReadMaster       : out   AxiReadMasterArray(1 downto 0);
      pcieReadSlave        : in    AxiReadSlaveArray(1 downto 0)                := (others=>AXI_READ_SLAVE_INIT_C);
      pcieWriteMaster      : out   AxiWriteMasterArray(1 downto 0);
      pcieWriteSlave       : in    AxiWriteSlaveArray(1 downto 0)               := (others=>AXI_WRITE_SLAVE_INIT_C);
      -- User ETH interface (userEthClk domain)
      userEthClk           : out   sl;
      userEthClkRst        : out   sl;
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
end DpmCore;

architecture STRUCTURE of DpmCore is

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
   signal coreAxilReadSlave   : AxiLiteReadSlaveType := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;
   signal armEthTx            : ArmEthTxArray(1 downto 0);
   signal armEthRx            : ArmEthRxArray(1 downto 0);
   signal armEthMode          : slv(31 downto 0);

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
   axiClk       <= iaxiClk;
   axiClkRst    <= iaxiClkRst;
   sysClk125    <= isysClk125;
   sysClk125Rst <= isysClk125Rst;
   sysClk200    <= isysClk200;
   sysClk200Rst <= isysClk200Rst;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk(2 downto 0);
   idmaClkRst(2 downto 0)   <= dmaClkRst(2 downto 0);
   dmaState(2 downto 0)     <= idmaState(2 downto 0);
   dmaObMaster(2 downto 0)  <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlave(2 downto 0);
   idmaIbMaster(2 downto 0) <= dmaIbMaster(2 downto 0);
   dmaIbSlave(2 downto 0)   <= idmaIbSlave(2 downto 0);

   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top : entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         USE_AXI_IC_G   => USE_AXI_IC_G,
         BUILD_INFO_G   => BUILD_INFO_G,
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
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave,
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
         pcieReadMaster      => pcieReadMaster,
         pcieReadSlave       => pcieReadSlave,
         pcieWriteMaster     => pcieWriteMaster,
         pcieWriteSlave      => pcieWriteSlave,
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode,
         clkSelA             => open,
         clkSelB             => open);

   -- Osc 0 = 156.25
   clkSelA(0) <= '0';
   clkSelB(0) <= '0';

   -- Osc 1 = 250
   clkSelA(1) <= '1';
   clkSelB(1) <= '1';

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
            ethRxM       => ethRxM(0),
            ethTxP       => ethTxP(0),
            ethTxM       => ethTxM(0));

      userEthClk           <= isysClk125;
      userEthClkRst        <= isysClk125Rst;
      userEthIpAddr        <= (others => '0');
      userEthMacAddr       <= (others => '0');
      userEthUdpIbSlave    <= AXI_STREAM_SLAVE_FORCE_C;
      userEthUdpObMaster   <= AXI_STREAM_MASTER_INIT_C;
      userEthBypIbSlave    <= AXI_STREAM_SLAVE_FORCE_C;
      userEthBypObMaster   <= AXI_STREAM_MASTER_INIT_C;
      userEthVlanIbSlaves  <= (others => AXI_STREAM_SLAVE_FORCE_C);
      userEthVlanObMasters <= (others => AXI_STREAM_MASTER_INIT_C);

      U_Q4X2DmaGen : if (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C) generate
         idmaClk(3)                    <= dmaClk(AXI_ST_COUNT_G-1);
         idmaClkRst(3)                 <= dmaClkRst(AXI_ST_COUNT_G-1);
         idmaObSlave(3)                <= dmaObSlave(AXI_ST_COUNT_G-1);
         idmaIbMaster(3)               <= dmaIbMaster(AXI_ST_COUNT_G-1);
         dmaState(AXI_ST_COUNT_G-1)    <= idmaState(3);
         dmaObMaster(AXI_ST_COUNT_G-1) <= idmaObMaster(3);
         dmaIbSlave(AXI_ST_COUNT_G-1)  <= idmaIbSlave(3);
      end generate;
      U_NoQ4X2DmaGen : if (RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C) generate
         idmaClk(3)      <= isysClk125;
         idmaClkRst(3)   <= isysClk125Rst;
         idmaObSlave(3)  <= AXI_STREAM_SLAVE_INIT_C;
         idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;
      end generate;

      ethTxP(3 downto 1) <= (others => '0');
      ethTxM(3 downto 1) <= (others => '0');
      armEthRx(1)        <= ARM_ETH_RX_INIT_C;
      armEthMode         <= x"00000001";  -- 1 Gig on lane 0

    end generate;

   U_Eth10gGen : if ETH_10G_EN_G = true generate
      U_ZynqEthernet10G : entity work.ZynqEthernet10G
         generic map (
            TPD_G              => TPD_G,
            RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
            UDP_SERVER_EN_G    => UDP_SERVER_EN_G,
            UDP_SERVER_SIZE_G  => UDP_SERVER_SIZE_G,
            UDP_SERVER_PORTS_G => UDP_SERVER_PORTS_G,
            BYP_EN_G           => BYP_EN_G,
            BYP_ETH_TYPE_G     => BYP_ETH_TYPE_G,
            VLAN_EN_G          => VLAN_EN_G,
            VLAN_SIZE_G        => VLAN_SIZE_G,
            VLAN_VID_G         => VLAN_VID_G)
         port map (
            -- Clocks
            sysClk200            => isysClk200,
            sysClk200Rst         => isysClk200Rst,
            -- PPI Interface
            dmaClk               => idmaClk(3),
            dmaClkRst            => idmaClkRst(3),
            dmaState             => idmaState(3),
            dmaIbMaster          => idmaIbMaster(3),
            dmaIbSlave           => idmaIbSlave(3),
            dmaObMaster          => idmaObMaster(3),
            dmaObSlave           => idmaObSlave(3),
            -- User ETH interface (userEthClk domain)
            userEthClk           => userEthClk,
            userEthClkRst        => userEthClkRst,
            userEthIpAddr        => userEthIpAddr,
            userEthMacAddr       => userEthMacAddr,
            userEthUdpObMaster   => userEthUdpObMaster,
            userEthUdpObSlave    => userEthUdpObSlave,
            userEthUdpIbMaster   => userEthUdpIbMaster,
            userEthUdpIbSlave    => userEthUdpIbSlave,
            userEthBypObMaster   => userEthBypObMaster,
            userEthBypObSlave    => userEthBypObSlave,
            userEthBypIbMaster   => userEthBypIbMaster,
            userEthBypIbSlave    => userEthBypIbSlave,
            userEthVlanObMasters => userEthVlanObMasters,
            userEthVlanObSlaves  => userEthVlanObSlaves,
            userEthVlanIbMasters => userEthVlanIbMasters,
            userEthVlanIbSlaves  => userEthVlanIbSlaves,
            -- AXI-Lite Buses
            axilClk              => iaxiClk,
            axilClkRst           => iaxiClkRst,
            axilWriteMaster      => coreAxilWriteMaster,
            axilWriteSlave       => coreAxilWriteSlave,
            axilReadMaster       => coreAxilReadMaster,
            axilReadSlave        => coreAxilReadSlave,
            -- Ref Clock
            ethRefClkP           => ethRefClkP,
            ethRefClkM           => ethRefClkM,
            -- Ethernet Lines
            ethRxP               => ethRxP,
            ethRxM               => ethRxM,
            ethTxP               => ethTxP,
            ethTxM               => ethTxM);

      armEthRx   <= (others => ARM_ETH_RX_INIT_C);
      armEthMode <= x"03030303";        -- XAUI on lanes 3:0

   end generate;

end architecture STRUCTURE;
