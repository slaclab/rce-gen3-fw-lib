-------------------------------------------------------------------------------
-- Title         : Zynq PCIE Express Core
-- File          : ZynqPcieMaster.vhd
-------------------------------------------------------------------------------
-- Description:
-- Wrapper file for Zynq PCI Express core.
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

entity ZynqPcieMaster is
   generic (
      TPD_G       : time    := 1 ns;
      HSIO_MODE_G : boolean := false
      );
   port (

      -- Local Bus
      axiClk         : in  sl;
      axiClkRst      : in  sl;
      axiReadMaster  : in  AxiLiteReadMasterType;
      axiReadSlave   : out AxiLiteReadSlaveType;
      axiWriteMaster : in  AxiLiteWriteMasterType;
      axiWriteSlave  : out AxiLiteWriteSlaveType;

      -- Master clock and reset
      pciRefClkP : in sl;
      pciRefClkM : in sl;

      -- Reset output
      pcieResetL : out sl;

      -- PCIE Lines
      pcieRxP : in  sl;
      pcieRxM : in  sl;
      pcieTxP : out sl;
      pcieTxM : out sl
      );
end ZynqPcieMaster;

architecture structure of ZynqPcieMaster is

   type PcieCfgOutType is record
      status             : slv(15 downto 0);
      command            : slv(15 downto 0);
      dStatus            : slv(15 downto 0);
      dCommand           : slv(15 downto 0);
      dCommand2          : slv(15 downto 0);
      lStatus            : slv(15 downto 0);
      lCommand           : slv(15 downto 0);
      pcieLinkState      : slv(2 downto 0);
      pmcsrPmeEn         : sl;
      pmcsrPowerstate    : slv(1 downto 0);
      pmcsrPmeStatus     : sl;
      receivedFuncLvlRst : sl;
   end record PcieCfgOutType;

   constant PCIE_CFG_OUT_SIZE_C : integer := 120;

   function toSlv (cfg : PcieCfgOutType) return slv is
      variable vector : slv(PCIE_CFG_OUT_SIZE_C-1 downto 0);
      variable i      : integer := 0;
   begin
      assignSlv(i, vector, cfg.status);
      assignSlv(i, vector, cfg.command);
      assignSlv(i, vector, cfg.dStatus);
      assignSlv(i, vector, cfg.dCommand);
      assignSlv(i, vector, cfg.dCommand2);
      assignSlv(i, vector, cfg.lStatus);
      assignSlv(i, vector, cfg.lCommand);
      assignSlv(i, vector, cfg.pcieLinkState);
      assignSlv(i, vector, cfg.pmcsrPmeEn);
      assignSlv(i, vector, cfg.pmcsrPowerstate);
      assignSlv(i, vector, cfg.pmcsrPmeStatus);
      assignSlv(i, vector, cfg.receivedFuncLvlRst);
      return vector;
   end function;

   function toPcieCfgOutType (vector : slv(PCIE_CFG_OUT_SIZE_C-1 downto 0)) return PcieCfgOutType is
      variable cfg : PcieCfgOutType;
      variable i   : integer := 0;
   begin
      assignRecord(i, vector, cfg.status);
      assignRecord(i, vector, cfg.command);
      assignRecord(i, vector, cfg.dStatus);
      assignRecord(i, vector, cfg.dCommand);
      assignRecord(i, vector, cfg.dCommand2);
      assignRecord(i, vector, cfg.lStatus);
      assignRecord(i, vector, cfg.lCommand);
      assignRecord(i, vector, cfg.pcieLinkState);
      assignRecord(i, vector, cfg.pmcsrPmeEn);
      assignRecord(i, vector, cfg.pmcsrPowerstate);
      assignRecord(i, vector, cfg.pmcsrPmeStatus);
      assignRecord(i, vector, cfg.receivedFuncLvlRst);
      return cfg;
   end function toPcieCfgOutType;

   -- Local signals
   signal pciRefClk    : sl;
   signal wrFifoDout   : slv(94 downto 0);
   signal wrFifoRdEn   : sl;
   signal wrFifoValid  : sl;
   signal rdFifoDin    : slv(94 downto 0);
   signal rdFifoDout   : slv(94 downto 0);
   signal rdFifoWrEn   : sl;
   signal rdFifoFull   : sl;
   signal rdFifoValid  : sl;
   signal pciClk       : sl;
   signal pciClkRst    : sl;
   signal txBufAv      : slv(5 downto 0);
   signal txReady      : sl;
   signal txValid      : sl;
   signal rxReady      : sl;
   signal rxValid      : sl;
   signal linkUp       : sl;
   signal cfg          : PcieCfgOutType;
   signal cfgSync      : PcieCfgOutType;
   signal cfgSyncSlv   : slv(PCIE_CFG_OUT_SIZE_C-1 downto 0);
   signal phyLinkUp    : sl;
   signal pciExpTxP    : slv(0 downto 0);
   signal pciExpTxN    : slv(0 downto 0);
   signal pciExpRxP    : slv(0 downto 0);
   signal pciExpRxN    : slv(0 downto 0);
   signal intResetL    : sl;
   signal axiClkRstInt : sl := '1';

   type RegType is record
      wrFifoDin         : slv(94 downto 0);
      wrFifoWrEn        : sl;
      rdFifoRdEn        : sl;
      cfgBusNumber      : slv(7 downto 0);
      cfgDeviceNumber   : slv(4 downto 0);
      cfgFunctionNumber : slv(2 downto 0);
      remResetL         : sl;
      pcieEnable        : sl;
      axiReadSlave      : AxiLiteReadSlaveType;
      axiWriteSlave     : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      wrFifoDin         => (others => '0'),
      wrFifoWrEn        => '0',
      rdFifoRdEn        => '0',
      cfgBusNumber      => (others => '0'),
      cfgDeviceNumber   => (others => '0'),
      cfgFunctionNumber => (others => '0'),
      remResetL         => '0',
      pcieEnable        => '0',
      axiReadSlave      => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave     => AXI_LITE_WRITE_SLAVE_INIT_C
      );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal phyLinkUpSync         : sl;
   signal linkUpSync            : sl;
   signal pciClkRstSync         : sl;
   signal cfgBusNumberSync      : slv(7 downto 0);
   signal cfgDeviceNumberSync   : slv(4 downto 0);
   signal cfgFunctionNumberSync : slv(2 downto 0);

   attribute INIT                 : string;
   attribute INIT of axiClkRstInt : signal is "1";

