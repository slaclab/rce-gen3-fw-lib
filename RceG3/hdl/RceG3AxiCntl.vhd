-------------------------------------------------------------------------------
-- Title         : Local AXI Bus Bridge and Registers
-- File          : RceG3AxiCntl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/06/2014
-------------------------------------------------------------------------------
-- Description:
-- Wrapper for AXI bus converter, crossbar and core registers
------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/06/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.RceG3Pkg.all;
use work.RceG3Version.all;

entity RceG3AxiCntl is
   generic (
      TPD_G          : time           := 1 ns;
      BUILD_INFO_G   : BuildInfoType;
      PCIE_EN_G      : boolean        := false;
      RCE_DMA_MODE_G : RceDmaModeType := RCE_DMA_PPI_C
      );
   port (

      -- GP AXI Masters, 0=axiDmaClk, 1=axiClk
      mGpReadMaster  : in  AxiReadMasterArray(1 downto 0);
      mGpReadSlave   : out AxiReadSlaveArray(1 downto 0);
      mGpWriteMaster : in  AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave  : out AxiWriteSlaveArray(1 downto 0);

      -- Fast AXI Busses
      axiDmaClk : in sl;
      axiDmaRst : in sl;

      -- Interrupt Control AXI Lite Bus
      icAxilReadMaster  : out AxiLiteReadMasterType;
      icAxilReadSlave   : in  AxiLiteReadSlaveType;
      icAxilWriteMaster : out AxiLiteWriteMasterType;
      icAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- DMA AXI Lite Busses, dmaAxiClk
      dmaAxilReadMaster  : out AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilReadSlave   : in  AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteMaster : out AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteSlave  : in  AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

      -- Slow AXI Busses
      axiClk    : in sl;
      axiClkRst : in sl;

      -- BSI AXI Lite
      bsiAxilReadMaster  : out AxiLiteReadMasterType;
      bsiAxilReadSlave   : in  AxiLiteReadSlaveType;
      bsiAxilWriteMaster : out AxiLiteWriteMasterType;
      bsiAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- External AXI Lite (top level, outside DpmCore, DtmCore)
      extAxilReadMaster  : out AxiLiteReadMasterType;
      extAxilReadSlave   : in  AxiLiteReadSlaveType;
      extAxilWriteMaster : out AxiLiteWriteMasterType;
      extAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- Core AXI Lite (outside RCE, insidde DpmCore, DtmCore)
      coreAxilReadMaster  : out AxiLiteReadMasterType;
      coreAxilReadSlave   : in  AxiLiteReadSlaveType;
      coreAxilWriteMaster : out AxiLiteWriteMasterType;
      coreAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- User AXI Interface
      userReadMaster  : in  AxiReadMasterType;
      userReadSlave   : out AxiReadSlaveType;
      userWriteMaster : in  AxiWriteMasterType;
      userWriteSlave  : out AxiWriteSlaveType;

      -- AUX AXI Interface
      auxReadMaster  : out AxiReadMasterType;
      auxReadSlave   : in  AxiReadSlaveType;
      auxWriteMaster : out AxiWriteMasterType;
      auxWriteSlave  : in  AxiWriteSlaveType;
      auxAxiClk      : out sl;

      -- PCIE AXI Interface
      pciRefClkP : in  sl;
      pciRefClkN : in  sl;
      pciResetL  : out sl;
      pcieInt    : out sl;
      pcieRxP    : in  sl;
      pcieRxN    : in  sl;
      pcieTxP    : out sl;
      pcieTxN    : out sl;

      -- Ethernet Mode
      armEthMode : in  slv(31 downto 0);
      eFuseValue : out slv(31 downto 0);
      deviceDna  : out slv(127 downto 0);

      -- Clock Select Lines
      clkSelA : out slv(1 downto 0);
      clkSelB : out slv(1 downto 0)
      );
end RceG3AxiCntl;

