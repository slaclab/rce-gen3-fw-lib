-------------------------------------------------------------------------------
-- Title         : Local AXI Bus Bridge and Registers
-- File          : RceG3AxiCntl.vhd
-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
-- Created       : 03/06/2014
-------------------------------------------------------------------------------
-- Description:
-- Wrapper for AXI bus converter, crossbar and core registers
------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 03/06/2014: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library unisim;
use unisim.vcomponents.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.RceG3Version.all;

entity RceG3AxiCntl is
   generic (
      TPD_G          : time           := 1 ns;
      BUILD_INFO_G   : BuildInfoType;
      PCIE_EN_G      : boolean        := false;
      RCE_DMA_MODE_G : RceDmaModeType := RCE_DMA_PPI_C
      );
   port (

      -- GP AXI Masters, 0=axiDmaClk, 1=axiClk
      mGpReadMaster  : in  AxiReadMasterArray(1 downto 0);
      mGpReadSlave   : out AxiReadSlaveArray(1 downto 0);
      mGpWriteMaster : in  AxiWriteMasterArray(1 downto 0);
      mGpWriteSlave  : out AxiWriteSlaveArray(1 downto 0);

      -- Fast AXI Busses
      axiDmaClk : in sl;
      axiDmaRst : in sl;

      -- Interrupt Control AXI Lite Bus
      icAxilReadMaster  : out AxiLiteReadMasterType;
      icAxilReadSlave   : in  AxiLiteReadSlaveType;
      icAxilWriteMaster : out AxiLiteWriteMasterType;
      icAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- DMA AXI Lite Busses, dmaAxiClk
      dmaAxilReadMaster  : out AxiLiteReadMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilReadSlave   : in  AxiLiteReadSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteMaster : out AxiLiteWriteMasterArray(DMA_AXIL_COUNT_C-1 downto 0);
      dmaAxilWriteSlave  : in  AxiLiteWriteSlaveArray(DMA_AXIL_COUNT_C-1 downto 0);

      -- Slow AXI Busses
      axiClk    : in sl;
      axiClkRst : in sl;

      -- BSI AXI Lite
      bsiAxilReadMaster  : out AxiLiteReadMasterType;
      bsiAxilReadSlave   : in  AxiLiteReadSlaveType;
      bsiAxilWriteMaster : out AxiLiteWriteMasterType;
      bsiAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- External AXI Lite (top level, outside DpmCore, DtmCore)
      extAxilReadMaster  : out AxiLiteReadMasterType;
      extAxilReadSlave   : in  AxiLiteReadSlaveType;
      extAxilWriteMaster : out AxiLiteWriteMasterType;
      extAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- Core AXI Lite (outside RCE, insidde DpmCore, DtmCore)
      coreAxilReadMaster  : out AxiLiteReadMasterType;
      coreAxilReadSlave   : in  AxiLiteReadSlaveType;
      coreAxilWriteMaster : out AxiLiteWriteMasterType;
      coreAxilWriteSlave  : in  AxiLiteWriteSlaveType;

      -- User AXI Interface
      userReadMaster      : in  AxiReadMasterType;
      userReadSlave       : out AxiReadSlaveType;
      userWriteMaster     : in  AxiWriteMasterType;
      userWriteSlave      : out AxiWriteSlaveType;

      -- AUX AXI Interface
      auxReadMaster       : out AxiReadMasterType;
      auxReadSlave        : in  AxiReadSlaveType;
      auxWriteMaster      : out AxiWriteMasterType;
      auxWriteSlave       : in  AxiWriteSlaveType;
      auxAxiClk           : out sl;

      -- PCIE AXI Interface
      pciRefClkP      : in  sl;
      pciRefClkM      : in  sl;
      pciResetL       : out sl;
      pcieInt         : out sl;
      pcieRxP         : in  sl;
      pcieRxM         : in  sl;
      pcieTxP         : out sl;
      pcieTxM         : out sl;

      -- Ethernet Mode
      armEthMode : in  slv(31 downto 0);
      eFuseValue : out slv(31 downto 0);
      deviceDna  : out slv(63 downto 0);

      -- Clock Select Lines
      clkSelA : out slv(1 downto 0);
      clkSelB : out slv(1 downto 0)
      );
end RceG3AxiCntl;

