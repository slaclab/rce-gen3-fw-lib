-------------------------------------------------------------------------------
-- File       : DtmCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-11-14
-- Last update: 2018-09-04
-------------------------------------------------------------------------------
-- Description: Common top level module for DTM
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

entity DtmCore is
   generic (
      TPD_G              : time                   := 1 ns;
      BUILD_INFO_G       : BuildInfoType;
      SIM_USER_ID_G      : natural range 0 to 100 := 1;
      SIMULATION_G       : boolean                := false;
      COB_GTE_C10_G      : boolean                := false;  -- true = COB with Mellanox ETH SW, false = COB with Fullcrum ETH SW
      ETH_TYPE_G         : string                 := "ZYNQ-GEM";  -- [ZYNQ-GEM, 1000BASE-KX, 10GBASE-KX4, 10GBASE-KR, 40GBASE-KR4] 
      RCE_DMA_MODE_G     : RceDmaModeType         := RCE_DMA_PPI_C;
      UDP_SERVER_EN_G    : boolean                := false;
      UDP_SERVER_SIZE_G  : positive               := 1;
      UDP_SERVER_PORTS_G : PositiveArray          := (0 => 8192);
      BYP_EN_G           : boolean                := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)       := x"AAAA";
      VLAN_EN_G          : boolean                := false;
      VLAN_SIZE_G        : positive range 1 to 8  := 1;
      VLAN_VID_G         : Slv12Array             := (0 => x"001"));
   port (
      -- I2C
      i2cSda               : inout sl;
      i2cScl               : inout sl;
      -- PCI Express
      pciRefClkP           : in    sl                                           := '0';  -- 7-series DTM only  
      pciRefClkM           : in    sl                                           := '1';  -- 7-series DTM only 
      pciRxP               : in    sl                                           := '0';  -- 7-series DTM only  
      pciRxM               : in    sl                                           := '1';  -- 7-series DTM only  
      pciTxP               : out   sl;
      pciTxM               : out   sl;
      pciResetL            : out   sl;
      -- COB Ethernet
      ethRxP               : in    sl;
      ethRxM               : in    sl;
      ethTxP               : out   sl;
      ethTxM               : out   sl;
      ethRefClkP           : in    sl                                           := '0';  -- Ultrascale+ DTM only  
      ethRefClkM           : in    sl                                           := '1';  -- Ultrascale+ DTM only      
      -- Clock Select
      clkSelA              : out   sl;
      clkSelB              : out   sl;
      -- Base Ethernet
      ethRxCtrl            : in    slv(1 downto 0)                              := "00";  -- 7-series DTM only  
      ethRxClk             : in    slv(1 downto 0)                              := "00";  -- 7-series DTM only  
      ethRxDataA           : in    Slv(1 downto 0)                              := "00";  -- 7-series DTM only  
      ethRxDataB           : in    Slv(1 downto 0)                              := "00";  -- 7-series DTM only  
      ethRxDataC           : in    Slv(1 downto 0)                              := "00";  -- 7-series DTM only  
      ethRxDataD           : in    Slv(1 downto 0)                              := "00";  -- 7-series DTM only  
      ethTxCtrl            : out   slv(1 downto 0);
      ethTxClk             : out   slv(1 downto 0);
      ethTxDataA           : out   Slv(1 downto 0);
      ethTxDataB           : out   Slv(1 downto 0);
      ethTxDataC           : out   Slv(1 downto 0);
      ethTxDataD           : out   Slv(1 downto 0);
      ethMdc               : out   Slv(1 downto 0);
      ethMio               : inout Slv(1 downto 0);
      ethResetL            : out   Slv(1 downto 0);
      -- IPMI
      dtmToIpmiP           : out   slv(1 downto 0);
      dtmToIpmiM           : out   slv(1 downto 0);
      -- Clocks
      sysClk125            : out   sl;
      sysClk125Rst         : out   sl;
      sysClk200            : out   sl;
      sysClk200Rst         : out   sl;
      -- External AXI-Lite Bus
      -- 0xA0000000 - 0xAFFFFFFF (COB_GTE_C10_G = False)
      -- 0x90000000 - 0x97FFFFFF (COB_GTE_C10_G = True)
      axiClk               : out   sl;
      axiClkRst            : out   sl;
      extAxilReadMaster    : out   AxiLiteReadMasterType;
      extAxilReadSlave     : in    AxiLiteReadSlaveType;
      extAxilWriteMaster   : out   AxiLiteWriteMasterType;
      extAxilWriteSlave    : in    AxiLiteWriteSlaveType;
      -- DMA Interfaces
      dmaClk               : in    slv(2 downto 0);
      dmaClkRst            : in    slv(2 downto 0);
      dmaState             : out   RceDmaStateArray(2 downto 0);
      dmaObMaster          : out   AxiStreamMasterArray(2 downto 0);
      dmaObSlave           : in    AxiStreamSlaveArray(2 downto 0);
      dmaIbMaster          : in    AxiStreamMasterArray(2 downto 0);
      dmaIbSlave           : out   AxiStreamSlaveArray(2 downto 0);
      -- User memory access (sysclk200 domain)
      userWriteSlave       : out   AxiWriteSlaveType;
      userWriteMaster      : in    AxiWriteMasterType                           := AXI_WRITE_MASTER_INIT_C;
      userReadSlave        : out   AxiReadSlaveType;
      userReadMaster       : in    AxiReadMasterType                            := AXI_READ_MASTER_INIT_C;
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

end DtmCore;

architecture mapping of DtmCore is

   constant SEL_REFCLK_C  : boolean := ite(XIL_DEVICE_C = "7SERIES", false, true);
   constant MEMORY_TYPE_C : string  := ite(XIL_DEVICE_C = "7SERIES", "block", "ultra");

   signal axilClock : sl;
   signal axilReset : sl;

   signal axiDmaClock : sl;
   signal axiDmaReset : sl;

   signal idmaClk      : slv(3 downto 0);
   signal idmaRst      : slv(3 downto 0);
   signal idmaState    : RceDmaStateArray(3 downto 0);
   signal idmaObMaster : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave  : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave  : AxiStreamSlaveArray(3 downto 0);

   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal armEthTx   : ArmEthTxArray(1 downto 0) := (others => ARM_ETH_TX_INIT_C);
   signal armEthRx   : ArmEthRxArray(1 downto 0) := (others => ARM_ETH_RX_INIT_C);
   signal armEthMode : slv(31 downto 0)          := (others => '0');

   signal gtRxP : slv(3 downto 0);
   signal gtRxN : slv(3 downto 0);
   signal gtTxP : slv(3 downto 0);
   signal gtTxN : slv(3 downto 0);

   signal ethRefClk     : sl;
   signal ethRefClkDiv2 : sl;
   signal stableClk     : sl;
   signal stableRst     : sl;

   signal clk312 : sl;
   signal clk200 : sl;
   signal clk156 : sl;
   signal clk125 : sl;
   signal clk62  : sl;

   signal rst312 : sl;
   signal rst200 : sl;
   signal rst156 : sl;
   signal rst125 : sl;
   signal rst62  : sl;

   signal locked : sl;

   signal pcieAxilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal pcieAxilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;
   signal pcieAxilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal pcieAxilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;
   signal ipciRefClkP         : sl                     := '0';
   signal ipciRefClkM         : sl                     := '1';
   signal ipciRxP             : sl                     := '0';
   signal ipciRxM             : sl                     := '1';
   signal ipciTxP             : sl                     := '0';
   signal ipciTxM             : sl                     := '1';
   signal ipciResetL          : sl                     := '1';

begin

   assert (ETH_TYPE_G = "ZYNQ-GEM") or (ETH_TYPE_G = "1000BASE-KX") or (ETH_TYPE_G = "10GBASE-KR")
      report "ETH_TYPE_G must be [ZYNQ-GEM, 1000BASE-KX, 10GBASE-KR]"
      severity failure;

   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   axiClk       <= axilClock;
   axiClkRst    <= axilReset;
   sysClk125    <= axilClock;
   sysClk125Rst <= axilReset;
   sysClk200    <= axiDmaClock;
   sysClk200Rst <= axiDmaReset;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk(2 downto 0);
   idmaRst(2 downto 0)      <= dmaClkRst(2 downto 0);
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
         SIM_USER_ID_G  => SIM_USER_ID_G,
         SIMULATION_G   => SIMULATION_G,
         MEMORY_TYPE_G  => MEMORY_TYPE_C,
         SEL_REFCLK_G   => SEL_REFCLK_C,
         BUILD_INFO_G   => BUILD_INFO_G,
         PCIE_EN_G      => COB_GTE_C10_G,
         RCE_DMA_MODE_G => RCE_DMA_MODE_G)
      port map (
         -- I2C Ports
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         -- Reference Clock
         ethRefClkP          => ethRefClkP,
         ethRefClkN          => ethRefClkM,
         ethRefClk           => ethRefClk,
         stableClk           => stableClk,
         stableRst           => stableRst,
         -- Top-level clocks and resets
         clk312              => clk312,
         rst312              => rst312,
         clk200              => clk200,
         rst200              => rst200,
         clk156              => clk156,
         rst156              => rst156,
         clk125              => clk125,
         rst125              => rst125,
         clk62               => clk62,
         rst62               => rst62,
         locked              => locked,
         -- DMA clock and reset
         axiDmaClk           => axiDmaClock,
         axiDmaRst           => axiDmaReset,
         -- AXI-Lite clock and reset
         axilClk             => axilClock,
         axilRst             => axilReset,
         -- External Axi Bus, (axilClk domain)
         -- 0xA0000000 - 0xAFFFFFFF (COB_MIN_C10_G = False)
         -- 0x90000000 - 0x97FFFFFF (COB_MIN_C10_G = True)         
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave,
         -- Core Axi Bus, 0xB0000000 - 0xBFFFFFFF  (axilClk domain)
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         -- PCIE Ports
         pciRefClkP          => ipciRefClkP,
         pciRefClkN          => ipciRefClkM,
         pciResetL           => ipciResetL,
         pcieRxP             => ipciRxP,
         pcieRxN             => ipciRxM,
         pcieTxP             => ipciTxP,
         pcieTxN             => ipciTxM,
         -- DMA Interfaces (dmaClk domain)
         dmaClk              => idmaClk,
         dmaClkRst           => idmaRst,
         dmaState            => idmaState,
         dmaObMaster         => idmaObMaster,
         dmaObSlave          => idmaObSlave,
         dmaIbMaster         => idmaIbMaster,
         dmaIbSlave          => idmaIbSlave,
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

   -- Hard code to 250Mhz
   clkSelA <= '1';
   clkSelB <= '1';

   U_C10_EN_G : if (COB_GTE_C10_G = true) and (XIL_DEVICE_C = "7SERIES") and (SIMULATION_G = false) generate
      ipciRefClkP <= pciRefClkP;
      ipciRefClkM <= pciRefClkM;
      ipciRxP     <= pciRxP;
      ipciRxM     <= pciRxM;
      pciTxP      <= ipciTxP;
      pciTxM      <= ipciTxM;
      pciResetL   <= ipciResetL;
   end generate;

   U_C10_DIS_G : if (COB_GTE_C10_G = false) and (XIL_DEVICE_C = "7SERIES") and (SIMULATION_G = false) generate

      ipciRefClkP <= '0';
      ipciRefClkM <= '0';
      ipciRxP     <= '0';
      ipciRxM     <= '0';

      -------------------------------------
      -- AXI Lite Crossbar
      -- Base: 0xB0000000 - 0xBFFFFFFF
      -------------------------------------
      U_AxiCrossbar : entity work.AxiLiteCrossbar
         generic map (
            TPD_G              => TPD_G,
            NUM_SLAVE_SLOTS_G  => 1,
            NUM_MASTER_SLOTS_G => 1,
            DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
            MASTERS_CONFIG_G   => (

               -- Channel 1 = 0xBC000000 - 0xBC00FFFF : PCI Express Registers
               0                  => (baseAddr => x"BC000000",
                     addrBits     => 16,
                     connectivity => x"FFFF")
               ))
         port map (
            axiClk              => axilClock,
            axiClkRst           => axilReset,
            sAxiWriteMasters(0) => coreAxilWriteMaster,
            sAxiWriteSlaves(0)  => coreAxilWriteSlave,
            sAxiReadMasters(0)  => coreAxilReadMaster,
            sAxiReadSlaves(0)   => coreAxilReadSlave,
            mAxiWriteMasters(0) => pcieAxilWriteMaster,
            mAxiWriteSlaves(0)  => pcieAxilWriteSlave,
            mAxiReadMasters(0)  => pcieAxilReadMaster,
            mAxiReadSlaves(0)   => pcieAxilReadSlave);


      --------------------------------------------------
      -- PCI Express : 0xBC00_0000 - 0xBC00_FFFF
      --------------------------------------------------
      U_ZynqPcieMaster : entity work.ZynqPcieMaster
         generic map (
            HSIO_MODE_G => false)
         port map (
            axiClk         => axilClock,
            axiClkRst      => axilReset,
            axiReadMaster  => pcieAxilReadMaster,
            axiReadSlave   => pcieAxilReadSlave,
            axiWriteMaster => pcieAxilWriteMaster,
            axiWriteSlave  => pcieAxilWriteSlave,
            pciRefClkP     => pciRefClkP,
            pciRefClkM     => pciRefClkM,
            pcieResetL     => pciResetL,
            pcieRxP        => pciRxP,
            pcieRxM        => pciRxM,
            pcieTxP        => pciTxP,
            pcieTxM        => pciTxM);

   end generate;

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------   
   U_Eth1gGen : if (ETH_TYPE_G = "ZYNQ-GEM") and (SIMULATION_G = false) generate

      -----------------------------------------------------------------------------      
      --                         ZYNQ GEM                                        --
      -----------------------------------------------------------------------------    
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceEthernet/rtl/zynq/RceEthGem.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceEthernet/rtl/zynquplus/RceEthGem.vhd
      -----------------------------------------------------------------------------     
      U_RceEthGem : entity work.RceEthGem
         generic map (
            TPD_G => TPD_G)
         port map (
            sysClk125 => clk125,
            sysRst125 => rst125,
            sysClk62  => clk62,
            sysRst62  => rst62,
            locked    => locked,
            stableClk => stableClk,
            stableRst => stableRst,
            -- ARM Interface
            armEthTx  => armEthTx(0),
            armEthRx  => armEthRx(0),
            -- Ethernet Lines
            gtRxP     => ethRxP,
            gtRxN     => ethRxM,
            gtTxP     => ethTxP,
            gtTxN     => ethTxM);

      userEthClk           <= clk125;
      userEthClkRst        <= rst125;
      userEthIpAddr        <= (others => '0');
      userEthMacAddr       <= (others => '0');
      userEthUdpIbSlave    <= AXI_STREAM_SLAVE_FORCE_C;
      userEthUdpObMaster   <= AXI_STREAM_MASTER_INIT_C;
      userEthBypIbSlave    <= AXI_STREAM_SLAVE_FORCE_C;
      userEthBypObMaster   <= AXI_STREAM_MASTER_INIT_C;
      userEthVlanIbSlaves  <= (others => AXI_STREAM_SLAVE_FORCE_C);
      userEthVlanObMasters <= (others => AXI_STREAM_MASTER_INIT_C);

      idmaClk(3)      <= clk125;
      idmaRst(3)      <= rst125;
      idmaObSlave(3)  <= AXI_STREAM_SLAVE_FORCE_C;
      idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;

      armEthMode <= x"00000001";

   end generate;

   U_Eth10gGen : if (ETH_TYPE_G /= "ZYNQ-GEM") and (SIMULATION_G = false) generate

      U_RceEthernet : entity work.RceEthernet
         generic map (
            -- Generic Configurations
            TPD_G              => TPD_G,
            RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
            ETH_TYPE_G         => ETH_TYPE_G,
            MEMORY_TYPE_G      => MEMORY_TYPE_C,
            EN_JUMBO_G         => true,
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
            -- Clocks and resets
            clk312               => clk312,
            rst312               => rst312,
            clk200               => clk200,
            rst200               => rst200,
            clk156               => clk156,
            rst156               => rst156,
            clk125               => clk125,
            rst125               => rst125,
            clk62                => clk62,
            rst62                => rst62,
            stableClk            => stableClk,
            stableRst            => stableRst,
            -- PPI Interface
            dmaClk               => idmaClk(3),
            dmaRst               => idmaRst(3),
            dmaState             => idmaState(3),
            dmaIbMaster          => idmaIbMaster(3),
            dmaIbSlave           => idmaIbSlave(3),
            dmaObMaster          => idmaObMaster(3),
            dmaObSlave           => idmaObSlave(3),
            -- User ETH interface
            userEthClk           => userEthClk,
            userEthRst           => userEthClkRst,
            userEthIpAddr        => userEthIpAddr,
            userEthMacAddr       => userEthMacAddr,
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
            -- AXI-Lite Buses
            axilClk              => axilClock,
            axilRst              => axilReset,
            axilWriteMaster      => coreAxilWriteMaster,
            axilWriteSlave       => coreAxilWriteSlave,
            axilReadMaster       => coreAxilReadMaster,
            axilReadSlave        => coreAxilReadSlave,
            -- Ref Clock
            ethRefClk            => ethRefClk,
            -- Ethernet Lines
            ethRxP(0)            => ethRxP,
            ethRxP(3 downto 1)   => "000",
            ethRxN(0)            => ethRxM,
            ethRxN(3 downto 1)   => "111",
            ethTxP(0)            => ethTxP,
            ethTxP(3 downto 1)   => open,
            ethTxN(0)            => ethTxM,
            ethTxN(3 downto 1)   => open);

      process (axilClock)
      begin
         if rising_edge(axilClock) then
            case ETH_TYPE_G is
               when "ZYNQ-GEM"    => armEthMode <= x"00000001";
               when "1000BASE-KX" => armEthMode <= x"00000002";
               when "10GBASE-KR"  => armEthMode <= x"0000000A";
               when others        => armEthMode <= x"00000000";
            end case;
         end if;
      end process;

   end generate;

   --------------------------------------------------
   -- Unused
   --------------------------------------------------
   dtmToIpmiP(0) <= 'Z';
   dtmToIpmiP(1) <= 'Z';
   dtmToIpmiM(0) <= 'Z';
   dtmToIpmiM(1) <= 'Z';

end mapping;
