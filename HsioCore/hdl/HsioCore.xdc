#-------------------------------------------------------------------------------
#-- Title         : Common DTM Core Constraints
#-- File          : HsioCore.xdc
#-- Author        : Ryan Herbst, rherbst@slac.stanford.edu
#-- Created       : 11/14/2013
#-------------------------------------------------------------------------------
#-- Description:
#-- Common top level constraints for DTM
#-------------------------------------------------------------------------------
## This file is part of 'SLAC RCE DTM Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE DTM Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
#-------------------------------------------------------------------------------
#-- Modification history:
#-- 11/14/2013: created.
#-- 01/20/2014: Added GMII-To-RGMII Switch
#-------------------------------------------------------------------------------

# CPU Clock
set fclk0Pin [get_pins U_HsioCore/U_RceG3Top/U_SimModeDis.U_RceG3Cpu/U_PS7/inst/PS7_i/FCLKCLK[0]]
create_clock -name fclk0 -period 10 ${fclk0Pin}

# Arm Core Clocks
create_generated_clock -name dmaClk -source ${fclk0Pin} \
    -multiply_by 2 [get_pins U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT0]

create_generated_clock -name sysClk200 -source ${fclk0Pin} \
    -multiply_by 2 [get_pins U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT1]

create_generated_clock -name sysClk125 -source ${fclk0Pin} \
    -multiply_by 5 -divide_by 4 [get_pins U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_ClockGen/CLKOUT2]

# Arm Core clocks are treated as asynchronous to each other
set_clock_groups -asynchronous \
    -group [get_clocks fclk0] \
    -group [get_clocks -include_generated_clocks dmaClk] \
    -group [get_clocks -include_generated_clocks sysClk200] \
    -group [get_clocks -include_generated_clocks sysClk125] \

create_clock -name ethRxClk0 -period 8.0 [get_ports ethRxClk[0]]
create_clock -name ethRxClk1 -period 8.0 [get_ports ethRxClk[1]]

# DNA Primitive Clock
create_clock -period 64.000 -name dnaClk [get_pins  {U_HsioCore/U_RceG3Top/U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}]
set_clock_groups -asynchronous \
    -group [get_clocks dnaClk] \
    -group [get_clocks sysClk125] \
    -group [get_clocks -of_objects [get_pins U_HsioCore/U_RceG3Top/U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O]]

# GMII-To-RGMII IODELAY Groups
set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rx_ctl          }]
set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rx_ctl          }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *i_GmiiToRgmiiCore_idelayctrl}]

set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rx_ctl          }]
set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rx_ctl          }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rxd*            }]

#########################################################
# Pin Locations. All Defined Here
#########################################################

set_property PACKAGE_PIN AA19 [get_ports led[0]]
set_property PACKAGE_PIN T15  [get_ports led[1]]

set_property PACKAGE_PIN AB13 [get_ports i2cScl]
set_property PACKAGE_PIN AA10 [get_ports i2cSda]

#SFP
#set_property PACKAGE_PIN W2 [get_ports dtmToRtmHsP]
#set_property PACKAGE_PIN W1 [get_ports dtmToRtmHsM]
#set_property PACKAGE_PIN V4 [get_ports rtmToDtmHsP]
#set_property PACKAGE_PIN V3 [get_ports rtmToDtmHsM]
#HSIO traces
set_property PACKAGE_PIN AB4 [get_ports dtmToRtmHsP]
set_property PACKAGE_PIN AB3 [get_ports dtmToRtmHsM]
set_property PACKAGE_PIN AA6 [get_ports rtmToDtmHsP]
set_property PACKAGE_PIN AA5 [get_ports rtmToDtmHsM]

set_property PACKAGE_PIN W6  [get_ports locRefClk1P]
set_property PACKAGE_PIN W5  [get_ports locRefClk1M]

set_property PACKAGE_PIN U6  [get_ports locRefClk0P]
set_property PACKAGE_PIN U5  [get_ports locRefClk0M]

set_property PACKAGE_PIN U9   [get_ports dpmClkP[2]]
set_property PACKAGE_PIN U8   [get_ports dpmClkM[2]]
set_property PACKAGE_PIN W9   [get_ports dpmClkP[1]]
set_property PACKAGE_PIN Y8   [get_ports dpmClkM[1]]
set_property PACKAGE_PIN AA14 [get_ports dpmClkP[0]]
set_property PACKAGE_PIN AB14 [get_ports dpmClkM[0]]

