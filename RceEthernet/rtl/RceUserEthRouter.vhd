-------------------------------------------------------------------------------
-- File       : RceUserEthRouter.vhd
-- Author     : Larry Ruckman  <ruckman@slac.stanford.edu>
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Module to route CPU/User Ethernet data
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

use work.StdRtlPkg.all;
use work.EthMacPkg.all;
use work.AxiStreamPkg.all;
use work.RceG3Pkg.all;

entity RceUserEthRouter is
   generic (
      -- Generic Configurations
      TPD_G              : time          := 1 ns;
      SYNTH_MODE_G       : string        := "inferred";
      UDP_SERVER_EN_G    : boolean       := false;
      UDP_SERVER_SIZE_G  : positive      := 1;
      UDP_SERVER_PORTS_G : PositiveArray := (0 => 8192));
   port (
      -- MAC Interface (ethClk domain)
      ethClk          : in  sl;
      ethRst          : in  sl;
      ibMacPrimMaster : out AxiStreamMasterType;
      ibMacPrimSlave  : in  AxiStreamSlaveType;
      obMacPrimMaster : in  AxiStreamMasterType;
      obMacPrimSlave  : out AxiStreamSlaveType;
      -- User ETH Interface (ethClk domain)
      ethUdpIbMaster  : in  AxiStreamMasterType;
      ethUdpIbSlave   : out AxiStreamSlaveType;
      ethUdpObMaster  : out AxiStreamMasterType;
      ethUdpObSlave   : in  AxiStreamSlaveType;
      -- CPU Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      ibPrimMaster    : in  AxiStreamMasterType;
      ibPrimSlave     : out AxiStreamSlaveType;
      obPrimMaster    : out AxiStreamMasterType;
      obPrimSlave     : in  AxiStreamSlaveType);
end RceUserEthRouter;

architecture rtl of RceUserEthRouter is

   type StateType is (
      IDLE_S,
      PRIM_S,
      USER_S);

   type RegType is record
      cacheCnt       : natural range 0 to 3;
      cache          : AxiStreamMasterArray(2 downto 0);
      cnt            : natural range 0 to 3;
      txMaster       : AxiStreamMasterType;
      ethUdpObMaster : AxiStreamMasterType;
      obMacPrimSlave : AxiStreamSlaveType;
      state          : StateType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      cacheCnt       => 0,
      cache          => (others => AXI_STREAM_MASTER_INIT_C),
      cnt            => 0,
      txMaster       => AXI_STREAM_MASTER_INIT_C,
      ethUdpObMaster => AXI_STREAM_MASTER_INIT_C,
      obMacPrimSlave => AXI_STREAM_SLAVE_INIT_C,
      state          => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal rxMaster : AxiStreamMasterType;
   signal rxSlave  : AxiStreamSlaveType;
   signal txMaster : AxiStreamMasterType;
   signal txSlave  : AxiStreamSlaveType;

--   attribute dont_touch      : string;
--   attribute dont_touch of r : signal is "TRUE";         

