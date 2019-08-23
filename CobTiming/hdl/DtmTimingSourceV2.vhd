-------------------------------------------------------------------------------
-- Title         : Clock/Trigger Source Module For DTM, Version 2
-- File          : DtmTimingSourceV2.vhd
-------------------------------------------------------------------------------
-- Description:
-- Clock & Trigger source module for DTM
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Timing Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Timing Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

entity DtmTimingSourceV2 is
   generic (
      TPD_G           : time   := 1 ns;
      IODELAY_GROUP_G : string := "DtmTimingGrp"
      );
   port (

      -- Local Bus
      axiClk         : in  sl;
      axiClkRst      : in  sl;
      axiReadMaster  : in  AxiLiteReadMasterType;
      axiReadSlave   : out AxiLiteReadSlaveType;
      axiWriteMaster : in  AxiLiteWriteMasterType;
      axiWriteSlave  : out AxiLiteWriteSlaveType;

      -- Reference Clock
      sysClk200    : in sl;
      sysClk200Rst : in sl;

      -- Distributed Clock and reset
      distClk    : in sl;
      distClkRst : in sl;

      -- Transmit Data, synchronous to distClk
      txData   : in  Slv10Array(1 downto 0);
      txDataEn : in  slv(1 downto 0);
      txReady  : out slv(1 downto 0);

      -- Receive data, synchronous to distClk
      rxData   : out Slv10Array(7 downto 0);
      rxDataEn : out slv(7 downto 0);

      -- COB Timing bus
      dpmClkP : out slv(2 downto 0);
      dpmClkM : out slv(2 downto 0);
      dpmFbP  : in  slv(7 downto 0);
      dpmFbM  : in  slv(7 downto 0)
      );
end DtmTimingSourceV2;

architecture STRUCTURE of DtmTimingSourceV2 is

   -- Local Signals
   signal dpmClk           : slv(2 downto 0);
   signal intTxData        : Slv10Array(1 downto 0);
   signal intTxDataEn      : slv(1 downto 0);
   signal intTxReady       : slv(1 downto 0);
   signal txCount          : Slv32Array(1 downto 0);
   signal txCountSync      : Slv32Array(1 downto 0);
   signal intRxData        : Slv10Array(7 downto 0);
   signal intRxDataEn      : slv(7 downto 0);
   signal rxCount          : Slv32Array(7 downto 0);
   signal rxCountSync      : Slv32Array(7 downto 0);
   signal fbStatusIdleCnt  : Slv16Array(7 downto 0);
   signal fbStatusErrorCnt : Slv16Array(7 downto 0);
   signal regCode          : Slv10Array(1 downto 0);
   signal regCodeEn        : slv(1 downto 0);
   signal dpmFb            : slv(7 downto 0);
   signal countReset       : sl;

   type RegType is record
      countReset    : sl;
      fbCfgSet      : slv(7 downto 0);
      fbCfgDelay    : Slv5Array(7 downto 0);
      cmdCode       : Slv10Array(1 downto 0);
      cmdCodeEn     : slv(1 downto 0);
      axiReadSlave  : AxiLiteReadSlaveType;
      axiWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      countReset    => '0',
      fbCfgSet      => (others => '0'),
      fbCfgDelay    => (others => (others => '0')),
      cmdCode       => (others => (others => '0')),
      cmdCodeEn     => (others => '0'),
      axiReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axiWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
      );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   attribute IODELAY_GROUP                        : string;
   attribute IODELAY_GROUP of U_DtmTimingDlyCntrl : label is IODELAY_GROUP_G;

