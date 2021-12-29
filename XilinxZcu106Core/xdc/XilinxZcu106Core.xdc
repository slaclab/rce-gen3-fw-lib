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

set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS18 } [get_ports { extRst }]


set_property -dict { PACKAGE_PIN AL11 IOSTANDARD LVCMOS12 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN AL13 IOSTANDARD LVCMOS12 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN AK13 IOSTANDARD LVCMOS12 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN AE15 IOSTANDARD LVCMOS12 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN AM8  IOSTANDARD LVCMOS12 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN AM9  IOSTANDARD LVCMOS12 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN AM10 IOSTANDARD LVCMOS12 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN AM11 IOSTANDARD LVCMOS12 } [get_ports { led[7] }]

set_property -dict { PACKAGE_PIN AH12 IOSTANDARD DIFF_SSTL12 ODT RTT_48 } [get_ports { sysClk300P }]
set_property -dict { PACKAGE_PIN AJ12 IOSTANDARD DIFF_SSTL12 ODT RTT_48 } [get_ports { sysClk300N }]

##############################################################################

set_property PACKAGE_PIN AA6  [get_ports { smaTxP }] ;# Bank 225 - MGTHTXP1_225
set_property PACKAGE_PIN AA5  [get_ports { smaTxN }] ;# Bank 225 - MGTHTXN1_225
                                                   
set_property PACKAGE_PIN AB4  [get_ports { smaRxP }] ;# Bank 225 - MGTHRXP1_225
set_property PACKAGE_PIN AB3  [get_ports { smaRxN }] ;# Bank 225 - MGTHRXN1_225
                                                   
set_property PACKAGE_PIN AA10 [get_ports { smaClkP }] ;# Bank 224 - MGTREFCLK1N_224
set_property PACKAGE_PIN AA9  [get_ports { smaClkN }] ;# Bank 224 - MGTREFCLK1P_224

##############################################################################

set_property PACKAGE_PIN AE22 [get_ports { sfpEnTx[0] }]
set_property PACKAGE_PIN AF20 [get_ports { sfpEnTx[1] }]
set_property -dict { IOSTANDARD LVCMOS12 } [get_ports { sfpEnTx[*] }]
 
set_property PACKAGE_PIN Y4  [get_ports { sfpTxP[0] }]
set_property PACKAGE_PIN Y3  [get_ports { sfpTxN[0] }]
set_property PACKAGE_PIN AA2 [get_ports { sfpRxP[0] }]
set_property PACKAGE_PIN AA1 [get_ports { sfpRxN[0] }]
                                                     
set_property PACKAGE_PIN W6  [get_ports { sfpTxP[1] }]
set_property PACKAGE_PIN W5  [get_ports { sfpTxN[1] }]
set_property PACKAGE_PIN W2  [get_ports { sfpRxP[1] }]
set_property PACKAGE_PIN W1  [get_ports { sfpRxN[1] }]


set_property PACKAGE_PIN R10 [get_ports { sfpClk156P }]
set_property PACKAGE_PIN R9  [get_ports { sfpClk156N }]

##############################################################################