begin

   U_RxFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G             => TPD_G,
         INT_PIPE_STAGES_G => 0,
         PIPE_STAGES_G     => 1,
         SLAVE_READY_EN_G  => true,
         VALID_THOLD_G     => 1,
         -- FIFO configurations

         -- SYNTH_MODE_G        => SYNTH_MODE_G,  <--- generic for future XPM FIFO release
         -- MEMORY_TYPE_G       => "distributed", <--- generic for future XPM FIFO release
         BRAM_EN_G       => false,
         GEN_SYNC_FIFO_G => false,

         FIFO_ADDR_WIDTH_G   => 4,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => RCEG3_AXIS_DMA_CONFIG_C,
         MASTER_AXI_CONFIG_G => EMAC_AXIS_CONFIG_C)
      port map (
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => ibPrimMaster,
         sAxisSlave  => ibPrimSlave,
         mAxisClk    => ethClk,
         mAxisRst    => ethRst,
         mAxisMaster => rxMaster,
         mAxisSlave  => rxSlave);

   U_TxFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G             => TPD_G,
         INT_PIPE_STAGES_G => 0,
         PIPE_STAGES_G     => 1,
         SLAVE_READY_EN_G  => true,
         VALID_THOLD_G     => 1,
         -- FIFO configurations

         -- SYNTH_MODE_G        => SYNTH_MODE_G,  <--- generic for future XPM FIFO release
         -- MEMORY_TYPE_G       => "distributed", <--- generic for future XPM FIFO release
         BRAM_EN_G       => false,
         GEN_SYNC_FIFO_G => false,

         FIFO_ADDR_WIDTH_G   => 4,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => EMAC_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C)
      port map (
         sAxisClk    => ethClk,
         sAxisRst    => ethRst,
         sAxisMaster => txMaster,
         sAxisSlave  => txSlave,
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => obPrimMaster,
         mAxisSlave  => obPrimSlave);

   BYPASS_USER_MUX : if (UDP_SERVER_EN_G = false) generate
      ibMacPrimMaster <= rxMaster;
      rxSlave         <= ibMacPrimSlave;
      txMaster        <= obMacPrimMaster;
      obMacPrimSlave  <= txSlave;
      ethUdpObMaster  <= AXI_STREAM_MASTER_INIT_C;
      ethUdpIbSlave   <= AXI_STREAM_SLAVE_FORCE_C;
   end generate;

   GEN_USER_MUX : if (UDP_SERVER_EN_G = true) generate

      U_AxiStreamMux : entity work.AxiStreamMux
         generic map (
            TPD_G        => TPD_G,
            NUM_SLAVES_G => 2)
         port map (
            -- Clock and reset
            axisClk         => ethClk,
            axisRst         => ethRst,
            -- Slaves
            sAxisMasters(0) => rxMaster,
            sAxisMasters(1) => ethUdpIbMaster,
            sAxisSlaves(0)  => rxSlave,
            sAxisSlaves(1)  => ethUdpIbSlave,
            -- Master
            mAxisMaster     => ibMacPrimMaster,
            mAxisSlave      => ibMacPrimSlave);

      comb : process (ethRst, ethUdpObSlave, obMacPrimMaster, r, txSlave) is
         variable v          : RegType;
         variable i          : natural;
         variable ipv4       : boolean;
         variable udpType    : boolean;
         variable udpPort    : boolean;
         variable userEthDet : boolean;
         variable udpNum     : slv(15 downto 0);
      begin
         -- Latch the current value
         v := r;

         -- Reset the flags
         v.obMacPrimSlave := AXI_STREAM_SLAVE_INIT_C;
         if (txSlave.tReady = '1') then
            v.txMaster.tValid := '0';
            v.txMaster.tLast  := '0';
            v.txMaster.tUser  := (others => '0');
            v.txMaster.tKeep  := (others => '1');
         end if;
         if (ethUdpObSlave.tReady = '1') then
            v.ethUdpObMaster.tValid := '0';
            v.ethUdpObMaster.tLast  := '0';
            v.ethUdpObMaster.tUser  := (others => '0');
            v.ethUdpObMaster.tKeep  := (others => '1');
         end if;

         -------------------------------------------------------------------------------------------------------
         -- IPv4/EtherType/UDP data fields:
         -- https://docs.google.com/spreadsheets/d/1_1M1keasfq8RLmRYHkO0IlRhMq5YZTgJ7OGrWvkib8I/edit?usp=sharing
         -- Note: Assuming NON-VLAN traffic
         -------------------------------------------------------------------------------------------------------

         -- Check for IPv4 EtherType
         if (r.cache(0).tData(111 downto 96) = IPV4_TYPE_C) then
            ipv4 := true;
         else
            ipv4 := false;
         end if;

         -- Check for UDP Protocol
         if (r.cache(1).tData(63 downto 56) = UDP_C) then
            udpType := true;
         else
            udpType := false;
         end if;

         -- Convert to little endianness 
         udpNum(15 downto 8) := obMacPrimMaster.tData(39 downto 32);
         udpNum(7 downto 0)  := obMacPrimMaster.tData(47 downto 40);

         -- Check if matches one of the User's UDP ports
         udpPort := false;
         for i in (UDP_SERVER_SIZE_G-1) downto 0 loop
            if (udpNum = UDP_SERVER_PORTS_G(i)) then
               udpPort := true;
            end if;
         end loop;

         -- Check if outbound Ethernet frame is a user Ethernet frame (non-fragmentation)
         if (ipv4 = true) and (udpType = true) and (udpPort = true) and (r.cache(0).tUser(EMAC_FRAG_BIT_C) = '0') then
            userEthDet := true;
         else
            userEthDet := false;
         end if;

         -- State Machine
         case r.state is
            ----------------------------------------------------------------------
            when IDLE_S =>
               -- Check for data
               if (obMacPrimMaster.tValid = '1') then

                  -- Accept the streaming data
                  v.obMacPrimSlave.tReady := '1';

                  -- Cache the data
                  v.cache(r.cacheCnt) := obMacPrimMaster;

                  -- Increment the counter
                  v.cacheCnt := r.cacheCnt + 1;

                  -- Check for EOF
                  if (obMacPrimMaster.tLast = '1') then
                     -- Next state
                     v.state := PRIM_S;
                  end if;

                  -- Check the counter
                  if (r.cacheCnt = 2) then

                     -- Check for CPU ETH data
                     if (userEthDet = false) then
                        -- Next state
                        v.state := PRIM_S;

                     -- Else this is user ETH data
                     else
                        -- Next state
                        v.state := USER_S;
                     end if;

                  end if;

               end if;
            ----------------------------------------------------------------------
            when PRIM_S =>
               -- Check if moving data
               if (obMacPrimMaster.tValid = '1') and (v.txMaster.tValid = '0') then

                  -- Check if moving cached data
                  if (r.cnt < r.cacheCnt) then

                     -- Increment the counter
                     v.cnt := r.cnt + 1;

                     -- Move the cached data
                     v.txMaster := r.cache(r.cnt);

                  else

                     -- Accept the streaming data
                     v.obMacPrimSlave.tReady := '1';

                     -- Move the streaming data
                     v.txMaster := obMacPrimMaster;

                  end if;

                  -- Check for EOF
                  if (v.txMaster.tLast = '1') then
                     -- Next state
                     v.state := IDLE_S;
                  end if;

               end if;
            ----------------------------------------------------------------------
            when USER_S =>
               -- Check if moving data
               if (obMacPrimMaster.tValid = '1') and (v.ethUdpObMaster.tValid = '0') then

                  -- Check if moving cached data
                  if (r.cnt < r.cacheCnt) then

                     -- Increment the counter
                     v.cnt := r.cnt + 1;

                     -- Move the cached data
                     v.ethUdpObMaster := r.cache(r.cnt);

                  else

                     -- Accept the streaming data
                     v.obMacPrimSlave.tReady := '1';

                     -- Move the streaming data
                     v.ethUdpObMaster := obMacPrimMaster;

                  end if;

                  -- Check for EOF
                  if (v.ethUdpObMaster.tLast = '1') then
                     -- Next state
                     v.state := IDLE_S;
                  end if;

               end if;
         ----------------------------------------------------------------------
         end case;

         -- Check if need to reset counter
         if (v.state = IDLE_S) and ((r.state = PRIM_S) or (r.state = USER_S)) then
            -- Reset the counter
            v.cacheCnt := 0;
            v.cnt      := 0;
         end if;

         -- Reset
         if (ethRst = '1') then
            v := REG_INIT_C;
         end if;

         -- Register the variable for next clock cycle
         rin <= v;

         -- Outputs       
         obMacPrimSlave <= v.obMacPrimSlave;
         txMaster       <= r.txMaster;
         ethUdpObMaster <= r.ethUdpObMaster;

      end process comb;

      seq : process (ethClk) is
      begin
         if rising_edge(ethClk) then
            r <= rin after TPD_G;
         end if;
      end process seq;

   end generate;

end architecture rtl;
