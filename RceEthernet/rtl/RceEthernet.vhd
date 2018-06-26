-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : RceEthernet.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-09-03
-- Last update: 2018-06-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Wrapper file for Zynq Ethernet 10G core
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE 10G Ethernet Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE 10G Ethernet Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.EthMacPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.PpiPkg.all;
use work.RceG3Pkg.all;

entity RceEthernet is
   generic (
      -- Generic Configurations
      TPD_G              : time                  := 1 ns;
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_PPI_C;
      ETH_TYPE_G         : string                := "XAUI";  -- or "10GBase" or "1000Base"
      SYNTH_MODE_G       : string                := "inferred";
      MEMORY_TYPE_G      : string                := "block";
      -- User ETH Configurations
      UDP_SERVER_EN_G    : boolean               := false;
      UDP_SERVER_SIZE_G  : positive              := 1;
      UDP_SERVER_PORTS_G : PositiveArray         := (0 => 8192);
      BYP_EN_G           : boolean               := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)      := x"AAAA";
      VLAN_EN_G          : boolean               := false;
      VLAN_SIZE_G        : positive range 1 to 8 := 1;
      VLAN_VID_G         : Slv12Array            := (0 => x"001"));
   port (
      -- Clocks
      sysClk200            : in  sl;
      sysClk200Rst         : in  sl;
      -- PPI Interface
      dmaClk               : out sl;
      dmaClkRst            : out sl;
      dmaState             : in  RceDmaStateType;
      dmaIbMaster          : out AxiStreamMasterType;
      dmaIbSlave           : in  AxiStreamSlaveType;
      dmaObMaster          : in  AxiStreamMasterType;
      dmaObSlave           : out AxiStreamSlaveType;
      -- User ETH interface
      userEthClk           : out sl;
      userEthClkRst        : out sl;
      userEthIpAddr        : out slv(31 downto 0);
      userEthMacAddr       : out slv(47 downto 0);
      userEthUdpIbMaster   : in  AxiStreamMasterType;
      userEthUdpIbSlave    : out AxiStreamSlaveType;
      userEthUdpObMaster   : out AxiStreamMasterType;
      userEthUdpObSlave    : in  AxiStreamSlaveType;
      userEthBypIbMaster   : in  AxiStreamMasterType;
      userEthBypIbSlave    : out AxiStreamSlaveType;
      userEthBypObMaster   : out AxiStreamMasterType;
      userEthBypObSlave    : in  AxiStreamSlaveType;
      userEthVlanIbMasters : in  AxiStreamMasterArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanIbSlaves  : out AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanObMasters : out AxiStreamMasterArray(VLAN_SIZE_G-1 downto 0);
      userEthVlanObSlaves  : in  AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0);
      -- AXI-Lite Buses
      axilClk              : in  sl;
      axilClkRst           : in  sl;
      axilWriteMaster      : in  AxiLiteWriteMasterType;
      axilWriteSlave       : out AxiLiteWriteSlaveType;
      axilReadMaster       : in  AxiLiteReadMasterType;
      axilReadSlave        : out AxiLiteReadSlaveType;
      -- Ref Clock
      ethRefClkP           : in  sl;
      ethRefClkM           : in  sl;
      -- Ethernet Lines
      ethRxP               : in  slv(3 downto 0) := x"0";
      ethRxM               : in  slv(3 downto 0) := x"F";
      ethTxP               : out slv(3 downto 0) := x"0";
      ethTxM               : out slv(3 downto 0) := x"F");
end RceEthernet;

