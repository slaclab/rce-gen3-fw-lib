-------------------------------------------------------------------------------
-- File       : RceEthernetMac.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper file for Zynq Ethernet 10G core
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE 10G Ethernet Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'SLAC RCE 10G Ethernet Core', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;


library surf;
use surf.StdRtlPkg.all;
use surf.EthMacPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.PpiPkg.all;
use rce_gen3_fw_lib.RceG3Pkg.all;

entity RceEthernetMac is
   generic (
      -- Generic Configurations
      TPD_G              : time                  := 1 ns;
      PHY_TYPE_G         : string                := "XGMII";
      RCE_DMA_MODE_G     : RceDmaModeType        := RCE_DMA_PPI_C;
      SYNTH_MODE_G       : string                := "inferred";
      MEMORY_TYPE_G      : string                := "block";
      EN_JUMBO_G         : boolean               := true;
      -- User ETH Configurations
      UDP_SERVER_EN_G    : boolean               := false;
      UDP_SERVER_SIZE_G  : positive              := 1;
      UDP_SERVER_PORTS_G : PositiveArray         := (0 => 8192);
      BYP_EN_G           : boolean               := false;
      BYP_ETH_TYPE_G     : slv(15 downto 0)      := x"AAAA");
   port (
      -- DMA Interface
      dmaClk               : in  sl;
      dmaRst               : in  sl;
      dmaState             : in  RceDmaStateType;
      dmaIbMaster          : out AxiStreamMasterType;
      dmaIbSlave           : in  AxiStreamSlaveType;
      dmaObMaster          : in  AxiStreamMasterType;
      dmaObSlave           : out AxiStreamSlaveType;
      -- Configuration/Status Interface
      phyReady             : in  sl;
      rxShift              : in  slv(3 downto 0);
      txShift              : in  slv(3 downto 0);
      ethHeaderSize        : in  slv(15 downto 0);
      macConfig            : in  EthMacConfigType;
      macStatus            : out EthMacStatusType;
      -- PHY clock and Reset
      ethClk               : in  sl;
      ethRst               : in  sl;
      -- User ETH interface
      userEthUdpIbMaster   : in  AxiStreamMasterType;
      userEthUdpIbSlave    : out AxiStreamSlaveType;
      userEthUdpObMaster   : out AxiStreamMasterType;
      userEthUdpObSlave    : in  AxiStreamSlaveType;
      userEthBypIbMaster   : in  AxiStreamMasterType;
      userEthBypIbSlave    : out AxiStreamSlaveType;
      userEthBypObMaster   : out AxiStreamMasterType;
      userEthBypObSlave    : in  AxiStreamSlaveType;
      -- XLGMII PHY Interface
      xlgmiiRxd            : in  slv(127 downto 0) := (others => '0');
      xlgmiiRxc            : in  slv(15 downto 0)  := (others => '0');
      xlgmiiTxd            : out slv(127 downto 0);
      xlgmiiTxc            : out slv(15 downto 0);
      -- XGMII PHY Interface
      xgmiiRxd             : in  slv(63 downto 0)  := (others => '0');
      xgmiiRxc             : in  slv(7 downto 0)   := (others => '0');
      xgmiiTxd             : out slv(63 downto 0);
      xgmiiTxc             : out slv(7 downto 0);
      -- GMII PHY Interface
      gmiiRxDv             : in  sl                := '0';
      gmiiRxEr             : in  sl                := '0';
      gmiiRxd              : in  slv(7 downto 0)   := (others => '0');
      gmiiTxEn             : out sl;
      gmiiTxEr             : out sl;
      gmiiTxd              : out slv(7 downto 0));
end RceEthernetMac;