set_property PACKAGE_PIN F17  [get_ports { fmcHpc0LaP[0] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L13P_T2L_N0_GC_QBC_67
set_property PACKAGE_PIN F16  [get_ports { fmcHpc0LaN[0] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L13N_T2L_N1_GC_QBC_67
set_property PACKAGE_PIN H18  [get_ports { fmcHpc0LaP[1] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L16P_T2U_N6_QBC_AD3P_67
set_property PACKAGE_PIN H17  [get_ports { fmcHpc0LaN[1] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L16N_T2U_N7_QBC_AD3N_67
set_property PACKAGE_PIN L20  [get_ports { fmcHpc0LaP[2] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_67
set_property PACKAGE_PIN K20  [get_ports { fmcHpc0LaN[2] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_67
set_property PACKAGE_PIN K19  [get_ports { fmcHpc0LaP[3] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L23P_T3U_N8_67
set_property PACKAGE_PIN K18  [get_ports { fmcHpc0LaN[3] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L23N_T3U_N9_67
set_property PACKAGE_PIN L17  [get_ports { fmcHpc0LaP[4] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L24P_T3U_N10_67
set_property PACKAGE_PIN L16  [get_ports { fmcHpc0LaN[4] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L24N_T3U_N11_67
set_property PACKAGE_PIN K17  [get_ports { fmcHpc0LaP[5] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L21P_T3L_N4_AD8P_67
set_property PACKAGE_PIN J17  [get_ports { fmcHpc0LaN[5] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L21N_T3L_N5_AD8N_67
set_property PACKAGE_PIN H19  [get_ports { fmcHpc0LaP[6] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L15P_T2L_N4_AD11P_67
set_property PACKAGE_PIN G19  [get_ports { fmcHpc0LaN[6] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L15N_T2L_N5_AD11N_67
set_property PACKAGE_PIN J16  [get_ports { fmcHpc0LaP[7] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L20P_T3L_N2_AD1P_67
set_property PACKAGE_PIN J15  [get_ports { fmcHpc0LaN[7] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L20N_T3L_N3_AD1N_67
set_property PACKAGE_PIN E18  [get_ports { fmcHpc0LaP[8] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L9P_T1L_N4_AD12P_67
set_property PACKAGE_PIN E17  [get_ports { fmcHpc0LaN[8] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L9N_T1L_N5_AD12N_67
set_property PACKAGE_PIN H16  [get_ports { fmcHpc0LaP[9] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L18P_T2U_N10_AD2P_67
set_property PACKAGE_PIN G16  [get_ports { fmcHpc0LaN[9] }]    ;# Bank  67 VCCO - VADJ_FMC - IO_L18N_T2U_N11_AD2N_67
set_property PACKAGE_PIN L15  [get_ports { fmcHpc0LaP[10] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_67
set_property PACKAGE_PIN K15  [get_ports { fmcHpc0LaN[10] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_67
set_property PACKAGE_PIN A13  [get_ports { fmcHpc0LaP[11] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L5P_T0U_N8_AD14P_67
set_property PACKAGE_PIN A12  [get_ports { fmcHpc0LaN[11] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L5N_T0U_N9_AD14N_67
set_property PACKAGE_PIN G18  [get_ports { fmcHpc0LaP[12] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_67
set_property PACKAGE_PIN F18  [get_ports { fmcHpc0LaN[12] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_67
set_property PACKAGE_PIN G15  [get_ports { fmcHpc0LaP[13] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L14P_T2L_N2_GC_67
set_property PACKAGE_PIN F15  [get_ports { fmcHpc0LaN[13] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L14N_T2L_N3_GC_67
set_property PACKAGE_PIN C13  [get_ports { fmcHpc0LaP[14] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L6P_T0U_N10_AD6P_67
set_property PACKAGE_PIN C12  [get_ports { fmcHpc0LaN[14] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L6N_T0U_N11_AD6N_67
set_property PACKAGE_PIN D16  [get_ports { fmcHpc0LaP[15] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L7P_T1L_N0_QBC_AD13P_67
set_property PACKAGE_PIN C16  [get_ports { fmcHpc0LaN[15] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L7N_T1L_N1_QBC_AD13N_67
set_property PACKAGE_PIN D17  [get_ports { fmcHpc0LaP[16] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_67
set_property PACKAGE_PIN C17  [get_ports { fmcHpc0LaN[16] }]   ;# Bank  67 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_67
set_property PACKAGE_PIN F11  [get_ports { fmcHpc0LaP[17] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L14P_T2L_N2_GC_68
set_property PACKAGE_PIN E10  [get_ports { fmcHpc0LaN[17] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L14N_T2L_N3_GC_68
set_property PACKAGE_PIN D11  [get_ports { fmcHpc0LaP[18] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L16P_T2U_N6_QBC_AD3P_68
set_property PACKAGE_PIN D10  [get_ports { fmcHpc0LaN[18] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L16N_T2U_N7_QBC_AD3N_68
set_property PACKAGE_PIN D12  [get_ports { fmcHpc0LaP[19] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L18P_T2U_N10_AD2P_68
set_property PACKAGE_PIN C11  [get_ports { fmcHpc0LaN[19] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L18N_T2U_N11_AD2N_68
set_property PACKAGE_PIN F12  [get_ports { fmcHpc0LaP[20] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_68
set_property PACKAGE_PIN E12  [get_ports { fmcHpc0LaN[20] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_68
set_property PACKAGE_PIN B10  [get_ports { fmcHpc0LaP[21] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_68
set_property PACKAGE_PIN A10  [get_ports { fmcHpc0LaN[21] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_68
set_property PACKAGE_PIN H13  [get_ports { fmcHpc0LaP[22] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L15P_T2L_N4_AD11P_68
set_property PACKAGE_PIN H12  [get_ports { fmcHpc0LaN[22] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L15N_T2L_N5_AD11N_68
set_property PACKAGE_PIN B11  [get_ports { fmcHpc0LaP[23] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L24P_T3U_N10_68
set_property PACKAGE_PIN A11  [get_ports { fmcHpc0LaN[23] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L24N_T3U_N11_68
set_property PACKAGE_PIN B6   [get_ports { fmcHpc0LaP[24] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L21P_T3L_N4_AD8P_68
set_property PACKAGE_PIN A6   [get_ports { fmcHpc0LaN[24] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L21N_T3L_N5_AD8N_68
set_property PACKAGE_PIN C7   [get_ports { fmcHpc0LaP[25] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_68
set_property PACKAGE_PIN C6   [get_ports { fmcHpc0LaN[25] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_68
set_property PACKAGE_PIN B9   [get_ports { fmcHpc0LaP[26] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L20P_T3L_N2_AD1P_68
set_property PACKAGE_PIN B8   [get_ports { fmcHpc0LaN[26] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L20N_T3L_N3_AD1N_68
set_property PACKAGE_PIN A8   [get_ports { fmcHpc0LaP[27] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L23P_T3U_N8_68
set_property PACKAGE_PIN A7   [get_ports { fmcHpc0LaN[27] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L23N_T3U_N9_68
set_property PACKAGE_PIN M13  [get_ports { fmcHpc0LaP[28] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L1P_T0L_N0_DBC_68
set_property PACKAGE_PIN L13  [get_ports { fmcHpc0LaN[28] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L1N_T0L_N1_DBC_68
set_property PACKAGE_PIN K10  [get_ports { fmcHpc0LaP[29] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L2P_T0L_N2_68
set_property PACKAGE_PIN J10  [get_ports { fmcHpc0LaN[29] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L2N_T0L_N3_68
set_property PACKAGE_PIN E9   [get_ports { fmcHpc0LaP[30] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L10P_T1U_N6_QBC_AD4P_68
set_property PACKAGE_PIN D9   [get_ports { fmcHpc0LaN[30] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L10N_T1U_N7_QBC_AD4N_68
set_property PACKAGE_PIN F7   [get_ports { fmcHpc0LaP[31] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L7P_T1L_N0_QBC_AD13P_68
set_property PACKAGE_PIN E7   [get_ports { fmcHpc0LaN[31] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L7N_T1L_N1_QBC_AD13N_68
set_property PACKAGE_PIN F8   [get_ports { fmcHpc0LaP[32] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L9P_T1L_N4_AD12P_68
set_property PACKAGE_PIN E8   [get_ports { fmcHpc0LaN[32] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L9N_T1L_N5_AD12N_68
set_property PACKAGE_PIN C9   [get_ports { fmcHpc0LaP[33] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_68
set_property PACKAGE_PIN C8   [get_ports { fmcHpc0LaN[33] }]   ;# Bank  68 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_68

set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpc0LaP[*] }]
set_property -dict { IOSTANDARD LVCMOS18 } [get_ports { fmcHpc0LaN[*] }]

##############################################################################

set_property PACKAGE_PIN B18  [get_ports {  fmcHpc1LaP[0]  }];# Bank  28 VCCO - VADJ_FMC - IO_L22P_T3U_N6_DBC_AD0P_28
set_property PACKAGE_PIN B19  [get_ports {  fmcHpc1LaN[0]  }];# Bank  28 VCCO - VADJ_FMC - IO_L22N_T3U_N7_DBC_AD0N_28
set_property PACKAGE_PIN E24  [get_ports {  fmcHpc1LaP[1]  }];# Bank  28 VCCO - VADJ_FMC - IO_L16P_T2U_N6_QBC_AD3P_28
set_property PACKAGE_PIN D24  [get_ports {  fmcHpc1LaN[1]  }];# Bank  28 VCCO - VADJ_FMC - IO_L16N_T2U_N7_QBC_AD3N_28
set_property PACKAGE_PIN K22  [get_ports {  fmcHpc1LaP[2]  }];# Bank  28 VCCO - VADJ_FMC - IO_L4P_T0U_N6_DBC_AD7P_28
set_property PACKAGE_PIN K23  [get_ports {  fmcHpc1LaN[2]  }];# Bank  28 VCCO - VADJ_FMC - IO_L4N_T0U_N7_DBC_AD7N_28
set_property PACKAGE_PIN J21  [get_ports {  fmcHpc1LaP[3]  }];# Bank  28 VCCO - VADJ_FMC - IO_L3P_T0L_N4_AD15P_28
set_property PACKAGE_PIN J22  [get_ports {  fmcHpc1LaN[3]  }];# Bank  28 VCCO - VADJ_FMC - IO_L3N_T0L_N5_AD15N_28
set_property PACKAGE_PIN J24  [get_ports {  fmcHpc1LaP[4]  }];# Bank  28 VCCO - VADJ_FMC - IO_L6P_T0U_N10_AD6P_28
set_property PACKAGE_PIN H24  [get_ports {  fmcHpc1LaN[4]  }];# Bank  28 VCCO - VADJ_FMC - IO_L6N_T0U_N11_AD6N_28
set_property PACKAGE_PIN G25  [get_ports {  fmcHpc1LaP[5]  }];# Bank  28 VCCO - VADJ_FMC - IO_L18P_T2U_N10_AD2P_28
set_property PACKAGE_PIN G26  [get_ports {  fmcHpc1LaN[5]  }];# Bank  28 VCCO - VADJ_FMC - IO_L18N_T2U_N11_AD2N_28
set_property PACKAGE_PIN H21  [get_ports {  fmcHpc1LaP[6]  }];# Bank  28 VCCO - VADJ_FMC - IO_L8P_T1L_N2_AD5P_28
set_property PACKAGE_PIN H22  [get_ports {  fmcHpc1LaN[6]  }];# Bank  28 VCCO - VADJ_FMC - IO_L8N_T1L_N3_AD5N_28
set_property PACKAGE_PIN D22  [get_ports {  fmcHpc1LaP[7]  }];# Bank  28 VCCO - VADJ_FMC - IO_L17P_T2U_N8_AD10P_28
set_property PACKAGE_PIN C23  [get_ports {  fmcHpc1LaN[7]  }];# Bank  28 VCCO - VADJ_FMC - IO_L17N_T2U_N9_AD10N_28
set_property PACKAGE_PIN J25  [get_ports {  fmcHpc1LaP[8]  }];# Bank  28 VCCO - VADJ_FMC - IO_L5P_T0U_N8_AD14P_28
set_property PACKAGE_PIN H26  [get_ports {  fmcHpc1LaN[8]  }];# Bank  28 VCCO - VADJ_FMC - IO_L5N_T0U_N9_AD14N_28
set_property PACKAGE_PIN G20  [get_ports {  fmcHpc1LaP[9]  }];# Bank  28 VCCO - VADJ_FMC - IO_L10P_T1U_N6_QBC_AD4P_28
set_property PACKAGE_PIN F20  [get_ports {  fmcHpc1LaN[9]  }];# Bank  28 VCCO - VADJ_FMC - IO_L10N_T1U_N7_QBC_AD4N_28
set_property PACKAGE_PIN F22  [get_ports {  fmcHpc1LaP[10] }];# Bank  28 VCCO - VADJ_FMC - IO_L11P_T1U_N8_GC_28
set_property PACKAGE_PIN E22  [get_ports {  fmcHpc1LaN[10] }];# Bank  28 VCCO - VADJ_FMC - IO_L11N_T1U_N9_GC_28
set_property PACKAGE_PIN A20  [get_ports {  fmcHpc1LaP[11] }];# Bank  28 VCCO - VADJ_FMC - IO_L21P_T3L_N4_AD8P_28
set_property PACKAGE_PIN A21  [get_ports {  fmcHpc1LaN[11] }];# Bank  28 VCCO - VADJ_FMC - IO_L21N_T3L_N5_AD8N_28
set_property PACKAGE_PIN E19  [get_ports {  fmcHpc1LaP[12] }];# Bank  28 VCCO - VADJ_FMC - IO_L7P_T1L_N0_QBC_AD13P_28
set_property PACKAGE_PIN D19  [get_ports {  fmcHpc1LaN[12] }];# Bank  28 VCCO - VADJ_FMC - IO_L7N_T1L_N1_QBC_AD13N_28
set_property PACKAGE_PIN C21  [get_ports {  fmcHpc1LaP[13] }];# Bank  28 VCCO - VADJ_FMC - IO_L15P_T2L_N4_AD11P_28
set_property PACKAGE_PIN C22  [get_ports {  fmcHpc1LaN[13] }];# Bank  28 VCCO - VADJ_FMC - IO_L15N_T2L_N5_AD11N_28
set_property PACKAGE_PIN D20  [get_ports {  fmcHpc1LaP[14] }];# Bank  28 VCCO - VADJ_FMC - IO_L9P_T1L_N4_AD12P_28
set_property PACKAGE_PIN D21  [get_ports {  fmcHpc1LaN[14] }];# Bank  28 VCCO - VADJ_FMC - IO_L9N_T1L_N5_AD12N_28
set_property PACKAGE_PIN A18  [get_ports {  fmcHpc1LaP[15] }];# Bank  28 VCCO - VADJ_FMC - IO_L19P_T3L_N0_DBC_AD9P_28
set_property PACKAGE_PIN A19  [get_ports {  fmcHpc1LaN[15] }];# Bank  28 VCCO - VADJ_FMC - IO_L19N_T3L_N1_DBC_AD9N_28
set_property PACKAGE_PIN C18  [get_ports {  fmcHpc1LaP[16] }];# Bank  28 VCCO - VADJ_FMC - IO_L20P_T3L_N2_AD1P_28
set_property PACKAGE_PIN C19  [get_ports {  fmcHpc1LaN[16] }];# Bank  28 VCCO - VADJ_FMC - IO_L20N_T3L_N3_AD1N_28

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
