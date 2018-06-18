-------------------------------------------------------------------------------
-- File       : RceG3PcieRoot.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-05-16
-- Last update: 2016-07-14
-------------------------------------------------------------------------------
-- Description: Wrapper for Xilinx PCIE Root & Axi Interconnect
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity RceG3PcieRoot is
   generic (
      TPD_G  : time := 1 ns);
   port (

      -- Clock and reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- GP Master, axi clock
      mGpReadMaster   : in  AxiReadMasterType;
      mGpReadSlave    : out AxiReadSlaveType;
      mGpWriteMaster  : in  AxiWriteMasterType;
      mGpWriteSlave   : out AxiWriteSlaveType;

      -- Local Master, axi clock
      locReadMaster   : out AxiReadMasterType;
      locReadSlave    : in  AxiReadSlaveType;
      locWriteMaster  : out AxiWriteMasterType;
      locWriteSlave   : in  AxiWriteSlaveType;

      -- DMA Master, pcieAxiClk
      pcieReadMaster  : out AxiReadMasterType;
      pcieReadSlave   : in  AxiReadSlaveType;
      pcieWriteMaster : out AxiWriteMasterType;
      pcieWriteSlave  : in  AxiWriteSlaveType;
      pcieAxiClk      : out sl;

      -- PCIE
      pciRefClkP      : in  sl;
      pciRefClkM      : in  sl;
      pciResetL       : out sl;
      pcieInt         : out sl;
      pcieRxP         : in  sl;
      pcieRxM         : in  sl;
      pcieTxP         : out sl;
      pcieTxM         : out sl
   );
end RceG3PcieRoot;

architecture mapping of RceG3PcieRoot is

   component pcie_root is
      port (
         pcie_mgt_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
         pcie_mgt_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
         pcie_mgt_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
         pcie_mgt_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_clk : in STD_LOGIC;
         axi_rstn : in STD_LOGIC;
         pcie_int : out STD_LOGIC;
         pcie_refclk : in STD_LOGIC;
         intx_msi_req : in STD_LOGIC;
         msi_vector_num : in STD_LOGIC_VECTOR ( 4 downto 0 );
         intx_msi_grant : out STD_LOGIC;
         msi_enable : out STD_LOGIC;
         msi_vector_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
         pcie_resetn : out STD_LOGIC;
         pcie_mast_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         pcie_mast_awlen : out STD_LOGIC_VECTOR ( 3 downto 0 );
         pcie_mast_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         pcie_mast_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         pcie_mast_awlock : out STD_LOGIC_VECTOR ( 1 to 0 );
         pcie_mast_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         pcie_mast_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         pcie_mast_awvalid : out STD_LOGIC;
         pcie_mast_awready : in STD_LOGIC;
         pcie_mast_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
         pcie_mast_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
         pcie_mast_wlast : out STD_LOGIC;
         pcie_mast_wvalid : out STD_LOGIC;
         pcie_mast_wready : in STD_LOGIC;
         pcie_mast_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         pcie_mast_bvalid : in STD_LOGIC;
         pcie_mast_bready : out STD_LOGIC;
         pcie_mast_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         pcie_mast_arlen : out STD_LOGIC_VECTOR ( 3 downto 0 );
         pcie_mast_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         pcie_mast_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         pcie_mast_arlock : out STD_LOGIC_VECTOR ( 1 to 0 );
         pcie_mast_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         pcie_mast_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         pcie_mast_arvalid : out STD_LOGIC;
         pcie_mast_arready : in STD_LOGIC;
         pcie_mast_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
         pcie_mast_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         pcie_mast_rlast : in STD_LOGIC;
         pcie_mast_rvalid : in STD_LOGIC;
         pcie_mast_rready : out STD_LOGIC;
         local_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         local_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         local_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         local_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         local_axi_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         local_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         local_axi_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_awvalid : out STD_LOGIC;
         local_axi_awready : in STD_LOGIC;
         local_axi_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
         local_axi_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_wlast : out STD_LOGIC;
         local_axi_wvalid : out STD_LOGIC;
         local_axi_wready : in STD_LOGIC;
         local_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         local_axi_bvalid : in STD_LOGIC;
         local_axi_bready : out STD_LOGIC;
         local_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         local_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         local_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         local_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         local_axi_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         local_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         local_axi_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         local_axi_arvalid : out STD_LOGIC;
         local_axi_arready : in STD_LOGIC;
         local_axi_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
         local_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         local_axi_rlast : in STD_LOGIC;
         local_axi_rvalid : in STD_LOGIC;
         local_axi_rready : out STD_LOGIC;
         gp_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
         gp_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
         gp_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
         gp_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
         gp_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
         gp_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
         gp_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
         gp_axi_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_awvalid : in STD_LOGIC;
         gp_axi_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
         gp_axi_awready : out STD_LOGIC;
         gp_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
         gp_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_wlast : in STD_LOGIC;
         gp_axi_wvalid : in STD_LOGIC;
         gp_axi_wready : out STD_LOGIC;
         gp_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
         gp_axi_bvalid : out STD_LOGIC;
         gp_axi_bready : in STD_LOGIC;
         gp_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
         gp_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
         gp_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
         gp_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
         gp_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
         gp_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
         gp_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
         gp_axi_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
         gp_axi_arvalid : in STD_LOGIC;
         gp_axi_arready : out STD_LOGIC;
         gp_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
         gp_axi_rid : out STD_LOGIC_VECTOR ( 11 downto 0 );
         gp_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
         gp_axi_rlast : out STD_LOGIC;
         gp_axi_rvalid : out STD_LOGIC;
         gp_axi_rready : in STD_LOGIC
      );
   end component pcie_root;

   signal intRefClk     : sl;
   signal axiClkRstN    : sl;

   signal intReadMaster  : AxiReadMasterType;
   signal intReadSlave   : AxiReadSlaveType;
   signal intWriteMaster : AxiWriteMasterType;
   signal intWriteSlave  : AxiWriteSlaveType;

