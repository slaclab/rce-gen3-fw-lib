#-------------------------------------------------------------------------------
## This file is part of 'SLAC RCE DPM Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE DPM Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
#-------------------------------------------------------------------------------
################
## IO Placements
################

set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS25 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN J10 IOSTANDARD LVCMOS25 } [get_ports { led[1] }]

set_property -dict { PACKAGE_PIN AG10 IOSTANDARD LVCMOS33 PULLTYPE PULLUP } [get_ports { i2cSda }]
set_property -dict { PACKAGE_PIN AH10 IOSTANDARD LVCMOS33 PULLTYPE PULLUP } [get_ports { i2cScl }]

set_property -dict { PACKAGE_PIN W4 } [get_ports { ethTxP }]
set_property -dict { PACKAGE_PIN W3 } [get_ports { ethTxM }]
set_property -dict { PACKAGE_PIN Y2 } [get_ports { ethRxP }]
set_property -dict { PACKAGE_PIN Y1 } [get_ports { ethRxM }]

set_property -dict { PACKAGE_PIN Y6 } [get_ports { ethRefClkP }]
set_property -dict { PACKAGE_PIN Y5 } [get_ports { ethRefClkM }]

set_property -dict { PACKAGE_PIN R4 } [get_ports { dtmToRtmHsP }]
set_property -dict { PACKAGE_PIN R3 } [get_ports { dtmToRtmHsM }]
set_property -dict { PACKAGE_PIN T2 } [get_ports { rtmToDtmHsP }]
set_property -dict { PACKAGE_PIN T1 } [get_ports { rtmToDtmHsM }]

set_property -dict { PACKAGE_PIN E9 IOSTANDARD LVDS } [get_ports dpmClkP[0]]
set_property -dict { PACKAGE_PIN D9 IOSTANDARD LVDS } [get_ports dpmClkM[0]]
set_property -dict { PACKAGE_PIN B5 IOSTANDARD LVDS } [get_ports dpmClkP[1]]
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVDS } [get_ports dpmClkM[1]]
set_property -dict { PACKAGE_PIN C6 IOSTANDARD LVDS } [get_ports dpmClkP[2]]
set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVDS } [get_ports dpmClkM[2]]

set_property -dict { PACKAGE_PIN D4 IOSTANDARD LVDS } [get_ports dtmToRtmLsP[0]]
set_property -dict { PACKAGE_PIN C4 IOSTANDARD LVDS } [get_ports dtmToRtmLsM[0]]
set_property -dict { PACKAGE_PIN C3 IOSTANDARD LVDS } [get_ports dtmToRtmLsP[1]]
set_property -dict { PACKAGE_PIN C2 IOSTANDARD LVDS } [get_ports dtmToRtmLsM[1]]
set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVDS } [get_ports dtmToRtmLsP[2]]
set_property -dict { PACKAGE_PIN D6 IOSTANDARD LVDS } [get_ports dtmToRtmLsM[2]]
set_property -dict { PACKAGE_PIN E5 IOSTANDARD LVDS } [get_ports dtmToRtmLsP[3]]
set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVDS } [get_ports dtmToRtmLsM[3]]
set_property -dict { PACKAGE_PIN G6 IOSTANDARD LVDS } [get_ports dtmToRtmLsP[4]]
set_property -dict { PACKAGE_PIN F6 IOSTANDARD LVDS } [get_ports dtmToRtmLsM[4]]
set_property -dict { PACKAGE_PIN G8 IOSTANDARD LVDS } [get_ports dtmToRtmLsP[5]]
set_property -dict { PACKAGE_PIN F7 IOSTANDARD LVDS } [get_ports dtmToRtmLsM[5]]