begin

   ----------------------------------------
   -- Delay Control
   ----------------------------------------
   U_DtmTimingDlyCntrl : IDELAYCTRL
      port map (
         RDY    => open,                -- 1-bit output: Ready output
         REFCLK => sysClk200,           -- 1-bit input: Reference clock input
         RST    => sysClk200Rst         -- 1-bit input: Active high reset input
         );

   ----------------------------------------
   -- Clock Output
   ----------------------------------------

   U_ClkGen : ODDR
      generic map(
         DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
         INIT         => '0',              -- Initial value for Q port ('1' or '0')
         SRTYPE       => "SYNC"            -- Reset Type ("ASYNC" or "SYNC")
         ) port map (
            Q  => dpmClk(0),               -- 1-bit DDR output
            C  => distClk,                 -- 1-bit clock input
            CE => '1',                     -- 1-bit clock enable input
            D1 => '1',                     -- 1-bit data input (positive edge)
            D2 => '0',                     -- 1-bit data input (negative edge)
            R  => distClkRst,              -- 1-bit reset input
            S  => '0'                      -- 1-bit set input
            );

   U_DpmClkOut : OBUFDS
      port map(
         O  => dpmClkP(0),
         OB => dpmClkM(0),
         I  => dpmClk(0)
         );


   ----------------------------------------
   -- OpCode Output
   ----------------------------------------
   U_OutGen : for i in 0 to 1 generate

      -- Select source
      process (txDataEn, txData, regCodeEn, regCode, intTxReady)
      begin
         if regCodeEn(i) = '1' then
            intTxDataEn(i) <= '1';
            intTxData(i)   <= regCode(i);
            txReady(i)     <= '0';
         else
            intTxDataEn(i) <= txDataEn(i);
            intTxData(i)   <= txData(i);
            txReady(i)     <= intTxReady(i);
         end if;
      end process;

      -- Module
      U_CobDataSource : entity work.CobDataSource10b
         generic map (
            TPD_G => TPD_G
            ) port map (
               distClk    => distClk,
               distClkRst => distClkRst,
               txData     => intTxData(i),
               txDataEn   => intTxDataEn(i),
               txReady    => intTxReady(i),
               serialData => dpmClk(i+1)
               );

      U_OpCodeClkBuf : OBUFDS
         port map(
            O  => dpmClkP(i+1),
            OB => dpmClkM(i+1),
            I  => dpmClk(i+1)
            );

      process (distClk)
      begin
         if rising_edge(distClk) then
            if distClkRst = '1' or countReset = '1' then
               txCount(i) <= (others => '0') after TPD_G;
            elsif intTxDataEn(i) = '1' and intTxReady(i) = '1' then
               txCount(i) <= txCount(i) + 1 after TPD_G;
            end if;
         end if;
      end process;

      -- Tx data count sync
      U_TxDataCntSync : entity work.SynchronizerFifo
         generic map (
            TPD_G         => 1 ns,
            COMMON_CLK_G  => false,
            BRAM_EN_G     => false,
            ALTERA_SYN_G  => false,
            ALTERA_RAM_G  => "M9K",
            SYNC_STAGES_G => 3,
            DATA_WIDTH_G  => 32,
            ADDR_WIDTH_G  => 4,
            INIT_G        => "0"
            ) port map (
               rst    => axiClkRst,
               wr_clk => distClk,
               wr_en  => '1',
               din    => txCount(i),
               rd_clk => axiClk,
               rd_en  => '1',
               valid  => open,
               dout   => txCountSync(i)
               );

   end generate;


   ----------------------------------------
   -- Feedback Inputs
   ----------------------------------------
   U_FbGen : for i in 0 to 7 generate

      -- IO Pin
      U_DpmFbBuf : IBUFDS
         port map(
            I  => dpmFbP(i),
            IB => dpmFbM(i),
            O  => dpmFb(i)
            );

      -- Input processor
      U_CobDataSink : entity work.CobDataSink10b
         generic map (
            TPD_G           => TPD_G,
            IODELAY_GROUP_G => IODELAY_GROUP_G
            ) port map (
               serialData     => dpmFb(i),
               distClk        => distClk,
               distClkRst     => distClkRst,
               rxData         => intRxData(i),
               rxDataEn       => intRxDataEn(i),
               configClk      => axiClk,
               configClkRst   => axiClkRst,
               configSet      => r.fbCfgSet(i),
               configDelay    => r.fbCfgDelay(i),
               statusIdleCnt  => fbStatusIdleCnt(i),
               statusErrorCnt => fbStatusErrorCnt(i)
               );

      process (distClk)
      begin
         if rising_edge(distClk) then
            if distClkRst = '1' or countReset = '1' then
               rxCount(i) <= (others => '0') after TPD_G;
            elsif intRxDataEn(i) = '1' then
               rxCount(i) <= rxCount(i) + 1 after TPD_G;
            end if;
         end if;
      end process;

      -- Rx data count sync
      U_RxDataCntSync : entity work.SynchronizerFifo
         generic map (
            TPD_G         => 1 ns,
            COMMON_CLK_G  => false,
            BRAM_EN_G     => false,
            ALTERA_SYN_G  => false,
            ALTERA_RAM_G  => "M9K",
            SYNC_STAGES_G => 3,
            DATA_WIDTH_G  => 32,
            ADDR_WIDTH_G  => 4,
            INIT_G        => "0"
            ) port map (
               rst    => axiClkRst,
               wr_clk => distClk,
               wr_en  => '1',
               din    => rxCount(i),
               rd_clk => axiClk,
               rd_en  => '1',
               valid  => open,
               dout   => rxCountSync(i)
               );

   end generate;

-- Outputs
   rxData   <= intRxData;
   rxDataEn <= intRxDataEn;


----------------------------------------
-- Local Registers
----------------------------------------

-- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

