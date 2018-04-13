-------------------------------------------------------------------------------
-- File       : RceG3AxiIcon.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2016-05-16
-- Last update: 2016-07-14
-------------------------------------------------------------------------------
-- Description: Wrapper for Microblaze Basic Core for "90% case"
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
use work.AxiStreamPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.SsiPkg.all;

entity RceG3AxiIcon is
   generic (
      TPD_G  : time := 1 ns);
   port (

      -- Clock and reset
      axiClk          : in  sl;
      axiRst          : in  sl;

      -- GP Master
      mGpReadMaster   : in  AxiReadMasterType;
      mGpReadSlave    : out AxiReadSlaveType;
      mGpWriteMaster  : in  AxiWriteMasterType;
      mGpWriteSlave   : out AxiWriteSlaveType;

      -- Local Master
      locReadMaster   : out AxiReadMasterType;
      locReadSlave    : in  AxiReadSlaveType;
      locWriteMaster  : out AxiWriteMasterType;
      locWriteSlave   : in  AxiWriteSlaveType;

      -- PCIE Masters
      pcieReadMaster  : out AxiReadMasterArray(1 downto 0);
      pcieReadSlave   : in  AxiReadSlaveArray(1 downto 0);
      pcieWriteMaster : out AxiWriteMasterArray(1 downto 0);
      pcieWriteSlave  : in  AxiWriteSlaveArray(1 downto 0)
   );
end RceG3AxiIcon;

architecture mapping of RceG3AxiIcon is

   component axi_icon is
      port (
         axi_slave_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_slave_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_slave_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_slave_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_slave_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_slave_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_slave_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_awvalid : in STD_LOGIC;
         axi_slave_awready : out STD_LOGIC;
         axi_slave_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_slave_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_wlast : in STD_LOGIC;
         axi_slave_wvalid : in STD_LOGIC;
         axi_slave_wready : out STD_LOGIC;
         axi_slave_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_slave_bvalid : out STD_LOGIC;
         axi_slave_bready : in STD_LOGIC;
         axi_slave_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_slave_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_slave_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_slave_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_slave_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_slave_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_slave_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_arvalid : in STD_LOGIC;
         axi_slave_arready : out STD_LOGIC;
         axi_slave_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_slave_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_slave_rlast : out STD_LOGIC;
         axi_slave_rvalid : out STD_LOGIC;
         axi_slave_rready : in STD_LOGIC;
         axi_mast2_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast2_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast2_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast2_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast2_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast2_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast2_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast2_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast2_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
         axi_mast2_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast2_wlast : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast2_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast2_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast2_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast2_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast2_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast2_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast2_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast2_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast2_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
         axi_mast2_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast2_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast2_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast1_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast1_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast1_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast1_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast1_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast1_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast1_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast1_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
         axi_mast1_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast1_wlast : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast1_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast1_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast1_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast1_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast1_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast1_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast1_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast1_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast1_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
         axi_mast1_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast1_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast1_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast0_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast0_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast0_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast0_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast0_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast0_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast0_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_awvalid : out STD_LOGIC;
         axi_mast0_awready : in STD_LOGIC;
         axi_mast0_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast0_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_wlast : out STD_LOGIC;
         axi_mast0_wvalid : out STD_LOGIC;
         axi_mast0_wready : in STD_LOGIC;
         axi_mast0_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast0_bvalid : in STD_LOGIC;
         axi_mast0_bready : out STD_LOGIC;
         axi_mast0_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast0_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
         axi_mast0_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast0_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast0_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
         axi_mast0_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
         axi_mast0_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_mast0_arvalid : out STD_LOGIC;
         axi_mast0_arready : in STD_LOGIC;
         axi_mast0_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
         axi_mast0_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
         axi_mast0_rlast : in STD_LOGIC;
         axi_mast0_rvalid : in STD_LOGIC;
         axi_mast0_rready : out STD_LOGIC;
         axi_clk : in STD_LOGIC;
         axi_rstn : in STD_LOGIC;
         axi_slave_arid : in STD_LOGIC_VECTOR ( 11 downto 0 );
         axi_slave_arregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_awid : in STD_LOGIC_VECTOR ( 11 downto 0 );
         axi_slave_awregion : in STD_LOGIC_VECTOR ( 3 downto 0 );
         axi_slave_bid : out STD_LOGIC_VECTOR ( 11 downto 0 );
         axi_slave_rid : out STD_LOGIC_VECTOR ( 11 downto 0 )
      );
   end component axi_icon;

   -- Inverted reset
   signal intRstL : sl;

