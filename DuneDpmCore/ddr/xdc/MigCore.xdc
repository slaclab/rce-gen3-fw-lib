##############################################################################
## This file is part of 'SLAC RCE Core'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'SLAC RCE Core', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

####################
# DDR: Constraints #
####################

# DDR.BYTE[7]
set_property -dict { PACKAGE_PIN AC2  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][7]   }]
set_property -dict { PACKAGE_PIN AB3  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][56]  }]
set_property -dict { PACKAGE_PIN AC3  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][57]  }]
set_property -dict { PACKAGE_PIN AA2  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][58]  }]
set_property -dict { PACKAGE_PIN AA1  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][59]  }]
set_property -dict { PACKAGE_PIN Y2   IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][7] }]
set_property -dict { PACKAGE_PIN Y1   IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][7] }]
set_property -dict { PACKAGE_PIN V2   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][60]  }]
set_property -dict { PACKAGE_PIN V1   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][61]  }]
set_property -dict { PACKAGE_PIN W2   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][62]  }]
set_property -dict { PACKAGE_PIN W1   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][63]  }]

# DDR.BYTE[6]
set_property -dict { PACKAGE_PIN Y4   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][6]   }]
set_property -dict { PACKAGE_PIN Y5   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][48]  }]
set_property -dict { PACKAGE_PIN AA5  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][49]  }]
set_property -dict { PACKAGE_PIN W5   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][50]  }]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][51]  }]
set_property -dict { PACKAGE_PIN AB4  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][6] }]
set_property -dict { PACKAGE_PIN AC4  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][6] }]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][52]  }]
set_property -dict { PACKAGE_PIN V3   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][53]  }]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][54]  }]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][55]  }]

# DDR.BYTE[5]
set_property -dict { PACKAGE_PIN AC7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][5]   }]
set_property -dict { PACKAGE_PIN AB8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][40]  }]
set_property -dict { PACKAGE_PIN AC8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][41]  }]
set_property -dict { PACKAGE_PIN W7   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][42]  }]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][43]  }]
set_property -dict { PACKAGE_PIN AB6  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][5] }]
set_property -dict { PACKAGE_PIN AB5  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][5] }]
set_property -dict { PACKAGE_PIN Y8   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][44]  }]
set_property -dict { PACKAGE_PIN Y7   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][45]  }]
set_property -dict { PACKAGE_PIN AA7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][46]  }]
set_property -dict { PACKAGE_PIN AA6  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][47]  }]


# DDR.BYTE[4]
set_property -dict { PACKAGE_PIN AC12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][4]   }]
set_property -dict { PACKAGE_PIN AB11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][32]  }]
set_property -dict { PACKAGE_PIN AB10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][33]  }]
set_property -dict { PACKAGE_PIN AA11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][34]  }]
set_property -dict { PACKAGE_PIN AA10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][35]  }]
set_property -dict { PACKAGE_PIN AB9  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][4] }]
set_property -dict { PACKAGE_PIN AC9  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][4] }]
set_property -dict { PACKAGE_PIN Y12  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][36]  }]
set_property -dict { PACKAGE_PIN AA12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][37]  }]
set_property -dict { PACKAGE_PIN Y10  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][38]  }]
set_property -dict { PACKAGE_PIN Y9   IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][39]  }]

# DDR.BYTE[3]
set_property -dict { PACKAGE_PIN AN2  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][3]   }]
set_property -dict { PACKAGE_PIN AN3  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][24]  }]
set_property -dict { PACKAGE_PIN AP3  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][25]  }]
set_property -dict { PACKAGE_PIN AM1  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][26]  }]
set_property -dict { PACKAGE_PIN AN1  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][27]  }]
set_property -dict { PACKAGE_PIN AL3  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][3] }]
set_property -dict { PACKAGE_PIN AL2  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][3] }]
set_property -dict { PACKAGE_PIN AK1  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][28]  }]
set_property -dict { PACKAGE_PIN AL1  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][29]  }]
set_property -dict { PACKAGE_PIN AK3  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][30]  }]
set_property -dict { PACKAGE_PIN AK2  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][31]  }]

# DDR.BYTE[2]
set_property -dict { PACKAGE_PIN AL6  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][2]   }]
set_property -dict { PACKAGE_PIN AM6  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][16]  }]
set_property -dict { PACKAGE_PIN AM5  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][17]  }]
set_property -dict { PACKAGE_PIN AP5  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][18]  }]
set_property -dict { PACKAGE_PIN AP4  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][19]  }]
set_property -dict { PACKAGE_PIN AN6  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][2] }]
set_property -dict { PACKAGE_PIN AP6  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][2] }]
set_property -dict { PACKAGE_PIN AM4  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][20]  }]
set_property -dict { PACKAGE_PIN AN4  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][21]  }]
set_property -dict { PACKAGE_PIN AK5  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][22]  }]
set_property -dict { PACKAGE_PIN AK4  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][23]  }]

