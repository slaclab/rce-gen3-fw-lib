-------------------------------------------------------------------------------
-- Title         : ARM Based RCE Generation 3, Package File
-- File          : RceG3Pkg.vhd
-------------------------------------------------------------------------------
-- Description:
-- Package file for ARM based rce generation 3 processor core.
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
use IEEE.STD_LOGIC_UNSIGNED.all;

use work.StdRtlPkg.all;
use work.AxiPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

package RceG3Pkg is

   constant XIL_DEVICE_C : string := "7SERIES";

   constant DMA_AXIL_COUNT_C : integer := 9;
   constant DMA_INT_COUNT_C  : integer := 56;

   constant USER_INT_COUNT_C : integer := 8;

   --------------------------------------------------------
   -- DMA Engine Types
   --------------------------------------------------------

   type RceDmaModeType is (RCE_DMA_PPI_C, RCE_DMA_AXIS_C, RCE_DMA_AXISV2_C, RCE_DMA_Q4X2_C);

   type RceDmaStateType is record
      online : sl;
      user   : sl;
   end record;

   constant RCE_DMA_STATE_INIT_C : RceDmaStateType := (
      online => '0',
      user   => '0'
      );

   type RceDmaStateArray is array (natural range<>) of RceDmaStateType;

   --------------------------------------------------------
   -- AXI Configuration Constants
   --------------------------------------------------------

   constant AXI_MAST_GP_INIT_C : AxiConfigType := (
      ADDR_WIDTH_C => 32,
      DATA_BYTES_C => 4,
      ID_BITS_C    => 12,
      LEN_BITS_C   => 4);

   constant AXI_SLAVE_GP_INIT_C : AxiConfigType := (
      ADDR_WIDTH_C => 32,
      DATA_BYTES_C => 4,
      ID_BITS_C    => 6,
      LEN_BITS_C   => 4);

   constant AXI_ACP_INIT_C : AxiConfigType := (
      ADDR_WIDTH_C => 32,
      DATA_BYTES_C => 8,
      ID_BITS_C    => 3,
      LEN_BITS_C   => 4);

   constant AXI_HP_INIT_C : AxiConfigType := (
      ADDR_WIDTH_C => 32,
      DATA_BYTES_C => 8,
      ID_BITS_C    => 6,
      LEN_BITS_C   => 4);

   --------------------------------------------------------
   -- AXIS Configuration Constants
   --------------------------------------------------------

   constant RCEG3_AXIS_DMA_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 4,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);
   constant RCEG3_AXIS_DMA_ACP_CONFIG_C : AxiStreamConfigType := RCEG3_AXIS_DMA_CONFIG_C;

   --------------------------------------------------------
   -- Ethernet Types
   --------------------------------------------------------

   -- Base Record
   type ArmEthTxType is record
      enetGmiiTxEn        : sl;
      enetGmiiTxEr        : sl;
      enetMdioMdc         : sl;
      enetMdioO           : sl;
      enetMdioT           : sl;
      enetPtpDelayReqRx   : sl;
      enetPtpDelayReqTx   : sl;
      enetPtpPDelayReqRx  : sl;
      enetPtpPDelayReqTx  : sl;
      enetPtpPDelayRespRx : sl;
      enetPtpPDelayRespTx : sl;
      enetPtpSyncFrameRx  : sl;
      enetPtpSyncFrameTx  : sl;
      enetSofRx           : sl;
      enetSofTx           : sl;
      enetGmiiTxD         : slv(7 downto 0);
   end record;

   -- Initialization constants
   constant ARM_ETH_TX_INIT_C : ArmEthTxType := (
      enetGmiiTxEn        => '0',
      enetGmiiTxEr        => '0',
      enetMdioMdc         => '0',
      enetMdioO           => '0',
      enetMdioT           => '0',
      enetPtpDelayReqRx   => '0',
      enetPtpDelayReqTx   => '0',
      enetPtpPDelayReqRx  => '0',
      enetPtpPDelayReqTx  => '0',
      enetPtpPDelayRespRx => '0',
      enetPtpPDelayRespTx => '0',
      enetPtpSyncFrameRx  => '0',
      enetPtpSyncFrameTx  => '0',
      enetSofRx           => '0',
      enetSofTx           => '0',
      enetGmiiTxD         => (others => '0')
      );

   -- Array
   type ArmEthTxArray is array (natural range<>) of ArmEthTxType;

   -- Base Record
   type ArmEthRxType is record
      enetGmiiCol   : sl;
      enetGmiiCrs   : sl;
      enetGmiiRxClk : sl;
      enetGmiiRxDv  : sl;
      enetGmiiRxEr  : sl;
      enetGmiiTxClk : sl;
      enetMdioI     : sl;
      enetExtInitN  : sl;
      enetGmiiRxd   : slv(7 downto 0);
   end record;

   -- Initialization constants
   constant ARM_ETH_RX_INIT_C : ArmEthRxType := (
      enetGmiiCol   => '0',
      enetGmiiCrs   => '0',
      enetGmiiRxClk => '0',
      enetGmiiRxDv  => '0',
      enetGmiiRxEr  => '0',
      enetGmiiTxClk => '0',
      enetMdioI     => '0',
      enetExtInitN  => '0',
      enetGmiiRxd   => (others => '0')
      );

   -- Array
   type ArmEthRxArray is array (natural range<>) of ArmEthRxType;

   function genGp0Config (RCE_DMA_MODE_G : RceDmaModeType) return AxiLiteCrossbarMasterConfigArray;
   function genGp1Config (PCIE_EN_G : boolean) return AxiLiteCrossbarMasterConfigArray;
   
end RceG3Pkg;

package body RceG3Pkg is

   -- GP0 Address Map Generator (0x4000_0000:0x7FFF_FFFF)
   function genGp0Config (RCE_DMA_MODE_G : RceDmaModeType) return AxiLiteCrossbarMasterConfigArray is
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

   -- GP1 Address Map Generator (0x8000_0000:0xBFFF_FFFF)
   function genGp1Config (PCIE_EN_G : boolean) return AxiLiteCrossbarMasterConfigArray is
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

end package body RceG3Pkg;
