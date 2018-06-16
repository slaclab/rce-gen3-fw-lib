-------------------------------------------------------------------------------
-- File       : DuneDpmCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2013-11-14
-- Last update: 2018-06-16
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
      -- Application ETH Tap
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
      sysClk156            : out   sl;
      sysRst156            : out   sl;
      sysClk200            : out   sl;
      sysRst200            : out   sl;
      sysClk312            : out   sl;
      sysRst312            : out   sl;
      gtRefClk156          : out   sl;
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
      dmaClk               : in    slv(2 downto 0);
      dmaRst               : in    slv(2 downto 0);
      dmaObMasters         : out   AxiStreamMasterArray(2 downto 0);
      dmaObSlaves          : in    AxiStreamSlaveArray(2 downto 0);
      dmaIbMasters         : in    AxiStreamMasterArray(2 downto 0);
      dmaIbSlaves          : out   AxiStreamSlaveArray(2 downto 0);
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
      userEthVlanObSlaves  : in    AxiStreamSlaveArray(VLAN_SIZE_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C));
end DuneDpmCore;

architecture mapping of DuneDpmCore is

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

   signal armEthTx   : ArmEthTxArray(1 downto 0);
   signal armEthRx   : ArmEthRxArray(1 downto 0);
   signal armEthMode : slv(31 downto 0);

   signal sgmiiRx : slv(3 downto 0);
   signal sgmiiTx : slv(3 downto 0);

   signal ethClk  : sl;
   signal iaxiClk : sl;
   signal refClk  : sl;
   signal clk625  : sl;
   signal clk312  : sl;
   signal clk200  : sl;
   signal clk156  : sl;
   signal clk125  : sl;
   signal rst62   : sl;

   signal locked  : sl;
   signal iaxiRst : sl;
   signal refRst  : sl;
   signal rst625  : sl;
   signal rst312  : sl;
   signal rst200  : sl;
   signal rst156  : sl;
   signal rst125  : sl;
   signal clk62   : sl;

   -- Prevent optimizing out the IBUFDS/OBUFDS
   attribute KEEP_HIERARCHY                                                   : string;
   attribute KEEP_HIERARCHY of U_sgmiiRx0, U_sgmiiRx1, U_sgmiiRx2, U_sgmiiRx3 : label is "TRUE";
   attribute KEEP_HIERARCHY of U_sgmiiTx0, U_sgmiiTx1, U_sgmiiTx2, U_sgmiiTx3 : label is "TRUE";

