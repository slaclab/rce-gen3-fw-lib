-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, CPU Wrapper
-- File          : RceG3Cpu.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description: CPU wrapper for ARM based RCE generation 3 processor core.
--
-- Note: ZYNQ ULTRA's AXI interface doesn't support AxiWriteMaster.wid
--
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

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.RceG3Pkg.all;

entity RceG3Cpu is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clocks
      fclkClk3       : out sl;
      fclkClk2       : out sl;
      fclkClk1       : out sl;
      fclkClk0       : out sl;
      fclkRst3       : out sl;
      fclkRst2       : out sl;
      fclkRst1       : out sl;
      fclkRst0       : out sl;
      -- Interrupts
      armInterrupt   : in  slv(15 downto 0);
      -- AXI GP Master
      mGpAxiClk      : in  slv(1 downto 0);
      mGpWriteMaster : out AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave  : in  AxiWriteSlaveArray(1 downto 0);
      mGpReadMaster  : out AxiReadMasterArray(1 downto 0);
      mGpReadSlave   : in  AxiReadSlaveArray(1 downto 0);
      -- AXI GP Slave
      sGpAxiClk      : in  slv(1 downto 0);
      sGpWriteSlave  : out AxiWriteSlaveArray(1 downto 0);
      sGpWriteMaster : in  AxiWriteMasterArray(1 downto 0);
      sGpReadSlave   : out AxiReadSlaveArray(1 downto 0);
      sGpReadMaster  : in  AxiReadMasterArray(1 downto 0);
      -- AXI ACP Slave
      acpAxiClk      : in  sl;
      acpWriteSlave  : out AxiWriteSlaveType;
      acpWriteMaster : in  AxiWriteMasterType;
      acpReadSlave   : out AxiReadSlaveType;
      acpReadMaster  : in  AxiReadMasterType;
      -- AXI HP Slave
      hpAxiClk       : in  slv(3 downto 0);
      hpWriteSlave   : out AxiWriteSlaveArray(3 downto 0);
      hpWriteMaster  : in  AxiWriteMasterArray(3 downto 0);
      hpReadSlave    : out AxiReadSlaveArray(3 downto 0);
      hpReadMaster   : in  AxiReadMasterArray(3 downto 0);
      -- Ethernet
      armEthTx       : out ArmEthTxArray(1 downto 0);
      armEthRx       : in  ArmEthRxArray(1 downto 0));
end RceG3Cpu;

