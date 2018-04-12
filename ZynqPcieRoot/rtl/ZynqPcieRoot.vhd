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
      pciRefClkP : in sl;
      pciRefClkM : in sl;

      -- Reset output
      pcieResetL : out sl;

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

begin

   -- Local Ref Clk 
   U_RefClk : IBUFDS_GTE2
      port map(
         O       => intRefClk,
         ODIV2   => open,
         I       => pcieRefClkP,
         IB      => pcieRefClkM,
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


   U_AxiRoot : axi_pcie_0
      PORT MAP (
         axi_aresetn      => sysClk200Rst,
         axi_aclk_out     => intAxiClk,
         axi_ctl_aclk_out => intAxiCtlClk
         mmcm_lock        => mmcmLock,
         interrupt_out    => pcieInt,
         INTX_MSI_Request => '0',
         INTX_MSI_Grant   => open
         MSI_enable       => '0',
         MSI_Vector_Num   => "00000",
         MSI_Vector_Width => open,

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
         s_axi_rready   => intReadSlave(1).rready,
         s_axi_awid     => intWriteMaster(1).awid,
         s_axi_awregion => intWriteMaster(1).awregion,
         s_axi_awlen    => intWriteMaster(1).awlen,
         s_axi_awsize   => intWriteMaster(1).awsize,
         s_axi_awburst  => intWriteMaster(1).awburst,
         s_axi_wlast    => intWriteMaster(1).wlast,
         s_axi_bid      => intWriteSlave(1).bid,
         s_axi_arid     => intReadMaster(1).arid,
         s_axi_arregion => intReadMaster(1).arregion
         s_axi_arlen    => intReadMaster(1).arlen,
         s_axi_arsize   => intReadMaster(1).arsize,
         s_axi_arburst  => intReadMaster(1).arburst,
         s_axi_rid      => intReadSlave(1).rid,
         s_axi_rlast    => intReadSlave(1).rlast,

         -- Master HP:  0xA0000000 - 0xAFFFFFFF
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
         m_axi_rready   => intReadSlave(2).rready,
         m_axi_awlen    => intWriteMaster(2).awlen,
         m_axi_awsize   => intWriteMaster(2).awsize,
         m_axi_awburst  => intWriteMaster(2).awburst,
         m_axi_wlast    => intWriteMaster(2).wlast,
         m_axi_arlen    => intReadMaster(2).arlen,
         m_axi_arsize   => intReadMaster(2).arsize,
         m_axi_arburst  => intReadMaster(2).arburst,
         m_axi_rlast    => intReadSlave(2).rlast,
         m_axi_awprot   => intWriteMaster(2).awprot,
         m_axi_awlock   => intWriteMaster(2).awlock,
         m_axi_awcache  => intWriteMaster(2).awcache,
         m_axi_arprot   => intReadMaster(2).arprot,
         m_axi_arlock   => intReadMaster(2).arlock,
         m_axi_arcache  => intReadMaster(2).arcache,

         -- Cntrl GP0:  0xA0000000 - 0xAFFFFFFF
         s_axi_ctl_awaddr  => intWriteMaster(0).awaddr(31 downto 0),
         s_axi_ctl_awvalid => intWriteMaster(0).awvalid,
         s_axi_ctl_awready => intWriteSlave(0).awready,
         s_axi_ctl_wdata   => intWriteMaster(0).wdata(63 downto 0),
         s_axi_ctl_wstrb   => intWriteMaster(0).wstrb(7 downto 0),
         s_axi_ctl_wvalid  => intWriteMaster(0).wvalid,
         s_axi_ctl_wready  => intWriteSlave(0).wready,
         s_axi_ctl_bresp   => intWriteSlave(0).bresp,
         s_axi_ctl_bvalid  => intWriteSlave(0).bvalid,
         s_axi_ctl_bready  => intWriteMaster(0).bready,
         s_axi_ctl_araddr  => intReadMaster(0).araddr(31 downto 0),
         s_axi_ctl_arvalid => intReadMaster(0).arvalid,
         s_axi_ctl_arready => intReadSlave(0).arready,
         s_axi_ctl_rdata   => intReadSlave(0).rdata(63 downto 0),
         s_axi_ctl_rresp   => intReadSlave(0).rresp,
         s_axi_ctl_rvalid  => intReadSlave(0).rvalid,
         s_axi_ctl_rready  => intReadMaster(0).rready,

         pci_exp_txp       => pcieTxP,
         pci_exp_txn       => pcieTxM,
         pci_exp_rxp       => pcieRxP,
         pci_exp_rxn       => pcieRxM,
         --REFCLK => REFCLK,

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
         int_pclk_sel_slave    => "0"
      );

   intReadMaster(2).arid      <= (others=>'0');
   intReadMaster(2).arqos     <= (others=>'0');
   intReadMaster(2).arregion  <= (others=>'0');
   intWriteMaster(2).awid     <= (others=>'0');
   intWriteMaster(2).awqos    <= (others=>'0');
   intWriteMaster(2).awregion <= (others=>'0');
   intWriteMaster(2).wid      <= (others=>'0');
   intReadSlave(1).rlast      <= '1';
   intReadSlave(1).rid        <= (others=>'0');
   intWriteSlave(1).bid       <= (others=>'0');


   --------------------------------
   -- SLAVE Interface FIFOs
   --------------------------------
   U_SlaveGen: for i in 0 to 1 generate

      U_SlaveRead: entity work.AxiReadPathFifo
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
            sAxiClk        => intAxiClk,
            sAxiRst        => intAxiClkRst,
            sAxiReadMaster => intReadMaster(i),
            sAxiReadSlave  => intReadSlave(i),
            mAxiClk        => axiClk,
            mAxiRst        => axiClkRst,
            mAxiReadMaster => pcieReadMaster(i),
            mAxiReadSlave  => pcieReadSlave(i));

      U_SlaveWrite: entity work.AxiWritePathFifo 
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
            sAxiClk         => intAxiClk,
            sAxiRst         => intAxiClkRst,
            sAxiWriteMaster => intWriteMaster(i),
            sAxiWriteSlave  => intWriteSlave(i),
            mAxiClk         => axiClk,
            mAxiRst         => axiClkRst,
            mAxiWriteMaster => pcieWriteMaster(i),
            mAxiWriteSlave  => pcieWriteSlave(i));

   end generate;

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
         sAxiClk         => intAxiCtlClk,
         sAxiRst         => intAxiCtlClkRst,
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
         sAxiClk         => intAxiCtlClk,
         sAxiRst         => intAxiCtlClkRst,
         sAxiWriteMaster => intWriteMaster(2),
         sAxiWriteSlave  => intWriteSlave(2),
         mAxiClk         => sysCLk200,
         mAxiRst         => sysCLk200Rst,
         mAxiWriteMaster => userWriteMaster,
         mAxiWriteSlave  => userWriteSlave);

end architecture structure;