begin

   axilClk <= iaxiClk;
   axilRst <= iaxiRst;

   sysClk125 <= clk125;
   sysRst125 <= rst125;

   sysClk156 <= clk156;
   sysRst156 <= rst156;

   sysClk200 <= clk200;
   sysRst200 <= rst200;

   sysClk312 <= clk312;
   sysRst312 <= rst312;

   -------------
   -- PL DDR MEM
   -------------
   U_Mig : entity work.MigCore
      generic map (
         TPD_G => TPD_G)
      port map (
         extRst         => rst156,
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

   ------------------
   -- Reference Clock
   ------------------
   U_IBUFDS : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => ethRefClkP,
         IB    => ethRefClkN,
         CEB   => '0',
         ODIV2 => ethClk,
         O     => gtRefClk156);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => ethClk,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => refClk);

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => refClk,
         rstOut => refRst);

   -----------------
   -- Clock Managers
   -----------------   
   U_MMCM : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 6,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,     -- 156.25 MHz
         DIVCLK_DIVIDE_G    => 1,       -- 156.25 MHz = (156.25 MHz/1)
         CLKFBOUT_MULT_F_G  => 8.0,
         CLKOUT0_DIVIDE_F_G => 6.25,    -- 200 MHz = (1.25 GHz/6.25)   
         CLKOUT1_DIVIDE_G   => 2,       -- 625 MHz = (1.25 GHz/2)    
         CLKOUT2_DIVIDE_G   => 4,       -- 312.5 MHz = (1.25 GHz/4)    
         CLKOUT3_DIVIDE_G   => 8,       -- 156.25 MHz=(1.25GHz/8)             
         CLKOUT4_DIVIDE_G   => 10,      -- 125 MHz = (1.25 GHz/10)    
         CLKOUT5_DIVIDE_G   => 20)      -- 62.5 MHz = (1.25 GHz/20)    
      port map(
         clkIn     => refClk,
         rstIn     => refRst,
         -- Clock Outputs
         clkOut(0) => clk200,
         clkOut(1) => clk625,
         clkOut(2) => clk312,
         clkOut(3) => clk156,
         clkOut(4) => clk125,
         clkOut(5) => clk62,
         -- Reset Outputs
         rstOut(0) => rst200,
         rstOut(1) => rst625,
         rstOut(2) => rst312,
         rstOut(3) => rst156,
         rstOut(4) => rst125,
         rstOut(5) => rst62,
         -- Status
         locked    => locked);

   --------------------------------------
   -- External DMA Inputs/Outputs Mapping
   --------------------------------------
   idmaClk(2 downto 0)      <= dmaClk(2 downto 0);
   idmaRst(2 downto 0)      <= dmaRst(2 downto 0);
   dmaObMasters(2 downto 0) <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlaves(2 downto 0);
   idmaIbMaster(2 downto 0) <= dmaIbMasters(2 downto 0);
   dmaIbSlaves(2 downto 0)  <= idmaIbSlave(2 downto 0);

   -----------
   -- RCE Core
   -----------
   U_RceG3Top : entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         BUILD_INFO_G   => BUILD_INFO_G,
         XIL_DEVICE_G   => "ULTRASCALE",
         RCE_DMA_MODE_G => RCE_DMA_AXISV2_C)
      port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiRst,
         extAxilReadMaster   => axilReadMaster,
         extAxilReadSlave    => axilReadSlave,
         extAxilWriteMaster  => axilWriteMaster,
         extAxilWriteSlave   => axilWriteSlave,
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
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode);

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------  
   armEthMode <= x"00000101";           -- 1 GbE on [lane2,lane0]

   U_Lane0 : entity work.ZynqEthernet
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
         ethRxM    => ethRxN(0),
         ethTxP    => ethTxP(0),
         ethTxM    => ethTxN(0));

   U_Lane2 : entity work.ZynqEthernet
      generic map (
         TPD_G => TPD_G)
      port map (
         sysClk125 => clk125,
         sysRst125 => rst125,
         sysClk62  => clk62,
         sysRst62  => rst62,
         locked    => locked,
         -- ARM Interface
         armEthTx  => armEthTx(1),
         armEthRx  => armEthRx(1),
         -- Ethernet Lines
         ethRxP    => ethRxP(1),
         ethRxM    => ethRxN(1),
         ethTxP    => ethTxP(1),
         ethTxM    => ethTxN(1));

   userEthClk           <= clk125;
   userEthRst           <= rst125;
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

   U_sgmiiRx0 : IBUFDS port map(I => sgmiiRxP(0), IB => sgmiiRxN(0), O => sgmiiRx(0));
   U_sgmiiRx1 : IBUFDS port map(I => sgmiiRxP(1), IB => sgmiiRxN(1), O => sgmiiRx(1));
   U_sgmiiRx2 : IBUFDS port map(I => sgmiiRxP(2), IB => sgmiiRxN(2), O => sgmiiRx(2));
   U_sgmiiRx3 : IBUFDS port map(I => sgmiiRxP(3), IB => sgmiiRxN(3), O => sgmiiRx(3));

   U_sgmiiTx0 : OBUFDS port map(O => sgmiiTxP(0), OB => sgmiiTxN(0), I => '0');
   U_sgmiiTx1 : OBUFDS port map(O => sgmiiTxP(1), OB => sgmiiTxN(1), I => '0');
   U_sgmiiTx2 : OBUFDS port map(O => sgmiiTxP(2), OB => sgmiiTxN(2), I => '0');
   U_sgmiiTx3 : OBUFDS port map(O => sgmiiTxP(3), OB => sgmiiTxN(3), I => '0');

end mapping;