architecture mapping of RceEthernet is

   constant PHY_TYPE_C : string := ite(ETH_TYPE_G = "1000Base", "GMII", "XGMII");

   component zynq_10g_xaui
      port (
         dclk                 : in  sl;
         reset                : in  sl;
         clk156_out           : out sl;
         refclk_p             : in  sl;
         refclk_n             : in  sl;
         clk156_lock          : out sl;
         xgmii_txd            : in  slv(63 downto 0);
         xgmii_txc            : in  slv(7 downto 0);
         xgmii_rxd            : out slv(63 downto 0);
         xgmii_rxc            : out slv(7 downto 0);
         xaui_tx_l0_p         : out sl;
         xaui_tx_l0_n         : out sl;
         xaui_tx_l1_p         : out sl;
         xaui_tx_l1_n         : out sl;
         xaui_tx_l2_p         : out sl;
         xaui_tx_l2_n         : out sl;
         xaui_tx_l3_p         : out sl;
         xaui_tx_l3_n         : out sl;
         xaui_rx_l0_p         : in  sl;
         xaui_rx_l0_n         : in  sl;
         xaui_rx_l1_p         : in  sl;
         xaui_rx_l1_n         : in  sl;
         xaui_rx_l2_p         : in  sl;
         xaui_rx_l2_n         : in  sl;
         xaui_rx_l3_p         : in  sl;
         xaui_rx_l3_n         : in  sl;
         signal_detect        : in  slv(3 downto 0);
         debug                : out slv(5 downto 0);
         configuration_vector : in  slv(6 downto 0);
         status_vector        : out slv(7 downto 0));
   end component;

   signal phyStatus : slv(7 downto 0);
   signal phyDebug  : slv(5 downto 0);
   signal phyConfig : slv(6 downto 0);

   signal ethClk     : sl;
   signal ethClkRst  : sl;
   signal ethClkLock : sl;
   signal phyReset   : sl;
   signal phyReady   : sl;

   signal macConfig : EthMacConfigType;
   signal macStatus : EthMacStatusType;

   signal ethHeaderSize : slv(15 downto 0);
   signal txShift       : slv(3 downto 0);
   signal rxShift       : slv(3 downto 0);
   signal cfgPhyReset   : sl;
   signal onlineSync    : sl;

   signal xgmiiRxd : slv(63 downto 0);
   signal xgmiiRxc : slv(7 downto 0);
   signal xgmiiTxd : slv(63 downto 0);
   signal xgmiiTxc : slv(7 downto 0);

   signal gmiiRxDv : sl;
   signal gmiiRxEr : sl;
   signal gmiiRxd  : slv(7 downto 0);
   signal gmiiTxEn : sl;
   signal gmiiTxEr : sl;
   signal gmiiTxd  : slv(7 downto 0);

