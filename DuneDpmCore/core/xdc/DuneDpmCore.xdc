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

set_property -dict { PACKAGE_PIN B13 IOSTANDARD LVCMOS33 } [get_ports { i2cSda }]
set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports { i2cScl }]

set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports { uartRx }]
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports { uartTx }]

set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS25 } [get_ports { dtmFbP[0] }]
set_property -dict { PACKAGE_PIN G11 IOSTANDARD LVCMOS25 } [get_ports { dtmFbN[0] }]

set_property -dict { PACKAGE_PIN J12 IOSTANDARD LVCMOS25 } [get_ports { dtmFbP[1] }]
set_property -dict { PACKAGE_PIN H12 IOSTANDARD LVCMOS25 } [get_ports { dtmFbN[1] }]

set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS25 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS25 } [get_ports { led[1] }]

set_property -dict { PACKAGE_PIN J11 IOSTANDARD LVCMOS25 } [get_ports { memPg[0] }]
set_property -dict { PACKAGE_PIN J10 IOSTANDARD LVCMOS25 } [get_ports { memPg[1] }]

set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVDS } [get_ports { dtmClkP[0] }]
set_property -dict { PACKAGE_PIN R9  IOSTANDARD LVDS } [get_ports { dtmClkN[0] }]

set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVDS } [get_ports { dtmClkP[1] }]
set_property -dict { PACKAGE_PIN R8  IOSTANDARD LVDS } [get_ports { dtmClkN[1] }]

set_property -dict { PACKAGE_PIN P11 IOSTANDARD LVDS } [get_ports { dtmClkP[2] }]
set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVDS } [get_ports { dtmClkN[2] }]

set_property -dict { PACKAGE_PIN P10 IOSTANDARD LVDS } [get_ports { dtmClkP[3] }]
set_property -dict { PACKAGE_PIN P9  IOSTANDARD LVDS } [get_ports { dtmClkN[3] }]

set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVDS } [get_ports { spareClkOutP[0] }]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVDS } [get_ports { spareClkOutN[0] }]

set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVDS } [get_ports { spareClkOutP[1] }]
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVDS } [get_ports { spareClkOutN[1] }]

set_property -dict { PACKAGE_PIN V6  IOSTANDARD LVDS } [get_ports { spareClkOutP[2] }]
set_property -dict { PACKAGE_PIN U6  IOSTANDARD LVDS } [get_ports { spareClkOutN[2] }]

set_property -dict { PACKAGE_PIN W12 IOSTANDARD LVDS } [get_ports { sgmiiTxP[0] }]
set_property -dict { PACKAGE_PIN W11 IOSTANDARD LVDS } [get_ports { sgmiiTxN[0] }]

set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVDS } [get_ports { sgmiiRxP[0] }]
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVDS } [get_ports { sgmiiRxN[0] }]

set_property -dict { PACKAGE_PIN V8  IOSTANDARD LVDS } [get_ports { sgmiiTxP[1] }]
set_property -dict { PACKAGE_PIN V7  IOSTANDARD LVDS } [get_ports { sgmiiTxN[1] }]

set_property -dict { PACKAGE_PIN T7  IOSTANDARD LVDS } [get_ports { sgmiiRxP[1] }]
set_property -dict { PACKAGE_PIN T6  IOSTANDARD LVDS } [get_ports { sgmiiRxN[1] }]

set_property -dict { PACKAGE_PIN M10 IOSTANDARD LVDS } [get_ports { sgmiiTxP[2] }]
set_property -dict { PACKAGE_PIN L10 IOSTANDARD LVDS } [get_ports { sgmiiTxN[2] }]

set_property -dict { PACKAGE_PIN L12 IOSTANDARD LVDS } [get_ports { sgmiiRxP[2] }]
set_property -dict { PACKAGE_PIN K12 IOSTANDARD LVDS } [get_ports { sgmiiRxN[2] }]

set_property -dict { PACKAGE_PIN P12 IOSTANDARD LVDS } [get_ports { sgmiiTxP[3] }]
set_property -dict { PACKAGE_PIN N12 IOSTANDARD LVDS } [get_ports { sgmiiTxN[3] }]

set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVDS } [get_ports { sgmiiRxP[3] }]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVDS } [get_ports { sgmiiRxN[3] }]

set_property -dict { PACKAGE_PIN R4 } [get_ports { ethTxP[0] }]
set_property -dict { PACKAGE_PIN R3 } [get_ports { ethTxN[0] }]

