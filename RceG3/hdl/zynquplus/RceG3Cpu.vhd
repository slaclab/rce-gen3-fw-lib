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

   component zynq_ultra_ps_e_0
      port (
         maxihpm0_fpd_aclk             : in  std_logic;
         maxigp0_awid                  : out std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp0_awaddr                : out std_logic_vector(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         maxigp0_awlen                 : out std_logic_vector(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0);
         maxigp0_awsize                : out std_logic_vector(2 downto 0);
         maxigp0_awburst               : out std_logic_vector(1 downto 0);
         maxigp0_awlock                : out std_logic;
         maxigp0_awcache               : out std_logic_vector(3 downto 0);
         maxigp0_awprot                : out std_logic_vector(2 downto 0);
         maxigp0_awvalid               : out std_logic;
         maxigp0_awuser                : out std_logic_vector(15 downto 0);
         maxigp0_awready               : in  std_logic;
         maxigp0_wdata                 : out std_logic_vector(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         maxigp0_wstrb                 : out std_logic_vector(AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         maxigp0_wlast                 : out std_logic;
         maxigp0_wvalid                : out std_logic;
         maxigp0_wready                : in  std_logic;
         maxigp0_bid                   : in  std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp0_bresp                 : in  std_logic_vector(1 downto 0);
         maxigp0_bvalid                : in  std_logic;
         maxigp0_bready                : out std_logic;
         maxigp0_arid                  : out std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp0_araddr                : out std_logic_vector(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         maxigp0_arlen                 : out std_logic_vector(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0);
         maxigp0_arsize                : out std_logic_vector(2 downto 0);
         maxigp0_arburst               : out std_logic_vector(1 downto 0);
         maxigp0_arlock                : out std_logic;
         maxigp0_arcache               : out std_logic_vector(3 downto 0);
         maxigp0_arprot                : out std_logic_vector(2 downto 0);
         maxigp0_arvalid               : out std_logic;
         maxigp0_aruser                : out std_logic_vector(15 downto 0);
         maxigp0_arready               : in  std_logic;
         maxigp0_rid                   : in  std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp0_rdata                 : in  std_logic_vector(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         maxigp0_rresp                 : in  std_logic_vector(1 downto 0);
         maxigp0_rlast                 : in  std_logic;
         maxigp0_rvalid                : in  std_logic;
         maxigp0_rready                : out std_logic;
         maxigp0_awqos                 : out std_logic_vector(3 downto 0);
         maxigp0_arqos                 : out std_logic_vector(3 downto 0);
         maxihpm1_fpd_aclk             : in  std_logic;
         maxigp1_awid                  : out std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp1_awaddr                : out std_logic_vector(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         maxigp1_awlen                 : out std_logic_vector(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0);
         maxigp1_awsize                : out std_logic_vector(2 downto 0);
         maxigp1_awburst               : out std_logic_vector(1 downto 0);
         maxigp1_awlock                : out std_logic;
         maxigp1_awcache               : out std_logic_vector(3 downto 0);
         maxigp1_awprot                : out std_logic_vector(2 downto 0);
         maxigp1_awvalid               : out std_logic;
         maxigp1_awuser                : out std_logic_vector(15 downto 0);
         maxigp1_awready               : in  std_logic;
         maxigp1_wdata                 : out std_logic_vector(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         maxigp1_wstrb                 : out std_logic_vector(AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         maxigp1_wlast                 : out std_logic;
         maxigp1_wvalid                : out std_logic;
         maxigp1_wready                : in  std_logic;
         maxigp1_bid                   : in  std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp1_bresp                 : in  std_logic_vector(1 downto 0);
         maxigp1_bvalid                : in  std_logic;
         maxigp1_bready                : out std_logic;
         maxigp1_arid                  : out std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp1_araddr                : out std_logic_vector(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         maxigp1_arlen                 : out std_logic_vector(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0);
         maxigp1_arsize                : out std_logic_vector(2 downto 0);
         maxigp1_arburst               : out std_logic_vector(1 downto 0);
         maxigp1_arlock                : out std_logic;
         maxigp1_arcache               : out std_logic_vector(3 downto 0);
         maxigp1_arprot                : out std_logic_vector(2 downto 0);
         maxigp1_arvalid               : out std_logic;
         maxigp1_aruser                : out std_logic_vector(15 downto 0);
         maxigp1_arready               : in  std_logic;
         maxigp1_rid                   : in  std_logic_vector(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0);
         maxigp1_rdata                 : in  std_logic_vector(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         maxigp1_rresp                 : in  std_logic_vector(1 downto 0);
         maxigp1_rlast                 : in  std_logic;
         maxigp1_rvalid                : in  std_logic;
         maxigp1_rready                : out std_logic;
         maxigp1_awqos                 : out std_logic_vector(3 downto 0);
         maxigp1_arqos                 : out std_logic_vector(3 downto 0);
         saxihpc0_fpd_aclk             : in  std_logic;
         saxigp0_aruser                : in  std_logic;
         saxigp0_awuser                : in  std_logic;
         saxigp0_awid                  : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp0_awaddr                : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp0_awlen                 : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp0_awsize                : in  std_logic_vector(2 downto 0);
         saxigp0_awburst               : in  std_logic_vector(1 downto 0);
         saxigp0_awlock                : in  std_logic;
         saxigp0_awcache               : in  std_logic_vector(3 downto 0);
         saxigp0_awprot                : in  std_logic_vector(2 downto 0);
         saxigp0_awvalid               : in  std_logic;
         saxigp0_awready               : out std_logic;
         saxigp0_wdata                 : in  std_logic_vector(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp0_wstrb                 : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp0_wlast                 : in  std_logic;
         saxigp0_wvalid                : in  std_logic;
         saxigp0_wready                : out std_logic;
         saxigp0_bid                   : out std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp0_bresp                 : out std_logic_vector(1 downto 0);
         saxigp0_bvalid                : out std_logic;
         saxigp0_bready                : in  std_logic;
         saxigp0_arid                  : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp0_araddr                : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp0_arlen                 : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp0_arsize                : in  std_logic_vector(2 downto 0);
         saxigp0_arburst               : in  std_logic_vector(1 downto 0);
         saxigp0_arlock                : in  std_logic;
         saxigp0_arcache               : in  std_logic_vector(3 downto 0);
         saxigp0_arprot                : in  std_logic_vector(2 downto 0);
         saxigp0_arvalid               : in  std_logic;
         saxigp0_arready               : out std_logic;
         saxigp0_rid                   : out std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp0_rdata                 : out std_logic_vector(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp0_rresp                 : out std_logic_vector(1 downto 0);
         saxigp0_rlast                 : out std_logic;
         saxigp0_rvalid                : out std_logic;
         saxigp0_rready                : in  std_logic;
         saxigp0_awqos                 : in  std_logic_vector(3 downto 0);
         saxigp0_arqos                 : in  std_logic_vector(3 downto 0);
         saxihpc1_fpd_aclk             : in  std_logic;
         saxigp1_aruser                : in  std_logic;
         saxigp1_awuser                : in  std_logic;
         saxigp1_awid                  : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp1_awaddr                : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp1_awlen                 : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp1_awsize                : in  std_logic_vector(2 downto 0);
         saxigp1_awburst               : in  std_logic_vector(1 downto 0);
         saxigp1_awlock                : in  std_logic;
         saxigp1_awcache               : in  std_logic_vector(3 downto 0);
         saxigp1_awprot                : in  std_logic_vector(2 downto 0);
         saxigp1_awvalid               : in  std_logic;
         saxigp1_awready               : out std_logic;
         saxigp1_wdata                 : in  std_logic_vector(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp1_wstrb                 : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp1_wlast                 : in  std_logic;
         saxigp1_wvalid                : in  std_logic;
         saxigp1_wready                : out std_logic;
         saxigp1_bid                   : out std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp1_bresp                 : out std_logic_vector(1 downto 0);
         saxigp1_bvalid                : out std_logic;
         saxigp1_bready                : in  std_logic;
         saxigp1_arid                  : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp1_araddr                : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp1_arlen                 : in  std_logic_vector(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp1_arsize                : in  std_logic_vector(2 downto 0);
         saxigp1_arburst               : in  std_logic_vector(1 downto 0);
         saxigp1_arlock                : in  std_logic;
         saxigp1_arcache               : in  std_logic_vector(3 downto 0);
         saxigp1_arprot                : in  std_logic_vector(2 downto 0);
         saxigp1_arvalid               : in  std_logic;
         saxigp1_arready               : out std_logic;
         saxigp1_rid                   : out std_logic_vector(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp1_rdata                 : out std_logic_vector(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp1_rresp                 : out std_logic_vector(1 downto 0);
         saxigp1_rlast                 : out std_logic;
         saxigp1_rvalid                : out std_logic;
         saxigp1_rready                : in  std_logic;
         saxigp1_awqos                 : in  std_logic_vector(3 downto 0);
         saxigp1_arqos                 : in  std_logic_vector(3 downto 0);
         saxihp0_fpd_aclk              : in  std_logic;
         saxigp2_aruser                : in  std_logic;
         saxigp2_awuser                : in  std_logic;
         saxigp2_awid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp2_awaddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp2_awlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp2_awsize                : in  std_logic_vector(2 downto 0);
         saxigp2_awburst               : in  std_logic_vector(1 downto 0);
         saxigp2_awlock                : in  std_logic;
         saxigp2_awcache               : in  std_logic_vector(3 downto 0);
         saxigp2_awprot                : in  std_logic_vector(2 downto 0);
         saxigp2_awvalid               : in  std_logic;
         saxigp2_awready               : out std_logic;
         saxigp2_wdata                 : in  std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp2_wstrb                 : in  std_logic_vector(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp2_wlast                 : in  std_logic;
         saxigp2_wvalid                : in  std_logic;
         saxigp2_wready                : out std_logic;
         saxigp2_bid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp2_bresp                 : out std_logic_vector(1 downto 0);
         saxigp2_bvalid                : out std_logic;
         saxigp2_bready                : in  std_logic;
         saxigp2_arid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp2_araddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp2_arlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp2_arsize                : in  std_logic_vector(2 downto 0);
         saxigp2_arburst               : in  std_logic_vector(1 downto 0);
         saxigp2_arlock                : in  std_logic;
         saxigp2_arcache               : in  std_logic_vector(3 downto 0);
         saxigp2_arprot                : in  std_logic_vector(2 downto 0);
         saxigp2_arvalid               : in  std_logic;
         saxigp2_arready               : out std_logic;
         saxigp2_rid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp2_rdata                 : out std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp2_rresp                 : out std_logic_vector(1 downto 0);
         saxigp2_rlast                 : out std_logic;
         saxigp2_rvalid                : out std_logic;
         saxigp2_rready                : in  std_logic;
         saxigp2_awqos                 : in  std_logic_vector(3 downto 0);
         saxigp2_arqos                 : in  std_logic_vector(3 downto 0);
         saxihp1_fpd_aclk              : in  std_logic;
         saxigp3_aruser                : in  std_logic;
         saxigp3_awuser                : in  std_logic;
         saxigp3_awid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp3_awaddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp3_awlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp3_awsize                : in  std_logic_vector(2 downto 0);
         saxigp3_awburst               : in  std_logic_vector(1 downto 0);
         saxigp3_awlock                : in  std_logic;
         saxigp3_awcache               : in  std_logic_vector(3 downto 0);
         saxigp3_awprot                : in  std_logic_vector(2 downto 0);
         saxigp3_awvalid               : in  std_logic;
         saxigp3_awready               : out std_logic;
         saxigp3_wdata                 : in  std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp3_wstrb                 : in  std_logic_vector(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp3_wlast                 : in  std_logic;
         saxigp3_wvalid                : in  std_logic;
         saxigp3_wready                : out std_logic;
         saxigp3_bid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp3_bresp                 : out std_logic_vector(1 downto 0);
         saxigp3_bvalid                : out std_logic;
         saxigp3_bready                : in  std_logic;
         saxigp3_arid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp3_araddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp3_arlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp3_arsize                : in  std_logic_vector(2 downto 0);
         saxigp3_arburst               : in  std_logic_vector(1 downto 0);
         saxigp3_arlock                : in  std_logic;
         saxigp3_arcache               : in  std_logic_vector(3 downto 0);
         saxigp3_arprot                : in  std_logic_vector(2 downto 0);
         saxigp3_arvalid               : in  std_logic;
         saxigp3_arready               : out std_logic;
         saxigp3_rid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp3_rdata                 : out std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp3_rresp                 : out std_logic_vector(1 downto 0);
         saxigp3_rlast                 : out std_logic;
         saxigp3_rvalid                : out std_logic;
         saxigp3_rready                : in  std_logic;
         saxigp3_awqos                 : in  std_logic_vector(3 downto 0);
         saxigp3_arqos                 : in  std_logic_vector(3 downto 0);
         saxihp2_fpd_aclk              : in  std_logic;
         saxigp4_aruser                : in  std_logic;
         saxigp4_awuser                : in  std_logic;
         saxigp4_awid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp4_awaddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp4_awlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp4_awsize                : in  std_logic_vector(2 downto 0);
         saxigp4_awburst               : in  std_logic_vector(1 downto 0);
         saxigp4_awlock                : in  std_logic;
         saxigp4_awcache               : in  std_logic_vector(3 downto 0);
         saxigp4_awprot                : in  std_logic_vector(2 downto 0);
         saxigp4_awvalid               : in  std_logic;
         saxigp4_awready               : out std_logic;
         saxigp4_wdata                 : in  std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp4_wstrb                 : in  std_logic_vector(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp4_wlast                 : in  std_logic;
         saxigp4_wvalid                : in  std_logic;
         saxigp4_wready                : out std_logic;
         saxigp4_bid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp4_bresp                 : out std_logic_vector(1 downto 0);
         saxigp4_bvalid                : out std_logic;
         saxigp4_bready                : in  std_logic;
         saxigp4_arid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp4_araddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp4_arlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp4_arsize                : in  std_logic_vector(2 downto 0);
         saxigp4_arburst               : in  std_logic_vector(1 downto 0);
         saxigp4_arlock                : in  std_logic;
         saxigp4_arcache               : in  std_logic_vector(3 downto 0);
         saxigp4_arprot                : in  std_logic_vector(2 downto 0);
         saxigp4_arvalid               : in  std_logic;
         saxigp4_arready               : out std_logic;
         saxigp4_rid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp4_rdata                 : out std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp4_rresp                 : out std_logic_vector(1 downto 0);
         saxigp4_rlast                 : out std_logic;
         saxigp4_rvalid                : out std_logic;
         saxigp4_rready                : in  std_logic;
         saxigp4_awqos                 : in  std_logic_vector(3 downto 0);
         saxigp4_arqos                 : in  std_logic_vector(3 downto 0);
         saxihp3_fpd_aclk              : in  std_logic;
         saxigp5_aruser                : in  std_logic;
         saxigp5_awuser                : in  std_logic;
         saxigp5_awid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp5_awaddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp5_awlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp5_awsize                : in  std_logic_vector(2 downto 0);
         saxigp5_awburst               : in  std_logic_vector(1 downto 0);
         saxigp5_awlock                : in  std_logic;
         saxigp5_awcache               : in  std_logic_vector(3 downto 0);
         saxigp5_awprot                : in  std_logic_vector(2 downto 0);
         saxigp5_awvalid               : in  std_logic;
         saxigp5_awready               : out std_logic;
         saxigp5_wdata                 : in  std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp5_wstrb                 : in  std_logic_vector(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp5_wlast                 : in  std_logic;
         saxigp5_wvalid                : in  std_logic;
         saxigp5_wready                : out std_logic;
         saxigp5_bid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp5_bresp                 : out std_logic_vector(1 downto 0);
         saxigp5_bvalid                : out std_logic;
         saxigp5_bready                : in  std_logic;
         saxigp5_arid                  : in  std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp5_araddr                : in  std_logic_vector(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxigp5_arlen                 : in  std_logic_vector(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0);
         saxigp5_arsize                : in  std_logic_vector(2 downto 0);
         saxigp5_arburst               : in  std_logic_vector(1 downto 0);
         saxigp5_arlock                : in  std_logic;
         saxigp5_arcache               : in  std_logic_vector(3 downto 0);
         saxigp5_arprot                : in  std_logic_vector(2 downto 0);
         saxigp5_arvalid               : in  std_logic;
         saxigp5_arready               : out std_logic;
         saxigp5_rid                   : out std_logic_vector(AXI_HP_INIT_C.ID_BITS_C-1 downto 0);
         saxigp5_rdata                 : out std_logic_vector(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxigp5_rresp                 : out std_logic_vector(1 downto 0);
         saxigp5_rlast                 : out std_logic;
         saxigp5_rvalid                : out std_logic;
         saxigp5_rready                : in  std_logic;
         saxigp5_awqos                 : in  std_logic_vector(3 downto 0);
         saxigp5_arqos                 : in  std_logic_vector(3 downto 0);
         saxiacp_fpd_aclk              : in  std_logic;
         saxiacp_awuser                : in  std_logic_vector(1 downto 0);
         saxiacp_aruser                : in  std_logic_vector(1 downto 0);
         saxiacp_awid                  : in  std_logic_vector(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0);
         saxiacp_awaddr                : in  std_logic_vector(AXI_ACP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxiacp_awlen                 : in  std_logic_vector(AXI_ACP_INIT_C.LEN_BITS_C-1 downto 0);
         saxiacp_awsize                : in  std_logic_vector(2 downto 0);
         saxiacp_awburst               : in  std_logic_vector(1 downto 0);
         saxiacp_awlock                : in  std_logic;
         saxiacp_awcache               : in  std_logic_vector(3 downto 0);
         saxiacp_awprot                : in  std_logic_vector(2 downto 0);
         saxiacp_awvalid               : in  std_logic;
         saxiacp_awready               : out std_logic;
         saxiacp_wdata                 : in  std_logic_vector(8*AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxiacp_wstrb                 : in  std_logic_vector(AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxiacp_wlast                 : in  std_logic;
         saxiacp_wvalid                : in  std_logic;
         saxiacp_wready                : out std_logic;
         saxiacp_bid                   : out std_logic_vector(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0);
         saxiacp_bresp                 : out std_logic_vector(1 downto 0);
         saxiacp_bvalid                : out std_logic;
         saxiacp_bready                : in  std_logic;
         saxiacp_arid                  : in  std_logic_vector(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0);
         saxiacp_araddr                : in  std_logic_vector(AXI_ACP_INIT_C.ADDR_WIDTH_C-1 downto 0);
         saxiacp_arlen                 : in  std_logic_vector(AXI_ACP_INIT_C.LEN_BITS_C-1 downto 0);
         saxiacp_arsize                : in  std_logic_vector(2 downto 0);
         saxiacp_arburst               : in  std_logic_vector(1 downto 0);
         saxiacp_arlock                : in  std_logic;
         saxiacp_arcache               : in  std_logic_vector(3 downto 0);
         saxiacp_arprot                : in  std_logic_vector(2 downto 0);
         saxiacp_arvalid               : in  std_logic;
         saxiacp_arready               : out std_logic;
         saxiacp_rid                   : out std_logic_vector(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0);
         saxiacp_rdata                 : out std_logic_vector(8*AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0);
         saxiacp_rresp                 : out std_logic_vector(1 downto 0);
         saxiacp_rlast                 : out std_logic;
         saxiacp_rvalid                : out std_logic;
         saxiacp_rready                : in  std_logic;
         saxiacp_awqos                 : in  std_logic_vector(3 downto 0);
         saxiacp_arqos                 : in  std_logic_vector(3 downto 0);
         emio_enet0_gmii_rx_clk        : in  std_logic;
         emio_enet0_speed_mode         : out std_logic_vector(2 downto 0);
         emio_enet0_gmii_crs           : in  std_logic;
         emio_enet0_gmii_col           : in  std_logic;
         emio_enet0_gmii_rxd           : in  std_logic_vector(7 downto 0);
         emio_enet0_gmii_rx_er         : in  std_logic;
         emio_enet0_gmii_rx_dv         : in  std_logic;
         emio_enet0_gmii_tx_clk        : in  std_logic;
         emio_enet0_gmii_txd           : out std_logic_vector(7 downto 0);
         emio_enet0_gmii_tx_en         : out std_logic;
         emio_enet0_gmii_tx_er         : out std_logic;
         emio_enet0_mdio_mdc           : out std_logic;
         emio_enet0_mdio_i             : in  std_logic;
         emio_enet0_mdio_o             : out std_logic;
         emio_enet0_mdio_t             : out std_logic;
         emio_enet1_gmii_rx_clk        : in  std_logic;
         emio_enet1_speed_mode         : out std_logic_vector(2 downto 0);
         emio_enet1_gmii_crs           : in  std_logic;
         emio_enet1_gmii_col           : in  std_logic;
         emio_enet1_gmii_rxd           : in  std_logic_vector(7 downto 0);
         emio_enet1_gmii_rx_er         : in  std_logic;
         emio_enet1_gmii_rx_dv         : in  std_logic;
         emio_enet1_gmii_tx_clk        : in  std_logic;
         emio_enet1_gmii_txd           : out std_logic_vector(7 downto 0);
         emio_enet1_gmii_tx_en         : out std_logic;
         emio_enet1_gmii_tx_er         : out std_logic;
         emio_enet1_mdio_mdc           : out std_logic;
         emio_enet1_mdio_i             : in  std_logic;
         emio_enet1_mdio_o             : out std_logic;
         emio_enet1_mdio_t             : out std_logic;
         emio_enet0_tsu_inc_ctrl       : in  std_logic_vector(1 downto 0);
         emio_enet0_tsu_timer_cmp_val  : out std_logic;
         emio_enet1_tsu_inc_ctrl       : in  std_logic_vector(1 downto 0);
         emio_enet1_tsu_timer_cmp_val  : out std_logic;
         emio_enet0_enet_tsu_timer_cnt : out std_logic_vector(93 downto 0);
         emio_enet0_ext_int_in         : in  std_logic;
         emio_enet1_ext_int_in         : in  std_logic;
         emio_enet0_dma_bus_width      : out std_logic_vector(1 downto 0);
         emio_enet1_dma_bus_width      : out std_logic_vector(1 downto 0);
         emio_gpio_i                   : in  std_logic_vector(95 downto 0);
         emio_gpio_o                   : out std_logic_vector(95 downto 0);
         emio_gpio_t                   : out std_logic_vector(95 downto 0);
         pl_ps_irq0                    : in  std_logic_vector(0 downto 0);
         pl_ps_irq1                    : in  std_logic_vector(0 downto 0);
         pl_acpinact                   : in  std_logic;
         pl_clk0                       : out std_logic;
         pl_clk1                       : out std_logic;
         pl_clk2                       : out std_logic;
         pl_clk3                       : out std_logic);
   end component;

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
   U_CPU : zynq_ultra_ps_e_0
      port map (
         -- M_AXI_GP0
         maxihpm0_fpd_aclk             => mGpAxiClk(0),
         maxigp0_awid                  => mGpWriteMasterOut(0).awid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp0_awaddr                => mGpWriteMasterOut(0).awaddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         maxigp0_awlen                 => mGpWriteMasterOut(0).awlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         maxigp0_awsize                => mGpWriteMasterOut(0).awsize,
         maxigp0_awburst               => mGpWriteMasterOut(0).awburst,
         maxigp0_awlock                => mGpWriteMasterOut(0).awlock(0),
         maxigp0_awcache               => mGpWriteMasterOut(0).awcache,
         maxigp0_awprot                => mGpWriteMasterOut(0).awprot,
         maxigp0_awvalid               => mGpWriteMasterOut(0).awvalid,
         maxigp0_awuser                => open,
         maxigp0_awready               => mGpWriteSlave(0).awready,
         maxigp0_wdata                 => mGpWriteMasterOut(0).wdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         maxigp0_wstrb                 => mGpWriteMasterOut(0).wstrb(AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         maxigp0_wlast                 => mGpWriteMasterOut(0).wlast,
         maxigp0_wvalid                => mGpWriteMasterOut(0).wvalid,
         maxigp0_wready                => mGpWriteSlave(0).wready,
         maxigp0_bid                   => mGpWriteSlave(0).bid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp0_bresp                 => mGpWriteSlave(0).bresp,
         maxigp0_bvalid                => mGpWriteSlave(0).bvalid,
         maxigp0_bready                => mGpWriteMasterOut(0).bready,
         maxigp0_arid                  => mGpReadMasterOut(0).arid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp0_araddr                => mGpReadMasterOut(0).araddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         maxigp0_arlen                 => mGpReadMasterOut(0).arlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         maxigp0_arsize                => mGpReadMasterOut(0).arsize,
         maxigp0_arburst               => mGpReadMasterOut(0).arburst,
         maxigp0_arlock                => mGpReadMasterOut(0).arlock(0),
         maxigp0_arcache               => mGpReadMasterOut(0).arcache,
         maxigp0_arprot                => mGpReadMasterOut(0).arprot,
         maxigp0_arvalid               => mGpReadMasterOut(0).arvalid,
         maxigp0_aruser                => open,
         maxigp0_arready               => mGpReadSlave(0).arready,
         maxigp0_rid                   => mGpReadSlave(0).rid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp0_rdata                 => mGpReadSlave(0).rdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         maxigp0_rresp                 => mGpReadSlave(0).rresp,
         maxigp0_rlast                 => mGpReadSlave(0).rlast,
         maxigp0_rvalid                => mGpReadSlave(0).rvalid,
         maxigp0_rready                => mGpReadMasterOut(0).rready,
         maxigp0_awqos                 => open,
         maxigp0_arqos                 => open,
         -- M_AXI_GP1
         maxihpm1_fpd_aclk             => mGpAxiClk(1),
         maxigp1_awid                  => mGpWriteMasterOut(1).awid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp1_awaddr                => mGpWriteMasterOut(1).awaddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         maxigp1_awlen                 => mGpWriteMasterOut(1).awlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         maxigp1_awsize                => mGpWriteMasterOut(1).awsize,
         maxigp1_awburst               => mGpWriteMasterOut(1).awburst,
         maxigp1_awlock                => mGpWriteMasterOut(1).awlock(0),
         maxigp1_awcache               => mGpWriteMasterOut(1).awcache,
         maxigp1_awprot                => mGpWriteMasterOut(1).awprot,
         maxigp1_awvalid               => mGpWriteMasterOut(1).awvalid,
         maxigp1_awuser                => open,
         maxigp1_awready               => mGpWriteSlave(1).awready,
         maxigp1_wdata                 => mGpWriteMasterOut(1).wdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         maxigp1_wstrb                 => mGpWriteMasterOut(1).wstrb(AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         maxigp1_wlast                 => mGpWriteMasterOut(1).wlast,
         maxigp1_wvalid                => mGpWriteMasterOut(1).wvalid,
         maxigp1_wready                => mGpWriteSlave(1).wready,
         maxigp1_bid                   => mGpWriteSlave(1).bid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp1_bresp                 => mGpWriteSlave(1).bresp,
         maxigp1_bvalid                => mGpWriteSlave(1).bvalid,
         maxigp1_bready                => mGpWriteMasterOut(1).bready,
         maxigp1_arid                  => mGpReadMasterOut(1).arid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp1_araddr                => mGpReadMasterOut(1).araddr(AXI_MAST_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         maxigp1_arlen                 => mGpReadMasterOut(1).arlen(AXI_MAST_GP_INIT_C.LEN_BITS_C-1 downto 0),
         maxigp1_arsize                => mGpReadMasterOut(1).arsize,
         maxigp1_arburst               => mGpReadMasterOut(1).arburst,
         maxigp1_arlock                => mGpReadMasterOut(1).arlock(0),
         maxigp1_arcache               => mGpReadMasterOut(1).arcache,
         maxigp1_arprot                => mGpReadMasterOut(1).arprot,
         maxigp1_arvalid               => mGpReadMasterOut(1).arvalid,
         maxigp1_aruser                => open,
         maxigp1_arready               => mGpReadSlave(1).arready,
         maxigp1_rid                   => mGpReadSlave(1).rid(AXI_MAST_GP_INIT_C.ID_BITS_C-1 downto 0),
         maxigp1_rdata                 => mGpReadSlave(1).rdata(8*AXI_MAST_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         maxigp1_rresp                 => mGpReadSlave(1).rresp,
         maxigp1_rlast                 => mGpReadSlave(1).rlast,
         maxigp1_rvalid                => mGpReadSlave(1).rvalid,
         maxigp1_rready                => mGpReadMasterOut(1).rready,
         maxigp1_awqos                 => open,
         maxigp1_arqos                 => open,
         -- S_AXI_GP0
         saxihpc0_fpd_aclk             => sGpAxiClk(0),
         saxigp0_aruser                => '0',
         saxigp0_awuser                => '0',
         saxigp0_awid                  => sGpWriteMaster(0).awid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp0_awaddr                => sGpWriteMaster(0).awaddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp0_awlen                 => sGpWriteMaster(0).awlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp0_awsize                => sGpWriteMaster(0).awsize,
         saxigp0_awburst               => sGpWriteMaster(0).awburst,
         saxigp0_awlock                => sGpWriteMaster(0).awlock(0),
         saxigp0_awcache               => sGpWriteMaster(0).awcache,
         saxigp0_awprot                => sGpWriteMaster(0).awprot,
         saxigp0_awvalid               => sGpWriteMaster(0).awvalid,
         saxigp0_awready               => sGpWriteSlaveOut(0).awready,
         saxigp0_wdata                 => sGpWriteMaster(0).wdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp0_wstrb                 => sGpWriteMaster(0).wstrb(AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp0_wlast                 => sGpWriteMaster(0).wlast,
         saxigp0_wvalid                => sGpWriteMaster(0).wvalid,
         saxigp0_wready                => sGpWriteSlaveOut(0).wready,
         saxigp0_bid                   => sGpWriteSlaveOut(0).bid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp0_bresp                 => sGpWriteSlaveOut(0).bresp,
         saxigp0_bvalid                => sGpWriteSlaveOut(0).bvalid,
         saxigp0_bready                => sGpWriteMaster(0).bready,
         saxigp0_arid                  => sGpReadMaster(0).arid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp0_araddr                => sGpReadMaster(0).araddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp0_arlen                 => sGpReadMaster(0).arlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp0_arsize                => sGpReadMaster(0).arsize,
         saxigp0_arburst               => sGpReadMaster(0).arburst,
         saxigp0_arlock                => sGpReadMaster(0).arlock(0),
         saxigp0_arcache               => sGpReadMaster(0).arcache,
         saxigp0_arprot                => sGpReadMaster(0).arprot,
         saxigp0_arvalid               => sGpReadMaster(0).arvalid,
         saxigp0_arready               => sGpReadSlaveOut(0).arready,
         saxigp0_rid                   => sGpReadSlaveOut(0).rid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp0_rdata                 => sGpReadSlaveOut(0).rdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp0_rresp                 => sGpReadSlaveOut(0).rresp,
         saxigp0_rlast                 => sGpReadSlaveOut(0).rlast,
         saxigp0_rvalid                => sGpReadSlaveOut(0).rvalid,
         saxigp0_rready                => sGpReadMaster(0).rready,
         saxigp0_awqos                 => "1111",           -- Highest priority
         saxigp0_arqos                 => "1111",           -- Highest priority
         -- S_AXI_GP1
         saxihpc1_fpd_aclk             => sGpAxiClk(1),
         saxigp1_aruser                => '0',
         saxigp1_awuser                => '0',
         saxigp1_awid                  => sGpWriteMaster(1).awid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp1_awaddr                => sGpWriteMaster(1).awaddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp1_awlen                 => sGpWriteMaster(1).awlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp1_awsize                => sGpWriteMaster(1).awsize,
         saxigp1_awburst               => sGpWriteMaster(1).awburst,
         saxigp1_awlock                => sGpWriteMaster(1).awlock(0),
         saxigp1_awcache               => sGpWriteMaster(1).awcache,
         saxigp1_awprot                => sGpWriteMaster(1).awprot,
         saxigp1_awvalid               => sGpWriteMaster(1).awvalid,
         saxigp1_awready               => sGpWriteSlaveOut(1).awready,
         saxigp1_wdata                 => sGpWriteMaster(1).wdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp1_wstrb                 => sGpWriteMaster(1).wstrb(AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp1_wlast                 => sGpWriteMaster(1).wlast,
         saxigp1_wvalid                => sGpWriteMaster(1).wvalid,
         saxigp1_wready                => sGpWriteSlaveOut(1).wready,
         saxigp1_bid                   => sGpWriteSlaveOut(1).bid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp1_bresp                 => sGpWriteSlaveOut(1).bresp,
         saxigp1_bvalid                => sGpWriteSlaveOut(1).bvalid,
         saxigp1_bready                => sGpWriteMaster(1).bready,
         saxigp1_arid                  => sGpReadMaster(1).arid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp1_araddr                => sGpReadMaster(1).araddr(AXI_SLAVE_GP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp1_arlen                 => sGpReadMaster(1).arlen(AXI_SLAVE_GP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp1_arsize                => sGpReadMaster(1).arsize,
         saxigp1_arburst               => sGpReadMaster(1).arburst,
         saxigp1_arlock                => sGpReadMaster(1).arlock(0),
         saxigp1_arcache               => sGpReadMaster(1).arcache,
         saxigp1_arprot                => sGpReadMaster(1).arprot,
         saxigp1_arvalid               => sGpReadMaster(1).arvalid,
         saxigp1_arready               => sGpReadSlaveOut(1).arready,
         saxigp1_rid                   => sGpReadSlaveOut(1).rid(AXI_SLAVE_GP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp1_rdata                 => sGpReadSlaveOut(1).rdata(8*AXI_SLAVE_GP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp1_rresp                 => sGpReadSlaveOut(1).rresp,
         saxigp1_rlast                 => sGpReadSlaveOut(1).rlast,
         saxigp1_rvalid                => sGpReadSlaveOut(1).rvalid,
         saxigp1_rready                => sGpReadMaster(1).rready,
         saxigp1_awqos                 => "1111",           -- Highest priority
         saxigp1_arqos                 => "1111",           -- Highest priority
         -- S_AXI_HP_0
         saxihp0_fpd_aclk              => hpAxiClk(0),
         saxigp2_aruser                => '0',
         saxigp2_awuser                => '0',
         saxigp2_awid                  => hpWriteMaster(0).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp2_awaddr                => hpWriteMaster(0).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp2_awlen                 => hpWriteMaster(0).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp2_awsize                => hpWriteMaster(0).awsize,
         saxigp2_awburst               => hpWriteMaster(0).awburst,
         saxigp2_awlock                => hpWriteMaster(0).awlock(0),
         saxigp2_awcache               => hpWriteMaster(0).awcache,
         saxigp2_awprot                => hpWriteMaster(0).awprot,
         saxigp2_awvalid               => hpWriteMaster(0).awvalid,
         saxigp2_awready               => hpWriteSlaveOut(0).awready,
         saxigp2_wdata                 => hpWriteMaster(0).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp2_wstrb                 => hpWriteMaster(0).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp2_wlast                 => hpWriteMaster(0).wlast,
         saxigp2_wvalid                => hpWriteMaster(0).wvalid,
         saxigp2_wready                => hpWriteSlaveOut(0).wready,
         saxigp2_bid                   => hpWriteSlaveOut(0).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp2_bresp                 => hpWriteSlaveOut(0).bresp,
         saxigp2_bvalid                => hpWriteSlaveOut(0).bvalid,
         saxigp2_bready                => hpWriteMaster(0).bready,
         saxigp2_arid                  => hpReadMaster(0).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp2_araddr                => hpReadMaster(0).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp2_arlen                 => hpReadMaster(0).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp2_arsize                => hpReadMaster(0).arsize,
         saxigp2_arburst               => hpReadMaster(0).arburst,
         saxigp2_arlock                => hpReadMaster(0).arlock(0),
         saxigp2_arcache               => hpReadMaster(0).arcache,
         saxigp2_arprot                => hpReadMaster(0).arprot,
         saxigp2_arvalid               => hpReadMaster(0).arvalid,
         saxigp2_arready               => hpReadSlaveOut(0).arready,
         saxigp2_rid                   => hpReadSlaveOut(0).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp2_rdata                 => hpReadSlaveOut(0).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp2_rresp                 => hpReadSlaveOut(0).rresp,
         saxigp2_rlast                 => hpReadSlaveOut(0).rlast,
         saxigp2_rvalid                => hpReadSlaveOut(0).rvalid,
         saxigp2_rready                => hpReadMaster(0).rready,
         saxigp2_awqos                 => "0000",
         saxigp2_arqos                 => "0000",
         -- S_AXI_HP_1
         saxihp1_fpd_aclk              => hpAxiClk(1),
         saxigp3_aruser                => '0',
         saxigp3_awuser                => '0',
         saxigp3_awid                  => hpWriteMaster(1).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp3_awaddr                => hpWriteMaster(1).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp3_awlen                 => hpWriteMaster(1).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp3_awsize                => hpWriteMaster(1).awsize,
         saxigp3_awburst               => hpWriteMaster(1).awburst,
         saxigp3_awlock                => hpWriteMaster(1).awlock(0),
         saxigp3_awcache               => hpWriteMaster(1).awcache,
         saxigp3_awprot                => hpWriteMaster(1).awprot,
         saxigp3_awvalid               => hpWriteMaster(1).awvalid,
         saxigp3_awready               => hpWriteSlaveOut(1).awready,
         saxigp3_wdata                 => hpWriteMaster(1).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp3_wstrb                 => hpWriteMaster(1).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp3_wlast                 => hpWriteMaster(1).wlast,
         saxigp3_wvalid                => hpWriteMaster(1).wvalid,
         saxigp3_wready                => hpWriteSlaveOut(1).wready,
         saxigp3_bid                   => hpWriteSlaveOut(1).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp3_bresp                 => hpWriteSlaveOut(1).bresp,
         saxigp3_bvalid                => hpWriteSlaveOut(1).bvalid,
         saxigp3_bready                => hpWriteMaster(1).bready,
         saxigp3_arid                  => hpReadMaster(1).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp3_araddr                => hpReadMaster(1).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp3_arlen                 => hpReadMaster(1).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp3_arsize                => hpReadMaster(1).arsize,
         saxigp3_arburst               => hpReadMaster(1).arburst,
         saxigp3_arlock                => hpReadMaster(1).arlock(0),
         saxigp3_arcache               => hpReadMaster(1).arcache,
         saxigp3_arprot                => hpReadMaster(1).arprot,
         saxigp3_arvalid               => hpReadMaster(1).arvalid,
         saxigp3_arready               => hpReadSlaveOut(1).arready,
         saxigp3_rid                   => hpReadSlaveOut(1).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp3_rdata                 => hpReadSlaveOut(1).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp3_rresp                 => hpReadSlaveOut(1).rresp,
         saxigp3_rlast                 => hpReadSlaveOut(1).rlast,
         saxigp3_rvalid                => hpReadSlaveOut(1).rvalid,
         saxigp3_rready                => hpReadMaster(1).rready,
         saxigp3_awqos                 => "0000",
         saxigp3_arqos                 => "0000",
         -- S_AXI_HP_2
         saxihp2_fpd_aclk              => hpAxiClk(2),
         saxigp4_aruser                => '0',
         saxigp4_awuser                => '0',
         saxigp4_awid                  => hpWriteMaster(2).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp4_awaddr                => hpWriteMaster(2).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp4_awlen                 => hpWriteMaster(2).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp4_awsize                => hpWriteMaster(2).awsize,
         saxigp4_awburst               => hpWriteMaster(2).awburst,
         saxigp4_awlock                => hpWriteMaster(2).awlock(0),
         saxigp4_awcache               => hpWriteMaster(2).awcache,
         saxigp4_awprot                => hpWriteMaster(2).awprot,
         saxigp4_awvalid               => hpWriteMaster(2).awvalid,
         saxigp4_awready               => hpWriteSlaveOut(2).awready,
         saxigp4_wdata                 => hpWriteMaster(2).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp4_wstrb                 => hpWriteMaster(2).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp4_wlast                 => hpWriteMaster(2).wlast,
         saxigp4_wvalid                => hpWriteMaster(2).wvalid,
         saxigp4_wready                => hpWriteSlaveOut(2).wready,
         saxigp4_bid                   => hpWriteSlaveOut(2).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp4_bresp                 => hpWriteSlaveOut(2).bresp,
         saxigp4_bvalid                => hpWriteSlaveOut(2).bvalid,
         saxigp4_bready                => hpWriteMaster(2).bready,
         saxigp4_arid                  => hpReadMaster(2).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp4_araddr                => hpReadMaster(2).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp4_arlen                 => hpReadMaster(2).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp4_arsize                => hpReadMaster(2).arsize,
         saxigp4_arburst               => hpReadMaster(2).arburst,
         saxigp4_arlock                => hpReadMaster(2).arlock(0),
         saxigp4_arcache               => hpReadMaster(2).arcache,
         saxigp4_arprot                => hpReadMaster(2).arprot,
         saxigp4_arvalid               => hpReadMaster(2).arvalid,
         saxigp4_arready               => hpReadSlaveOut(2).arready,
         saxigp4_rid                   => hpReadSlaveOut(2).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp4_rdata                 => hpReadSlaveOut(2).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp4_rresp                 => hpReadSlaveOut(2).rresp,
         saxigp4_rlast                 => hpReadSlaveOut(2).rlast,
         saxigp4_rvalid                => hpReadSlaveOut(2).rvalid,
         saxigp4_rready                => hpReadMaster(2).rready,
         saxigp4_awqos                 => "0000",
         saxigp4_arqos                 => "0000",
         -- S_AXI_HP_3
         saxihp3_fpd_aclk              => hpAxiClk(3),
         saxigp5_aruser                => '0',
         saxigp5_awuser                => '0',
         saxigp5_awid                  => hpWriteMaster(3).awid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp5_awaddr                => hpWriteMaster(3).awaddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp5_awlen                 => hpWriteMaster(3).awlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp5_awsize                => hpWriteMaster(3).awsize,
         saxigp5_awburst               => hpWriteMaster(3).awburst,
         saxigp5_awlock                => hpWriteMaster(3).awlock(0),
         saxigp5_awcache               => hpWriteMaster(3).awcache,
         saxigp5_awprot                => hpWriteMaster(3).awprot,
         saxigp5_awvalid               => hpWriteMaster(3).awvalid,
         saxigp5_awready               => hpWriteSlaveOut(3).awready,
         saxigp5_wdata                 => hpWriteMaster(3).wdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp5_wstrb                 => hpWriteMaster(3).wstrb(AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp5_wlast                 => hpWriteMaster(3).wlast,
         saxigp5_wvalid                => hpWriteMaster(3).wvalid,
         saxigp5_wready                => hpWriteSlaveOut(3).wready,
         saxigp5_bid                   => hpWriteSlaveOut(3).bid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp5_bresp                 => hpWriteSlaveOut(3).bresp,
         saxigp5_bvalid                => hpWriteSlaveOut(3).bvalid,
         saxigp5_bready                => hpWriteMaster(3).bready,
         saxigp5_arid                  => hpReadMaster(3).arid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp5_araddr                => hpReadMaster(3).araddr(AXI_HP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxigp5_arlen                 => hpReadMaster(3).arlen(AXI_HP_INIT_C.LEN_BITS_C-1 downto 0),
         saxigp5_arsize                => hpReadMaster(3).arsize,
         saxigp5_arburst               => hpReadMaster(3).arburst,
         saxigp5_arlock                => hpReadMaster(3).arlock(0),
         saxigp5_arcache               => hpReadMaster(3).arcache,
         saxigp5_arprot                => hpReadMaster(3).arprot,
         saxigp5_arvalid               => hpReadMaster(3).arvalid,
         saxigp5_arready               => hpReadSlaveOut(3).arready,
         saxigp5_rid                   => hpReadSlaveOut(3).rid(AXI_HP_INIT_C.ID_BITS_C-1 downto 0),
         saxigp5_rdata                 => hpReadSlaveOut(3).rdata(8*AXI_HP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxigp5_rresp                 => hpReadSlaveOut(3).rresp,
         saxigp5_rlast                 => hpReadSlaveOut(3).rlast,
         saxigp5_rvalid                => hpReadSlaveOut(3).rvalid,
         saxigp5_rready                => hpReadMaster(3).rready,
         saxigp5_awqos                 => "0000",
         saxigp5_arqos                 => "0000",
         -- S_AXI_ACP
         saxiacp_fpd_aclk              => acpAxiClk,
         saxiacp_awuser                => "11",
         saxiacp_aruser                => "11",
         saxiacp_awid                  => acpWriteMaster.awid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         saxiacp_awaddr                => acpWriteMaster.awaddr(AXI_ACP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxiacp_awlen                 => acpWriteMaster.awlen(AXI_ACP_INIT_C.LEN_BITS_C-1 downto 0),
         saxiacp_awsize                => acpWriteMaster.awsize,
         saxiacp_awburst               => acpWriteMaster.awburst,
         saxiacp_awlock                => acpWriteMaster.awlock(0),
         saxiacp_awcache               => acpWriteMaster.awcache,
         saxiacp_awprot                => acpWriteMaster.awprot,
         saxiacp_awvalid               => acpWriteMaster.awvalid,
         saxiacp_awready               => acpWriteSlaveOut.awready,
         saxiacp_wdata                 => acpWriteMaster.wdata(8*AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxiacp_wstrb                 => acpWriteMaster.wstrb(AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxiacp_wlast                 => acpWriteMaster.wlast,
         saxiacp_wvalid                => acpWriteMaster.wvalid,
         saxiacp_wready                => acpWriteSlaveOut.wready,
         saxiacp_bid                   => acpWriteSlaveOut.bid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         saxiacp_bresp                 => acpWriteSlaveOut.bresp,
         saxiacp_bvalid                => acpWriteSlaveOut.bvalid,
         saxiacp_bready                => acpWriteMaster.bready,
         saxiacp_arid                  => acpReadMaster.arid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         saxiacp_araddr                => acpReadMaster.araddr(AXI_ACP_INIT_C.ADDR_WIDTH_C-1 downto 0),
         saxiacp_arlen                 => acpReadMaster.arlen(AXI_ACP_INIT_C.LEN_BITS_C-1 downto 0),
         saxiacp_arsize                => acpReadMaster.arsize,
         saxiacp_arburst               => acpReadMaster.arburst,
         saxiacp_arlock                => acpReadMaster.arlock(0),
         saxiacp_arcache               => acpReadMaster.arcache,
         saxiacp_arprot                => acpReadMaster.arprot,
         saxiacp_arvalid               => acpReadMaster.arvalid,
         saxiacp_arready               => acpReadSlaveOut.arready,
         saxiacp_rid                   => acpReadSlaveOut.rid(AXI_ACP_INIT_C.ID_BITS_C-1 downto 0),
         saxiacp_rdata                 => acpReadSlaveOut.rdata(8*AXI_ACP_INIT_C.DATA_BYTES_C-1 downto 0),
         saxiacp_rresp                 => acpReadSlaveOut.rresp,
         saxiacp_rlast                 => acpReadSlaveOut.rlast,
         saxiacp_rvalid                => acpReadSlaveOut.rvalid,
         saxiacp_rready                => acpReadMaster.rready,
         saxiacp_awqos                 => "0000",
         saxiacp_arqos                 => "0000",
         -- EMIO ENET0
         emio_enet0_gmii_rx_clk        => armEthRx(0).enetGmiiRxClk,
         emio_enet0_speed_mode         => armEthTx(0).enetGmiispeedMode,
         emio_enet0_gmii_crs           => armEthRx(0).enetGmiiCrs,
         emio_enet0_gmii_col           => armEthRx(0).enetGmiiCol,
         emio_enet0_gmii_rxd           => armEthRx(0).enetGmiiRxd,
         emio_enet0_gmii_rx_er         => armEthRx(0).enetGmiiRxEr,
         emio_enet0_gmii_rx_dv         => armEthRx(0).enetGmiiRxDv,
         emio_enet0_gmii_tx_clk        => armEthRx(0).enetGmiiTxClk,
         emio_enet0_gmii_txd           => armEthTx(0).enetGmiiTxD,
         emio_enet0_gmii_tx_en         => armEthTx(0).enetGmiiTxEn,
         emio_enet0_gmii_tx_er         => armEthTx(0).enetGmiiTxEr,
         emio_enet0_mdio_mdc           => armEthTx(0).enetMdioMdc,
         emio_enet0_mdio_i             => armEthRx(0).enetMdioI,
         emio_enet0_mdio_o             => armEthTx(0).enetMdioO,
         emio_enet0_mdio_t             => armEthTx(0).enetMdioT,
         -- EMIO ENET1
         emio_enet1_gmii_rx_clk        => armEthRx(1).enetGmiiRxClk,
         emio_enet1_speed_mode         => armEthTx(1).enetGmiispeedMode,
         emio_enet1_gmii_crs           => armEthRx(1).enetGmiiCrs,
         emio_enet1_gmii_col           => armEthRx(1).enetGmiiCol,
         emio_enet1_gmii_rxd           => armEthRx(1).enetGmiiRxd,
         emio_enet1_gmii_rx_er         => armEthRx(1).enetGmiiRxEr,
         emio_enet1_gmii_rx_dv         => armEthRx(1).enetGmiiRxDv,
         emio_enet1_gmii_tx_clk        => armEthRx(1).enetGmiiTxClk,
         emio_enet1_gmii_txd           => armEthTx(1).enetGmiiTxD,
         emio_enet1_gmii_tx_en         => armEthTx(1).enetGmiiTxEn,
         emio_enet1_gmii_tx_er         => armEthTx(1).enetGmiiTxEr,
         emio_enet1_mdio_mdc           => armEthTx(1).enetMdioMdc,
         emio_enet1_mdio_i             => armEthRx(1).enetMdioI,
         emio_enet1_mdio_o             => armEthTx(1).enetMdioO,
         emio_enet1_mdio_t             => armEthTx(1).enetMdioT,
         -- EMIO ENET[1:0] MISC    
         emio_enet0_tsu_inc_ctrl       => (others => '0'),  -- ??? Not sure if I am setting this correctly
         emio_enet0_tsu_timer_cmp_val  => open,
         emio_enet1_tsu_inc_ctrl       => (others => '0'),  -- ??? Not sure if I am setting this correctly
         emio_enet1_tsu_timer_cmp_val  => open,
         emio_enet0_enet_tsu_timer_cnt => open,
         emio_enet0_ext_int_in         => '0',  -- ??? Not sure if I am setting this correctly
         emio_enet1_ext_int_in         => '0',  -- ??? Not sure if I am setting this correctly
         emio_enet0_dma_bus_width      => open,
         emio_enet1_dma_bus_width      => open,
         -- FMIO GPIO
         emio_gpio_i                   => (others => '0'),
         emio_gpio_o                   => open,
         emio_gpio_t                   => open,
         -- IRQ
         pl_ps_irq0(0)                 => armInterrupt(0),  -- ??? Not sure if I am setting this correctly
         pl_ps_irq1(0)                 => armInterrupt(1),  -- ??? Not sure if I am setting this correctly
         pl_acpinact                   => '0',  -- ??? Not sure if I am setting this correctly
         -- FCLK
         pl_clk0                       => fclk(0),
         pl_clk1                       => fclk(1),
         pl_clk2                       => fclk(2),
         pl_clk3                       => fclk(3));

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