architecture structure of RceG3AxiCntl is

   constant GP0_MAST_CNT_C : integer := DMA_AXIL_COUNT_C + 1;
   constant GP1_MAST_CNT_C : integer := 4;

   constant BUILD_INFO_C       : BuildInfoRetType    := toBuildInfo(BUILD_INFO_G);
   constant BUILD_STRING_ROM_C : Slv32Array(0 to 63) := BUILD_INFO_C.buildString;

   -- Gp0 Signals
   signal midGp0ReadMaster   : AxiLiteReadMasterType;
   signal midGp0ReadSlave    : AxiLiteReadSlaveType;
   signal midGp0WriteMaster  : AxiLiteWriteMasterType;
   signal midGp0WriteSlave   : AxiLiteWriteSlaveType;
   signal tmpGp0ReadMasters  : AxiLiteReadMasterArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0ReadSlaves   : AxiLiteReadSlaveArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0WriteMasters : AxiLiteWriteMasterArray(GP0_MAST_CNT_C-1 downto 0);
   signal tmpGp0WriteSlaves  : AxiLiteWriteSlaveArray(GP0_MAST_CNT_C-1 downto 0);

   -- Gp1 Signals
   signal gp1AxiReadMaster   : AxiReadMasterType;
   signal gp1AxiReadSlave    : AxiReadSlaveType;
   signal gp1AxiWriteMaster  : AxiWriteMasterType;
   signal gp1AxiWriteSlave   : AxiWriteSlaveType;
   signal midGp1ReadMaster   : AxiLiteReadMasterType;
   signal midGp1ReadSlave    : AxiLiteReadSlaveType;
   signal midGp1WriteMaster  : AxiLiteWriteMasterType;
   signal midGp1WriteSlave   : AxiLiteWriteSlaveType;
   signal tmpGp1ReadMasters  : AxiLiteReadMasterArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1ReadSlaves   : AxiLiteReadSlaveArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1WriteMasters : AxiLiteWriteMasterArray(GP1_MAST_CNT_C-1 downto 0);
   signal tmpGp1WriteSlaves  : AxiLiteWriteSlaveArray(GP1_MAST_CNT_C-1 downto 0);

   -- Local signals
   signal intReadMaster  : AxiLiteReadMasterType;
   signal intReadSlave   : AxiLiteReadSlaveType;
   signal intWriteMaster : AxiLiteWriteMasterType;
   signal intWriteSlave  : AxiLiteWriteSlaveType;
   signal dnaValue       : slv(127 downto 0);
   signal dnaValid       : sl;
   signal eFuseUsr       : slv(31 downto 0);

   type RegType is record
      scratchPad    : slv(31 downto 0);
      clkSelA       : slv(1 downto 0);
      clkSelB       : slv(1 downto 0);
      heartbeat     : slv(31 downto 0);
      intReadSlave  : AxiLiteReadSlaveType;
      intWriteSlave : AxiLiteWriteSlaveType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      scratchPad    => (others => '0'),
      clkSelA       => (others => '0'),
      clkSelB       => (others => '1'),
      heartbeat     => (others => '0'),
      intReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      intWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C
      );

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   -- GP0 Address Map Generator
   function genGp0Config return AxiLiteCrossbarMasterConfigArray is
      variable retConf : AxiLiteCrossbarMasterConfigArray(DMA_AXIL_COUNT_C downto 0);
      variable addr    : slv(31 downto 0);
   begin

      -- Int control record is fixed
      retConf(0).baseAddr     := x"40000000";
      retConf(0).addrBits     := 16;
      retConf(0).connectivity := x"FFFF";

      -- Generate dma records
      if RCE_DMA_MODE_G = RCE_DMA_PPI_C then
         addr := x"50000000";
      else
         addr := x"60000000";
      end if;

      for i in 0 to DMA_AXIL_COUNT_C-1 loop
         addr(23 downto 16)        := toSlv(i, 8);
         retConf(i+1).baseAddr     := addr;
         retConf(i+1).addrBits     := 16;
         retConf(i+1).connectivity := x"FFFF";
      end loop;

      return retConf;
   end function;

   -- GP0 Address Map Generator
   function genGp1Config return AxiLiteCrossbarMasterConfigArray is
      variable retConf : AxiLiteCrossbarMasterConfigArray(3 downto 0);
   begin
      if PCIE_EN_G then
          -- 0x80000000 - 0x8000FFFF : Internal registers
          retConf(0).baseAddr     := x"80000000";
          retConf(0).addrBits     := 16;
          retConf(0).connectivity := x"FFFF";

          -- 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
          retConf(1).baseAddr     := x"84000000";
          retConf(1).addrBits     := 12;
          retConf(1).connectivity := x"FFFF";

          -- 0x90000000 - 0x97FFFFFF : External Register Space
          retConf(2).baseAddr     := x"90000000";
          retConf(2).addrBits     := 27;
          retConf(2).connectivity := x"FFFF";

          -- 0x98000000 - 0x9FFFFFFF : Core Register Space
          retConf(3).baseAddr     := x"98000000";
          retConf(3).addrBits     := 27;
          retConf(3).connectivity := x"FFFF";

      else

          -- 0x80000000 - 0x8000FFFF : Internal registers
          retConf(0).baseAddr     := x"80000000";
          retConf(0).addrBits     := 16;
          retConf(0).connectivity := x"FFFF";

          -- 0x84000000 - 0x84000FFF : BSI I2C Slave Registers
          retConf(1).baseAddr     := x"84000000";
          retConf(1).addrBits     := 12;
          retConf(1).connectivity := x"FFFF";

          -- 0xA0000000 - 0xAFFFFFFF : External Register Space
          retConf(2).baseAddr     := x"A0000000";
          retConf(2).addrBits     := 28;
          retConf(2).connectivity := x"FFFF";

          -- 0xB0000000 - 0xBFFFFFFF : Core Register Space
          retConf(3).baseAddr     := x"B0000000";
          retConf(3).addrBits     := 28;
          retConf(3).connectivity := x"FFFF";

      end if;
      return retConf;
   end function;