begin

   ----------
   -- Outputs
   ----------
   dmaClk         <= sysClk200;
   dmaClkRst      <= sysClk200Rst;
   userEthClk     <= ethClk;
   userEthClkRst  <= ethClkRst;
   userEthMacAddr <= macConfig.macAddress;

   -----------------
   -- Register Space
   -----------------
   U_Reg : entity work.RceEthernetReg
      generic map (
         TPD_G => TPD_G)
      port map (
         axilClk         => axilClk,
         axilClkRst      => axilClkRst,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         dmaClk          => sysClk200,
         dmaClkRst       => sysClk200Rst,
         ethClk          => ethClk,
         ethClkRst       => ethClkRst,
         phyStatus       => phyStatus,
         phyDebug        => phyDebug,
         phyConfig       => phyConfig,
         phyReset        => cfgPhyReset,
         ethHeaderSize   => ethHeaderSize,
         txShift         => txShift,
         rxShift         => rxShift,
         macConfig       => macConfig,
         macStatus       => macStatus,
         ipAddr          => userEthIpAddr);

   -------
   -- XAUI
   -------
   GEN_XAUI : if (ETH_TYPE_G = "XAUI") generate

      U_ZynqXaui : zynq_10g_xaui
         port map (
            dclk                 => axilClk,
            reset                => phyReset,
            clk156_out           => ethClk,
            refclk_p             => ethRefClkP,
            refclk_n             => ethRefClkM,
            clk156_lock          => ethClkLock,
            xgmii_txd            => xgmiiTxd,
            xgmii_txc            => xgmiiTxc,
            xgmii_rxd            => xgmiiRxd,
            xgmii_rxc            => xgmiiRxc,
            xaui_tx_l0_p         => ethTxP(0),
            xaui_tx_l0_n         => ethTxM(0),
            xaui_tx_l1_p         => ethTxP(1),
            xaui_tx_l1_n         => ethTxM(1),
            xaui_tx_l2_p         => ethTxP(2),
            xaui_tx_l2_n         => ethTxM(2),
            xaui_tx_l3_p         => ethTxP(3),
            xaui_tx_l3_n         => ethTxM(3),
            xaui_rx_l0_p         => ethRxP(0),
            xaui_rx_l0_n         => ethRxM(0),
            xaui_rx_l1_p         => ethRxP(1),
            xaui_rx_l1_n         => ethRxM(1),
            xaui_rx_l2_p         => ethRxP(2),
            xaui_rx_l2_n         => ethRxM(2),
            xaui_rx_l3_p         => ethRxP(3),
            xaui_rx_l3_n         => ethRxM(3),
            signal_detect        => (others => '1'),
            debug                => phyDebug,
            configuration_vector => phyConfig,
            status_vector        => phyStatus);

      U_EthClkRst : entity work.RstSync
         generic map (
            TPD_G           => TPD_G,
            IN_POLARITY_G   => '0',
            OUT_POLARITY_G  => '1',
            RELEASE_DELAY_G => 3)
         port map (
            clk      => ethClk,
            asyncRst => ethClkLock,
            syncRst  => ethClkRst);

      onlineSync <= dmaState.online;
      phyReset   <= cfgPhyReset or not onlineSync;

      phyReady <= phyStatus(7);

   end generate;

   U_RceMac : entity work.RceEthernetMac
      generic map (
         -- Generic Configurations
         TPD_G              => TPD_G,
         PHY_TYPE_G         => PHY_TYPE_C,
         RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
         SYNTH_MODE_G       => SYNTH_MODE_G,
         MEMORY_TYPE_G      => MEMORY_TYPE_G,
         -- User ETH Configurations
         UDP_SERVER_EN_G    => UDP_SERVER_EN_G,
         UDP_SERVER_SIZE_G  => UDP_SERVER_SIZE_G,
         UDP_SERVER_PORTS_G => UDP_SERVER_PORTS_G,
         BYP_EN_G           => BYP_EN_G,
         BYP_ETH_TYPE_G     => BYP_ETH_TYPE_G,
         VLAN_EN_G          => VLAN_EN_G,
         VLAN_SIZE_G        => VLAN_SIZE_G,
         VLAN_VID_G         => VLAN_VID_G)
      port map (
         -- DMA Interface
         dmaClk               => sysClk200,
         dmaClkRst            => sysClk200Rst,
         dmaState             => dmaState,
         dmaIbMaster          => dmaIbMaster,
         dmaIbSlave           => dmaIbSlave,
         dmaObMaster          => dmaObMaster,
         dmaObSlave           => dmaObSlave,
         -- Configuration/Status Interface
         phyReady             => phyReady,
         rxShift              => rxShift,
         txShift              => txShift,
         ethHeaderSize        => ethHeaderSize,
         macConfig            => macConfig,
         macStatus            => macStatus,
         -- PHY clock and Reset
         ethClk               => ethClk,
         ethClkRst            => ethClkRst,
         -- User ETH interface
         userEthUdpIbMaster   => userEthUdpIbMaster,
         userEthUdpIbSlave    => userEthUdpIbSlave,
         userEthUdpObMaster   => userEthUdpObMaster,
         userEthUdpObSlave    => userEthUdpObSlave,
         userEthBypIbMaster   => userEthBypIbMaster,
         userEthBypIbSlave    => userEthBypIbSlave,
         userEthBypObMaster   => userEthBypObMaster,
         userEthBypObSlave    => userEthBypObSlave,
         userEthVlanIbMasters => userEthVlanIbMasters,
         userEthVlanIbSlaves  => userEthVlanIbSlaves,
         userEthVlanObMasters => userEthVlanObMasters,
         userEthVlanObSlaves  => userEthVlanObSlaves,
         -- XGMII PHY Interface
         xgmiiRxd             => xgmiiRxd,
         xgmiiRxc             => xgmiiRxc,
         xgmiiTxd             => xgmiiTxd,
         xgmiiTxc             => xgmiiTxc,
         -- GMII PHY Interface
         gmiiRxDv             => gmiiRxDv,
         gmiiRxEr             => gmiiRxEr,
         gmiiRxd              => gmiiRxd,
         gmiiTxEn             => gmiiTxEn,
         gmiiTxEr             => gmiiTxEr,
         gmiiTxd              => gmiiTxd);

end mapping;
