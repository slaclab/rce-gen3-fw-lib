#-------------------------------------------------------------------------------
#-- Title         : Common DPM Core Constraints
#-- File          : DpmCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for DPM
#-------------------------------------------------------------------------------
## This file is part of 'SLAC RCE DPM Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE DPM Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-------------------------------------------------------------------------------

################
## IO Placements
################

set_property PACKAGE_PIN AA28 [get_ports led[0]]
set_property PACKAGE_PIN AB26 [get_ports led[1]]

set_property PACKAGE_PIN AC29 [get_ports i2cScl]
set_property PACKAGE_PIN AD30 [get_ports i2cSda]

set_property PACKAGE_PIN AH10 [get_ports ethRxP[0]]
set_property PACKAGE_PIN AH9  [get_ports ethRxM[0]]
set_property PACKAGE_PIN AK10 [get_ports ethTxP[0]]
set_property PACKAGE_PIN AK9  [get_ports ethTxM[0]]
set_property PACKAGE_PIN AJ8  [get_ports ethRxP[1]]
set_property PACKAGE_PIN AJ7  [get_ports ethRxM[1]]
set_property PACKAGE_PIN AK6  [get_ports ethTxP[1]]
set_property PACKAGE_PIN AK5  [get_ports ethTxM[1]]
set_property PACKAGE_PIN AG8  [get_ports ethRxP[2]]
set_property PACKAGE_PIN AG7  [get_ports ethRxM[2]]
set_property PACKAGE_PIN AJ4  [get_ports ethTxP[2]]
set_property PACKAGE_PIN AJ3  [get_ports ethTxM[2]]
set_property PACKAGE_PIN AE8  [get_ports ethRxP[3]]
set_property PACKAGE_PIN AE7  [get_ports ethRxM[3]]
set_property PACKAGE_PIN AK2  [get_ports ethTxP[3]]
set_property PACKAGE_PIN AK1  [get_ports ethTxM[3]]

set_property PACKAGE_PIN AA8 [get_ports ethRefClkP]
set_property PACKAGE_PIN AA7 [get_ports ethRefClkM]
set_property PACKAGE_PIN U8  [get_ports locRefClkP]
set_property PACKAGE_PIN U7  [get_ports locRefClkM]
set_property PACKAGE_PIN W8  [get_ports dtmRefClkP]
set_property PACKAGE_PIN W7  [get_ports dtmRefClkM]

set_property PACKAGE_PIN AE28 [get_ports dtmClkP[0]]
set_property PACKAGE_PIN AF28 [get_ports dtmClkM[0]]
set_property PACKAGE_PIN AC28 [get_ports dtmClkP[1]]
set_property PACKAGE_PIN AD28 [get_ports dtmClkM[1]]
set_property PACKAGE_PIN AE25 [get_ports dtmFbP]
set_property PACKAGE_PIN AF25 [get_ports dtmFbM]

set_property PACKAGE_PIN AK27 [get_ports clkSelA[0]]
set_property PACKAGE_PIN AK28 [get_ports clkSelB[0]]
set_property PACKAGE_PIN AH26 [get_ports clkSelA[1]]
set_property PACKAGE_PIN AH27 [get_ports clkSelB[1]]

set_property PACKAGE_PIN AH2 [get_ports dpmToRtmHsP[0]]
set_property PACKAGE_PIN AH1 [get_ports dpmToRtmHsM[0]]
set_property PACKAGE_PIN AH6 [get_ports rtmToDpmHsP[0]]
set_property PACKAGE_PIN AH5 [get_ports rtmToDpmHsM[0]]
set_property PACKAGE_PIN AF2 [get_ports dpmToRtmHsP[1]]
set_property PACKAGE_PIN AF1 [get_ports dpmToRtmHsM[1]]
set_property PACKAGE_PIN AG4 [get_ports rtmToDpmHsP[1]]
set_property PACKAGE_PIN AG3 [get_ports rtmToDpmHsM[1]]
set_property PACKAGE_PIN AE4 [get_ports dpmToRtmHsP[2]]
set_property PACKAGE_PIN AE3 [get_ports dpmToRtmHsM[2]]
set_property PACKAGE_PIN AF6 [get_ports rtmToDpmHsP[2]]
set_property PACKAGE_PIN AF5 [get_ports rtmToDpmHsM[2]]
set_property PACKAGE_PIN AD2 [get_ports dpmToRtmHsP[3]]
set_property PACKAGE_PIN AD1 [get_ports dpmToRtmHsM[3]]
set_property PACKAGE_PIN AD6 [get_ports rtmToDpmHsP[3]]
set_property PACKAGE_PIN AD5 [get_ports rtmToDpmHsM[3]]
set_property PACKAGE_PIN AB2 [get_ports dpmToRtmHsP[4]]
set_property PACKAGE_PIN AB1 [get_ports dpmToRtmHsM[4]]
set_property PACKAGE_PIN AC4 [get_ports rtmToDpmHsP[4]]
set_property PACKAGE_PIN AC3 [get_ports rtmToDpmHsM[4]]
set_property PACKAGE_PIN Y2  [get_ports dpmToRtmHsP[5]]
set_property PACKAGE_PIN Y1  [get_ports dpmToRtmHsM[5]]
set_property PACKAGE_PIN AB6 [get_ports rtmToDpmHsP[5]]
set_property PACKAGE_PIN AB5 [get_ports rtmToDpmHsM[5]]
set_property PACKAGE_PIN W4  [get_ports dpmToRtmHsP[6]]
set_property PACKAGE_PIN W3  [get_ports dpmToRtmHsM[6]]
set_property PACKAGE_PIN Y6  [get_ports rtmToDpmHsP[6]]
set_property PACKAGE_PIN Y5  [get_ports rtmToDpmHsM[6]]
set_property PACKAGE_PIN V2  [get_ports dpmToRtmHsP[7]]
set_property PACKAGE_PIN V1  [get_ports dpmToRtmHsM[7]]
set_property PACKAGE_PIN AA4 [get_ports rtmToDpmHsP[7]]
set_property PACKAGE_PIN AA3 [get_ports rtmToDpmHsM[7]]
set_property PACKAGE_PIN T2  [get_ports dpmToRtmHsP[8]]
set_property PACKAGE_PIN T1  [get_ports dpmToRtmHsM[8]]
set_property PACKAGE_PIN V6  [get_ports rtmToDpmHsP[8]]
set_property PACKAGE_PIN V5  [get_ports rtmToDpmHsM[8]]
set_property PACKAGE_PIN R4  [get_ports dpmToRtmHsP[9]]
set_property PACKAGE_PIN R3  [get_ports dpmToRtmHsM[9]]
set_property PACKAGE_PIN U4  [get_ports rtmToDpmHsP[9]]
set_property PACKAGE_PIN U3  [get_ports rtmToDpmHsM[9]]
set_property PACKAGE_PIN P2  [get_ports dpmToRtmHsP[10]]
set_property PACKAGE_PIN P1  [get_ports dpmToRtmHsM[10]]
set_property PACKAGE_PIN T6  [get_ports rtmToDpmHsP[10]]
set_property PACKAGE_PIN T5  [get_ports rtmToDpmHsM[10]]
set_property PACKAGE_PIN N4  [get_ports dpmToRtmHsP[11]]
set_property PACKAGE_PIN N3  [get_ports dpmToRtmHsM[11]]
set_property PACKAGE_PIN P6  [get_ports rtmToDpmHsP[11]]
set_property PACKAGE_PIN P5  [get_ports rtmToDpmHsM[11]]

