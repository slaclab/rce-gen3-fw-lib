-------------------------------------------------------------------------------
-- File       : RceEthGtMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Terminate Unused GTs
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

entity RceEthGtMapping is
   generic (
      TPD_G      : time   := 1 ns;
      ETH_TYPE_G : string := "1000BASE-KX");
   port (
      stableClk : in  sl;
      ethRxP    : in  slv(3 downto 0);
      ethRxN    : in  slv(3 downto 0);
      ethTxP    : out slv(3 downto 0);
      ethTxN    : out slv(3 downto 0);
      gtRxP     : out slv(3 downto 0);
      gtRxN     : out slv(3 downto 0);
      gtTxP     : in  slv(3 downto 0);
      gtTxN     : in  slv(3 downto 0));
end RceEthGtMapping;

architecture mapping of RceEthGtMapping is

   constant GT_TERM_C : boolean := ite((ETH_TYPE_G = "10GBASE-KX4") or (ETH_TYPE_G = "40GBASE-KR4"), false, true);

begin

   ethTxP(0) <= gtTxP(0);
   ethTxN(0) <= gtTxN(0);
   gtRxP(0)  <= ethRxP(0);
   gtRxN(0)  <= ethRxN(0);

   GEN_PASS : if (GT_TERM_C = false) generate
      GEN_VEC : for i in 3 downto 1 generate
         ethTxP(i) <= gtTxP(i);
         ethTxN(i) <= gtTxN(i);
         gtRxP(i)  <= ethRxP(i);
         gtRxN(i)  <= ethRxN(i);
      end generate GEN_VEC;
   end generate;

   GEN_TERM : if (GT_TERM_C = true) generate

      gtRxP(3 downto 1) <= (others => '0');
      gtRxN(3 downto 1) <= (others => '1');

      U_Gtxe2ChannelDummy : entity surf.Gtxe2ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 3)
         port map (
            refClk => stableClk,
            gtRxP  => ethRxP(3 downto 1),
            gtRxN  => ethRxN(3 downto 1),
            gtTxP  => ethTxP(3 downto 1),
            gtTxN  => ethTxN(3 downto 1));

   end generate;

end mapping;
