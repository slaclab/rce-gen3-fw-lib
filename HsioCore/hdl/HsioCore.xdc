#-------------------------------------------------------------------------------
## This file is part of 'SLAC RCE DPM Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE DPM Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
#-------------------------------------------------------------------------------

#########################################################
# Pin Locations. All Defined Here
#########################################################

set_property -dict { PACKAGE_PIN AA19 IOSTANDARD LVCMOS25 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN T15  IOSTANDARD LVCMOS25 } [get_ports { led[1] }]

set_property -dict { PACKAGE_PIN AB13 IOSTANDARD LVCMOS25 PULLTYPE PULLUP } [get_ports { i2cScl }]
set_property -dict { PACKAGE_PIN AA10 IOSTANDARD LVCMOS25 PULLTYPE PULLUP } [get_ports { i2cSda }]

# SFP
set_property PACKAGE_PIN W2 [get_ports dtmToRtmHsP]
set_property PACKAGE_PIN W1 [get_ports dtmToRtmHsM]
set_property PACKAGE_PIN V4 [get_ports rtmToDtmHsP]
set_property PACKAGE_PIN V3 [get_ports rtmToDtmHsM]

# HSIO traces
set_property PACKAGE_PIN AB4 [get_ports dtmToRtmHsP]
set_property PACKAGE_PIN AB3 [get_ports dtmToRtmHsM]
set_property PACKAGE_PIN AA6 [get_ports rtmToDtmHsP]
set_property PACKAGE_PIN AA5 [get_ports rtmToDtmHsM]

set_property PACKAGE_PIN W6  [get_ports locRefClk1P]
set_property PACKAGE_PIN W5  [get_ports locRefClk1M]

set_property PACKAGE_PIN U6  [get_ports locRefClk0P]
set_property PACKAGE_PIN U5  [get_ports locRefClk0M]

set_property -dict { PACKAGE_PIN U9   IOSTANDARD LVDS_25 } [get_ports dpmClkP[2]]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVDS_25 } [get_ports dpmClkM[2]]
set_property -dict { PACKAGE_PIN W9   IOSTANDARD LVDS_25 } [get_ports dpmClkP[1]]
set_property -dict { PACKAGE_PIN Y8   IOSTANDARD LVDS_25 } [get_ports dpmClkM[1]]
set_property -dict { PACKAGE_PIN AA14 IOSTANDARD LVDS_25 } [get_ports dpmClkP[0]]
set_property -dict { PACKAGE_PIN AB14 IOSTANDARD LVDS_25 } [get_ports dpmClkM[0]]

set_property -dict { PACKAGE_PIN V8  IOSTANDARD LVDS_25 } [get_ports busyOutP]; # dtmToRtmLsP[5]
set_property -dict { PACKAGE_PIN W8  IOSTANDARD LVDS_25 } [get_ports busyOutM]; # dtmToRtmLsM[4]
# set_property -dict { PACKAGE_PIN U10 IOSTANDARD LVDS_25 } [get_ports dtmToRtmLsP[4]]
# set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVDS_25 } [get_ports dtmToRtmLsM[4]]
set_property -dict { PACKAGE_PIN T20 IOSTANDARD LVDS_25 } [get_ports sdInP]; # dtmToRtmLsP[3]
set_property -dict { PACKAGE_PIN U20 IOSTANDARD LVDS_25 } [get_ports sdInM]; # dtmToRtmLsM[3]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVDS_25 } [get_ports lolInP]; # dtmToRtmLsP[2]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVDS_25 } [get_ports lolInM]; # dtmToRtmLsM[2]
# set_property -dict { PACKAGE_PIN R19 IOSTANDARD LVDS_25 } [get_ports dtmToRtmLsP[1]]
# set_property -dict { PACKAGE_PIN T19 IOSTANDARD LVDS_25 } [get_ports dtmToRtmLsM[1]]
# set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVDS_25 } [get_ports dtmToRtmLsP[0]]
# set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVDS_25 } [get_ports dtmToRtmLsM[0]]LsM[0]]

