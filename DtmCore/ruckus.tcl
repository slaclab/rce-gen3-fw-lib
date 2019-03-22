# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XC7Z030FBG484-2" && $::env(PRJ_PART) != "XCZU4CG-SFVC784-1-E" } {
#   puts "\n\nERROR: PRJ_PART must be either XC7Z030FBG484-2 or XCZU4CG-SFVC784-1-E in the Makefile\n\n"; exit -1
}

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../RceG3"
loadRuckusTcl "$::DIR_PATH/../RceEthernet"
loadRuckusTcl "$::DIR_PATH/../CobTiming"
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"

# Load local Source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -dir  "$::DIR_PATH/xdc/${family}"

# Check if ZYNQ 7000 series
if { ${family} eq {zynq} } {
   loadRuckusTcl "$::DIR_PATH/../ZynqPcieMaster"
   #loadIpCore      -path "$::DIR_PATH/coregen/GmiiToRgmiiCore/GmiiToRgmiiCore.xci"
   loadBlockDesign -path "$::DIR_PATH/coregen/pcie_root/pcie_root.bd"
}
