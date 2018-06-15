-------------------------------------------------------------------------------
-- File       : MigCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-08-10
-- Last update: 2017-08-10
-------------------------------------------------------------------------------
-- Description: Wrapper for the MIG core
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
use work.MigCorePkg.all;

entity MigCore is
   generic (
      TPD_G : time := 1 ns);
   port (
      extRst         : in    sl;
      -- PL DDR MEM Interface
      ddrClk         : out   sl;
      ddrRst         : out   sl;
      ddrWriteMaster : in    AxiWriteMasterType;
      ddrWriteSlave  : out   AxiWriteSlaveType;
      ddrReadMaster  : in    AxiReadMasterType;
      ddrReadSlave   : out   AxiReadSlaveType;
      -- PL DDR MEM Ports
      ddrClkP        : in    sl;
      ddrClkN        : in    sl;
      ddrOut         : out   DdrOutType;
      ddrInOut       : inout DdrInOutType);
end MigCore;

architecture mapping of MigCore is

begin

   ddrClk         <= '0';
   ddrRst         <= '1';
   axiWriteSlaves <= (others => AXI_WRITE_SLAVE_FORCE_C);
   axiReadSlaves  <= (others => AXI_READ_SLAVE_FORCE_C);
   ddrOut         <= DDR_OUT_INIT_C;

end mapping;
