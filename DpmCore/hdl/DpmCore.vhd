-------------------------------------------------------------------------------
-- Title      : 
-------------------------------------------------------------------------------
-- File       : DpmCore.vhd
-- Author     : Ryan Herbst <rherbst@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-11-14
-- Last update: 2018-07-26
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
      ETH_TYPE_G         : string                := "ZYNQ-GEM";  -- [ZYNQ-GEM, 1000BASE-KX, 10GBASE-KX4, 10GBASE-KR, 40GBASE-KR4] 
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_PPI_C;
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

architecture STRUCTURE of DpmCore is

   signal iaxiClk : sl;
   signal iaxiRst : sl;

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
   assert (ETH_TYPE_G = "ZYNQ-GEM") or (ETH_TYPE_G = "1000BASE-KX") or (ETH_TYPE_G = "10GBASE-KX4") or (ETH_TYPE_G = "10GBASE-KR") or (ETH_TYPE_G = "40GBASE-KR4")
      report "ETH_TYPE_G must be [ZYNQ-GEM, 1000BASE-KX, 10GBASE-KX4, 10GBASE-KR, 40GBASE-KR4]"
      severity failure;

   -- more assertion checks should be added e.g. ETH_10G_EN_G = true only with RCE_DMA_MODE_G = RCE_DMA_PPI_C ???
   -- my 3rd assertion can be removed when the above check is added

   --------------------------------------------------
   -- Inputs/Outputs
   --------------------------------------------------
   axiClk       <= iaxiClk;
   axiClkRst    <= iaxiRst;
   sysClk125    <= clk125;
   sysClk125Rst <= rst125;
   sysClk200    <= clk200;
   sysClk200Rst <= rst200;

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
         BUILD_INFO_G   => BUILD_INFO_G,
         RCE_DMA_MODE_G => RCE_DMA_MODE_G)
      port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiRst,
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave,
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         dmaClk              => idmaClk,
         dmaClkRst           => idmaRst,
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

   -- Osc 0 = 156.25
   clkSelA(0) <= '0';
   clkSelB(0) <= '0';

   -- Osc 1 = 250
   clkSelA(1) <= '1';
   clkSelB(1) <= '1';

   ------------------
   -- Reference Clock
   ------------------
   U_IBUFDS_GTE2 : IBUFDS_GTE2
      port map (
         I     => ethRefClkP,
         IB    => ethRefClkM,
         CEB   => '0',
         ODIV2 => ethRefClkDiv2,
         O     => ethRefClk);

   U_BUFG : BUFG
      port map (
         I => ethRefClkDiv2,
         O => stableClk);

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => stableClk,
         rstOut => stableRst);

   -----------------
   -- Clock Managers
   -----------------   
   U_MMCM : entity work.ClockManager7
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => false,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 5,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 12.8,    -- 78.125
         DIVCLK_DIVIDE_G    => 1,       -- 78.125 MHz = (78.125 MHz/1)
         CLKFBOUT_MULT_F_G  => 16.0,
         CLKOUT0_DIVIDE_F_G => 6.25,    -- 200 MHz = (1.25 GHz/6.25)   
         CLKOUT1_DIVIDE_G   => 4,       -- 312.5 MHz = (1.25 GHz/4)    
         CLKOUT2_DIVIDE_G   => 8,       -- 156.25 MHz=(1.25GHz/8)             
         CLKOUT3_DIVIDE_G   => 10,      -- 125 MHz = (1.25 GHz/10)    
         CLKOUT4_DIVIDE_G   => 20)      -- 62.5 MHz = (1.25 GHz/20)    
      port map(
         clkIn     => stableClk,
         rstIn     => stableRst,
         -- Clock Outputs
         clkOut(0) => clk200,
         clkOut(1) => clk312,
         clkOut(2) => clk156,
         clkOut(3) => clk125,
         clkOut(4) => clk62,
         -- Reset Outputs
         rstOut(0) => rst200,
         rstOut(1) => rst312,
         rstOut(2) => rst156,
         rstOut(3) => rst125,
         rstOut(4) => rst62,
         -- Status
         locked    => locked);

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_Eth1gGen : if (ETH_TYPE_G = "ZYNQ-GEM") generate

      U_RceEthGem : entity work.RceEthGem
         generic map (
            TPD_G => TPD_G)
         port map (
            sysClk125 => clk125,
            sysRst125 => rst125,
            sysClk62  => clk62,
            sysRst62  => rst62,
            locked    => locked,
            -- ARM Interface
            armEthTx  => armEthTx(0),
            armEthRx  => armEthRx(0),
            -- Ethernet Lines
            ethRxP    => ethRxP(0),
            ethRxM    => ethRxM(0),
            ethTxP    => ethTxP(0),
            ethTxM    => ethTxM(0));

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

      ethTxP(3 downto 1) <= (others => '0');
      ethTxM(3 downto 1) <= (others => '0');

   end generate;

   U_Eth10gGen : if (ETH_TYPE_G /= "ZYNQ-GEM") generate

      U_RceEthernet : entity work.RceEthernet
         generic map (
            -- Generic Configurations
            TPD_G              => TPD_G,
            RCE_DMA_MODE_G     => RCE_DMA_MODE_G,
            ETH_TYPE_G         => ETH_TYPE_G,
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
            clk200               => clk200,
            rst200               => rst200,
            clk156               => clk156,
            rst156               => rst156,
            clk125               => clk125,
            rst125               => rst125,
            clk62                => clk62,
            rst62                => rst62,
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
            axilClk              => iaxiClk,
            axilRst              => iaxiRst,
            axilWriteMaster      => coreAxilWriteMaster,
            axilWriteSlave       => coreAxilWriteSlave,
            axilReadMaster       => coreAxilReadMaster,
            axilReadSlave        => coreAxilReadSlave,
            -- Ref Clock
            ethRefClk            => ethRefClk,
            -- Ethernet Lines
            ethRxP               => ethRxP,
            ethRxN               => ethRxM,
            ethTxP               => ethTxP,
            ethTxN               => ethTxM);

   end generate;

   process (iaxiClk)
   begin
      if rising_edge(iaxiClk) then
         case ETH_TYPE_G is
            when "ZYNQ-GEM"    => armEthMode <= x"00000001";
            when "1000BASE-KX" => armEthMode <= x"00000001";
            when "10GBASE-KX4" => armEthMode <= x"03030303";
            when "10GBASE-KR"  => armEthMode <= x"0000000A";
            when "40GBASE-KR4" => armEthMode <= x"0A0A0A0A";
            when others        => armEthMode <= x"00000000";
         end case;
      end if;
   end process;

end architecture STRUCTURE;
