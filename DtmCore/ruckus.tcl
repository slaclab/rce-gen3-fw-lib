# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Get the family type
set family [getFpgaFamily]

# Check for valid FPGA 
if { $::env(PRJ_PART) != "XC7Z030FBG484-2" } {
   puts "\n\nERROR: PRJ_PART was not defined as XC7Z030FBG484-2 in the Makefile\n\n"; exit -1
}

# Load the dependent source code
loadRuckusTcl "$::DIR_PATH/../RceG3"
loadRuckusTcl "$::DIR_PATH/../RceEthernet"
loadRuckusTcl "$::DIR_PATH/../CobTiming"
loadRuckusTcl "$::DIR_PATH/../PpiCommon"
loadRuckusTcl "$::DIR_PATH/../PpiPgp"
loadRuckusTcl "$::DIR_PATH/../ZynqPcieMaster"

# Load local Source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -dir  "$::DIR_PATH/xdc/${family}"
loadIpCore      -dir  "$::DIR_PATH/coregen/GmiiToRgmiiCore"
loadBlockDesign -path "$::DIR_PATH/coregen/pcie_root/pcie_root.bd"