architecture mapping of RceG3Cpu is

   component Base_Zynq_MPSoC is
      port (
         GMII_ENET0_0_col                : in  std_logic;
         GMII_ENET0_0_crs                : in  std_logic;
         GMII_ENET0_0_rx_clk             : in  std_logic;
         GMII_ENET0_0_rx_dv              : in  std_logic;
         GMII_ENET0_0_rx_er              : in  std_logic;
         GMII_ENET0_0_rxd                : in  std_logic_vector (7 downto 0);
         GMII_ENET0_0_speed_mode         : out std_logic_vector (2 downto 0);
         GMII_ENET0_0_tx_clk             : in  std_logic;
         GMII_ENET0_0_tx_en              : out std_logic;
         GMII_ENET0_0_tx_er              : out std_logic;
         GMII_ENET0_0_txd                : out std_logic_vector (7 downto 0);
         GMII_ENET1_0_col                : in  std_logic;
         GMII_ENET1_0_crs                : in  std_logic;
         GMII_ENET1_0_rx_clk             : in  std_logic;
         GMII_ENET1_0_rx_dv              : in  std_logic;
         GMII_ENET1_0_rx_er              : in  std_logic;
         GMII_ENET1_0_rxd                : in  std_logic_vector (7 downto 0);
         GMII_ENET1_0_speed_mode         : out std_logic_vector (2 downto 0);
         GMII_ENET1_0_tx_clk             : in  std_logic;
         GMII_ENET1_0_tx_en              : out std_logic;
         GMII_ENET1_0_tx_er              : out std_logic;
         GMII_ENET1_0_txd                : out std_logic_vector (7 downto 0);
         M_AXI_HPM0_FPD_0_araddr         : out std_logic_vector (39 downto 0);
         M_AXI_HPM0_FPD_0_arburst        : out std_logic_vector (1 downto 0);
         M_AXI_HPM0_FPD_0_arcache        : out std_logic_vector (3 downto 0);
         M_AXI_HPM0_FPD_0_arid           : out std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_arlen          : out std_logic_vector (7 downto 0);
         M_AXI_HPM0_FPD_0_arlock         : out std_logic;
         M_AXI_HPM0_FPD_0_arprot         : out std_logic_vector (2 downto 0);
         M_AXI_HPM0_FPD_0_arqos          : out std_logic_vector (3 downto 0);
         M_AXI_HPM0_FPD_0_arready        : in  std_logic;
         M_AXI_HPM0_FPD_0_arsize         : out std_logic_vector (2 downto 0);
         M_AXI_HPM0_FPD_0_aruser         : out std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_arvalid        : out std_logic;
         M_AXI_HPM0_FPD_0_awaddr         : out std_logic_vector (39 downto 0);
         M_AXI_HPM0_FPD_0_awburst        : out std_logic_vector (1 downto 0);
         M_AXI_HPM0_FPD_0_awcache        : out std_logic_vector (3 downto 0);
         M_AXI_HPM0_FPD_0_awid           : out std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_awlen          : out std_logic_vector (7 downto 0);
         M_AXI_HPM0_FPD_0_awlock         : out std_logic;
         M_AXI_HPM0_FPD_0_awprot         : out std_logic_vector (2 downto 0);
         M_AXI_HPM0_FPD_0_awqos          : out std_logic_vector (3 downto 0);
         M_AXI_HPM0_FPD_0_awready        : in  std_logic;
         M_AXI_HPM0_FPD_0_awsize         : out std_logic_vector (2 downto 0);
         M_AXI_HPM0_FPD_0_awuser         : out std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_awvalid        : out std_logic;
         M_AXI_HPM0_FPD_0_bid            : in  std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_bready         : out std_logic;
         M_AXI_HPM0_FPD_0_bresp          : in  std_logic_vector (1 downto 0);
         M_AXI_HPM0_FPD_0_bvalid         : in  std_logic;
         M_AXI_HPM0_FPD_0_rdata          : in  std_logic_vector (127 downto 0);
         M_AXI_HPM0_FPD_0_rid            : in  std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_rlast          : in  std_logic;
         M_AXI_HPM0_FPD_0_rready         : out std_logic;
         M_AXI_HPM0_FPD_0_rresp          : in  std_logic_vector (1 downto 0);
         M_AXI_HPM0_FPD_0_rvalid         : in  std_logic;
         M_AXI_HPM0_FPD_0_wdata          : out std_logic_vector (127 downto 0);
         M_AXI_HPM0_FPD_0_wlast          : out std_logic;
         M_AXI_HPM0_FPD_0_wready         : in  std_logic;
         M_AXI_HPM0_FPD_0_wstrb          : out std_logic_vector (15 downto 0);
         M_AXI_HPM0_FPD_0_wvalid         : out std_logic;
         M_AXI_HPM1_FPD_0_araddr         : out std_logic_vector (39 downto 0);
         M_AXI_HPM1_FPD_0_arburst        : out std_logic_vector (1 downto 0);
         M_AXI_HPM1_FPD_0_arcache        : out std_logic_vector (3 downto 0);
         M_AXI_HPM1_FPD_0_arid           : out std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_arlen          : out std_logic_vector (7 downto 0);
         M_AXI_HPM1_FPD_0_arlock         : out std_logic;
         M_AXI_HPM1_FPD_0_arprot         : out std_logic_vector (2 downto 0);
         M_AXI_HPM1_FPD_0_arqos          : out std_logic_vector (3 downto 0);
         M_AXI_HPM1_FPD_0_arready        : in  std_logic;
         M_AXI_HPM1_FPD_0_arsize         : out std_logic_vector (2 downto 0);
         M_AXI_HPM1_FPD_0_aruser         : out std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_arvalid        : out std_logic;
         M_AXI_HPM1_FPD_0_awaddr         : out std_logic_vector (39 downto 0);
         M_AXI_HPM1_FPD_0_awburst        : out std_logic_vector (1 downto 0);
         M_AXI_HPM1_FPD_0_awcache        : out std_logic_vector (3 downto 0);
         M_AXI_HPM1_FPD_0_awid           : out std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_awlen          : out std_logic_vector (7 downto 0);
         M_AXI_HPM1_FPD_0_awlock         : out std_logic;
         M_AXI_HPM1_FPD_0_awprot         : out std_logic_vector (2 downto 0);
         M_AXI_HPM1_FPD_0_awqos          : out std_logic_vector (3 downto 0);
         M_AXI_HPM1_FPD_0_awready        : in  std_logic;
         M_AXI_HPM1_FPD_0_awsize         : out std_logic_vector (2 downto 0);
         M_AXI_HPM1_FPD_0_awuser         : out std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_awvalid        : out std_logic;
         M_AXI_HPM1_FPD_0_bid            : in  std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_bready         : out std_logic;
         M_AXI_HPM1_FPD_0_bresp          : in  std_logic_vector (1 downto 0);
         M_AXI_HPM1_FPD_0_bvalid         : in  std_logic;
         M_AXI_HPM1_FPD_0_rdata          : in  std_logic_vector (127 downto 0);
         M_AXI_HPM1_FPD_0_rid            : in  std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_rlast          : in  std_logic;
         M_AXI_HPM1_FPD_0_rready         : out std_logic;
         M_AXI_HPM1_FPD_0_rresp          : in  std_logic_vector (1 downto 0);
         M_AXI_HPM1_FPD_0_rvalid         : in  std_logic;
         M_AXI_HPM1_FPD_0_wdata          : out std_logic_vector (127 downto 0);
         M_AXI_HPM1_FPD_0_wlast          : out std_logic;
         M_AXI_HPM1_FPD_0_wready         : in  std_logic;
         M_AXI_HPM1_FPD_0_wstrb          : out std_logic_vector (15 downto 0);
         M_AXI_HPM1_FPD_0_wvalid         : out std_logic;
         S_AXI_ACP_FPD_0_araddr          : in  std_logic_vector (39 downto 0);
         S_AXI_ACP_FPD_0_arburst         : in  std_logic_vector (1 downto 0);
         S_AXI_ACP_FPD_0_arcache         : in  std_logic_vector (3 downto 0);
         S_AXI_ACP_FPD_0_arid            : in  std_logic_vector (4 downto 0);
         S_AXI_ACP_FPD_0_arlen           : in  std_logic_vector (7 downto 0);
         S_AXI_ACP_FPD_0_arlock          : in  std_logic;
         S_AXI_ACP_FPD_0_arprot          : in  std_logic_vector (2 downto 0);
         S_AXI_ACP_FPD_0_arqos           : in  std_logic_vector (3 downto 0);
         S_AXI_ACP_FPD_0_arready         : out std_logic;
         S_AXI_ACP_FPD_0_arsize          : in  std_logic_vector (2 downto 0);
         S_AXI_ACP_FPD_0_aruser          : in  std_logic_vector (1 downto 0);
         S_AXI_ACP_FPD_0_arvalid         : in  std_logic;
         S_AXI_ACP_FPD_0_awaddr          : in  std_logic_vector (39 downto 0);
         S_AXI_ACP_FPD_0_awburst         : in  std_logic_vector (1 downto 0);
         S_AXI_ACP_FPD_0_awcache         : in  std_logic_vector (3 downto 0);
         S_AXI_ACP_FPD_0_awid            : in  std_logic_vector (4 downto 0);
         S_AXI_ACP_FPD_0_awlen           : in  std_logic_vector (7 downto 0);
         S_AXI_ACP_FPD_0_awlock          : in  std_logic;
         S_AXI_ACP_FPD_0_awprot          : in  std_logic_vector (2 downto 0);
         S_AXI_ACP_FPD_0_awqos           : in  std_logic_vector (3 downto 0);
         S_AXI_ACP_FPD_0_awready         : out std_logic;
         S_AXI_ACP_FPD_0_awsize          : in  std_logic_vector (2 downto 0);
         S_AXI_ACP_FPD_0_awuser          : in  std_logic_vector (1 downto 0);
         S_AXI_ACP_FPD_0_awvalid         : in  std_logic;
         S_AXI_ACP_FPD_0_bid             : out std_logic_vector (4 downto 0);
         S_AXI_ACP_FPD_0_bready          : in  std_logic;
         S_AXI_ACP_FPD_0_bresp           : out std_logic_vector (1 downto 0);
         S_AXI_ACP_FPD_0_bvalid          : out std_logic;
         S_AXI_ACP_FPD_0_rdata           : out std_logic_vector (127 downto 0);
         S_AXI_ACP_FPD_0_rid             : out std_logic_vector (4 downto 0);
         S_AXI_ACP_FPD_0_rlast           : out std_logic;
         S_AXI_ACP_FPD_0_rready          : in  std_logic;
         S_AXI_ACP_FPD_0_rresp           : out std_logic_vector (1 downto 0);
         S_AXI_ACP_FPD_0_rvalid          : out std_logic;
         S_AXI_ACP_FPD_0_wdata           : in  std_logic_vector (127 downto 0);
         S_AXI_ACP_FPD_0_wlast           : in  std_logic;
         S_AXI_ACP_FPD_0_wready          : out std_logic;
         S_AXI_ACP_FPD_0_wstrb           : in  std_logic_vector (15 downto 0);
         S_AXI_ACP_FPD_0_wvalid          : in  std_logic;
         S_AXI_HP0_FPD_0_araddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP0_FPD_0_arburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP0_FPD_0_arcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP0_FPD_0_arid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP0_FPD_0_arlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP0_FPD_0_arlock          : in  std_logic;
         S_AXI_HP0_FPD_0_arprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP0_FPD_0_arqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP0_FPD_0_arready         : out std_logic;
         S_AXI_HP0_FPD_0_arsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP0_FPD_0_aruser          : in  std_logic;
         S_AXI_HP0_FPD_0_arvalid         : in  std_logic;
         S_AXI_HP0_FPD_0_awaddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP0_FPD_0_awburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP0_FPD_0_awcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP0_FPD_0_awid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP0_FPD_0_awlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP0_FPD_0_awlock          : in  std_logic;
         S_AXI_HP0_FPD_0_awprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP0_FPD_0_awqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP0_FPD_0_awready         : out std_logic;
         S_AXI_HP0_FPD_0_awsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP0_FPD_0_awuser          : in  std_logic;
         S_AXI_HP0_FPD_0_awvalid         : in  std_logic;
         S_AXI_HP0_FPD_0_bid             : out std_logic_vector (5 downto 0);
         S_AXI_HP0_FPD_0_bready          : in  std_logic;
         S_AXI_HP0_FPD_0_bresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP0_FPD_0_bvalid          : out std_logic;
         S_AXI_HP0_FPD_0_rdata           : out std_logic_vector (127 downto 0);
         S_AXI_HP0_FPD_0_rid             : out std_logic_vector (5 downto 0);
         S_AXI_HP0_FPD_0_rlast           : out std_logic;
         S_AXI_HP0_FPD_0_rready          : in  std_logic;
         S_AXI_HP0_FPD_0_rresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP0_FPD_0_rvalid          : out std_logic;
         S_AXI_HP0_FPD_0_wdata           : in  std_logic_vector (127 downto 0);
         S_AXI_HP0_FPD_0_wlast           : in  std_logic;
         S_AXI_HP0_FPD_0_wready          : out std_logic;
         S_AXI_HP0_FPD_0_wstrb           : in  std_logic_vector (15 downto 0);
         S_AXI_HP0_FPD_0_wvalid          : in  std_logic;
         S_AXI_HP1_FPD_0_araddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP1_FPD_0_arburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP1_FPD_0_arcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP1_FPD_0_arid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP1_FPD_0_arlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP1_FPD_0_arlock          : in  std_logic;
         S_AXI_HP1_FPD_0_arprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP1_FPD_0_arqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP1_FPD_0_arready         : out std_logic;
         S_AXI_HP1_FPD_0_arsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP1_FPD_0_aruser          : in  std_logic;
         S_AXI_HP1_FPD_0_arvalid         : in  std_logic;
         S_AXI_HP1_FPD_0_awaddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP1_FPD_0_awburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP1_FPD_0_awcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP1_FPD_0_awid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP1_FPD_0_awlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP1_FPD_0_awlock          : in  std_logic;
         S_AXI_HP1_FPD_0_awprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP1_FPD_0_awqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP1_FPD_0_awready         : out std_logic;
         S_AXI_HP1_FPD_0_awsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP1_FPD_0_awuser          : in  std_logic;
         S_AXI_HP1_FPD_0_awvalid         : in  std_logic;
         S_AXI_HP1_FPD_0_bid             : out std_logic_vector (5 downto 0);
         S_AXI_HP1_FPD_0_bready          : in  std_logic;
         S_AXI_HP1_FPD_0_bresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP1_FPD_0_bvalid          : out std_logic;
         S_AXI_HP1_FPD_0_rdata           : out std_logic_vector (127 downto 0);
         S_AXI_HP1_FPD_0_rid             : out std_logic_vector (5 downto 0);
         S_AXI_HP1_FPD_0_rlast           : out std_logic;
         S_AXI_HP1_FPD_0_rready          : in  std_logic;
         S_AXI_HP1_FPD_0_rresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP1_FPD_0_rvalid          : out std_logic;
         S_AXI_HP1_FPD_0_wdata           : in  std_logic_vector (127 downto 0);
         S_AXI_HP1_FPD_0_wlast           : in  std_logic;
         S_AXI_HP1_FPD_0_wready          : out std_logic;
         S_AXI_HP1_FPD_0_wstrb           : in  std_logic_vector (15 downto 0);
         S_AXI_HP1_FPD_0_wvalid          : in  std_logic;
         S_AXI_HP2_FPD_0_araddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP2_FPD_0_arburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP2_FPD_0_arcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP2_FPD_0_arid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP2_FPD_0_arlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP2_FPD_0_arlock          : in  std_logic;
         S_AXI_HP2_FPD_0_arprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP2_FPD_0_arqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP2_FPD_0_arready         : out std_logic;
         S_AXI_HP2_FPD_0_arsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP2_FPD_0_aruser          : in  std_logic;
         S_AXI_HP2_FPD_0_arvalid         : in  std_logic;
         S_AXI_HP2_FPD_0_awaddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP2_FPD_0_awburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP2_FPD_0_awcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP2_FPD_0_awid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP2_FPD_0_awlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP2_FPD_0_awlock          : in  std_logic;
         S_AXI_HP2_FPD_0_awprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP2_FPD_0_awqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP2_FPD_0_awready         : out std_logic;
         S_AXI_HP2_FPD_0_awsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP2_FPD_0_awuser          : in  std_logic;
         S_AXI_HP2_FPD_0_awvalid         : in  std_logic;
         S_AXI_HP2_FPD_0_bid             : out std_logic_vector (5 downto 0);
         S_AXI_HP2_FPD_0_bready          : in  std_logic;
         S_AXI_HP2_FPD_0_bresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP2_FPD_0_bvalid          : out std_logic;
         S_AXI_HP2_FPD_0_rdata           : out std_logic_vector (127 downto 0);
         S_AXI_HP2_FPD_0_rid             : out std_logic_vector (5 downto 0);
         S_AXI_HP2_FPD_0_rlast           : out std_logic;
         S_AXI_HP2_FPD_0_rready          : in  std_logic;
         S_AXI_HP2_FPD_0_rresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP2_FPD_0_rvalid          : out std_logic;
         S_AXI_HP2_FPD_0_wdata           : in  std_logic_vector (127 downto 0);
         S_AXI_HP2_FPD_0_wlast           : in  std_logic;
         S_AXI_HP2_FPD_0_wready          : out std_logic;
         S_AXI_HP2_FPD_0_wstrb           : in  std_logic_vector (15 downto 0);
         S_AXI_HP2_FPD_0_wvalid          : in  std_logic;
         S_AXI_HP3_FPD_0_araddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP3_FPD_0_arburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP3_FPD_0_arcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP3_FPD_0_arid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP3_FPD_0_arlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP3_FPD_0_arlock          : in  std_logic;
         S_AXI_HP3_FPD_0_arprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP3_FPD_0_arqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP3_FPD_0_arready         : out std_logic;
         S_AXI_HP3_FPD_0_arsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP3_FPD_0_aruser          : in  std_logic;
         S_AXI_HP3_FPD_0_arvalid         : in  std_logic;
         S_AXI_HP3_FPD_0_awaddr          : in  std_logic_vector (48 downto 0);
         S_AXI_HP3_FPD_0_awburst         : in  std_logic_vector (1 downto 0);
         S_AXI_HP3_FPD_0_awcache         : in  std_logic_vector (3 downto 0);
         S_AXI_HP3_FPD_0_awid            : in  std_logic_vector (5 downto 0);
         S_AXI_HP3_FPD_0_awlen           : in  std_logic_vector (7 downto 0);
         S_AXI_HP3_FPD_0_awlock          : in  std_logic;
         S_AXI_HP3_FPD_0_awprot          : in  std_logic_vector (2 downto 0);
         S_AXI_HP3_FPD_0_awqos           : in  std_logic_vector (3 downto 0);
         S_AXI_HP3_FPD_0_awready         : out std_logic;
         S_AXI_HP3_FPD_0_awsize          : in  std_logic_vector (2 downto 0);
         S_AXI_HP3_FPD_0_awuser          : in  std_logic;
         S_AXI_HP3_FPD_0_awvalid         : in  std_logic;
         S_AXI_HP3_FPD_0_bid             : out std_logic_vector (5 downto 0);
         S_AXI_HP3_FPD_0_bready          : in  std_logic;
         S_AXI_HP3_FPD_0_bresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP3_FPD_0_bvalid          : out std_logic;
         S_AXI_HP3_FPD_0_rdata           : out std_logic_vector (127 downto 0);
         S_AXI_HP3_FPD_0_rid             : out std_logic_vector (5 downto 0);
         S_AXI_HP3_FPD_0_rlast           : out std_logic;
         S_AXI_HP3_FPD_0_rready          : in  std_logic;
         S_AXI_HP3_FPD_0_rresp           : out std_logic_vector (1 downto 0);
         S_AXI_HP3_FPD_0_rvalid          : out std_logic;
         S_AXI_HP3_FPD_0_wdata           : in  std_logic_vector (127 downto 0);
         S_AXI_HP3_FPD_0_wlast           : in  std_logic;
         S_AXI_HP3_FPD_0_wready          : out std_logic;
         S_AXI_HP3_FPD_0_wstrb           : in  std_logic_vector (15 downto 0);
         S_AXI_HP3_FPD_0_wvalid          : in  std_logic;
         S_AXI_HPC0_FPD_0_araddr         : in  std_logic_vector (48 downto 0);
         S_AXI_HPC0_FPD_0_arburst        : in  std_logic_vector (1 downto 0);
         S_AXI_HPC0_FPD_0_arcache        : in  std_logic_vector (3 downto 0);
         S_AXI_HPC0_FPD_0_arid           : in  std_logic_vector (5 downto 0);
         S_AXI_HPC0_FPD_0_arlen          : in  std_logic_vector (7 downto 0);
         S_AXI_HPC0_FPD_0_arlock         : in  std_logic;
         S_AXI_HPC0_FPD_0_arprot         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC0_FPD_0_arqos          : in  std_logic_vector (3 downto 0);
         S_AXI_HPC0_FPD_0_arready        : out std_logic;
         S_AXI_HPC0_FPD_0_arsize         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC0_FPD_0_aruser         : in  std_logic;
         S_AXI_HPC0_FPD_0_arvalid        : in  std_logic;
         S_AXI_HPC0_FPD_0_awaddr         : in  std_logic_vector (48 downto 0);
         S_AXI_HPC0_FPD_0_awburst        : in  std_logic_vector (1 downto 0);
         S_AXI_HPC0_FPD_0_awcache        : in  std_logic_vector (3 downto 0);
         S_AXI_HPC0_FPD_0_awid           : in  std_logic_vector (5 downto 0);
         S_AXI_HPC0_FPD_0_awlen          : in  std_logic_vector (7 downto 0);
         S_AXI_HPC0_FPD_0_awlock         : in  std_logic;
         S_AXI_HPC0_FPD_0_awprot         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC0_FPD_0_awqos          : in  std_logic_vector (3 downto 0);
         S_AXI_HPC0_FPD_0_awready        : out std_logic;
         S_AXI_HPC0_FPD_0_awsize         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC0_FPD_0_awuser         : in  std_logic;
         S_AXI_HPC0_FPD_0_awvalid        : in  std_logic;
         S_AXI_HPC0_FPD_0_bid            : out std_logic_vector (5 downto 0);
         S_AXI_HPC0_FPD_0_bready         : in  std_logic;
         S_AXI_HPC0_FPD_0_bresp          : out std_logic_vector (1 downto 0);
         S_AXI_HPC0_FPD_0_bvalid         : out std_logic;
         S_AXI_HPC0_FPD_0_rdata          : out std_logic_vector (127 downto 0);
         S_AXI_HPC0_FPD_0_rid            : out std_logic_vector (5 downto 0);
         S_AXI_HPC0_FPD_0_rlast          : out std_logic;
         S_AXI_HPC0_FPD_0_rready         : in  std_logic;
         S_AXI_HPC0_FPD_0_rresp          : out std_logic_vector (1 downto 0);
         S_AXI_HPC0_FPD_0_rvalid         : out std_logic;
         S_AXI_HPC0_FPD_0_wdata          : in  std_logic_vector (127 downto 0);
         S_AXI_HPC0_FPD_0_wlast          : in  std_logic;
         S_AXI_HPC0_FPD_0_wready         : out std_logic;
         S_AXI_HPC0_FPD_0_wstrb          : in  std_logic_vector (15 downto 0);
         S_AXI_HPC0_FPD_0_wvalid         : in  std_logic;
         S_AXI_HPC1_FPD_0_araddr         : in  std_logic_vector (48 downto 0);
         S_AXI_HPC1_FPD_0_arburst        : in  std_logic_vector (1 downto 0);
         S_AXI_HPC1_FPD_0_arcache        : in  std_logic_vector (3 downto 0);
         S_AXI_HPC1_FPD_0_arid           : in  std_logic_vector (5 downto 0);
         S_AXI_HPC1_FPD_0_arlen          : in  std_logic_vector (7 downto 0);
         S_AXI_HPC1_FPD_0_arlock         : in  std_logic;
         S_AXI_HPC1_FPD_0_arprot         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC1_FPD_0_arqos          : in  std_logic_vector (3 downto 0);
         S_AXI_HPC1_FPD_0_arready        : out std_logic;
         S_AXI_HPC1_FPD_0_arsize         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC1_FPD_0_aruser         : in  std_logic;
         S_AXI_HPC1_FPD_0_arvalid        : in  std_logic;
         S_AXI_HPC1_FPD_0_awaddr         : in  std_logic_vector (48 downto 0);
         S_AXI_HPC1_FPD_0_awburst        : in  std_logic_vector (1 downto 0);
         S_AXI_HPC1_FPD_0_awcache        : in  std_logic_vector (3 downto 0);
         S_AXI_HPC1_FPD_0_awid           : in  std_logic_vector (5 downto 0);
         S_AXI_HPC1_FPD_0_awlen          : in  std_logic_vector (7 downto 0);
         S_AXI_HPC1_FPD_0_awlock         : in  std_logic;
         S_AXI_HPC1_FPD_0_awprot         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC1_FPD_0_awqos          : in  std_logic_vector (3 downto 0);
         S_AXI_HPC1_FPD_0_awready        : out std_logic;
         S_AXI_HPC1_FPD_0_awsize         : in  std_logic_vector (2 downto 0);
         S_AXI_HPC1_FPD_0_awuser         : in  std_logic;
         S_AXI_HPC1_FPD_0_awvalid        : in  std_logic;
         S_AXI_HPC1_FPD_0_bid            : out std_logic_vector (5 downto 0);
         S_AXI_HPC1_FPD_0_bready         : in  std_logic;
         S_AXI_HPC1_FPD_0_bresp          : out std_logic_vector (1 downto 0);
         S_AXI_HPC1_FPD_0_bvalid         : out std_logic;
         S_AXI_HPC1_FPD_0_rdata          : out std_logic_vector (127 downto 0);
         S_AXI_HPC1_FPD_0_rid            : out std_logic_vector (5 downto 0);
         S_AXI_HPC1_FPD_0_rlast          : out std_logic;
         S_AXI_HPC1_FPD_0_rready         : in  std_logic;
         S_AXI_HPC1_FPD_0_rresp          : out std_logic_vector (1 downto 0);
         S_AXI_HPC1_FPD_0_rvalid         : out std_logic;
         S_AXI_HPC1_FPD_0_wdata          : in  std_logic_vector (127 downto 0);
         S_AXI_HPC1_FPD_0_wlast          : in  std_logic;
         S_AXI_HPC1_FPD_0_wready         : out std_logic;
         S_AXI_HPC1_FPD_0_wstrb          : in  std_logic_vector (15 downto 0);
         S_AXI_HPC1_FPD_0_wvalid         : in  std_logic;
         emio_enet0_dma_bus_width_0      : out std_logic_vector (1 downto 0);
         emio_enet0_enet_tsu_timer_cnt_0 : out std_logic_vector (93 downto 0);
         emio_enet0_ext_int_in_0         : in  std_logic;
         emio_enet0_tsu_inc_ctrl_0       : in  std_logic_vector (1 downto 0);
         emio_enet0_tsu_timer_cmp_val_0  : out std_logic;
         emio_enet1_dma_bus_width_0      : out std_logic_vector (1 downto 0);
         emio_enet1_ext_int_in_0         : in  std_logic;
         emio_enet1_tsu_inc_ctrl_0       : in  std_logic_vector (1 downto 0);
         emio_enet1_tsu_timer_cmp_val_0  : out std_logic;
         maxihpm0_fpd_aclk_0             : in  std_logic;
         maxihpm1_fpd_aclk_0             : in  std_logic;
         pl_acpinact_0                   : in  std_logic;
         pl_clk0_0                       : out std_logic;
         pl_clk1_0                       : out std_logic;
         pl_clk2_0                       : out std_logic;
         pl_clk3_0                       : out std_logic;
         pl_ps_irq0_0                    : in  std_logic_vector (7 downto 0);
         pl_ps_irq1_0                    : in  std_logic_vector (7 downto 0);
         saxiacp_fpd_aclk_0              : in  std_logic;
         saxihp0_fpd_aclk_0              : in  std_logic;
         saxihp1_fpd_aclk_0              : in  std_logic;
         saxihp2_fpd_aclk_0              : in  std_logic;
         saxihp3_fpd_aclk_0              : in  std_logic;
         saxihpc0_fpd_aclk_0             : in  std_logic;
         saxihpc1_fpd_aclk_0             : in  std_logic
         );
   end component Base_Zynq_MPSoC;

   signal mGpWriteMasterOut : AxiWriteMasterArray(1 downto 0) := (others => AXI_WRITE_MASTER_INIT_C);
   signal mGpReadMasterOut  : AxiReadMasterArray(1 downto 0)  := (others => AXI_READ_MASTER_INIT_C);

   signal sGpWriteSlaveOut : AxiWriteSlaveArray(1 downto 0) := (others => AXI_WRITE_SLAVE_INIT_C);
   signal sGpReadSlaveOut  : AxiReadSlaveArray(1 downto 0)  := (others => AXI_READ_SLAVE_INIT_C);

   signal acpWriteSlaveOut : AxiWriteSlaveType := AXI_WRITE_SLAVE_INIT_C;
   signal acpReadSlaveOut  : AxiReadSlaveType  := AXI_READ_SLAVE_INIT_C;

   signal hpWriteSlaveOut : AxiWriteSlaveArray(3 downto 0) := (others => AXI_WRITE_SLAVE_INIT_C);
   signal hpReadSlaveOut  : AxiReadSlaveArray(3 downto 0)  := (others => AXI_READ_SLAVE_INIT_C);

   signal fclk : slv(3 downto 0) := (others => '0');
   signal frst : slv(3 downto 0) := (others => '1');