architecture structure of RceG3AxiCntl is

   component RceG3AxiToAxiLiteBridge
      port (
         aclk           : in  std_logic;
         aresetn        : in  std_logic;
         s_axi_awid     : in  std_logic_vector(15 downto 0);
         s_axi_awaddr   : in  std_logic_vector(31 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awlock   : in  std_logic_vector(0 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_wdata    : in  std_logic_vector(31 downto 0);
         s_axi_wstrb    : in  std_logic_vector(3 downto 0);
         s_axi_wlast    : in  std_logic;
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_bid      : out std_logic_vector(15 downto 0);
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_arid     : in  std_logic_vector(15 downto 0);
         s_axi_araddr   : in  std_logic_vector(31 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arlock   : in  std_logic_vector(0 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_rid      : out std_logic_vector(15 downto 0);
         s_axi_rdata    : out std_logic_vector(31 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rlast    : out std_logic;
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : in  std_logic;
         m_axi_awaddr   : out std_logic_vector(31 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_wdata    : out std_logic_vector(31 downto 0);
         m_axi_wstrb    : out std_logic_vector(3 downto 0);
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_araddr   : out std_logic_vector(31 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_rdata    : in  std_logic_vector(31 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : out std_logic
         );
   end component;

   constant GP0_MAST_CNT_C : integer := DMA_AXIL_COUNT_C + 1;
   constant GP1_MAST_CNT_C : integer := 4;

   constant BUILD_INFO_C       : BuildInfoRetType    := toBuildInfo(BUILD_INFO_G);
   constant BUILD_STRING_ROM_C : Slv32Array(0 to 63) := BUILD_INFO_C.buildString;

   -- Gp0 Signals
   signal midGp0ReadMaster   : AxiLiteReadMasterType;
   signal midGp0ReadSlave    : AxiLiteReadSlaveType;
   signal midGp0WriteMaster  : AxiLiteWriteMasterType;
   signal midGp0WriteSlave   : AxiLiteWriteSlaveType;
   signal tmpGp0ReadMasters  : AxiLiteReadMasterArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0ReadSlaves   : AxiLiteReadSlaveArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0WriteMasters : AxiLiteWriteMasterArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0WriteSlaves  : AxiLiteWriteSlaveArray(GP0_MAST_CNT_C-1 downto 0);

   -- Gp1 Signals
   signal gp1AxiReadMaster   : AxiReadMasterType;
   signal gp1AxiReadSlave    : AxiReadSlaveType;
   signal gp1AxiWriteMaster  : AxiWriteMasterType;
   signal gp1AxiWriteSlave   : AxiWriteSlaveType;
   signal midGp1ReadMaster   : AxiLiteReadMasterType;
   signal midGp1ReadSlave    : AxiLiteReadSlaveType;
   signal midGp1WriteMaster  : AxiLiteWriteMasterType;
   signal midGp1WriteSlave   : AxiLiteWriteSlaveType;
   signal tmpGp1ReadMasters  : AxiLiteReadMasterArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1ReadSlaves   : AxiLiteReadSlaveArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1WriteMasters : AxiLiteWriteMasterArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1WriteSlaves  : AxiLiteWriteSlaveArray(GP1_MAST_CNT_C-1 downto 0);

   -- Local signals
   signal intReadMaster  : AxiLiteReadMasterType;
   signal intReadSlave   : AxiLiteReadSlaveType;
   signal intWriteMaster : AxiLiteWriteMasterType;
   signal intWriteSlave  : AxiLiteWriteSlaveType;
   signal dnaValue       : slv(127 downto 0);
   signal eFuseUsr       : slv(31 downto 0);

   type RegType is record
      scratchPad    : slv(31 downto 0);
      clkSelA       : slv(1 downto 0);
      clkSelB       : slv(1 downto 0);
      heartbeat     : slv(31 downto 0);
      intReadSlave  : AxiLiteReadSlaveType;
      intWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      scratchPad    => (others => '0'),
      clkSelA       => (others => '0'),
      clkSelB       => (others => '1'),
      heartbeat     => (others => '0'),
      intReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      intWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
      );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal axiDmaRstL : sl;

begin

   axiDmaRstL <= not(axiDmaRst);

   -------------------------------------
   -- GP0 AXI-4 to AXI Lite Conversion
   -- 0x40000000 - 0x7FFFFFFF, axiDmaClk
   -------------------------------------
   U_Gp0AxiLite : RceG3AxiToAxiLiteBridge
      port map (
         aclk            => axiDmaClk,
         aresetn         => axiDmaRstL,
         s_axi_awid      => mGpWriteMaster(0).awid(15 downto 0),
         s_axi_awaddr    => mGpWriteMaster(0).awaddr(31 downto 0),
         s_axi_awlen     => mGpWriteMaster(0).awlen,
         s_axi_awsize    => mGpWriteMaster(0).awsize,
         s_axi_awburst   => mGpWriteMaster(0).awburst,
         s_axi_awlock(0) => mGpWriteMaster(0).awlock(0),
         s_axi_awcache   => mGpWriteMaster(0).awcache,
         s_axi_awprot    => mGpWriteMaster(0).awprot,
         s_axi_awregion  => mGpWriteMaster(0).awregion,
         s_axi_awqos     => mGpWriteMaster(0).awqos,
         s_axi_awvalid   => mGpWriteMaster(0).awvalid,
         s_axi_awready   => mGpWriteSlave(0).awready,
         s_axi_wdata     => mGpWriteMaster(0).wdata(31 downto 0),
         s_axi_wstrb     => mGpWriteMaster(0).wstrb(3 downto 0),
         s_axi_wlast     => mGpWriteMaster(0).wlast,
         s_axi_wvalid    => mGpWriteMaster(0).wvalid,
         s_axi_wready    => mGpWriteSlave(0).wready,
         s_axi_bid       => mGpWriteSlave(0).bid(15 downto 0),
         s_axi_bresp     => mGpWriteSlave(0).bresp,
         s_axi_bvalid    => mGpWriteSlave(0).bvalid,
         s_axi_bready    => mGpWriteMaster(0).bready,
         s_axi_arid      => mGpReadMaster(0).arid(15 downto 0),
         s_axi_araddr    => mGpReadMaster(0).araddr(31 downto 0),
         s_axi_arlen     => mGpReadMaster(0).arlen,
         s_axi_arsize    => mGpReadMaster(0).arsize,
         s_axi_arburst   => mGpReadMaster(0).arburst,
         s_axi_arlock(0) => mGpReadMaster(0).arlock(0),
         s_axi_arcache   => mGpReadMaster(0).arcache,
         s_axi_arprot    => mGpReadMaster(0).arprot,
         s_axi_arregion  => mGpReadMaster(0).arregion,
         s_axi_arqos     => mGpReadMaster(0).arqos,
         s_axi_arvalid   => mGpReadMaster(0).arvalid,
         s_axi_arready   => mGpReadSlave(0).arready,
         s_axi_rid       => mGpReadSlave(0).rid(15 downto 0),
         s_axi_rdata     => mGpReadSlave(0).rdata(31 downto 0),
         s_axi_rresp     => mGpReadSlave(0).rresp,
         s_axi_rlast     => mGpReadSlave(0).rlast,
         s_axi_rvalid    => mGpReadSlave(0).rvalid,
         s_axi_rready    => mGpReadMaster(0).rready,
         m_axi_awaddr    => midGp0WriteMaster.awaddr,
         m_axi_awprot    => midGp0WriteMaster.awprot,
         m_axi_awvalid   => midGp0WriteMaster.awvalid,
         m_axi_awready   => midGp0WriteSlave.awready,
         m_axi_wdata     => midGp0WriteMaster.wdata,
         m_axi_wstrb     => midGp0WriteMaster.wstrb,
         m_axi_wvalid    => midGp0WriteMaster.wvalid,
         m_axi_wready    => midGp0WriteSlave.wready,
         m_axi_bresp     => midGp0WriteSlave.bresp,
         m_axi_bvalid    => midGp0WriteSlave.bvalid,
         m_axi_bready    => midGp0WriteMaster.bready,
         m_axi_araddr    => midGp0ReadMaster.araddr,
         m_axi_arprot    => midGp0ReadMaster.arprot,
         m_axi_arvalid   => midGp0ReadMaster.arvalid,
         m_axi_arready   => midGp0ReadSlave.arready,
         m_axi_rdata     => midGp0ReadSlave.rdata,
         m_axi_rresp     => midGp0ReadSlave.rresp,
         m_axi_rvalid    => midGp0ReadSlave.rvalid,
         m_axi_rready    => midGp0ReadMaster.rready);

   -------------------------------------
   -- GP0 AXI Lite Crossbar
   -- 0x40000000 - 0x7FFFFFFF, axiDmaClk
   -------------------------------------
   U_Gp0Crossbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => GP0_MAST_CNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => genGp0Config(RCE_DMA_MODE_G)
         ) port map (
            axiClk              => axiDmaClk,
            axiClkRst           => axiDmaRst,
            sAxiWriteMasters(0) => midGp0WriteMaster,
            sAxiWriteSlaves(0)  => midGp0WriteSlave,
            sAxiReadMasters(0)  => midGp0ReadMaster,
            sAxiReadSlaves(0)   => midGp0ReadSlave,
            mAxiWriteMasters    => tmpGp0WriteMasters,
            mAxiWriteSlaves     => tmpGp0WriteSlaves,
            mAxiReadMasters     => tmpGp0ReadMasters,
            mAxiReadSlaves      => tmpGp0ReadSlaves
            );

   icAxilWriteMaster    <= tmpGp0WriteMasters(0);
   tmpGp0WriteSlaves(0) <= icAxilWriteSlave;
   icAxilReadMaster     <= tmpGp0ReadMasters(0);
   tmpGp0ReadSlaves(0)  <= icAxilReadSlave;

   dmaAxilWriteMaster                           <= tmpGp0WriteMasters(DMA_AXIL_COUNT_C downto 1);
   tmpGp0WriteSlaves(DMA_AXIL_COUNT_C downto 1) <= dmaAxilWriteSlave;
   dmaAxilReadMaster                            <= tmpGp0ReadMasters(DMA_AXIL_COUNT_C downto 1);
   tmpGp0ReadSlaves(DMA_AXIL_COUNT_C downto 1)  <= dmaAxilReadSlave;


   -------------------------------------
   -- GP1 AXI-4 Interconnect
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_ICEN : if PCIE_EN_G generate

      ----------------------------------------------------------------------------      
      --                         PCIE Root Complex                              --
      ----------------------------------------------------------------------------      
      -- This VHDL wrapper is determined by the ZYNQ family type
      -- Zynq-7000:        rce-gen3-fw-lib/RceG3/hdl/zynq/RceG3PcieRoot.vhd
      -- Zynq Ultrascale+: rce-gen3-fw-lib/RceG3/hdl/zynquplus/RceG3PcieRoot.vhd
      ----------------------------------------------------------------------------    
      -- Local    = 0x80000000 - 9FFFFFFF
      -- pcie cfg = 0xA0000000 - AFFFFFFF
      -- pcie bar = 0xB0000000 - BFFFFFFF
      ----------------------------------------------------------------------------    
      U_RceG3PcieRoot : entity work.RceG3PcieRoot
         generic map (TPD_G => TPD_G)
         port map (
            axiClk          => axiClk,
            axiRst          => axiClkRst,
            mGpReadMaster   => mGpReadMaster(1),
            mGpReadSlave    => mGpReadSlave(1),
            mGpWriteMaster  => mGpWriteMaster(1),
            mGpWriteSlave   => mGpWriteSlave(1),
            locReadMaster   => gp1AxiReadMaster,
            locReadSlave    => gp1AxiReadSlave,
            locWriteMaster  => gp1AxiWriteMaster,
            locWriteSlave   => gp1AxiWriteSlave,
            pcieReadMaster  => auxReadMaster,
            pcieReadSlave   => auxReadSlave,
            pcieWriteMaster => auxWriteMaster,
            pcieWriteSlave  => auxWriteSlave,
            pciRefClkP      => pciRefClkP,
            pciRefClkN      => pciRefClkN,
            pciResetL       => pciResetL,
            pcieInt         => pcieInt,
            pcieRxP         => pcieRxP,
            pcieRxN         => pcieRxN,
            pcieTxP         => pcieTxP,
            pcieTxN         => pcieTxN
            );

      userReadSlave  <= AXI_READ_SLAVE_INIT_C;
      userWriteSlave <= AXI_WRITE_SLAVE_INIT_C;
      auxAxiClk      <= axiClk;

   end generate;

   U_ICDIS : if not PCIE_EN_G generate

      auxReadMaster  <= userReadMaster;
      userReadSlave  <= auxReadSlave;
      auxWriteMaster <= userWriteMaster;
      userWriteSlave <= auxWriteSlave;

      auxAxiClk <= axiDmaClk;

      pciResetL <= '0';
      pcieInt   <= '0';
      pcieTxP   <= '0';
      pcieTxN   <= '0';

      gp1AxiReadMaster  <= mGpReadMaster(1);
      mGpReadSlave(1)   <= gp1AxiReadSlave;
      gp1AxiWriteMaster <= mGpWriteMaster(1);
      mGpWriteSlave(1)  <= gp1AxiWriteSlave;

   end generate;

   -------------------------------------
   -- GP1 AXI-4 to AXI Lite Conversion
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_Gp1AxiLite : RceG3AxiToAxiLiteBridge
      port map (
         aclk            => axiDmaClk,
         aresetn         => axiDmaRstL,
         s_axi_awid      => mGpWriteMaster(1).awid(15 downto 0),
         s_axi_awaddr    => mGpWriteMaster(1).awaddr(31 downto 0),
         s_axi_awlen     => mGpWriteMaster(1).awlen,
         s_axi_awsize    => mGpWriteMaster(1).awsize,
         s_axi_awburst   => mGpWriteMaster(1).awburst,
         s_axi_awlock(0) => mGpWriteMaster(1).awlock(0),
         s_axi_awcache   => mGpWriteMaster(1).awcache,
         s_axi_awprot    => mGpWriteMaster(1).awprot,
         s_axi_awregion  => mGpWriteMaster(1).awregion,
         s_axi_awqos     => mGpWriteMaster(1).awqos,
         s_axi_awvalid   => mGpWriteMaster(1).awvalid,
         s_axi_awready   => mGpWriteSlave(1).awready,
         s_axi_wdata     => mGpWriteMaster(1).wdata(31 downto 0),
         s_axi_wstrb     => mGpWriteMaster(1).wstrb(3 downto 0),
         s_axi_wlast     => mGpWriteMaster(1).wlast,
         s_axi_wvalid    => mGpWriteMaster(1).wvalid,
         s_axi_wready    => mGpWriteSlave(1).wready,
         s_axi_bid       => mGpWriteSlave(1).bid(15 downto 0),
         s_axi_bresp     => mGpWriteSlave(1).bresp,
         s_axi_bvalid    => mGpWriteSlave(1).bvalid,
         s_axi_bready    => mGpWriteMaster(1).bready,
         s_axi_arid      => mGpReadMaster(1).arid(15 downto 0),
         s_axi_araddr    => mGpReadMaster(1).araddr(31 downto 0),
         s_axi_arlen     => mGpReadMaster(1).arlen,
         s_axi_arsize    => mGpReadMaster(1).arsize,
         s_axi_arburst   => mGpReadMaster(1).arburst,
         s_axi_arlock(0) => mGpReadMaster(1).arlock(0),
         s_axi_arcache   => mGpReadMaster(1).arcache,
         s_axi_arprot    => mGpReadMaster(1).arprot,
         s_axi_arregion  => mGpReadMaster(1).arregion,
         s_axi_arqos     => mGpReadMaster(1).arqos,
         s_axi_arvalid   => mGpReadMaster(1).arvalid,
         s_axi_arready   => mGpReadSlave(1).arready,
         s_axi_rid       => mGpReadSlave(1).rid(15 downto 0),
         s_axi_rdata     => mGpReadSlave(1).rdata(31 downto 0),
         s_axi_rresp     => mGpReadSlave(1).rresp,
         s_axi_rlast     => mGpReadSlave(1).rlast,
         s_axi_rvalid    => mGpReadSlave(1).rvalid,
         s_axi_rready    => mGpReadMaster(1).rready,
         m_axi_awaddr    => midGp1WriteMaster.awaddr,
         m_axi_awprot    => midGp1WriteMaster.awprot,
         m_axi_awvalid   => midGp1WriteMaster.awvalid,
         m_axi_awready   => midGp1WriteSlave.awready,
         m_axi_wdata     => midGp1WriteMaster.wdata,
         m_axi_wstrb     => midGp1WriteMaster.wstrb,
         m_axi_wvalid    => midGp1WriteMaster.wvalid,
         m_axi_wready    => midGp1WriteSlave.wready,
         m_axi_bresp     => midGp1WriteSlave.bresp,
         m_axi_bvalid    => midGp1WriteSlave.bvalid,
         m_axi_bready    => midGp1WriteMaster.bready,
         m_axi_araddr    => midGp1ReadMaster.araddr,
         m_axi_arprot    => midGp1ReadMaster.arprot,
         m_axi_arvalid   => midGp1ReadMaster.arvalid,
         m_axi_arready   => midGp1ReadSlave.arready,
         m_axi_rdata     => midGp1ReadSlave.rdata,
         m_axi_rresp     => midGp1ReadSlave.rresp,
         m_axi_rvalid    => midGp1ReadSlave.rvalid,
         m_axi_rready    => midGp1ReadMaster.rready);

   -------------------------------------
   -- GP1 AXI Lite Crossbar
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_Gp1Crossbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => GP1_MAST_CNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => genGp1Config(PCIE_EN_G)
         )
      port map (
         axiClk              => axiClk,
         axiClkRst           => axiClkRst,
         sAxiWriteMasters(0) => midGp1WriteMaster,
         sAxiWriteSlaves(0)  => midGp1WriteSlave,
         sAxiReadMasters(0)  => midGp1ReadMaster,
         sAxiReadSlaves(0)   => midGp1ReadSlave,
         mAxiWriteMasters    => tmpGp1WriteMasters,
         mAxiWriteSlaves     => tmpGp1WriteSlaves,
         mAxiReadMasters     => tmpGp1ReadMasters,
         mAxiReadSlaves      => tmpGp1ReadSlaves
         );

   intWriteMaster       <= tmpGp1WriteMasters(0);
   tmpGp1WriteSlaves(0) <= intWriteSlave;
   intReadMaster        <= tmpGp1ReadMasters(0);
   tmpGp1ReadSlaves(0)  <= intReadSlave;

   bsiAxilWriteMaster   <= tmpGp1WriteMasters(1);
   tmpGp1WriteSlaves(1) <= bsiAxilWriteSlave;
   bsiAxilReadMaster    <= tmpGp1ReadMasters(1);
   tmpGp1ReadSlaves(1)  <= bsiAxilReadSlave;

   extAxilWriteMaster   <= tmpGp1WriteMasters(2);
   tmpGp1WriteSlaves(2) <= extAxilWriteSlave;
   extAxilReadMaster    <= tmpGp1ReadMasters(2);
   tmpGp1ReadSlaves(2)  <= extAxilReadSlave;

   coreAxilWriteMaster  <= tmpGp1WriteMasters(3);
   tmpGp1WriteSlaves(3) <= coreAxilWriteSlave;
   coreAxilReadMaster   <= tmpGp1ReadMasters(3);
   tmpGp1ReadSlaves(3)  <= coreAxilReadSlave;


   -------------------------------------
   -- Local Registers
   -------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (armEthMode, axiClkRst, dnaValue, eFuseUsr, intReadMaster,
            intWriteMaster, r) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      v.heartbeat := r.heartbeat + 1;

      axiSlaveWaitTxn(intWriteMaster, intReadMaster, v.intWriteSlave, v.intReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (intWriteMaster.awaddr(15 downto 0)) is
            when X"0004" =>
               v.scratchPad := intWriteMaster.wdata;
            when X"0010" =>
               v.clkSelA(0) := intWriteMaster.wdata(0);
               v.clkSelB(0) := intWriteMaster.wdata(1);
            when X"0014" =>
               v.clkSelA(1) := intWriteMaster.wdata(0);
               v.clkSelB(1) := intWriteMaster.wdata(1);
            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.intWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.intReadSlave.rdata := (others => '0');

         if intReadMaster.araddr(15 downto 12) = 0 then

            -- Decode address and assign read data
            case intReadMaster.araddr(15 downto 0) is
               when X"0000" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.fwVersion;
               when X"0004" =>
                  v.intReadSlave.rdata := r.scratchPad;
               when X"0008" =>
                  v.intReadSlave.rdata := RCE_G3_VERSION_C;
               when X"000C" =>
                  v.intReadSlave.rdata(0) := toSl(PCIE_EN_G);
               when X"0010" =>
                  v.intReadSlave.rdata(0) := r.clkSelA(0);
                  v.intReadSlave.rdata(1) := r.clkSelB(0);
               when X"0014" =>
                  v.intReadSlave.rdata(0) := r.clkSelA(1);
                  v.intReadSlave.rdata(1) := r.clkSelB(1);
               when X"0020" =>
                  v.intReadSlave.rdata := dnaValue(31 downto 0);
               when X"0024" =>
                  v.intReadSlave.rdata := dnaValue(63 downto 32);
               when X"0028" =>
                  v.intReadSlave.rdata := dnaValue(95 downto 64);
               when X"002C" =>
                  v.intReadSlave.rdata := dnaValue(127 downto 96);
               when X"0030" =>
                  v.intReadSlave.rdata := eFuseUsr;
               when X"0034" =>
                  v.intReadSlave.rdata := armEthMode;
               when X"0038" =>
                  v.intReadSlave.rdata := r.heartbeat;
               when X"0040" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(31 downto 0);
               when X"0044" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(63 downto 32);
               when X"0048" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(95 downto 64);
               when X"004C" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(127 downto 96);
               when X"0050" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(159 downto 128);
               when others => null;
            end case;
         else
            v.intReadSlave.rdata := BUILD_STRING_ROM_C(conv_integer(intReadMaster.araddr(7 downto 2)));
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.intReadSlave);
      end if;

      -- Reset
      if (axiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      intReadSlave  <= r.intReadSlave;
      intWriteSlave <= r.intWriteSlave;
      clkSelA       <= r.clkSelA;
      clkSelB       <= r.clkSelB;

   end process;

   -------------------------------------
   -- Device DNA
   -------------------------------------
   U_DeviceDna : entity work.DeviceDna
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clk      => axiClk,
         rst      => axiClkRst,
         dnaValue => dnaValue);
   deviceDna <= dnaValue;

   -------------------------------------
   -- EFuse
   -------------------------------------
   U_EFuse : EFUSE_USR
      port map (
         EFUSEUSR => eFuseUsr
         );
   eFuseValue <= eFuseUsr;

end architecture structure;
