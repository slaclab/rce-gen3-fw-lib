-------------------------------------------------------------------------------
-- Title         : RCE Generation 3, BSI Controller
-- File          : RceG3Bsi.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 05/08/2014
-------------------------------------------------------------------------------
-- Description:
-- I2C Slave block for IPMI operations:
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
-- 05/08/2014: created.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.i2cPkg.all;
use work.RceG3Pkg.all;
use work.AxiLitePkg.all;

entity RceG3Bsi is
   generic (
      TPD_G      : time    := 1 ns;
      BYP_BSI_G  : boolean := false); -- true for non-COB applications (like DEV boards)
   port (

      -- Clock and reset
      axiClk    : in sl;
      axiClkRst : in sl;

      -- AXI Lite Buses
      -- Channel 0 = 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;

      -- Interrupt
      armEthMode : in slv(31 downto 0);
      eFuseValue : in slv(31 downto 0);
      deviceDna  : in slv(127 downto 0);

      -- IIC Interface
      i2cSda : inout sl;
      i2cScl : inout sl
      );
end RceG3Bsi;

architecture IMP of RceG3Bsi is

   signal i2cBramRd    : sl;
   signal i2cBramWr    : sl;
   signal i2cBramAddr  : slv(15 downto 0);
   signal i2cBramDout  : slv(7 downto 0);
   signal locBramDout  : slv(7 downto 0);
   signal i2cBramDin   : slv(7 downto 0);
   signal cpuBramDout  : slv(31 downto 0);
   signal i2cIn        : i2c_in_type;
   signal i2cOut       : i2c_out_type;
   signal bsiFifoWrite : sl;
   signal bsiFifoDin   : slv(47 downto 0);
   signal bsiFifoAFull : sl;
   signal bsiFifoDout  : slv(47 downto 0);
   signal bsiFifoValid : sl;
   signal aFullData    : slv(7 downto 0);

   type RegType is record
      cpuBramWr      : sl;
      cpuBramAddr    : slv(8 downto 0);
      cpuBramDin     : slv(31 downto 0);
      readEnDly      : slv(1 downto 0);
      bsiFifoRd      : sl;
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      cpuBramWr      => '0',
      cpuBramAddr    => (others => '0'),
      cpuBramDin     => (others => '0'),
      readEnDly      => (others => '0'),
      bsiFifoRd      => '0',
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
      );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   -------------------------
   -- I2c Slave
   -------------------------
   U_i2cb : entity work.i2cRegSlave
      generic map (
         TPD_G                => TPD_G,
         TENBIT_G             => 0,
         I2C_ADDR_G           => 73,    -- "1001001";
         OUTPUT_EN_POLARITY_G => 0,
         FILTER_G             => 4,
         ADDR_SIZE_G          => 2,     -- in bytes
         DATA_SIZE_G          => 1,     -- in bytes
         ENDIANNESS_G         => 0      -- 0=LE, 1=BE
         ) port map (
            sRst   => '0',
            aRst   => axiClkRst,
            clk    => axiClk,
            addr   => i2cBramAddr,
            wrEn   => i2cBramWr,
            wrData => i2cBramDin,
            rdEn   => i2cBramRd,
            rdData => i2cBramDout,
            i2ci   => i2cIn,
            i2co   => i2cOut
            );

   GEN_BSI : if (BYP_BSI_G = false) generate         
   
      U_I2cScl : IOBUF
         port map (
            IO => i2cScl,
            I  => i2cOut.scl,
            O  => i2cIn.scl,
            T  => i2cOut.scloen);

      U_I2cSda : IOBUF
         port map (
            IO => i2cSda,
            I  => i2cOut.sda,
            O  => i2cIn.sda,
            T  => i2cOut.sdaoen);
            
   end generate;

   -------------------------
   -- Dual port ram
   -------------------------
   bram_0 : RAMB16_S9_S36
      port map (
         DOB   => cpuBramDout,
         DOPB  => open,
         ADDRB => r.cpuBramAddr,
         CLKB  => axiClk,
         DIB   => r.cpuBramDin,
         DIPB  => x"0",
         ENB   => '1',
         SSRB  => '0',
         WEB   => r.cpuBramWr,
         DOA   => locBramDout,
         DOPA  => open,
         ADDRA => i2cBramAddr(10 downto 0),
         CLKA  => axiClk,
         DIA   => i2cBramDin,
         DIPA  => "0",
         ENA   => '1',
         SSRA  => '0',
         WEA   => i2cBramWr
         );

   -- Mux I2C Output Data
   process (aFullData, armEthMode, deviceDna, eFuseValue, i2cBramAddr,
            locBramDout)
   begin
      case i2cBramAddr(11 downto 0) is
         when x"800" => i2cBramDout <= aFullData;    -- Bit 0 = AFULL
         when x"801" => i2cBramDout <= (others => '0');
         when x"802" => i2cBramDout <= (others => '0');
         when x"803" => i2cBramDout <= (others => '0');
         when x"804" => i2cBramDout <= armEthMode(7 downto 0);
         when x"805" => i2cBramDout <= armEthMode(15 downto 8);
         when x"806" => i2cBramDout <= armEthMode(23 downto 16);
         when x"807" => i2cBramDout <= armEthMode(31 downto 24);
         when x"808" => i2cBramDout <= eFuseValue(7 downto 0);
         when x"809" => i2cBramDout <= eFuseValue(15 downto 8);
         when x"80A" => i2cBramDout <= eFuseValue(23 downto 16);
         when x"80B" => i2cBramDout <= eFuseValue(31 downto 24);
         when x"80C" => i2cBramDout <= deviceDna(7 downto 0);
         when x"80D" => i2cBramDout <= deviceDna(15 downto 8);
         when x"80E" => i2cBramDout <= deviceDna(23 downto 16);
         when x"80F" => i2cBramDout <= deviceDna(31 downto 24);
         when x"810" => i2cBramDout <= deviceDna(39 downto 32);
         when x"811" => i2cBramDout <= deviceDna(47 downto 40);
         when x"812" => i2cBramDout <= deviceDna(55 downto 48);
         when x"813" => i2cBramDout <= deviceDna(63 downto 56);
         when x"814" => i2cBramDout <= deviceDna(71 downto 64);
         when x"815" => i2cBramDout <= deviceDna(79 downto 72);
         when x"816" => i2cBramDout <= deviceDna(87 downto 80);
         when x"817" => i2cBramDout <= deviceDna(95 downto 88);
         when x"818" => i2cBramDout <= deviceDna(103 downto 96);
         when x"819" => i2cBramDout <= deviceDna(111 downto 104);
         when x"81A" => i2cBramDout <= deviceDna(119 downto 112);
         when x"81B" => i2cBramDout <= deviceDna(127 downto 120);
         when others => i2cBramDout <= locBramDout;  -- DPRAM 0x000 - 0x7FF
      end case;
   end process;

   -- Register almost full data
   process (axiClk)
   begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            aFullData <= (others => '0') after TPD_G;
         else
            aFullData(0) <= bsiFifoAFull after TPD_G;
         end if;
      end if;
   end process;


   -------------------------
   -- BSI CPU Interface
   -------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (axiClkRst, axilReadMaster, axilWriteMaster, bsiFifoDout,
            bsiFifoValid, cpuBramDout, r) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
   begin
      v := r;

      v.bsiFifoRd := '0';
      v.cpuBramWr := '0';
      v.readEnDly := (others => '0');

      axiSlaveWaitTxn(axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Write only to block ram
         if axilWriteMaster.awaddr(11) = '0' then
            v.cpuBramWr   := '1';
            v.cpuBramAddr := axilWriteMaster.awaddr(10 downto 2);
            v.cpuBramDin  := axilWriteMaster.wdata;
         end if;
         axiSlaveWriteResponse(v.axilWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.cpuBramAddr := axilReadMaster.araddr(10 downto 2);

         -- Read from to block ram
         if axilReadMaster.araddr(11) = '0' then
            v.readEnDly(0) := '1';
            v.readEnDly(1) := r.readEnDly(0);

            -- Send Axi Response
            if (r.readEnDly(1) = '1') then
               v.axilReadSlave.rdata := cpuBramDout;
               axiSlaveReadResponse(v.axilReadSlave);
            end if;
         else
            v.bsiFifoRd                        := bsiFifoValid;
            v.axilReadSlave.rdata(15 downto 0) := bsiFifoDout(47 downto 32);
            v.axilReadSlave.rdata(16)          := bsiFifoValid;
            axiSlaveReadResponse(v.axilReadSlave);
         end if;
      end if;

      -- Reset
      if (axiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      axilReadSlave  <= r.axilReadSlave;
      axilWriteSlave <= r.axilWriteSlave;

   end process;


   --------------------------------------------------
   -- BSI FIFO 
   --------------------------------------------------
   process (axiClk)
   begin
      if rising_edge(axiClk) then
         if axiClkRst = '1' then
            bsiFifoDin   <= (others => '0') after TPD_G;
            bsiFifoWrite <= '0'             after TPD_G;
         elsif i2cBramWr = '1' then
            if i2cBramAddr(1 downto 0) = 0 then
               bsiFifoDin(7 downto 0) <= i2cBramDin after TPD_G;
               bsiFifoWrite           <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 1 then
               bsiFifoDin(15 downto 8) <= i2cBramDin after TPD_G;
               bsiFifoWrite            <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 2 then
               bsiFifoDin(23 downto 16) <= i2cBramDin after TPD_G;
               bsiFifoWrite             <= '0'        after TPD_G;
            elsif i2cBramAddr(1 downto 0) = 3 then
               bsiFifoDin(47 downto 32) <= i2cBramAddr after TPD_G;
               bsiFifoDin(31 downto 24) <= i2cBramDin  after TPD_G;
               bsiFifoWrite             <= '1'         after TPD_G;
            end if;
         else
            bsiFifoWrite <= '0' after TPD_G;
         end if;
      end if;
   end process;


   U_BsiFifo : entity work.Fifo
      generic map (
         TPD_G           => TPD_G,
         GEN_SYNC_FIFO_G => true,
         FWFT_EN_G       => true,
         DATA_WIDTH_G    => 48,
         ADDR_WIDTH_G    => 9,
         FULL_THRES_G    => 479)
      port map (
         rst           => axiClkRst,
         wr_clk        => axiClk,
         wr_en         => bsiFifoWrite,
         din           => bsiFifoDin,
         prog_full     => bsiFifoAFull,
         rd_clk        => axiClk,
         rd_en         => r.bsiFifoRd,
         dout          => bsiFifoDout,
         valid         => bsiFifoValid);

end architecture IMP;

