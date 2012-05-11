


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity Ppc440RceG2Boot is
   port (

      -- Clock inputs
      bramClk                   : in  std_logic;
      bramClkRst                : in  std_logic;

      -- MPLB Bus
      plbPpcmMBusy              : out std_logic;
      plbPpcmAddrAck            : out std_logic;
      plbPpcmRdDack             : out std_logic;
      plbPpcmRdDbus             : out std_logic_vector(0 to 127);
      plbPpcmRdWdAddr           : out std_logic_vector(0 to 3);
      plbPpcmTimeout            : out std_logic;
      plbPpcmWrDack             : out std_logic;
      ppcMplbAbus               : in  std_logic_vector(0 to 31);
      ppcMplbBe                 : in  std_logic_vector(0 to 15);
      ppcMplbRequest            : in  std_logic;
      ppcMplbRnW                : in  std_logic;
      ppcMplbSize               : in  std_logic_vector(0 to 3);
      ppcMplbWrDBus             : in  std_logic_vector(0 to 127)
   );
end Ppc440RceG2Boot;

architecture behavioral of Ppc440RceG2Boot is

   -- Boot Ram
   component Ppc440RceG2Bram 
      port (
         bramRstA  : in  std_logic;
         bramClkA  : in  std_logic;
         bramEnA   : in  std_logic;
         bramWenA  : in  std_logic_vector(0 to 7);
         bramAddrA : in  std_logic_vector(0 to 31);
         bramDinA  : out std_logic_vector(0 to 63);
         bramDoutA : in  std_logic_vector(0 to 63);
         bramRstB  : in  std_logic;
         bramClkB  : in  std_logic;
         bramEnB   : in  std_logic;
         bramWenB  : in  std_logic_vector(0 to 7);
         bramAddrB : in  std_logic_vector(0 to 31);
         bramDinB  : out std_logic_vector(0 to 63);
         bramDoutB : in  std_logic_vector(0 to 63)
      );
   end component;

   -- Signals
   signal bramWenA         : std_logic_vector(0 to 7);
   signal nextWenA         : std_logic_vector(0 to 7);
   signal bramAddrA        : std_logic_vector(0 to 31);
   signal nextAddrA        : std_logic_vector(0 to 31);
   signal bramDinA         : std_logic_vector(0 to 63);
   signal nextDinA         : std_logic_vector(0 to 63);
   signal bramDoutA        : std_logic_vector(0 to 63);
   signal nextPpcmMBusy    : std_logic;
   signal nextPpcmAddrAck  : std_logic;
   signal nextPpcmRdDack   : std_logic;
   signal nextPpcmRdDbus   : std_logic_vector(0 to 127);
   signal nextPpcmRdWdAddr : std_logic_vector(0 to 3);
   signal nextPpcmTimeout  : std_logic;
   signal nextPpcmWrDack   : std_logic;
   signal stateCount       : std_logic_vector(3 downto 0);

   -- States
   constant ST_IDLE      : std_logic_vector(3 downto 0) := "0000";
   constant ST_ADDR      : std_logic_vector(3 downto 0) := "0001";
   constant ST_WR_CLN4   : std_logic_vector(3 downto 0) := "0010";
   constant ST_WR_CLN8   : std_logic_vector(3 downto 0) := "0011";
   constant ST_RD_CLN4   : std_logic_vector(3 downto 0) := "0100";
   constant ST_RD_CLN8   : std_logic_vector(3 downto 0) := "0101";
   constant ST_WR_SNGL   : std_logic_vector(3 downto 0) := "0110";
   constant ST_RD_SNGL   : std_logic_vector(3 downto 0) := "0111";
   constant ST_TIMEOUT   : std_logic_vector(3 downto 0) := "1000";
   signal   curState     : std_logic_vector(3 downto 0);
   signal   nxtState     : std_logic_vector(3 downto 0);

   -- Register delay for simulation
   constant tpd:time := 0.5 ns;

