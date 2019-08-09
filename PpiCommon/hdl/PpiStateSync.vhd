-------------------------------------------------------------------------------
-- Title         : General Purpopse PPI State Sync
-- File          : PpiStateSync.vhd
-------------------------------------------------------------------------------
-- Description:
-- PPI block to sync DMA state across clock domains
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

entity PpiStateSync is
   generic (
      TPD_G  : time := 1 ns
   );
   port (

      -- PPI Interface
      ppiState  : in  RceDmaStateType;

      -- Local Interface
      locClk    : in  sl;
      locClkRst : in  sl;
      locState  : out RceDmaStateType
   );
end PpiStateSync;

architecture structure of PpiStateSync is

begin

   U_Sync: entity work.SynchronizerVector
      generic map (
         TPD_G          => TPD_G,
         RST_POLARITY_G => '1',
         OUT_POLARITY_G => '1',
         RST_ASYNC_G    => false,
         STAGES_G       => 2,
         WIDTH_G        => 2,
         INIT_G         => "0"
      ) port map (
         clk        => locClk,
         rst        => locClkRst,
         dataIn(0)  => ppiState.online,
         dataIn(1)  => ppiState.user,
         dataOut(0) => locState.online,
         dataOut(1) => locState.user
      );

end architecture structure;

