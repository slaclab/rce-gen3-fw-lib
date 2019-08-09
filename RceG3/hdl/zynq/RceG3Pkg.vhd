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

end RceG3Pkg;