begin

   --- Unused regions
   intWriteMaster.awregion(3 downto 0) <= (others=>'0');
   intWriteMaster.awqos(3 downto 0)    <= (others=>'0');
   intReadMaster.arregion(3 downto 0)  <= (others=>'0');
   intReadMaster.arqos(3 downto 0)     <= (others=>'0');

   -- Unused master read data 
   mGpReadSlave.rdata(1023 downto 32) <= (others=>'0');

   -- Unused master write address bits
   locWriteMaster.awaddr(63 downto 32)  <= (others=>'0');
   intWriteMaster.awaddr(63 downto 32) <= (others=>'0');

   -- Unused master read address bits
   locReadMaster.araddr(63 downto 32)  <= (others=>'0');
   intReadMaster.araddr(63 downto 32) <= (others=>'0');

   -- Unused master write data bits
   locWriteMaster.wdata(1023 downto 32)  <= (others=>'0');
   intWriteMaster.wdata(1023 downto 64) <= (others=>'0');

   -- Unused master write data strobe bits
   locWriteMaster.wstrb(127 downto 4)  <= (others=>'0');
   intWriteMaster.wstrb(127 downto 8) <= (others=>'0');

   -- Unused IDs
   locReadMaster.arid   <= (others=>'0');
   intReadMaster.arid  <= (others=>'0');
   locWriteMaster.awid  <= (others=>'0');
   intWriteMaster.awid <= (others=>'0');
   locWriteMaster.wid   <= (others=>'0');
   intWriteMaster.wid  <= (others=>'0');
   mGpWriteSlave.bid(31 downto 12) <= (others=>'0');
   mGpReadSlave.rid(31 downto 12)  <= (others=>'0');

   pcieAxiClk <= axiClk;


   -- Local Ref Clk 
   U_RefClk : IBUFDS_GTE2
      port map(
         O       => intRefClk,
         ODIV2   => open,
         I       => pciRefClkP,
         IB      => pciRefClkM,
         CEB     => '0'
      );

   -- Invert resets
   axiClkRstN    <= not axiRst;


   -- PCIE Core
   U_PcieRoot : pcie_root
      port map (
         pcie_mgt_rxn(0)  => pcieRxM,
         pcie_mgt_rxp(0)  => pcieRxP,
         pcie_mgt_txn(0)  => pcieTxM,
         pcie_mgt_txp(0)  => pcieTxP,
         axi_clk          => axiClk,
         axi_rstn         => axiClkRstN,
         pcie_int         => pcieInt,
         pcie_refclk      => intRefClk,
         pcie_resetn      => pciResetL,

         intx_msi_req     => '0',     -- in STD_LOGIC;
         msi_vector_num   => "00000", -- in STD_LOGIC_VECTOR ( 4 downto 0 );
         intx_msi_grant   => open,    -- out STD_LOGIC;
         msi_enable       => open,    -- out STD_LOGIC;
         msi_vector_width => open,    -- out STD_LOGIC_VECTOR ( 2 downto 0 );

         pcie_mast_awaddr     => intWriteMaster.awaddr(31 downto 0),
         pcie_mast_awlen      => intWriteMaster.awlen(3 downto 0),
         pcie_mast_awsize     => intWriteMaster.awsize(2 downto 0),
         pcie_mast_awburst    => intWriteMaster.awburst(1 downto 0),
         pcie_mast_awlock     => intWriteMaster.awlock(1 downto 0),
         pcie_mast_awcache    => intWriteMaster.awcache(3 downto 0),
         pcie_mast_awprot     => intWriteMaster.awprot(2 downto 0),
         pcie_mast_awvalid    => intWriteMaster.awvalid,
         pcie_mast_awready    => intWriteSlave.awready,
         pcie_mast_wdata      => intWriteMaster.wdata(63 downto 0),
         pcie_mast_wstrb      => intWriteMaster.wstrb(7 downto 0),
         pcie_mast_wlast      => intWriteMaster.wlast,
         pcie_mast_wvalid     => intWriteMaster.wvalid,
         pcie_mast_wready     => intWriteSlave.wready,
         pcie_mast_bresp      => intWriteSlave.bresp(1 downto 0),
         pcie_mast_bvalid     => intWriteSlave.bvalid,
         pcie_mast_bready     => intWriteMaster.bready,
         pcie_mast_araddr     => intReadMaster.araddr(31 downto 0),
         pcie_mast_arlen      => intReadMaster.arlen(3 downto 0),
         pcie_mast_arsize     => intReadMaster.arsize(2 downto 0),
         pcie_mast_arburst    => intReadMaster.arburst(1 downto 0),
         pcie_mast_arlock     => intReadMaster.arlock(1 downto 0),
         pcie_mast_arcache    => intReadMaster.arcache(3 downto 0),
         pcie_mast_arprot     => intReadMaster.arprot(2 downto 0),
         pcie_mast_arvalid    => intReadMaster.arvalid,
         pcie_mast_arready    => intReadSlave.arready,
         pcie_mast_rdata      => intReadSlave.rdata(63 downto 0),
         pcie_mast_rresp      => intReadSlave.rresp(1 downto 0),
         pcie_mast_rlast      => intReadSlave.rlast,
         pcie_mast_rvalid     => intReadSlave.rvalid,
         pcie_mast_rready     => intReadMaster.rready,

         local_axi_awaddr     => locWriteMaster.awaddr(31 downto 0),
         local_axi_awlen      => locWriteMaster.awlen(7 downto 0),
         local_axi_awsize     => locWriteMaster.awsize(2 downto 0),
         local_axi_awburst    => locWriteMaster.awburst(1 downto 0),
         local_axi_awlock     => locWriteMaster.awlock(0 downto 0),
         local_axi_awcache    => locWriteMaster.awcache(3 downto 0),
         local_axi_awprot     => locWriteMaster.awprot(2 downto 0),
         local_axi_awregion   => locWriteMaster.awregion(3 downto 0),
         local_axi_awqos      => locWriteMaster.awqos(3 downto 0),
         local_axi_awvalid    => locWriteMaster.awvalid,
         local_axi_awready    => locWriteSlave.awready,
         local_axi_wdata      => locWriteMaster.wdata(31 downto 0),
         local_axi_wstrb      => locWriteMaster.wstrb(3 downto 0),
         local_axi_wlast      => locWriteMaster.wlast,
         local_axi_wvalid     => locWriteMaster.wvalid,
         local_axi_wready     => locWriteSlave.wready,
         local_axi_bresp      => locWriteSlave.bresp(1 downto 0),
         local_axi_bvalid     => locWriteSlave.bvalid,
         local_axi_bready     => locWriteMaster.bready,
         local_axi_araddr     => locReadMaster.araddr(31 downto 0),
         local_axi_arlen      => locReadMaster.arlen(7 downto 0),
         local_axi_arsize     => locReadMaster.arsize(2 downto 0),
         local_axi_arburst    => locReadMaster.arburst(1 downto 0),
         local_axi_arlock     => locReadMaster.arlock(0 downto 0),
         local_axi_arcache    => locReadMaster.arcache(3 downto 0),
         local_axi_arprot     => locReadMaster.arprot(2 downto 0),
         local_axi_arregion   => locReadMaster.arregion(3 downto 0),
         local_axi_arqos      => locReadMaster.arqos(3 downto 0),
         local_axi_arvalid    => locReadMaster.arvalid,
         local_axi_arready    => locReadSlave.arready,
         local_axi_rdata      => locReadSlave.rdata(31 downto 0),
         local_axi_rresp      => locReadSlave.rresp(1 downto 0),
         local_axi_rlast      => locReadSlave.rlast,
         local_axi_rvalid     => locReadSlave.rvalid,
         local_axi_rready     => locReadMaster.rready,

         gp_axi_awaddr     => mGpWriteMaster.awaddr(31 downto 0),
         gp_axi_awlen      => mGpWriteMaster.awlen(7 downto 0),
         gp_axi_awsize     => mGpWriteMaster.awsize(2 downto 0),
         gp_axi_awburst    => mGpWriteMaster.awburst(1 downto 0),
         gp_axi_awlock     => mGpWriteMaster.awlock(0 downto 0),
         gp_axi_awcache    => mGpWriteMaster.awcache(3 downto 0),
         gp_axi_awid       => mGpWriteMaster.awid(11 downto 0),
         gp_axi_awprot     => mGpWriteMaster.awprot(2 downto 0),
         gp_axi_awregion   => mgpWriteMaster.awregion(3 downto 0),
         gp_axi_awqos      => mGpWriteMaster.awqos(3 downto 0),
         gp_axi_awvalid    => mGpWriteMaster.awvalid,
         gp_axi_bid        => mGpWriteSlave.bid(11 downto 0),
         gp_axi_awready    => mGpWriteSlave.awready,
         gp_axi_wdata      => mGpWriteMaster.wdata(31 downto 0),
         gp_axi_wstrb      => mGpWriteMaster.wstrb(3 downto 0),
         gp_axi_wlast      => mGpWriteMaster.wlast,
         gp_axi_wvalid     => mGpWriteMaster.wvalid,
         gp_axi_wready     => mGpWriteSlave.wready,
         gp_axi_bresp      => mGpWriteSlave.bresp(1 downto 0),
         gp_axi_bvalid     => mGpWriteSlave.bvalid,
         gp_axi_bready     => mGpWriteMaster.bready,
         gp_axi_araddr     => mGpReadMaster.araddr(31 downto 0),
         gp_axi_arlen      => mGpReadMaster.arlen(7 downto 0),
         gp_axi_arsize     => mGpReadMaster.arsize(2 downto 0),
         gp_axi_arburst    => mGpReadMaster.arburst(1 downto 0),
         gp_axi_arlock     => mGpReadMaster.arlock(0 downto 0),
         gp_axi_arcache    => mGpReadMaster.arcache(3 downto 0),
         gp_axi_arid       => mGpReadMaster.arid(11 downto 0),
         gp_axi_arprot     => mGpReadMaster.arprot(2 downto 0),
         gp_axi_arregion   => mgpReadMaster.arregion(3 downto 0),
         gp_axi_arqos      => mGpReadMaster.arqos(3 downto 0),
         gp_axi_arvalid    => mGpReadMaster.arvalid,
         gp_axi_arready    => mGpReadSlave.arready,
         gp_axi_rdata      => mGpReadSlave.rdata(31 downto 0),
         gp_axi_rid        => mGpReadSlave.rid(11 downto 0),
         gp_axi_rresp      => mGpReadSlave.rresp(1 downto 0),
         gp_axi_rlast      => mGpReadSlave.rlast,
         gp_axi_rvalid     => mGpReadSlave.rvalid,
         gp_axi_rready     => mGpReadMaster.rready
      );


   U_AxiTranFilter: entity work.AxiTranFilter
      generic map ( TPD_G => TPD_G )
      port map (
         axiClk          => axiClk,
         axiRst          => axiRst,
         sAxiReadMaster  => intReadMaster,
         sAxiReadSlave   => intReadSlave,
         sAxiWriteMaster => intWriteMaster,
         sAxiWriteSlave  => intWriteSlave,
         mAxiReadMaster  => pcieReadMaster,
         mAxiReadSlave   => pcieReadSlave,
         mAxiWriteMaster => pcieWriteMaster,
         mAxiWriteSlave  => pcieWriteSlave
      );

end mapping;

