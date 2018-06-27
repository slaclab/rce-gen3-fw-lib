-------------------------------------------------------------------------------
-- Title         : Clock generation block
-- File          : RceG3Clocks.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 04/02/2013
-------------------------------------------------------------------------------
-- Description:
-- Clock generation block for generation 3 RCE core.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 04/02/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_arith.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;

entity RceG3Clocks is
   generic (
      TPD_G           : time    := 1 ns;
      DMA_CLKDIV_EN_G : boolean := false;  --- Legacy, not used
      DMA_CLKDIV_G    : real    := 5.0);
   port (
      -- Core clock and reset inputs
      fclkClk3     : in  sl;
      fclkClk2     : in  sl;
      fclkClk1     : in  sl;
      fclkClk0     : in  sl;               -- 100Mhz
      fclkRst3     : in  sl;
      fclkRst2     : in  sl;
      fclkRst1     : in  sl;
      fclkRst0     : in  sl;
      -- DMA clock and reset
      axiDmaClk    : out sl;
      axiDmaRst    : out sl;
      -- Other system clocks
      sysClk125    : out sl;
      sysClk125Rst : out sl;
      sysClk200    : out sl;
      sysClk200Rst : out sl);
end RceG3Clocks;

architecture structure of RceG3Clocks is

   signal pwrUpRst : sl;

begin

   -----------------
   -- Power Up Reset
   -----------------
   PwrUpRst_Inst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => fclkRst0,
         clk    => fclkClk0,
         rstOut => pwrUpRst);

   ----------------
   -- Clock Manager
   ----------------
   U_MMCM : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 3,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 10.0,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 10.0,
         CLKOUT0_DIVIDE_F_G => DMA_CLKDIV_G,
         CLKOUT1_DIVIDE_G   => 5,
         CLKOUT2_DIVIDE_G   => 8)
      port map(
         clkIn     => fclkClk0,
         rstIn     => pwrUpRst,
         -- Clock Outputs
         clkOut(0) => axiDmaClk,
         clkOut(1) => sysClk200,
         clkOut(2) => sysClk125,
         -- Reset Outputs
         rstOut(0) => axiDmaRst,
         rstOut(1) => sysClk200Rst,
         rstOut(2) => sysClk125Rst);

end architecture structure;