set_property PACKAGE_PIN V8  [get_ports busyOutP]
set_property PACKAGE_PIN W8  [get_ports busyOutM]
set_property IOSTANDARD LVDS_25  [get_ports busyOutP]
set_property IOSTANDARD LVDS_25  [get_ports busyOutM]
set_property PACKAGE_PIN T20  [get_ports sdInP]
set_property PACKAGE_PIN U20  [get_ports sdInM]
set_property IOSTANDARD LVDS_25  [get_ports sdInP]
set_property IOSTANDARD LVDS_25  [get_ports sdInM]
set_property PACKAGE_PIN R17  [get_ports lolInP]
set_property PACKAGE_PIN R18  [get_ports lolInM]
set_property IOSTANDARD LVDS_25  [get_ports lolInP]
set_property IOSTANDARD LVDS_25  [get_ports lolInM]

#set_property PACKAGE_PIN V8  [get_ports dtmToRtmLsP[5]]
#set_property PACKAGE_PIN W8  [get_ports dtmToRtmLsM[5]]
#set_property PACKAGE_PIN U10 [get_ports dtmToRtmLsP[4]]
#set_property PACKAGE_PIN V10 [get_ports dtmToRtmLsM[4]]
#set_property PACKAGE_PIN T20 [get_ports dtmToRtmLsP[3]]
#set_property PACKAGE_PIN U20 [get_ports dtmToRtmLsM[3]]
#set_property PACKAGE_PIN R17 [get_ports dtmToRtmLsP[2]]
#set_property PACKAGE_PIN R18 [get_ports dtmToRtmLsM[2]]
#set_property PACKAGE_PIN R19 [get_ports dtmToRtmLsP[1]]
#set_property PACKAGE_PIN T19 [get_ports dtmToRtmLsM[1]]
#set_property PACKAGE_PIN T17 [get_ports dtmToRtmLsP[0]]
#set_property PACKAGE_PIN U17 [get_ports dtmToRtmLsM[0]]

set_property PACKAGE_PIN R22  [get_ports idpmFbP[3]]
set_property PACKAGE_PIN T22  [get_ports idpmFbM[3]]
set_property PACKAGE_PIN N21  [get_ports idpmFbP[2]]
set_property PACKAGE_PIN N22  [get_ports idpmFbM[2]]
set_property PACKAGE_PIN W19  [get_ports idpmFbP[1]]
set_property PACKAGE_PIN W20  [get_ports idpmFbM[1]]
set_property PACKAGE_PIN V21  [get_ports idpmFbP[0]]
set_property PACKAGE_PIN V22  [get_ports idpmFbM[0]]
set_property PACKAGE_PIN W21  [get_ports odpmFbP[3]]
set_property PACKAGE_PIN Y22  [get_ports odpmFbM[3]]
set_property PACKAGE_PIN AA20 [get_ports odpmFbP[2]]
set_property PACKAGE_PIN AB20 [get_ports odpmFbM[2]]
set_property PACKAGE_PIN Y21  [get_ports odpmFbP[1]]
set_property PACKAGE_PIN AA21 [get_ports odpmFbM[1]]
set_property PACKAGE_PIN AA22 [get_ports odpmFbP[0]]
set_property PACKAGE_PIN AB22 [get_ports odpmFbM[0]]

set_property PACKAGE_PIN W18 [get_ports clkSelA]
set_property PACKAGE_PIN V17 [get_ports clkSelB]


set_property PACKAGE_PIN AA12 [get_ports bpClkIn[5]]
set_property PACKAGE_PIN Y16  [get_ports bpClkIn[4]]
set_property PACKAGE_PIN W11  [get_ports bpClkIn[3]]
set_property PACKAGE_PIN Y14  [get_ports bpClkIn[2]]
set_property PACKAGE_PIN Y12  [get_ports bpClkIn[1]]
set_property PACKAGE_PIN W14  [get_ports bpClkIn[0]]

set_property PACKAGE_PIN T12 [get_ports bpClkOut[5]]
set_property PACKAGE_PIN V16 [get_ports bpClkOut[4]]
set_property PACKAGE_PIN U13 [get_ports bpClkOut[3]]
set_property PACKAGE_PIN U15 [get_ports bpClkOut[2]]
set_property PACKAGE_PIN V12 [get_ports bpClkOut[1]]
set_property PACKAGE_PIN T11 [get_ports bpClkOut[0]]

set_property PACKAGE_PIN T10 [get_ports dtmToIpmiP[1]]
set_property PACKAGE_PIN T9  [get_ports dtmToIpmiM[1]]
set_property PACKAGE_PIN Y9  [get_ports dtmToIpmiP[0]]
set_property PACKAGE_PIN AA9 [get_ports dtmToIpmiM[0]]

