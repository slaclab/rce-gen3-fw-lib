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

set_property -dict { PACKAGE_PIN AM13 IOSTANDARD LVCMOS33 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN AG14 IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN AF13 IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN AJ14 IOSTANDARD LVCMOS33 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN AJ15 IOSTANDARD LVCMOS33 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN AH13 IOSTANDARD LVCMOS33 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN AH14 IOSTANDARD LVCMOS33 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN AL12 IOSTANDARD LVCMOS33 } [get_ports { led[7] }]

set_property -dict { PACKAGE_PIN AL8 IOSTANDARD DIFF_SSTL12_DCI ODT RTT_48 } [get_ports { sysClk300P }]
set_property -dict { PACKAGE_PIN AL7 IOSTANDARD DIFF_SSTL12_DCI ODT RTT_48 } [get_ports { sysClk300N }]

##############################################################################

set_property PACKAGE_PIN M29 [get_ports { smaTxP }]
set_property PACKAGE_PIN M30 [get_ports { smaTxN }]

set_property PACKAGE_PIN M33 [get_ports { smaRxP }]
set_property PACKAGE_PIN M34 [get_ports { smaRxN }]

set_property PACKAGE_PIN J27 [get_ports { smaClkP }]
set_property PACKAGE_PIN J28 [get_ports { smaClkN }]

##############################################################################

set_property PACKAGE_PIN A12 [get_ports { sfpEnTx[0] }]
set_property PACKAGE_PIN A13 [get_ports { sfpEnTx[1] }]
set_property PACKAGE_PIN B13 [get_ports { sfpEnTx[2] }]
set_property PACKAGE_PIN C13 [get_ports { sfpEnTx[3] }]
set_property -dict { IOSTANDARD LVCMOS33 } [get_ports { sfpEnTx[*] }]
 
set_property PACKAGE_PIN E4 [get_ports { sfpTxP[0] }]
set_property PACKAGE_PIN E3 [get_ports { sfpTxN[0] }]
set_property PACKAGE_PIN D2 [get_ports { sfpRxP[0] }]
set_property PACKAGE_PIN D1 [get_ports { sfpRxN[0] }]

set_property PACKAGE_PIN D6 [get_ports { sfpTxP[1] }]
set_property PACKAGE_PIN D5 [get_ports { sfpTxN[1] }]
set_property PACKAGE_PIN C4 [get_ports { sfpRxP[1] }]
set_property PACKAGE_PIN C3 [get_ports { sfpRxN[1] }]

set_property PACKAGE_PIN B6 [get_ports { sfpTxP[2] }]
set_property PACKAGE_PIN B5 [get_ports { sfpTxN[2] }]
set_property PACKAGE_PIN B2 [get_ports { sfpRxP[2] }]
set_property PACKAGE_PIN B1 [get_ports { sfpRxN[2] }]

set_property PACKAGE_PIN A8 [get_ports { sfpTxP[3] }]
set_property PACKAGE_PIN A7 [get_ports { sfpTxN[3] }]
set_property PACKAGE_PIN A4 [get_ports { sfpRxP[3] }]
set_property PACKAGE_PIN A3 [get_ports { sfpRxN[3] }]

set_property PACKAGE_PIN C8 [get_ports { sfpClk156P }]
set_property PACKAGE_PIN C7 [get_ports { sfpClk156N }]

##############################################################################