set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVDS } [get_ports dpmFbP[0]]
set_property -dict { PACKAGE_PIN F1 IOSTANDARD LVDS } [get_ports dpmFbM[0]]
set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVDS } [get_ports dpmFbP[1]]
set_property -dict { PACKAGE_PIN D1 IOSTANDARD LVDS } [get_ports dpmFbM[1]]
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVDS } [get_ports dpmFbP[2]]
set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVDS } [get_ports dpmFbM[2]]
set_property -dict { PACKAGE_PIN G3 IOSTANDARD LVDS } [get_ports dpmFbP[3]]
set_property -dict { PACKAGE_PIN F3 IOSTANDARD LVDS } [get_ports dpmFbM[3]]
set_property -dict { PACKAGE_PIN E4 IOSTANDARD LVDS } [get_ports dpmFbP[4]]
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVDS } [get_ports dpmFbM[4]]
set_property -dict { PACKAGE_PIN G5 IOSTANDARD LVDS } [get_ports dpmFbP[5]]
set_property -dict { PACKAGE_PIN F5 IOSTANDARD LVDS } [get_ports dpmFbM[5]]
set_property -dict { PACKAGE_PIN C1 IOSTANDARD LVDS } [get_ports dpmFbP[6]]
set_property -dict { PACKAGE_PIN B1 IOSTANDARD LVDS } [get_ports dpmFbM[6]]
set_property -dict { PACKAGE_PIN A2 IOSTANDARD LVDS } [get_ports dpmFbP[7]]
set_property -dict { PACKAGE_PIN A1 IOSTANDARD LVDS } [get_ports dpmFbM[7]]

set_property -dict { PACKAGE_PIN AD15 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[0]]
set_property -dict { PACKAGE_PIN AD14 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[1]]
set_property -dict { PACKAGE_PIN AC14 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[2]]
set_property -dict { PACKAGE_PIN AC13 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[3]]
set_property -dict { PACKAGE_PIN AA13 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[4]]
set_property -dict { PACKAGE_PIN AB13 IOSTANDARD LVCMOS25 } [get_ports bpClkIn[5]]

set_property -dict { PACKAGE_PIN Y14  IOSTANDARD LVCMOS25 } [get_ports bpClkOut[0]]
set_property -dict { PACKAGE_PIN Y13  IOSTANDARD LVCMOS25 } [get_ports bpClkOut[1]]
set_property -dict { PACKAGE_PIN W12  IOSTANDARD LVCMOS25 } [get_ports bpClkOut[2]]
set_property -dict { PACKAGE_PIN W11  IOSTANDARD LVCMOS25 } [get_ports bpClkOut[3]]
set_property -dict { PACKAGE_PIN Y12  IOSTANDARD LVCMOS25 } [get_ports bpClkOut[4]]
set_property -dict { PACKAGE_PIN AA12 IOSTANDARD LVCMOS25 } [get_ports bpClkOut[5]]

set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiP[0]]
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiM[0]]
set_property -dict { PACKAGE_PIN E14 IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiP[1]]
set_property -dict { PACKAGE_PIN E13 IOSTANDARD LVCMOS25 } [get_ports dtmToIpmiM[1]]

####################
# Timing Constraints
####################

create_clock -name ethRefClkP -period 6.400 [get_ports {ethRefClkP}]

create_generated_clock -name clk200 [get_pins {U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name clk312 [get_pins {U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name clk156 [get_pins {U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name clk125 [get_pins {U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3}]
create_generated_clock -name clk62  [get_pins {U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT4}]

create_generated_clock -name dnaClk  [get_pins {U_DtmCore/U_RceG3Top/GEN_SYNTH.U_RceG3AxiCntl/U_DeviceDna/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
set_clock_groups -asynchronous -group [get_clocks {dnaClk}] -group [get_clocks {clk125}] 

# Treat all clocks asynchronous to each-other except for clk62/clk125 (required by GEM/1000BASE-KX)    
set_clock_groups -asynchronous -group [get_clocks {clk62}]  -group [get_clocks {clk156}] -group [get_clocks {clk200}] -group [get_clocks {clk312}]   
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks {clk156}] -group [get_clocks {clk200}] -group [get_clocks {clk312}]  

# 10GBase-KR timing constraints
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -of_objects [get_pins U_DtmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O]]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -of_objects [get_pins U_DtmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O]] 
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -of_objects [get_pins {U_DtmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_DtmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_DtmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2]]
