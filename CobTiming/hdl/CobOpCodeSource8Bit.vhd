-------------------------------------------------------------------------------
-- Title         : Trigger Source Module For COB
-- File          : CobOpCodeSource8Bit.vhd
-------------------------------------------------------------------------------
-- Description:
-- OpCode source module for COB
-- Delivers encoded 8-bit opcode on DPM clk2 line. Opcode is synchronous to the
-- rising edge of clk. 
--
-- OpCode Pattern:
-- Bit   : 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
-- Value :  0  0  0  0  1  1  1  1 B0 I0 B1 I1 B2 I2 B3 I3 B4 I4 B5 I5 B6 I6 B7 I7
--
-- Idle / Training Pattern:
-- Bit   : 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
-- Value :  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1  0  1
--
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Timing Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Timing Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use work.StdRtlPkg.all;

entity CobOpCodeSource8Bit is
   generic (
      TPD_G : time := 1 ns
   );
   port (

      -- Clock and reset
      distClk                  : in  sl;
      distClkRst               : in  sl;
      
      -- Opcode information
      timingCode               : in  slv(7 downto 0);
      timingCodeEn             : in  sl;
      timingCodeReady          : out sl;

      -- Timing bus
      serialCode               : out sl
   );
end CobOpCodeSource8Bit;

architecture STRUCTURE of CobOpCodeSource8Bit is

   -- Local Signals
   signal txCount  : slv(4 downto 0);
   signal txEnable : sl;
   signal outBit   : sl;
   signal codeEn   : sl;
   signal codeVal  : slv(31 downto 0);

begin

   timingCodeReady <= not txEnable;

   ----------------------------------------
   -- Sync Data Generator
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            txCount <= (others=>'0') after TPD_G;
            txEnable <= '0'           after TPD_G;
            outBit   <= '0'           after TPD_G;
            codeEn   <= '0'           after TPD_G;
            codeVal  <= (others=>'0') after TPD_G;
         else

            -- Sample incoming data when idle
            if txEnable = '0' and timingCodeEn = '1' then
               codeVal(7 downto 0) <= "11110000" after TPD_G;

               for i in 0 to 7 loop
                  codeVal(i*2+8) <=     timingCode(i) after TPD_G;
                  codeVal(i*2+9) <= not timingCode(i) after TPD_G;
               end loop;
            end if;

            -- Pass enable when idle
            codeEn <= timingCodeEn and (not txEnable) after TPD_G;

            -- Setup counter
            if codeEn = '1' then
               txCount <= "00001" after TPD_G;
            else
               txCount <= txCount + 1 after TPD_G;
            end if;

            -- Start new transmission, bit = '0'
            if codeEn = '1' then
               outBit   <= '0'   after TPD_G;
               txEnable <= '1'   after TPD_G;

            -- In transmission
            elsif txEnable = '1' then
               outBit <= codeVal(conv_integer(txCount)) after TPD_G;

               -- Done at 23
               if txCount = 23 then
                  txEnable <= '0' after TPD_G;
               end if;

            -- Idle 
            else 
               outBit <= txCount(0) after TPD_G;
            end if;

         end if;
      end if;
   end process;

   ----------------------------------------
   -- Output Register
   ----------------------------------------
   process ( distClk ) begin
      if rising_edge(distClk) then
         if distClkRst = '1' then
            serialCode <= '0'    after TPD_G;
         else
            serialCode <= outBit after TPD_G;
         end if;
      end if;
   end process;

end architecture STRUCTURE;