# DDR.BYTE[1]
set_property -dict { PACKAGE_PIN AN8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][1]   }]
set_property -dict { PACKAGE_PIN AM9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][8]  }]
set_property -dict { PACKAGE_PIN AM8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][9]   }]
set_property -dict { PACKAGE_PIN AJ9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][10]   }]
set_property -dict { PACKAGE_PIN AK9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][11]  }]
set_property -dict { PACKAGE_PIN AN7  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][1] }]
set_property -dict { PACKAGE_PIN AP7  IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][1] }]
set_property -dict { PACKAGE_PIN AK8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][12]  }]
set_property -dict { PACKAGE_PIN AK7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][13]  }]
set_property -dict { PACKAGE_PIN AL8  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][14]  }]
set_property -dict { PACKAGE_PIN AL7  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][15]  }]

# DDR.BYTE[0]
set_property -dict { PACKAGE_PIN AJ12 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dm][0]   }]
set_property -dict { PACKAGE_PIN AL11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][0]   }]
set_property -dict { PACKAGE_PIN AM11 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][1]   }]
set_property -dict { PACKAGE_PIN AL10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][2]   }]
set_property -dict { PACKAGE_PIN AM10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][3]   }]
set_property -dict { PACKAGE_PIN AP11 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsT][0] }]
set_property -dict { PACKAGE_PIN AP10 IOSTANDARD DIFF_POD12_DCI } [get_ports { ddrInOut[dqsC][0] }]
set_property -dict { PACKAGE_PIN AN9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][4]   }]
set_property -dict { PACKAGE_PIN AP9  IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][5]   }]
set_property -dict { PACKAGE_PIN AJ10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][6]   }]
set_property -dict { PACKAGE_PIN AK10 IOSTANDARD POD12_DCI      } [get_ports { ddrInOut[dq][7]   }]

# DDR.ADDR
set_property -dict { PACKAGE_PIN AE12 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][0]  }]
set_property -dict { PACKAGE_PIN AF12 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][1]  }]
set_property -dict { PACKAGE_PIN AF11 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][2]  }]
set_property -dict { PACKAGE_PIN AG11 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][3]  }]
set_property -dict { PACKAGE_PIN AG10 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][4]  }]
set_property -dict { PACKAGE_PIN AG9  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][5]  }]
set_property -dict { PACKAGE_PIN AD10 IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][6]  }]
set_property -dict { PACKAGE_PIN AE9  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][7]  }]
set_property -dict { PACKAGE_PIN AH7  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][8]  }]
set_property -dict { PACKAGE_PIN AH6  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][9]  }]
set_property -dict { PACKAGE_PIN AG8  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][10] }]
set_property -dict { PACKAGE_PIN AH8  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][11] }]
set_property -dict { PACKAGE_PIN AD7  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][12] }]
set_property -dict { PACKAGE_PIN AD6  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][13] }]
set_property -dict { PACKAGE_PIN AE8  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][14] }]; # WE_B
set_property -dict { PACKAGE_PIN AF8  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][15] }]; # CAS_B
set_property -dict { PACKAGE_PIN AE7  IOSTANDARD SSTL12_DCI  } [get_ports { ddrOut[addr][16] }]; # RAS_B

# DDR.CTRL
set_property -dict { PACKAGE_PIN AE10 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[ckT][0] }]
set_property -dict { PACKAGE_PIN AF10 IOSTANDARD DIFF_SSTL12_DCI  } [get_ports { ddrOut[ckC][0] }]
set_property -dict { PACKAGE_PIN AF6  IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkP        }]
set_property -dict { PACKAGE_PIN AG6  IOSTANDARD DIFF_SSTL12      } [get_ports { ddrClkN        }]
set_property -dict { PACKAGE_PIN AG5  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[csL][0] }]
set_property -dict { PACKAGE_PIN AH4  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[cke][0] }]
set_property -dict { PACKAGE_PIN AJ6  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[odt][0] }]
set_property -dict { PACKAGE_PIN AE3  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[actL]   }]
set_property -dict { PACKAGE_PIN AF3  IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports { ddrOut[rstL]   }]
set_property -dict { PACKAGE_PIN AD2  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[bg][1]  }]
set_property -dict { PACKAGE_PIN AD1  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[bg][0]  }]
set_property -dict { PACKAGE_PIN AE2  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[ba][1]  }]
set_property -dict { PACKAGE_PIN AE1  IOSTANDARD SSTL12_DCI       } [get_ports { ddrOut[ba][0]  }]

##########
# Clocks #
##########

create_clock -period 5.000 -name ddrClkP  [get_ports {ddrClkP}]
create_generated_clock -name ddrIntClk00  [get_pins {U_Core/U_Mig/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT0}]
create_generated_clock -name ddrIntClk10  [get_pins {U_Core/U_Mig/U_MIG/inst/u_ddr4_infrastructure/gen_mmcme3.u_mmcme_adv_inst/CLKOUT6}]
set_property HIGH_PRIORITY true [get_nets {U_Core/U_Mig/U_MIG/inst/u_ddr4_infrastructure/div_clk}]
