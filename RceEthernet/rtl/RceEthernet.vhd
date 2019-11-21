-------------------------------------------------------------------------------
-- File       : RceEthernet.vhd
-- Company    : SLAC National Accelerator Laboratory
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


library surf;
use surf.StdRtlPkg.all;
use surf.EthMacPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.PpiPkg.all;
use rce_gen3_fw_lib.RceG3Pkg.all;

entity RceEthernet is
   generic (
      -- Generic Configurations
      TPD_G              : time                  := 1 ns;
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_AXISV2_C;
      ETH_TYPE_G         : string                := "1000BASE-KX";  -- [1000BASE-KX, 10GBASE-KX4, 10GBASE-KR, 40GBASE-KR4] 
      SYNTH_MODE_G       : string                := "xpm";
      MEMORY_TYPE_G      : string                := "block";
      EN_JUMBO_G         : boolean               := true;
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
      clk312               : in  sl;
      rst312               : in  sl;
      clk200               : in  sl;
      rst200               : in  sl;
      clk156               : in  sl;
      rst156               : in  sl;
      clk125               : in  sl;
      rst125               : in  sl;
      clk62                : in  sl;
      rst62                : in  sl;
      stableClk            : in  sl;    -- free-running clock reference
      stableRst            : in  sl;
      -- PPI Interface
      dmaClk               : out sl;
      dmaRst               : out sl;
      dmaState             : in  RceDmaStateType;
      dmaIbMaster          : out AxiStreamMasterType;
      dmaIbSlave           : in  AxiStreamSlaveType;
      dmaObMaster          : in  AxiStreamMasterType;
      dmaObSlave           : out AxiStreamSlaveType;
      -- User ETH interface
      userEthClk           : out sl;
      userEthRst           : out sl;
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
      axilRst              : in  sl;
      axilWriteMaster      : in  AxiLiteWriteMasterType;
      axilWriteSlave       : out AxiLiteWriteSlaveType;
      axilReadMaster       : in  AxiLiteReadMasterType;
      axilReadSlave        : out AxiLiteReadSlaveType;
      -- Ref Clock
      ethRefClk            : in  sl;
      -- Ethernet Lines
      ethRxP               : in  slv(3 downto 0) := x"0";
      ethRxN               : in  slv(3 downto 0) := x"F";
      ethTxP               : out slv(3 downto 0) := x"0";
      ethTxN               : out slv(3 downto 0) := x"F");
end RceEthernet;

