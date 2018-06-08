-------------------------------------------------------------------------------
-- Title      : Common DTM Core Module
-- File       : DtmCoreC10.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2019-04-12
-------------------------------------------------------------------------------
-- Description:
-- Common top level module for DTM, COB C10 Version
-------------------------------------------------------------------------------
-- This file is part of 'SLAC RCE DTM Core'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC RCE DTM Core', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------
-- Modification history:
-- 11/14/2013: created.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.RceG3Pkg.all;
use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;

library unisim;
use unisim.vcomponents.all;

entity DtmCore is
   generic (
      TPD_G          : time           := 1 ns;
      BUILD_INFO_G   : BuildInfoType
   ); port (

      -- I2C
      i2cSda                  : inout sl;
      i2cScl                  : inout sl;

      -- PCI Exress
      pciRefClkP              : in    sl;
      pciRefClkM              : in    sl;
      pciRxP                  : in    sl;
      pciRxM                  : in    sl;
      pciTxP                  : out   sl;
      pciTxM                  : out   sl;
      pciResetL               : out   sl;

      -- COB Ethernet
      ethRxP                  : in    sl;
      ethRxM                  : in    sl;
      ethTxP                  : out   sl;
      ethTxM                  : out   sl;

      -- Clock Select
      clkSelA                 : out   sl;
      clkSelB                 : out   sl;

      -- Base Ethernet
      ethRxCtrl               : in    slv(1 downto 0);
      ethRxClk                : in    slv(1 downto 0);
      ethRxDataA              : in    Slv(1 downto 0);
      ethRxDataB              : in    Slv(1 downto 0);
      ethRxDataC              : in    Slv(1 downto 0);
      ethRxDataD              : in    Slv(1 downto 0);
      ethTxCtrl               : out   slv(1 downto 0);
      ethTxClk                : out   slv(1 downto 0);
      ethTxDataA              : out   Slv(1 downto 0);
      ethTxDataB              : out   Slv(1 downto 0);
      ethTxDataC              : out   Slv(1 downto 0);
      ethTxDataD              : out   Slv(1 downto 0);
      ethMdc                  : out   Slv(1 downto 0);
      ethMio                  : inout Slv(1 downto 0);
      ethResetL               : out   Slv(1 downto 0);

      -- IPMI
      dtmToIpmiP              : out   slv(1 downto 0);
      dtmToIpmiM              : out   slv(1 downto 0);

      -- Clocks
      sysClk125               : out   sl;
      sysClk125Rst            : out   sl;
      sysClk200               : out   sl;
      sysClk200Rst            : out   sl;

      -- External Axi Bus, 0x90000000 - 0x97FFFFFF
      axiClk                  : out   sl;
      axiClkRst               : out   sl;
      extAxilReadMaster       : out   AxiLiteReadMasterType;
      extAxilReadSlave        : in    AxiLiteReadSlaveType;
      extAxilWriteMaster      : out   AxiLiteWriteMasterType;
      extAxilWriteSlave       : in    AxiLiteWriteSlaveType;

      -- DMA Interfaces
      dmaClk                  : in    slv(2 downto 0);
      dmaClkRst               : in    slv(2 downto 0);
      dmaState                : out   RceDmaStateArray(2 downto 0);
      dmaObMaster             : out   AxiStreamMasterArray(2 downto 0);
      dmaObSlave              : in    AxiStreamSlaveArray(2 downto 0);
      dmaIbMaster             : in    AxiStreamMasterArray(2 downto 0);
      dmaIbSlave              : out   AxiStreamSlaveArray(2 downto 0);

      -- User Interrupts
      userInterrupt            : in    slv(USER_INT_COUNT_C-1 downto 0)

   );
end DtmCore;

architecture STRUCTURE of DtmCore is
   signal iaxiClk             : sl;
   signal iaxiClkRst          : sl;
   signal isysClk125          : sl;
   signal isysClk125Rst       : sl;
   signal isysClk200          : sl;
   signal isysClk200Rst       : sl;
   signal idmaClk             : slv(3 downto 0);
   signal idmaClkRst          : slv(3 downto 0);
   signal idmaState           : RceDmaStateArray(3 downto 0);
   signal idmaObMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaObSlave         : AxiStreamSlaveArray(3 downto 0);
   signal idmaIbMaster        : AxiStreamMasterArray(3 downto 0);
   signal idmaIbSlave         : AxiStreamSlaveArray(3 downto 0);
   signal coreAxilReadMaster  : AxiLiteReadMasterType;
   signal coreAxilReadSlave   : AxiLiteReadSlaveType;
   signal coreAxilWriteMaster : AxiLiteWriteMasterType;
   signal coreAxilWriteSlave  : AxiLiteWriteSlaveType;
   signal armEthTx            : ArmEthTxArray(1 downto 0);
   signal armEthRx            : ArmEthRxArray(1 downto 0);
   signal armEthMode          : slv(31 downto 0);