begin

   intRstL <= not axiRst;

   -- Unused master read data 
   mGpReadSlave.rdata(1023 downto 32) <= (others=>'0');

   -- Unused master write address bits
   locWriteMaster.awaddr(63 downto 32)     <= (others=>'0');
   pcieWriteMaster(0).awaddr(63 downto 32) <= (others=>'0');
   pcieWriteMaster(1).awaddr(63 downto 32) <= (others=>'0');

   -- Unused master read address bits
   locReadMaster.araddr(63 downto 32) <= (others=>'0');
   pcieReadMaster(0).araddr(63 downto 32) <= (others=>'0');
   pcieReadMaster(1).araddr(63 downto 32) <= (others=>'0');

   -- Unused master write data bits
   locWriteMaster.wdata(1023 downto 32) <= (others=>'0');
   pcieWriteMaster(0).wdata(1023 downto 64) <= (others=>'0');
   pcieWriteMaster(1).wdata(1023 downto 64) <= (others=>'0');

   -- Unused master write data strobe bits
   locWriteMaster.wstrb(127 downto 8) <= (others=>'0');
   pcieWriteMaster(0).wstrb(127 downto 8) <= (others=>'0');
   pcieWriteMaster(1).wstrb(127 downto 8) <= (others=>'0');

   -- Unused IDs
   locReadMaster.arid      <= (others=>'0');
   pcieReadMaster(0).arid  <= (others=>'0');
   pcieReadMaster(1).arid  <= (others=>'0');
   locWriteMaster.awid     <= (others=>'0');
   pcieWriteMaster(0).awid <= (others=>'0');
   pcieWriteMaster(1).awid <= (others=>'0');
   locWriteMaster.wid      <= (others=>'0');
   pcieWriteMaster(0).wid  <= (others=>'0');
   pcieWriteMaster(1).wid  <= (others=>'0');

   -- Unused IDs
   mGpWriteSlave.bid(31 downto 12) <= (others=>'0');
   mGpReadSlave.rid(31 downto 12)  <= (others=>'0');


   U_AxiIcon : axi_icon 
      port map (
         axi_slave_awaddr     => mGpWriteMaster.awaddr(31 downto 0),
         axi_slave_awlen      => mGpWriteMaster.awlen,
         axi_slave_awsize     => mGpWriteMaster.awsize,
         axi_slave_awburst    => mGpWriteMaster.awburst,
         axi_slave_awlock     => mGpWriteMaster.awlock(0 downto 0),
         axi_slave_awcache    => mGpWriteMaster.awcache,
         axi_slave_awprot     => mGpWriteMaster.awprot,
         axi_slave_awqos      => mGpWriteMaster.awqos,
         axi_slave_awvalid    => mGpWriteMaster.awvalid,
         axi_slave_awready    => mGpWriteSlave.awready,
         axi_slave_wdata      => mGpWriteMaster.wdata(31 downto 0),
         axi_slave_wstrb      => mGpWriteMaster.wstrb(3 downto 0),
         axi_slave_wlast      => mGpWriteMaster.wlast,
         axi_slave_wvalid     => mGpWriteMaster.wvalid,
         axi_slave_wready     => mGpWriteSlave.wready,
         axi_slave_bresp      => mGpWriteSlave.bresp,
         axi_slave_bvalid     => mGpWriteSlave.bvalid,
         axi_slave_bready     => mGpWriteMaster.bready,
         axi_slave_araddr     => mGpReadMaster.araddr(31 downto 0),
         axi_slave_arlen      => mGpReadMaster.arlen,
         axi_slave_arsize     => mGpReadMaster.arsize,
         axi_slave_arburst    => mGpReadMaster.arburst,
         axi_slave_arlock     => mGpReadMaster.arlock(0 downto 0),
         axi_slave_arcache    => mGpReadMaster.arcache,
         axi_slave_arprot     => mGpReadMaster.arprot,
         axi_slave_arqos      => mGpReadMaster.arqos,
         axi_slave_arvalid    => mGpReadMaster.arvalid,
         axi_slave_arready    => mGpReadSlave.arready,
         axi_slave_rdata      => mGpReadSlave.rdata(31 downto 0),
         axi_slave_rresp      => mGpReadSlave.rresp,
         axi_slave_rlast      => mGpReadSlave.rlast,
         axi_slave_rvalid     => mGpReadSlave.rvalid,
         axi_slave_rready     => mGpReadMaster.rready,

         axi_mast2_awaddr     => pcieWriteMaster(1).awaddr(31 downto 0),
         axi_mast2_awlen      => pcieWriteMaster(1).awlen,
         axi_mast2_awsize     => pcieWriteMaster(1).awsize,
         axi_mast2_awburst    => pcieWriteMaster(1).awburst,
         axi_mast2_awlock     => pcieWriteMaster(1).awlock(0 downto 0),
         axi_mast2_awcache    => pcieWriteMaster(1).awcache,
         axi_mast2_awprot     => pcieWriteMaster(1).awprot,
         axi_mast2_awregion   => pcieWriteMaster(1).awregion,
         axi_mast2_awqos      => pcieWriteMaster(1).awqos,
         axi_mast2_awvalid(0) => pcieWriteMaster(1).awvalid,
         axi_mast2_awready(0) => pcieWriteSlave(1).awready,
         axi_mast2_wdata      => pcieWriteMaster(1).wdata(63 downto 0),
         axi_mast2_wstrb      => pcieWriteMaster(1).wstrb(7 downto 0),
         axi_mast2_wlast(0)   => pcieWriteMaster(1).wlast,
         axi_mast2_wvalid(0)  => pcieWriteMaster(1).wvalid,
         axi_mast2_wready(0)  => pcieWriteSlave(1).wready,
         axi_mast2_bresp      => pcieWriteSlave(1).bresp,
         axi_mast2_bvalid(0)  => pcieWriteSlave(1).bvalid,
         axi_mast2_bready(0)  => pcieWriteMaster(1).bready,
         axi_mast2_araddr     => pcieReadMaster(1).araddr(31 downto 0),
         axi_mast2_arlen      => pcieReadMaster(1).arlen,
         axi_mast2_arsize     => pcieReadMaster(1).arsize,
         axi_mast2_arburst    => pcieReadMaster(1).arburst,
         axi_mast2_arlock     => pcieReadMaster(1).arlock(0 downto 0),
         axi_mast2_arcache    => pcieReadMaster(1).arcache,
         axi_mast2_arprot     => pcieReadMaster(1).arprot,
         axi_mast2_arregion   => pcieReadMaster(1).arregion,
         axi_mast2_arqos      => pcieReadMaster(1).arqos,
         axi_mast2_arvalid(0) => pcieReadMaster(1).arvalid,
         axi_mast2_arready(0) => pcieReadSlave(1).arready,
         axi_mast2_rdata      => pcieReadSlave(1).rdata(63 downto 0),
         axi_mast2_rresp      => pcieReadSlave(1).rresp,
         axi_mast2_rlast(0)   => pcieReadSlave(1).rlast,
         axi_mast2_rvalid(0)  => pcieReadSlave(1).rvalid,
         axi_mast2_rready(0)  => pcieReadMaster(1).rready,

         axi_mast1_awaddr     => pcieWriteMaster(0).awaddr(31 downto 0),
         axi_mast1_awlen      => pcieWriteMaster(0).awlen,
         axi_mast1_awsize     => pcieWriteMaster(0).awsize,
         axi_mast1_awburst    => pcieWriteMaster(0).awburst,
         axi_mast1_awlock     => pcieWriteMaster(0).awlock(0 downto 0),
         axi_mast1_awcache    => pcieWriteMaster(0).awcache,
         axi_mast1_awprot     => pcieWriteMaster(0).awprot,
         axi_mast1_awregion   => pcieWriteMaster(0).awregion,
         axi_mast1_awqos      => pcieWriteMaster(0).awqos,
         axi_mast1_awvalid(0) => pcieWriteMaster(0).awvalid,
         axi_mast1_awready(0) => pcieWriteSlave(0).awready,
         axi_mast1_wdata      => pcieWriteMaster(0).wdata(63 downto 0),
         axi_mast1_wstrb      => pcieWriteMaster(0).wstrb(7 downto 0),
         axi_mast1_wlast(0)   => pcieWriteMaster(0).wlast,
         axi_mast1_wvalid(0)  => pcieWriteMaster(0).wvalid,
         axi_mast1_wready(0)  => pcieWriteSlave(0).wready,
         axi_mast1_bresp      => pcieWriteSlave(0).bresp,
         axi_mast1_bvalid(0)  => pcieWriteSlave(0).bvalid,
         axi_mast1_bready(0)  => pcieWriteMaster(0).bready,
         axi_mast1_araddr     => pcieReadMaster(0).araddr(31 downto 0),
         axi_mast1_arlen      => pcieReadMaster(0).arlen,
         axi_mast1_arsize     => pcieReadMaster(0).arsize,
         axi_mast1_arburst    => pcieReadMaster(0).arburst,
         axi_mast1_arlock     => pcieReadMaster(0).arlock(0 downto 0),
         axi_mast1_arcache    => pcieReadMaster(0).arcache,
         axi_mast1_arprot     => pcieReadMaster(0).arprot,
         axi_mast1_arregion   => pcieReadMaster(0).arregion,
         axi_mast1_arqos      => pcieReadMaster(0).arqos,
         axi_mast1_arvalid(0) => pcieReadMaster(0).arvalid,
         axi_mast1_arready(0) => pcieReadSlave(0).arready,
         axi_mast1_rdata      => pcieReadSlave(0).rdata(63 downto 0),
         axi_mast1_rresp      => pcieReadSlave(0).rresp,
         axi_mast1_rlast(0)   => pcieReadSlave(0).rlast,
         axi_mast1_rvalid(0)  => pcieReadSlave(0).rvalid,
         axi_mast1_rready(0)  => pcieReadMaster(0).rready,

         axi_mast0_awaddr     => locWriteMaster.awaddr(31 downto 0),
         axi_mast0_awlen      => locWriteMaster.awlen,
         axi_mast0_awsize     => locWriteMaster.awsize,
         axi_mast0_awburst    => locWriteMaster.awburst,
         axi_mast0_awlock     => locWriteMaster.awlock(0 downto 0),
         axi_mast0_awcache    => locWriteMaster.awcache,
         axi_mast0_awprot     => locWriteMaster.awprot,
         axi_mast0_awregion   => locWriteMaster.awregion,
         axi_mast0_awqos      => locWriteMaster.awqos,
         axi_mast0_awvalid    => locWriteMaster.awvalid,
         axi_mast0_awready    => locWriteSlave.awready,
         axi_mast0_wdata      => locWriteMaster.wdata(31 downto 0),
         axi_mast0_wstrb      => locWriteMaster.wstrb(3 downto 0),
         axi_mast0_wlast      => locWriteMaster.wlast,
         axi_mast0_wvalid     => locWriteMaster.wvalid,
         axi_mast0_wready     => locWriteSlave.wready,
         axi_mast0_bresp      => locWriteSlave.bresp,
         axi_mast0_bvalid     => locWriteSlave.bvalid,
         axi_mast0_bready     => locWriteMaster.bready,
         axi_mast0_araddr     => locReadMaster.araddr(31 downto 0),
         axi_mast0_arlen      => locReadMaster.arlen,
         axi_mast0_arsize     => locReadMaster.arsize,
         axi_mast0_arburst    => locReadMaster.arburst,
         axi_mast0_arlock(0)  => locReadMaster.arlock(0),
         axi_mast0_arcache    => locReadMaster.arcache,
         axi_mast0_arprot     => locReadMaster.arprot,
         axi_mast0_arregion   => locReadMaster.arregion,
         axi_mast0_arqos      => locReadMaster.arqos,
         axi_mast0_arvalid    => locReadMaster.arvalid,
         axi_mast0_arready    => locReadSlave.arready,
         axi_mast0_rdata      => locReadSlave.rdata(31 downto 0),
         axi_mast0_rresp      => locReadSlave.rresp,
         axi_mast0_rlast      => locReadSlave.rlast,
         axi_mast0_rvalid     => locReadSlave.rvalid,
         axi_mast0_rready     => locReadMaster.rready,

         axi_clk              => axiClk,
         axi_rstn             => intRstL,

         axi_slave_arid       => mGpReadMaster.arid(11 downto 0),
         axi_slave_arregion   => mGpReadMaster.arregion,
         axi_slave_awid       => mGpWriteMaster.awid(11 downto 0),
         axi_slave_awregion   => mGpWriteMaster.awregion,
         axi_slave_bid        => mGpWriteSlave.bid(11 downto 0),
         axi_slave_rid        => mGpReadSlave.rid(11 downto 0)
      );

end mapping;
