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

# Placeholder for future code

####################
# Timing Constraints
####################

create_clock -name ethRefClkP -period 6.400 [get_ports {ethRefClkP}]
create_clock -name locRefClkP -period 6.400 [get_ports {locRefClkP}]

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