architecture mapping of RceEthernet is

   constant PHY_TYPE_C : string :=
      ite(ETH_TYPE_G = "1000BASE-KX", "GMII",
          ite(ETH_TYPE_G = "10GBASE-KX4", "XGMII",
              ite(ETH_TYPE_G = "10GBASE-KR", "XGMII",
                  ite(ETH_TYPE_G = "40GBASE-KR4", "XLGMII",
                      "UNDEFINED"))));

   signal phyStatus : slv(7 downto 0);
   signal phyDebug  : slv(5 downto 0);
   signal phyConfig : slv(6 downto 0);

   signal dmaClock : sl;
   signal dmaReset : sl;

   signal ethClk     : sl;
   signal ethRst     : sl;
   signal ethClkLock : sl;
   signal phyReset   : sl;
   signal phyReady   : sl;

   signal macConfig : EthMacConfigType;
   signal macStatus : EthMacStatusType;

   signal ethHeaderSize : slv(15 downto 0);
   signal txShift       : slv(3 downto 0);
   signal rxShift       : slv(3 downto 0);
   signal cfgPhyReset   : sl;

   signal xlgmiiRxd : slv(127 downto 0);
   signal xlgmiiRxc : slv(15 downto 0);
   signal xlgmiiTxd : slv(127 downto 0);
   signal xlgmiiTxc : slv(15 downto 0);

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

   assert (ETH_TYPE_G = "ZYNQ-GEM") or (ETH_TYPE_G = "1000BASE-KX") or (ETH_TYPE_G = "10GBASE-KX4") or (ETH_TYPE_G = "10GBASE-KR") or (ETH_TYPE_G = "40GBASE-KR4")
      report "ETH_TYPE_G must be [ZYNQ-GEM, 1000BASE-KX, 10GBASE-KX4, 10GBASE-KR, 40GBASE-KR4]"
      severity failure;

   ----------
   -- Outputs
   ----------   
   dmaClk         <= dmaClock;
   dmaRst         <= dmaReset;
   dmaClock       <= clk200;
   dmaReset       <= rst200;
   userEthClk     <= ethClk;
   userEthRst     <= ethRst;
   userEthMacAddr <= macConfig.macAddress;

   -----------------
   -- Register Space
   -----------------
   U_Reg : entity rce_gen3_fw_lib.RceEthernetReg
      generic map (
         TPD_G => TPD_G)
      port map (
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         dmaClk          => dmaClock,
         dmaRst          => dmaReset,
         ethClk          => ethClk,
         ethRst          => ethRst,
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

   phyReset <= cfgPhyReset or not dmaState.online;

   --------------
   -- 1000BASE-KX
   --------------
   GEN_1000Base : if (ETH_TYPE_G = "1000BASE-KX") generate

      ethClk <= clk125;
      ethRst <= rst125;

      --------------------------------------------------------------------------------      
      --                         1000BASE-KX                                        --
      --------------------------------------------------------------------------------    
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceEthernet/rtl/zynq/Rce1GbE1lane.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceEthernet/rtl/zynquplus/Rce1GbE1lane.vhd
      --------------------------------------------------------------------------------        
      U_Eth : entity rce_gen3_fw_lib.Rce1GbE1lane
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Misc. Signals
            extRst    => phyReset,
            sysClk62  => clk62,
            sysClk125 => clk125,
            sysRst125 => rst125,
            phyReady  => phyReady,
            phyStatus => phyStatus,
            phyDebug  => phyDebug,
            phyConfig => phyConfig,
            stableClk => stableClk,
            stableRst => stableRst,
            -- PHY Interface
            gmiiRxDv  => gmiiRxDv,
            gmiiRxEr  => gmiiRxEr,
            gmiiRxd   => gmiiRxd,
            gmiiTxEn  => gmiiTxEn,
            gmiiTxEr  => gmiiTxEr,
            gmiiTxd   => gmiiTxd,
            -- MGT Ports
            gtTxP     => ethTxP(0),
            gtTxN     => ethTxN(0),
            gtRxP     => ethRxP(0),
            gtRxN     => ethRxN(0));

   end generate;

   --------------
   -- 10GBASE-KX4
   --------------
   GEN_XAUI : if (ETH_TYPE_G = "10GBASE-KX4") generate

      --------------------------------------------------------------------------------      
      --                    10GBASE-KX4 (A.K.A. XAUI)                               --
      --------------------------------------------------------------------------------    
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceEthernet/rtl/zynq/Rce10GbE4lane.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceEthernet/rtl/zynquplus/Rce10GbE4lane.vhd
      --------------------------------------------------------------------------------      
      U_Eth : entity rce_gen3_fw_lib.Rce10GbE4lane
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Misc. Signals
            extRst    => phyReset,
            dclk      => axilClk,
            phyClk    => ethClk,
            phyRst    => ethRst,
            phyReady  => phyReady,
            phyStatus => phyStatus,
            phyDebug  => phyDebug,
            phyConfig => phyConfig,
            stableClk => stableClk,
            stableRst => stableRst,
            -- PHY Interface
            xgmiiRxd  => xgmiiRxd,
            xgmiiRxc  => xgmiiRxc,
            xgmiiTxd  => xgmiiTxd,
            xgmiiTxc  => xgmiiTxc,
            -- MGT Ports
            gtRefClk  => ethRefClk,
            gtTxP     => ethTxP,
            gtTxN     => ethTxN,
            gtRxP     => ethRxP,
            gtRxN     => ethRxN);

   end generate;

   -------------
   -- 10GBASE-KR
   -------------
   GEN_10GBase : if (ETH_TYPE_G = "10GBASE-KR") generate

      --------------------------------------------------------------------------------      
      --                         10GBASE-KR                                         --
      --------------------------------------------------------------------------------    
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceEthernet/rtl/zynq/Rce10GbE1lane.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceEthernet/rtl/zynquplus/Rce10GbE1lane.vhd
      --------------------------------------------------------------------------------      
      U_Eth : entity rce_gen3_fw_lib.Rce10GbE1lane
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Misc. Signals
            extRst    => phyReset,
            coreClk   => clk156,
            coreRst   => rst156,
            phyClk    => ethClk,
            phyRst    => ethRst,
            phyReady  => phyReady,
            phyStatus => phyStatus,
            phyDebug  => phyDebug,
            phyConfig => phyConfig,
            stableClk => stableClk,
            stableRst => stableRst,
            -- PHY Interface
            xgmiiRxd  => xgmiiRxd,
            xgmiiRxc  => xgmiiRxc,
            xgmiiTxd  => xgmiiTxd,
            xgmiiTxc  => xgmiiTxc,
            -- MGT Ports
            gtRefClk  => ethRefClk,
            gtTxP     => ethTxP(0),
            gtTxN     => ethTxN(0),
            gtRxP     => ethRxP(0),
            gtRxN     => ethRxN(0));

   end generate;

   --------------
   -- 40GBASE-KR4
   --------------
   GEN_40GBase : if (ETH_TYPE_G = "40GBASE-KR4") generate

      --------------------------------------------------------------------------------      
      --                         40GBASE-KR4                                        --
      --------------------------------------------------------------------------------    
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceEthernet/rtl/zynq/Rce40GbE4lane.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceEthernet/rtl/zynquplus/Rce40GbE4lane.vhd
      --------------------------------------------------------------------------------    
      U_Eth : entity rce_gen3_fw_lib.Rce40GbE4lane
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Misc. Signals
            phyClk    => ethClk,
            phyRst    => ethRst,
            phyReady  => phyReady,
            phyStatus => phyStatus,
            phyDebug  => phyDebug,
            phyConfig => phyConfig,
            stableClk => stableClk,
            stableRst => stableRst,
            -- PHY Interface
            xlgmiiRxd => xlgmiiRxd,
            xlgmiiRxc => xlgmiiRxc,
            xlgmiiTxd => xlgmiiTxd,
            xlgmiiTxc => xlgmiiTxc,
            -- MGT Ports
            gtRefClk  => ethRefClk,
            gtTxP     => ethTxP,
            gtTxN     => ethTxN,
            gtRxP     => ethRxP,
            gtRxN     => ethRxN);

   end generate;

   U_RceMac : entity rce_gen3_fw_lib.RceEthernetMac
      generic map (
         -- Generic Configurations
         TPD_G              => TPD_G,
         PHY_TYPE_G         => PHY_TYPE_C,
         RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
         SYNTH_MODE_G       => SYNTH_MODE_G,
         MEMORY_TYPE_G      => MEMORY_TYPE_G,
         EN_JUMBO_G         => EN_JUMBO_G,
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
         dmaClk               => dmaClock,
         dmaRst               => dmaReset,
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
         ethRst               => ethRst,
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
         -- XLGMII PHY Interface
         xlgmiiRxd            => xlgmiiRxd,
         xlgmiiRxc            => xlgmiiRxc,
         xlgmiiTxd            => xlgmiiTxd,
         xlgmiiTxc            => xlgmiiTxc,
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