begin

   --------------------------------------------------
   -- Outputs
   --------------------------------------------------
   axiClk          <= iaxiClk;
   axiClkRst       <= iaxiClkRst;
   sysClk125       <= isysClk125;
   sysClk125Rst    <= isysClk125Rst;
   sysClk200       <= isysClk200;
   sysClk200Rst    <= isysClk200Rst;

   -- DMA Interfaces
   idmaClk(2 downto 0)      <= dmaClk;
   idmaClkRst(2 downto 0)   <= dmaClkRst;
   dmaState                 <= idmaState(2 downto 0);
   dmaObMaster              <= idmaObMaster(2 downto 0);
   idmaObSlave(2 downto 0)  <= dmaObSlave;
   idmaIbMaster(2 downto 0) <= dmaIbMaster;
   dmaIbSlave               <= idmaIbSlave(2 downto 0);


   --------------------------------------------------
   -- RCE Core
   --------------------------------------------------
   U_RceG3Top: entity work.RceG3Top
      generic map (
         TPD_G          => TPD_G,
         BUILD_INFO_G   => BUILD_INFO_G,
         PCIE_EN_G      => true,
         RCE_DMA_MODE_G => RCE_DMA_AXIS_C
      ) port map (
         i2cSda              => i2cSda,
         i2cScl              => i2cScl,
         sysClk125           => isysClk125,
         sysClk125Rst        => isysClk125Rst,
         sysClk200           => isysClk200,
         sysClk200Rst        => isysClk200Rst,
         axiClk              => iaxiClk,
         axiClkRst           => iaxiClkRst,
         extAxilReadMaster   => extAxilReadMaster,
         extAxilReadSlave    => extAxilReadSlave ,
         extAxilWriteMaster  => extAxilWriteMaster,
         extAxilWriteSlave   => extAxilWriteSlave ,
         coreAxilReadMaster  => coreAxilReadMaster,
         coreAxilReadSlave   => coreAxilReadSlave,
         coreAxilWriteMaster => coreAxilWriteMaster,
         coreAxilWriteSlave  => coreAxilWriteSlave,
         pciRefClkP          => pciRefClkP,
         pciRefClkM          => pciRefClkM,
         pciResetL           => pciResetL,
         pcieRxP             => pciRxP,
         pcieRxM             => pciRxM,
         pcieTxP             => pciTxP,
         pcieTxM             => pciTxM,
         dmaClk              => idmaClk,
         dmaClkRst           => idmaClkRst,
         dmaState            => idmaState,
         dmaObMaster         => idmaObMaster,
         dmaObSlave          => idmaObSlave,
         dmaIbMaster         => idmaIbMaster,
         dmaIbSlave          => idmaIbSlave,
         userInterrupt       => userInterrupt,
         armEthTx            => armEthTx,
         armEthRx            => armEthRx,
         armEthMode          => armEthMode,
         clkSelA             => open,
         clkSelB             => open
      );

   -- Hard code to 250Mhz
   clkSelA <= '1';
   clkSelB <= '1';

   coreAxilReadSlave  <= AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   coreAxilWriteSlave <= AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   --------------------------------------------------
   -- Ethernet
   --------------------------------------------------
   U_ZynqEthernet : entity work.ZynqEthernet 
      port map (
         sysClk125          => isysClk125,
         sysClk200          => isysClk200,
         sysClk200Rst       => isysClk200Rst,
         armEthTx           => armEthTx(0),
         armEthRx           => armEthRx(0),
         ethRxP             => ethRxP,
         ethRxM             => ethRxM,
         ethTxP             => ethTxP,
         ethTxM             => ethTxM
      );

   armEthRx(1)     <= ARM_ETH_RX_INIT_C;
   armEthMode      <= x"00000001"; -- 1 Gig on lane 0
   idmaClk(3)      <= isysClk125;
   idmaClkRst(3)   <= isysClk125Rst;
   idmaObSlave(3)  <= AXI_STREAM_SLAVE_INIT_C;
   idmaIbMaster(3) <= AXI_STREAM_MASTER_INIT_C;

   --------------------------------------------------
   -- Unused
   --------------------------------------------------

   dtmToIpmiP(0) <= 'Z';
   dtmToIpmiP(1) <= 'Z';
   dtmToIpmiM(0) <= 'Z';
   dtmToIpmiM(1) <= 'Z';

end architecture STRUCTURE;