begin

   --------------------------
   -- AXI Output Assignments
   --------------------------

   mGpWriteMaster <= mGpWriteMasterOut;
   mGpReadMaster  <= mGpReadMasterOut;

   sGpWriteSlave <= sGpWriteSlaveOut;
   sGpReadSlave  <= sGpReadSlaveOut;

   acpWriteSlave <= acpWriteSlaveOut;
   acpReadSlave  <= acpReadSlaveOut;

   hpWriteSlave <= hpWriteSlaveOut;
   hpReadSlave  <= hpReadSlaveOut;

   --------------------------
   -- Processor system module
   --------------------------
   U_CPU : Base_Zynq_MPSoC
      port map (
         -- M_AXI_GP0
         maxihpm0_fpd_aclk_0             => mGpAxiClk(0),
         M_AXI_HPM0_FPD_0_awid           => mGpWriteMasterOut(0).awid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM0_FPD_0_awaddr         => mGpWriteMasterOut(0).awaddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         M_AXI_HPM0_FPD_0_awlen          => mGpWriteMasterOut(0).awlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         M_AXI_HPM0_FPD_0_awsize         => mGpWriteMasterOut(0).awsize,
         M_AXI_HPM0_FPD_0_awburst        => mGpWriteMasterOut(0).awburst,
         M_AXI_HPM0_FPD_0_awlock         => mGpWriteMasterOut(0).awlock(0),
         M_AXI_HPM0_FPD_0_awcache        => mGpWriteMasterOut(0).awcache,
         M_AXI_HPM0_FPD_0_awprot         => mGpWriteMasterOut(0).awprot,
         M_AXI_HPM0_FPD_0_awvalid        => mGpWriteMasterOut(0).awvalid,
         M_AXI_HPM0_FPD_0_awuser         => open,
         M_AXI_HPM0_FPD_0_awready        => mGpWriteSlave(0).awready,
         M_AXI_HPM0_FPD_0_wdata          => mGpWriteMasterOut(0).wdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         M_AXI_HPM0_FPD_0_wstrb          => mGpWriteMasterOut(0).wstrb(AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         M_AXI_HPM0_FPD_0_wlast          => mGpWriteMasterOut(0).wlast,
         M_AXI_HPM0_FPD_0_wvalid         => mGpWriteMasterOut(0).wvalid,
         M_AXI_HPM0_FPD_0_wready         => mGpWriteSlave(0).wready,
         M_AXI_HPM0_FPD_0_bid            => mGpWriteSlave(0).bid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM0_FPD_0_bresp          => mGpWriteSlave(0).bresp,
         M_AXI_HPM0_FPD_0_bvalid         => mGpWriteSlave(0).bvalid,
         M_AXI_HPM0_FPD_0_bready         => mGpWriteMasterOut(0).bready,
         M_AXI_HPM0_FPD_0_arid           => mGpReadMasterOut(0).arid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM0_FPD_0_araddr         => mGpReadMasterOut(0).araddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         M_AXI_HPM0_FPD_0_arlen          => mGpReadMasterOut(0).arlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         M_AXI_HPM0_FPD_0_arsize         => mGpReadMasterOut(0).arsize,
         M_AXI_HPM0_FPD_0_arburst        => mGpReadMasterOut(0).arburst,
         M_AXI_HPM0_FPD_0_arlock         => mGpReadMasterOut(0).arlock(0),
         M_AXI_HPM0_FPD_0_arcache        => mGpReadMasterOut(0).arcache,
         M_AXI_HPM0_FPD_0_arprot         => mGpReadMasterOut(0).arprot,
         M_AXI_HPM0_FPD_0_arvalid        => mGpReadMasterOut(0).arvalid,
         M_AXI_HPM0_FPD_0_aruser         => open,
         M_AXI_HPM0_FPD_0_arready        => mGpReadSlave(0).arready,
         M_AXI_HPM0_FPD_0_rid            => mGpReadSlave(0).rid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM0_FPD_0_rdata          => mGpReadSlave(0).rdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         M_AXI_HPM0_FPD_0_rresp          => mGpReadSlave(0).rresp,
         M_AXI_HPM0_FPD_0_rlast          => mGpReadSlave(0).rlast,
         M_AXI_HPM0_FPD_0_rvalid         => mGpReadSlave(0).rvalid,
         M_AXI_HPM0_FPD_0_rready         => mGpReadMasterOut(0).rready,
         M_AXI_HPM0_FPD_0_awqos          => open,
         M_AXI_HPM0_FPD_0_arqos          => open,
         -- M_AXI_GP1
         maxihpm1_fpd_aclk_0             => mGpAxiClk(1),
         M_AXI_HPM1_FPD_0_awid           => mGpWriteMasterOut(1).awid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM1_FPD_0_awaddr         => mGpWriteMasterOut(1).awaddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         M_AXI_HPM1_FPD_0_awlen          => mGpWriteMasterOut(1).awlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         M_AXI_HPM1_FPD_0_awsize         => mGpWriteMasterOut(1).awsize,
         M_AXI_HPM1_FPD_0_awburst        => mGpWriteMasterOut(1).awburst,
         M_AXI_HPM1_FPD_0_awlock         => mGpWriteMasterOut(1).awlock(0),
         M_AXI_HPM1_FPD_0_awcache        => mGpWriteMasterOut(1).awcache,
         M_AXI_HPM1_FPD_0_awprot         => mGpWriteMasterOut(1).awprot,
         M_AXI_HPM1_FPD_0_awvalid        => mGpWriteMasterOut(1).awvalid,
         M_AXI_HPM1_FPD_0_awuser         => open,
         M_AXI_HPM1_FPD_0_awready        => mGpWriteSlave(1).awready,
         M_AXI_HPM1_FPD_0_wdata          => mGpWriteMasterOut(1).wdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         M_AXI_HPM1_FPD_0_wstrb          => mGpWriteMasterOut(1).wstrb(AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         M_AXI_HPM1_FPD_0_wlast          => mGpWriteMasterOut(1).wlast,
         M_AXI_HPM1_FPD_0_wvalid         => mGpWriteMasterOut(1).wvalid,
         M_AXI_HPM1_FPD_0_wready         => mGpWriteSlave(1).wready,
         M_AXI_HPM1_FPD_0_bid            => mGpWriteSlave(1).bid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM1_FPD_0_bresp          => mGpWriteSlave(1).bresp,
         M_AXI_HPM1_FPD_0_bvalid         => mGpWriteSlave(1).bvalid,
         M_AXI_HPM1_FPD_0_bready         => mGpWriteMasterOut(1).bready,
         M_AXI_HPM1_FPD_0_arid           => mGpReadMasterOut(1).arid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM1_FPD_0_araddr         => mGpReadMasterOut(1).araddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         M_AXI_HPM1_FPD_0_arlen          => mGpReadMasterOut(1).arlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         M_AXI_HPM1_FPD_0_arsize         => mGpReadMasterOut(1).arsize,
         M_AXI_HPM1_FPD_0_arburst        => mGpReadMasterOut(1).arburst,
         M_AXI_HPM1_FPD_0_arlock         => mGpReadMasterOut(1).arlock(0),
         M_AXI_HPM1_FPD_0_arcache        => mGpReadMasterOut(1).arcache,
         M_AXI_HPM1_FPD_0_arprot         => mGpReadMasterOut(1).arprot,
         M_AXI_HPM1_FPD_0_arvalid        => mGpReadMasterOut(1).arvalid,
         M_AXI_HPM1_FPD_0_aruser         => open,
         M_AXI_HPM1_FPD_0_arready        => mGpReadSlave(1).arready,
         M_AXI_HPM1_FPD_0_rid            => mGpReadSlave(1).rid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         M_AXI_HPM1_FPD_0_rdata          => mGpReadSlave(1).rdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         M_AXI_HPM1_FPD_0_rresp          => mGpReadSlave(1).rresp,
         M_AXI_HPM1_FPD_0_rlast          => mGpReadSlave(1).rlast,
         M_AXI_HPM1_FPD_0_rvalid         => mGpReadSlave(1).rvalid,
         M_AXI_HPM1_FPD_0_rready         => mGpReadMasterOut(1).rready,
         M_AXI_HPM1_FPD_0_awqos          => open,
         M_AXI_HPM1_FPD_0_arqos          => open,
         -- S_AXI_GP0
         saxihpc0_fpd_aclk_0             => sGpAxiClk(0),
         S_AXI_HPC0_FPD_0_aruser         => '0',
         S_AXI_HPC0_FPD_0_awuser         => '0',
         S_AXI_HPC0_FPD_0_awid           => sGpWriteMaster(0).awid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC0_FPD_0_awaddr         => sGpWriteMaster(0).awaddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HPC0_FPD_0_awlen          => sGpWriteMaster(0).awlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HPC0_FPD_0_awsize         => sGpWriteMaster(0).awsize,
         S_AXI_HPC0_FPD_0_awburst        => sGpWriteMaster(0).awburst,
         S_AXI_HPC0_FPD_0_awlock         => sGpWriteMaster(0).awlock(0),
         S_AXI_HPC0_FPD_0_awcache        => sGpWriteMaster(0).awcache,
         S_AXI_HPC0_FPD_0_awprot         => sGpWriteMaster(0).awprot,
         S_AXI_HPC0_FPD_0_awvalid        => sGpWriteMaster(0).awvalid,
         S_AXI_HPC0_FPD_0_awready        => sGpWriteSlaveOut(0).awready,
         S_AXI_HPC0_FPD_0_wdata          => sGpWriteMaster(0).wdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HPC0_FPD_0_wstrb          => sGpWriteMaster(0).wstrb(AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HPC0_FPD_0_wlast          => sGpWriteMaster(0).wlast,
         S_AXI_HPC0_FPD_0_wvalid         => sGpWriteMaster(0).wvalid,
         S_AXI_HPC0_FPD_0_wready         => sGpWriteSlaveOut(0).wready,
         S_AXI_HPC0_FPD_0_bid            => sGpWriteSlaveOut(0).bid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC0_FPD_0_bresp          => sGpWriteSlaveOut(0).bresp,
         S_AXI_HPC0_FPD_0_bvalid         => sGpWriteSlaveOut(0).bvalid,
         S_AXI_HPC0_FPD_0_bready         => sGpWriteMaster(0).bready,
         S_AXI_HPC0_FPD_0_arid           => sGpReadMaster(0).arid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC0_FPD_0_araddr         => sGpReadMaster(0).araddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HPC0_FPD_0_arlen          => sGpReadMaster(0).arlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HPC0_FPD_0_arsize         => sGpReadMaster(0).arsize,
         S_AXI_HPC0_FPD_0_arburst        => sGpReadMaster(0).arburst,
         S_AXI_HPC0_FPD_0_arlock         => sGpReadMaster(0).arlock(0),
         S_AXI_HPC0_FPD_0_arcache        => sGpReadMaster(0).arcache,
         S_AXI_HPC0_FPD_0_arprot         => sGpReadMaster(0).arprot,
         S_AXI_HPC0_FPD_0_arvalid        => sGpReadMaster(0).arvalid,
         S_AXI_HPC0_FPD_0_arready        => sGpReadSlaveOut(0).arready,
         S_AXI_HPC0_FPD_0_rid            => sGpReadSlaveOut(0).rid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC0_FPD_0_rdata          => sGpReadSlaveOut(0).rdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HPC0_FPD_0_rresp          => sGpReadSlaveOut(0).rresp,
         S_AXI_HPC0_FPD_0_rlast          => sGpReadSlaveOut(0).rlast,
         S_AXI_HPC0_FPD_0_rvalid         => sGpReadSlaveOut(0).rvalid,
         S_AXI_HPC0_FPD_0_rready         => sGpReadMaster(0).rready,
         S_AXI_HPC0_FPD_0_awqos          => "1111",  -- Highest priority
         S_AXI_HPC0_FPD_0_arqos          => "1111",  -- Highest priority
         -- S_AXI_GP1
         saxihpc1_fpd_aclk_0             => sGpAxiClk(1),
         S_AXI_HPC1_FPD_0_aruser         => '0',
         S_AXI_HPC1_FPD_0_awuser         => '0',
         S_AXI_HPC1_FPD_0_awid           => sGpWriteMaster(1).awid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC1_FPD_0_awaddr         => sGpWriteMaster(1).awaddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HPC1_FPD_0_awlen          => sGpWriteMaster(1).awlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HPC1_FPD_0_awsize         => sGpWriteMaster(1).awsize,
         S_AXI_HPC1_FPD_0_awburst        => sGpWriteMaster(1).awburst,
         S_AXI_HPC1_FPD_0_awlock         => sGpWriteMaster(1).awlock(0),
         S_AXI_HPC1_FPD_0_awcache        => sGpWriteMaster(1).awcache,
         S_AXI_HPC1_FPD_0_awprot         => sGpWriteMaster(1).awprot,
         S_AXI_HPC1_FPD_0_awvalid        => sGpWriteMaster(1).awvalid,
         S_AXI_HPC1_FPD_0_awready        => sGpWriteSlaveOut(1).awready,
         S_AXI_HPC1_FPD_0_wdata          => sGpWriteMaster(1).wdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HPC1_FPD_0_wstrb          => sGpWriteMaster(1).wstrb(AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HPC1_FPD_0_wlast          => sGpWriteMaster(1).wlast,
         S_AXI_HPC1_FPD_0_wvalid         => sGpWriteMaster(1).wvalid,
         S_AXI_HPC1_FPD_0_wready         => sGpWriteSlaveOut(1).wready,
         S_AXI_HPC1_FPD_0_bid            => sGpWriteSlaveOut(1).bid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC1_FPD_0_bresp          => sGpWriteSlaveOut(1).bresp,
         S_AXI_HPC1_FPD_0_bvalid         => sGpWriteSlaveOut(1).bvalid,
         S_AXI_HPC1_FPD_0_bready         => sGpWriteMaster(1).bready,
         S_AXI_HPC1_FPD_0_arid           => sGpReadMaster(1).arid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC1_FPD_0_araddr         => sGpReadMaster(1).araddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HPC1_FPD_0_arlen          => sGpReadMaster(1).arlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HPC1_FPD_0_arsize         => sGpReadMaster(1).arsize,
         S_AXI_HPC1_FPD_0_arburst        => sGpReadMaster(1).arburst,
         S_AXI_HPC1_FPD_0_arlock         => sGpReadMaster(1).arlock(0),
         S_AXI_HPC1_FPD_0_arcache        => sGpReadMaster(1).arcache,
         S_AXI_HPC1_FPD_0_arprot         => sGpReadMaster(1).arprot,
         S_AXI_HPC1_FPD_0_arvalid        => sGpReadMaster(1).arvalid,
         S_AXI_HPC1_FPD_0_arready        => sGpReadSlaveOut(1).arready,
         S_AXI_HPC1_FPD_0_rid            => sGpReadSlaveOut(1).rid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HPC1_FPD_0_rdata          => sGpReadSlaveOut(1).rdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HPC1_FPD_0_rresp          => sGpReadSlaveOut(1).rresp,
         S_AXI_HPC1_FPD_0_rlast          => sGpReadSlaveOut(1).rlast,
         S_AXI_HPC1_FPD_0_rvalid         => sGpReadSlaveOut(1).rvalid,
         S_AXI_HPC1_FPD_0_rready         => sGpReadMaster(1).rready,
         S_AXI_HPC1_FPD_0_awqos          => "1111",  -- Highest priority
         S_AXI_HPC1_FPD_0_arqos          => "1111",  -- Highest priority
         -- S_AXI_HP_0
         saxihp0_fpd_aclk_0              => hpAxiClk(0),
         S_AXI_HP0_FPD_0_aruser          => '0',
         S_AXI_HP0_FPD_0_awuser          => '0',
         S_AXI_HP0_FPD_0_awid            => hpWriteMaster(0).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP0_FPD_0_awaddr          => hpWriteMaster(0).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP0_FPD_0_awlen           => hpWriteMaster(0).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP0_FPD_0_awsize          => hpWriteMaster(0).awsize,
         S_AXI_HP0_FPD_0_awburst         => hpWriteMaster(0).awburst,
         S_AXI_HP0_FPD_0_awlock          => hpWriteMaster(0).awlock(0),
         S_AXI_HP0_FPD_0_awcache         => hpWriteMaster(0).awcache,
         S_AXI_HP0_FPD_0_awprot          => hpWriteMaster(0).awprot,
         S_AXI_HP0_FPD_0_awvalid         => hpWriteMaster(0).awvalid,
         S_AXI_HP0_FPD_0_awready         => hpWriteSlaveOut(0).awready,
         S_AXI_HP0_FPD_0_wdata           => hpWriteMaster(0).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP0_FPD_0_wstrb           => hpWriteMaster(0).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP0_FPD_0_wlast           => hpWriteMaster(0).wlast,
         S_AXI_HP0_FPD_0_wvalid          => hpWriteMaster(0).wvalid,
         S_AXI_HP0_FPD_0_wready          => hpWriteSlaveOut(0).wready,
         S_AXI_HP0_FPD_0_bid             => hpWriteSlaveOut(0).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP0_FPD_0_bresp           => hpWriteSlaveOut(0).bresp,
         S_AXI_HP0_FPD_0_bvalid          => hpWriteSlaveOut(0).bvalid,
         S_AXI_HP0_FPD_0_bready          => hpWriteMaster(0).bready,
         S_AXI_HP0_FPD_0_arid            => hpReadMaster(0).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP0_FPD_0_araddr          => hpReadMaster(0).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP0_FPD_0_arlen           => hpReadMaster(0).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP0_FPD_0_arsize          => hpReadMaster(0).arsize,
         S_AXI_HP0_FPD_0_arburst         => hpReadMaster(0).arburst,
         S_AXI_HP0_FPD_0_arlock          => hpReadMaster(0).arlock(0),
         S_AXI_HP0_FPD_0_arcache         => hpReadMaster(0).arcache,
         S_AXI_HP0_FPD_0_arprot          => hpReadMaster(0).arprot,
         S_AXI_HP0_FPD_0_arvalid         => hpReadMaster(0).arvalid,
         S_AXI_HP0_FPD_0_arready         => hpReadSlaveOut(0).arready,
         S_AXI_HP0_FPD_0_rid             => hpReadSlaveOut(0).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP0_FPD_0_rdata           => hpReadSlaveOut(0).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP0_FPD_0_rresp           => hpReadSlaveOut(0).rresp,
         S_AXI_HP0_FPD_0_rlast           => hpReadSlaveOut(0).rlast,
         S_AXI_HP0_FPD_0_rvalid          => hpReadSlaveOut(0).rvalid,
         S_AXI_HP0_FPD_0_rready          => hpReadMaster(0).rready,
         S_AXI_HP0_FPD_0_awqos           => "0000",
         S_AXI_HP0_FPD_0_arqos           => "0000",
         -- S_AXI_HP_1
         saxihp1_fpd_aclk_0              => hpAxiClk(1),
         S_AXI_HP1_FPD_0_aruser          => '0',
         S_AXI_HP1_FPD_0_awuser          => '0',
         S_AXI_HP1_FPD_0_awid            => hpWriteMaster(1).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP1_FPD_0_awaddr          => hpWriteMaster(1).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP1_FPD_0_awlen           => hpWriteMaster(1).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP1_FPD_0_awsize          => hpWriteMaster(1).awsize,
         S_AXI_HP1_FPD_0_awburst         => hpWriteMaster(1).awburst,
         S_AXI_HP1_FPD_0_awlock          => hpWriteMaster(1).awlock(0),
         S_AXI_HP1_FPD_0_awcache         => hpWriteMaster(1).awcache,
         S_AXI_HP1_FPD_0_awprot          => hpWriteMaster(1).awprot,
         S_AXI_HP1_FPD_0_awvalid         => hpWriteMaster(1).awvalid,
         S_AXI_HP1_FPD_0_awready         => hpWriteSlaveOut(1).awready,
         S_AXI_HP1_FPD_0_wdata           => hpWriteMaster(1).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP1_FPD_0_wstrb           => hpWriteMaster(1).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP1_FPD_0_wlast           => hpWriteMaster(1).wlast,
         S_AXI_HP1_FPD_0_wvalid          => hpWriteMaster(1).wvalid,
         S_AXI_HP1_FPD_0_wready          => hpWriteSlaveOut(1).wready,
         S_AXI_HP1_FPD_0_bid             => hpWriteSlaveOut(1).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP1_FPD_0_bresp           => hpWriteSlaveOut(1).bresp,
         S_AXI_HP1_FPD_0_bvalid          => hpWriteSlaveOut(1).bvalid,
         S_AXI_HP1_FPD_0_bready          => hpWriteMaster(1).bready,
         S_AXI_HP1_FPD_0_arid            => hpReadMaster(1).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP1_FPD_0_araddr          => hpReadMaster(1).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP1_FPD_0_arlen           => hpReadMaster(1).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP1_FPD_0_arsize          => hpReadMaster(1).arsize,
         S_AXI_HP1_FPD_0_arburst         => hpReadMaster(1).arburst,
         S_AXI_HP1_FPD_0_arlock          => hpReadMaster(1).arlock(0),
         S_AXI_HP1_FPD_0_arcache         => hpReadMaster(1).arcache,
         S_AXI_HP1_FPD_0_arprot          => hpReadMaster(1).arprot,
         S_AXI_HP1_FPD_0_arvalid         => hpReadMaster(1).arvalid,
         S_AXI_HP1_FPD_0_arready         => hpReadSlaveOut(1).arready,
         S_AXI_HP1_FPD_0_rid             => hpReadSlaveOut(1).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP1_FPD_0_rdata           => hpReadSlaveOut(1).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP1_FPD_0_rresp           => hpReadSlaveOut(1).rresp,
         S_AXI_HP1_FPD_0_rlast           => hpReadSlaveOut(1).rlast,
         S_AXI_HP1_FPD_0_rvalid          => hpReadSlaveOut(1).rvalid,
         S_AXI_HP1_FPD_0_rready          => hpReadMaster(1).rready,
         S_AXI_HP1_FPD_0_awqos           => "0000",
         S_AXI_HP1_FPD_0_arqos           => "0000",
         -- S_AXI_HP_2
         saxihp2_fpd_aclk_0              => hpAxiClk(2),
         S_AXI_HP2_FPD_0_aruser          => '0',
         S_AXI_HP2_FPD_0_awuser          => '0',
         S_AXI_HP2_FPD_0_awid            => hpWriteMaster(2).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP2_FPD_0_awaddr          => hpWriteMaster(2).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP2_FPD_0_awlen           => hpWriteMaster(2).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP2_FPD_0_awsize          => hpWriteMaster(2).awsize,
         S_AXI_HP2_FPD_0_awburst         => hpWriteMaster(2).awburst,
         S_AXI_HP2_FPD_0_awlock          => hpWriteMaster(2).awlock(0),
         S_AXI_HP2_FPD_0_awcache         => hpWriteMaster(2).awcache,
         S_AXI_HP2_FPD_0_awprot          => hpWriteMaster(2).awprot,
         S_AXI_HP2_FPD_0_awvalid         => hpWriteMaster(2).awvalid,
         S_AXI_HP2_FPD_0_awready         => hpWriteSlaveOut(2).awready,
         S_AXI_HP2_FPD_0_wdata           => hpWriteMaster(2).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP2_FPD_0_wstrb           => hpWriteMaster(2).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP2_FPD_0_wlast           => hpWriteMaster(2).wlast,
         S_AXI_HP2_FPD_0_wvalid          => hpWriteMaster(2).wvalid,
         S_AXI_HP2_FPD_0_wready          => hpWriteSlaveOut(2).wready,
         S_AXI_HP2_FPD_0_bid             => hpWriteSlaveOut(2).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP2_FPD_0_bresp           => hpWriteSlaveOut(2).bresp,
         S_AXI_HP2_FPD_0_bvalid          => hpWriteSlaveOut(2).bvalid,
         S_AXI_HP2_FPD_0_bready          => hpWriteMaster(2).bready,
         S_AXI_HP2_FPD_0_arid            => hpReadMaster(2).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP2_FPD_0_araddr          => hpReadMaster(2).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP2_FPD_0_arlen           => hpReadMaster(2).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP2_FPD_0_arsize          => hpReadMaster(2).arsize,
         S_AXI_HP2_FPD_0_arburst         => hpReadMaster(2).arburst,
         S_AXI_HP2_FPD_0_arlock          => hpReadMaster(2).arlock(0),
         S_AXI_HP2_FPD_0_arcache         => hpReadMaster(2).arcache,
         S_AXI_HP2_FPD_0_arprot          => hpReadMaster(2).arprot,
         S_AXI_HP2_FPD_0_arvalid         => hpReadMaster(2).arvalid,
         S_AXI_HP2_FPD_0_arready         => hpReadSlaveOut(2).arready,
         S_AXI_HP2_FPD_0_rid             => hpReadSlaveOut(2).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP2_FPD_0_rdata           => hpReadSlaveOut(2).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP2_FPD_0_rresp           => hpReadSlaveOut(2).rresp,
         S_AXI_HP2_FPD_0_rlast           => hpReadSlaveOut(2).rlast,
         S_AXI_HP2_FPD_0_rvalid          => hpReadSlaveOut(2).rvalid,
         S_AXI_HP2_FPD_0_rready          => hpReadMaster(2).rready,
         S_AXI_HP2_FPD_0_awqos           => "0000",
         S_AXI_HP2_FPD_0_arqos           => "0000",
         -- S_AXI_HP_3
         saxihp3_fpd_aclk_0              => hpAxiClk(3),
         S_AXI_HP3_FPD_0_aruser          => '0',
         S_AXI_HP3_FPD_0_awuser          => '0',
         S_AXI_HP3_FPD_0_awid            => hpWriteMaster(3).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP3_FPD_0_awaddr          => hpWriteMaster(3).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP3_FPD_0_awlen           => hpWriteMaster(3).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP3_FPD_0_awsize          => hpWriteMaster(3).awsize,
         S_AXI_HP3_FPD_0_awburst         => hpWriteMaster(3).awburst,
         S_AXI_HP3_FPD_0_awlock          => hpWriteMaster(3).awlock(0),
         S_AXI_HP3_FPD_0_awcache         => hpWriteMaster(3).awcache,
         S_AXI_HP3_FPD_0_awprot          => hpWriteMaster(3).awprot,
         S_AXI_HP3_FPD_0_awvalid         => hpWriteMaster(3).awvalid,
         S_AXI_HP3_FPD_0_awready         => hpWriteSlaveOut(3).awready,
         S_AXI_HP3_FPD_0_wdata           => hpWriteMaster(3).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP3_FPD_0_wstrb           => hpWriteMaster(3).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP3_FPD_0_wlast           => hpWriteMaster(3).wlast,
         S_AXI_HP3_FPD_0_wvalid          => hpWriteMaster(3).wvalid,
         S_AXI_HP3_FPD_0_wready          => hpWriteSlaveOut(3).wready,
         S_AXI_HP3_FPD_0_bid             => hpWriteSlaveOut(3).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP3_FPD_0_bresp           => hpWriteSlaveOut(3).bresp,
         S_AXI_HP3_FPD_0_bvalid          => hpWriteSlaveOut(3).bvalid,
         S_AXI_HP3_FPD_0_bready          => hpWriteMaster(3).bready,
         S_AXI_HP3_FPD_0_arid            => hpReadMaster(3).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP3_FPD_0_araddr          => hpReadMaster(3).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_HP3_FPD_0_arlen           => hpReadMaster(3).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_HP3_FPD_0_arsize          => hpReadMaster(3).arsize,
         S_AXI_HP3_FPD_0_arburst         => hpReadMaster(3).arburst,
         S_AXI_HP3_FPD_0_arlock          => hpReadMaster(3).arlock(0),
         S_AXI_HP3_FPD_0_arcache         => hpReadMaster(3).arcache,
         S_AXI_HP3_FPD_0_arprot          => hpReadMaster(3).arprot,
         S_AXI_HP3_FPD_0_arvalid         => hpReadMaster(3).arvalid,
         S_AXI_HP3_FPD_0_arready         => hpReadSlaveOut(3).arready,
         S_AXI_HP3_FPD_0_rid             => hpReadSlaveOut(3).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_HP3_FPD_0_rdata           => hpReadSlaveOut(3).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_HP3_FPD_0_rresp           => hpReadSlaveOut(3).rresp,
         S_AXI_HP3_FPD_0_rlast           => hpReadSlaveOut(3).rlast,
         S_AXI_HP3_FPD_0_rvalid          => hpReadSlaveOut(3).rvalid,
         S_AXI_HP3_FPD_0_rready          => hpReadMaster(3).rready,
         S_AXI_HP3_FPD_0_awqos           => "0000",
         S_AXI_HP3_FPD_0_arqos           => "0000",
         -- S_AXI_ACP
         saxiacp_fpd_aclk_0              => acpAxiClk,
         S_AXI_ACP_FPD_0_awuser          => "11",
         S_AXI_ACP_FPD_0_aruser          => "11",
         S_AXI_ACP_FPD_0_awid            => acpWriteMaster.awid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_ACP_FPD_0_awaddr          => acpWriteMaster.awaddr(AXI_ACP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_ACP_FPD_0_awlen           => acpWriteMaster.awlen(AXI_ACP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_ACP_FPD_0_awsize          => acpWriteMaster.awsize,
         S_AXI_ACP_FPD_0_awburst         => acpWriteMaster.awburst,
         S_AXI_ACP_FPD_0_awlock          => acpWriteMaster.awlock(0),
         S_AXI_ACP_FPD_0_awcache         => acpWriteMaster.awcache,
         S_AXI_ACP_FPD_0_awprot          => acpWriteMaster.awprot,
         S_AXI_ACP_FPD_0_awvalid         => acpWriteMaster.awvalid,
         S_AXI_ACP_FPD_0_awready         => acpWriteSlaveOut.awready,
         S_AXI_ACP_FPD_0_wdata           => acpWriteMaster.wdata(8*AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_ACP_FPD_0_wstrb           => acpWriteMaster.wstrb(AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_ACP_FPD_0_wlast           => acpWriteMaster.wlast,
         S_AXI_ACP_FPD_0_wvalid          => acpWriteMaster.wvalid,
         S_AXI_ACP_FPD_0_wready          => acpWriteSlaveOut.wready,
         S_AXI_ACP_FPD_0_bid             => acpWriteSlaveOut.bid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_ACP_FPD_0_bresp           => acpWriteSlaveOut.bresp,
         S_AXI_ACP_FPD_0_bvalid          => acpWriteSlaveOut.bvalid,
         S_AXI_ACP_FPD_0_bready          => acpWriteMaster.bready,
         S_AXI_ACP_FPD_0_arid            => acpReadMaster.arid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_ACP_FPD_0_araddr          => acpReadMaster.araddr(AXI_ACP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         S_AXI_ACP_FPD_0_arlen           => acpReadMaster.arlen(AXI_ACP_INIT_C.LEN_BITS_C-1 downto 0),
         S_AXI_ACP_FPD_0_arsize          => acpReadMaster.arsize,
         S_AXI_ACP_FPD_0_arburst         => acpReadMaster.arburst,
         S_AXI_ACP_FPD_0_arlock          => acpReadMaster.arlock(0),
         S_AXI_ACP_FPD_0_arcache         => acpReadMaster.arcache,
         S_AXI_ACP_FPD_0_arprot          => acpReadMaster.arprot,
         S_AXI_ACP_FPD_0_arvalid         => acpReadMaster.arvalid,
         S_AXI_ACP_FPD_0_arready         => acpReadSlaveOut.arready,
         S_AXI_ACP_FPD_0_rid             => acpReadSlaveOut.rid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         S_AXI_ACP_FPD_0_rdata           => acpReadSlaveOut.rdata(8*AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0),
         S_AXI_ACP_FPD_0_rresp           => acpReadSlaveOut.rresp,
         S_AXI_ACP_FPD_0_rlast           => acpReadSlaveOut.rlast,
         S_AXI_ACP_FPD_0_rvalid          => acpReadSlaveOut.rvalid,
         S_AXI_ACP_FPD_0_rready          => acpReadMaster.rready,
         S_AXI_ACP_FPD_0_awqos           => "0000",
         S_AXI_ACP_FPD_0_arqos           => "0000",
         -- EMIO ENET0
         GMII_ENET0_0_rx_clk             => armEthRx(0).enetGmiiRxClk,
         GMII_ENET0_0_speed_mode         => armEthTx(0).enetGmiispeedMode,
         GMII_ENET0_0_crs                => armEthRx(0).enetGmiiCrs,
         GMII_ENET0_0_col                => armEthRx(0).enetGmiiCol,
         GMII_ENET0_0_rxd                => armEthRx(0).enetGmiiRxd,
         GMII_ENET0_0_rx_er              => armEthRx(0).enetGmiiRxEr,
         GMII_ENET0_0_rx_dv              => armEthRx(0).enetGmiiRxDv,
         GMII_ENET0_0_tx_clk             => armEthRx(0).enetGmiiTxClk,
         GMII_ENET0_0_txd                => armEthTx(0).enetGmiiTxD,
         GMII_ENET0_0_tx_en              => armEthTx(0).enetGmiiTxEn,
         GMII_ENET0_0_tx_er              => armEthTx(0).enetGmiiTxEr,
         -- EMIO ENET1
         GMII_ENET1_0_rx_clk             => armEthRx(1).enetGmiiRxClk,
         GMII_ENET1_0_speed_mode         => armEthTx(1).enetGmiispeedMode,
         GMII_ENET1_0_crs                => armEthRx(1).enetGmiiCrs,
         GMII_ENET1_0_col                => armEthRx(1).enetGmiiCol,
         GMII_ENET1_0_rxd                => armEthRx(1).enetGmiiRxd,
         GMII_ENET1_0_rx_er              => armEthRx(1).enetGmiiRxEr,
         GMII_ENET1_0_rx_dv              => armEthRx(1).enetGmiiRxDv,
         GMII_ENET1_0_tx_clk             => armEthRx(1).enetGmiiTxClk,
         GMII_ENET1_0_txd                => armEthTx(1).enetGmiiTxD,
         GMII_ENET1_0_tx_en              => armEthTx(1).enetGmiiTxEn,
         GMII_ENET1_0_tx_er              => armEthTx(1).enetGmiiTxEr,
         -- EMIO ENET[1:0] MISC    
         emio_enet0_tsu_inc_ctrl_0       => (others => '0'),  -- ??? Not sure if I am setting this correctly
         emio_enet0_tsu_timer_cmp_val_0  => open,
         emio_enet1_tsu_inc_ctrl_0       => (others => '0'),  -- ??? Not sure if I am setting this correctly
         emio_enet1_tsu_timer_cmp_val_0  => open,
         emio_enet0_enet_tsu_timer_cnt_0 => open,
         emio_enet0_ext_int_in_0         => '0',  -- ??? Not sure if I am setting this correctly
         emio_enet1_ext_int_in_0         => '0',  -- ??? Not sure if I am setting this correctly
         emio_enet0_dma_bus_width_0      => open,
         emio_enet1_dma_bus_width_0      => open,
         -- IRQ
         pl_ps_irq0_0                    => armInterrupt(7 downto 0),
         pl_ps_irq1_0                    => armInterrupt(15 downto 8),
         pl_acpinact_0                   => '0',  -- ??? Not sure if I am setting this correctly
         -- FCLK
         pl_clk0_0                       => fclk(0),
         pl_clk1_0                       => fclk(1),
         pl_clk2_0                       => fclk(2),
         pl_clk3_0                       => fclk(3));

   -----------------
   -- Power Up Reset
   -----------------
   U_PwrUpRst : entity work.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => 10000000)        -- 100 ms
      port map (
         clk    => fclk(0),
         rstOut => frst(0));

   GEN_VEC :
   for i in 3 to 1 generate
      U_RstSync : entity work.RstSync
         generic map (
            TPD_G => TPD_G)
         port map (
            clk      => fclk(i),
            asyncRst => frst(0),
            syncRst  => frst(i));
   end generate GEN_VEC;

   --------------------------------------
   -- Clock and Reset Output Assignments
   --------------------------------------
   -- Clocks
   fclkClk0 <= fclk(0);
   fclkClk1 <= fclk(1);
   fclkClk2 <= fclk(2);
   fclkClk3 <= fclk(3);
   -- Resets
   fclkRst0 <= frst(0);
   fclkRst1 <= frst(1);
   fclkRst2 <= frst(2);
   fclkRst3 <= frst(3);

end architecture mapping;