architecture mapping of RceEthernetMac is

   -- For 1GbE: 64 clock cycles for 512 bits = one pause "quanta"
   -- For 10GbE: 8 clock cycles for 512 bits = one pause "quanta"
   -- For 40GbE: 4 clock cycles for 512 bits = one pause "quanta"
   constant PAUSE_512BITS_C : positive := ite(PHY_TYPE_G = "GMII", 64, ite(PHY_TYPE_G = "XGMII", 8, 4));

   type RegType is record
      sof          : sl;
      wrCnt        : slv(15 downto 0);
      rxSlave      : AxiStreamSlaveType;
      txSlave      : AxiStreamSlaveType;
      dmaIbMaster  : AxiStreamMasterType;
      ibPrimMaster : AxiStreamMasterType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      sof          => '1',
      wrCnt        => (others => '0'),
      rxSlave      => AXI_STREAM_SLAVE_INIT_C,
      txSlave      => AXI_STREAM_SLAVE_INIT_C,
      dmaIbMaster  => AXI_STREAM_MASTER_INIT_C,
      ibPrimMaster => AXI_STREAM_MASTER_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ibMacPrimMaster : AxiStreamMasterType;
   signal ibMacPrimSlave  : AxiStreamSlaveType;
   signal obMacPrimMaster : AxiStreamMasterType;
   signal obMacPrimSlave  : AxiStreamSlaveType;

   signal ibPrimMaster : AxiStreamMasterType;
   signal ibPrimSlave  : AxiStreamSlaveType;
   signal obPrimMaster : AxiStreamMasterType;
   signal obPrimSlave  : AxiStreamSlaveType;

   signal rxMaster : AxiStreamMasterType;
   signal rxSlave  : AxiStreamSlaveType;
   signal txMaster : AxiStreamMasterType;
   signal txSlave  : AxiStreamSlaveType;

