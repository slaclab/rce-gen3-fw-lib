-------------------------------------------------------------------------------
-- File       : MigCorePkg.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2017-03-06
-- Last update: 2018-06-14
-------------------------------------------------------------------------------
-- Description: Package file for MIG Core
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

package MigCorePkg is

   -- DDR Clock Frequency
   constant DDR_CLK_FREQ_C : real := 125.0E+6;  -- units of Hz

   -- DDR MEM AXI Configuration
   constant DDR_AXI_CONFIG_C : AxiConfigType := (
      ADDR_WIDTH_C => 33,               -- 8GB interface
      DATA_BYTES_C => 64,               -- 512-bit data interface
      ID_BITS_C    => 4,                -- Up to 16 IDS
      LEN_BITS_C   => 8);               -- 8-bit awlen/arlen interface  
      
   constant DDR_START_ADDR_C : slv(DDR_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0) := (others => '0');
   constant DDR_STOP_ADDR_C  : slv(DDR_AXI_CONFIG_C.ADDR_WIDTH_C-1 downto 0) := (others => '1');         
      
   -- DDR Port Types
   type DdrOutType is record
      addr : slv(16 downto 0);
      ba   : slv(1 downto 0);
      cke  : slv(0 downto 0);
      csL  : slv(0 downto 0);
      odt  : slv(0 downto 0);
      bg   : slv(1 downto 0);
      rstL : sl;
      actL : sl;
      ckC  : slv(0 downto 0);
      ckT  : slv(0 downto 0);
   end record DdrOutType;
   constant DDR_OUT_INIT_C : DdrOutType := (
      addr => (others => '1'),
      ba   => (others => '1'),
      cke  => (others => '1'),
      csL  => (others => '1'),
      odt  => (others => '1'),
      bg   => (others => '1'),
      rstL => '1',
      actL => '1',
      ckC  => (others => '1'),
      ckT  => (others => '1'));

   type DdrInOutType is record
      dm   : slv(7 downto 0);
      dq   : slv(63 downto 0);
      dqsC : slv(7 downto 0);
      dqsT : slv(7 downto 0);
   end record DdrInOutType;

end package MigCorePkg;
