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

set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 PULLTYPE PULLUP } [get_ports { i2cSda }]
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 PULLTYPE PULLUP } [get_ports { i2cScl }]

set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS25 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS25 } [get_ports { led[1] }]

set_property -dict { PACKAGE_PIN B14 IOSTANDARD LVCMOS25 } [get_ports { clkSelA[0] }]
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS25 } [get_ports { clkSelA[1] }]

set_property -dict { PACKAGE_PIN B13 IOSTANDARD LVCMOS25 } [get_ports { clkSelB[0] }]
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS25 } [get_ports { clkSelB[1] }]

set_property -dict { PACKAGE_PIN AG6 IOSTANDARD LVDS } [get_ports { dtmFbP }]
set_property -dict { PACKAGE_PIN AG5 IOSTANDARD LVDS } [get_ports { dtmFbM }]

set_property -dict { PACKAGE_PIN AG8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dtmClkP[0] }]
set_property -dict { PACKAGE_PIN AH8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dtmClkM[0] }]

set_property -dict { PACKAGE_PIN AH6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dtmClkP[1] }]
set_property -dict { PACKAGE_PIN AJ6 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dtmClkM[1] }]

set_property -dict { PACKAGE_PIN L8 } [get_ports { dtmRefClkP }]
set_property -dict { PACKAGE_PIN L7 } [get_ports { dtmRefClkM }]

set_property -dict { PACKAGE_PIN J8 } [get_ports { locRefClkP }]
set_property -dict { PACKAGE_PIN J7 } [get_ports { locRefClkM }]

set_property -dict { PACKAGE_PIN G27 } [get_ports { ethTxP[0] }]
set_property -dict { PACKAGE_PIN G28 } [get_ports { ethTxM[0] }]
set_property -dict { PACKAGE_PIN H29 } [get_ports { ethRxP[0] }]
set_property -dict { PACKAGE_PIN H30 } [get_ports { ethRxM[0] }]

set_property -dict { PACKAGE_PIN E27 } [get_ports { ethTxP[1] }]
set_property -dict { PACKAGE_PIN E28 } [get_ports { ethTxM[1] }]
set_property -dict { PACKAGE_PIN F29 } [get_ports { ethRxP[1] }]
set_property -dict { PACKAGE_PIN F30 } [get_ports { ethRxM[1] }]

set_property -dict { PACKAGE_PIN C27 } [get_ports { ethTxP[2] }]
set_property -dict { PACKAGE_PIN C28 } [get_ports { ethTxM[2] }]
set_property -dict { PACKAGE_PIN D29 } [get_ports { ethRxP[2] }]
set_property -dict { PACKAGE_PIN D30 } [get_ports { ethRxM[2] }]

set_property -dict { PACKAGE_PIN A27 } [get_ports { ethTxP[3] }]
set_property -dict { PACKAGE_PIN A28 } [get_ports { ethTxM[3] }]
set_property -dict { PACKAGE_PIN B29 } [get_ports { ethRxP[3] }]
set_property -dict { PACKAGE_PIN B30 } [get_ports { ethRxM[3] }]

set_property -dict { PACKAGE_PIN F25 } [get_ports { ethRefClkP }]
set_property -dict { PACKAGE_PIN F26 } [get_ports { ethRefClkM }]

set_property -dict { PACKAGE_PIN P6 } [get_ports { dpmToRtmHsP[0] }]
set_property -dict { PACKAGE_PIN P5 } [get_ports { dpmToRtmHsM[0] }]

set_property -dict { PACKAGE_PIN R4 } [get_ports { rtmToDpmHsP[0] }]
set_property -dict { PACKAGE_PIN R3 } [get_ports { rtmToDpmHsM[0] }]

set_property -dict { PACKAGE_PIN N4 } [get_ports { dpmToRtmHsP[1] }]
set_property -dict { PACKAGE_PIN N3 } [get_ports { dpmToRtmHsM[1] }]

set_property -dict { PACKAGE_PIN P2 } [get_ports { rtmToDpmHsP[1] }]
set_property -dict { PACKAGE_PIN P1 } [get_ports { rtmToDpmHsM[1] }]

set_property -dict { PACKAGE_PIN M6 } [get_ports { dpmToRtmHsP[2] }]
set_property -dict { PACKAGE_PIN M5 } [get_ports { dpmToRtmHsM[2] }]

set_property -dict { PACKAGE_PIN M2 } [get_ports { rtmToDpmHsP[2] }]
set_property -dict { PACKAGE_PIN M1 } [get_ports { rtmToDpmHsM[2] }]

set_property -dict { PACKAGE_PIN K6 } [get_ports { dpmToRtmHsP[3] }]
set_property -dict { PACKAGE_PIN K5 } [get_ports { dpmToRtmHsM[3] }]

set_property -dict { PACKAGE_PIN L4 } [get_ports { rtmToDpmHsP[3] }]
set_property -dict { PACKAGE_PIN L3 } [get_ports { rtmToDpmHsM[3] }]

set_property -dict { PACKAGE_PIN J4 } [get_ports { dpmToRtmHsP[4] }]
set_property -dict { PACKAGE_PIN J3 } [get_ports { dpmToRtmHsM[4] }]

set_property -dict { PACKAGE_PIN K2 } [get_ports { rtmToDpmHsP[4] }]
set_property -dict { PACKAGE_PIN K1 } [get_ports { rtmToDpmHsM[4] }]

