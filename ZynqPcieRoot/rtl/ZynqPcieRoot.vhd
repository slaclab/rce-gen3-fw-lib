-------------------------------------------------------------------------------
-- Title         : Zynq PCIE Root Core
-- File          : ZynqPcieRoot.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/09/2018
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq PCI Root core.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PCIE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PCIE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;

entity ZynqPcieRoot is
   generic (
      TPD_G       : time    := 1 ns
   );
   port (

      -- PCIE AXI Interface, AXIClk
      axiClk          : in    sl;
      axiClkRst       : in    sl;
      pcieReadMaster  : in    AxiReadMasterArray(1 downto 0);
      pcieReadSlave   : out   AxiReadSlaveArray(1 downto 0);
      pcieWriteMaster : in    AxiWriteMasterArray(1 downto 0);
      pcieWriteSlave  : out   AxiWriteSlaveArray(1 downto 0);

      -- User AXI Interface, sysclk200
      sysClk200       : in    sl;
      sysClk200Rst    : in    sl;
      userWriteSlave  : in    AxiWriteSlaveType;
      userWriteMaster : out   AxiWriteMasterType;
      userReadSlave   : in    AxiReadSlaveType;
      userReadMaster  : out   AxiReadMasterType;

      -- Master clock and reset
      pciRefClkP : in  sl;
      pciRefClkM : in  sl;
      pciResetL  : out sl;

      -- Interrupt output
      pcieInt    : out sl;

      -- PCIE Lines
      pcieRxP : in  sl;
      pcieRxM : in  sl;
      pcieTxP : out sl;
      pcieTxM : out sl
      );
end ZynqPcieRoot;

architecture structure of ZynqPcieRoot is

   -- Local signals
   signal intReadMaster   : AxiReadMasterArray(2 downto 0);
   signal intReadSlave    : AxiReadSlaveArray(2 downto 0);
   signal intWriteMaster  : AxiWriteMasterArray(2 downto 0);
   signal intWriteSlave   : AxiWriteSlaveArray(2 downto 0);
   signal intAxiClk       : sl;
   signal intAxiCtlClk    : sl;
   signal intAxiClkRst    : sl;
   signal intAxiCtlClkRst : sl;
   signal mmcmLock        : sl;
   signal intRefClk       : sl;

   signal intxMsiRequest  : sl;
   signal intxMsiGrant    : sl;
   signal msiEnable       : sl;
   signal msiVectorNum    : slv(4 downto 0);
   signal msiVectorWidth  : slv(2 downto 0);
   signal intPclkSelSlave : slv(0 downto 0);
   signal resetInL        : sl;

   COMPONENT axi_pcie_0
     PORT (
       axi_aresetn : IN STD_LOGIC;
       axi_aclk_out : OUT STD_LOGIC;
       axi_ctl_aclk_out : OUT STD_LOGIC;
       mmcm_lock : OUT STD_LOGIC;
       interrupt_out : OUT STD_LOGIC;
       INTX_MSI_Request : IN STD_LOGIC;
       INTX_MSI_Grant : OUT STD_LOGIC;
       MSI_enable : OUT STD_LOGIC;
       MSI_Vector_Num : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
       MSI_Vector_Width : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       s_axi_awid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       s_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axi_awregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       s_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       s_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       s_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       s_axi_awvalid : IN STD_LOGIC;
       s_axi_awready : OUT STD_LOGIC;
       s_axi_wdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       s_axi_wstrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       s_axi_wlast : IN STD_LOGIC;
       s_axi_wvalid : IN STD_LOGIC;
       s_axi_wready : OUT STD_LOGIC;
       s_axi_bid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       s_axi_bvalid : OUT STD_LOGIC;
       s_axi_bready : IN STD_LOGIC;
       s_axi_arid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
       s_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axi_arregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       s_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
       s_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
       s_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       s_axi_arvalid : IN STD_LOGIC;
       s_axi_arready : OUT STD_LOGIC;
       s_axi_rid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
       s_axi_rdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       s_axi_rlast : OUT STD_LOGIC;
       s_axi_rvalid : OUT STD_LOGIC;
       s_axi_rready : IN STD_LOGIC;
       m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axi_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       m_axi_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       m_axi_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       m_axi_awvalid : OUT STD_LOGIC;
       m_axi_awready : IN STD_LOGIC;
       m_axi_awlock : OUT STD_LOGIC;
       m_axi_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       m_axi_wdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
       m_axi_wstrb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       m_axi_wlast : OUT STD_LOGIC;
       m_axi_wvalid : OUT STD_LOGIC;
       m_axi_wready : IN STD_LOGIC;
       m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       m_axi_bvalid : IN STD_LOGIC;
       m_axi_bready : OUT STD_LOGIC;
       m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axi_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       m_axi_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       m_axi_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       m_axi_arvalid : OUT STD_LOGIC;
       m_axi_arready : IN STD_LOGIC;
       m_axi_arlock : OUT STD_LOGIC;
       m_axi_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       m_axi_rdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
       m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       m_axi_rlast : IN STD_LOGIC;
       m_axi_rvalid : IN STD_LOGIC;
       m_axi_rready : OUT STD_LOGIC;
       pci_exp_txp : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       pci_exp_txn : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       pci_exp_rxp : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
       pci_exp_rxn : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
       REFCLK : IN STD_LOGIC;
       s_axi_ctl_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axi_ctl_awvalid : IN STD_LOGIC;
       s_axi_ctl_awready : OUT STD_LOGIC;
       s_axi_ctl_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axi_ctl_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
       s_axi_ctl_wvalid : IN STD_LOGIC;
       s_axi_ctl_wready : OUT STD_LOGIC;
       s_axi_ctl_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       s_axi_ctl_bvalid : OUT STD_LOGIC;
       s_axi_ctl_bready : IN STD_LOGIC;
       s_axi_ctl_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axi_ctl_arvalid : IN STD_LOGIC;
       s_axi_ctl_arready : OUT STD_LOGIC;
       s_axi_ctl_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       s_axi_ctl_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       s_axi_ctl_rvalid : OUT STD_LOGIC;
       s_axi_ctl_rready : IN STD_LOGIC;
       int_pclk_out_slave : OUT STD_LOGIC;
       int_rxusrclk_out : OUT STD_LOGIC;
       int_dclk_out : OUT STD_LOGIC;
       int_userclk1_out : OUT STD_LOGIC;
       int_userclk2_out : OUT STD_LOGIC;
       int_oobclk_out : OUT STD_LOGIC;
       int_mmcm_lock_out : OUT STD_LOGIC;
       int_qplllock_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       int_qplloutclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       int_qplloutrefclk_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       int_rxoutclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
       int_pclk_sel_slave : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
     );
   END COMPONENT;

   attribute DONT_TOUCH : string;
   attribute DONT_TOUCH of intReadMaster       : signal is "true";
   attribute DONT_TOUCH of intReadSlave        : signal is "true";
   attribute DONT_TOUCH of intWriteMaster      : signal is "true";
   attribute DONT_TOUCH of intWriteSlave       : signal is "true";