begin


   -- Sync state logic
   process (bramClk, bramClkRst ) begin
      if bramClkRst = '1' then
         plbPpcmMBusy     <= '0'              after tpd;
         plbPpcmAddrAck   <= '0'              after tpd;
         plbPpcmRdDack    <= '0'              after tpd;
         plbPpcmRdDbus    <= (others=>'0')    after tpd;
         plbPpcmRdWdAddr  <= (others=>'0')    after tpd;
         plbPpcmTimeout   <= '0'              after tpd;
         plbPpcmWrDack    <= '0'              after tpd;
         bramWenA         <= (others=>'0')    after tpd;
         bramAddrA        <= (others=>'0')    after tpd;
         bramDinA         <= (others=>'0')    after tpd;
         stateCount       <= (others=>'0')    after tpd;
         curState         <= ST_IDLE          after tpd;
      elsif rising_edge(bramClk) then

         -- MPLB outputs
         plbPpcmMBusy     <= nextPpcmMBusy    after tpd;
         plbPpcmAddrAck   <= nextPpcmAddrAck  after tpd;
         plbPpcmRdDack    <= nextPpcmRdDack   after tpd;
         plbPpcmRdDbus    <= nextPpcmRdDbus   after tpd;
         plbPpcmRdWdAddr  <= nextPpcmRdWdAddr after tpd;
         plbPpcmTimeout   <= nextPpcmTimeout  after tpd;
         plbPpcmWrDack    <= nextPpcmWrDack   after tpd;

         -- Block ram
         bramWenA         <= nextWenA         after tpd;
         bramAddrA        <= nextAddrA        after tpd;
         bramDinA         <= nextDinA         after tpd;

         -- State counter
         if nxtState /= curState then
            stateCount <= (others=>'0') after tpd;
         else
            stateCount <= stateCount    after tpd;
         end if;

         -- State transition
         curState         <= nxtState after tpd;

      end if;
   end process;

   -- ASync state logic
   process (curState, ppcMplbAbus, ppcMplbBe, ppcMplbRequest, bramDoutA,
            ppcMplbRnW, ppcMplbSize, ppcMplbWrDBus, stateCount ) begin

      case curState is 

         -- Idle. Wait for data
         when ST_IDLE =>
            nextPpcmMBusy    <= '0';
            nextPpcmRdDack   <= '0';
            nextPpcmRdDbus   <= (others=>'0');
            nextPpcmRdWdAddr <= (others=>'0');
            nextPpcmTimeout  <= '0';
            nextPpcmWrDack   <= '0';
            nextWenA         <= (others=>'0');
            nextAddrA        <= (others=>'0');
            nextDinA         <= (others=>'0');

            -- Bus request
            if ppcMplbRequest = '1' then

               -- Address matches
               if ppcMplbAbus(0 to 15) = x"FFFF" then
                  nextPpcmAddrAck <= '1';
                  nxtState        <= ST_ADDR;
               else
                  nextPpcmAddrAck <= '0';
                  nxtState        <= ST_TIMEOUT;
               end if;
            else
               nextPpcmAddrAck <= '0';
               nxtState        <= curState;
            end if;

         -- Address ack
         when ST_ADDR =>
            nextPpcmAddrAck  <= '0';
            nextPpcmMBusy    <= '1';
            nextPpcmRdDack   <= '0';
            nextPpcmRdDbus   <= (others=>'0');
            nextPpcmRdWdAddr <= (others=>'0');
            nextPpcmTimeout  <= '0';

            -- Four word cache line
            if ppcMplbSize = "0001" then
               nextAddrA <= ppcMplbAbus(0 to 27) & "0000";
               nextDinA  <= ppcMplbWrDBus(0 to 63);

               -- Write
               if ppcMplbRnW = '0' then
                  nextPpcmWrDack <= '1';
                  nextWenA       <= x"FF";
                  nxtState       <= ST_WR_CLN4;

               -- Read
               else
                  nextPpcmWrDack <= '0';
                  nextWenA       <= x"00";
                  nxtState       <= ST_RD_CLN4;
               end if;

            -- Eight word cache line
            elsif ppcMplbSize = "0010" then
               nextAddrA <= ppcMplbAbus(0 to 26) & "00000";
               nextDinA  <= ppcMplbWrDBus(0 to 63);

               -- Write
               if ppcMplbRnW = '0' then
                  nextPpcmWrDack <= '1';
                  nextWenA       <= x"FF";
                  nxtState       <= ST_WR_CLN8;

               -- Read
               else
                  nextPpcmWrDack <= '0';
                  nextWenA       <= x"00";
                  nxtState       <= ST_RD_CLN8;
               end if;

            -- Single transfer
            else
               nextAddrA <= ppcMplbAbus(0 to 29) & "00";
               nextDinA  <= ppcMplbWrDBus(0 to 63);

               -- Write
               if ppcMplbRnW = '0' then
                  if ppcMplbAbus(28) = '0' then
                     nextWenA <= ppcMplbBe(0 to 7);
                  else
                     nextWenA <= ppcMplbBe(8 to 15);
                  end if;
                  nextPpcmWrDack <= '1';
                  nxtState       <= ST_IDLE;

               -- Read
               else
                  nextWenA       <= (others=>'0');
                  nextPpcmWrDack <= '0';
                  nxtState       <= ST_IDLE;
               end if;

            end if;

         -- Cache line (4 word) 
         when ST_WR_CLN4 =>
            nextPpcmAddrAck  <= '0';
            nextPpcmRdDack   <= '0';
            nextPpcmRdDbus   <= (others=>'0');
            nextPpcmRdWdAddr <= nextPpcmRdWdAddr + 1;
            nextPpcmTimeout  <= '0';
            nextAddrA        <= nextAddrA + 8;
            nextDinA         <= ppcMplbWrDBus(0 to 63);
            nextWenA         <= x"FF";

            if stateCount > 1 then
               nextPpcmWrDack <= '0';
            else
               nextPpcmWrDack <= '1';
            end if;

            if stateCount = 3 then
               nxtState      <= ST_IDLE;
               nextPpcmMBusy <= '0';
            else
               nxtState      <= curState;
               nextPpcmMBusy <= '1';
            end if;

         -- Cache line (8 word) 
         when ST_WR_CLN8 =>
            nextPpcmAddrAck  <= '0';
            nextPpcmRdDack   <= '0';
            nextPpcmRdDbus   <= (others=>'0');
            nextPpcmRdWdAddr <= nextPpcmRdWdAddr + 1;
            nextPpcmTimeout  <= '0';
            nextAddrA        <= nextAddrA + 8;
            nextDinA         <= ppcMplbWrDBus(0 to 63);
            nextWenA         <= x"FF";

            if stateCount > 5 then
               nextPpcmWrDack <= '0';
            else
               nextPpcmWrDack <= '1';
            end if;

            if stateCount = 7 then
               nxtState      <= ST_IDLE;
               nextPpcmMBusy <= '0';
            else
               nxtState      <= curState;
               nextPpcmMBusy <= '1';
            end if;

         -- Cache line (4 word) 
         when ST_RD_CLN4 =>
            nextPpcmAddrAck  <= '0';
            nextPpcmRdDbus   <= bramDoutA & x"0000000000000000";
            nextPpcmMBusy    <= '1';
            nextPpcmWrDack   <= '0';
            nextPpcmTimeout  <= '0';
            nextAddrA        <= nextAddrA + 8;
            nextDinA         <= ppcMplbWrDBus(0 to 63);
            nextWenA         <= x"00";

            if stateCount > 0 then
               nextPpcmRdDack   <= '1';
               nextPpcmRdWdAddr <= nextPpcmRdWdAddr + 1;
            else
               nextPpcmRdDack   <= '0';
               nextPpcmRdWdAddr <= (others=>'0');
            end if;

            if stateCount = 3 then
               nxtState <= ST_IDLE;
            else
               nxtState <= curState;
            end if;

         -- Cache line (8 word) 
         when ST_RD_CLN8 =>
            nextPpcmAddrAck  <= '0';
            nextPpcmRdDbus   <= bramDoutA & x"0000000000000000";
            nextPpcmMBusy    <= '1';
            nextPpcmWrDack   <= '0';
            nextPpcmTimeout  <= '0';
            nextAddrA        <= nextAddrA + 8;
            nextDinA         <= ppcMplbWrDBus(0 to 63);
            nextWenA         <= x"00";

            if stateCount > 0 then
               nextPpcmRdDack   <= '1';
               nextPpcmRdWdAddr <= nextPpcmRdWdAddr + 1;
            else
               nextPpcmRdDack   <= '0';
               nextPpcmRdWdAddr <= (others=>'0');
            end if;

            if stateCount = 7 then
               nxtState <= ST_IDLE;
            else
               nxtState <= curState;
            end if;

         -- Single read
         when ST_RD_SNGL =>
            nextPpcmAddrAck  <= '0';
            nextPpcmRdDbus   <= bramDoutA & x"0000000000000000";
            nextPpcmMBusy    <= '1';
            nextPpcmWrDack   <= '0';
            nextPpcmTimeout  <= '0';
            nextAddrA        <= bramAddrA;
            nextDinA         <= bramDinA;
            nextWenA         <= x"00";
            nextPpcmRdDack   <= '1';
            nextPpcmRdWdAddr <= (others=>'0');
            nxtState         <= ST_IDLE;

         -- Single Write
         when ST_WR_SNGL =>
            nextPpcmAddrAck  <= '0';
            nextPpcmRdDbus   <= bramDoutA & x"0000000000000000";
            nextPpcmMBusy    <= '1';
            nextPpcmWrDack   <= '0';
            nextPpcmTimeout  <= '0';
            nextAddrA        <= bramAddrA;
            nextDinA         <= bramDinA;
            nextWenA         <= x"00";
            nextPpcmRdDack   <= '0';
            nextPpcmRdWdAddr <= (others=>'0');
            nxtState         <= ST_IDLE;

         -- Timeout
         when ST_TIMEOUT =>
            nextPpcmMBusy    <= '0';
            nextPpcmRdDack   <= '0';
            nextPpcmRdDbus   <= (others=>'0');
            nextPpcmRdWdAddr <= (others=>'0');
            nextPpcmWrDack   <= '0';
            nextWenA         <= (others=>'0');
            nextAddrA        <= (others=>'0');
            nextDinA         <= (others=>'0');
            nextPpcmAddrAck  <= '1';

            if stateCount = 15 then
               nxtState         <= ST_IDLE;
               nextPpcmTimeout  <= '1';
            else
               nxtState         <= curState;
               nextPpcmTimeout  <= '0';
            end if;

         when others =>
            nextPpcmMBusy    <= '0';
            nextPpcmRdDack   <= '0';
            nextPpcmRdDbus   <= (others=>'0');
            nextPpcmRdWdAddr <= (others=>'0');
            nextPpcmTimeout  <= '0';
            nextPpcmWrDack   <= '0';
            nextWenA         <= (others=>'0');
            nextAddrA        <= (others=>'0');
            nextDinA         <= (others=>'0');
            nextPpcmAddrAck  <= '1';
            nxtState         <= ST_IDLE;

      end case;
   end process;

   -- Boot RAM
   U_Ppc440RceG2Bram : Ppc440RceG2Bram 
      port map (
         bramRstA  => bramClkRst,
         bramClkA  => bramClk,
         bramEnA   => '1',
         bramWenA  => bramWenA,
         bramAddrA => bramAddrA,
         bramDinA  => bramDinA,
         bramDoutA => bramDoutA,
         bramRstB  => '0',
         bramClkB  => '0',
         bramEnB   => '0',
         bramWenB  => (others=>'0'),
         bramAddrB => (others=>'0'),
         bramDinB  => open,
         bramDoutB => (others=>'0')
      );

end architecture behavioral;