begin

   -------------------------------------
   -- GP0 AXI-4 to AXI Lite Conversion
   -- 0x40000000 - 0x7FFFFFFF, axiDmaClk
   -------------------------------------
   U_Gp0AxiLite : entity work.AxiToAxiLite
      generic map (
         TPD_G => TPD_G
         ) port map (
            axiClk          => axiDmaClk,
            axiClkRst       => axiDmaRst,
            axiReadMaster   => mGpReadMaster(0),
            axiReadSlave    => mGpReadSlave(0),
            axiWriteMaster  => mGpWriteMaster(0),
            axiWriteSlave   => mGpWriteSlave(0),
            axilReadMaster  => midGp0ReadMaster,
            axilReadSlave   => midGp0ReadSlave,
            axilWriteMaster => midGp0WriteMaster,
            axilWriteSlave  => midGp0WriteSlave
            );

   -------------------------------------
   -- GP0 AXI Lite Crossbar
   -- 0x40000000 - 0x7FFFFFFF, axiDmaClk
   -------------------------------------
   U_Gp0Crossbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => GP0_MAST_CNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => genGp0Config
         ) port map (
            axiClk              => axiDmaClk,
            axiClkRst           => axiDmaRst,
            sAxiWriteMasters(0) => midGp0WriteMaster,
            sAxiWriteSlaves(0)  => midGp0WriteSlave,
            sAxiReadMasters(0)  => midGp0ReadMaster,
            sAxiReadSlaves(0)   => midGp0ReadSlave,
            mAxiWriteMasters    => tmpGp0WriteMasters,
            mAxiWriteSlaves     => tmpGp0WriteSlaves,
            mAxiReadMasters     => tmpGp0ReadMasters,
            mAxiReadSlaves      => tmpGp0ReadSlaves
            );

   icAxilWriteMaster    <= tmpGp0WriteMasters(0);
   tmpGp0WriteSlaves(0) <= icAxilWriteSlave;
   icAxilReadMaster     <= tmpGp0ReadMasters(0);
   tmpGp0ReadSlaves(0)  <= icAxilReadSlave;

   dmaAxilWriteMaster                           <= tmpGp0WriteMasters(DMA_AXIL_COUNT_C downto 1);
   tmpGp0WriteSlaves(DMA_AXIL_COUNT_C downto 1) <= dmaAxilWriteSlave;
   dmaAxilReadMaster                            <= tmpGp0ReadMasters(DMA_AXIL_COUNT_C downto 1);
   tmpGp0ReadSlaves(DMA_AXIL_COUNT_C downto 1)  <= dmaAxilReadSlave;


   -------------------------------------
   -- GP1 AXI-4 Interconnect
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_ICEN: if PCIE_EN_G generate

      -- Local    = 0x80000000 - 9FFFFFFF
      -- pcie cfg = 0xA0000000 - AFFFFFFF
      -- pcie bar = 0xB0000000 - BFFFFFFF
      U_RceG3PcieRoot: entity work.RceG3PcieRoot
         generic map ( TPD_G  => TPD_G )
         port map (
            axiClk           => axiClk,
            axiRst           => axiClkRst,
            mGpReadMaster    => mGpReadMaster(1),
            mGpReadSlave     => mGpReadSlave(1),
            mGpWriteMaster   => mGpWriteMaster(1),
            mGpWriteSlave    => mGpWriteSlave(1),
            locReadMaster    => gp1AxiReadMaster,
            locReadSlave     => gp1AxiReadSlave,
            locWriteMaster   => gp1AxiWriteMaster,
            locWriteSlave    => gp1AxiWriteSlave,
            pcieReadMaster   => auxReadMaster,
            pcieReadSlave    => auxReadSlave,
            pcieWriteMaster  => auxWriteMaster,
            pcieWriteSlave   => auxWriteSlave,
            pcieAxiClk       => auxAxiClk,
            pciRefClkP       => pciRefClkP,
            pciRefClkM       => pciRefClkM,
            pciResetL        => pciResetL,
            pcieInt          => pcieInt,
            pcieRxP          => pcieRxP,
            pcieRxM          => pcieRxM,
            pcieTxP          => pcieTxP,
            pcieTxM          => pcieTxM
         );

      userReadSlave  <= AXI_READ_SLAVE_INIT_C;
      userWriteSlave <= AXI_WRITE_SLAVE_INIT_C;

   end generate;

   U_ICDIS: if not PCIE_EN_G generate

      auxReadMaster  <= userReadMaster;
      userReadSlave  <= auxReadSlave;
      auxWriteMaster <= userWriteMaster;
      userWriteSlave <= auxWriteSlave;

      auxAxiClk <= axiDmaClk;

      pciResetL  <= '0';
      pcieInt    <= '0';
      pcieTxP    <= '0';
      pcieTxM    <= '0';

      gp1AxiReadMaster  <= mGpReadMaster(1);
      mGpReadSlave(1)   <= gp1AxiReadSlave;
      gp1AxiWriteMaster <= mGpWriteMaster(1);
      mGpWriteSlave(1)  <= gp1AxiWriteSlave;

   end generate;

   -------------------------------------
   -- GP1 AXI-4 to AXI Lite Conversion
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_Gp1AxiLite : entity work.AxiToAxiLite
      generic map (
         TPD_G => TPD_G
         ) port map (
            axiClk          => axiClk,
            axiClkRst       => axiClkRst,
            axiReadMaster   => gp1AxiReadMaster,
            axiReadSlave    => gp1AxiReadSlave,
            axiWriteMaster  => gp1AxiWriteMaster,
            axiWriteSlave   => gp1AxiWriteSlave,
            axilReadMaster  => midGp1ReadMaster,
            axilReadSlave   => midGp1ReadSlave,
            axilWriteMaster => midGp1WriteMaster,
            axilWriteSlave  => midGp1WriteSlave
         );

   -------------------------------------
   -- GP1 AXI Lite Crossbar
   -- 0x80000000 - 0xBFFFFFFF, axiClk
   -------------------------------------
   U_Gp1Crossbar : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => GP1_MAST_CNT_C,
         DEC_ERROR_RESP_G   => AXI_RESP_OK_C,
         MASTERS_CONFIG_G   => genGp1Config)
      port map (
            axiClk              => axiClk,
            axiClkRst           => axiClkRst,
            sAxiWriteMasters(0) => midGp1WriteMaster,
            sAxiWriteSlaves(0)  => midGp1WriteSlave,
            sAxiReadMasters(0)  => midGp1ReadMaster,
            sAxiReadSlaves(0)   => midGp1ReadSlave,
            mAxiWriteMasters    => tmpGp1WriteMasters,
            mAxiWriteSlaves     => tmpGp1WriteSlaves,
            mAxiReadMasters     => tmpGp1ReadMasters,
            mAxiReadSlaves      => tmpGp1ReadSlaves
            );

   intWriteMaster       <= tmpGp1WriteMasters(0);
   tmpGp1WriteSlaves(0) <= intWriteSlave;
   intReadMaster        <= tmpGp1ReadMasters(0);
   tmpGp1ReadSlaves(0)  <= intReadSlave;

   bsiAxilWriteMaster   <= tmpGp1WriteMasters(1);
   tmpGp1WriteSlaves(1) <= bsiAxilWriteSlave;
   bsiAxilReadMaster    <= tmpGp1ReadMasters(1);
   tmpGp1ReadSlaves(1)  <= bsiAxilReadSlave;

   extAxilWriteMaster   <= tmpGp1WriteMasters(2);
   tmpGp1WriteSlaves(2) <= extAxilWriteSlave;
   extAxilReadMaster    <= tmpGp1ReadMasters(2);
   tmpGp1ReadSlaves(2)  <= extAxilReadSlave;

   coreAxilWriteMaster  <= tmpGp1WriteMasters(3);
   tmpGp1WriteSlaves(3) <= coreAxilWriteSlave;
   coreAxilReadMaster   <= tmpGp1ReadMasters(3);
   tmpGp1ReadSlaves(3)  <= coreAxilReadSlave;


   -------------------------------------
   -- Local Registers
   -------------------------------------

   -- Sync
   process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process;

   -- Async
   process (armEthMode, axiClkRst, dnaValid, dnaValue, eFuseUsr, intReadMaster, intWriteMaster, r) is
      variable v         : RegType;
      variable axiStatus : AxiLiteStatusType;
      variable c         : character;
   begin
      v := r;

      v.heartbeat := r.heartbeat + 1;

      axiSlaveWaitTxn(intWriteMaster, intReadMaster, v.intWriteSlave, v.intReadSlave, axiStatus);

      -- Write
      if (axiStatus.writeEnable = '1') then

         -- Decode address and perform write
         case (intWriteMaster.awaddr(15 downto 0)) is
            when X"0004" =>
               v.scratchPad := intWriteMaster.wdata;
            when X"0010" =>
               v.clkSelA(0) := intWriteMaster.wdata(0);
               v.clkSelB(0) := intWriteMaster.wdata(1);
            when X"0014" =>
               v.clkSelA(1) := intWriteMaster.wdata(0);
               v.clkSelB(1) := intWriteMaster.wdata(1);
            when others => null;
         end case;

         -- Send Axi response
         axiSlaveWriteResponse(v.intWriteSlave);
      end if;

      -- Read
      if (axiStatus.readEnable = '1') then
         v.intReadSlave.rdata := (others => '0');

         if intReadMaster.araddr(15 downto 12) = 0 then

            -- Decode address and assign read data
            case intReadMaster.araddr(15 downto 0) is
               when X"0000" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.fwVersion;
               when X"0004" =>
                  v.intReadSlave.rdata := r.scratchPad;
               when X"0008" =>
                  v.intReadSlave.rdata := RCE_G3_VERSION_C;
               when X"000C" =>
                  v.intReadSlave.rdata(0) := toSl(PCIE_EN_G);
               when X"0010" =>
                  v.intReadSlave.rdata(0) := r.clkSelA(0);
                  v.intReadSlave.rdata(1) := r.clkSelB(0);
               when X"0014" =>
                  v.intReadSlave.rdata(0) := r.clkSelA(1);
                  v.intReadSlave.rdata(1) := r.clkSelB(1);
               when X"0020" =>
                  v.intReadSlave.rdata(31)          := dnaValid;
                  v.intReadSlave.rdata(24 downto 0) := dnaValue(56 downto 32);
               when X"0024" =>
                  v.intReadSlave.rdata := dnaValue(31 downto 0);
               when X"0030" =>
                  v.intReadSlave.rdata := eFuseUsr;
               when X"0034" =>
                  v.intReadSlave.rdata := armEthMode;
               when X"0038" =>
                  v.intReadSlave.rdata := r.heartbeat;
               when X"0040" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(31 downto 0);
               when X"0044" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(63 downto 32);
               when X"0048" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(95 downto 64);
               when X"004C" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(127 downto 96);
               when X"0050" =>
                  v.intReadSlave.rdata := BUILD_INFO_C.gitHash(159 downto 128);
               when others => null;
            end case;
         else
            v.intReadSlave.rdata := BUILD_STRING_ROM_C(conv_integer(intReadMaster.araddr(7 downto 2)));
         end if;

         -- Send Axi Response
         axiSlaveReadResponse(v.intReadSlave);
      end if;

      -- Reset
      if (axiClkRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Next register assignment
      rin <= v;

      -- Outputs
      intReadSlave  <= r.intReadSlave;
      intWriteSlave <= r.intWriteSlave;
      clkSelA       <= r.clkSelA;
      clkSelB       <= r.clkSelB;
      
   end process;


   -------------------------------------
   -- Device DNA
   -------------------------------------
   U_DeviceDna : entity work.DeviceDna
      generic map (
         TPD_G           => TPD_G,
         RST_POLARITY_G  => '1',
         SIM_DNA_VALUE_G => X"000000000000000"
         ) port map (
            clk      => axiClk,
            rst      => axiClkRst,
            dnaValue => dnaValue,
            dnaValid => dnaValid
            );
   deviceDna <= dnaValue(63 downto 0);

   -------------------------------------
   -- EFuse
   -------------------------------------
   U_EFuse : EFUSE_USR
      port map (
         EFUSEUSR => eFuseUsr
         );
   eFuseValue <= eFuseUsr;

end architecture structure;