set_property -dict { PACKAGE_PIN R22  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbP[3]]
set_property -dict { PACKAGE_PIN T22  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbM[3]]
set_property -dict { PACKAGE_PIN N21  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbP[2]]
set_property -dict { PACKAGE_PIN N22  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbM[2]]
set_property -dict { PACKAGE_PIN W19  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbP[1]]
set_property -dict { PACKAGE_PIN W20  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbM[1]]
set_property -dict { PACKAGE_PIN V21  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbP[0]]
set_property -dict { PACKAGE_PIN V22  IOSTANDARD LVDS_25 DIFF_TERM_ADV TERM_100 } [get_ports idpmFbM[0]]
set_property -dict { PACKAGE_PIN W21  IOSTANDARD LVDS_25 } [get_ports odpmFbP[3]]
set_property -dict { PACKAGE_PIN Y22  IOSTANDARD LVDS_25 } [get_ports odpmFbM[3]]
set_property -dict { PACKAGE_PIN AA20 IOSTANDARD LVDS_25 } [get_ports odpmFbP[2]]
set_property -dict { PACKAGE_PIN AB20 IOSTANDARD LVDS_25 } [get_ports odpmFbM[2]]
set_property -dict { PACKAGE_PIN Y21  IOSTANDARD LVDS_25 } [get_ports odpmFbP[1]]
set_property -dict { PACKAGE_PIN AA21 IOSTANDARD LVDS_25 } [get_ports odpmFbM[1]]
set_property -dict { PACKAGE_PIN AA22 IOSTANDARD LVDS_25 } [get_ports odpmFbP[0]]
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVDS_25 } [get_ports odpmFbM[0]]

set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS25 } [get_ports clkSelA]
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS25 } [get_ports clkSelB]

set_property -dict { PACKAGE_PIN AA12 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[5]]
set_property -dict { PACKAGE_PIN Y16  IOSTANDARD LVCMOS25 } [get_ports bpClkIn[4]]
set_property -dict { PACKAGE_PIN W11  IOSTANDARD LVCMOS25 } [get_ports bpClkIn[3]]
set_property -dict { PACKAGE_PIN Y14  IOSTANDARD LVCMOS25 } [get_ports bpClkIn[2]]
set_property -dict { PACKAGE_PIN Y12  IOSTANDARD LVCMOS25 } [get_ports bpClkIn[1]]
set_property -dict { PACKAGE_PIN W14  IOSTANDARD LVCMOS25 } [get_ports bpClkIn[0]]

set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[5]]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[4]]
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[3]]
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[2]]
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[1]]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[0]]

set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiP[1]]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiM[1]]
set_property -dict { PACKAGE_PIN Y9  IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiP[0]]
set_property -dict { PACKAGE_PIN AA9 IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiM[0]]

set_property -dict { PACKAGE_PIN F2 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxCtrl[1]]
set_property -dict { PACKAGE_PIN J5 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxClk[1]]
set_property -dict { PACKAGE_PIN J3 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataA[1]]
set_property -dict { PACKAGE_PIN H3 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataB[1]]
set_property -dict { PACKAGE_PIN H2 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataC[1]]
set_property -dict { PACKAGE_PIN H1 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataD[1]]
set_property -dict { PACKAGE_PIN F4 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxCtrl[1]]
set_property -dict { PACKAGE_PIN F5 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxClk[1]]
set_property -dict { PACKAGE_PIN H7 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataA[1]]
set_property -dict { PACKAGE_PIN G7 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataB[1]]
set_property -dict { PACKAGE_PIN F7 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataC[1]]
set_property -dict { PACKAGE_PIN F6 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataD[1]]
set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS18 SLEW FAST } [get_ports ethMdc[1]]
set_property -dict { PACKAGE_PIN J6 IOSTANDARD LVCMOS18 } [get_ports ethMio[1]]
set_property -dict { PACKAGE_PIN H6 IOSTANDARD LVCMOS18 SLEW FAST } [get_ports ethResetL[1]]