set_property PACKAGE_PIN Y4   [get_ports { fmcHpc0LaP[0] }]
set_property PACKAGE_PIN Y3   [get_ports { fmcHpc0LaN[0] }]
set_property PACKAGE_PIN AB4  [get_ports { fmcHpc0LaP[1] }]
set_property PACKAGE_PIN AC4  [get_ports { fmcHpc0LaN[1] }]
set_property PACKAGE_PIN V2   [get_ports { fmcHpc0LaP[2] }]
set_property PACKAGE_PIN V1   [get_ports { fmcHpc0LaN[2] }]
set_property PACKAGE_PIN Y2   [get_ports { fmcHpc0LaP[3] }]
set_property PACKAGE_PIN Y1   [get_ports { fmcHpc0LaN[3] }]
set_property PACKAGE_PIN AA2  [get_ports { fmcHpc0LaP[4] }]
set_property PACKAGE_PIN AA1  [get_ports { fmcHpc0LaN[4] }]
set_property PACKAGE_PIN AB3  [get_ports { fmcHpc0LaP[5] }]
set_property PACKAGE_PIN AC3  [get_ports { fmcHpc0LaN[5] }]
set_property PACKAGE_PIN AC2  [get_ports { fmcHpc0LaP[6] }]
set_property PACKAGE_PIN AC1  [get_ports { fmcHpc0LaN[6] }]
set_property PACKAGE_PIN U5   [get_ports { fmcHpc0LaP[7] }]
set_property PACKAGE_PIN U4   [get_ports { fmcHpc0LaN[7] }]
set_property PACKAGE_PIN V4   [get_ports { fmcHpc0LaP[8] }]
set_property PACKAGE_PIN V3   [get_ports { fmcHpc0LaN[8] }]
set_property PACKAGE_PIN W2   [get_ports { fmcHpc0LaP[9] }]
set_property PACKAGE_PIN W1   [get_ports { fmcHpc0LaN[9] }]
set_property PACKAGE_PIN W5   [get_ports { fmcHpc0LaP[10] }]
set_property PACKAGE_PIN W4   [get_ports { fmcHpc0LaN[10] }]
set_property PACKAGE_PIN AB6  [get_ports { fmcHpc0LaP[11] }]
set_property PACKAGE_PIN AB5  [get_ports { fmcHpc0LaN[11] }]
set_property PACKAGE_PIN W7   [get_ports { fmcHpc0LaP[12] }]
set_property PACKAGE_PIN W6   [get_ports { fmcHpc0LaN[12] }]
set_property PACKAGE_PIN AB8  [get_ports { fmcHpc0LaP[13] }]
set_property PACKAGE_PIN AC8  [get_ports { fmcHpc0LaN[13] }]
set_property PACKAGE_PIN AC7  [get_ports { fmcHpc0LaP[14] }]
set_property PACKAGE_PIN AC6  [get_ports { fmcHpc0LaN[14] }]
set_property PACKAGE_PIN Y10  [get_ports { fmcHpc0LaP[15] }]
set_property PACKAGE_PIN Y9   [get_ports { fmcHpc0LaN[15] }]
set_property PACKAGE_PIN Y12  [get_ports { fmcHpc0LaP[16] }]
set_property PACKAGE_PIN AA12 [get_ports { fmcHpc0LaN[16] }]
set_property PACKAGE_PIN P11  [get_ports { fmcHpc0LaP[17] }]
set_property PACKAGE_PIN N11  [get_ports { fmcHpc0LaN[17] }]
set_property PACKAGE_PIN N9   [get_ports { fmcHpc0LaP[18] }]
set_property PACKAGE_PIN N8   [get_ports { fmcHpc0LaN[18] }]
set_property PACKAGE_PIN L13  [get_ports { fmcHpc0LaP[19] }]
set_property PACKAGE_PIN K13  [get_ports { fmcHpc0LaN[19] }]
set_property PACKAGE_PIN N13  [get_ports { fmcHpc0LaP[20] }]
set_property PACKAGE_PIN M13  [get_ports { fmcHpc0LaN[20] }]
set_property PACKAGE_PIN P12  [get_ports { fmcHpc0LaP[21] }]
set_property PACKAGE_PIN N12  [get_ports { fmcHpc0LaN[21] }]
set_property PACKAGE_PIN M15  [get_ports { fmcHpc0LaP[22] }]
set_property PACKAGE_PIN M14  [get_ports { fmcHpc0LaN[22] }]
set_property PACKAGE_PIN L16  [get_ports { fmcHpc0LaP[23] }]
set_property PACKAGE_PIN K16  [get_ports { fmcHpc0LaN[23] }]
set_property PACKAGE_PIN L12  [get_ports { fmcHpc0LaP[24] }]
set_property PACKAGE_PIN K12  [get_ports { fmcHpc0LaN[24] }]
set_property PACKAGE_PIN M11  [get_ports { fmcHpc0LaP[25] }]
set_property PACKAGE_PIN L11  [get_ports { fmcHpc0LaN[25] }]
set_property PACKAGE_PIN L15  [get_ports { fmcHpc0LaP[26] }]
set_property PACKAGE_PIN K15  [get_ports { fmcHpc0LaN[26] }]
set_property PACKAGE_PIN M10  [get_ports { fmcHpc0LaP[27] }]
set_property PACKAGE_PIN L10  [get_ports { fmcHpc0LaN[27] }]
set_property PACKAGE_PIN T7   [get_ports { fmcHpc0LaP[28] }]
set_property PACKAGE_PIN T6   [get_ports { fmcHpc0LaN[28] }]
set_property PACKAGE_PIN U9   [get_ports { fmcHpc0LaP[29] }]
set_property PACKAGE_PIN U8   [get_ports { fmcHpc0LaN[29] }]
set_property PACKAGE_PIN V6   [get_ports { fmcHpc0LaP[30] }]
set_property PACKAGE_PIN U6   [get_ports { fmcHpc0LaN[30] }]
set_property PACKAGE_PIN V8   [get_ports { fmcHpc0LaP[31] }]
set_property PACKAGE_PIN V7   [get_ports { fmcHpc0LaN[31] }]
set_property PACKAGE_PIN U11  [get_ports { fmcHpc0LaP[32] }]
set_property PACKAGE_PIN T11  [get_ports { fmcHpc0LaN[32] }]
set_property PACKAGE_PIN V12  [get_ports { fmcHpc0LaP[33] }]
set_property PACKAGE_PIN V11  [get_ports { fmcHpc0LaN[33] }]

