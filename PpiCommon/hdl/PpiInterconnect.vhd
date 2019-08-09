-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI Crossbar
-- File          : PpiInterconnect.vhd
-------------------------------------------------------------------------------
-- Description:
-- PPI Interconnect
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE PPI Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE PPI Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity PpiInterconnect is
   generic (
      TPD_G               : time                  := 1 ns;
      NUM_PPI_SLOTS_G     : natural range 1 to 15 := 1;
      NUM_STATUS_WORDS_G  : natural range 1 to 30 := 1;
      STATUS_SEND_WIDTH_G : natural               := 1
   );
   port (

      -- PPI Clock
      ppiClk           : in  sl;
      ppiClkRst        : in  sl;
      ppiState         : in  RceDmaStateType;

      -- Inbound/Outbound Upstream
      ppiIbMaster      : out AxiStreamMasterType;
      ppiIbSlave       : in  AxiStreamSlaveType;
      ppiObMaster      : in  AxiStreamMasterType;
      ppiObSlave       : out AxiStreamSlaveType;

      -- Inbound/Outbound Downstream 
      locIbMaster      : in  AxiStreamMasterArray(NUM_PPI_SLOTS_G-1 downto 0);
      locIbSlave       : out AxiStreamSlaveArray(NUM_PPI_SLOTS_G-1 downto 0);
      locObMaster      : out AxiStreamMasterArray(NUM_PPI_SLOTS_G-1 downto 0);
      locObSlave       : in  AxiStreamSlaveArray(NUM_PPI_SLOTS_G-1 downto 0);

      -- Status Bus
      statusClk        : in  sl;
      statusClkRst     : in  sl;
      statusWords      : in  Slv64Array(NUM_STATUS_WORDS_G-1 downto 0);
      statusSend       : in  slv(STATUS_SEND_WIDTH_G-1 downto 0);
      offlineAck       : in  sl
   );
end PpiInterconnect;

architecture structure of PpiInterconnect is

   constant NUM_INT_SLOTS_C : natural := 16;

   signal intIbMaster : AxiStreamMasterArray(NUM_INT_SLOTS_C-1 downto 0);
   signal intIbSlave  : AxiStreamSlaveArray(NUM_INT_SLOTS_C-1 downto 0);
   signal intObMaster : AxiStreamMasterArray(NUM_INT_SLOTS_C-1 downto 0);
   signal intObSlave  : AxiStreamSlaveArray(NUM_INT_SLOTS_C-1 downto 0);

begin

   -- Inputs
   intIbMaster(NUM_PPI_SLOTS_G-1 downto 0) <= locIbMaster;
   intObSlave(NUM_PPI_SLOTS_G-1 downto 0)  <= locObSlave;

   -- Outputs
   locIbSlave  <= intIbSlave(NUM_PPI_SLOTS_G-1 downto 0);
   locObMaster <= intObMaster(NUM_PPI_SLOTS_G-1 downto 0);

   -- Unused slots
   U_UnusedPpiGen : if NUM_PPI_SLOTS_G /= 15 generate
      intIbMaster(14 downto NUM_PPI_SLOTS_G) <= (others=>AXI_STREAM_MASTER_INIT_C);
      intObSlave(14 downto NUM_PPI_SLOTS_G)  <= (others=>AXI_STREAM_SLAVE_FORCE_C);
   end generate;

   -- Outbound DeMux
   U_ObDeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => NUM_INT_SLOTS_C
      ) port map (
         axisClk           => ppiClk,
         axisRst           => ppiClkRst,
         sAxisMaster       => ppiObMaster,
         sAxisSlave        => ppiObSlave,
         mAxisMasters      => intObMaster,
         mAxisSlaves       => intObSlave
      );

   -- Inbound Mux
   U_IbMux : entity work.AxiStreamMux
      generic map (
         TPD_G        => TPD_G,
         NUM_SLAVES_G => NUM_INT_SLOTS_C
      ) port map (
         axisClk           => ppiClk,
         axisRst           => ppiClkRst,
         sAxisMasters      => intIbMaster,
         sAxisSlaves       => intIbSlave,
         mAxisMaster       => ppiIbMaster,
         mAxisSlave        => ppiIbSlave

      );

   -- Status Bridge
   U_PpiStatus : entity work.PpiStatus
      generic map (
         TPD_G               => TPD_G,
         NUM_STATUS_WORDS_G  => NUM_STATUS_WORDS_G,
         STATUS_SEND_WIDTH_G => STATUS_SEND_WIDTH_G
      ) port map (
         ppiClk            => ppiClk,
         ppiClkRst         => ppiClkRst,
         ppiIbMaster       => intIbMaster(NUM_INT_SLOTS_C-1),
         ppiIbSlave        => intIbSlave(NUM_INT_SLOTS_C-1),
         ppiObMaster       => intObMaster(NUM_INT_SLOTS_C-1),
         ppiObSlave        => intObSlave(NUM_INT_SLOTS_C-1),
         statusClk         => statusClk,
         statusClkRst      => statusClkRst,
         statusWords       => statusWords,
         statusSend        => statusSend,
         offlineAck        => offlineAck
      );

end architecture structure;