set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]

set_property IOSTANDARD LVCMOS25 [get_ports clkSelA]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelB]

set_property IOSTANDARD LVCMOS25 [get_ports led]

set_property IOSTANDARD LVDS_25 [get_ports dtmClkP]
set_property IOSTANDARD LVDS_25 [get_ports dtmClkM]

set_property IOSTANDARD LVDS_25 [get_ports dtmFbP]
set_property IOSTANDARD LVDS_25 [get_ports dtmFbM]


####################
# Timing Constraints
####################


create_clock -name ethRefClkP -period 6.400 [get_ports {ethRefClkP}]
create_clock -name fclk0      -period 10.00 [get_pins {U_DpmCore/U_RceG3Top/U_SimModeDis.U_RceG3Cpu/U_PS7/inst/buffer_fclk_clk_0.FCLK_CLK_0_BUFG/O}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -include_generated_clocks {fclk0}] 

create_generated_clock -name fClk200 [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT1}]
create_generated_clock -name fClk125 [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT2}]
create_generated_clock -name dnaClk  [get_pins {U_DpmCore/U_RceG3Top/U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}] 
create_generated_clock -name dnaClkL [get_pins {U_DpmCore/U_RceG3Top/U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}] 

create_generated_clock -name clk200 [get_pins {U_DpmCore/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name clk312 [get_pins {U_DpmCore/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name clk156 [get_pins {U_DpmCore/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name clk125 [get_pins {U_DpmCore/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3}]
create_generated_clock -name clk62  [get_pins {U_DpmCore/U_MMCM/MmcmGen.U_Mmcm/CLKOUT4}]

set_clock_groups -asynchronous \
    -group [get_clocks {dnaClk}] \
    -group [get_clocks {dnaClkL}] \
    -group [get_clocks {fclk0}] \
    -group [get_clocks {fClk200}] \
    -group [get_clocks {fClk125}] 
    
set_clock_groups -asynchronous -group [get_clocks {clk200}] -group [get_clocks {clk312}] 
set_clock_groups -asynchronous -group [get_clocks {clk200}] -group [get_clocks {clk156}] 
set_clock_groups -asynchronous -group [get_clocks {clk200}] -group [get_clocks {clk125}] 
set_clock_groups -asynchronous -group [get_clocks {clk200}] -group [get_clocks {clk62}] 
set_clock_groups -asynchronous -group [get_clocks {clk200}] -group [get_clocks {fClk125}] 
set_clock_groups -asynchronous -group [get_clocks {clk200}] -group [get_clocks {fClk200}] 

create_clock -name xauiClk  -period  6.400 [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_XAUI.U_Eth/U_IpCore/U0/gt_wrapper_i/gt0_XauiGtx7Core_gt_wrapper_i/gtxe2_i/TXOUTCLK}]
set_clock_groups -asynchronous -group [get_clocks {xauiClk}] -group [get_clocks {clk200}] 
set_clock_groups -asynchronous -group [get_clocks {xauiClk}] -group [get_clocks {fClk200}] 
set_clock_groups -asynchronous -group [get_clocks {xauiClk}] -group [get_clocks {fClk125}] 
set_clock_groups -asynchronous -group [get_clocks {clk156}]  -group [get_clocks {ethRefClkP}] 

set_clock_groups -asynchronous -group [get_clocks {ethRefClkP}] -group [get_clocks {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/U0/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK}]                               
set_clock_groups -asynchronous -group [get_clocks {clk156}]     -group [get_clocks {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/U0/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i/TXOUTCLK}]                               