set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpc0LaP[*] }]
set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpc0LaN[*] }]

##############################################################################

set_property PACKAGE_PIN AE5  [get_ports { fmcHpc1LaP[0] }]
set_property PACKAGE_PIN AF5  [get_ports { fmcHpc1LaN[0] }]
set_property PACKAGE_PIN AJ6  [get_ports { fmcHpc1LaP[1] }]
set_property PACKAGE_PIN AJ5  [get_ports { fmcHpc1LaN[1] }]
set_property PACKAGE_PIN AD2  [get_ports { fmcHpc1LaP[2] }]
set_property PACKAGE_PIN AD1  [get_ports { fmcHpc1LaN[2] }]
set_property PACKAGE_PIN AH1  [get_ports { fmcHpc1LaP[3] }]
set_property PACKAGE_PIN AJ1  [get_ports { fmcHpc1LaN[3] }]
set_property PACKAGE_PIN AF2  [get_ports { fmcHpc1LaP[4] }]
set_property PACKAGE_PIN AF1  [get_ports { fmcHpc1LaN[4] }]
set_property PACKAGE_PIN AG3  [get_ports { fmcHpc1LaP[5] }]
set_property PACKAGE_PIN AH3  [get_ports { fmcHpc1LaN[5] }]
set_property PACKAGE_PIN AH2  [get_ports { fmcHpc1LaP[6] }]
set_property PACKAGE_PIN AJ2  [get_ports { fmcHpc1LaN[6] }]
set_property PACKAGE_PIN AD4  [get_ports { fmcHpc1LaP[7] }]
set_property PACKAGE_PIN AE4  [get_ports { fmcHpc1LaN[7] }]
set_property PACKAGE_PIN AE3  [get_ports { fmcHpc1LaP[8] }]
set_property PACKAGE_PIN AF3  [get_ports { fmcHpc1LaN[8] }]
set_property PACKAGE_PIN AE2  [get_ports { fmcHpc1LaP[9] }]
set_property PACKAGE_PIN AE1  [get_ports { fmcHpc1LaN[9] }]
set_property PACKAGE_PIN AH4  [get_ports { fmcHpc1LaP[10] }]
set_property PACKAGE_PIN AJ4  [get_ports { fmcHpc1LaN[10] }]
set_property PACKAGE_PIN AE8  [get_ports { fmcHpc1LaP[11] }]
set_property PACKAGE_PIN AF8  [get_ports { fmcHpc1LaN[11] }]
set_property PACKAGE_PIN AD7  [get_ports { fmcHpc1LaP[12] }]
set_property PACKAGE_PIN AD6  [get_ports { fmcHpc1LaN[12] }]
set_property PACKAGE_PIN AG8  [get_ports { fmcHpc1LaP[13] }]
set_property PACKAGE_PIN AH8  [get_ports { fmcHpc1LaN[13] }]
set_property PACKAGE_PIN AH7  [get_ports { fmcHpc1LaP[14] }]
set_property PACKAGE_PIN AH6  [get_ports { fmcHpc1LaN[14] }]
set_property PACKAGE_PIN AD10 [get_ports { fmcHpc1LaP[15] }]
set_property PACKAGE_PIN AE9  [get_ports { fmcHpc1LaN[15] }]
set_property PACKAGE_PIN AG10 [get_ports { fmcHpc1LaP[16] }]
set_property PACKAGE_PIN AG9  [get_ports { fmcHpc1LaN[16] }]
set_property PACKAGE_PIN Y5   [get_ports { fmcHpc1LaP[17] }]
set_property PACKAGE_PIN AA5  [get_ports { fmcHpc1LaN[17] }]
set_property PACKAGE_PIN Y8   [get_ports { fmcHpc1LaP[18] }]
set_property PACKAGE_PIN Y7   [get_ports { fmcHpc1LaN[18] }]
set_property PACKAGE_PIN AA11 [get_ports { fmcHpc1LaP[19] }]
set_property PACKAGE_PIN AA10 [get_ports { fmcHpc1LaN[19] }]
set_property PACKAGE_PIN AB11 [get_ports { fmcHpc1LaP[20] }]
set_property PACKAGE_PIN AB10 [get_ports { fmcHpc1LaN[20] }]
set_property PACKAGE_PIN AC12 [get_ports { fmcHpc1LaP[21] }]
set_property PACKAGE_PIN AC11 [get_ports { fmcHpc1LaN[21] }]
set_property PACKAGE_PIN AF11 [get_ports { fmcHpc1LaP[22] }]
set_property PACKAGE_PIN AG11 [get_ports { fmcHpc1LaN[22] }]
set_property PACKAGE_PIN AE12 [get_ports { fmcHpc1LaP[23] }]
set_property PACKAGE_PIN AF12 [get_ports { fmcHpc1LaN[23] }]
set_property PACKAGE_PIN AH12 [get_ports { fmcHpc1LaP[24] }]
set_property PACKAGE_PIN AH11 [get_ports { fmcHpc1LaN[24] }]
set_property PACKAGE_PIN AE10 [get_ports { fmcHpc1LaP[25] }]
set_property PACKAGE_PIN AF10 [get_ports { fmcHpc1LaN[25] }]
set_property PACKAGE_PIN T12  [get_ports { fmcHpc1LaP[26] }]
set_property PACKAGE_PIN R12  [get_ports { fmcHpc1LaN[26] }]
set_property PACKAGE_PIN U10  [get_ports { fmcHpc1LaP[27] }]
set_property PACKAGE_PIN T10  [get_ports { fmcHpc1LaN[27] }]
set_property PACKAGE_PIN T13  [get_ports { fmcHpc1LaP[28] }]
set_property PACKAGE_PIN R13  [get_ports { fmcHpc1LaN[28] }]
set_property PACKAGE_PIN W12  [get_ports { fmcHpc1LaP[29] }]
set_property PACKAGE_PIN W11  [get_ports { fmcHpc1LaN[29] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaP[30] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaN[30] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaP[31] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaN[31] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaP[32] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaN[32] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaP[33] }]
# set_property PACKAGE_PIN NOT_CONNECTED  [get_ports { fmcHpc1LaN[33] }]

set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpc1LaP[*] }]
set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpc1LaN[*] }]

##############################################################################

####################
# Timing Constraints
####################

create_clock -name sfpClk156P -period 6.400 [get_ports {sfpClk156P}]
create_clock -name fclk0      -period 10.0  [get_pins  {U_Core/U_RceG3Top/GEN_SYNTH.U_RceG3Cpu/U_CPU/U0/PS8_i/PLCLK[0]}]

create_generated_clock -name clk200 [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]
create_generated_clock -name clk125 [get_pins {U_Core/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3}]
create_generated_clock -name dnaClk [get_pins {U_Core/U_RceG3Top/GEN_SYNTH.U_RceG3AxiCntl/U_DeviceDna/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {dnaClk}] -group [get_clocks {clk125}] 
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks {sfpClk156P}] -group [get_clocks {clk200}]  -group [get_clocks {clk125}]