begin

   -- Reset registration
   process (axiClk)
   begin
      if rising_edge(axiClk) then
         axiClkRstInt <= axiClkRst after TPD_G;
      end if;
   end process;

   -- Outputs
   pcieResetL <= r.remResetL;

   U_PciClkEnGen: if HSIO_MODE_G = false generate
      U_PciRefClk : IBUFDS_GTE2
         port map(
            O     => pciRefClk,
            ODIV2 => open,
            I     => pciRefClkP,
            IB    => pciRefClkM,
            CEB   => '0'
            );
   end generate;

   U_PciClkDisGen: if HSIO_MODE_G = true generate
      pciRefClk <= axiClk;
   end generate;

   -------------------------------------------------------------------------------------------------
   -- Sync signals to pciClk
   -------------------------------------------------------------------------------------------------
   RstSync_1 : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '0')
      port map (
         clk      => pciClk,
         asyncRst => r.pcieEnable,
         syncRst  => intResetL);

   SynchronizerFifo_2 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 16)
      port map (
         rst                => axiClkRstInt,
         wr_clk             => axiClk,
         din(7 downto 0)    => r.cfgBusNumber,
         din(12 downto 8)   => r.cfgDeviceNumber,
         din(15 downto 13)  => r.cfgFunctionNumber,
         rd_clk             => pciClk,
         dout(7 downto 0)   => cfgBusNumberSync,
         dout(12 downto 8)  => cfgDeviceNumberSync,
         dout(15 downto 13) => cfgFunctionNumberSync);

   -------------------------------------------------------------------------------------------------
   -- Some signals need to be sync'd to AxiClk
   -------------------------------------------------------------------------------------------------
   -- pcieClk125
   Synchronizer_1 : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axiClk,
         rst     => axiClkRstInt,
         dataIn  => phyLinkUp,
         dataOut => phyLinkUpSync);

   -- pcieUserClk2
   SynchronizerVector_1 : entity work.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk        => axiClk,
         rst        => axiClkRstInt,
         dataIn(0)  => linkUp,
         dataIn(1)  => pciClkRst,
         dataOut(0) => linkUpSync,
         dataOut(1) => pciClkRstSync);  

   SynchronizerFifo_1 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => PCIE_CFG_OUT_SIZE_C)
      port map (
         rst    => axiClkRstInt,
         wr_clk => pciClk,
         din    => toSlv(cfg),
         rd_clk => axiClk,
         dout   => cfgSyncSlv);
   cfgSync <= toPcieCfgOutType(cfgSyncSlv);

   --------------------------------------------
   -- Registers: 0x0000 - 0xFFFF
   --------------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRstInt, axiReadMaster, axiWriteMaster, cfgSync, intResetL, linkUpSync,
            pciClkRstSync, phyLinkUpSync, r, rdFifoDout, rdFifoValid) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.wrFifoWrEn := '0';
      v.rdFifoRdEn := '0';

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (axiWriteMaster.awaddr(15 downto 0)) is

            -- Write FIFO QWord0, - 0x1000
            when x"1000" =>
               v.wrFifoDin(31 downto 0) := axiWriteMaster.wdata;

            -- Write FIFO QWord1, - 0x1004
            when x"1004" =>
               v.wrFifoDin(63 downto 32) := axiWriteMaster.wdata;

            -- Write FIFO QWord2, - 0x1008
            when x"1008" =>
               v.wrFifoDin(94 downto 64) := axiWriteMaster.wdata(30 downto 0);
               v.wrFifoWrEn              := '1';

            -- Config Bus Number, - 0x1018
            when x"1018" =>
               v.cfgBusNumber := axiWriteMaster.wdata(7 downto 0);

            -- Config Device Number, - 0x101C
            when x"101C" =>
               v.cfgDeviceNumber := axiWriteMaster.wdata(4 downto 0);

            -- Config Function Number, - 0x1020
            when x"1020" =>
               v.cfgFunctionNumber := axiWriteMaster.wdata(2 downto 0);

            -- Enable Register - 0x1044
            when x"1044" =>
               v.pcieEnable := axiWriteMaster.wdata(0);
               v.remResetL  := axiWriteMaster.wdata(1);

            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);

      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- Decode address and assign read data
         case axiReadMaster.araddr(15 downto 0) is

            -- Read FIFO QWord0, - 0x100C
            when X"100C" =>
               v.axiReadSlave.rdata := rdFifoDout(31 downto 0);
               v.rdFifoRdEn         := '1';

            -- Read FIFO QWord1, - 0x1010
            when X"1010" =>
               v.axiReadSlave.rdata := rdFifoDout(63 downto 32);

            -- Read FIFO QWord2, - 0x1014
            when X"1014" =>
               v.axiReadSlave.rdata(31)          := rdFifoValid;
               v.axiReadSlave.rdata(30 downto 0) := rdFifoDout(94 downto 64);

            -- Config Bus Number, - 0x1018
            when X"1018" =>
               v.axiReadSlave.rdata(7 downto 0) := r.cfgBusNumber;

            -- Config Device Number, - 0x101C
            when X"101C" =>
               v.axiReadSlave.rdata(4 downto 0) := r.cfgDeviceNumber;

            -- Config Function Number, - 0x1020
            when X"1020" =>
               v.axiReadSlave.rdata(2 downto 0) := r.cfgFunctionNumber;

            -- Config Status, - 0x1024
            when X"1024" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.Status;

            -- Config Status, - 0x1028
            when X"1028" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.Command;

            -- Config DStatus, - 0x102C
            when X"102C" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.DStatus;

            -- Config DStatus, - 0x1030
            when X"1030" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.DCommand;

            -- Config DStatus, - 0x1034
            when X"1034" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.DCommand2;

            -- Config LStatus, - 0x1038
            when X"1038" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.LStatus;

            -- Config LStatus, - 0x103C
            when X"103C" =>
               v.axiReadSlave.rdata(15 downto 0) := cfgSync.LCommand;

            -- Other Status, - 0x1040
            when X"1040" =>
               v.axiReadSlave.rdata(2 downto 0) := cfgSync.PcieLinkState;
               v.axiReadSlave.rdata(3)          := linkUpSync;
               v.axiReadSlave.rdata(4)          := phyLinkUpSync;
               v.axiReadSlave.rdata(6 downto 5) := cfgSync.PmcsrPowerstate;
               v.axiReadSlave.rdata(7)          := cfgSync.PmcsrPmeEn;
               v.axiReadSlave.rdata(8)          := cfgSync.PmcsrPmeStatus;
               v.axiReadSlave.rdata(9)          := cfgSync.ReceivedFuncLvlRst;
               v.axiReadSlave.rdata(12)         := pciClkRstSync;

            -- Enable Register - 0x1044
            when X"1044" =>
               v.axiReadSlave.rdata(0) := v.pcieEnable;
               v.axiReadSlave.rdata(1) := v.remResetL;
               v.axiReadSlave.rdata(4) := intResetL;

            when others => null;
         end case;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
      end if;

      -- Reset
      if (axiClkRstInt = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;
      
   end process;


   -----------------------------------------
   -- FIFOs, Dist Ram
   -----------------------------------------
   U_WriteFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => false,      -- Async FIFO
         BRAM_EN_G       => false,      -- Use Dist Ram
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         ALTERA_SYN_G    => false,
         ALTERA_RAM_G    => "M512",
         USE_BUILT_IN_G  => false,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 95,
         ADDR_WIDTH_G    => 4,
         INIT_G          => "0",
         FULL_THRES_G    => 15,
         EMPTY_THRES_G   => 1
         ) port map (
            rst           => axiClkRstInt,
            wr_clk        => axiClk,
            wr_en         => r.wrFifoWrEn,
            din           => r.wrFifoDin,
            wr_data_count => open,
            wr_ack        => open,
            overflow      => open,
            prog_full     => open,
            almost_full   => open,
            full          => open,
            not_full      => open,
            rd_clk        => pciClk,
            rd_en         => wrFifoRdEn,
            dout          => wrFifoDout,
            rd_data_count => open,
            valid         => wrFifoValid,
            underflow     => open,
            prog_empty    => open,
            almost_empty  => open,
            empty         => open
            );

   wrFifoRdEn <= txReady and txValid;
   txValid    <= wrFifoValid when txBufAv > 1 else '0';

   U_ReadFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         RST_ASYNC_G     => false,
         GEN_SYNC_FIFO_G => false,      -- Async FIFO
         BRAM_EN_G       => false,      -- Use Dist Ram
         FWFT_EN_G       => true,
         USE_DSP48_G     => "no",
         ALTERA_SYN_G    => false,
         ALTERA_RAM_G    => "M512",
         USE_BUILT_IN_G  => false,
         XIL_DEVICE_G    => "7SERIES",
         SYNC_STAGES_G   => 3,
         DATA_WIDTH_G    => 95,
         ADDR_WIDTH_G    => 4,
         INIT_G          => "0",
         FULL_THRES_G    => 15,
         EMPTY_THRES_G   => 1
         )
      port map (
         rst           => axiClkRstInt,
         wr_clk        => pciClk,
         wr_en         => rdFifoWrEn,
         din           => rdFifoDin,
         wr_data_count => open,
         wr_ack        => open,
         overflow      => open,
         prog_full     => open,
         almost_full   => open,
         full          => rdFifoFull,
         not_full      => open,
         rd_clk        => axiClk,
         rd_en         => r.rdFifoRdEn,
         dout          => rdFifoDout,
         rd_data_count => open,
         valid         => rdFifoValid,
         underflow     => open,
         prog_empty    => open,
         almost_empty  => open,
         empty         => open
         );

   rxReady    <= not rdFifoFull;
   rdFifoWrEn <= rxReady and rxValid;


   -----------------------------------------
   -- PCI Express Core
   -----------------------------------------

   U_PciCoreEnGen: if HSIO_MODE_G = false generate

      pcieTxP      <= pciExpTxP(0);
      pcieTxM      <= pciExpTxN(0);
      pciExpRxP(0) <= pcieRxP;
      pciExpRxN(0) <= pcieRxM;

      U_Pcie : entity work.pcie_7x_v1_9
         generic map (
            PCIE_EXT_CLK => "FALSE"
            )
         port map (
            pci_exp_txp                                => pciExpTxP,
            pci_exp_txn                                => pciExpTxN,
            pci_exp_rxp                                => pciExpRxP,
            pci_exp_rxn                                => pciExpRxN,
            PIPE_PCLK_IN                               => '0',
            PIPE_RXUSRCLK_IN                           => '0',
            PIPE_RXOUTCLK_IN                           => (others => '0'),
            PIPE_DCLK_IN                               => '0',
            PIPE_USERCLK1_IN                           => '0',
            PIPE_USERCLK2_IN                           => '0',
            PIPE_OOBCLK_IN                             => '0',
            PIPE_MMCM_LOCK_IN                          => '0',
            PIPE_TXOUTCLK_OUT                          => open,
            PIPE_RXOUTCLK_OUT                          => open,
            PIPE_PCLK_SEL_OUT                          => open,
            PIPE_GEN3_OUT                              => open,
            user_clk_out                               => pciClk,
            user_reset_out                             => pciClkRst,
            user_lnk_up                                => linkUp,
            tx_buf_av                                  => txBufAv,
            tx_cfg_req                                 => open,
            tx_err_drop                                => open,
            s_axis_tx_tready                           => txReady,
            s_axis_tx_tdata                            => wrFifoDout(63 downto 0),
            s_axis_tx_tkeep                            => wrFifoDout(71 downto 64),
            s_axis_tx_tlast                            => wrFifoDout(94),
            s_axis_tx_tvalid                           => txValid,
            s_axis_tx_tuser                            => wrFifoDout(75 downto 72),
            tx_cfg_gnt                                 => '1',
            m_axis_rx_tdata                            => rdFifoDin(63 downto 0),
            m_axis_rx_tkeep                            => rdFifoDin(71 downto 64),
            m_axis_rx_tlast                            => rdFifoDin(94),
            m_axis_rx_tvalid                           => rxValid,
            m_axis_rx_tready                           => rxReady,
            m_axis_rx_tuser                            => rdFifoDin(93 downto 72),
            rx_np_ok                                   => '1',
            rx_np_req                                  => '1',
            fc_cpld                                    => open,
            fc_cplh                                    => open,
            fc_npd                                     => open,
            fc_nph                                     => open,
            fc_pd                                      => open,
            fc_ph                                      => open,
            fc_sel                                     => "000",
            cfg_mgmt_do                                => open,
            cfg_mgmt_rd_wr_done                        => open,
            cfg_status                                 => cfg.status,
            cfg_command                                => cfg.command,
            cfg_dstatus                                => cfg.dStatus,
            cfg_dcommand                               => cfg.dCommand,
            cfg_lstatus                                => cfg.lStatus,
            cfg_lcommand                               => cfg.lCommand,
            cfg_dcommand2                              => cfg.dCommand2,
            cfg_pcie_link_state                        => cfg.pcieLinkState,
            cfg_pmcsr_pme_en                           => cfg.pmcsrPmeEn,
            cfg_pmcsr_powerstate                       => cfg.pmcsrPowerstate,
            cfg_pmcsr_pme_status                       => cfg.pmcsrPmeStatus,
            cfg_received_func_lvl_rst                  => cfg.receivedFuncLvlRst,
            cfg_mgmt_di                                => (others => '0'),
            cfg_mgmt_byte_en                           => "1111",
            cfg_mgmt_dwaddr                            => (others => '0'),
            cfg_mgmt_wr_en                             => '0',
            cfg_mgmt_rd_en                             => '0',
            cfg_mgmt_wr_readonly                       => '0',
            cfg_err_ecrc                               => '0',
            cfg_err_ur                                 => '0',
            cfg_err_cpl_timeout                        => '0',
            cfg_err_cpl_unexpect                       => '0',
            cfg_err_cpl_abort                          => '0',
            cfg_err_posted                             => '0',
            cfg_err_cor                                => '0',
            cfg_err_atomic_egress_blocked              => '0',
            cfg_err_internal_cor                       => '0',
            cfg_err_malformed                          => '0',
            cfg_err_mc_blocked                         => '0',
            cfg_err_poisoned                           => '0',
            cfg_err_norecovery                         => '0',
            cfg_err_tlp_cpl_header                     => (others => '0'),
            cfg_err_cpl_rdy                            => open,
            cfg_err_locked                             => '0',
            cfg_err_acs                                => '0',
            cfg_err_internal_uncor                     => '0',
            cfg_trn_pending                            => '0',
            cfg_pm_halt_aspm_l0s                       => '0',
            cfg_pm_halt_aspm_l1                        => '0',
            cfg_pm_force_state_en                      => '0',
            cfg_pm_force_state                         => (others => '0'),
            cfg_dsn                                    => (others => '0'),
            cfg_interrupt                              => '0',
            cfg_interrupt_rdy                          => open,
            cfg_interrupt_assert                       => '0',
            cfg_interrupt_di                           => (others => '0'),
            cfg_interrupt_do                           => open,
            cfg_interrupt_mmenable                     => open,
            cfg_interrupt_msienable                    => open,
            cfg_interrupt_msixenable                   => open,
            cfg_interrupt_msixfm                       => open,
            cfg_interrupt_stat                         => '0',
            cfg_pciecap_interrupt_msgnum               => (others => '0'),
            cfg_to_turnoff                             => open,
            cfg_turnoff_ok                             => '0',
            cfg_bus_number                             => open,
            cfg_device_number                          => open,
            cfg_function_number                        => open,
            cfg_pm_wake                                => '0',
            cfg_pm_send_pme_to                         => '0',
            cfg_ds_bus_number                          => cfgBusNumberSync,
            cfg_ds_device_number                       => cfgDeviceNumberSync,
            cfg_ds_function_number                     => cfgFunctionNumberSync,
            cfg_mgmt_wr_rw1c_as_rw                     => '0',
            cfg_msg_received                           => open,
            cfg_msg_data                               => open,
            cfg_bridge_serr_en                         => open,
            cfg_slot_control_electromech_il_ctl_pulse  => open,
            cfg_root_control_syserr_corr_err_en        => open,
            cfg_root_control_syserr_non_fatal_err_en   => open,
            cfg_root_control_syserr_fatal_err_en       => open,
            cfg_root_control_pme_int_en                => open,
            cfg_aer_rooterr_corr_err_reporting_en      => open,
            cfg_aer_rooterr_non_fatal_err_reporting_en => open,
            cfg_aer_rooterr_fatal_err_reporting_en     => open,
            cfg_aer_rooterr_corr_err_received          => open,
            cfg_aer_rooterr_non_fatal_err_received     => open,
            cfg_aer_rooterr_fatal_err_received         => open,
            cfg_msg_received_err_cor                   => open,
            cfg_msg_received_err_non_fatal             => open,
            cfg_msg_received_err_fatal                 => open,
            cfg_msg_received_pm_as_nak                 => open,
            cfg_msg_received_pm_pme                    => open,
            cfg_msg_received_pme_to_ack                => open,
            cfg_msg_received_assert_int_a              => open,
            cfg_msg_received_assert_int_b              => open,
            cfg_msg_received_assert_int_c              => open,
            cfg_msg_received_assert_int_d              => open,
            cfg_msg_received_deassert_int_a            => open,
            cfg_msg_received_deassert_int_b            => open,
            cfg_msg_received_deassert_int_c            => open,
            cfg_msg_received_deassert_int_d            => open,
            cfg_msg_received_setslotpowerlimit         => open,
            pl_directed_link_change                    => "00",
            pl_directed_link_width                     => "00",
            pl_directed_link_speed                     => '0',
            pl_directed_link_auton                     => '0',
            pl_upstream_prefer_deemph                  => '0',
            pl_sel_lnk_rate                            => open,
            pl_sel_lnk_width                           => open,
            pl_ltssm_state                             => open,
            pl_lane_reversal_mode                      => open,
            pl_phy_lnk_up                              => phyLinkUp,
            pl_tx_pm_state                             => open,
            pl_rx_pm_state                             => open,
            pl_link_upcfg_cap                          => open,
            pl_link_gen2_cap                           => open,
            pl_link_partner_gen2_supported             => open,
            pl_initial_link_width                      => open,
            pl_directed_change_done                    => open,
            pl_received_hot_rst                        => open,
            pl_transmit_hot_rst                        => '0',
            pl_downstream_deemph_source                => '0',
            cfg_err_aer_headerlog                      => (others => '0'),
            cfg_aer_interrupt_msgnum                   => (others => '0'),
            cfg_err_aer_headerlog_set                  => open,
            cfg_aer_ecrc_check_en                      => open,
            cfg_aer_ecrc_gen_en                        => open,
            cfg_vc_tcvc_map                            => open,
            PIPE_MMCM_RST_N                            => '1',
            sys_clk                                    => pciRefClk,
            sys_rst_n                                  => intResetL
            );
   end generate;

   U_PciCoreDisGen: if HSIO_MODE_G = true generate
      pciExpTxP              <= (others=>'0');
      pciExpTxN              <= (others=>'0');
      pciExpRxP              <= (others=>'0');
      pciExpRxN              <= (others=>'0');
      pcieTxP                <= '1';
      pcieTxM                <= '0';
      pciClk                 <= axiClk;
      pciClkRst              <= axiClkRst;
      linkUp                 <= '1';
      txBufAv                <= (others=>'0');
      txReady                <= '0';
      rdFifoDin              <= (others=>'0');
      rxValid                <= '0';
      phyLinkUp              <= '0';
      cfg.status             <= (others=>'0');
      cfg.command            <= (others=>'0');
      cfg.dStatus            <= (others=>'0');
      cfg.dCommand           <= (others=>'0');
      cfg.lStatus            <= (others=>'0');
      cfg.lCommand           <= (others=>'0');
      cfg.dCommand2          <= (others=>'0');
      cfg.pcieLinkState      <= (others=>'0');
      cfg.pmcsrPmeEn         <= '0';
      cfg.pmcsrPowerstate    <= (others=>'0');
      cfg.pmcsrPmeStatus     <= '0';
      cfg.receivedFuncLvlRst <= '0';
      cfgBusNumberSync       <= (others=>'0');
      cfgDeviceNumberSync    <= (others=>'0');
      cfgFunctionNumberSync  <= (others=>'0');
   end generate;

end architecture structure;

