-------------------------------------------------------------------------------
-- File       : DpmCore.vhd
-- Company    : SLAC National Accelerator Laboratory
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


library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DpmCore is
   generic (
      TPD_G              : time                        := 1 ns;
      BUILD_INFO_G       : BuildInfoType;
      SIMULATION_G       : boolean                     := false;
      SIM_MEM_PORT_NUM_G : natural range 1024 to 49151 := 9000;
      SIM_DMA_PORT_NUM_G : natural range 1024 to 49151 := 9002;
      SIM_DMA_CHANNELS_G : natural range 0 to 4        := 3;
      SIM_DMA_TDESTS_G   : natural range 0 to 256      := 256;
      ETH_TYPE_G         : string                      := "ZYNQ-GEM";  -- [ZYNQ-GEM, 1000BASE-KX, 10GBASE-KX4, 10GBASE-KR, 40GBASE-KR4] 
      RCE_DMA_MODE_G     : RceDmaModeType              := RCE_DMA_PPI_C;
      AXI_ST_COUNT_G     : natural range 3 to 4        := 3;
      UDP_SERVER_EN_G    : boolean                     := false;
      UDP_SERVER_SIZE_G  : positive                    := 1;
      UDP_SERVER_PORTS_G : PositiveArray               := (0 => 8192);
      BYP_EN_G           : boolean                     := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)            := x"AAAA";
      VLAN_EN_G          : boolean                     := false;
      VLAN_SIZE_G        : positive range 1 to 8       := 1;
      VLAN_VID_G         : Slv12Array                  := (0 => x"001"));
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

architecture mapping of DpmCore is

   constant MEMORY_TYPE_C : string := ite(XIL_DEVICE_C = "7SERIES", "block", "ultra");

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

   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_DECERR_C;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C;

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

begin

   --------------------------------------------------
   -- Assertions to validate the configuration
   --------------------------------------------------

   assert (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C and AXI_ST_COUNT_G = 4) or RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C
      report "Only AXI_ST_COUNT_G = 4 is supported when RCE_DMA_MODE_G = RCE_DMA_Q4X2_C"
      severity failure;
   assert (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C and ETH_TYPE_G = "ZYNQ-GEM") or RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C
      report "RCE_DMA_MODE_G = RCE_DMA_Q4X2_C is not supported when ETH_10G_EN_G = true"
      severity failure;

   -- more assertion checks should be added e.g. ETH_10G_EN_G = true only with RCE_DMA_MODE_G = RCE_DMA_PPI_C ???
   -- my 3rd assertion can be removed when the above check is added

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
   U_RceG3Top : entity rce_gen3_fw_lib.RceG3Top
      generic map (
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         SIM_MEM_PORT_NUM_G => SIM_MEM_PORT_NUM_G,
         SIM_DMA_PORT_NUM_G => SIM_DMA_PORT_NUM_G,
         SIM_DMA_CHANNELS_G => SIM_DMA_CHANNELS_G,
         SIM_DMA_TDESTS_G   => SIM_DMA_TDESTS_G,
         MEMORY_TYPE_G      => MEMORY_TYPE_C,
         SEL_REFCLK_G       => true,    -- true = ETH ref
         BUILD_INFO_G       => BUILD_INFO_G,
         RCE_DMA_MODE_G     => RCE_DMA_MODE_G)
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
         axilClk             => iAxilClk,
         axilRst             => iAxilRst,
         -- External Axi Bus, 0xA0000000 - 0xAFFFFFFF  (axilClk domain)
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave,
         -- Core Axi Bus, 0xB0000000 - 0xBFFFFFFF  (axilClk domain)
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
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

   -- Osc 0 = 156.25
   clkSelA(0) <= '0';
   clkSelB(0) <= '0';

   -- Osc 1 = 250
   clkSelA(1) <= '1';
   clkSelB(1) <= '1';

   ----------------------------------------------------------------------------      
   --                         ETH GT Mapping                                 --
   ----------------------------------------------------------------------------      
   -- This VHDL wrapper is determined by the ZYNQ family type
   -- Zynq-7000:        rce-gen3-fw-lib/RceG3/hdl/zynq/RceEthGtMapping.vhd
   -- Zynq Ultrascale+: rce-gen3-fw-lib/RceG3/hdl/zynquplus/RceEthGtMapping.vhd
   ----------------------------------------------------------------------------      
   U_RceEthGem : entity rce_gen3_fw_lib.RceEthGtMapping
      generic map (
         TPD_G      => TPD_G,
         ETH_TYPE_G => ETH_TYPE_G)
      port map (
         stableClk => stableClk,
         ethRxP    => ethRxP,
         ethRxN    => ethRxM,
         ethTxP    => ethTxP,
         ethTxN    => ethTxM,
         gtRxP     => gtRxP,
         gtRxN     => gtRxN,
         gtTxP     => gtTxP,
         gtTxN     => gtTxN);

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
      U_RceEthGem : entity rce_gen3_fw_lib.RceEthGem
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
            gtRxP     => gtRxP(0),
            gtRxN     => gtRxN(0),
            gtTxP     => gtTxP(0),
            gtTxN     => gtTxN(0));

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

      U_Q4X2DmaGen : if (RCE_DMA_MODE_G = RCE_DMA_Q4X2_C) generate
         idmaClk(3)                    <= dmaClk(AXI_ST_COUNT_G-1);
         idmaRst(3)                    <= dmaClkRst(AXI_ST_COUNT_G-1);
         idmaObSlave(3)                <= dmaObSlave(AXI_ST_COUNT_G-1);
         idmaIbMaster(3)               <= dmaIbMaster(AXI_ST_COUNT_G-1);
         dmaState(AXI_ST_COUNT_G-1)    <= idmaState(3);
         dmaObMaster(AXI_ST_COUNT_G-1) <= idmaObMaster(3);
         dmaIbSlave(AXI_ST_COUNT_G-1)  <= idmaIbSlave(3);
      end generate;
      U_NoQ4X2DmaGen : if (RCE_DMA_MODE_G /= RCE_DMA_Q4X2_C) generate
         idmaClk(3)      <= clk125;
         idmaRst(3)      <= rst125;
         idmaObSlave(3)  <= AXI_STREAM_SLAVE_FORCE_C;
         idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;
      end generate;

   end generate;

   U_Eth10gGen : if (ETH_TYPE_G /= "ZYNQ-GEM") and (SIMULATION_G = false) generate

      U_RceEthernet : entity rce_gen3_fw_lib.RceEthernet
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
            axilClk              => iAxilClk,
            axilRst              => iAxilRst,
            axilWriteMaster      => coreAxilWriteMaster,
            axilWriteSlave       => coreAxilWriteSlave,
            axilReadMaster       => coreAxilReadMaster,
            axilReadSlave        => coreAxilReadSlave,
            -- Ref Clock
            ethRefClk            => ethRefClk,
            -- Ethernet Lines
            ethRxP               => gtRxP,
            ethRxN               => gtRxN,
            ethTxP               => gtTxP,
            ethTxN               => gtTxN);

   end generate;

   armEthMode <= X"00000001" when ETH_TYPE_G = "ZYNQ-GEM" else
                 X"00000002" when ETH_TYPE_G = "1000BASE-KX" else
                 X"03030303" when ETH_TYPE_G = "10GBASE-KX4" else
                 X"0000000A" when ETH_TYPE_G = "10GBASE-KR" else
                 X"0A0A0A0A" when ETH_TYPE_G = "40GBASE-KR4" else
                 X"00000000";

end mapping;