set_property -dict { PACKAGE_PIN N3 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxCtrl[0]]
set_property -dict { PACKAGE_PIN M5 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxClk[0]]
set_property -dict { PACKAGE_PIN N2 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataA[0]]
set_property -dict { PACKAGE_PIN L2 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataB[0]]
set_property -dict { PACKAGE_PIN L1 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataC[0]]
set_property -dict { PACKAGE_PIN P1 IOSTANDARD HSTL_I_DCI_18 } [get_ports ethRxDataD[0]]
set_property -dict { PACKAGE_PIN L7 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxCtrl[0]]
set_property -dict { PACKAGE_PIN M4 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxClk[0]]
set_property -dict { PACKAGE_PIN L6 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataA[0]]
set_property -dict { PACKAGE_PIN P4 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataB[0]]
set_property -dict { PACKAGE_PIN M2 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataC[0]]
set_property -dict { PACKAGE_PIN K3 IOSTANDARD HSTL_I_DCI_18 SLEW FAST } [get_ports ethTxDataD[0]]
set_property -dict { PACKAGE_PIN K7 IOSTANDARD LVCMOS18 SLEW FAST } [get_ports ethMdc[0]]
set_property -dict { PACKAGE_PIN K6 IOSTANDARD LVCMOS18 } [get_ports ethMio[0]]
set_property -dict { PACKAGE_PIN N5 IOSTANDARD LVCMOS18 SLEW FAST } [get_ports ethResetL[0]]

####################
# Timing Constraints
####################

# CPU Clock
create_clock -name fclk0 -period 10.0 [get_pins {U_HsioCore/U_RceG3Top/GEN_SYNTH.U_RceG3Cpu/U_PS7/inst/PS7_i/FCLKCLK[0]}]

create_generated_clock -name clk200 [get_pins {U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name clk312 [get_pins {U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name clk156 [get_pins {U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name clk125 [get_pins {U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3}]
create_generated_clock -name clk62  [get_pins {U_HsioCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT4}]

create_generated_clock -name dnaClk  [get_pins {U_HsioCore/U_RceG3Top/GEN_SYNTH.U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/BUFR_Inst/O}] 
create_generated_clock -name dnaClkL [get_pins {U_HsioCore/U_RceG3Top/GEN_SYNTH.U_RceG3AxiCntl/U_DeviceDna/GEN_7SERIES.DeviceDna7Series_Inst/DNA_CLK_INV_BUFR/O}] 
set_clock_groups -asynchronous -group [get_clocks {dnaClk}] -group [get_clocks {dnaClkL}] -group [get_clocks {clk125}] 

# Treat all clocks asynchronous to each-other except for clk62/clk125 (required by GEM/1000BASE-KX)    
set_clock_groups -asynchronous -group [get_clocks {clk62}]  -group [get_clocks {clk156}] -group [get_clocks {clk200}] -group [get_clocks {clk312}]   
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks {clk156}] -group [get_clocks {clk200}] -group [get_clocks {clk312}]  

# GMII-To-RGMII 
create_clock -name ethRxClk0 -period 8.0 [get_ports ethRxClk[0]]
create_clock -name ethRxClk1 -period 8.0 [get_ports ethRxClk[1]]

set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rx_ctl          }]
set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rx_ctl          }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiCore_Inst/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *i_GmiiToRgmiiCore_idelayctrl}]

set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rx_ctl          }]
set_property IDELAY_VALUE  "16"   [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rxd*            }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rx_ctl          }]
set_property IODELAY_GROUP "GmiiToRgmiiGrpA" [get_cells -hier -filter {name =~ *GmiiToRgmiiSlave_Inst/*delay_rgmii_rxd*            }]
