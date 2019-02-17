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

set_property -dict { PACKAGE_PIN E4 } [get_ports { sfpTxP[0] }]
set_property -dict { PACKAGE_PIN E3 } [get_ports { sfpTxN[0] }]
set_property -dict { PACKAGE_PIN D2 } [get_ports { sfpRxP[0] }]
set_property -dict { PACKAGE_PIN D1 } [get_ports { sfpRxN[0] }]

set_property -dict { PACKAGE_PIN D6 } [get_ports { sfpTxP[1] }]
set_property -dict { PACKAGE_PIN D5 } [get_ports { sfpTxN[1] }]
set_property -dict { PACKAGE_PIN C4 } [get_ports { sfpRxP[1] }]
set_property -dict { PACKAGE_PIN C3 } [get_ports { sfpRxN[1] }]

set_property -dict { PACKAGE_PIN B6 } [get_ports { sfpTxP[2] }]
set_property -dict { PACKAGE_PIN B5 } [get_ports { sfpTxN[2] }]
set_property -dict { PACKAGE_PIN B2 } [get_ports { sfpRxP[2] }]
set_property -dict { PACKAGE_PIN B1 } [get_ports { sfpRxN[2] }]

set_property -dict { PACKAGE_PIN A8 } [get_ports { sfpTxP[3] }]
set_property -dict { PACKAGE_PIN A7 } [get_ports { sfpTxN[3] }]
set_property -dict { PACKAGE_PIN A4 } [get_ports { sfpRxP[3] }]
set_property -dict { PACKAGE_PIN A3 } [get_ports { sfpRxN[3] }]

set_property -dict { PACKAGE_PIN C8 } [get_ports { sfpRefClkP }]
set_property -dict { PACKAGE_PIN C7 } [get_ports { sfpRefClkN }]

####################
# Timing Constraints
####################

create_clock -name sfpRefClkP -period 6.400 [get_ports {sfpRefClkP}]
create_clock -name fclk0      -period 10.0  [get_pins  {U_Core/U_RceG3Top/GEN_SYNTH.U_RceG3Cpu/U_CPU/U0/PS8_i/PLCLK[0]}]

create_generated_clock -name clk200 [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name clk125 [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3}]
create_generated_clock -name dnaClk [get_pins {U_Core/U_RceG3Top/GEN_SYNTH.U_RceG3AxiCntl/U_DeviceDna/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {dnaClk}] -group [get_clocks {clk125}] 
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {sfpRefClkP}] -group [get_clocks {clk200}]  -group [get_clocks {clk125}]