set_property -dict { PACKAGE_PIN T2 } [get_ports { ethRxP[0] }]
set_property -dict { PACKAGE_PIN T1 } [get_ports { ethRxN[0] }]

set_property -dict { PACKAGE_PIN P6 } [get_ports { ethTxP[1] }]
set_property -dict { PACKAGE_PIN P5 } [get_ports { ethTxN[1] }]

set_property -dict { PACKAGE_PIN P2 } [get_ports { ethRxP[1] }]
set_property -dict { PACKAGE_PIN P1 } [get_ports { ethRxN[1] }]

set_property -dict { PACKAGE_PIN J8 } [get_ports { ethRefClkP }]
set_property -dict { PACKAGE_PIN J7 } [get_ports { ethRefClkN }]

set_property -dict { PACKAGE_PIN E8 } [get_ports { spareClkInP[0] }]
set_property -dict { PACKAGE_PIN E7 } [get_ports { spareClkInN[0] }]

set_property -dict { PACKAGE_PIN J27 } [get_ports { spareClkInP[1] }]
set_property -dict { PACKAGE_PIN J28 } [get_ports { spareClkInN[1] }]

set_property -dict { PACKAGE_PIN G8 } [get_ports { dtmGtRefClkP[0] }]
set_property -dict { PACKAGE_PIN G7 } [get_ports { dtmGtRefClkN[0] }]

set_property -dict { PACKAGE_PIN L27 } [get_ports { dtmGtRefClkP[1] }]
set_property -dict { PACKAGE_PIN L28 } [get_ports { dtmGtRefClkN[1] }]

set_property -dict { PACKAGE_PIN K6 } [get_ports { dpmToRtmHsP[0] }]
set_property -dict { PACKAGE_PIN K5 } [get_ports { dpmToRtmHsN[0] }]

set_property -dict { PACKAGE_PIN K2 } [get_ports { rtmToDpmHsP[0] }]
set_property -dict { PACKAGE_PIN K1 } [get_ports { rtmToDpmHsN[0] }]

set_property -dict { PACKAGE_PIN H6 } [get_ports { dpmToRtmHsP[1] }]
set_property -dict { PACKAGE_PIN H5 } [get_ports { dpmToRtmHsN[1] }]

set_property -dict { PACKAGE_PIN J4 } [get_ports { rtmToDpmHsP[1] }]
set_property -dict { PACKAGE_PIN J3 } [get_ports { rtmToDpmHsN[1] }]

set_property -dict { PACKAGE_PIN G4 } [get_ports { dpmToRtmHsP[2] }]
set_property -dict { PACKAGE_PIN G3 } [get_ports { dpmToRtmHsN[2] }]

set_property -dict { PACKAGE_PIN H2 } [get_ports { rtmToDpmHsP[2] }]
set_property -dict { PACKAGE_PIN H1 } [get_ports { rtmToDpmHsN[2] }]

set_property -dict { PACKAGE_PIN F6 } [get_ports { dpmToRtmHsP[3] }]
set_property -dict { PACKAGE_PIN F5 } [get_ports { dpmToRtmHsN[3] }]

set_property -dict { PACKAGE_PIN F2 } [get_ports { rtmToDpmHsP[3] }]
set_property -dict { PACKAGE_PIN F1 } [get_ports { rtmToDpmHsN[3] }]

set_property -dict { PACKAGE_PIN E4 } [get_ports { dpmToRtmHsP[4] }]
set_property -dict { PACKAGE_PIN E3 } [get_ports { dpmToRtmHsN[4] }]

set_property -dict { PACKAGE_PIN D2 } [get_ports { rtmToDpmHsP[4] }]
set_property -dict { PACKAGE_PIN D1 } [get_ports { rtmToDpmHsN[4] }]

set_property -dict { PACKAGE_PIN D6 } [get_ports { dpmToRtmHsP[5] }]
set_property -dict { PACKAGE_PIN D5 } [get_ports { dpmToRtmHsN[5] }]

set_property -dict { PACKAGE_PIN C4 } [get_ports { rtmToDpmHsP[5] }]
set_property -dict { PACKAGE_PIN C3 } [get_ports { rtmToDpmHsN[5] }]

set_property -dict { PACKAGE_PIN B6 } [get_ports { dpmToRtmHsP[6] }]
set_property -dict { PACKAGE_PIN B5 } [get_ports { dpmToRtmHsN[6] }]

