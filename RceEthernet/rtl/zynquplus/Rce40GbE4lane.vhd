-------------------------------------------------------------------------------
-- File       : Rce40GbE4lane.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2018-08-21
-- Last update: 2018-08-29
-------------------------------------------------------------------------------
-- Description: 40GBASE-KR4 Wrapper
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

entity Rce40GbE4lane is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Misc. Signals
      phyClk    : out sl                := '0';
      phyRst    : out sl                := '0';
      phyReady  : out sl                := '0';
      phyStatus : out slv(7 downto 0)   := (others => '0');
      phyDebug  : out slv(5 downto 0)   := (others => '0');
      phyConfig : in  slv(6 downto 0);
      stableClk : in  sl;               -- free-running clock reference
      stableRst : in  sl;
      -- PHY Interface
      xlgmiiRxd : out slv(127 downto 0) := (others => '0');
      xlgmiiRxc : out slv(15 downto 0)  := (others => '0');
      xlgmiiTxd : in  slv(127 downto 0);
      xlgmiiTxc : in  slv(15 downto 0);
      -- MGT Ports
      gtRefClk  : in  sl;
      gtTxP     : out slv(3 downto 0)   := (others => '0');
      gtTxN     : out slv(3 downto 0)   := (others => '0');
      gtRxP     : in  slv(3 downto 0);
      gtRxN     : in  slv(3 downto 0));
end Rce40GbE4lane;

architecture mapping of Rce40GbE4lane is

begin

   assert (false) report "ETH_TYPE_G = 40GBASE-KR4 not supported yet" severity failure;

end mapping;