-- Async
   process (axiClkRst, axiReadMaster, axiWriteMaster, r, fbStatusErrorCnt, fbStatusIdleCnt, rxCountSync, txCountSync) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.fbCfgSet   := (others => '0');
      v.countReset := '0';
      v.cmdCodeEn  := "00";

      axiSlaveWaitTxn(axiWriteMaster, axiReadMaster, v.axiWriteSlave, v.axiReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- FB Fifo Write Enable, one per FIFO, 0x000 (legacy)

         -- FB Delay configuration, one per FIFO, 0x1xx
         if axiWriteMaster.awaddr(11 downto 8) = x"1" then
            v.fbCfgSet(conv_integer(axiWriteMaster.awaddr(4 downto 2)))   := '1';
            v.fbCfgDelay(conv_integer(axiWriteMaster.awaddr(4 downto 2))) := axiWriteMaster.wdata(4 downto 0);

            -- Feedback status, 0x2xx 

            -- FB FIFO read, one per FIFO, 0x300

         -- OC Opcode A Generation, 0x400
         elsif axiWriteMaster.awaddr(11 downto 0) = x"400" then
            v.cmdCodeEn(0) := '1';
            v.cmdCode(0)   := axiWriteMaster.wdata(9 downto 0);

            -- OC FIFO read, 0x404 (legacy)

            -- OC Fifo Enable, 0x408 (legacy)

            -- Debug counter, 0x40c (legacy)

         -- OC Opcode B Generation, 0x410
         elsif axiWriteMaster.awaddr(11 downto 0) = x"410" then
            v.cmdCodeEn(1) := '1';
            v.cmdCode(1)   := axiWriteMaster.wdata(9 downto 0);

            -- Tx Data A Count, 0x414

            -- Tx Data B Count, 0x418

         -- Counter Reset, 0x41C
         elsif axiWriteMaster.awaddr(11 downto 0) = x"41C" then
            v.countReset := axiWriteMaster.wdata(0);

            -- Rx Data Count, 0x5xx

         end if;

         -- Send Axi response
         axiSlaveWriteResponse(v.axiWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.axiReadSlave.rdata := (others => '0');

         -- FB Fifo Write Enable, one per FIFO, 0x000

         -- FB Delay configuration, one per FIFO, 0x1xx
         if axiReadMaster.araddr(11 downto 8) = x"1" then
            v.axiReadSlave.rdata(4 downto 0) := r.fbCfgDelay(conv_integer(axiReadMaster.araddr(4 downto 2)));

         -- Feedback status, 0x2xx 
         elsif axiReadMaster.araddr(11 downto 8) = x"2" then
            v.axiReadSlave.rdata(31 downto 16) := fbStatusErrorCnt(conv_integer(axiReadMaster.araddr(4 downto 2)));
            v.axiReadSlave.rdata(15 downto 0)  := fbStatusIdleCnt(conv_integer(axiReadMaster.araddr(4 downto 2)));

            -- FB FIFO read, one per FIFO, 0x300

            -- OC Opcode A Generation, 0x400

            -- OC FIFO read, 0x404 (legacy)

            -- OC Fifo Enable, 0x408 (legacy)

            -- Debug counter, 0x40c (legacy)

            -- OC Opcode B Generation, 0x410

         -- Tx Data A Count, 0x414
         elsif axiReadMaster.araddr(11 downto 0) = x"414" then
            v.axiReadSlave.rdata := txCountSync(0);

         -- Tx Data B Count, 0x418
         elsif axiReadMaster.araddr(11 downto 0) = x"418" then
            v.axiReadSlave.rdata := txCountSync(1);

            -- Counter Reset, 0x41C

         -- Rx Data Count, 0x5xx
         elsif axiReadMaster.araddr(11 downto 8) = x"5" then
            v.axiReadSlave.rdata := rxCountSync(conv_integer(axiReadMaster.araddr(4 downto 2)));

         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.axiReadSlave);
      end if;

      -- Reset
      if (axiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axiReadSlave  <= r.axiReadSlave;
      axiWriteSlave <= r.axiWriteSlave;

   end process;

-- Count Reset gen
   U_CountRstGen : entity work.RstSync
      generic map (
         TPD_G           => TPD_G,
         IN_POLARITY_G   => '1',
         OUT_POLARITY_G  => '1',
         RELEASE_DELAY_G => 16
         )
      port map (
         clk      => distClk,
         asyncRst => r.countReset,
         syncRst  => countReset
         );

   U_SynchronizerFifo_1 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 10)
      port map (
         wr_clk => axiClk,              -- [in]
         wr_en  => r.cmdCodeEn(0),      -- [in]
         din    => r.cmdCode(0),        -- [in]
         rd_clk => distClk,             -- [in]
         rd_en  => regCodeEn(0),        -- [in]
         valid  => regCodeEn(0),        -- [out]
         dout   => regCode(0));         -- [out]

   U_SynchronizerFifo_2 : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => 10)
      port map (
         wr_clk => axiClk,              -- [in]
         wr_en  => r.cmdCodeEn(1),      -- [in]
         din    => r.cmdCode(1),        -- [in]
         rd_clk => distClk,             -- [in]
         rd_en  => regCodeEn(1),        -- [in]
         valid  => regCodeEn(1),        -- [out]
         dout   => regCode(1));         -- [out]


end architecture STRUCTURE;