set_property -dict { PACKAGE_PIN B2 } [get_ports { rtmToDpmHsP[6] }]
set_property -dict { PACKAGE_PIN B1 } [get_ports { rtmToDpmHsN[6] }]

set_property -dict { PACKAGE_PIN A8 } [get_ports { dpmToRtmHsP[7] }]
set_property -dict { PACKAGE_PIN A7 } [get_ports { dpmToRtmHsN[7] }]

set_property -dict { PACKAGE_PIN A4 } [get_ports { rtmToDpmHsP[7] }]
set_property -dict { PACKAGE_PIN A3 } [get_ports { rtmToDpmHsN[7] }]

set_property -dict { PACKAGE_PIN F29 } [get_ports { dpmToRtmHsP[8] }]
set_property -dict { PACKAGE_PIN F30 } [get_ports { dpmToRtmHsN[8] }]

set_property -dict { PACKAGE_PIN E31 } [get_ports { rtmToDpmHsP[8] }]
set_property -dict { PACKAGE_PIN E32 } [get_ports { rtmToDpmHsN[8] }]

set_property -dict { PACKAGE_PIN D29 } [get_ports { dpmToRtmHsP[9] }]
set_property -dict { PACKAGE_PIN D30 } [get_ports { dpmToRtmHsN[9] }]

set_property -dict { PACKAGE_PIN D33 } [get_ports { rtmToDpmHsP[9] }]
set_property -dict { PACKAGE_PIN D34 } [get_ports { rtmToDpmHsN[9] }]

set_property -dict { PACKAGE_PIN B29 } [get_ports { dpmToRtmHsP[10] }]
set_property -dict { PACKAGE_PIN B30 } [get_ports { dpmToRtmHsN[10] }]

set_property -dict { PACKAGE_PIN C31 } [get_ports { rtmToDpmHsP[10] }]
set_property -dict { PACKAGE_PIN C32 } [get_ports { rtmToDpmHsN[10] }]

set_property -dict { PACKAGE_PIN A31 } [get_ports { dpmToRtmHsP[11] }]
set_property -dict { PACKAGE_PIN A32 } [get_ports { dpmToRtmHsN[11] }]

set_property -dict { PACKAGE_PIN B33 } [get_ports { rtmToDpmHsP[11] }]
set_property -dict { PACKAGE_PIN B34 } [get_ports { rtmToDpmHsN[11] }]

set_property -dict { PACKAGE_PIN K29 } [get_ports { dpmToRtmHsP[12] }]
set_property -dict { PACKAGE_PIN K30 } [get_ports { dpmToRtmHsN[12] }]

set_property -dict { PACKAGE_PIN L31 } [get_ports { rtmToDpmHsP[12] }]
set_property -dict { PACKAGE_PIN L32 } [get_ports { rtmToDpmHsN[12] }]

set_property -dict { PACKAGE_PIN J31 } [get_ports { dpmToRtmHsP[13] }]
set_property -dict { PACKAGE_PIN J32 } [get_ports { dpmToRtmHsN[13] }]

set_property -dict { PACKAGE_PIN K33 } [get_ports { rtmToDpmHsP[13] }]
set_property -dict { PACKAGE_PIN K34 } [get_ports { rtmToDpmHsN[13] }]

set_property -dict { PACKAGE_PIN H29 } [get_ports { dpmToRtmHsP[14] }]
set_property -dict { PACKAGE_PIN H30 } [get_ports { dpmToRtmHsN[14] }]

set_property -dict { PACKAGE_PIN H33 } [get_ports { rtmToDpmHsP[14] }]
set_property -dict { PACKAGE_PIN H34 } [get_ports { rtmToDpmHsN[14] }]

set_property -dict { PACKAGE_PIN G31 } [get_ports { dpmToRtmHsP[15] }]
set_property -dict { PACKAGE_PIN G32 } [get_ports { dpmToRtmHsN[15] }]

set_property -dict { PACKAGE_PIN F33 } [get_ports { rtmToDpmHsP[15] }]
set_property -dict { PACKAGE_PIN F34 } [get_ports { rtmToDpmHsN[15] }]

set_property -dict { PACKAGE_PIN T29 } [get_ports { dpmToRtmHsP[16] }]
set_property -dict { PACKAGE_PIN T30 } [get_ports { dpmToRtmHsN[16] }]