begin

   -- Local Ref Clk 
   U_RefClk : IBUFDS_GTE2
      port map(
         O       => intRefClk,
         ODIV2   => open,
         I       => pciRefClkP,
         IB      => pciRefClkM,
         CEB     => '0'
      );

   U_AxiRst: entity work.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => true)
      port map (
         clk    => intAxiClk,
         rstIn  => mmcmLock,
         rstOut => intAxiClkRst);

   U_AxiCtlRst: entity work.RstPipeline
      generic map (
         TPD_G     => TPD_G,
         INV_RST_G => true)
      port map (
         clk    => intAxiCtlClk,
         rstIn  => mmcmLock,
         rstOut => intAxiCtlClkRst);


   intxMsiRequest   <= '0';
   msiEnable        <= '0';
   msiVectorNum     <= "00000";
   resetInL         <= not intAxiCtlClkRst;
   pciResetL        <= resetInL;

   U_AxiRoot : axi_pcie_0
      PORT MAP (
         axi_aresetn      => resetInL,
         axi_aclk_out     => intAxiClk,
         axi_ctl_aclk_out => intAxiCtlClk,
         mmcm_lock        => mmcmLock,
         interrupt_out    => pcieInt,
         INTX_MSI_Request => intxMsiRequest,
         INTX_MSI_Grant   => intxMsiGrant,
         MSI_enable       => msiEnable,
         MSI_Vector_Num   => msiVectorNum,
         MSI_Vector_Width => msiVectorWidth,

         -- Slave GP0: 0xB0000000 - 0xBFFFFFFF
         s_axi_awaddr   => intWriteMaster(1).awaddr(31 downto 0),
         s_axi_awvalid  => intWriteMaster(1).awvalid,
         s_axi_awready  => intWriteSlave(1).awready,
         s_axi_wdata    => intWriteMaster(1).wdata(63 downto 0),
         s_axi_wstrb    => intWriteMaster(1).wstrb(7 downto 0),
         s_axi_wvalid   => intWriteMaster(1).wvalid,
         s_axi_wready   => intWriteSlave(1).wready,
         s_axi_bresp    => intWriteSlave(1).bresp,
         s_axi_bvalid   => intWriteSlave(1).bvalid,
         s_axi_bready   => intWriteMaster(1).bready,
         s_axi_araddr   => intReadMaster(1).araddr(31 downto 0),
         s_axi_arvalid  => intReadMaster(1).arvalid,
         s_axi_arready  => intReadSlave(1).arready,
         s_axi_rdata    => intReadSlave(1).rdata(63 downto 0),
         s_axi_rresp    => intReadSlave(1).rresp,
         s_axi_rvalid   => intReadSlave(1).rvalid,
         s_axi_rready   => intReadMaster(1).rready,
         s_axi_awid     => intWriteMaster(1).awid(11 downto 0),
         s_axi_awregion => intWriteMaster(1).awregion,
         s_axi_awlen    => intWriteMaster(1).awlen,
         s_axi_awsize   => intWriteMaster(1).awsize,
         s_axi_awburst  => intWriteMaster(1).awburst,
         s_axi_wlast    => intWriteMaster(1).wlast,
         s_axi_bid      => intWriteSlave(1).bid(11 downto 0),
         s_axi_arid     => intReadMaster(1).arid(11 downto 0),
         s_axi_arregion => intReadMaster(1).arregion,
         s_axi_arlen    => intReadMaster(1).arlen,
         s_axi_arsize   => intReadMaster(1).arsize,
         s_axi_arburst  => intReadMaster(1).arburst,
         s_axi_rid      => intReadSlave(1).rid(11 downto 0),
         s_axi_rlast    => intReadSlave(1).rlast,

         -- Master HP:
         m_axi_awaddr   => intWriteMaster(2).awaddr(31 downto 0),
         m_axi_awvalid  => intWriteMaster(2).awvalid,
         m_axi_awready  => intWriteSlave(2).awready,
         m_axi_wdata    => intWriteMaster(2).wdata(63 downto 0),
         m_axi_wstrb    => intWriteMaster(2).wstrb(7 downto 0),
         m_axi_wvalid   => intWriteMaster(2).wvalid,
         m_axi_wready   => intWriteSlave(2).wready,
         m_axi_bresp    => intWriteSlave(2).bresp,
         m_axi_bvalid   => intWriteSlave(2).bvalid,
         m_axi_bready   => intWriteMaster(2).bready,
         m_axi_araddr   => intReadMaster(2).araddr(31 downto 0),
         m_axi_arvalid  => intReadMaster(2).arvalid,
         m_axi_arready  => intReadSlave(2).arready,
         m_axi_rdata    => intReadSlave(2).rdata(63 downto 0),
         m_axi_rresp    => intReadSlave(2).rresp,
         m_axi_rvalid   => intReadSlave(2).rvalid,
         m_axi_rready   => intReadMaster(2).rready,
         m_axi_awlen    => intWriteMaster(2).awlen,
         m_axi_awsize   => intWriteMaster(2).awsize,
         m_axi_awburst  => intWriteMaster(2).awburst,
         m_axi_wlast    => intWriteMaster(2).wlast,
         m_axi_arlen    => intReadMaster(2).arlen,
         m_axi_arsize   => intReadMaster(2).arsize,
         m_axi_arburst  => intReadMaster(2).arburst,
         m_axi_rlast    => intReadSlave(2).rlast,
         m_axi_awprot   => intWriteMaster(2).awprot,
         m_axi_awlock   => intWriteMaster(2).awlock(0),
         m_axi_awcache  => intWriteMaster(2).awcache,
         m_axi_arprot   => intReadMaster(2).arprot,
         m_axi_arlock   => intReadMaster(2).arlock(0),
         m_axi_arcache  => intReadMaster(2).arcache,

         -- Cntrl GP0:  0xA0000000 - 0xAFFFFFFF
         s_axi_ctl_awaddr  => intWriteMaster(0).awaddr(31 downto 0),
         s_axi_ctl_awvalid => intWriteMaster(0).awvalid,
         s_axi_ctl_awready => intWriteSlave(0).awready,
         s_axi_ctl_wdata   => intWriteMaster(0).wdata(31 downto 0),
         s_axi_ctl_wstrb   => intWriteMaster(0).wstrb(3 downto 0),
         s_axi_ctl_wvalid  => intWriteMaster(0).wvalid,
         s_axi_ctl_wready  => intWriteSlave(0).wready,
         s_axi_ctl_bresp   => intWriteSlave(0).bresp,
         s_axi_ctl_bvalid  => intWriteSlave(0).bvalid,
         s_axi_ctl_bready  => intWriteMaster(0).bready,
         s_axi_ctl_araddr  => intReadMaster(0).araddr(31 downto 0),
         s_axi_ctl_arvalid => intReadMaster(0).arvalid,
         s_axi_ctl_arready => intReadSlave(0).arready,
         s_axi_ctl_rdata   => intReadSlave(0).rdata(31 downto 0),
         s_axi_ctl_rresp   => intReadSlave(0).rresp,
         s_axi_ctl_rvalid  => intReadSlave(0).rvalid,
         s_axi_ctl_rready  => intReadMaster(0).rready,

         pci_exp_txp(0)    => pcieTxP,
         pci_exp_txn(0)    => pcieTxM,
         pci_exp_rxp(0)    => pcieRxP,
         pci_exp_rxn(0)    => pcieRxM,

         REFCLK            => intRefClk,

         int_pclk_out_slave    => open,
         int_rxusrclk_out      => open,
         int_dclk_out          => open,
         int_userclk1_out      => open,
         int_userclk2_out      => open,
         int_oobclk_out        => open,
         int_mmcm_lock_out     => open,
         int_qplllock_out      => open,
         int_qplloutclk_out    => open,
         int_qplloutrefclk_out => open,
         int_rxoutclk_out      => open,
         int_pclk_sel_slave    => intPclkSelSlave
      );

   intReadSlave(1).rid(31 downto 12)    <= (others=>'0');
   intReadSlave(1).rdata(127 downto 64) <= (others=>'0');
   intWriteSlave(1).bid(31 downto 12)   <= (others=>'0');

   intReadSlave(0).rdata(127 downto 32) <= (others=>'0');
   intReadSlave(0).rlast                <= '1';
   intReadSlave(0).rid                  <= (others=>'0');
   intWriteSlave(0).bid                 <= (others=>'0');

   intReadMaster(2).arid                   <= (others=>'0');
   intReadMaster(2).arqos                  <= (others=>'0');
   intReadMaster(2).arregion               <= (others=>'0');
   intReadMaster(2).araddr(63 downto 32)   <= (others=>'0');
   intWriteMaster(2).awid                  <= (others=>'0');
   intWriteMaster(2).awqos                 <= (others=>'0');
   intWriteMaster(2).awregion              <= (others=>'0');
   intWriteMaster(2).wid                   <= (others=>'0');
   intWriteMaster(2).awaddr(63 downto 32)  <= (others=>'0');
   intWriteMaster(2).wdata(1023 downto 64) <= (others=>'0');
   intWriteMaster(2).wstrb(127  downto  8) <= (others=>'0');

   --------------------------------
   -- SLAVE Interface FIFOs
   --------------------------------
   U_Slave0Read: entity work.AxiReadPathFifo
      generic map (
         TPD_G                  => TPD_G,
         ID_FIXED_EN_G          => false,
         SIZE_FIXED_EN_G        => false,
         BURST_FIXED_EN_G       => false,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => false,
         PROT_FIXED_EN_G        => false,
         CACHE_FIXED_EN_G       => false,
         ADDR_FIFO_ADDR_WIDTH_G => 9,
         DATA_FIFO_ADDR_WIDTH_G => 9,
         AXI_CONFIG_G           => AXI_MAST_GP_INIT_C
      ) port map (
         sAxiClk        => axiClk,
         sAxiRst        => axiClkRst,
         sAxiReadMaster => pcieReadMaster(0),
         sAxiReadSlave  => pcieReadSlave(0),
         mAxiClk        => intAxiCtlClk,
         mAxiRst        => intAxiCtlClkRst,
         mAxiReadMaster => intReadMaster(0),
         mAxiReadSlave  => intReadSlave(0));

   U_Slave0Write: entity work.AxiWritePathFifo 
      generic map (
         TPD_G                  => TPD_G,
         ID_FIXED_EN_G          => false,
         SIZE_FIXED_EN_G        => false,
         BURST_FIXED_EN_G       => false,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => false,
         PROT_FIXED_EN_G        => false,
         CACHE_FIXED_EN_G       => false,
         ADDR_FIFO_ADDR_WIDTH_G => 9,
         DATA_FIFO_ADDR_WIDTH_G => 9,
         RESP_FIFO_ADDR_WIDTH_G => 9,
         AXI_CONFIG_G           => AXI_MAST_GP_INIT_C
      ) port map (
         sAxiClk         => axiClk,
         sAxiRst         => axiClkRst,
         sAxiWriteMaster => pcieWriteMaster(0),
         sAxiWriteSlave  => pcieWriteSlave(0),
         mAxiClk         => intAxiCtlClk,
         mAxiRst         => intAxiCtlClkRst,
         mAxiWriteMaster => intWriteMaster(0),
         mAxiWriteSlave  => intWriteSlave(0));

   U_Slave1Read: entity work.AxiReadPathFifo
      generic map (
         TPD_G                  => TPD_G,
         ID_FIXED_EN_G          => false,
         SIZE_FIXED_EN_G        => false,
         BURST_FIXED_EN_G       => false,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => false,
         PROT_FIXED_EN_G        => false,
         CACHE_FIXED_EN_G       => false,
         ADDR_FIFO_ADDR_WIDTH_G => 9,
         DATA_FIFO_ADDR_WIDTH_G => 9,
         AXI_CONFIG_G           => AXI_MAST_GP64_INIT_C
      ) port map (
         sAxiClk        => axiClk,
         sAxiRst        => axiClkRst,
         sAxiReadMaster => pcieReadMaster(1),
         sAxiReadSlave  => pcieReadSlave(1),
         mAxiClk        => intAxiClk,
         mAxiRst        => intAxiClkRst,
         mAxiReadMaster => intReadMaster(1),
         mAxiReadSlave  => intReadSlave(1));

   U_Slave1Write: entity work.AxiWritePathFifo 
      generic map (
         TPD_G                  => TPD_G,
         ID_FIXED_EN_G          => false,
         SIZE_FIXED_EN_G        => false,
         BURST_FIXED_EN_G       => false,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => false,
         PROT_FIXED_EN_G        => false,
         CACHE_FIXED_EN_G       => false,
         ADDR_FIFO_ADDR_WIDTH_G => 9,
         DATA_FIFO_ADDR_WIDTH_G => 9,
         RESP_FIFO_ADDR_WIDTH_G => 9,
         AXI_CONFIG_G           => AXI_MAST_GP64_INIT_C
      ) port map (
         sAxiClk         => axiClk,
         sAxiRst         => axiClkRst,
         sAxiWriteMaster => pcieWriteMaster(1),
         sAxiWriteSlave  => pcieWriteSlave(1),
         mAxiClk         => intAxiClk,
         mAxiRst         => intAxiClkRst,
         mAxiWriteMaster => intWriteMaster(1),
         mAxiWriteSlave  => intWriteSlave(1));

   --------------------------------
   -- Master Interface FIFOs
   --------------------------------
   U_MastRead: entity work.AxiReadPathFifo
      generic map (
         TPD_G                  => TPD_G,
         ID_FIXED_EN_G          => false,
         SIZE_FIXED_EN_G        => false,
         BURST_FIXED_EN_G       => false,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => false,
         PROT_FIXED_EN_G        => false,
         CACHE_FIXED_EN_G       => false,
         ADDR_FIFO_ADDR_WIDTH_G => 9,
         DATA_FIFO_ADDR_WIDTH_G => 9,
         AXI_CONFIG_G           => AXI_HP_INIT_C
      ) port map (
         sAxiClk         => intAxiClk,
         sAxiRst         => intAxiClkRst,
         sAxiReadMaster  => intReadMaster(2),
         sAxiReadSlave   => intReadSlave(2),
         mAxiClk         => sysCLk200,
         mAxiRst         => sysCLk200Rst,
         mAxiReadMaster  => userReadMaster,
         mAxiReadSlave   => userReadSlave);

   U_MastWrite: entity work.AxiWritePathFifo 
      generic map (
         TPD_G                  => TPD_G,
         ID_FIXED_EN_G          => false,
         SIZE_FIXED_EN_G        => false,
         BURST_FIXED_EN_G       => false,
         LEN_FIXED_EN_G         => false,
         LOCK_FIXED_EN_G        => false,
         PROT_FIXED_EN_G        => false,
         CACHE_FIXED_EN_G       => false,
         ADDR_FIFO_ADDR_WIDTH_G => 9,
         DATA_FIFO_ADDR_WIDTH_G => 9,
         RESP_FIFO_ADDR_WIDTH_G => 9,
         AXI_CONFIG_G           => AXI_HP_INIT_C
      ) port map (
         sAxiClk         => intAxiClk,
         sAxiRst         => intAxiClkRst,
         sAxiWriteMaster => intWriteMaster(2),
         sAxiWriteSlave  => intWriteSlave(2),
         mAxiClk         => sysCLk200,
         mAxiRst         => sysCLk200Rst,
         mAxiWriteMaster => userWriteMaster,
         mAxiWriteSlave  => userWriteSlave);

end architecture structure;