set_property -dict { PACKAGE_PIN H6 } [get_ports { dpmToRtmHsP[5] }]
set_property -dict { PACKAGE_PIN H5 } [get_ports { dpmToRtmHsM[5] }]

set_property -dict { PACKAGE_PIN H2 } [get_ports { rtmToDpmHsP[5] }]
set_property -dict { PACKAGE_PIN H1 } [get_ports { rtmToDpmHsM[5] }]

set_property -dict { PACKAGE_PIN F6 } [get_ports { dpmToRtmHsP[6] }]
set_property -dict { PACKAGE_PIN F5 } [get_ports { dpmToRtmHsM[6] }]

set_property -dict { PACKAGE_PIN G4 } [get_ports { rtmToDpmHsP[6] }]
set_property -dict { PACKAGE_PIN G3 } [get_ports { rtmToDpmHsM[6] }]

set_property -dict { PACKAGE_PIN E4 } [get_ports { dpmToRtmHsP[7] }]
set_property -dict { PACKAGE_PIN E3 } [get_ports { dpmToRtmHsM[7] }]

set_property -dict { PACKAGE_PIN F2 } [get_ports { rtmToDpmHsP[7] }]
set_property -dict { PACKAGE_PIN F1 } [get_ports { rtmToDpmHsM[7] }]

set_property -dict { PACKAGE_PIN D6 } [get_ports { dpmToRtmHsP[8] }]
set_property -dict { PACKAGE_PIN D5 } [get_ports { dpmToRtmHsM[8] }]

set_property -dict { PACKAGE_PIN D2 } [get_ports { rtmToDpmHsP[8] }]
set_property -dict { PACKAGE_PIN D1 } [get_ports { rtmToDpmHsM[8] }]

set_property -dict { PACKAGE_PIN C8 } [get_ports { dpmToRtmHsP[9] }]
set_property -dict { PACKAGE_PIN C7 } [get_ports { dpmToRtmHsM[9] }]

set_property -dict { PACKAGE_PIN C4 } [get_ports { rtmToDpmHsP[9] }]
set_property -dict { PACKAGE_PIN C3 } [get_ports { rtmToDpmHsM[9] }]

set_property -dict { PACKAGE_PIN B6 } [get_ports { dpmToRtmHsP[10] }]
set_property -dict { PACKAGE_PIN B5 } [get_ports { dpmToRtmHsM[10] }]

set_property -dict { PACKAGE_PIN B2 } [get_ports { rtmToDpmHsP[10] }]
set_property -dict { PACKAGE_PIN B1 } [get_ports { rtmToDpmHsM[10] }]

set_property -dict { PACKAGE_PIN A8 } [get_ports { dpmToRtmHsP[11] }]
set_property -dict { PACKAGE_PIN A7 } [get_ports { dpmToRtmHsM[11] }]

set_property -dict { PACKAGE_PIN A4 } [get_ports { rtmToDpmHsP[11] }]
set_property -dict { PACKAGE_PIN A3 } [get_ports { rtmToDpmHsM[11] }]

####################
# Timing Constraints
####################

create_clock -name ethRefClkP -period 6.400 [get_ports {ethRefClkP}]
create_clock -name locRefClkP -period 6.400 [get_ports {locRefClkP}]

create_generated_clock -name clk200 [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name clk312 [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name clk156 [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name clk125 [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3}]
create_generated_clock -name clk62  [get_pins {U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT4}]

create_generated_clock -name dnaClk  [get_pins {U_DpmCore/U_RceG3Top/GEN_SYNTH.U_RceG3AxiCntl/U_DeviceDna/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
set_clock_groups -asynchronous -group [get_clocks {dnaClk}] -group [get_clocks {clk125}] 

# Treat all clocks asynchronous to each-other except for clk62/clk125 (required by GEM/1000BASE-KX)    
set_clock_groups -asynchronous -group [get_clocks {clk62}]  -group [get_clocks {clk156}] -group [get_clocks {clk200}] -group [get_clocks {clk312}]   
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks {clk156}] -group [get_clocks {clk200}] -group [get_clocks {clk312}]  

# 10GBase-KR timing constraints
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -of_objects [get_pins U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_core_gtwiz_userclk_tx_inst_0/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O]]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -of_objects [get_pins U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_core_gtwiz_userclk_rx_inst_0/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O]] 
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_10GBase.U_Eth/U_IpCore/inst/i_TenGigEthGthUltraScale156p25MHzCore_gt/inst/gen_gtwizard_gthe4_top.TenGigEthGthUltraScale156p25MHzCore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2]]

# 10GBase-KX4 timing constraints
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_XAUI.U_Eth/U_IpCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_XAUI.U_Eth/U_IpCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]]
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_XAUI.U_Eth/U_IpCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[1].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]]
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_XAUI.U_Eth/U_IpCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[2].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]]
set_clock_groups -asynchronous -group [get_clocks {clk125}] -group [get_clocks -of_objects [get_pins {U_DpmCore/U_Eth10gGen.U_RceEthernet/GEN_XAUI.U_Eth/U_IpCore/U0/XauiGthUltraScale156p25MHz10GigECore_gt_i/inst/gen_gtwizard_gthe4_top.XauiGthUltraScale156p25MHz10GigECore_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[0].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[3].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]]