begin

   ---------------
   -- ETH MAC Core
   ---------------
   U_EthMacTop : entity surf.EthMacTop
      generic map (
         -- Simulation Generics
         TPD_G             => TPD_G,
         -- MAC Configurations
         PAUSE_EN_G        => true,
         PAUSE_512BITS_G   => PAUSE_512BITS_C,
         PHY_TYPE_G        => PHY_TYPE_G,
         DROP_ERR_PKT_G    => true,
         JUMBO_G           => EN_JUMBO_G,
         -- SYNTH_MODE_G        => SYNTH_MODE_G,  <--- generic for future XPM FIFO release
         -- MEMORY_TYPE_G       => MEMORY_TYPE_G, <--- generic for future XPM FIFO release
         FILT_EN_G         => true,
         PRIM_COMMON_CLK_G => true,
         PRIM_CONFIG_G     => EMAC_AXIS_CONFIG_C,
         BYP_EN_G          => BYP_EN_G,
         BYP_ETH_TYPE_G    => BYP_ETH_TYPE_G,
         BYP_COMMON_CLK_G  => true,
         BYP_CONFIG_G      => EMAC_AXIS_CONFIG_C)
      port map (
         -- Core Clock and Reset
         ethClk           => ethClk,
         ethRst           => ethRst,
         -- Primary Interface
         primClk          => ethClk,
         primRst          => ethRst,
         ibMacPrimMaster  => ibMacPrimMaster,
         ibMacPrimSlave   => ibMacPrimSlave,
         obMacPrimMaster  => obMacPrimMaster,
         obMacPrimSlave   => obMacPrimSlave,
         -- Bypass interface
         bypClk           => ethClk,
         bypRst           => ethRst,
         ibMacBypMaster   => userEthBypIbMaster,
         ibMacBypSlave    => userEthBypIbSlave,
         obMacBypMaster   => userEthBypObMaster,
         obMacBypSlave    => userEthBypObSlave,
         -- XLGMII PHY Interface
         xlgmiiRxd        => xlgmiiRxd,
         xlgmiiRxc        => xlgmiiRxc,
         xlgmiiTxd        => xlgmiiTxd,
         xlgmiiTxc        => xlgmiiTxc,
         -- XGMII PHY Interface
         xgmiiRxd         => xgmiiRxd,
         xgmiiRxc         => xgmiiRxc,
         xgmiiTxd         => xgmiiTxd,
         xgmiiTxc         => xgmiiTxc,
         -- GMII PHY Interface
         gmiiRxDv         => gmiiRxDv,
         gmiiRxEr         => gmiiRxEr,
         gmiiRxd          => gmiiRxd,
         gmiiTxEn         => gmiiTxEn,
         gmiiTxEr         => gmiiTxEr,
         gmiiTxd          => gmiiTxd,
         -- Configuration and status
         phyReady         => phyReady,
         ethConfig        => macConfig,
         ethStatus        => macStatus);

   ------------------
   -- ETH USER Router
   ------------------
   U_UserEthRouter : entity rce_gen3_fw_lib.RceUserEthRouter
      generic map (
         TPD_G              => TPD_G,
         SYNTH_MODE_G       => SYNTH_MODE_G,
         UDP_SERVER_EN_G    => UDP_SERVER_EN_G,
         UDP_SERVER_SIZE_G  => UDP_SERVER_SIZE_G,
         UDP_SERVER_PORTS_G => UDP_SERVER_PORTS_G)
      port map (
         -- MAC Interface (ethClk domain)
         ethClk          => ethClk,
         ethRst          => ethRst,
         ibMacPrimMaster => ibMacPrimMaster,
         ibMacPrimSlave  => ibMacPrimSlave,
         obMacPrimMaster => obMacPrimMaster,
         obMacPrimSlave  => obMacPrimSlave,
         -- User ETH Interface (ethClk domain)
         ethUdpObMaster  => userEthUdpObMaster,
         ethUdpObSlave   => userEthUdpObSlave,
         ethUdpIbMaster  => userEthUdpIbMaster,
         ethUdpIbSlave   => userEthUdpIbSlave,
         -- CPU Interface (axisClk domain)
         axisClk         => dmaClk,
         axisRst         => dmaRst,
         ibPrimMaster    => ibPrimMaster,
         ibPrimSlave     => ibPrimSlave,
         obPrimMaster    => obPrimMaster,
         obPrimSlave     => obPrimSlave);

   BYPASS_SHIFT : if (RCE_DMA_MODE_G /= RCE_DMA_PPI_C) generate
      dmaIbMaster  <= obPrimMaster;
      obPrimSlave  <= dmaIbSlave;
      ibPrimMaster <= dmaObMaster;
      dmaObSlave   <= ibPrimSlave;
   end generate;

   GEN_SHIFT : if (RCE_DMA_MODE_G = RCE_DMA_PPI_C) generate

      -------------------------------------------------
      -- Shift inbound data n bytes to the left.
      -- This adds bytes of data at start of the packet
      -------------------------------------------------
      U_RxShift : entity surf.AxiStreamShift
         generic map (
            TPD_G          => TPD_G,
            PIPE_STAGES_G  => 1,
            AXIS_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
            ADD_VALID_EN_G => true)
         port map (
            axisClk     => dmaClk,
            axisRst     => dmaRst,
            axiStart    => '1',
            axiShiftDir => '0',         -- 0 = left (lsb to msb)
            axiShiftCnt => rxShift,
            sAxisMaster => obPrimMaster,
            sAxisSlave  => obPrimSlave,
            mAxisMaster => rxMaster,
            mAxisSlave  => rxSlave);

      ----------------------------------------------
      -- Shift outbound data n bytes to the right.
      -- This removes bytes of data at start
      -- of the packet. These were added by software
      -- to create a software friendly alignment of
      -- outbound data.
      ----------------------------------------------
      U_TxShift : entity surf.AxiStreamShift
         generic map (
            TPD_G         => TPD_G,
            PIPE_STAGES_G => 1,
            AXIS_CONFIG_G => PPI_AXIS_CONFIG_INIT_C)
         port map (
            axisClk     => dmaClk,
            axisRst     => dmaRst,
            axiStart    => '1',
            axiShiftDir => '1',         -- 1 = right (msb to lsb)
            axiShiftCnt => txShift,
            sAxisMaster => dmaObMaster,
            sAxisSlave  => dmaObSlave,
            mAxisMaster => txMaster,
            mAxisSlave  => txSlave);

      --------------
      -- PPI support
      --------------
      comb : process (dmaIbSlave, dmaRst, ethHeaderSize, ibPrimSlave, r,
                      rxMaster, txMaster) is
         variable v    : RegType;
         variable eofe : sl;
      begin
         -- Latch the current value
         v := r;

         -- Reset the flags
         v.txSlave := AXI_STREAM_SLAVE_INIT_C;
         v.rxSlave := AXI_STREAM_SLAVE_INIT_C;
         if dmaIbSlave.tReady = '1' then
            v.dmaIbMaster.tValid := '0';
         end if;
         if ibPrimSlave.tReady = '1' then
            v.ibPrimMaster.tValid := '0';
         end if;

         -- Check for RX data and ready to move
         if (rxMaster.tValid = '1') and (v.dmaIbMaster.tValid = '0') then
            -- Accept the data
            v.rxSlave.tReady := '1';
            -- Move the data
            v.dmaIbMaster    := rxMaster;
            -- Increment the counter
            v.wrCnt          := r.wrCnt + 1;
            -- Check for EOF
            if (rxMaster.tLast = '1') then
               -- Reset the counter
               v.wrCnt := (others => '0');
            end if;
            -- Get EOFE bit
            eofe                := axiStreamGetUserBit(RCEG3_AXIS_DMA_CONFIG_C, rxMaster, EMAC_EOFE_BIT_C);
            -- Reset tUser field
            v.dmaIbMaster.tUser := (others => '0');
            -- Set EOH if necessary
            if (r.wrCnt = ethHeaderSize) then
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.dmaIbMaster, PPI_EOH_C, '1');
            end if;
            -- Update ERR bit with EOFE
            if (rxMaster.tLast = '1') then
               axiStreamSetUserBit(PPI_AXIS_CONFIG_INIT_C, v.dmaIbMaster, PPI_ERR_C, eofe);
            end if;
         end if;

         -- Check for TX data and ready to move
         if (txMaster.tValid = '1') and (v.ibPrimMaster.tValid = '0') then
            -- Accept the data
            v.txSlave.tReady     := '1';
            -- Move the data
            v.ibPrimMaster       := txMaster;
            -- Get PPI_ERR bit
            eofe                 := axiStreamGetUserBit(PPI_AXIS_CONFIG_INIT_C, txMaster, PPI_ERR_C);
            -- Reset tUser field
            v.ibPrimMaster.tUser := (others => '0');
            -- Check for SOF
            if r.sof = '1' then
               -- Reset the flag
               v.sof := '0';
               -- Insert the EMAC_SOF_BIT_C bit after the AxiStreamShift
               axiStreamSetUserBit(RCEG3_AXIS_DMA_CONFIG_C, v.ibPrimMaster, EMAC_SOF_BIT_C, '1', 0);
            end if;
            -- Check for EOF
            if (txMaster.tLast = '1') then
               -- Set the flag
               v.sof := '1';
               -- Insert the EMAC_EOFE_BIT_C bit
               axiStreamSetUserBit(RCEG3_AXIS_DMA_CONFIG_C, v.ibPrimMaster, EMAC_EOFE_BIT_C, eofe);
            end if;
         end if;

         -- Combinatorial output
         rxSlave <= v.rxSlave;
         txSlave <= v.txSlave;

         -- Reset
         if (dmaRst = '1') then
            v := REG_INIT_C;
         end if;

         -- Register the variable for next clock cycle
         rin <= v;

         -- Outputs
         dmaIbMaster  <= r.dmaIbMaster;
         ibPrimMaster <= r.ibPrimMaster;

      end process comb;

      seq : process (dmaClk) is
      begin
         if rising_edge(dmaClk) then
            r <= rin after TPD_G;
         end if;
      end process seq;

   end generate;

end architecture mapping;