set_property -dict { PACKAGE_PIN T33 } [get_ports { rtmToDpmHsP[16] }]
set_property -dict { PACKAGE_PIN T34 } [get_ports { rtmToDpmHsN[16] }]

set_property -dict { PACKAGE_PIN R31 } [get_ports { dpmToRtmHsP[17] }]
set_property -dict { PACKAGE_PIN R32 } [get_ports { dpmToRtmHsN[17] }]

set_property -dict { PACKAGE_PIN P33 } [get_ports { rtmToDpmHsP[17] }]
set_property -dict { PACKAGE_PIN P34 } [get_ports { rtmToDpmHsN[17] }]

set_property -dict { PACKAGE_PIN P29 } [get_ports { dpmToRtmHsP[18] }]
set_property -dict { PACKAGE_PIN P30 } [get_ports { dpmToRtmHsN[18] }]

set_property -dict { PACKAGE_PIN N31 } [get_ports { rtmToDpmHsP[18] }]
set_property -dict { PACKAGE_PIN N32 } [get_ports { rtmToDpmHsN[18] }]

set_property -dict { PACKAGE_PIN M29 } [get_ports { dpmToRtmHsP[19] }]
set_property -dict { PACKAGE_PIN M30 } [get_ports { dpmToRtmHsN[19] }]

set_property -dict { PACKAGE_PIN M33 } [get_ports { rtmToDpmHsP[19] }]
set_property -dict { PACKAGE_PIN M34 } [get_ports { rtmToDpmHsN[19] }]

set_property -dict { PACKAGE_PIN N4 } [get_ports { dpmToRtmHsP[20] }]
set_property -dict { PACKAGE_PIN N3 } [get_ports { dpmToRtmHsN[20] }]

set_property -dict { PACKAGE_PIN M2 } [get_ports { rtmToDpmHsP[20] }]
set_property -dict { PACKAGE_PIN M1 } [get_ports { rtmToDpmHsN[20] }]

set_property -dict { PACKAGE_PIN M6 } [get_ports { dpmToRtmHsP[21] }]
set_property -dict { PACKAGE_PIN M5 } [get_ports { dpmToRtmHsN[21] }]

set_property -dict { PACKAGE_PIN L4 } [get_ports { rtmToDpmHsP[21] }]
set_property -dict { PACKAGE_PIN L3 } [get_ports { rtmToDpmHsN[21] }]

####################
# Timing Constraints
####################

create_clock -name ethRefClkP -period 6.400 [get_ports {ethRefClkP}]
create_clock -name fclk0      -period 10.00 [get_pins {U_Core/U_RceG3Top/U_SimModeDis.U_RceG3Cpu/U_CPU/U0/buffer_pl_clk_0.PL_CLK_0_BUFG/O}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {ethRefClkP}] -group [get_clocks -include_generated_clocks {fclk0}] 

create_generated_clock -name axiDmaClk [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name sysClk200 [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT1}]
create_generated_clock -name sysClk125 [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT2}]
create_generated_clock -name dnaClk    [get_pins {U_Core/U_RceG3Top/U_RceG3AxiCntl/U_DeviceDna/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]
set_clock_groups -asynchronous \
    -group [get_clocks {dnaClk}] \
    -group [get_clocks {axiDmaClk}] \
    -group [get_clocks {sysClk200}] \
    -group [get_clocks {sysClk125}] 

create_clock -name eth1GbETxClk -period 16.00 [get_pins {U_Core/U_Eth1gGen.U_ZynqEthernet/core_wrapper/transceiver_inst/zynq_gige_gt_i/inst/gen_gtwizard_gthe4_top.zynq_gige_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]
create_generated_clock -name eth1GbERxClk     [get_pins {U_Core/U_Eth1gGen.U_ZynqEthernet/core_wrapper/transceiver_inst/zynq_gige_gt_i/inst/gen_gtwizard_gthe4_top.zynq_gige_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]
create_generated_clock -name eth125Clk        [get_pins {U_Core/U_Eth1gGen.U_ZynqEthernet/U_MMCM/PllGen.U_Pll/CLKOUT0}]
create_generated_clock -name eth62Clk         [get_pins {U_Core/U_Eth1gGen.U_ZynqEthernet/U_MMCM/PllGen.U_Pll/CLKOUT1}]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {eth1GbETxClk}] -group [get_clocks {eth1GbERxClk}] -group [get_clocks -include_generated_clocks {fclk0}] 