set_property PACKAGE_PIN F2 [get_ports ethRxCtrl[1]]
set_property PACKAGE_PIN J5 [get_ports ethRxClk[1]]
set_property PACKAGE_PIN J3 [get_ports ethRxDataA[1]]
set_property PACKAGE_PIN H3 [get_ports ethRxDataB[1]]
set_property PACKAGE_PIN H2 [get_ports ethRxDataC[1]]
set_property PACKAGE_PIN H1 [get_ports ethRxDataD[1]]
set_property PACKAGE_PIN F4 [get_ports ethTxCtrl[1]]
set_property PACKAGE_PIN F5 [get_ports ethTxClk[1]]
set_property PACKAGE_PIN H7 [get_ports ethTxDataA[1]]
set_property PACKAGE_PIN G7 [get_ports ethTxDataB[1]]
set_property PACKAGE_PIN F7 [get_ports ethTxDataC[1]]
set_property PACKAGE_PIN F6 [get_ports ethTxDataD[1]]
set_property PACKAGE_PIN G4 [get_ports ethMdc[1]]
set_property PACKAGE_PIN J6 [get_ports ethMio[1]]
set_property PACKAGE_PIN H6 [get_ports ethResetL[1]]

set_property PACKAGE_PIN N3 [get_ports ethRxCtrl[0]]
set_property PACKAGE_PIN M5 [get_ports ethRxClk[0]]
set_property PACKAGE_PIN N2 [get_ports ethRxDataA[0]]
set_property PACKAGE_PIN L2 [get_ports ethRxDataB[0]]
set_property PACKAGE_PIN L1 [get_ports ethRxDataC[0]]
set_property PACKAGE_PIN P1 [get_ports ethRxDataD[0]]
set_property PACKAGE_PIN L7 [get_ports ethTxCtrl[0]]
set_property PACKAGE_PIN M4 [get_ports ethTxClk[0]]
set_property PACKAGE_PIN L6 [get_ports ethTxDataA[0]]
set_property PACKAGE_PIN P4 [get_ports ethTxDataB[0]]
set_property PACKAGE_PIN M2 [get_ports ethTxDataC[0]]
set_property PACKAGE_PIN K3 [get_ports ethTxDataD[0]]
set_property PACKAGE_PIN K7 [get_ports ethMdc[0]]
set_property PACKAGE_PIN K6 [get_ports ethMio[0]]
set_property PACKAGE_PIN N5 [get_ports ethResetL[0]]

set_property slew FAST [get_ports [list {ethTxCtrl[*]} {ethTxClk[*]} {ethTxDataA[*]} {ethTxDataB[*]} {ethTxDataC[*]} {ethTxDataD[*]} {ethMdc[*]}  {ethResetL[*]} ]]

#########################################################
# Common IO Types
#########################################################

set_property IOSTANDARD LVCMOS25 [get_ports i2cScl]
set_property IOSTANDARD LVCMOS25 [get_ports i2cSda]


set_property IOSTANDARD LVCMOS25 [get_ports clkSelA]
set_property IOSTANDARD LVCMOS25 [get_ports clkSelB]

set_property IOSTANDARD LVCMOS25 [get_ports bpClkIn]
set_property IOSTANDARD LVCMOS25 [get_ports bpClkOut]

set_property IOSTANDARD LVCMOS25 [get_ports dtmToIpmiP]
set_property IOSTANDARD LVCMOS25 [get_ports dtmToIpmiM]

set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxCtrl]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxClk]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataA]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataB]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataC]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethRxDataD]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxCtrl]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxClk]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataA]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataB]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataC]
set_property IOSTANDARD HSTL_I_DCI_18   [get_ports ethTxDataD]
set_property IOSTANDARD LVCMOS18        [get_ports ethMdc]
set_property IOSTANDARD LVCMOS18        [get_ports ethMio]
set_property IOSTANDARD LVCMOS18        [get_ports ethResetL]

set_property IOSTANDARD LVDS_25         [get_ports dpmClkP]
set_property IOSTANDARD LVDS_25         [get_ports dpmClkM]
set_property IOSTANDARD LVDS_25         [get_ports idpmFbP]
set_property IOSTANDARD LVDS_25         [get_ports idpmFbM]
set_property IOSTANDARD LVDS_25         [get_ports odpmFbP]
set_property IOSTANDARD LVDS_25         [get_ports odpmFbM]
set_property IOSTANDARD LVCMOS25        [get_ports led]


#########################################################
# Top Level IO Types, To Be Defined At Top Level
#########################################################

#set_property IOSTANDARD LVDS_25 [get_ports dtmToRtmLsP]
#set_property IOSTANDARD LVDS_25 [get_ports dtmToRtmLsM]


